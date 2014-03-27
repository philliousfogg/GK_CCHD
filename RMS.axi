PROGRAM_NAME='RMS'

DEFINE_VARIABLE


// this array includes the main touch panel devices that contain the RMS pages and buttons
VOLATILE DEV dvRMSTP[] =
{
  dvTPRMS
}

// this array includes the main touch panel devices BASE ADDRESSES for handling user keyboard input
// (each device in this array must define the DEVICE PORT = 1)
VOLATILE DEV dvRMSTP_Base[] =
{
  dvTP
}

VOLATILE DEV dvRMSTPWelcome[] =
{
  dvTPRMS_Welcome
}

// this array includes the welcome touch panel devices BASE ADDRESSES for handling user keyboard input
// (each device in this array must define the DEVICE PORT = 1)
VOLATILE DEV dvRMSTPWelcome_Base[] =
{
  dvTP
}

//
// The following constant strings provide
// a default subject and messages text for
// meeting scheduled via the touch panels
//
VOLATILE CHAR RMS_MEETING_DEFAULT_SUBJECT[] = ''
VOLATILE CHAR RMS_MEETING_DEFAULT_MESSAGE[] = ''

VOLATILE INTEGER RMS_REPORT_TYPE

#INCLUDE 'RMSCommon.axi'

#INCLUDE 'TimeDateLib.axi'

//Generates a random 5 digit pin
DEFINE_FUNCTION LONG RMS_generatePin()
{
    STACK_VAR LONG pin
    
    pin = RANDOM_NUMBER(99999)
    
    //Keep generating a pin until a 5 digit number is created
    if ( pin < 10000 )
    {
	pin = RMS_generatePin()
    }
    
    //Return pin 
    return pin
} 

//Generates a formatted list on Attending sites for the next lesson
DEFINE_FUNCTION CHAR[255] RMS_listAttendingSites( integer lesson )
{
    STACK_VAR INTEGER i 
    STACK_VAR CHAR sitesAttending[255]
    
    //Cycle through each system and find the sites in this lesson
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	//if the system exists in the slot
	if ( SYSTEMS[i].SystemNumber )
	{
	    if ( lesson == cNEXT )
	    {
		//is the system attending the next lesson
		if ( SYSTEMS[i].nextLesson )
		{
		    //Append site name to sites attending with a line feed to 'list'
		    //the items
		    sitesAttending = "sitesAttending,$0D,$0A,SYSTEMS[i].name"
		}
	    }
	    ELSE if ( lesson == cLIVE )
	    {
		//is the system attending the current lesson
		if ( SYSTEMS[i].liveLesson )
		{
		    //Append site name to sites attending with a line feed to 'list'
		    //the items
		    sitesAttending = "sitesAttending,$0D,$0A,SYSTEMS[i].name"
		}
	    }
	}
	ELSE
	{
	    break
	}
    }
    
    return sitesAttending
}

//Clear or the Lesson Fields
DEFINE_FUNCTION RMS_clearLessonText()
{
    STACK_VAR INTEGER i 
    
    //Go through each text field and remove text
    for ( i=1; i<=7; i++ )
    {
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ i+9 ] ),'- '" 
    }
    
    // Clear Map Points
    UI_MAP_clearPoints()
    
    //Set Page tite
    SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 17 ] ),'-No Lessons Today'"
    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[ 86 ] ),',1'"
}

