MODULE_NAME='NECPROJECTOR' (dev vdvModule,dev dvDevice)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/04/2006  AT: 11:33:16        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)    
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)


#INCLUDE 'SNAPI.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

TL_POLL  		= 1
RS232_TIMELINE 		= 2
MAX_STRING_LENGTH 	= 500

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

integer i
CKS
integer nCheckSum
char cStringtoSend[100]

long tlPollingIntervals[] = { 2000, 2000, 2000, 2000 }		

integer nData
integer nInitial

integer nLampLeft
integer nLampMeter
integer nLampWarn
integer nLampProhibit

integer LAMP_METER

char cProjectorBuffer[255]
char cLampMeter[4]
char cLampWarn[255]
char cLampProhibit


VOLATILE char IP_ADDRESS[255]
VOLATILE INTEGER IP_PORT = 7142
VOLATILE INTEGER IP_CONNECTED 

INTEGER Proj_Warm
INTEGER Proj_Cool
INTEGER Proj_On
INTEGER Proj_Off
INTEGER Proj_Init

VOLATILE INTEGER LISTEN_FOR
VOLATILE CHAR INPUT[16]

//1: Power
//2: Input


//RS-232 Queue
VOLATILE CHAR RS232_QUEUE[16000] //THE LIMIT FOR STRING CONCATENATION
VOLATILE CHAR DELIMITER[4] = '$XX'
VOLATILE LONG INTERVAL[] = { 150 }


VOLATILE CHAR svCommand[32]
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION ADD_TO_QUEUE (CHAR QUEUE_DATA[MAX_STRING_LENGTH])
{
    RS232_QUEUE = "RS232_QUEUE,QUEUE_DATA,DELIMITER"
    IF(!(TIMELINE_ACTIVE(RS232_TIMELINE)))
    {
	TIMELINE_CREATE(RS232_TIMELINE,INTERVAL,1,TIMELINE_ABSOLUTE,TIMELINE_REPEAT)
    }
    //SEND_STRING 0,"'ADDING TO QUEUE'"
}

DEFINE_FUNCTION SEND_A_STRING()
{
    LOCAL_VAR CHAR TEMP_STRING[MAX_STRING_LENGTH]
    IF((LENGTH_STRING(RS232_QUEUE)) && (FIND_STRING(RS232_QUEUE,"DELIMITER",1)))
    {
	TEMP_STRING = REMOVE_STRING(RS232_QUEUE,"DELIMITER",1)
	SET_LENGTH_STRING(TEMP_STRING,LENGTH_STRING(TEMP_STRING)-3)
	SEND_STRING dvDevice,"TEMP_STRING"
	
	SEND_STRING 0,"'Out: ',TEMP_STRING"
    }
    ELSE IF(LENGTH_STRING(RS232_QUEUE) = 0)
    {
	if ( TIMELINE_ACTIVE(RS232_TIMELINE) )
	{
	    TIMELINE_KILL(RS232_TIMELINE)
	}
    }
    ELSE IF((LENGTH_STRING(RS232_QUEUE)) && (!(FIND_STRING(RS232_QUEUE,"DELIMITER",1))))
    {
	CLEAR_BUFFER RS232_QUEUE
    }
}


define_function integer fnChecksum(char cString[32])
{
    integer nLength,i,nChecksum
    nLength = length_string(cString)
    for(i=1;i<=nLength;i++)
    {
	nChecksum = nChecksum BXOR cString[i]
    }
    return nChecksum
}

DEFINE_FUNCTION NECLampProcessor(char cMeter[4], char cWarn[4])//takes a character array of hex and converts it to Decimal
{
    LOCAL_VAR integer i
    Local_Var integer DataMeter[4]
    LOCAL_VAR integer DataWarn[4]
    LOCAL_VAR integer Group1Hi
    LOCAL_VAR integer Group1Lo
    LOCAL_VAR integer Group2Hi
    LOCAL_VAR integer Group2Lo
    LOCAL_VAR integer Group1
    LOCAL_VAR integer Group2
    LOCAL_VAR integer Group1Mod
    LOCAL_VAR integer Group2Mod
    LOCAL_VAR integer nNumber
    
    For (i=1; i<=length_array(cMeter); i++)
    {
	DataMeter[i] = cMeter[i]
    }
    For (i=1; i<=length_array(cWarn); i++)
    {
	DataWarn[i] = cWarn[i]
    }
    Group1Hi = (DataMeter[4] * 256) + DataMeter[3]
    Group1Lo = (DataMeter[2] * 256) + DataMeter[1]
    Group2Hi = (DataWarn[4] * 256) + DataWarn[3]
    Group2Lo = (DataWarn[2] * 256) + DataWarn[1]
    
    Group1 = (((Group1Hi MOD 3600) * 182)/10) + (Group1Lo / 3600)
    Group2 = (((Group2Hi MOD 3600) * 182)/10) + (Group2Lo / 3600)
    
    Group1Mod = Group1Lo - ((Group1Lo / 3600) * 3600)
    Group2Mod = Group2Lo - ((Group2Lo / 3600) * 3600)
    
    IF((Group1Mod + Group2Mod) > 3600) 
    {
	nLampLeft = Group2 - Group1
	nLampWarn = Group2
	nLampMeter = Group1
    }
    Else
    {
	nNumber = Group2 - Group1 + 1
	nLampWarn = Group2
	nLampMeter = Group1 + 1
    }

}

