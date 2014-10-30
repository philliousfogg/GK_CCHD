PROGRAM_NAME='MobileGateway'

DEFINE_DEVICE


#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'Utilities.axi'

DEFINE_CONSTANT

VOLATILE INTEGER TL = 1

DEFINE_VARIABLE

// Define Timline intervals
VOLATILE LONG TL_INTERVALS[] = {

    30000  // Every 30 Seconds
}

DEFINE_START

// Create system polling timeline
TIMELINE_CREATE ( TL, TL_INTERVALS, 1, TIMELINE_ABSOLUTE, TIMELINE_REPEAT )

DEFINE_EVENT

TIMELINE_EVENT [ TL ]
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

