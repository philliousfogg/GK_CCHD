PROGRAM_NAME='CodecSetupClass'

#INCLUDE 'SNAPI.axi'

DEFINE_CONSTANT

CHAR CONF_STATE_IDLE[] = 'Idle'
CHAR CONF_STATE_NEG[]  = 'Negotiating'
CHAR CONF_STATE_CONN[] = 'Connected'
CHAR CONF_STATE_RING[] = 'Ringing'
CHAR CONF_STATE_DIAL[] = 'Dialing'
CHAR CONF_STATE_ONHOLD[] = 'OnHold'

INTEGER MAX_CALLS = 4


DEFINE_TYPE

DEFINE_TYPE

STRUCTURE _CALLS 
{
    INTEGER ID     //Index
    INTEGER CallID //Last Known Call ID 
    Char State[15] //State
    Char Direction[32] //Direction of the Call
    Char Type[32] //Call Type
    Char rate[16] //Call Rate
    Char encryption[16] //Encryption
    Char presenting[16] //Call presenting
    Char remoteNumber[255] //Remote Number
    Char callBackNumber[255] //Call Back Number
    Char DisplayName[255] //Display Name
    Char protocol[16] //Sip H232 ISDN etc
    INTEGER Selected 
}


STRUCTURE _Codec
{
    CHAR FWVersion[16]
    CHAR SIPURL[255]
    CHAR SIPProxy[255]
    CHAR SIPStatus[16]
    
    CHAR SWVersion[16]
    CHAR E164[16]
    CHAR H323ID[255]
    CHAR Gatekeeper[255]
    CHAR H323Status[255]
}

STRUCTURE _PRESET
{
    INTEGER ID
    INTEGER CameraID
    CHAR LABEL[32] //Stores a label associated with the preset
    CHAR PTZF[255] //Stores the PTZF Command
}

DEFINE_VARIABLE 

_Codec Codec
_CALLS Calls[4]
VOLATILE INTEGER CAMERA_PRESET_ACTIVE[LENGTH_SYSTEMS]

VOLATILE CHAR CAM_PRESET_BUFFER[1024]

VOLATILE CHAR CAMERA_LABELS[4][16] = {
    
    'Front',
    'Back',
    'Students',
    'Instructor'
}

VOLATILE _PRESET CAMERA_PRESETS[10]

VOLATILE CHAR CURRENT_CAMERA_POSTION[2][255]

VOLATILE INTEGER SELFVIEW_POSITION

//Remaps Camera buttons if cameras are reversed
DEFINE_FUNCTION Codec_setCameraMapping (INTEGER index)
{
    if ( systems[index].cameraInverse )
    {
	MAPPED_CAMERAS[1] = 2
	MAPPED_CAMERAS[2] = 1
    }
    ELSE
    {
	MAPPED_CAMERAS[1] = 1
	MAPPED_CAMERAS[2] = 2
    }
    
    //Set Camera Mapping 
    SEND_COMMAND dvTPCodec, "'TEXT',ITOA ( VCCameraBtns[7] ),'-',CAMERA_LABELS[ MAPPED_CAMERAS[1] ]"
    SEND_COMMAND dvTPCodec, "'TEXT',ITOA ( VCCameraBtns[8] ),'-',CAMERA_LABELS[ MAPPED_CAMERAS[2] ]"
	
    //Set Camera Mapping
    SEND_COMMAND dvTPCodec, "'TEXT',ITOA ( VCCameraBtns[31] ),'-',CAMERA_LABELS[ MAPPED_CAMERAS[1] + 2 ]"
    SEND_COMMAND dvTPCodec, "'TEXT',ITOA ( VCCameraBtns[32] ),'-',CAMERA_LABELS[ MAPPED_CAMERAS[2] + 2 ]"
}


DEFINE_FUNCTION char[255] getDelimitedData(char aData[255], char delimiter[1])
{
    STACK_VAR Char sData[255]
    
    //get <data><delimiter>
    sData = REMOVE_STRING ( aData, delimiter, 1 )
    
    //remove <delimiter>
    SET_LENGTH_STRING ( sData, ( LENGTH_STRING( sData ) - 1 ) )
    
    return sData
} 




