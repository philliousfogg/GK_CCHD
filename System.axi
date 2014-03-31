PROGRAM_NAME='SystemClass'

DEFINE_CONSTANT 

volatile integer LENGTH_SYSTEMS = 40
volatile integer LISTS_LENGTH = 1

VOLATILE INTEGER TEACHER = 1
VOLATILE INTEGER STUDENT = 2
VOLATILE INTEGER OFF_LINE = 3

VOLATILE INTEGER cNEXT 	 = 1
VOLATILE INTEGER cLIVE	 = 2

LENGTH_DEVICES = 6

VOLATILE INTEGER SITE = 1
VOLATILE INTEGER VIRTUAL = 2
VOLATILE INTEGER MOBILE_UNITS = 3

DEFINE_VARIABLE

VOLATILE INTEGER MASTER_PIN = 1988

DEFINE_TYPE

STRUCTURE _DEVICES {

    INTEGER Id
    Char Name[64]
    Char Manufacturer[64]
    Char Model[64]
    Char SerialNumber[64]
    Char IPAddress[18]
    Char Password[64]
    CHAR BaudRate[6]
    dev vDevice
    dev pDevice
    INTEGER Lamptime
    CHAR Input[16]
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
    integer mobile		//Is the system a mobile system
    integer roomType		//What is the room type Student Only or Teacher
    integer volume		//Room Volume Level
    integer cameraInverse	//if Cam 1 is rear and Cam 2 is front
}


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
    CHAR external[255]
    LONG Pin
    INTEGER Type
    CHAR Code[16]
    CHAR StartTime[9]
    CHAR EndTime[9]
}

DEFINE_VARIABLE

VOLATILE _Systems Systems[LENGTH_SYSTEMS]

VOLATILE INTEGER SystemUIList	//The UI Room List Index number
VOLATILE INTEGER ACTIVE_SYSTEM	//Current Active System 
VOLATILE INTEGER CONNECT_SITES 	//Instructs system to try and connect to sites in the lesson
VOLATILE INTEGER ACTIVE_CAMERA[LENGTH_SYSTEMS]
VOLATILE INTEGER MAPPED_CAMERAS[2]  //By default sets front cam as 1 and Back cam as 2 but can be
				    //remapped for existing rooms


//User variables
VOLATILE INTEGER SYSTEM_PIN = 7988
VOLATILE INTEGER PERMISSION_LEVEL

VOLATILE _Lesson NEXT_LESSON
VOLATILE _Lesson LIVE_LESSON

VOLATILE INTEGER RMS_REFRESH_DATA

VOLATILE INTEGER RMS_ROOM_SETUP_TIME = 60 //Minutes
VOLATILE LONG LOGOUT_TIME = 72000 //120 minutes

VOLATILE CHAR PREVIOUS_CALL_STATE[10][255]

VOLATILE CHAR SPLASH_SCREEN_TEXT[255]

VOLATILE INTEGER CALL_ATTEMPT[LENGTH_SYSTEMS]

//Structure for Storing RMS Level
_RMS_LEVELS RMS_LEVELS
_RMS_LEVELS REPORTED_RMS_LEVELS

//Flag to tell system to override RMS events
VOLATILE INTEGER OVERRIDE_RMS
VOLATILE INTEGER RECURRING_SHUTDOWN

//Initial Camera Switch at beginning of lesson
VOLATILE INTEGER CAM_LESSON_SWITCHED

//Switch all projectors on at start of lesson 
VOLATILE INTEGER PROJECTOR_INIT_START[LENGTH_DEVICES]

//Packet identifier for clipped packets
VOLATILE INTEGER PACKET_ID

//Control Menu
VOLATILE INTEGER SELECTED_MENU
VOLATILE CHAR uiMenu[8][64] = 	{
				    'Home',
				    'CameraControls',
				    'Lights',
				    'Presentation',
				    'SiteList',
				    'Devices',
				    'Setup',
				    'ScreenLayout'
				}

//An Array of all the Devices within the system
volatile dev vdvDevices[] = {

    vdvProjector1,
    vdvProjector2,
    vdvProjector3,
    vdvCodec,
    vdvCodecPres,
    vdvAmplifier,
    vdvLight
}

VOLATILE _DEVICES DEVICES[LENGTH_DEVICES]

VOLATILE INTEGER SITE_LIST_FILTER

VOLATILE CHAR RMS_SERVER_URL[255]

VOLATILE INTEGER CAM_CONTROL_TIMEOUT

DEFINE_MUTUALLY_EXCLUSIVE

( [dvRelay, 1], [dvRelay, 2] )

//Send Command with delimiter added
DEFINE_FUNCTION SYSTEM_sendCommand ( DEV device, CHAR tCommand[512] )
{
    SEND_COMMAND device, "tCommand"
}

//Debugs System
DEFINE_FUNCTION DEBUG ( char text[255] )
{
    if ( [vdvSystem, SystemChannels[256]] )
    {
	SEND_STRING 0, text
    }
}

//Sets the feedback for each mic mute button in the site list (Ran in main line)
DEFINE_FUNCTION SYSTEM_micMuteSiteFB()
{
    STACK_VAR INTEGER i 
    
    //Cycle through each button and get mic mute status
    for ( i=1; i<=UIList[SystemUIList].DisplaySize; i++ )
    {
	STACK_VAR INTEGER sysnum
	STACK_VAR INTEGER Index
	
	//if there is a 
	if ( UIList[SystemUIList].Slot[i] )
	{
	    //Set Sysnum
	    sysnum = GetDataIDFromDataSet ( SystemUIList, i )  
		
	    if ( sysnum < 1000 )
	    {
		
		//Index
		Index = SYSTEM_getIndexFromSysNum( sysnum ) 
		
		if ( sysnum < 500 )
		{
		    //Set the feedback on button
		    [dvTP, UIBtns[i+30] ] = [vdvCodecs[ sysnum ], VCONF_PRIVACY_FB ]
		}
		
		//If in call then show end call button
		if ( SysNum != SYSTEM_NUMBER)
		{
		    //Set the feedback on button
		    [dvTP, UIBtns[i+40] ] = ( Systems[Index].liveLesson OR Systems[Index].NextLesson ) 
		}
		
		//Notifys user of connection status
		[dvTP, UIBtns[i+110]] = Systems[Index].status
	    }
	}
    }
}	


