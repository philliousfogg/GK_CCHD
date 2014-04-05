MODULE_NAME='RMSVirtualRoom' (DEV dvRMSSocket,
			      DEV vdvRMSEngine,
			      DEV vdvCLActions,
			      DEV vdvSystems[],
			      DEV vdvSystem,
			      DEV vdvLesson)

DEFINE_DEVICE 

#INCLUDE 'Utilities.axi'

DEFINE_TYPE

STRUCTURE _RMS_LEVELS
{
    INTEGER Current
    INTEGER MinutesRemaining
    INTEGER Next
    INTEGER MinutesUntilNext
    INTEGER First
    INTEGER Last
    INTEGER RemainingCount
}


STRUCTURE _Lesson
{
    INTEGER index
    INTEGER state
    CHAR Subject[64]
    CHAR Instructor[64]
    CHAR Message[100]
    INTEGER Pin
    INTEGER Type
    CHAR Code[16]
    CHAR StartTime[8]
    CHAR EndTime[8]
}

STRUCTURE _Systems
{
    integer systemNumber	//The system number
    char name[64]		//Name of the room and dialling detail
    char location[64]		//Where the System is Located
    char company[64]		//Who the system belongs to
    char contact[255]		//Video Connection Information	
    char ip[16]			//IP address of the room
    char callStatus[255]	//Call Status
    INTEGER inCall		//Boolean Call Status
    dev SysDev			//System Device Address
    integer status 		//the status of the room
    integer thisSystem		//Is it 'this' room
    integer nextLesson		//Is it being used for the next lesson
    integer liveLesson		//Is it being used for the current lesson
    integer receiveOnly		//Is the system a receive only room
    integer mobile		//Is the system a mobile room
}

DEFINE_CONSTANT

VOLATILE INTEGER TEACHER = 1
VOLATILE INTEGER STUDENT = 2

VOLATILE INTEGER cNEXT 	 = 1
VOLATILE INTEGER cLIVE	 = 2

volatile integer LENGTH_SYSTEMS = 40

DEFINE_VARIABLE


//Structure for Storing RMS Level
_RMS_LEVELS RMS_LEVELS
_RMS_LEVELS REPORTED_RMS_LEVELS
_Systems System

VOLATILE _Lesson NEXT_LESSON
VOLATILE _Lesson LIVE_LESSON

VOLATILE INTEGER RMS_REFRESH_DATA

//
// The following constant strings provide
// a default subject and messages text for
// meeting scheduled via the touch panels
//
VOLATILE CHAR RMS_MEETING_DEFAULT_SUBJECT[] = ''
VOLATILE CHAR RMS_MEETING_DEFAULT_MESSAGE[] = ''

VOLATILE CHAR SYSTEMS_COMMAND_BUFFER[5120]

#INCLUDE 'RMSCommon.axi'


//Send Command with delimiter added
DEFINE_FUNCTION SYSTEM_sendCommand ( DEV device, CHAR tCommand[512] )
{
    SEND_COMMAND device, "tCommand"
}


(***************************************)
(* Call Name: RMSDevMonSetParamCallback*)
(* Function:  Reset parameters         *)
(* Param:     DPS, Name, Value         *)
(* Return:    None                     *)
(* Note:      Caller must define this  *)
(***************************************)
DEFINE_FUNCTION RMSDevMonSetParamCallback(DEV dvTPMaster, CHAR cName[], CHAR cValue[])
{
}

(***************************************)
(* Call Name: RMSDevMonRegisterCallback*)
(* Function:  time to register devices *)
(* Param:     None                     *)
(* Return:    None                     *)
(* Note:      Caller must define this  *)
(***************************************)
DEFINE_FUNCTION RMSDevMonRegisterCallback()
{
}



//This evaluates the current RMS levels
DEFINE_FUNCTION RMS_evaluateLevels()
{
    //Current Appointment
    if ( RMS_LEVELS.Current != REPORTED_RMS_LEVELS.Current )
    {
	RMS_LEVELS.Current = REPORTED_RMS_LEVELS.Current
	
	//Refresh Lesson Data
	ON[RMS_REFRESH_DATA]
	
	//Remove Current Appt from Current Lesson
	if ( !RMS_LEVELS.Current )
	{
	    STACK_VAR _Lesson Blank
	    
	    //Send end call 
	    SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'EndMCUCall-code=',LIVE_LESSON.Code" )
	    
	    //Inform all other Systems that the lesson has ended
	    SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'LESSON_siteEnd-lesson=',ITOA(cLive),'&sysnum=',ITOA(SYSTEM_NUMBER+500)" )
	    
	    LIVE_LESSON = Blank
	}
    }
    
    //Minutes Remaining in Appointment
    if ( RMS_LEVELS.MinutesRemaining != REPORTED_RMS_LEVELS.MinutesRemaining )
    {
	RMS_LEVELS.MinutesRemaining = REPORTED_RMS_LEVELS.MinutesRemaining
	
	//Refresh Lesson Data
	ON[RMS_REFRESH_DATA]
    }
    
    //Next Appointment
    if ( RMS_LEVELS.Next != REPORTED_RMS_LEVELS.Next )
    {
	RMS_LEVELS.Next = REPORTED_RMS_LEVELS.Next

	//Remove Current Appt from Current Lesson
	if ( !RMS_LEVELS.Next )
	{
	    STACK_VAR _Lesson Blank
	    
	    //Send end Call
	    SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'EndMCUCall-code=',NEXT_LESSON.Code" )
	    
	    //Inform all other Systems that the lesson has ended
	    SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'LESSON_siteEnd-lesson=',ITOA(cNext),'&sysnum=',ITOA(SYSTEM_NUMBER+500)" )
	    
	    NEXT_LESSON = Blank
	}
	
	//Refresh Lesson Data
	ON[RMS_REFRESH_DATA]
    }
    
    //Minutes until Next Appt
    if ( RMS_LEVELS.MinutesUntilNext != REPORTED_RMS_LEVELS.MinutesUntilNext )
    {
	RMS_LEVELS.MinutesUntilNext = REPORTED_RMS_LEVELS.MinutesUntilNext
	
	//Refresh Lesson Data
	ON[RMS_REFRESH_DATA]
    }
}