//Returns the codec call state for all call channels
DEFINE_FUNCTION integer CODEC_isCall( CHAR Status[] )
{
    STACK_VAR INTEGER i 
    FOR ( i=1; i<=MAX_CALLS; i++ )
    {
	if ( CALLS[i].STATE == Status )
	{
	    return i 
	}
    }
    return 0
}


//Evaluates the response to reset attempt
DEFINE_FUNCTION Codec_RetryConnectCallResponse( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer callIndex 
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'callfail', 1 ) )
    {
	//remove 'siteend'
	REMOVE_STRING ( ref, 'callfail', 1 )
	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	//get index from response
	callIndex = ATOI ( ref )
	
	Switch ( response )
	{ 
	    //Reset call attempt
	    CASE 1: 
	    {
		CALL_ATTEMPT[callIndex] = 0
		SEND_STRING 0, 'ok'
	    }
	    CASE 2: 
	    {
		SEND_STRING 0, 'Cancel'
	    }
	}
    }
}

//See if there are any call attempts in progress
DEFINE_FUNCTION integer CODECS_CallAttempts()
{
    STACK_VAR INTEGER i 
    
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	if ( CALL_ATTEMPT[i] > 4 )
	{
	    return 1
	}
    }
    
    return 0
}

//Finds if the site is connected point to point to a room in the lesson
DEFINE_FUNCTION integer CODEC_findPointToPointSite()
{
    STACK_VAR INTEGER i, index
    
    index = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
    
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	//if a point to point call and not a virtual room
	if ( FIND_STRING ( Systems[index].callstatus, Systems[i].contact, 1 ) AND Systems[i].systemNumber < 500 )
	{
	    return i
	}
    }
    
    return 0
}

//Attempts connection to site
DEFINE_FUNCTION CODEC_connectToSite( dev codec, integer CodecIndex, CHAR name[255] )
{
    
    SEND_STRING 0, "'166 Name: ', name,' '"
    
    //How many attempts have been made to call the site
    if ( CALL_ATTEMPT[CodecIndex] < 3 )
    {	
	//is the system already connected to the system
	if ( !FIND_STRING ( SYSTEMS[CodecIndex].callStatus, name, 1 ) )
	{
	    SEND_STRING 0, "'System not Connected'"
	    
	    CALL_ATTEMPT[CodecIndex]++
	    
	    //if the system is not in a call then attempt connection 
	    if ( systems[codecIndex].callStatus == 'idle' )
	    {
		if ( [codec, DATA_INITIALIZED ] )
		{
		    SEND_STRING 0, "'Call not connected'"
		    
		    //Attempt to dial other site from this site
		    SEND_COMMAND codec, "'DIALNUMBER-', name"
		    
		    //if the site is a virtual room
		    if ( systems[codecIndex].systemnumber > 500 )
		    {
			//Show Screen Layout Button
			SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[58] ),',1'"
		    }
		}
	    }
	}
	
	//System is connected to the site
	else
	{
	    //Site Connected
	    CALL_ATTEMPT[CodecIndex] = 0
	    
	    //Check to see if all 
	    if ( !CODECS_CallAttempts() )
	    {
		//Hide Alert button 
		SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[81] ),',0'"
	    }
	}
    }
    //if this is the 4th attempt then inform user of failure
    else
    {	
	if ( CALL_ATTEMPT[CodecIndex] != 5 )
	{
	    //If the user and ask if the user wants to try again.
	    SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=callfail',ITOA ( CodecIndex ),'&title=Call Failed',
					     '&message=',Systems[CodecIndex].name,' cannot connect call to ',name,$0A,$0D,$0A,$0D,
					     'What do you want to do?',
					     '&res1=Try Again&res2=Cancel&norepeat=1'")
					     
	    
	    //Send Error to RMS
	    SEND_COMMAND vdvRMSEngine,"'MAINT-',Systems[CodecIndex].name,' cannot connect call to ',name"
	    
	    //Show Alert button 
	    SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[81] ),',1'"
	    
	    //Set to 5 to indeicate that user has been notified
	    CALL_ATTEMPT[CodecIndex] = 5
	}
    }
}

DEFINE_FUNCTION CODEC_SwitchCameras(integer SysNum, integer Camera)
{
    ACTIVE_CAMERA[SysNum] = Camera

    //Video Switching
    SEND_COMMAND vdvCodecs[SysNum], "'INPUT-HDMI,',ITOA( Camera )"
}