//Creates an Alert Message Box
DEFINE_FUNCTION SYSTEM_alert( char title[32], Char message[150] )
{
    //Set Text for the dialog box
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[61] ),'-',title"
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[62] ),'-',message"
    
    //Show Dialog Box
    SEND_COMMAND dvTP, "'@PPN-_Alert'"
}


//Clear all the this lesson flags form the system
DEFINE_FUNCTION SYSTEMS_clearLesson( integer lesson )
{
    STACK_VAR INTEGER i 
    
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//if there is a system stored
	if ( SYSTEMS[i].systemNumber )
	{
	    if ( lesson == cNEXT )
	    {
		OFF [ SYSTEMS[i].NextLesson ]
	    }
	    else if ( lesson == cLIVE )
	    {
		OFF [ SYSTEMS[i].liveLesson ]
	    }
	}
	
	//break loop if not
	ELSE
	{
	    break
	}
    }
}

//Returns the number of sites in the lesson
DEFINE_FUNCTION integer SYSTEM_countLessonSites(integer lesson)
{
    STACK_VAR INTEGER i,ct 
    
    //Cycle through all systems
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//Check if system exists
	if ( SYSTEMS[i].systemNumber )
	{
	    if ( lesson ==  cNEXT ) 
	    {
		//Check the system is in the next lesson
		if ( SYSTEMS[i].nextLesson )
		{
		    //Count system
		    ct++
		}
	    }
	    else if ( lesson == cLIVE )
	    {
		//Check the system is in this lesson
		if ( SYSTEMS[i].liveLesson )
		{
		    //Count system
		    ct++
		}
	    }
	}
	//End of list break loop 
	ELSE
	{
	    break
	}
    }
    
    //Return Count 
    return ct
}

//Set Projector 
DEFINE_FUNCTION SYSTEM_setProjectorPower(dev device, INTEGER Function)
{
    if ( [device, DATA_INITIALIZED] )
    {
	//If the projector is not on and the lamp is not warming or cooling 
	if ( ![ device, POWER_FB ] AND ![ device, LAMP_WARMING_FB ]
		OR ![ device, LAMP_COOLING_FB ] AND ( Function == PWR_ON ) )
	{
	    //Power up the projector
	    PULSE[ device, PWR_ON ]
	}
	
	ELSE IF ( [ device, POWER_FB ] AND ![ device, LAMP_WARMING_FB ]
		OR ![ device, LAMP_COOLING_FB ] AND (Function == PWR_OFF) )
	{
	    //Power Off the projector
	    PULSE[ device, PWR_OFF ]
	}
    }
}

//Set Projector input
DEFINE_FUNCTION SYSTEM_setProjectorInput(dev device, CHAR input[] )
{
    //if the prejector is on and the lamp is not warming or cooling
    IF ( [ device, POWER_FB ] AND ( ![ device, LAMP_WARMING_FB ] OR ![ device, LAMP_COOLING_FB ] ) )
    {
	STACK_VAR INTEGER index
	
	//Get Device index from the DATA.DEVICE
	index = DEVICES_getDeviceIDFromDev( DEVICE )
	
	//Is the device already set to the correct input
	if ( !FIND_STRING( input, DEVICES[index].input, 1 ) )
	{
	    //Set to the correct input
	    SEND_COMMAND device, "'Input-',input"
	}
    }
}

//Finds Teacher room
DEFINE_FUNCTION integer SYSTEMS_getTeacherRoom()
{
    STACK_VAR INTEGER i 
    
    //Cycle through all systems and find techer room
    FOR ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	if ( Systems[i].roomType == TEACHER)
	{
	    return i
	}
    }
    
    //No teacher room in lesson
    return 0
}

