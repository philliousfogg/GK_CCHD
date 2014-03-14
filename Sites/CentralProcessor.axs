PROGRAM_NAME='CentralProcessor'

DEFINE_DEVICE

vdvSystem1 	= 33050:1:1
vdvSystem2 	= 33050:1:2
vdvSystem3 	= 33050:1:3
vdvSystem4 	= 33050:1:4
vdvSystem5 	= 33050:1:5
vdvSystem6 	= 33050:1:6
vdvSystem7 	= 33050:1:7
vdvSystem8 	= 33050:1:8
vdvSystem9 	= 33050:1:9
vdvSystem10 	= 33050:1:10

vdvSystem11 	= 33050:1:11
vdvSystem12 	= 33050:1:12
vdvSystem13	= 33050:1:13
vdvSystem14 	= 33050:1:14
vdvSystem15 	= 33050:1:15
vdvSystem16 	= 33050:1:16
vdvSystem17	= 33050:1:17
vdvSystem18 	= 33050:1:18
vdvSystem19 	= 33050:1:19
vdvSystem20	= 33050:1:20

DEFINE_VARIABLE

volatile dev vdvSystems[] = {

    vdvSystem1, 	
    vdvSystem2, 	
    vdvSystem3, 	
    vdvSystem4, 	
    vdvSystem5, 	
    vdvSystem6, 	
    vdvSystem7, 	
    vdvSystem8, 
    vdvSystem9, 	
    vdvSystem10, 	
    
    vdvSystem11,	
    vdvSystem12,	
    vdvSystem13,
    vdvSystem14, 	
    vdvSystem15, 	
    vdvSystem16, 	
    vdvSystem17,	
    vdvSystem18, 	
    vdvSystem19, 	
    vdvSystem20
} 

#INCLUDE 'Utilities.axi'

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
    SEND_COMMAND vdvSystem20, "'SYSTEM_PIN-pin=',Pin"
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
	SEND_COMMAND vdvSystem20, "'SYSTEM_PIN-pin=',svPin"
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
	    SEND_COMMAND vdvSystem20, "'SYSTEM_PIN-pin=',svPin"
	}
    }
}



(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