//Calls all the sites in the Lesson (This Function Appears in the main line
//and is called every 5 seconds
DEFINE_FUNCTION CODEC_connectSites()
{
    //If the system is ready to connect sites
    if ( CONNECT_SITES )
    {
	STACK_VAR INTEGER numberOfSites
	
	//Which Lesson is being used
	if ( RMS_LEVELS.Current )
	{
	    //How many calls in the lesson
	    numberOfSites = SYSTEM_countLessonSites(cLIVE)
	}
	ELSE 
	{
	    //How many calls in the lesson
	    numberOfSites = SYSTEM_countLessonSites(cNEXT)
	}
	
	//if there are only 2 sites then connect point to point
	if ( numberOfSites == 2 )
	{
	    STACK_VAR INTEGER i,ct 
	    
	    SEND_STRING 0, "'PTP'"
	    
	    //Find the other site in the lesson that is not this system
	    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
	    {
		//Check if system exists
		if ( SYSTEMS[i].systemNumber )
		{
		    if ( RMS_LEVELS.Current )
		    {
			//Check the system is in this lesson
			if ( SYSTEMS[i].LiveLesson AND !SYSTEMS[i].thisSystem )
			{
			    ct = i
			    break
			}
		    }
		    ELSE 
		    {
			//Check the system is in this lesson
			if ( SYSTEMS[i].NextLesson AND !SYSTEMS[i].thisSystem )
			{
			    ct = i
			    break
			}
		    }
		}
	    }
	    
	    //if there is a system to dial.
	    if ( ct )
	    {
		STACK_VAR INTEGER thisIndex 
		
		thisIndex = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
		
		CODEC_connectToSite(vdvCodec, thisIndex, Systems[ct].contact)
	    }
	}
	
	//If a multisite call with a virtual room
	else
	{
	    STACK_VAR INTEGER index
	    
	    SEND_STRING 0, "'Multisite'"
	    
	    //Which Lesson is being used
	    if ( RMS_LEVELS.Current )
	    {
		//Get the system number of the virtual room
		index = SYSTEM_findVirtualRoom(cLIVE)
	    }
	    ELSE 
	    {
		//Get the system number of the virtual room
		index = SYSTEM_findVirtualRoom(cNEXT) 
	    }
	    
	    //if there is a virtual room then dial the room from each site
	    if ( index )
	    {
		STACK_VAR INTEGER ptpIndex
		
		//Check for point to point calls
		ptpIndex = CODEC_findPointToPointSite()
		
		SEND_STRING 0, "'ptpIndex: ',ITOA ( ptpIndex )"
		
		//End point to point call
		if ( ptpIndex )
		{
		    //Disconnect call in the lesson
		    PULSE[vdvCodecs[SYSTEM_NUMBER], DIAL_FLASH_HOOK]
		}
		else
		{
		    STACK_VAR INTEGER  i
		    
		    //Find the other site in the lesson that is not this system
		    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
		    {
			//Check if system exists and the system is not a virtual room
			if ( SYSTEMS[i].systemNumber AND SYSTEMS[i].systemNumber < 500 )
			{
			    if ( RMS_LEVELS.Current )
			    {
				//Check the system is in this lesson
				if ( SYSTEMS[i].LiveLesson)
				{
				    //Connect to the virtual room
				    CODEC_connectToSite(vdvCodecs[SYSTEMS[i].systemNumber], i, Systems[index].contact)
				}
			    }
			    ELSE 
			    {
				//Check the system is in this lesson  and not the virtual room
				if ( SYSTEMS[i].NextLesson)
				{
				    //Connect to the virtual room
				    CODEC_connectToSite(vdvCodecs[SYSTEMS[i].systemNumber], i, Systems[index].contact)
				}
			    }
			}
		    }
		}
	    }
	    else
	    {
		//Send Message to RMS
		//SEND_COMMAND vdvRMSEngine,"'MAINT-',Systems[CodecIndex].name,' cannot connect call to ',name"
	    }
	}
    }
}

//Set the camera speed of the current live camera
DEFINE_FUNCTION CODEC_setCameraSpeed(INTEGER speed)
{
    //Set to slow camera speed
    if ( ACTIVE_CAMERA[ACTIVE_SYSTEM] == 1 )
    {
	SEND_LEVEL vdvCodecs[ACTIVE_SYSTEM], 29, speed
	SEND_LEVEL vdvCodecs[ACTIVE_SYSTEM], 30, speed
    }
    else
    {
	SEND_LEVEL vdvCodecs_Cam2[ACTIVE_SYSTEM], 29, speed
	SEND_LEVEL vdvCodecs_Cam2[ACTIVE_SYSTEM], 30, speed
    }
}

