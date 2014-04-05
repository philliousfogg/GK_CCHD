PROGRAM_NAME='Events'

DEFINE_VARIABLE


DEFINE_EVENT

// Lesson Events from the RMSUIMod
DATA_EVENT [vdvLesson]
{    
    STRING:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Parse Lesson Data
	IF ( FIND_STRING ( DATA.TEXT, 'LESSON_DATA', 1 ) )
	{
	    STACK_VAR INTEGER index
	    
	    //Get Index from the command
	    index = ATOI( getAttrValue( 'index', aCommand ) )
		
	    if ( index == RMS_LEVELS.Current )
	    {
		LIVE_LESSON.index	= index
		LIVE_LESSON.Subject 	= getAttrValue( 'subjt', aCommand )
		LIVE_LESSON.Instructor 	= getAttrValue( 'instr', aCommand )
		LIVE_LESSON.Type 	= ATOI ( getAttrValue( 'type', aCommand ) )
		LIVE_LESSON.Code	= getAttrValue( 'code', aCommand ) 
		LIVE_LESSON.Pin		= ATOI ( getAttrValue( 'pin', aCommand ) )
		
		if ( getAttrValue( 'ext', aCommand ) != 'null' )
		{
		    LIVE_LESSON.External = removeLastByte( getAttrValue( 'ext', aCommand ) )
		}
		
		LIVE_LESSON.Message  	= getAttrValue( 'message', aCommand )
		LIVE_LESSON.StartTime 	= getAttrValue( 'start', aCommand )
		LIVE_LESSON.EndTime 	= getAttrValue( 'end', aCommand )
		
		//Get other sites in the lesson
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_SystemNumber-lesson=',ITOA ( cLIVE ),
					'&sysnum=',ITOA(SYSTEM_NUMBER),
					'&code=',LIVE_LESSON.Code,
					'&type=',ITOA ( LIVE_LESSON.Type )" )
	    }
	    ELSE if ( index == RMS_LEVELS.Next )
	    {
		NEXT_LESSON.index	= index
		NEXT_LESSON.Subject 	= getAttrValue( 'subjt', aCommand )
		NEXT_LESSON.Instructor 	= getAttrValue( 'instr', aCommand )
		NEXT_LESSON.Type 	= ATOI ( getAttrValue( 'type', aCommand )  )
		NEXT_LESSON.Code  	= getAttrValue( 'code', aCommand  )
		NEXT_LESSON.Pin		= ATOI ( getAttrValue( 'pin', aCommand )  )
		
		if ( getAttrValue( 'ext', aCommand ) != 'null' )
		{
		   NEXT_LESSON.External	= removeLastByte( getAttrValue( 'ext', aCommand ) )
		}
		
		NEXT_LESSON.Message  	= getAttrValue( 'message', aCommand ) 
		NEXT_LESSON.StartTime 	= getAttrValue( 'start', aCommand )
		NEXT_LESSON.EndTime 	= getAttrValue( 'end', aCommand )
		
		//Get other sites in the lesson
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_SystemNumber-lesson=',ITOA ( cNEXT ),
					'&sysnum=',ITOA(SYSTEM_NUMBER),
					'&code=',NEXT_LESSON.Code,
					'&type=',ITOA ( NEXT_LESSON.Type )" )
	    }
	    
	    //Update Text on user interface
	    RMS_refreshLessonText()
	}
    }
}

// Internal Strings 
DATA_EVENT [vdvSystem]
{
    STRING:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Response to Dialog
	IF ( FIND_STRING ( DATA.TEXT, 'Dialog', 1) )
	{
	    RMS_endLessonResponse( aCommand )
	    RMS_removeSiteResponse( aCommand )
	    RMS_startSiteResponse( aCommand )
	    RMS_RMSMesgResponse( aCommand )
	    RMS_restartRoomRespone( aCommand )
	    Codec_RetryConnectCallResponse( aCommand )
	    DEVICES_pictureMuteTimeOut( aCommand )
	    System_changePinResponse( aCommand )
	}
    }
}

// Get pin master number from GW1 or GW2
DATA_EVENT [vdvSystem101]
DATA_EVENT [vdvSystem102]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'GET_PIN-'"
    }
}