DEFINE_FUNCTION RMS_RefreshLesson(integer lesson)
{
    if ( lesson == cNEXT )
    {
	//Only retrieve data if there is a lesson
	if ( RMS_LEVELS.Next )
	{
	    //Get Lesson information
	    SEND_COMMAND vdvLesson, "'GET_LESSON_DATA-index=',ITOA(RMS_LEVELS.Next)" 
	}
    }
    
    ELSE IF ( lesson == cLIVE )
    {
	//Only retrieve data if there is a lesson
	if ( RMS_LEVELS.Current )
	{
	    //Get Lesson information
	    SEND_COMMAND vdvLesson, "'GET_LESSON_DATA-index=',ITOA(RMS_LEVELS.Current)" 
	}
    }
}

DEFINE_EVENT

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
		LIVE_LESSON.Pin		= ATOI ( getAttrValue( 'pin', aCommand )  )
		LIVE_LESSON.Message  	= getAttrValue( 'message', aCommand )
		LIVE_LESSON.StartTime 	= getAttrValue( 'start', aCommand )
		LIVE_LESSON.EndTime 	= getAttrValue( 'end', aCommand )
		
		//Get other sites in the lesson
		SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'LESSON_SystemNumber-lesson=',ITOA ( cLIVE ),
					'&sysnum=',ITOA(SYSTEM_NUMBER+500),
					'&code=',LIVE_LESSON.Code,
					'&type=',ITOA ( LIVE_LESSON.Type )" )
	    }
	    ELSE if ( index == RMS_LEVELS.Next )
	    {
		NEXT_LESSON.index	= index
		NEXT_LESSON.Subject 	= getAttrValue( 'subjt', aCommand )
		NEXT_LESSON.Instructor 	= getAttrValue( 'instr', aCommand )
		NEXT_LESSON.Type 	= ATOI ( getAttrValue( 'type', aCommand ) )
		NEXT_LESSON.Code  	= getAttrValue( 'code', aCommand ) 
		NEXT_LESSON.Pin		= ATOI ( getAttrValue( 'pin', aCommand ) )
		NEXT_LESSON.Message  	= getAttrValue( 'message', aCommand ) 
		NEXT_LESSON.StartTime 	= getAttrValue( 'start', aCommand )
		NEXT_LESSON.EndTime 	= getAttrValue( 'end', aCommand )
		
		//Get other sites in the lesson
		SYSTEM_sendCommand ( vdvSystems[SYSTEM_NUMBER], "'LESSON_SystemNumber-lesson=',ITOA ( cNEXT ),
					'&sysnum=',ITOA(SYSTEM_NUMBER+500),
					'&code=',NEXT_LESSON.Code,
					'&type=',ITOA ( NEXT_LESSON.Type )" )
	    }
	}
    }
}