//Set Camera Preset for a given camera
DEFINE_FUNCTION CODEC_setCameraPreset(INTEGER camera, INTEGER presetID, INTEGER sysNum)
{
    //Set Auto Focus
    PULSE[ vdvCodec, 172 ]
    
    WAIT 10
    {
	//Get Current camera postion
	if ( camera == 1 )
	{
	    SEND_COMMAND vdvCodec, "'?CAMERA_PTZF'"
	}
	ELSE
	{
	    SEND_COMMAND vdvCodecPres, "'?CAMERA_PTZF'"
	}
    }
    
    //Wait for camera postion
    WAIT 20
    {
	//Store in data structure
	CAMERA_PRESETS[presetID].ID = presetID
	CAMERA_PRESETS[presetID].CameraID = camera
	CAMERA_PRESETS[presetID].PTZF = CURRENT_CAMERA_POSTION[camera]
	
	//Alert Sender system that preset has been saved 
	SYSTEM_sendCommand ( vdvSystem, "'CAMERA_PRESET_SAVED-sysnum=',ITOA(sysNum),'&preset=',ITOA( presetID )")
	
	//Convert Data Structure to string
	VARIABLE_TO_STRING (CAMERA_PRESETS, CAM_PRESET_BUFFER, 1 )
	
	//Save to disk
	SaveFile('CameraPresets.txt', CAM_PRESET_BUFFER )
    }
}

//Recall Camera Preset
DEFINE_FUNCTION CODEC_getCameraPreset(INTEGER presetID)
{
    //Make sure preset is set
    if ( CAMERA_PRESETS[presetID].ID AND CAMERA_PRESETS[presetID].CameraID )
    {
	//Change Camera
	CODEC_SwitchCameras(SYSTEM_NUMBER, CAMERA_PRESETS[presetID].CameraID)
	
	//Set PTZF
	if ( CAMERA_PRESETS[presetID].CameraID == 1 )
	{
	    SEND_COMMAND vdvCodec, "'CAMERA_PTZF-',CAMERA_PRESETS[presetID].PTZF"
	}
	ELSE
	{
	    SEND_COMMAND vdvCodecPres, "'CAMERA_PTZF-',CAMERA_PRESETS[presetID].PTZF"
	}
    }
}

//Mover Camera 
DEFINE_FUNCTION CODEC_moveCamera( integer Direction )
{
    SET_PULSE_TIME(2)
    
    if ( ACTIVE_SYSTEM == SYSTEM_NUMBER )
    {
	if ( Direction )
	{
	    if ( ACTIVE_CAMERA[ACTIVE_SYSTEM] == 1 )
	    {
		ON[vdvCodecs[ACTIVE_SYSTEM], Direction]
	    }
	    else
	    {
		ON[vdvCodecs_Cam2[ACTIVE_SYSTEM], Direction]
	    }
	}
	ELSE 
	{
	    OFF[vdvCodecs[ACTIVE_SYSTEM], ZOOM_IN ]
	    OFF[vdvCodecs[ACTIVE_SYSTEM], ZOOM_OUT ]
	    OFF[vdvCodecs[ACTIVE_SYSTEM], PAN_LT ]
	    OFF[vdvCodecs[ACTIVE_SYSTEM], PAN_RT ]
	    OFF[vdvCodecs[ACTIVE_SYSTEM], TILT_DN ]
	    OFF[vdvCodecs[ACTIVE_SYSTEM], TILT_UP ]
	    
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], ZOOM_IN ]
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], ZOOM_OUT ]
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], PAN_LT ]
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], PAN_RT ]
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], TILT_DN ]
	    OFF[vdvCodecs_Cam2[ACTIVE_SYSTEM], TILT_UP ]   
	}
    }
    ELSE
    {
	if ( Direction )
	{
	    if ( ACTIVE_CAMERA[ACTIVE_SYSTEM] == 1 )
	    {
		PULSE[vdvCodecs[ACTIVE_SYSTEM], Direction]
	    }
	    else
	    {
		PULSE[vdvCodecs_Cam2[ACTIVE_SYSTEM], Direction]
	    }
	}
    }
    
    SET_PULSE_TIME(5)
}