//Sets Room According to Useage type
DEFINE_FUNCTION SYSTEM_setupRoom( INTEGER Type )
{
    //Switch on Codec
    PULSE[vdvCodec, PWR_ON]
    
    //If the room is for teacher
    if ( type == TEACHER )
    {
	STACK_VAR INTEGER i
	
	//Projectors
	FOR ( i=1; i<=LENGTH_DEVICES; i++ )
	{
	    if ( DEVICES[i].id )
	    {
		//SmartBoard Projector 
		if ( DEVICES[i].vDevice.number == 33011 )
		{
		    if ( !PROJECTOR_INIT_START[i] )
		    {
			// Set Codec presentation to on 
			ON[vdvCodec, 309]
			
			SYSTEM_setProjectorPower(DEVICES[i].vDevice, PWR_ON)
			
			//If Projector on set flag
			if ( [DEVICES[i].vDevice, POWER_FB] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] ) )
			{
			    ON[PROJECTOR_INIT_START[i]]
			}
		    }
		    
		    //If codec presentation is set
		    if ( [vdvCodec, 309] )
		    {
			SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'HDMI,1' )
		    }
		    ELSE
		    {
			SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'VGA,1' )
		    }
		}
		
		//Far End Rear Projector 
		if ( DEVICES[i].vDevice.number == 33013 AND !PROJECTOR_INIT_START[i] )
		{
		    SYSTEM_setProjectorPower(DEVICES[i].vDevice, PWR_ON)
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'HDMI,1' )
		    
		    //If Projector on set flag
		    if ( [DEVICES[i].vDevice, POWER_FB] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] ) )
		    {
			ON[PROJECTOR_INIT_START[i]]
		    }
		}
		
		//Set Amplifier Input
		if ( DEVICES[i].vDevice.number == 33014 )
		{
		    if ( ![vdvAmplifier,POWER_FB] )
		    {
			PULSE[vdvAmplifier, PWR_ON]
		    }
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'A' )
		}
	    }
	}
	
	//Set Lights
    }
    
    //If room is for students only
    else if ( type == STUDENT )
    {
	STACK_VAR INTEGER i
	
	//Projectors
	FOR ( i=1; i<=LENGTH_DEVICES; i++ )
	{
	    if ( DEVICES[i].id )
	    {
		//SmartBoard Projector 
		if ( DEVICES[i].vDevice.number == 33011 )
		{
		    STACK_VAR index
		    
		    index = SYSTEMS_getTeacherRoom()
		    
		    if ( !PROJECTOR_INIT_START[i] )
		    {
			SYSTEM_setProjectorPower(DEVICES[i].vDevice, PWR_ON)
			
			//If Projector on set flag
			if ( [DEVICES[i].vDevice, POWER_FB] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] ) )
			{
			    ON[PROJECTOR_INIT_START[i]]
			}
		    }
		    
		    //If codec presentation is set
		    if ( [ vdvCodecs[ Systems[index].SystemNumber ], 309] )
		    {
			SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'HDMI,1' )
		    }
		    ELSE
		    {
			SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'VGA,1' )
		    }
		    
		    
		}
		
		//Far End Front Projector 
		if ( DEVICES[i].vDevice.number == 33012 AND !PROJECTOR_INIT_START[i]  )
		{
		    SYSTEM_setProjectorPower(DEVICES[i].vDevice, PWR_ON)
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'HDMI,1' )
		    
		    //If Projector on set flag
		    if ( [DEVICES[i].vDevice, POWER_FB] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] ) )
		    {
			ON[PROJECTOR_INIT_START[i]]
		    }
		}
		
		//Set Amplifier Input
		if ( DEVICES[i].vDevice.number == 33014 )
		{
		    if ( ![vdvAmplifier,POWER_FB] )
		    {
			PULSE[vdvAmplifier, PWR_ON]
		    }
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'A' )
		}
	    }
	}
    }
    
    //If Offline mode
    ELSE IF ( type == OFF_LINE )
    {
	STACK_VAR INTEGER i
	
	//Projectors
	FOR ( i=1; i<=LENGTH_DEVICES; i++ )
	{
	    if ( DEVICES[i].id )
	    {
		SEND_STRING 0, "'Device Number = ', ITOA ( DEVICES[i].vDevice.number )"
		
		//SmartBoard Projector 
		if ( DEVICES[i].vDevice.number == 33011 AND !PROJECTOR_INIT_START[i] )
		{
		    STACK_VAR index
		    
		    SEND_STRING 0, "'ON = ', ITOA ( DEVICES[i].vDevice.number )"
		    
		    SYSTEM_setProjectorPower(DEVICES[i].vDevice, PWR_ON)
		    
		    index = SYSTEMS_getTeacherRoom()
		    
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'VGA,1' )
		    
		    //If Projector on set flag
		    if ( [DEVICES[i].vDevice, POWER_FB] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] )  )
		    {
			ON[PROJECTOR_INIT_START[i]]
		    }
		}
		
		//Set Amplifier Input
		if ( DEVICES[i].vDevice.number == 33014 )
		{
		    if ( ![vdvAmplifier,POWER_FB] )
		    {
			PULSE[vdvAmplifier, PWR_ON]
		    }
		    
		    SYSTEM_setProjectorInput( DEVICES[i].vDevice, 'A' )
		}
	    }
	}
    }
}

//Add System to structure
DEFINE_FUNCTION SYSTEMS_thisSystem (  
				     CHAR name[64], 
				     CHAR location[64], 
				     CHAR company[64], 
				     INTEGER camInverse,
				     INTEGER mobile,
				     INTEGER receiveOnly
				    )
{
    // Register Room
    SYSTEMS[1].SysDev 		= vdvSystem
    SYSTEMS[1].systemNumber 	= SYSTEM_NUMBER
    SYSTEMS[1].NAME 		= name
    SYSTEMS[1].LOCATION 	= location
    SYSTEMS[1].COMPANY 		= company
    SYSTEMS[1].thisSystem	= true
    SYSTEMS[1].mobile		= mobile
    SYSTEMS[1].receiveOnly	= receiveOnly
    SYSTEMS[1].cameraInverse	= camInverse
}


//Adds System to the systems structure
DEFINE_FUNCTION Systems_AddSystem( _Command aCommand  )
{
    STACK_VAR integer i 
    STACK_VAR integer found
    STACK_VAR _Systems system
    STACK_VAR INTEGER sysnum
    
    sysnum = ATOI ( GetAttrValue( 'sysnum', aCommand ) )   
    
    //Check to see if system exists
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//if system exists then update data by system number
	if ( sysNum == Systems[i].systemNumber )
	{
	    //Only Update request fields
	    if ( GetAttrValue('name',aCommand) != 'null' ) 
		systems[i].Name = GetAttrValue('name',aCommand)
	    if ( GetAttrValue('loc',aCommand) != 'null' )
		systems[i].location = GetAttrValue('loc',aCommand)
	    if ( GetAttrValue('comp',aCommand) != 'null' ) 
		systems[i].company = GetAttrValue('comp',aCommand)
	    if ( GetAttrValue('contact',aCommand) != 'null' ) 
		systems[i].contact = GetAttrValue('contact',aCommand)
	    
	    if ( GetAttrValue('mobile',aCommand) != 'null' )
	    {
		systems[i].mobile = AtoI ( GetAttrValue('mobile',aCommand) )
	    }
	    
	    if ( GetAttrValue('receive',aCommand) != 'null' )
	    {
		systems[i].receiveOnly = AtoI ( GetAttrValue('receive',aCommand) )
	    }
	    
	    if ( GetAttrValue('invcam',aCommand) != 'null' )
	    {
		systems[i].cameraInverse = AtoI ( GetAttrValue('invcam',aCommand) )
	    }
	    
	    ON[found]
	    break;
	}
    }
    
    if ( !found )
    {
	//Cycle through system list
	for ( i=1; i<=LENGTH_SYSTEMS; i++ )
	{
	    //Find an empty slot
	    if ( !Systems[i].systemNumber )
	    {
		Systems[i].systemNumber = sysNum
		
		//If it is 'this' system then flag
		if ( systems[i].systemNumber == SYSTEM_NUMBER )
		    Systems[i].thisSystem = 1
		//Only Update request fields
		if ( GetAttrValue('name',aCommand) != 'null' ) 
		    systems[i].Name = GetAttrValue('name',aCommand)
		if ( GetAttrValue('loc',aCommand) != 'null' )
		    systems[i].location = GetAttrValue('loc',aCommand)
		if ( GetAttrValue('comp',aCommand) != 'null' ) 
		    systems[i].company = GetAttrValue('comp',aCommand)
		if ( GetAttrValue('contact',aCommand) != 'null' ) 
		    systems[i].contact = GetAttrValue('contact',aCommand)
		
		if ( GetAttrValue('receive',aCommand) != 'null' )
		{
		    systems[i].receiveOnly = AtoI ( GetAttrValue('receive',aCommand) )
		}
		
		if ( GetAttrValue('invcam',aCommand) != 'null' )
		{
		    systems[i].cameraInverse = AtoI ( GetAttrValue('invcam',aCommand) )
		}
		
		break
	    }
	}
    }
    
    //Update the RMS file
    SEND_COMMAND vdvCLActions, "'SET ROOM INFO-',systems[i].Name ,',',systems[i].location,',',systems[i].company"
    
    //Update Room Status to On
    System_Status(sysNum, 1)
}