//Refreshes the Lesson text on the touch panel
DEFINE_FUNCTION RMS_refreshLessonText()
{	
    STACK_VAR CHAR startTime[5]
    STACK_VAR CHAR endTime[5]
        
    //if there is no current lesson
    if ( RMS_LEVELS.Current )
    {
	startTime = LEFT_STRING ( LIVE_LESSON.startTime, 5 )
	endTime = LEFT_STRING ( LIVE_LESSON.endTime, 5 )
	
	if ( RECURRING_SHUTDOWN )
	{
	    SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 10 ] ),'-', LIVE_LESSON.Subject,' [SUSPENDED]'"
	}
	ELSE
	{
	    SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 10 ] ),'-', LIVE_LESSON.Subject"
	}
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 11 ] ),'-', LIVE_LESSON.Instructor"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 12 ] ),'-', LIVE_LESSON.Message"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 13 ] ),'-', LIVE_LESSON.Code"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 14 ] ),'-', startTime,' - ',endTime"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 16 ] ),'-', RMS_listAttendingSites(cLIVE)"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 17 ] ),'-Current Lesson'"
	SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[ 86 ] ),',0'"
	
	UI_Map_attendingSites( cLive )
    }
    else if ( RMS_LEVELS.Next )
    {
	startTime = LEFT_STRING ( NEXT_LESSON.startTime, 5 )
	endTime = LEFT_STRING ( NEXT_LESSON.endTime, 5 )
	
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 10 ] ),'-', NEXT_LESSON.Subject"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 11 ] ),'-', NEXT_LESSON.Instructor"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 12 ] ),'-', NEXT_LESSON.Message"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 13 ] ),'-', NEXT_LESSON.Code"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 14 ] ),'-', startTime,' - ',endTime"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 16 ] ),'-', RMS_listAttendingSites(cNEXT)"
	SEND_COMMAND dvTP, "'TEXT',ITOA( RMSBtns[ 17 ] ),'-Next Lesson'"
	
	UI_Map_attendingSites( cNext )
    }
    else
    {
	//Clear Lesson Text
	RMS_clearLessonText()
    }
    
    //If there is no lesson then show the login page
    if ( !PERMISSION_LEVEL )
    {
	SEND_COMMAND dvTP, "'PAGE-Login'"
    }
    
    //Show Waiting
    SEND_COMMAND dvTP, "'@PPK-_Waiting'"

}

DEFINE_FUNCTION RMS_RefreshLessonData()
{
    //Only retrieve data if there is a lesson
    if ( RMS_LEVELS.Current )
    {
	//Get Lesson information
	SEND_COMMAND vdvLesson, "'GET_LESSON_DATA-index=',ITOA(RMS_LEVELS.Current)"
    }
    
    //Only retrieve data if there is a lesson
    if ( RMS_LEVELS.Next )
    {
	//Get Lesson information
	SEND_COMMAND vdvLesson, "'GET_LESSON_DATA-index=',ITOA(RMS_LEVELS.Next)"
    }
}

//Extend lesson
DEFINE_FUNCTION RMS_extendLesson(integer minutes)
{
    STACK_VAR INTEGER i 
    
    //Cycle through all registered systems
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	//If System exists
	if ( SYSTEMS[i].SystemNumber )
	{
	    if ( SYSTEMS[i].LiveLesson )
	    {
		//Send Lesson extension request to the system
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_Extend-&sysnum=',ITOA( Systems[i].SystemNumber ),'&mins=',ITOA( minutes )" )
	    }
	}
	else
	{
	    break
	}
    }
}

//End the lesson
DEFINE_FUNCTION RMS_endLesson()
{
    STACK_VAR INTEGER i 
    
    //Cycle through all registered systems
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	//If System exists
	if ( SYSTEMS[i].SystemNumber )
	{
	    if ( SYSTEMS[i].LiveLesson )
	    {
		//Send Lesson extension request to the system
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_End-&sysnum=',ITOA( Systems[i].SystemNumber )"	)
	    }
	}
	else
	{
	    break
	}
    }

    //Logout of system
    SYSTEM_logout()
}

//Evaluates the response to the end lesson dialog
DEFINE_FUNCTION RMS_restartRoomRespone( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer index
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'RestartLesson', 1 ) )
    {	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	Switch ( response )
	{ 
	    CASE 1: 
	    {		
		SEND_STRING 0, 'ok'
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_forceShutdown-func=0&code=',LIVE_LESSON.Code")
	    }
	    CASE 2: 
	    {		
		SEND_STRING 0, 'cancel'
	    }
	}
    }
}

//Returns true if there are virtual rooms
DEFINE_FUNCTION integer RMS_isVirtualRoom()
{
    STACK_VAR INTEGER i
    
    FOR ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//is the system a virtual room
	if ( SYSTEMS[i].systemNumber > 500 )
	{
	    return 1
	}
    }
    
    return 0
} 