DEFINE_START 

//Get Camera Presets from disk
ReadFile('CameraPresets.txt', CAM_PRESET_BUFFER)

//Store in Camera Presets Structre
STRING_TO_VARIABLE ( CAMERA_PRESETS, CAM_PRESET_BUFFER, 1 )

//Define Module
//DEFINE_MODULE 'CISCO_TC_COMM_dr1_0_0' codec(vdvCodec, dvCodec)
DEFINE_MODULE 'CiscoTCThinClient' m( dvCodec, vdvCodecP )
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSCodec(vdvCodec, dvCodec, vdvRMSEngine)

DEFINE_EVENT 

DATA_EVENT [vdvCodecPres]
{
    COMMAND:
    {
	if ( FIND_STRING ( DATA.TEXT, 'CAMERA_PTZF-', 1 ) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    
	    //Stores Current camera position
	    CURRENT_CAMERA_POSTION[DATA.DEVICE.PORT] = DATA.TEXT
	}
    }
}


DATA_EVENT [vdvCodec]
{
    ONLINE:
    {
	//Switch Auto Answer On
	ON[vdvCodec, 239]
	
	//Switch On Camera Scaling
	ON[vdvCodec, 312]
	
	//Send call status to System List
	SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=NO NETWORK'" )
    }
    
    COMMAND:
    {
	STACK_VAR Char CallStatus[255]
	
	if ( FIND_STRING ( data.text, 'FWVERSION-', 1 ) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    Codec.FWVersion = data.text
	}
	if ( FIND_STRING ( data.text, 'VERSION', 1 ) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    Codec.SWVersion = data.text
	}
	if ( FIND_STRING ( data.text, 'H323-', 1) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    
	    //Remove E164 Number
	    Codec.E164 = getDelimitedData(DATA.TEXT, ',')
	    
	    Codec.H323ID = getDelimitedData(DATA.TEXT, ',')
	    Codec.GateKeeper = getDelimitedData(DATA.TEXT, ',')
	    Codec.H323Status = Data.TEXT
	    
	    if ( LENGTH_STRING ( Codec.SIPURL ) )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'SetSystemData-sysnum=',ITOA( SYSTEM_NUMBER ),'&contact=',Codec.SIPURL")
	    }
	    else if ( LENGTH_STRING ( Codec.H323ID ) )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'SetSystemData-sysnum=',ITOA( SYSTEM_NUMBER ),'&contact=',Codec.H323ID")
	    }
	}
	if ( FIND_STRING ( data.text, 'SIP-', 1) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    
	    Codec.SIPURL = getDelimitedData(DATA.TEXT, ',')
	    Codec.SIPProxy = getDelimitedData(DATA.TEXT, ',')
	    Codec.SIPStatus = Data.TEXT
	    
	    if ( LENGTH_STRING ( Codec.SIPURL ) )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'SetSystemData-sysnum=',ITOA( SYSTEM_NUMBER ),'&contact=',Codec.SIPURL" )
	    }
	    else if ( LENGTH_STRING ( Codec.H323ID ) )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'SetSystemData-sysnum=',ITOA( SYSTEM_NUMBER ),'&contact=',Codec.H323ID" )
	    }
	}
	
	if ( FIND_STRING ( DATA.TEXT, 'CAMERA_PTZF-', 1 ) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    
	    //Stores Current camera position
	    CURRENT_CAMERA_POSTION[DATA.DEVICE.PORT] = DATA.TEXT
	}
	
	switch(remove_string(data.text, '-', 1)) {
	    
	    case 'CALL-':
	    {
		CALLS[DATA.DEVICE.PORT].ID = data.device.port
		CALLS[DATA.DEVICE.PORT].CallID = ATOI ( removeLastbyte( remove_string(data.text, ',', 1) ) ) // real callId
		CALLS[DATA.DEVICE.PORT].Direction = removeLastbyte( remove_string(data.text, ',', 1) )// direction
		CALLS[DATA.DEVICE.PORT].Type = removeLastbyte( remove_string(data.text, ',', 1) )// calltype
		CALLS[DATA.DEVICE.PORT].rate = removeLastbyte( remove_string(data.text, ',', 1) )// callrate
		CALLS[DATA.DEVICE.PORT].encryption = removeLastbyte ( remove_string(data.text, ',', 1) )// encryption
		CALLS[DATA.DEVICE.PORT].presenting = removeLastbyte ( remove_string(data.text, ',', 1) )// presenting
		CALLS[DATA.DEVICE.PORT].remoteNumber = removeLastbyte( remove_string(data.text, ',', 1) ) //Remote Number
		CALLS[DATA.DEVICE.PORT].callBackNumber = removeLastbyte( remove_string(data.text, ',', 1) )// Call Back Number
		CALLS[DATA.DEVICE.PORT].callBackNumber = remove_string(calls[data.device.port].remoteNumber, ':',1) //Remove h323: text
		CALLS[DATA.DEVICE.PORT].DisplayName = removeLastbyte( remove_string(data.text, ',', 1) )// Display Name
		CALLS[DATA.DEVICE.PORT].protocol = data.text //Protocol 
		
		//Send call status to System List
		SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=',Calls[DATA.DEVICE.PORT].State,'&site=',Calls[DATA.DEVICE.PORT].remoteNumber" )
	    }
	    case 'DIALERSTATUS-':
	    {	
		switch(data.text)
		{
		    case 'NEGOTIATING':
		    {
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=Inviting'" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_NEG
		    }
		    case 'RINGING':
		    {
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=Ringing'" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_RING
		    }
		    case 'DIALING':
		    {
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=Dialing'" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_DIAL
		    }
		    case 'DISCONNECTED':
		    {
			//Check Not  
			IF ( PERMISSION_LEVEL >= 3 )
			{
			    //Show Screen Layout Button
			    SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[58] ),',0'"
			}
			
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=idle'" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_IDLE
		    }
		    case 'CONNECTED':
		    {
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=Connected&site=',Calls[DATA.DEVICE.PORT].remoteNumber" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_CONN
		    }
		    case 'ON_HOLD':
		    {
			//Send call status to System List
			SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=OnHold&site=',Calls[DATA.DEVICE.PORT].remoteNumber,' - On Hold'" )
			
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_ONHOLD
		    }
		}
	    }
	    case 'INCOMINGCALL-':
	    {
		//Send call status to System List
		SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=Incoming Call'" )
	    }
	}
    }
}