//Get Array Index from the system number
DEFINE_FUNCTION INTEGER SYSTEM_getIndexFromSysNum(INTEGER SysNum)
{
    STACK_VAR INTEGER i 
    
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//if the system number matches 
	if ( SysNum == SYSTEMS[i].systemNumber )
	{
	    //return index
	    return i
	}
    }

    //No System found
    return 0
}

DEFINE_FUNCTION Systems_addSystemToList( integer counter, integer i )
{
    STACK_VAR CHAR StatusTxt[64]
    
    if ( Systems[i].thisSystem )
    {
	StatusTxt = "' - My Room'"
    }
    
    if ( !Systems[i].status )  
    {
	StatusTxt = "StatusTxt, ' OFFLINE'"
    }
    
    addListElement( SystemUIList, "systems[i].name", counter, Systems[i].systemNumber )
}


//Updates Systems UI List
DEFINE_FUNCTION Systems_UpdateUIList(integer position)
{
    STACK_VAR INTEGER i,x
    STACK_VAR INTEGER index
    
    //if no position then maintain list position
    if ( !position )
    {
	position = UIList[SystemUIList].Position
    }    
    
    //Clear List Elements
    clearListElements(SystemUIList)
    
    //get this system index
    index = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
    
    //Populate list with active systems
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	if ( Systems[i].systemNumber )
	{
	    //Filter for sites in this lesson if Teacher is logged in
	    if ( PERMISSION_LEVEL == 3 )
	    {
		//Don't add virtual rooms
		if ( Systems[i].systemNumber < 500 )
		{
		    if ( Systems[index].liveLesson )
		    {
			if ( Systems[i].liveLesson )
			{
			    x++
			    Systems_addSystemToList(x,i)
			}
		    }
		    else
		    {
			if ( Systems[i].nextLesson )
			{
			    x++
			    Systems_addSystemToList(x,i)
			}
		    }
		}
	    }
	    
	    //Administrator
	    else if ( PERMISSION_LEVEL < 3 )
	    {
		if ( ( SITE_LIST_FILTER == VIRTUAL ) AND ( Systems[i].systemNumber > 500 ) )
		{
		    x++
		    Systems_addSystemToList(x,i)
		}
		ELSE if ( ( SITE_LIST_FILTER == SITE ) AND ( Systems[i].systemNumber < 500 ) AND ( !Systems[i].mobile ) )
		{
		    x++
		    Systems_addSystemToList(x,i)
		}
		ELSE if ( ( SITE_LIST_FILTER == MOBILE_UNITS ) AND ( Systems[i].mobile ) )
		{
		    x++
		    Systems_addSystemToList(x,i)
		}
		ELSE if ( !SITE_LIST_FILTER )
		{
		    x++
		    Systems_addSystemToList(x,i)
		}
	    }
	}
    }
    
    // Check for external Parties
    if ( Systems[index].liveLesson )
    {
	if ( LENGTH_STRING ( LIVE_LESSON.external ) )
	{
	    x++
	    addListElement( SystemUIList, LIVE_LESSON.external, x, 1001 )
	}
    }	
    
    //Display list on the UI
    displayListData( SystemUIList, position, UIBtns, 0 )
}

//Removes System from Systems
DEFINE_FUNCTION Systems_Remove( integer sysNum )
{
    STACK_VAR _Systems Blank
    STACK_VAR INTEGER i 
    
    //Cycle through system list
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//Find system to remove
	if ( Systems[i].systemNumber == sysNum )
	{
	    //Clear system from slot
	    Systems[i] = Blank
	    break
	}
    }
    
    //Update UI List
    Systems_UpdateUIList(0)
}

//Sets the current status of the system
DEFINE_FUNCTION System_Status( integer sysNum, integer status )
{
    STACK_VAR INTEGER i 
    
    //Cycle through system list
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//Find system to remove
	if ( Systems[i].systemNumber == sysNum OR Systems[i].systemNumber == 500 + sysNum )
	{
	    //Clear system from slot
	    Systems[i].Status = status
	    
	    //Clear lesson information if system offline
	    if ( !status )
	    {
		Systems[i].liveLesson = 0
		Systems[i].nextLesson = 0
		Systems[i].roomType = 0
	    }
	}
    }
    
    //Update UI List
    Systems_UpdateUIList(0)
}

//Clear Splash Screen Text
DEFINE_FUNCTION SYSTEM_clearSplashScreenText()
{
    STACK_VAR INTEGER i 
    
    SPLASH_SCREEN_TEXT = ''
    
    SEND_COMMAND dvTP, "'TEXT', ITOA( UIBtns[ 3 ] ),'-'"
}

 

//Updates the Status on the Splash Screen
DEFINE_FUNCTION SYSTEM_addSplashScreenText(CHAR text[255])
{
    SPLASH_SCREEN_TEXT = text
    SEND_COMMAND dvTP, "'TEXT', ITOA( UIBtns[ 3 ] ),'-',SPLASH_SCREEN_TEXT"
}