DATA_EVENT [vdvSystems]
{
    COMMAND:
    {
	STACK_VAR INTEGER reqSys
	#INCLUDE 'EventCommandParser.axi'
	
	//Get RMS Server details
	if ( FIND_STRING ( DATA.TEXT, 'SetRMSServer-', 1 ) )
	{
	    STACK_VAR CHAR Url[768]
	    
	    //Get URL Attribute
	    Url = GetAttrValue('url',aCommand)
	    
	    // Configure RMS Server Address
	    RMSSetServer(url)
	}
	
	//Return System Data to sender
	if ( FIND_STRING ( DATA.TEXT, 'GetSystemData-', 1 ))
	{
	    STACK_VAR INTEGER index
	    
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
						'sysnum=',ITOA(SYSTEM_NUMBER+500),
						'&name=',System.name,
						'&comp=',System.company,
						'&contact=',System.contact" )
	}
	
	//Extends Recurring Meeting by adding a new meeting
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_ExtendRecurring-', 1 ) )
	{
	    STACK_VAR CHAR code[16]
	    
	    code = getAttrValue('code', aCommand ) 
	    
	    //Is this system in this lesson
	    if ( FIND_STRING( code, LIVE_LESSON.Code, 1 ) )
	    {
		//Starts a new lesson from the end time of the existing lesson
		SYSTEM_sendCommand ( vdvSystems[ SYSTEM_NUMBER ], "'LESSON_Start-type=',ITOA(LIVE_LESSON.type),'&pin=',ITOA(LIVE_LESSON.pin),
					      '&sysnum=',ITOA( SYSTEM_NUMBER+500 ),
					      '&code=',LIVE_LESSON.Code,
					      '&start=',LEFT_STRING ( LIVE_LESSON.EndTime, 2 ),':02:00',
					      '&dur=60',
					      '&instr=',LIVE_LESSON.Instructor,
					      '&subject=',LIVE_LESSON.Subject,' [Extended]',
					      '&message=',LIVE_LESSON.message" )
	    }
	}
	
	//Receive extension request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_Extend', 1 ) )
	{
	    //if the command is for this system
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == system_number+500 )
	    {
		//Send Extension request to RMS Server
		SEND_COMMAND vdvRMSEngine, "'EXTEND-',getAttrValue( 'mins', aCommand )"
	    }
	}
	
	//Receive end request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_End', 1 ) )
	{
	    //if the command is for this system
	    if ( ATOI ( GetAttrValue('sysnum',aCommand) ) == system_number+500 )
	    {
		//Send Extension request to RMS Server
		SEND_COMMAND vdvRMSEngine, "'ENDNOW'"
	    }
	}
	
	//Receive end request
	if ( FIND_STRING ( DATA.TEXT, 'LESSON_Start', 1 ) )
	{
	    STACK_VAR INTEGER SysNum
	    
	    SysNum = ATOI ( GetAttrValue('sysnum',aCommand) ) 
	    
	    //if the command is for this system
	    if ( SysNum == system_number+500 )
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
    }
}


DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	//Set UK Time and Date Standard
	//UK date and time format?
	SEND_COMMAND vdvRMSEngine, "'DFORMAT-D'"
	SEND_COMMAND vdvRMSEngine, "'TFORMAT-2'"
	
	//Update the RMS file
	SEND_COMMAND vdvCLActions, "'SET ROOM INFO-Virtual Room ',ITOA ( SYSTEM_NUMBER + 500 ),',Ether,Global Knowledge'"
	
    }
    STRING:
    {
	if ( FIND_STRING ( DATA.TEXT,"'CHANGE-',LDATE",1 ) )
	{
	    ON[RMS_REFRESH_DATA]
	}
	
	//Read room info and update system info - Name
	if ( FIND_STRING ( DATA.TEXT,"'ROOM NAME-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM NAME-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER+500),
				'&name=',DATA.TEXT" )
				
	    SEND_COMMAND vdvCLActions, "'ROOM NAME-',DATA.TEXT"
	    
	    System.systemNumber = SYSTEM_NUMBER+500
	    System.name = DATA.TEXT
	}
	
	//Location
	if ( FIND_STRING ( DATA.TEXT,"'ROOM LOCATION-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM LOCATION-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER+500),
				'&contact=',DATA.TEXT,'@interoute.vc'" )
	    
	    System.contact = "DATA.TEXT,'@interoute.vc'"
	    
	    SEND_COMMAND vdvCLActions, "'ROOM LOCATION-',DATA.TEXT,'@interoute.vc'"
	}
	
	//Extend Lesson Error
	if ( FIND_STRING ( DATA.TEXT,"'EXTEND-NO'", 1 ) )
	{
	    //Remove ENDNOW-NO,
	    REMOVE_STRING ( DATA.TEXT, ',', 1 )
	    
	    //Extend by setting up a new meeting
	    SYSTEM_sendCommand ( vdvSystem, "'LESSON_ExtendRecurring-&code=',LIVE_LESSON.Code" )
	}
	
	//Company
	if ( FIND_STRING ( DATA.TEXT,"'ROOM OWNER-'",1) )
	{
	    REMOVE_STRING ( DATA.TEXT,"'ROOM OWNER-'",1 )
	    
	    SYSTEM_sendCommand ( vdvSystem,"'SetSystemData-',
				    'sysnum=',ITOA(SYSTEM_NUMBER+500),
				    '&comp=',DATA.TEXT" )
				    
	    System.company = DATA.TEXT
				    
	    SEND_COMMAND vdvCLActions, "'ROOM OWNER-',DATA.TEXT"
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
}



DEFINE_PROGRAM

//Loop to prevent multiple refresh requests
WAIT 20
{
    if ( RMS_REFRESH_DATA )
    {
	RMS_RefreshLesson(cNEXT)
	RMS_RefreshLesson(cLIVE)
	
	//Reset Flag
	OFF[RMS_REFRESH_DATA]
    }
}

WAIT 100
{
    //If Connected to the RMS server then evaluate the RMS Levels
    if ( [ vdvRMSEngine, 248 ] AND [ vdvRMSEngine, 249 ] AND [ vdvRMSEngine, 250 ])
    {
	//Revaluate Levels
	RMS_evaluateLevels()
    }
}