define_function openIPConnection()
{
    //Show Waiting Popup
    ip_client_open(dvDevice.port,IP_ADDRESS,IP_PORT,1) 
} 

define_function closeIPConnection()
{
    ip_client_close(dvDevice.port)
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvDevice, cProjectorBuffer
off[nInitial]

//create the polling timeline
timeline_create(TL_POLL,tlPollingIntervals,length_array(tlPollingIntervals),TIMELINE_RELATIVE,TIMELINE_REPEAT);

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


TIMELINE_EVENT[RS232_TIMELINE]
{
    SEND_A_STRING()
}

DATA_EVENT[dvDevice]
{
    ONLINE:
    {
	//If IP Comms
	IF (data.device.number == 0)
	{
	    if ( LENGTH_STRING ( IP_ADDRESS ) )
		openIPConnection()
	}
	
	//If RS-232 Comms
	ELSE
	{
	    Wait 10 SEND_COMMAND dvDevice, "'SET BAUD 38400,N,8,1 485 DISABLE'"
	}
	
	send_string 0:0:0, "'fnTCP_ClientConnect(): NOW CONNECTED TO DEVICE...' ";
	ON[vdvModule,DEVICE_COMMUNICATING]
	ON[vdvModule,DATA_INITIALIZED]
	
	IP_CONNECTED = 1
    }
    
    ONERROR:
    {
	STACK_VAR CHAR Error[64]
	
	SWITCH ( DATA.NUMBER )
	{
	    CASE 2: Error =  "'2: General failure (out of memory)'"
	    CASE 4: Error =  "'4: Unknown host'"
	    CASE 6: Error =  "'6: Connection refused'"
	    CASE 7: Error =  "'7: Connection timed out'"
	    CASE 8: Error =  "'8: Unknown connection error'"
	    CASE 9: Error =  "'9: Already closed'"
	    CASE 14: Error =  "'14: Local port already used'"
	    CASE 16: Error =  "'16: Too many open sockets'"
	    CASE 17: Error =  "'17: Local Port Not Open'"
	}
	SEND_STRING 0, "'Projector - Connection Error: ',Error"
    }
    
    offline:
    {
	ip_client_close(dvDevice.port)
	send_string 0:0:0, "'fnTCP_ClientConnect(): NOW DISCONNECTED FROM DEVICE...'"
	
	//Reset Flags
	OFF[vdvModule,DEVICE_COMMUNICATING]
	OFF[vdvModule,DATA_INITIALIZED]
	
	//Reset Flags
	OFF[vdvModule, LAMP_WARMING_FB]
	OFF[vdvModule, LAMP_COOLING_FB]
	OFF[vdvModule, POWER_FB]
	
	IP_CONNECTED = 0
    }
    
    STRING:
    {
	SEND_STRING 0,"'IN: ',DATA.TEXT"
	
	SELECT
	{
	    //Get Picture Mute State
	    ACTIVE(LEFT_STRING(cProjectorBuffer, 3) == "$22,$11,$01"):
	    {
		OFF[vdvModule, PIC_MUTE_FB]
	    }
	    
	    //Get Picture Mute State
	    ACTIVE(LEFT_STRING(cProjectorBuffer, 3) == "$22,$10,$01"):
	    {
		ON[vdvModule, PIC_MUTE_FB]
	    }
	    
	    //Status 
	    ACTIVE(FIND_STRING(cProjectorBuffer, "$20,$85", 1) AND ( LISTEN_FOR == 1 ) ):
	    {
		//If Projector is switched on
		IF (MID_STRING(cProjectorBuffer,11,1)== $04)
		{
		    OFF[vdvModule, LAMP_WARMING_FB]
		    OFF[vdvModule, LAMP_COOLING_FB]
		    ON[vdvModule, POWER_FB]
		}
		//If Projector is switched off
		IF (MID_STRING(cProjectorBuffer,11,1)== $00)
		{
		    OFF[vdvModule, LAMP_WARMING_FB]
		    OFF[vdvModule, LAMP_COOLING_FB]
		    OFF[vdvModule, POWER_FB]
		}
		
		//If Projector is Warming
		if  (MID_STRING(cProjectorBuffer,11,1)== $02)
		{
		    ON[vdvModule, LAMP_WARMING_FB]
		    OFF[vdvModule, LAMP_COOLING_FB]
		    ON[vdvModule, POWER_FB]
		}
		
		//if Projector is cooling
		if (MID_STRING(cProjectorBuffer,11,1)== $05)
		{
		    OFF[vdvModule, LAMP_WARMING_FB]
		    ON[vdvModule, LAMP_COOLING_FB]
		    ON[vdvModule, POWER_FB]
		}
	    }
	    
	    (*
		 +--------------------+--------+--------+
                 |  Terminal name     | DATA03 | DATA04 |
                 +--------------------+--------+--------+
                 | Computer1          |    01H |    01H |
                 | Computer2          |    02H |    01H |
                 | Computer3(DVI)/HDMI|    01H |    06H |
                 | Component          |    03H |    04H |
                 | Video              |    01H |    02H |
                 | S-Video            |    01H |    03H |
                 | Viewer             |    01H |    07H |
                 +--------------------+--------+--------+
	    *)
	    
	    //Input 
	    ACTIVE(FIND_STRING(cProjectorBuffer, "$20,$85", 1) AND ( LISTEN_FOR == 2 ) ):
	    {
		STACK_VAR CHAR sINPUT[16]
	    
		//Computer 1
		IF (MID_STRING(cProjectorBuffer,8,2)== "$01,$01")
		{
		    sINPUT = 'VGA,1'
		}
		
		//Computer 2
		IF (MID_STRING(cProjectorBuffer,8,2)== "$02,$01")
		{
		    sINPUT = 'VGA,2'
		}
		
		//Computer 3 (DVI)/HDMI
		IF (MID_STRING(cProjectorBuffer,8,2)== "$01,$06")
		{
		    sINPUT = 'HDMI,1'
		}
		
		//Component
		IF (MID_STRING(cProjectorBuffer,8,2)== "$03,$04")
		{
		    sINPUT = 'COMPONENT,1'
		}
		
		//Video
		IF (MID_STRING(cProjectorBuffer,8,2)== "$01,$02")
		{
		    sINPUT = 'COMPOSITE,1'
		}
		
		//S-Video
		IF (MID_STRING(cProjectorBuffer,8,2)== "$01,$03")
		{
		    sINPUT = 'SVid,1'
		}
		
		
		if ( sINPUT != INPUT AND LENGTH_STRING( sINPUT ) )
		{
		    INPUT = sINPUT
		    SEND_COMMAND vdvModule, "'INPUT-',INPUT"
		}
	    }
	    
	    //Get Lamp hours
	    ACTIVE(FIND_STRING(cProjectorBuffer, "$23,$8C,$01", 1) AND ( LISTEN_FOR == 3 )):
	    {
		cLampMeter = mid_string(cProjectorBuffer, 6, 4)
		cLampWarn  = mid_string(cProjectorBuffer, 14, 4)
		
		NECLampProcessor(cLampMeter, cLampWarn)
		
		//if Lamp_meter value has changed then update program
		if ( nLampMeter != LAMP_METER )
		{
		    LAMP_METER = nLampMeter
		    SEND_STRING vdvModule, "'LAMPTIME-',itoa(LAMP_METER)"
		}
	    }
	    
	    //Listen to All states
	    ACTIVE(FIND_STRING(cProjectorBuffer, "$20,$BF,$01", 1) AND ( LISTEN_FOR == 4 ) ):
	    {
		//If Projector is switched on
		IF (MID_STRING(cProjectorBuffer,12,1)== $01)
		{
		    ON[vdvModule, PIC_MUTE_FB]
		}
		
		
		//If Projector is switched on
		IF (MID_STRING(cProjectorBuffer,12,1)== $00)
		{
		    OFF[vdvModule, PIC_MUTE_FB]
		}
	    }
	}
    }
}

//20H  85H  01H  xxH  10H  DATA01 ..  DATA16  CKS Running Status

data_event [vdvModule]
{
    command:
    {	
	if( find_string(  DATA.TEXT, 'Input-', 1 ) )
	{
	    remove_string( DATA.TEXT, '-', 1 )
	    if (find_string(DATA.TEXT,'VGA,1',1)) 
	    { 
		ADD_TO_QUEUE ("$02,$03,$00,$00,$02,$01,$01,$09")
	    }
	    else if (find_string(DATA.TEXT,'COMPOSITE,1',1)) 
	    { 
		ADD_TO_QUEUE ("$02,$03,$00,$00,$02,$01,$06,$0E") 
	    }
	    else if (find_string(DATA.TEXT,'HDMI,1',1)) 
	    { 
		ADD_TO_QUEUE ("$02,$03,$00,$00,$02,$01,$1A,$22")
	    }
	    else if (find_string(DATA.TEXT,'VGA,2',1)) 
	    {  
		ADD_TO_QUEUE ("$02,$03,$00,$00,$02,$01,$02,$0A")
	    }
	    else if (find_string(DATA.TEXT,'SVID,1',1)) 
	    {  
		ADD_TO_QUEUE ("$02,$03,$00,$00,$02,$01,$0B,$13")
	    }
	    
	}
	
	//LampTime
	IF ( FIND_STRING(data.text, '?LAMPTIME', 1) )
	{
	    SEND_COMMAND vdvModule, "'LAMPTIME-',ITOA ( nLampMeter ) "
	}
	
	//LampWarn
	IF ( FIND_STRING(data.text, '?LAMPWARN', 1) )
	{
	    SEND_COMMAND vdvModule, "'LAMPWARN-',ITOA ( nLampWarn ) "
	}
	
	//Properties
	If ( find_string(data.text, 'PROPERTY-', 1 ) )
	{
	    IF ( FIND_STRING (data.text, 'IP_Address', 1 ) )
	    {
		//Remove INPUT-IP_Address,
		REMOVE_STRING ( data.text, 'IP_Address,', 1 )
		IP_ADDRESS = data.text
		
		//reset IP 
		closeIPConnection()
	    }
	}
	
	//Properties
	If ( find_string(data.text, '?property-', 1 ) )
	{
	    IF ( FIND_STRING (data.text, 'IP_Address', 1 ) )
	    {
		SEND_COMMAND vdvModule, "'PROPERTY-IP_Address,',IP_ADDRESS"
	    }
	}
	
	//Get Input
	If ( find_string(data.text, '?INPUT', 1 ) )
	{
	    SEND_COMMAND vdvModule, "'INPUT-',INPUT"
	}
    }
}

CHANNEL_EVENT [vdvModule, 0]
{
    ON:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    CASE PWR_ON:
	    {
		ADD_TO_QUEUE ("$02,$00,$00,$00,$00,$02")
		ON[vdvModule, POWER_FB]
	    }
	    CASE PWR_OFF:
	    {
		ADD_TO_QUEUE ("$02,$01,$00,$00,$00,$03")
	    }
	    CASE POWER:
	    {
		IF ( ![vdvModule, POWER_FB] )
		{ 
		    PULSE[ vdvModule, PWR_ON  ]
		}
		ELSE
		{
		    PULSE[ vdvModule, PWR_OFF ]
		}
	    }
	    CASE PIC_MUTE:
	    {
		if ( ![ vdvModule, PIC_MUTE_FB ] )
		{
		    ADD_TO_QUEUE ("$02,$10,$00,$00,$00,$12")
		    SEND_STRING 0, "'PIC_MUTE_ON'"
		    ON[ vdvModule, PIC_MUTE_FB]
		}
		ELSE
		{
		    ADD_TO_QUEUE ("$02,$11,$00,$00,$00,$13")
		    SEND_STRING 0, "'PIC_MUTE_OFF'"
		    OFF[ vdvModule, PIC_MUTE_ON]
		}
	    }
	}	
    }
}