//Evaluates the response to the end lesson dialog
DEFINE_FUNCTION RMS_endLessonResponse( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'lessend', 1 ) )
    {
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	Switch ( response )
	{
	    CASE 1: 
	    {
		//Send an end request to all rooms
		RMS_endLesson()
		
		//Show Waiting
		SEND_COMMAND dvTP, "'@PPN-_Waiting'"
		
		SEND_STRING 0, 'End Now'
	    }
	    CASE 2: 
	    {
		//Send an extension request to all rooms
		RMS_extendLesson(60)
		
		//Show Waiting
		SEND_COMMAND dvTP, "'@PPN-_Waiting'"
		
		SEND_STRING 0, 'Extend'
	    }
	    CASE 3: 
	    {
		SEND_STRING 0, 'Acknowledge'
	    }
	}
    }
}

//Evaluates the response to the Start lesson dialog
DEFINE_FUNCTION RMS_startSiteResponse(_Command parser)
{   
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer index
    STACK_VAR integer svButton
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //Get Response
    response = ATOI ( GetAttrValue ( 'res', parser ) )
	
    //get index from response
    index = ATOI ( ref )
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'sitestart', 1 ) )
    {
	//remove 'siteend'
	REMOVE_STRING ( ref, 'sitestart', 1 )
	
	Switch ( response )
	{ 
	    CASE 1: 
	    {
		STACK_VAR INTEGER SysIndex
		
		SysIndex = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
		
		//if there is a lesson in progress then connect room to lesson
		if ( Systems[SysIndex].LiveLesson )
		{  
		    SYSTEM_sendCommand ( vdvSystem, "'LESSON_Start-type=2&pin=',ITOA(LIVE_LESSON.pin),
					      '&sysnum=',ITOA( Systems[index].SystemNumber ),
					      '&code=',LIVE_LESSON.Code,
					      '&start=',TIME,
					      '&dur=',ITOA(RMS_LEVELS.MinutesRemaining),
					      '&instr=',LIVE_LESSON.Instructor,
					      '&subject=',LIVE_LESSON.Subject,
					      '&message=Start from ',Systems[SysIndex].name")
		}
		(*ELSE if ( Systems[SysIndex].NextLesson )
		{
		    STACK_VAR LONG secs,mins,hrs
		    STACK_VAR CHAR diff[9]
		    STACK_VAR CHAR bOneLtTwo
		    
		    TDLTimeDiff( NEXT_LESSON.EndTime, NEXT_LESSON.StartTime, hrs, mins, secs, diff, bOneLtTwo)
		    
		    SEND_COMMAND vdvSystem, 
					     "'LESSON_Start-type=2&pin=',ITOA(NEXT_LESSON.pin),
					      '&sysnum=',ITOA( Systems[index].SystemNumber ),
					      '&code=',NEXT_LESSON.Code,
					      '&start=',NEXT_LESSON.StartTime,
					      '&dur=',ITOA( mins ),
					      '&instr=',NEXT_LESSON.Instructor,
					      '&subject=',NEXT_LESSON.Subject,
					      '&message=Start from ',Systems[SysIndex].name"
		}*)
		
		//if there is no lesson in progress then start 60 minute AdHoc with room
		else
		{
		    STACK_VAR LONG RandomCode
		    STACK_VAR INTEGER Duration
		    
		    //Generate Random Pin
		    RandomCode = RMS_generatePin()		    
		    
		    //If there is another lesson after the current 
		    if ( RMS_LEVELS.Next )
		    {
			Duration = RMS_LEVELS.MinutesUntilNext
		    }
		    //240 minutes by default
		    ELSE
		    {
			Duration = 240 //4hrs
		    }
		    
		    
		    //Teacher room (this room)
		    SYSTEM_sendCommand ( vdvSystem, 
					     "'LESSON_Start-type=1&pin=',ITOA( RandomCode ),
					      '&sysnum=',ITOA( SYSTEM_NUMBER ),
					      '&code=Adhoc',ITOA(SYSTEM_NUMBER),
					      '&start=',TIME,
					      '&dur=',ITOA ( Duration ),
					      '&instr=Unknown',
					      '&subject=Unknown',
					      '&message=Start from ',Systems[SysIndex].name" )
		    
		    if ( index )
		    {
			//Connecting room 
			SYSTEM_sendCommand ( vdvSystem, 
						"'LESSON_Start-type=2&pin=',ITOA( RandomCode ),
						  '&sysnum=',ITOA( Systems[index].SystemNumber ),
						  '&code=Adhoc',ITOA(SYSTEM_NUMBER),
						  '&start=',TIME,
						  '&dur=',ITOA ( Duration ),
						  '&instr=Unknown',
						  '&subject=Unknown',
						  '&message=Start from ',Systems[SysIndex].name" )
						  
		    }
		    
		    //Notify User of pin code]
		    SYSTEM_Alert( 'Add Lesson',  "'Please note the lesson pin number ',ITOA( RandomCode ),$0D,$0A,$0D,$0A,'Please contact the system administrator to change.'")
		}
		
		//Get the button index for the site list
		svbutton = GetSlotFromDataIndex( SystemUIList, index)
		
		//Tag Please Wait onto Site Name
		SEND_COMMAND dvTP, "'TEXT',ITOA( UIBtns[10+svButton] ),'-',Systems[index].name,' - Please Wait'"
		
		SEND_STRING 0, 'ok'
	    }
	    CASE 2:
	    {
		SEND_STRING 0, 'Cancel'
	    }
	}
    }
}

//Evaluates the response to the end lesson dialog
DEFINE_FUNCTION RMS_removeSiteResponse( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer index
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'siteend', 1 ) )
    {
	//remove 'siteend'
	REMOVE_STRING ( ref, 'siteend', 1 )
	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	//get index from response
	index = ATOI ( ref )
	
	Switch ( response )
	{ 
	    CASE 1: 
	    {
		//Send an end request to site
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_End-sysnum=',ITOA(SYSTEMS[index].SystemNumber)" )
		
		//Remove Site from current to prevent recall
		Systems[index].liveLesson = 0	
		
		//Show Waiting
		SEND_COMMAND dvTP, "'@PPN-_Waiting'"
		
		SEND_STRING 0, 'ok'
	    }
	    CASE 2: 
	    {
		SEND_STRING 0, 'Cancel'
	    }
	}
    }
}