//Show the UI Page
DEFINE_FUNCTION SYSTEM_ShowUIStart()
{    
    SYSTEM_sendCommand ( vdvSystem, "'RefreshUI-'" )
    
    //Set This Room Name
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[80] ),'-',SYSTEMS[SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)].NAME"
} 

//Show the projector Buttons in the system
DEFINE_FUNCTION	System_setProjectorButtons()
{
    //Hide all of them first
}

//Show the control page
DEFINE_FUNCTION SYSTEM_ShowMain()
{
    STACK_VAR INTEGER Index
    STACK_VAR INTEGER DialogIndex
    
    //Set Room list depending on permission level
    //if there is no presentation selected display options
    if ( ![dvRELAY,1] AND ![dvRelay,2] )
    {
	if ( PERMISSION_LEVEL == 3 )
	{
	    //Display the presentation options
	    SEND_COMMAND dvTP, "'@PPN-_ShowPresentationOptions;Admin'"
	}
    }
    
    UIList[SystemUIList].Selected = 0
    
    //Update Name
    if ( ACTIVE_SYSTEM )
    {
	//Get index from Active System number
	Index = SYSTEM_getIndexFromSysNum(ACTIVE_SYSTEM)
    }
    ELSE
    {
	//Get Index from Resident System Number
	Index = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
	
	//Set Active system to local system
	ACTIVE_SYSTEM = SYSTEM_NUMBER
	
	//Set site list filter to site list
	SITE_LIST_FILTER = 0
	
	//Set the list item to this system
	setElementSelectedbyButton( SystemUIList, 11 )
	
	//Show only the rooms in the lesson
	Systems_UpdateUIList(1)
    }
  
    
    //Sets the buttons depending on if its a receive room
    SYSTEM_evaluateRoom(Index)
    
    //Get Current Lighting Levels
    SEND_COMMAND vdvLights[ACTIVE_SYSTEM], "'GET_LEVELS'"

    //Set Active Room Name
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[2] ),'-',SYSTEMS[index].NAME"
    
    //Set This Room Name
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[80] ),'-',SYSTEMS[SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)].NAME"

    //Set the Active Room Connected Site
    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[4] ),'-',SYSTEMS[index].callStatus"
    
    //Show Devices menu if admin and hide if not
    if ( PERMISSION_LEVEL >= 3 )
    {
	//Hide Admin Device Buttons
	SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[100] ),',0'"
	
	//if there is a virtual room
	if ( RMS_isVirtualRoom() )
	{
	    //Hide Screen Layout Button
	    SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[58] ),',1'"
	}
	ELSE
	{
	    //Show Screen Layout Button
	    SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[58] ),',0'"
	}
    }
    ELSE
    {
	//Show Admin Devices Buttons
	SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[100] ),',1'"
	
	//Show Screen Layout Button
	SEND_COMMAND dvTP, "'^SHO-',ITOA( UIBtns[58] ),',1'"
    }

    SEND_COMMAND dvTP, "'PAGE-Admin'"
    
    //Map Cameras
    Codec_setCameraMapping ( index )
    
    //Show Current Dialogs
    Dialog_ShowCurrentDialog()
}

//Updates the Call status field in the System List
DEFINE_FUNCTION Systems_CallStatus( integer sysnum, char status[255] )
{
    STACK_VAR INTEGER i    
    
    //Cycle through systems
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	if ( SYSTEMS[i].systemNumber == sysnum )
	{
	    //Only update if necessary
	    if ( SYSTEMS[i].callStatus != status )
	    {
		Systems[i].callStatus = status 
		
		//Update UI
		Systems_UpdateUIList(0)
		
		//Set Active System Status
		if ( sysnum == ACTIVE_SYSTEM )
		{
		    SEND_COMMAND dvTP, "'TEXT',ITOA( UIBtns[4] ),'-',Systems[i].callStatus"
		}			
	    }
	}
    }
}

//Set Logout
DEFINE_FUNCTION SYSTEM_logout()
{
    //Set Permission Level to Zero 
    PERMISSION_LEVEL = 0
    
    //Set Selected page to 0
    SELECTED_MENU = 0
    
    //Set Active system to 'this' system
    ACTIVE_SYSTEM = SYSTEM_NUMBER
    
    //Refresh UI to bring up the Login page
    SYSTEM_sendCommand ( vdvSystem, "'RefreshUI-'" )
    
    //Show Current Dialogs
    Dialog_ShowCurrentDialog()
}

//Shut down devices
DEFINE_FUNCTION SYSTEM_ShutdownDevices( )
{
    STACK_VAR INTEGER i 
    
    for ( i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( DEVICES[i].Id )
	{
	    if ( [ DEVICES[i].vDevice, POWER_FB ] AND ( ![ DEVICES[i].vDevice, LAMP_WARMING_FB ] OR ![ DEVICES[i].vDevice, LAMP_COOLING_FB ] ) )
	    {
		//Pulse the power command
		PULSE[ DEVICES[i].vDevice, PWR_OFF ]
	    }
	}
    }
}

//Finds the virtual room within the lesson
DEFINE_FUNCTION integer SYSTEM_findVirtualRoom(integer lesson)
{
    STACK_VAR INTEGER i,ct 
    
    //Cycle through all systems
    for ( i=1; i<=LENGTH_SYSTEMS; i++ )
    {
	//Check if system exists
	if ( SYSTEMS[i].systemNumber > 500 )
	{
	    if ( lesson ==  cNEXT ) 
	    {
		//Check the system is in the next lesson
		if ( SYSTEMS[i].nextLesson )
		{
		    return i
		}
	    }
	    else if ( lesson == cLIVE )
	    {
		//Check the system is in this lesson
		if ( SYSTEMS[i].liveLesson )
		{
		    return i
		}
	    }
	}
    }
    
    //Return Count 
    return 0
}

DEFINE_FUNCTION SYSTEM_setBtnVisibility( DEV TP, INTEGER btn, INTEGER show )
{
    SEND_COMMAND TP, "'^SHO-',ITOA ( btn ),',',ITOA (show)"
}