CHANNEL_EVENT [vdvCodec, 0]
{
    ON:
    {
	SWITCH (CHANNEL.CHANNEL)
	{
	    CASE DATA_INITIALIZED:
	    {
		STACK_VAR CHAR blankArray[10][255]
		
		SEND_COMMAND channel.device, "'?FWVERSION'"
		SEND_COMMAND channel.device, "'?VERSION'"
		SEND_COMMAND channel.device, "'?H323'"
		SEND_COMMAND channel.device, "'?SIP'"
		
		//Reset Previous call state to refresh the call control
		PREVIOUS_CALL_STATE = blankArray		
	    }
	}
    }
    OFF:
    {
	SWITCH (CHANNEL.CHANNEL)
	{
	    CASE DATA_INITIALIZED:
	    {
		//Send call status to System List
		SYSTEM_sendCommand ( vdvSystem, "'SYSTEM_CallStatus-status=NO NETWORK'" )
	    }
	}
    }
}


//VC Volume Controls
BUTTON_EVENT [ dvTPCodec, VCVolumeControls ]
{
    PUSH:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( VCVolumeControls )
	
	SWITCH ( svButton )
	{
	    //Audio Vol Up
	    CASE 2:
	    {
		ON[vdvCodecs[ACTIVE_SYSTEM], VOL_UP]
	    }
	    
	    //Audio Vol Dn
	    CASE 3:
	    {
		ON[vdvCodecs[ACTIVE_SYSTEM], VOL_DN]
	    }
	}
    }	
    
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( VCVolumeControls )
	
	SWITCH ( svButton )
	{
	    //Microphone Mute
	    CASE 1:
	    {
		PULSE[vdvCodecs[ACTIVE_SYSTEM], VCONF_PRIVACY]
	    }
	    
	    //Audio Vol Up
	    CASE 2:
	    {
		//This will register a volume change for a tap
		WAIT 3
		{
		    OFF[vdvCodecs[ACTIVE_SYSTEM], VOL_UP]
		}
	    }
	    
	    //Audio Vol Dn
	    CASE 3:
	    {
		WAIT 3
		{
		    OFF[vdvCodecs[ACTIVE_SYSTEM], VOL_DN]
		}
	    }
	    
	    //Audio Mute
	    CASE 4:
	    {
		PULSE[ vdvCodecs[ACTIVE_SYSTEM], VOL_MUTE ]
	    }
	}
    }
}