timeline_event[TL_POLL]
{   
    if ( [ vdvModule, DATA_INITIALIZED ] )
    {
	LISTEN_FOR = timeline.sequence
	
	CLEAR_BUFFER cProjectorBuffer
	
	switch(timeline.sequence)
	{	   
	    case 1: 
	    {
		ADD_TO_QUEUE ( "$00,$85,$00,$00,$01,$01,$87" ) //Read Running Status
	    }
	    
	    CASE 2:
	    {
		ADD_TO_QUEUE ( "$00,$85,$00,$00,$01,$02,$88" ) //Read Input
	    }
	    case 3: //Read Lamp
	    {
		STACK_VAR CHAR svCommand[32]
		
		svCommand = "$03,$8C,$00,$00,$00,$8F"
		
		ADD_TO_QUEUE (  svCommand  )
	    }
	    //Get all information
	    CASE 4:
	    {
		ADD_TO_QUEUE ( "$00,$BF,$00,$00,$01,$02,$C2" )
	    }
	}
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

WAIT 100
{
    //Maitain lighting connection
    IF ( ![ vdvModule, DATA_INITIALIZED ] AND LENGTH_STRING ( IP_ADDRESS ) )
    {
	openIPConnection()
    }
}

Proj_Cool = [vdvModule, LAMP_COOLING_FB ]
Proj_Warm = [vdvModule, LAMP_WARMING_FB ]
Proj_On = [vdvModule, POWER_FB ]
Proj_Off = ![vdvModule, POWER_FB ]
Proj_Init = [vdvModule, DATA_INITIALIZED ]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