DEFINE_FUNCTION SYSTEM_evaluateRoom(Integer Index) 
{    
    // Hide all effected Buttons
    
    // Camera Front/Back Buttons 
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[7], 0 )
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[8], 0 )
    
    // Camera Help Text
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[31], 0 )
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[32], 0 )
    
    // Rear Projector Button
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[73], 0 )
    
    // Camera 2 Backlight compensation
    SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[22], 0 )
    
    // All Functionality Menu buttons
    SYSTEM_setBtnVisibility ( dvTP, UIBtns[52], 0 )
    SYSTEM_setBtnVisibility ( dvTP, UIBtns[54], 0 )
    SYSTEM_setBtnVisibility ( dvTP, UIBtns[58], 0 )
    SYSTEM_setBtnVisibility ( dvTP, UIBtns[56], 0 )
    SYSTEM_setBtnVisibility ( dvTP, UIBtns[53], 0 )
    
    //Receive Room
    if ( Systems[index].receiveOnly )
    {
	// Mobile Rooms
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[52], true )
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[53], true )
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[54], true )
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[56], true )
	
	if ( RMS_isVirtualRoom() )
	{
	    SYSTEM_setBtnVisibility ( dvTP, UIBtns[58], true )
	}
	
	//Make sure camera 1 is active camera
	ACTIVE_CAMERA[ACTIVE_SYSTEM] = 1
	
	// Select Camera
	SELECTED_MENU = 52
    }
    
    // Mobile Rooms
    ELSE IF ( Systems[index].mobile )
    {
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[52], true )
	
	if ( RMS_isVirtualRoom() )
	{
	    SYSTEM_setBtnVisibility ( dvTP, UIBtns[58], true )
	}
	
	// Select Camera
	SELECTED_MENU = 52
    }
    
    // Virtual Rooms
    ELSE IF ( SYSTEMS[index].systemNumber > 500 )
    {
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[58], true )
	
	// Select Screen Layout
	SELECTED_MENU = 58
    }
    
    // Normal CCHD Room
    ELSE 
    {
	// Camera Front/Back Buttons 
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[7], 1 )
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[8], 1 )
	
	// Camera Help Text
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[31], 1 )
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[32], 1 )
	
	// Rear Projector Button
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[73], 1 )
	
	// All Functionality Menu buttons
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[52], 1 )
	
	if ( RMS_isVirtualRoom() )
	{
	    SYSTEM_setBtnVisibility ( dvTP, UIBtns[58], 1 )
	}
	
	SYSTEM_setBtnVisibility ( dvTP, UIBtns[53], 1 )
	
	// Camera 2 Backlight compensation
	SYSTEM_setBtnVisibility ( dvTPCodec, VCCameraBtns[22], 1 )
	
	if ( SYSTEMS[Index].thisSystem )
	{
	    SYSTEM_setBtnVisibility ( dvTP, UIBtns[54], 1 )
	    SYSTEM_setBtnVisibility ( dvTP, UIBtns[56], 1 )
	    
	    // Select Presentation Page
	    SELECTED_MENU = 54
	}
	ELSE
	{
	    // Select Camera Page
	    SELECTED_MENU = 52
	}
    }
    
    //Show Control Page
    SEND_COMMAND dvTP, "'@PPN-[Menu]',uiMenu[ SELECTED_MENU - 50 ],';Admin'"
}

//Adds additional elements to the list (this is called from UI_TOOLs
DEFINE_FUNCTION UI_TOOLS_DisplayListElement( integer List, char ref[], integer pData, integer BtnIndex, integer TPport )
	{
	    //Check to see we are using the correct list by UI Port.
	    if ( list == SystemUIList )
	    {
		STACK_VAR INTEGER Index
		STACK_VAR INTEGER SysNum
		
		//Get System Number 
		SysNum = pData
		
		//Index
		Index = SYSTEM_getIndexFromSysNum( sysnum )
		
		IF ( SysNum )
		{
		    //Show Call List Buttons
		    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[BtnIndex + 20] ),'-',SYSTEMS[ Index ].callStatus" //Show Call State
		    
		    //Don't show mic if virtual system and external call
		    if ( SysNum < 501 ) 
		    {
			//Show Mic Mute Button
			SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 30] ),',1'"
		    }
		    
		    //Don't show the button if the this system and external call
		    if ( SysNum != SYSTEM_NUMBER OR SysNum < 1000 )
		    {
			//Show +/- button for add remove class
			SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 40] ),',1'"
		    }
		    
		    //Don't show the button if this is an external call
		    if ( SysNum < 1000 )
		    {
			//Show Offline Button
			SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 110] ),',1'"
		    }
		}
		
		//If Clearing List
		ELSE
		{
		    //Hide Call List Buttons
		    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[BtnIndex + 20] ),'-'" //Clear Call State
		    
		    //Hide Offline Button
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 110] ),',0'"
		    
		    //Hide Mic Mute Button
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 30] ),',0'"
		    
		    //Hide Mic Mute Button
		    SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[BtnIndex + 40] ),',0'"
		}
	    }
	}

//Confirms PIN change
DEFINE_FUNCTION System_changePinResponse( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer index
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'chgpin', 1 ) )
    {
	//remove 'chgpin-'
	REMOVE_STRING ( ref, '-', 1 )
	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	Switch ( response )
	{ 
	    CASE 1: 
	    {
		SYSTEM_sendCommand ( vdvSystem, "'CHANGE_PIN-pin=',ref" )
		
		SYSTEM_sendCommand ( vdvSystem, "'SET_PIN-pin=',ref" )
		
		SEND_STRING 0, 'ok'
	    }
	    CASE 2: 
	    {
		SEND_STRING 0, 'Cancel'
	    }
	}
    }
}



DEFINE_START

SET_VIRTUAL_CHANNEL_COUNT(vdvSystem, 1024)

//Set Active System to the Native system number
ACTIVE_SYSTEM = SYSTEM_NUMBER

//Create a system list
SystemUIList = NewList(dvTP, 10, 4, 'sylist')