//Camera Controls 
BUTTON_EVENT [ dvTPCodec, VCCameraBtns ]
{
    PUSH:
    {
	STACK_VAR INTEGER svButton
	
	CODEC_setCameraSpeed(10)
	
	svButton = GET_LAST ( VCCameraBtns )
	SWITCH ( svButton )
	{
	    //Zoom In
	    CASE 1:  Codec_MoveCamera( ZOOM_IN )
	    
	    //Zoom Out
	    CASE 2: Codec_MoveCamera( ZOOM_OUT )
	    
	    //Tilt Up
	    CASE 3: Codec_MoveCamera( TILT_UP )
	    
	    //Tilt Down
	    CASE 4: Codec_MoveCamera( TILT_DN )
	    
	    //Pan Left
	    CASE 5: Codec_MoveCamera( PAN_LT )
	    
	    //Pan Right
	    CASE 6: Codec_MoveCamera( PAN_RT )
	    
	    
	    //Far/Conference End 
	    CASE 33: //Zoom In
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], ZOOM_IN]
		
		//Begin Camera Control timeout
		CAM_CONTROL_TIMEOUT = 10
		
		//Switch to MCU Camera Control Subpage
		SEND_COMMAND dvTP, "'@PPN-[Menu]MCUCamControl'"
	    }
	    CASE 34: //Zoom Out
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], ZOOM_OUT]
		
		//Begin Camera Control timeout
		CAM_CONTROL_TIMEOUT = 10
	    }
	    CASE 35: //Tilt Up
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], TILT_UP]
		
		if ( CAM_CONTROL_TIMEOUT )
		{
		    //Begin Camera Control timeout
		    CAM_CONTROL_TIMEOUT = 10
		}
	    }
	    CASE 36: //Tilt Down
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], TILT_DN]
		
		if ( CAM_CONTROL_TIMEOUT )
		{
		    //Begin Camera Control timeout
		    CAM_CONTROL_TIMEOUT = 10
		}
	    }
	    CASE 37: //Pan Left
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], PAN_LT]
		
		if ( CAM_CONTROL_TIMEOUT )
		{
		    //Begin Camera Control timeout
		    CAM_CONTROL_TIMEOUT = 10
		}
	    }
	    CASE 38: //Pan Right
	    {
		PULSE[vdvCodecFar[ACTIVE_SYSTEM], PAN_RT]
		
		if ( CAM_CONTROL_TIMEOUT )
		{
		    //Begin Camera Control timeout
		    CAM_CONTROL_TIMEOUT = 10
		}
	    }
	    
	    //DTMF Tones
	    CASE 40:
	    CASE 41:
	    CASE 42:
	    CASE 43:
	    CASE 44:
	    CASE 45:
	    CASE 46:
	    CASE 47:
	    CASE 48:
	    CASE 49:
	    {
		//DTMF to single site
		SEND_COMMAND vdvCodecs[ACTIVE_SYSTEM], "'DTMF-',ITOA ( svButton - 40 )"
	    }
	    
	    //DTMF *
	    CASE 50:
	    {
		//DTMF to single site
		SEND_COMMAND vdvCodecs[ACTIVE_SYSTEM], "'DTMF-*'"
	    }
	    
	    //DTMF #
	    CASE 51:
	    {
		//DTMF to single site
		SEND_COMMAND vdvCodecs[ACTIVE_SYSTEM], "'DTMF-#'"
	    }
	}
    }
    
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( VCCameraBtns )
	
	CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] = 0 
	
	SWITCH ( svButton )
	{
	    //Zoom In
	    CASE 1:
	    //Zoom Out
	    CASE 2:
	    //Tilt Up
	    CASE 3:
	    //Tilt Down
	    CASE 4:
	    //Pan Left
	    CASE 5:
	    //Pan Right
	    CASE 6:
	    {
		Codec_MoveCamera( 0 )
	    }
	    
	    //Select Student Camera 1
	    CASE 7:
	    {
		CODEC_SwitchCameras(ACTIVE_SYSTEM, 1)
	    }
	    //Select Teacher Camera 2
	    CASE 8:
	    {
		CODEC_SwitchCameras(ACTIVE_SYSTEM, 2)
	    }
	    
	    //Selfview
	    CASE 9:
	    {
		//Create Toggle
		IF ( SELFVIEW_POSITION < 4  )
		{
		    //SWITCH ON SELFVIEW 
		    ON[vdvCodecs[ACTIVE_SYSTEM], 305 ]
		    
		    //change position
		    PULSE[vdvCodecs[ACTIVE_SYSTEM], 191]
		    
		    //Increment Selfview position
		    SELFVIEW_POSITION++
		    
		}
		ELSE
		{
		    //Set Selfview Position off
		    SELFVIEW_POSITION = 0
		    
		    //Switch Off Selfview
		    OFF[vdvCodecs[ACTIVE_SYSTEM], 305 ]
		}
	    }
	    
	    //Camera Presets
	    case 10:
	    case 11:
	    case 12:
	    case 13:
	    case 14:
	    {
		//Recall Camera Preset
		SYSTEM_sendCommand ( vdvSystem, "'RECALL_CAMERA_PRESET-preset=',ITOA ( svButton-9 ),'&sysnum=',ITOA(ACTIVE_SYSTEM)" )
		
		CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] = svButton - 9
	    }
	    
	    //Camera Presets
	    case 20:
	    case 21:
	    case 22:
	    case 23:
	    case 24:
	    {
		//Send Camera Preset
		SYSTEM_sendCommand ( vdvSystem, "'SET_CAMERA_PRESET-camera=',ITOA ( ACTIVE_CAMERA[ACTIVE_SYSTEM] ),'&preset=',ITOA ( svButton-19 ),'&sysnum=',ITOA(ACTIVE_SYSTEM)" )
	    }
	    
	    //OSD Display
	    CASE 30:
	    {
		if ( [vdvCodec, 303] )
		{
		    OFF[vdvCodec, 303]
		}
		ELSE
		{
		    ON[vdvCodec, 303]
		}
	    }
	    
	    //Auto Answer
	    CASE 52:
	    {
		IF ( [vdvCodec, DIAL_AUTO_ANSWER_ON] )
		{
		    OFF[vdvCodec, DIAL_AUTO_ANSWER_ON]
		}
		ELSE
		{
		    ON[vdvCodec, DIAL_AUTO_ANSWER_ON]
		}
	    }
	    
	    //IR Control on/off
	    CASE 53:
	    {
		[vdvCodecs[SYSTEM_NUMBER], 321] = ![vdvCodec, 321]
		[vdvCodecs_Cam2[SYSTEM_NUMBER], 321] = ![vdvCodecs_Cam2, 321]
	    }
	}
    }
    
    HOLD[10]:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( VCCameraBtns )
	
	SWITCH ( svButton )
	{
	    CASE 7:
	    {
		[vdvCodecs[ACTIVE_SYSTEM], 322] = ![vdvCodecs[ACTIVE_SYSTEM], 322]
	    }
	    CASE 8:
	    {
		[vdvCodecs_Cam2[ACTIVE_SYSTEM], 322] = ![vdvCodecs_Cam2[ACTIVE_SYSTEM], 322]
	    }
	}
    }
}

//Recieve Level from Codec
LEVEL_EVENT[ vdvCodecs, VOL_LVL ]
{
    STACK_VAR INTEGER Index
    
    if ( LEVEL.INPUT.DEVICE.SYSTEM == ACTIVE_SYSTEM )
    {
	SEND_LEVEL dvTPCodec, VCVolumeControls[5], LEVEL.VALUE
    }
    
    //Store Volume Level
    Index = SYSTEM_getIndexFromSysNum( LEVEL.INPUT.DEVICE.SYSTEM  )
    Systems[Index].Volume = LEVEL.VALUE
}


DEFINE_PROGRAM

WAIT 10
{
    //MCU Cam Control Timout
    if ( CAM_CONTROL_TIMEOUT > 1 )
    {
	CAM_CONTROL_TIMEOUT --
    }
    else if ( CAM_CONTROL_TIMEOUT == 1 )
    {
	CAM_CONTROL_TIMEOUT = 0
	
	//Switch to MCU Camera Control Subpage
	SEND_COMMAND dvTP, "'@PPN-[Menu]ScreenLayout;Admin'"
    }
}
