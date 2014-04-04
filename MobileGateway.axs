PROGRAM_NAME='MobileGateway'

DEFINE_DEVICE

// RMS Sockets_________________________________________________________________
dvRMSSocket1	= 0:11:0
dvRMSSocket2	= 0:12:0
dvRMSSocket3	= 0:13:0

// RMS Virtual Devices (This is what the mobile gateways talk to_______________

vdvRMSEngine1 	= 33101:1:0
vdvRMSEngine2 	= 33102:1:0
vdvRMSEngine3 	= 33103:1:0

vdvCLActions1 	= 33201:1:0
vdvCLActions2 	= 33202:1:0
vdvCLActions3 	= 33203:1:0

vdvLesson1 	= 33301:1:0
vdvLesson2 	= 33302:1:0
vdvLesson3 	= 33303:1:0

#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'Utilities.axi'

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


DEFINE_START

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL1(vdvCLActions1)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng1(vdvRMSEngine1, dvRMSSocket1, vdvCLActions1)

// RMSUIMod - The RMS User Interface.  Requires KeyboardMod.
// Channel And Variable Text Code Defined Inside The Module
DEFINE_MODULE 'RMSUIMod' mdlRMSUI(vdvRMSEngine1,
				  vdvLesson1,
                                  dvRMSTP,dvRMSTP_Base,
				  dvRMSTPWelcome,
				  dvRMSTPWelcome_Base,
				  RMS_MEETING_DEFAULT_SUBJECT,
				  RMS_MEETING_DEFAULT_MESSAGE)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL2(vdvCLActions2)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng2(vdvRMSEngine2, dvRMSSocket2, vdvCLActions2)

// RMSUIMod - The RMS User Interface.  Requires KeyboardMod.
// Channel And Variable Text Code Defined Inside The Module
DEFINE_MODULE 'RMSUIMod' mdlRMSUI(vdvRMSEngine2,
				  vdvLesson2,
                                  dvRMSTP,dvRMSTP_Base,
				  dvRMSTPWelcome,
				  dvRMSTPWelcome_Base,
				  RMS_MEETING_DEFAULT_SUBJECT,
				  RMS_MEETING_DEFAULT_MESSAGE)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL3(vdvCLActions3)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng3(vdvRMSEngine3, dvRMSSocket3, vdvCLActions3)

// RMSUIMod - The RMS User Interface.  Requires KeyboardMod.
// Channel And Variable Text Code Defined Inside The Module
DEFINE_MODULE 'RMSUIMod' mdlRMSUI(vdvRMSEngine3,
				  vdvLesson3,
                                  dvRMSTP,dvRMSTP_Base,
				  dvRMSTPWelcome,
				  dvRMSTPWelcome_Base,
				  RMS_MEETING_DEFAULT_SUBJECT,
				  RMS_MEETING_DEFAULT_MESSAGE)

DEFINE_PROGRAM

WAIT 300
{
    //Request System Data every 30 secs
    SEND_COMMAND vdvSystem, "'MGGetSystemData-'"
}


//Pin Manager__________________________________________________________________

//retrieves system panel 
DEFINE_FUNCTION CHAR[5] CP_getSystemPin()
{
    STACK_VAR CHAR svPin[5]
    
    ReadFile( 'systemPin.txt', svPin )
    
    RETURN svPin 
}

//retrieves system panel 
DEFINE_FUNCTION CP_setSystemPin( CHAR Pin[5] )
{
    SaveFile( 'systemPin.txt', Pin )
    
    //Send Pin to all systems
    SEND_COMMAND vdvSystem, "'SYSTEM_PIN-pin=',Pin"
}

DEFINE_EVENT

DATA_EVENT [vdvSystems]
{
    ONLINE:
    {
	STACK_VAR CHAR svPin[5]
	
	//Get Pin from file
	svPin = CP_getSystemPin()
	
	//Send pin to systems
	SEND_COMMAND vdvSystem, "'SYSTEM_PIN-pin=',svPin"
    }
    
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Set the data for the responding system
	if ( FIND_STRING ( DATA.TEXT, 'CHANGE_PIN-', 1 ))
	{
	    CP_setSystemPin( GetAttrValue('pin', aCommand ) )
	}
	
	//Return system pin
	if ( FIND_STRING ( DATA.TEXT, 'GET_PIN-', 1 ) )
	{
	    STACK_VAR CHAR svPin[5]
	    
	    //Get Pin from file
	    svPin = CP_getSystemPin()
	    
	    //Send pin to systems
	    SEND_COMMAND vdvSystem, "'SYSTEM_PIN-pin=',svPin"
	}
    }
}