//Evaluates the response to the end lesson dialog
DEFINE_FUNCTION RMS_RMSMesgResponse( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer index
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'RMSMesg', 1 ) )
    {	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	Switch ( response )
	{ 
	    CASE 1: 
	    {		
		SEND_STRING 0, 'ok'
	    }
	    CASE 2: 
	    {
		//Send Text
		SEND_COMMAND dvTP, "'TEXT',ITOA ( RMSBtns[34] ),'-Request Help (Reply)'"
		
		//Set Flag for receive 
		RMS_REPORT_TYPE = 33
		
		//Show rms Reporting Page
		SEND_COMMAND dvTP, "'@PPN-_rmsReporting'"
		
		SEND_STRING 0, 'Reply'
	    }
	}
    }
}

//This evaluates the current RMS levels
DEFINE_FUNCTION RMS_evaluateLevels()
{
    //Current Appointment
    if ( RMS_LEVELS.Current != REPORTED_RMS_LEVELS.Current )
    {
	RMS_LEVELS.Current = REPORTED_RMS_LEVELS.Current
	SEND_STRING 0, "'Change in Current Appt'"
	
	//Remove Current Appt from Current Lesson
	if ( !RMS_LEVELS.Current )
	{
	    STACK_VAR _Lesson Blank
	    STACK_VAR Integer DialogIndex
	    LIVE_LESSON = Blank
	    
	    //Refresh UI
	    RMS_refreshLessonText()
	    
	    //Dismiss any dialog warnings
	    DialogIndex = Dialog_getIdfromRef( 'lessend' )
	    Dialog_Remove( DialogIndex )
	    
	    //Disconnect call in the lesson
	    PULSE[vdvCodec, DIAL_FLASH_HOOK]
	    
	    //Hide Extend and End meeting Buttons
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[30] ),',0'" //End Meeting
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[31] ),',0'" //Extend Meeting 
	    
	    //Switch off presentation
	    OFF[ dvRELAY, 1 ]
	    OFF[ dvRELAY, 2 ]
	    
	    //Pulse Resident PC Relay by default
	    PULSE[ dvRelay, 1 ]
	    
	    //Hide Alert button 
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[81] ),',0'"
	    
	    //Return Cameras to Master Preset
	    send_command vdvCodecs[SYSTEM_NUMBER],"'CAMERAPRESET-1'"
	    send_command vdvCodecs_Cam2[SYSTEM_NUMBER],"'CAMERAPRESET-1'"
	    
	    //Inform all other Systems that the lesson has ended
	    SYSTEM_sendCommand ( vdvSystem, "'LESSON_siteEnd-lesson=',ITOA(cLive),'&sysnum=',ITOA(SYSTEM_NUMBER)" )
	    
	    //Reset Lights
	    LIGHTS_resetLights(vdvLight)
	    
	    //Logout of system
	    SYSTEM_logout()
	}
	ELSE
	{
	    //Show Extend and End meeting Buttons
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[30] ),',1'" //End Meeting
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( RMSBtns[31] ),',1'" //Extend Meeting 
	}
	
	//Refresh the RMS data across all systems
	ON[RMS_REFRESH_DATA]
    }
    
    //Minutes Remaining in Appointment
    if ( RMS_LEVELS.MinutesRemaining != REPORTED_RMS_LEVELS.MinutesRemaining )
    {
	RMS_LEVELS.MinutesRemaining = REPORTED_RMS_LEVELS.MinutesRemaining
	SEND_STRING 0, "'Change in Minutes Remaining'"
	
	//Start Call initialisation if teacher room
	if ( LIVE_LESSON.Type == TEACHER )
	{
	    
	    //30 minutes before the end of the lesson and at intervals of 5 minutes
	    if ( RMS_LEVELS.MinutesRemaining <= 30 AND  !( RMS_LEVELS.MinutesRemaining % 5 ) )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=lessend&title=Lesson End Warning',
					 '&message=This lesson is ending in ',ITOA( RMS_LEVELS.MinutesRemaining ),' Minutes',
					 '&res1=End Now&res2=Extend&res3=Cancel&norepeat=1'" )
	    }
	}
	
	//Refresh the RMS data across all systems
	ON[RMS_REFRESH_DATA]
    }
    
    //Next Appointment
    if ( RMS_LEVELS.Next != REPORTED_RMS_LEVELS.Next )
    {
	RMS_LEVELS.Next = REPORTED_RMS_LEVELS.Next
	SEND_STRING 0, "'Change in Next Appt'"
	
	//Remove Current Appt from Current Lesson
	if ( !RMS_LEVELS.Next )
	{
	    STACK_VAR _Lesson Blank
	    STACK_VAR Integer DialogIndex
	    
	    NEXT_LESSON = Blank
	    
	    //Refresh UI
	    RMS_refreshLessonText()
	    
	    //Dismiss any dialog warnings
	    DialogIndex = Dialog_getIdfromRef( 'lessend' )
	    Dialog_Remove( DialogIndex )
	    
	    //Hide Alert button 
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[81] ),',0'"
	    
	    //Inform all other Systems that the lesson has ended
	    SYSTEM_sendCommand ( vdvSystem, "'LESSON_siteEnd-lesson=',ITOA(cNext),'&sysnum=',ITOA(SYSTEM_NUMBER)" )
	}
	
	//Refresh the RMS data across all systems
	ON[RMS_REFRESH_DATA]
    }
    
    //Minutes until Next Appt
    if ( RMS_LEVELS.MinutesUntilNext != REPORTED_RMS_LEVELS.MinutesUntilNext )
    {
	RMS_LEVELS.MinutesUntilNext = REPORTED_RMS_LEVELS.MinutesUntilNext
	SEND_STRING 0, "'Change in Minutes Until Next'"
	
	//Refresh the RMS data across all systems
	ON[RMS_REFRESH_DATA]
    }
}