//Set the selected menu to 1
SELECTED_MENU = 1

//Maps Camera to the correct port in the room
MAPPED_CAMERAS[1] = 1
MAPPED_CAMERAS[2] = 2


DEFINE_EVENT

//Check all button pushes
BUTTON_EVENT [dvTP, 0]
BUTTON_EVENT [dvTPCodec, 0]
{
    PUSH:
    {
	CANCEL_WAIT 'Logout'
	
	WAIT LOGOUT_TIME 'Logout'
	{
	    //if the system is logged in then log out.
	    if( PERMISSION_LEVEL AND !Dialog_getShowing() )
	    {
		SYSTEM_logout()
	    }
	}
    }
}

//Systems Button Events
BUTTON_EVENT [dvTP, UIBtns]
{
    PUSH:
    {
	STACK_VAR INTEGER svBtn
	
	svBtn = GET_LAST( UIBtns )
	
	SWITCH ( svBtn )
	{
	    //Amp Volume Up
	    CASE 100:
	    {
		ON[vdvAmplifier, VOL_UP]
	    }
	    
	    //Amp Volume Down
	    CASE 101:
	    {
		ON[vdvAmplifier, VOL_DN]
	    }
	    
	    CASE 11:
	    CASE 12:
	    CASE 13:
	    CASE 14:
	    {
		// Hide Site Add/Remove Context
		SEND_COMMAND dvTP, "'@PPK-_SiteContext'"
	    }
	}
    }
    RELEASE:
    {
	STACK_VAR INTEGER svBtn
	
	svBtn = GET_LAST( UIBtns )
	
	SWITCH ( svBtn )
	{
	    //Logout of the Session
	    CASE 6:
	    {
		SYSTEM_logout()
		
		// Hide Site Add/Remove Context
		SEND_COMMAND dvTP, "'@PPK-_SiteContext'"
	    }
	    
	    //Switch to Resident PC
	    CASE 7:
	    {
		ON[dvRelay, 1]
	    }
	    
	    CASE 8:
	    {
		ON[dvRelay, 2]
	    }
	    
	    //IncrementList
	    CASE 9:
	    {
		incrementList(SystemUIList, 1, UIbtns )
	    }
	    //DecrementList
	    CASE 10:
	    {
		decrementList(SystemUIList, 1, UIBtns )
	    }
	    
	    CASE 11:
	    CASE 12:
	    CASE 13:
	    CASE 14:
	    {
		STACK_VAR INTEGER index
		STACK_VAR INTEGER SysNum
		
		//Set Active System
		sysNum = GetDataIDFromDataSet ( SystemUIList, svBtn - 10 ) 
		
		//Get System Index
		index = SYSTEM_getIndexFromSysNum( sysNum )
		
		//If the system is not a virtual room
		if ( SYSTEMS[index].systemNumber < 501 )
		{
		    //Set the list item
		    setElementSelectedbyButton( SystemUIList, svBtn )
		    
		    //Set Active System
		    ACTIVE_SYSTEM = sysnum
		    
		    //Update Volume Level
		    SEND_LEVEL dvTPCodec, VCVolumeControls[5], Systems[index].volume
		    
		    //Set Active Room Name
		    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[2] ),'-',SYSTEMS[index].NAME"
		    
		    //Set the Active Room Connected Site
		    SEND_COMMAND dvTP, "'TEXT',ITOA ( UIBtns[4] ),'-',SYSTEMS[index].callStatus"
		    
		    //Map Cameras
		    Codec_setCameraMapping ( index )
		    
		    //Get Current Lighting Levels
		    SEND_COMMAND vdvLights[ACTIVE_SYSTEM], "'GET_LEVELS'"
		    
		    //Sets the buttons depending on if its a receive room
		    SYSTEM_evaluateRoom( Index )
		}
		ELSE
		{
		    SYSTEM_alert('Control Room','This room cannot be controlled.')
		}
	    }
	    
	    //Individual site mutes
	    CASE 31:
	    CASE 32:
	    CASE 33:
	    CASE 34:
	    {
		STACK_VAR INTEGER sysnum
		
		//Set sysnum
		sysnum = GetDataIDFromDataSet ( SystemUIList, svBtn - 30 ) 
		
		//Pulse the Mic Mute for this site
		PULSE[vdvCodecs[sysnum], VCONF_PRIVACY  ]
	    }
	    
	    //Individual Call Control
	    CASE 41:
	    CASE 42:
	    CASE 43:
	    CASE 44:
	    {
		STACK_VAR INTEGER sysnum
		STACK_VAR INTEGER index
		STACK_VAR INTEGER thisIndex
		
		//Set sysnum
		sysnum = GetDataIDFromDataSet ( SystemUIList, svBtn - 40 )
		
		//get index for systems
		index = SYSTEM_getIndexFromSysNum(sysnum)
		
		//get the index for this system
		thisIndex = SYSTEM_getIndexFromSysNum(SYSTEM_NUMBER)
		
		//If system online start lesson
		If ( Systems[Index].status )
		{
		    //if the system is in call ends the call on that system
		    if ( ( Systems[Index].liveLesson OR Systems[Index].NextLesson ) )
		    {
			if ( Systems[Index].liveLesson )
			{
			    SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=siteend',ITOA ( index ),
						    '&title=Remove Site From Lesson ',
						    '&message=This will remove ',Systems[index].name,' from the lesson',$0A,$0D,$0A,$0D,
						    'Do you wish to continue?',
						    '&res1=Ok&res2=Cancel&norepeat=1'" )
			}
			else
			{
			    SYSTEM_alert('End Meeting',"'You cannot end a lesson until it has started. Please contact the Administrator to remove the site.'")
			}
		    }
		    ELSE
		    {
			SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=sitestart',ITOA ( index ),
						'&title=Add Site',
						'&message=You are about to add ',Systems[index].name,' to the Lesson',$0A,$0D,$0A,$0D,
						'Do you wish to continue?',
						'&res1=Ok&res2=Cancel&norepeat=1'" )
		    }
		}
		ELSE
		{
		    SYSTEM_alert('System Online',"'This system is not currently online.'")
		}
	    }
	    
	    //Control Menu
	    CASE 51:
	    CASE 52:
	    CASE 53:
	    CASE 54:
	    CASE 55:
	    CASE 56:
	    CASE 57:
	    CASE 58:
	    {
		//Set the Menu and the selected option
		SELECTED_MENU = svBtn
		
		//Reset Cam_Control Layout
		CAM_CONTROL_TIMEOUT = 0
		
		//if the site list update site list
		if ( SELECTED_MENU == 55 )
		{
		    //Get all data from systems
		    SYSTEM_sendCommand ( vdvSystem, "'3GetSystemData-'" )
		    
		    //Show only the rooms in the lesson
		    Systems_UpdateUIList(0)
		}
		
		//Show Control Page
		SEND_COMMAND dvTP, "'@PPN-[Menu]',uiMenu[ SELECTED_MENU - 50 ],';Admin'"
	    }
	    
	    //Alert Ok
	    CASE 63:
	    {
		//Hide Alert Dialog
		SEND_COMMAND dvTP,"'@PPK-_Alert'"
	    }
	    
	    //Reset Call Attempt flag
	    CASE 81:
	    {
		STACK_VAR INTEGER i 
		
		//Show Alert button 
		SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[81] ),',0'"
		
		for ( i=1; i<= LENGTH_SYSTEMS; i++ )
		{
		    //Resets call attempt flag
		    CALL_ATTEMPT[i] = 0
		}
	    }
	    
	    //Override Scheduling
	    CASE 82:
	    {
		if ( OVERRIDE_RMS )
		{
		    OVERRIDE_RMS = 0
		    SEND_COMMAND dvTP, "'TEXT',ITOA( UIBtns[82] ),'-Override',$0D,'Scheduling'"
		}
		ELSE
		{
		    OVERRIDE_RMS = 4
		    SEND_COMMAND dvTP, "'TEXT',ITOA( UIBtns[82] ),'-Reset',$0D,'Override'"
		}
	    }
	    
	    //Setup room without scheduling
	    CASE 83:
	    CASE 84:
	    CASE 85:
	    {
		OVERRIDE_RMS = svBtn - 82
		SEND_COMMAND dvTP, "'TEXT',ITOA( UIBtns[82] ),'-Reset',$0D,'Override'"
	    }
	    
	    //Start Offline Meeting
	    CASE 86:
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=sitestart0',
					    '&title=Start Lesson',
					    '&message=You are about to start a new lesson.',$0A,$0D,$0A,$0D,
					    'Do you wish to continue?',
					    '&res1=Ok&res2=Cancel&norepeat=1'" )
	    }
	    
	    //Filter Sites to Sites
	    CASE 87:
	    {
		SITE_LIST_FILTER = SITE
		
		Systems_UpdateUIList(1)
		
		SEND_COMMAND dvTP, "'@PPK-Filter'"
	    }
	    
	    //Filter Sites to Virtual
	    CASE 88:
	    {
		SITE_LIST_FILTER = VIRTUAL
		
		Systems_UpdateUIList(1)
		
		SEND_COMMAND dvTP, "'@PPK-Filter'"
	    }
	    
	    //Filter Sites to Virtual
	    CASE 89:
	    {
		SITE_LIST_FILTER = MOBILE_UNITS
		
		Systems_UpdateUIList(1)
		
		SEND_COMMAND dvTP, "'@PPK-Filter'"
	    }
	    
	    //Refresh Site List
	    CASE 90:
	    {
		//Refresh Data Across systems
		SYSTEM_sendCommand ( vdvSystem, "'4GetSystemData-'" )
	    }
	    
	    //Set Presentation Tranmission type
	    CASE 91: //Bridgeit
	    {
		//Switch Off Codec Presentation
		OFF[vdvCodec, 309]
		
		//Switch Projector Presentation
		SYSTEM_setProjectorInput( vdvProjector1, 'VGA,1' )
	    }	
	    CASE 92: //Codec
	    {
		//Switch On Codec Presentation Type
		ON[vdvCodec, 309]
		
		//Switch Projector Presentation
		SYSTEM_setProjectorInput( vdvProjector1, 'HDMI,1' )
	    }
	    //Change Pin
	    CASE 93:
	    {
		SEND_COMMAND dvTP, "'@PPN-[Menu]ChangePIN;Admin'"
	    }
	    
	    //Amp Volume Up
	    CASE 100:
	    {
		OFF[vdvAmplifier, VOL_UP]
	    }
	    
	    //Amp Volume Down
	    CASE 101:
	    {
		OFF[vdvAmplifier, VOL_DN]
	    }
	    
	    //Filter Sites to All
	    CASE 121:
	    {
		SITE_LIST_FILTER = 0
		
		Systems_UpdateUIList(1)
		
		SEND_COMMAND dvTP, "'@PPK-Filter'"
	    }
	    
	    //Show Filter Menu
	    CASE 122:
	    {
		SEND_COMMAND dvTP, "'@PPN-Filter;Admin'"
	    }
	}
    }
    
    HOLD[10]:
    {
	STACK_VAR INTEGER svBtn
	
	svBtn = GET_LAST( UIBtns )
	
	SWITCH ( svBtn )
	{
	    CASE 11:
	    CASE 12:
	    CASE 13:
	    CASE 14:
	    {
		// Show Site Add/Remove Context
		SEND_COMMAND dvTP, "'@PPN-_SiteContext;Admin'"
		
		WAIT 150 {
		    
		    // Hide Site Add/Remove Context
		    SEND_COMMAND dvTP, "'@PPK-_SiteContext'"
		}
	    }
	}
    }
}

DATA_EVENT [dvTP]
{
    ONLINE:
    {
	if ( DATA.DEVICE.PORT == 1 )
	{
	    SYSTEM_clearSplashScreenText()
	    
	    SYSTEM_addSplashScreenText('Starting System...')
	    
	    PERMISSION_LEVEL = 0
	    
	    SYSTEM_ShowUIStart()
	}
    }
} 


DEFINE_PROGRAM 