DATA_EVENT [vdvSystems]
{
    COMMAND:
    {
	STACK_VAR _Systems system
	STACK_VAR INTEGER reqSys
	_DEVICES device
	
	#INCLUDE 'EventCommandParser.axi'
	
	//Set the data for the responding system
	if ( FIND_STRING ( DATA.TEXT, 'SetSystemData-', 1 ))
	{	    	    
	    //Add to structure
	    Systems_AddSystem( aCommand )
	}
	
	//Return System Data to sender
	if ( FIND_STRING ( DATA.TEXT, 'GetSystemData-', 1 ))
	{
	    STACK_VAR INTEGER index
	    
	    index = SYSTEM_getIndexFromSysNum( SYSTEM_NUMBER )
	    
	    reqSys = DATA.DEVICE.SYSTEM
	    
	    // if primary GW
	    if ( reqSys == 101 )
	    {
		reqSys = LENGTH_SYSTEMS + 1
	    }
	    
	    // if secondary GW
	    else if ( reqSys == 102 )
	    {
		reqSys = LENGTH_SYSTEMS + 2
	    }
	    
	    SYSTEM_sendCommand ( vdvSystems[reqSys],"'SetSystemData-',
						    'sysnum=',ITOA(SYSTEM_NUMBER),
						    '&name=',Systems[index].name,
						    '&loc=',Systems[index].location,
						    '&comp=',Systems[index].company,
						    '&receive=',ITOA ( Systems[index].receiveOnly ),
						    '&mobile=',ITOA ( Systems[index].mobile ),
						    '&contact=',Systems[index].contact,
						    '&invcam=',ITOA ( Systems[index].cameraInverse )" )
	    
	    //Get Current Dialer Status
	    SEND_COMMAND vdvCodec, "'?DIALERSTATUS'"
	}
	
	//Get RMS Server details
	if ( FIND_STRING ( DATA.TEXT, 'SetRMSServer-', 1 ) )
	{
	    if ( DATA.DEVICE.SYSTEM == SYSTEM_NUMBER )
	    {
		STACK_VAR CHAR Url[768]
		
		//Get URL Attribute
		RMS_SERVER_URL = GetAttrValue('url',aCommand)
		
		//Set RMS Server Address
		RMSSetServer(RMS_SERVER_URL)
	    }
	}
	
	//Refreshes the User Interface
	If ( FIND_STRING ( DATA.TEXT, 'DialogOkCancel', 1 ) )
	{
	    if ( DATA.DEVICE.SYSTEM == SYSTEM_NUMBER )
	    {
		Dialog_Add( aCommand )
	    }
	}
	
	//Set the data for the responding system
	if ( FIND_STRING ( DATA.TEXT, 'DEVICES_Add-', 1 ))
	{
	    if ( DATA.DEVICE.SYSTEM == SYSTEM_NUMBER )
	    {
		device.Name			= getAttrValue('name',aCommand)
		device.Manufacturer		= getAttrValue('man',aCommand)
		device.Model		= getAttrValue('model',aCommand)
		device.SerialNumber		= getAttrValue('sn',aCommand)
		device.IPAddress		= getAttrValue('ip',aCommand)
		device.BaudRate		= getAttrValue('baud',aCommand )
		device.Password		= getAttrValue('password',aCommand )
		device.vDevice.NUMBER	= ATOI ( getAttrValue('devd',aCommand) )
		device.vDevice.PORT		= ATOI ( getAttrValue('devp',aCommand) )
		device.vDevice.SYSTEM	= ATOI ( getAttrValue('devs',aCommand) )
		device.pDevice.NUMBER	= ATOI ( getAttrValue('pdd',aCommand) )
		device.pDevice.PORT		= ATOI ( getAttrValue('pdp',aCommand) )
		device.pDevice.SYSTEM	= ATOI ( getAttrValue('pds',aCommand) )
		
		//Add device to device list
		DEVICES_Add( device )
	    }
	}
	
	//Refresh UI
	if ( FIND_STRING ( DATA.TEXT, 'RefreshUI-', 1 ) )
	{  
	    if ( DATA.DEVICE.SYSTEM == SYSTEM_NUMBER )
	    {
		STACK_VAR CHAR blankArray[10][255]
		
		// All popups on page
		SYSTEM_hidePopups()
		
		//Reset Previous call state to refresh the call control
		PREVIOUS_CALL_STATE = blankArray
		
		//Send Splash Screen Text
		SEND_COMMAND dvTP, "'TEXT', ITOA( UIBtns[ 3 ] ),'-', SPLASH_SCREEN_TEXT"
		
		if ( PERMISSION_LEVEL )
		{
		    SYSTEM_showMain()
		}
		else
		{
		    //if this room is the teacher room then gather together all other 
		    //rooms in the lesson.
		    
		    //Clear keypad
		    SEND_COMMAND dvTP, "'@PPK-_login'"
		    
		    SEND_COMMAND dvTP, "'PAGE-Login'"
		    
		    //Set External Control to off
		    EXTERNAL_SITE = 0
		}
		
		//Refresh RMS text
		RMS_refreshLessonText()
		
		if ( !RMS_LEVELS.Current )
		{
		    //Hide Extend and End meeting Buttons
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[30] ),',0'" //End Meeting
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[31] ),',0'" //Extend Meeting 
		}
		ELSE
		{
		    //Show Extend and End meeting Buttons
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[30] ),',1'" //End Meeting
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[31] ),',1'" //Extend Meeting 
		}
		
		//Refresh Dial Status on all codecs
		SEND_COMMAND vdvCodecs, "'?DIALERSTATUS'"
		
		//Send Lighting timeout to touch panel
		SEND_COMMAND dvTPLights, "'TEXT',ITOA ( UILightsBtns[27] ),'-',LIGHTS_TIMEOUT_CHAR[LIGHTS_TIMEOUT]"
		
		//Show Projector Buttons
		System_setProjectorButtons()
	    }
	}
	
	//Receives new system pin
	if ( FIND_STRING ( DATA.TEXT, 'SYSTEM_PIN-', 1 ) )
	{
	    MASTER_PIN = ATOI ( getAttrValue( 'pin', aCommand ) )
	}
	
	
	//Extends Recurring Meeting by adding a new meeting
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_ExtendRecurring-', 1 ) )
	{
	    STACK_VAR CHAR code[16]
	    
	    code = getAttrValue('code', aCommand ) 
	    
	    //Is this system in this lesson
	    if ( FIND_STRING( LIVE_LESSON.Code, code, 1 ) )
	    {
		//Starts a new lesson from the end time of the existing lesson
		SEND_COMMAND vdvSystem, "'LESSON_Start-type=',ITOA(LIVE_LESSON.type),'&pin=',ITOA(LIVE_LESSON.pin),
					      '&sysnum=',ITOA( SYSTEM_NUMBER ),
					      '&code=',LIVE_LESSON.Code,
					      '&start=',LEFT_STRING ( LIVE_LESSON.EndTime, 2 ),':02:00',
					      '&dur=60',
					      '&instr=',LIVE_LESSON.Instructor,
					      '&subject=',LIVE_LESSON.Subject,' [Extended]',
					      '&message=',LIVE_LESSON.message"
	    }
	}
	
	//Force Shutdown on reoccurring Meetings
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_forceShutdown-', 1 ) )
	{
	    STACK_VAR CHAR code[16]
	    
	    code = getAttrValue('code', aCommand ) 
	    
	    //Is this system in this lesson
	    if ( FIND_STRING( LIVE_LESSON.Code, code, 1 ) )
	    {
		if ( ATOI( getAttrValue('func', aCommand )  ) )
		{
		    ON[RECURRING_SHUTDOWN]
		    
		    //Disconnect call in the lesson
		    PULSE[vdvCodec, DIAL_FLASH_HOOK]
		}
		else
		{
		    OFF[RECURRING_SHUTDOWN]
		}
	    }
	    
	    //Refresh Lesson Text on Screen
	    RMS_refreshLessonText()
	}
	
	//Lesson Reserve Failure
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_reserveFailure-', 1 ) )
	{
	    STACK_VAR INTEGER sysnum
	    STACK_VAR INTEGER index
	    
	    sysnum = ATOI ( getAttrValue('sysnum', aCommand ) )
	    
	    index = SYSTEM_getIndexFromSysNum(SysNum)
	    
	    //Is it this system
	    if ( SYSTEMS[index].thisSystem )
	    {
		SEND_COMMAND vdvSystem, "'DialogOkCancel-ref=LessonFailure',
						'&title=Appointment Reservation Failed',
						'&message=This room is in use at ',getAttrValue( 'time', aCommand ),$0A,$0D,$0A,$0D,
						'Press ok to continue',
						'&res1=Ok&norepeat=1'"
	    }
	    else
	    {
		SEND_COMMAND vdvSystem, "'DialogOkCancel-ref=LessonFailure',
						'&title=Appointment Reservation Failed',
						'&message=',SYSTEMS[index].name,' is in use at ',getAttrValue( 'time', aCommand ),'. It will not be added to the lesson.',$0A,$0D,$0A,$0D,
						'Press ok to continue',
						'&res1=Ok&norepeat=1'"
	    }
	}
	
	//Clears lesson from the system
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_siteEnd', 1) )
	{
	    STACK_VAR INTEGER sysnum
	    STACK_VAR INTEGER lesson
	    STACK_VAR INTEGER index
	    
	    SEND_STRING 0, "'End Sys# ', ITOA ( sysnum ), ' Lesson ', ITOA ( lesson )"
	    
	    sysnum = ATOI ( getAttrValue('sysnum', aCommand ) )
	    lesson = ATOI ( getAttrValue('lesson', aCommand ) )
	    
	    //Get the Index from the system number
	    index = SYSTEM_getIndexFromSysNum( sysnum )
	    
	    if ( lesson == cNEXT )
	    {
		//Clear Site from Lesson
		SYSTEMS[index].nextLesson = 0
		Systems[index].RoomType = 0
	    }
	    else if ( lesson == cLIVE)
	    {
		//Clear Site from Lesson
		SYSTEMS[index].liveLesson = 0
		Systems[index].RoomType = 0
	    }
	    
	    //Update Text on user interface
	    RMS_refreshLessonText()
	    
	    //Update UI List
	    UPDATE_SYSTEM_LIST = UILIST[SystemUIList].position
	}
	
	
	//Receives a system number from system
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_SystemNumber', 1 ) )
	{
	    STACK_VAR INTEGER sysnum
	    STACK_VAR INTEGER index
	    STACK_VAR INTEGER lesson
	    STACK_VAR CHAR code[64]
	    
	    sysnum = ATOI ( getAttrValue('sysnum', aCommand ) )
	    lesson = ATOI ( getAttrValue('lesson', aCommand ) )
	    code = getAttrValue('code', aCommand )
	    
	    //Get the Index from the system number
	    index = SYSTEM_getIndexFromSysNum( sysnum )
	    
	    if ( lesson == cNEXT )
	    {
		//
		if ( FIND_STRING(NEXT_LESSON.code, code, 1 ) )
		{
		    
		    //Set the system to the same lesson as this system lesson
		    ON[SYSTEMS[index].nextLesson]
		    
		    Systems[index].RoomType = ATOI ( getAttrValue('type', aCommand) )
		}
	    }
	    else if ( lesson == cLIVE)
	    {
		//
		if ( FIND_STRING( LIVE_LESSON.code, code, 1 ) )
		{
		    
		    ON[SYSTEMS[index].liveLesson]
		    
		    Systems[index].RoomType = ATOI ( getAttrValue('type', aCommand) )
		}
	    }
	    
	    //Update Text on user interface
	    RMS_refreshLessonText()
	    
	    //Update UI List
	    UPDATE_SYSTEM_LIST = UILIST[SystemUIList].position
	}
	
	
	//End Call from MCU 
	if ( FIND_STRING ( DATA.TEXT, 'EndMCUCall-', 1 ) )
	{
	    //if 'this' system is in the same lesson as the MCUCall then end call
	    if ( FIND_STRING ( LIVE_LESSON.code, GetAttrValue('code',aCommand), 1 ) OR FIND_STRING ( NEXT_LESSON.code, GetAttrValue('code',aCommand), 1 ) )
	    {
		//Disconnect call in the lesson
		PULSE[vdvCodec, DIAL_FLASH_HOOK]
	    }
	}
	
	//Set the Call Status Field 
	if ( FIND_STRING ( DATA.TEXT, 'SYSTEM_CallStatus-', 1 ))
	{
	    STACK_VAR CHAR Status[16]
	    
	    Status = GetAttrValue('status',aCommand)
	    
	    //if connected or on hold so site
	    if ( FIND_STRING ( Status, 'Connected', 1 ) OR FIND_STRING ( Status, 'OnHold', 1 ) )
	    {
		//Updates the Call status field in the System List
		Systems_CallStatus( DATA.DEVICE.SYSTEM, GetAttrValue('site',aCommand) )
		
		//Set Boolean status
		ON[Systems[DATA.DEVICE.SYSTEM].inCall]
	    }
	    ELSE
	    {
		//Updates the Call status field in the System List
		Systems_CallStatus( DATA.DEVICE.SYSTEM, GetAttrValue('status',aCommand) )
		
		//Set Boolean status
		OFF[Systems[DATA.DEVICE.SYSTEM].inCall]
	    }
	}
	
	//Receive extension request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_Extend', 1 ) )
	{
	    //if the command is for this system
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == system_number )
	    {
		//Send Extension request to RMS Server
		SEND_COMMAND vdvRMSEngine, "'EXTEND-',getAttrValue( 'mins', aCommand )"
	    }
	}
	
	//Receive end request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_End', 1 ) )
	{
	    //if the command is for this system
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == system_number )
	    {
		//Send Extension request to RMS Server
		SEND_COMMAND vdvRMSEngine, "'ENDNOW'"
	    }
	}
	
	//Receive end request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_Start', 1 ) )
	{
	    //if the command is for this system
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == system_number )
	    {
		//Send lesson start request to RMS Server
		SEND_COMMAND vdvRMSEngine, "'RESERVE-',LDATE,',',
						    GetAttrValue('start',aCommand),',',
						    GetAttrValue('dur',aCommand),',',
						    GetAttrValue('subject',aCommand),
						    '&pin=',GetAttrValue('pin',aCommand),
						    '&code=',GetAttrValue('code',aCommand),
						    '&type=',GetAttrValue('type',aCommand),',',
						    GetAttrValue('message',aCommand)"
	    }
	}
	
	//Set Camera Preset
	if ( FIND_STRING ( DATA.TEXT, 'SET_CAMERA_PRESET-', 1 ) )
	{
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == SYSTEM_NUMBER )
	    {
		CODEC_setCameraPreset( ATOI ( GetAttrValue('camera',aCommand) ),  ATOI ( GetAttrValue('preset',aCommand) ), DATA.DEVICE.SYSTEM )
	    }
	}
	
	//Preset Saved Alert User
	if ( FIND_STRING ( DATA.TEXT, 'CAMERA_PRESET_SAVED', 1 ) )
	{
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == SYSTEM_NUMBER )
	    {
		SYSTEM_Alert( 'Camera Preset',  "'Camera Preset ',GetAttrValue('preset',aCommand),' saved.',$0D,$0A,$0D,$0A,'Press ok to continue.'")
	    }
	}
	
	//Recall Camera Preset
	if ( FIND_STRING ( DATA.TEXT, 'RECALL_CAMERA_PRESET-', 1 ) )
	{
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == SYSTEM_NUMBER )
	    {
		CODEC_getCameraPreset( ATOI ( GetAttrValue('preset',aCommand) ) )
	    }
	}
	
	//Set Lighting Preset
	if ( FIND_STRING ( DATA.TEXT, 'SET_LIGHTING_PRESET-', 1 ) )
	{
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == SYSTEM_NUMBER )
	    {
		LIGHTS_setPreset( ATOI ( GetAttrValue('preset',aCommand) ), DATA.DEVICE.SYSTEM )
	    }
	}
	
	//Preset Saved Alert User
	if ( FIND_STRING ( DATA.TEXT, 'LIGHTING_PRESET_SAVED', 1 ) )
	{
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == SYSTEM_NUMBER )
	    {
		SYSTEM_Alert( 'Lighting Preset',  "'Lighting Preset ',GetAttrValue('preset',aCommand),' saved.',$0D,$0A,$0D,$0A,'Press ok to continue.'")
	    }
	}
    }
}

DEFINE_PROGRAM