//Removes $0A from the data stream
DEFINE_FUNCTION char[255] RMS_removeLineFeed( char text[255] )
{
    STACK_VAR char result[255]
    
    result = REMOVE_STRING ( text, $0A, 1 )
    SET_LENGTH_STRING ( result, LENGTH_STRING( result ) - 1 )
    
    return result
}


DEFINE_START


DEFINE_EVENT

DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	//Set UK Time and Date Standard
	//UK date and time format?
	SEND_COMMAND vdvRMSEngine, "'DFORMAT-D'"
	SEND_COMMAND vdvRMSEngine, "'TFORMAT-2'"
    }
    STRING:
    {
	//End Lesson Error
	if ( FIND_STRING ( DATA.TEXT,"'ENDNOW-NO'", 1 ) )
	{
	    //Remove ENDNOW-NO,
	    REMOVE_STRING ( DATA.TEXT, ',', 1 )
	    
	    //Hide Waiting
	    SEND_COMMAND dvTP, "'@PPK-_Waiting'"
	    
	    If ( PERMISSION_LEVEL < 3 OR LIVE_LESSON.TYPE == TEACHER )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=EndLessonError',
						    '&title=End Current Lesson',
						    '&message=You cannot remove a recurring lesson from the calendar.  The lesson will be suspended.',$0A,$0D,$0A,$0D,
						    'Press ok to continue',
						    '&res1=Ok&norepeat=1'" )
	    }
	    
	    //Set the reoccurring shutdown flag on all systems in lesson.
	    SYSTEM_sendCommand ( vdvSystem, "'LESSON_forceShutdown-func=1&code=',LIVE_LESSON.Code" )
	}
	
	//End Lesson Sucess
	if ( FIND_STRING ( DATA.TEXT,"'ENDNOW-YES'", 1 ) )
	{
	    //Hide Waiting
	    SEND_COMMAND dvTP, "'@PPK-_Waiting'"
	    
	    If ( PERMISSION_LEVEL < 3 OR LIVE_LESSON.TYPE == TEACHER )
	    {
		
	    }
	}
	
	//Extend Lesson Error
	if ( FIND_STRING ( DATA.TEXT,"'EXTEND-NO'", 1 ) )
	{
	    //Remove ENDNOW-NO,
	    REMOVE_STRING ( DATA.TEXT, ',', 1 )
	    
	    //Hide Waiting
	    SEND_COMMAND dvTP, "'@PPK-_Waiting'"
	    
	    If ( PERMISSION_LEVEL < 3 OR LIVE_LESSON.TYPE == TEACHER )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=ExLessonError',
						    '&title=Extend Current Lesson',
						    '&message=At ',LIVE_LESSON.EndTime,' the room will shut for 2 minute. Please be patient.',$0A,$0D,$0A,$0D,
						    'Press ok to continue',
						    '&res1=Ok&norepeat=1'" )
	    }
	    
	    //Extend by setting up a new meeting
	    SYSTEM_sendCommand ( vdvSystem, "'LESSON_ExtendRecurring-&code=',LIVE_LESSON.Code" )
	}
	
	//Reserve Failure
	if ( FIND_STRING ( DATA.TEXT,"'RESERVE-NO'", 1 ) )
	{
	    if ( FIND_STRING( DATA.TEXT, 'conflicting appointment detected.', 1 ) )
	    {
		STACK_VAR CHAR svTime[5]
		
		//Remove RESERVE-No,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		//Remove <date>,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		//Remove <time>,
		svTime = REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		SEND_STRING 0, DATA.TEXT
		SEND_STRING 0, svTime
		
		//Hide Waiting
		SEND_COMMAND dvTP, "'@PPK-_Waiting'"
		
		//Extend by setting up a new meeting
		SYSTEM_sendCommand ( vdvSystem, "'LESSON_reserveFailure-&sysnum=',ITOA(SYSTEM_NUMBER),'&time=',svTime")
	    }
	}
	
	//Extend Lesson Success
	if ( FIND_STRING ( DATA.TEXT,"'EXTEND-YES'", 1 ) )
	{	    
	    //Hide Waiting
	    SEND_COMMAND dvTP, "'@PPK-_Waiting'"
	    
	    If ( PERMISSION_LEVEL < 3 OR LIVE_LESSON.TYPE == TEACHER )
	    {
	    
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=ExLessonSuccess',
						    '&title=Extend Current Lesson',
						    '&message=Lesson has been Extended until - ',LIVE_LESSON.endTime,$0A,$0D,$0A,$0D,
						    'Press ok to continue',
						    '&res1=Ok&norepeat=1'" )
						
	    }
	}
	
	if ( FIND_STRING ( DATA.TEXT,"'CHANGE-',LDATE",1 ) )
	{
	    //Refresh the RMS data across all systems
	    ON[RMS_REFRESH_DATA]
	}
	
	//Read room info and update system info - Name
	if ( FIND_STRING ( DATA.TEXT,"'ROOM NAME-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM NAME-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER),
				'&name=',DATA.TEXT" )
	}
	
	//Location
	if ( FIND_STRING ( DATA.TEXT,"'ROOM LOCATION-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM LOCATION-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER),
				'&loc=',DATA.TEXT" )
	}
	
	//Company
	if ( FIND_STRING ( DATA.TEXT,"'ROOM OWNER-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM OWNER-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				    'sysnum=',ITOA(SYSTEM_NUMBER),
				    '&comp=',DATA.TEXT" )
	}
	
	//A response to the help request
	IF (FIND_STRING(DATA.TEXT, 'MESG-',1))
	{
	    REMOVE_STRING(DATA.TEXT,',',1)
	    SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=RMSMesg',
					    '&title=Response the Support Desk',
					    '&message=',DATA.TEXT,
					    '&res1=Ok&res2=Reply&norepeat=1'" )
	}
    }
}

LEVEL_EVENT [ vdvRMSEngine, 0]
{    
    SWITCH ( LEVEL.INPUT.LEVEL )
    {
	CASE 1: REPORTED_RMS_LEVELS.Current = LEVEL.VALUE
	CASE 2: REPORTED_RMS_LEVELS.MinutesRemaining = LEVEL.VALUE
	CASE 3: REPORTED_RMS_LEVELS.Next = LEVEL.VALUE
	CASE 4: REPORTED_RMS_LEVELS.MinutesUntilNext = LEVEL.VALUE
	CASE 5: REPORTED_RMS_LEVELS.First = LEVEL.VALUE
	CASE 6: REPORTED_RMS_LEVELS.Last = LEVEL.VALUE
	CASE 7: REPORTED_RMS_LEVELS.RemainingCount = LEVEL.VALUE
    }   

    If ( LEVEL.VALUE == 0 )
    {
	//This waits for the levels to reset (on level change the level resets 
	//to 0 and then immediately sets to the correct level value or remains 
	//0 if 0 is the value.  The delay compensates for this reset.
	
    }
}



DATA_EVENT [dvTP]
{
    STRING:
    {
	if ( FIND_STRING ( DATA.TEXT, 'PIN-', 1 ) )
	{
	    STACK_VAR INTEGER pin
	    
	    //Remove 'PIN-'
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    
	    if ( !FIND_STRING ( DATA.TEXT, 'ABORT', 1 ) )
	    {
		//Convert entered pin to integer
		pin = ATOI( DATA.TEXT )
		
		//Is pin not equal to 4
		IF ( pin > 9999 OR !pin )
		{
		    //Confirm System Pin Change
		    SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=PinNot4-',DATA.TEXT,
							'&title=Change Admin Pin',
							'&message=The PIN number must be 4 digits.',
							'&res1=Ok&norepeat=1'" )
		}
		ELSE
		{
		    //Confirm System Pin Change
		    SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=chgpin-',DATA.TEXT,
							'&title=Change Admin Pin',
							'&message=You are about to change the PIN this will affect all systems.',$0A,$0D,$0A,$0D,
							'Would you like to change it to ',DATA.TEXT,'?',
							'&res1=Yes&res2=No&norepeat=1'" )   
		}
	    }
	}
	
	if ( FIND_STRING ( DATA.TEXT, 'KEYP-', 1 ) )
	{
	    //Remove 'KEYP-'
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    
	    if ( !FIND_STRING ( DATA.TEXT, 'ABORT', 1 ) )
	    {
		//Teachers current lesson
		if ( ATOI ( DATA.TEXT ) == LIVE_LESSON.Pin AND RMS_LEVELS.Current)
		{
		    //Set Permission Level
		    PERMISSION_LEVEL = 3		
		}
		
		//Teachers next lesson
		else if ( ATOI( DATA.TEXT ) == NEXT_LESSON.Pin AND RMS_LEVELS.Next )
		{
		    //if there is not lesson in progress
		    //set permission level
		    if ( !RMS_LEVELS.Current )
		    {
			//Set Permission Level
			PERMISSION_LEVEL = 3
		    }
		    else
		    {
			//Show Alert
			SYSTEM_Alert( 'Another Lesson in Progress',  "'There is another lesson in progress ',$0D,$0A,$0D,$0A,'Please wait until ',NEXT_LESSON.StartTime")
		    }
		}
		
		//Administrators Pin
		ELSE if ( ATOI( DATA.TEXT ) == SYSTEM_PIN )
		{
		    //Set Permission Level
		    PERMISSION_LEVEL = 2
		}
		
		//Master Pin
		ELSE if ( ATOI( DATA.TEXT ) == MASTER_PIN )
		{
		    //Set Permission Level
		    PERMISSION_LEVEL = 1
		}
		
		//Wrong Pin
		ELSE
		{
		    //Set Permission Level
		    PERMISSION_LEVEL = 0
		    
		    //Show Alert
		    SYSTEM_Alert( 'Wrong Pin',  "'The pin you have entered is incorrect.',$0D,$0A,$0D,$0A,'Please Try again.'")
		}
		
		//Show List
		Systems_UpdateUIList(1)
		
		//Show Controls if permission level is set
		if ( PERMISSION_LEVEL )
		{  
		    //Display Control Page
		    SYSTEM_ShowMain()
		    
		    //If Current lesson is shutdown then restart
		    if ( RMS_LEVELS.Current AND RECURRING_SHUTDOWN )
		    {
			//Ask user if they want to restart meeting
			SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=RestartLesson',
						    '&title=Restart Lesson',
						    '&message=There is a currently suspended meeting',$0A,$0D,$0A,$0D,
						    'Would you like to restart it?',
						    '&res1=Ok&res2=Cancel&norepeat=1'" )
		    }
		}
	    }
	}
	
	if ( FIND_STRING ( DATA.TEXT, 'TextField-', 1 ) )
	{
	    STACK_VAR CHAR sMessage[255]
	    
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    
	    if ( !FIND_STRING ( DATA.TEXT, 'ABORT', 1 ) )
	    {
		//Set message content depending on permission level
		if ( PERMISSION_LEVEL < 3 )
		{
		    sMessage = "'Admin - ',DATA.TEXT"
		}
		ELSE
		{
		    if ( RMS_LEVELS.Current )
		    {	    
			sMessage = "LIVE_LESSON.Instructor,' - ',DATA.TEXT"
		    }
		    ELSE
		    {
			sMessage = "NEXT_LESSON.Instructor,' - ',DATA.TEXT"
		    }
		}
		
		//if a fault report then
		SWITCH ( RMS_REPORT_TYPE  ) 
		{
		    //if a fault report then
		    CASE 32:
		    {
			//Send Message to RMS
			SEND_COMMAND vdvRMSEngine,"'MAINT-',sMessage"
			
			//Show Alert to confirm that the message has been sent
			SYSTEM_Alert( 'Fault Reported',  "'Thank you for your fault report.',$0D,$0A,$0D,$0A,'This will be addressed as soon as possible.'")
		    }
		    
		    //Help request
		    CASE 33:
		    {
			//Send Message to RMS
			SEND_COMMAND vdvRMSEngine,"'HELP-',sMessage"
			
			//Show Alert to confirm that the message has been sent
			SYSTEM_Alert( 'Help Request',  "'One of the support staff will contact you soon.',$0D,$0A,$0D,$0A,''")
		    }
		}
	    }
	} 
    }
}

//RMS Button Events
BUTTON_EVENT [dvTP, RMSBtns]
{
    PUSH:
    {
    
    }
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( RMSBtns )
	
	SWITCH ( svButton )
	{
	    CASE 30:
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=lessend&title=End Lesson',
					 '&message=This will end the lesson and disconnect all sites',$0A,$0D,$0A,$0D,
					 'Do you wish to continue?',
					 '&res1=Ok&res3=Cancel&norepeat=1'" )
	    }
	    
	    CASE 31:
	    {
		//Send an extension request to all rooms
		RMS_extendLesson(60)
		
		//Show waiting
		SEND_COMMAND dvTP, "'@PPN-_Waiting'"
	    }
	    
	    //Report Fault
	    CASE 32:
	    {
		//Send Text
		SEND_COMMAND dvTP, "'TEXT',ITOA ( RMSBtns[34] ),'-Report Fault'"
		
		//Set Flag for receive 
		RMS_REPORT_TYPE = svButton
		
		//Show Page
		SEND_COMMAND dvTP, "'@PPN-_rmsReporting'"
	    }
	    
	    //Request Help
	    CASE 33:
	    {
		//Send Text
		SEND_COMMAND dvTP, "'TEXT',ITOA ( RMSBtns[34] ),'-Request Help'"
		
		//Set Flag for receive 
		RMS_REPORT_TYPE = svButton
		
		//Show Page
		SEND_COMMAND dvTP, "'@PPN-_rmsReporting'"
	    }
	}
    }
}
