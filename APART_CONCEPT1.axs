MODULE_NAME='APART_CONCEPT1' (dev vdvModule,dev dvDevice)
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
DEFINE_DEVICE

#INCLUDE 'SNAPI.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//Key Words

//LCD Commands

SwitchOn	= 1	
SwitchOff	= 0
VGA		= 2
HDMI		= 3
RGBHV		= 4
Component	= 5
Video		= 6
SVid		= 7
DVI		= 8
DVDHD		= 9
Scart           = 10
Audio1		= 11
Audio2		= 12
Audio3		= 13
Audio4		= 14

TL_POLL  		= 1

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE CHAR INPUT[1]

long tlPollingIntervals[] = { 2000, 10000 }		// length of time between retrying to connect

VOLATILE CHAR cCurrentVol[4]

VOLATILE INTEGER MAX_VOL

VOLATILE INTEGER VOLUME_LEVEL

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




define_Function fnDevice(INTEGER func)
//Func are declared as integer constants up above
{
    SWITCH(func)
    {
	CASE SwitchOff: //Power Off
	{
	    SEND_STRING dvDevice, "'SET STANDBY ON',$0D"
	    SEND_STRING vdvModule, "'Power-3'"
	    WAIT 70
	    {
		SEND_STRING vdvModule, "'Power-0'"
		//OFF[vdvModule, PWR_ON]
	    }
	}
	CASE SwitchOn: //Power On
	{
	    SEND_STRING dvDevice, "'SET STANDBY OFF',$0D"
	    SEND_STRING vdvModule, "'Power-2'"
	    WAIT 70
	    {
		SEND_STRING vdvModule, "'Power-1'"
		//ON[vdvModule, PWR_ON]
	    }
	}
    }
}

DEFINE_FUNCTION fnVolume(FLOAT volume)
{
    STACK_VAR SINTEGER Vol
    local_var char nSendVolString[100]
    local_var char cVolString[4]
    local_var FLOAT nSendVol
    nSendVol = (volume/100)*MAX_VOL
    nSendVol = nSendVol - 80
    cVolString = FORMAT('%3.0f',nSendVol)
    SEND_STRING dvDevice,"'SET MSCLVL ',cVolString,$0D"
    cCurrentVol = cVolString
    SEND_STRING vdvModule, "'AudioMute-0'"
}

DEFINE_FUNCTION fnMaxVol(FLOAT volume)
{
    local_var char cVolString[4]
    local_var FLOAT nSendVol
    nSendVol = 0 - MAX_VOL
    cVolString = FORMAT('%3.0f',nSendVol)
    SEND_STRING dvDevice,"'SET MAXMSCLVL ',cVolString,$0D"
}

DEFINE_FUNCTION fnAudioMute(integer func)
{
    IF (func == SwitchOff)//unMute
    {
	SEND_STRING dvDevice,"'SET MSCLVL ',cCurrentVol,$0D"
	SEND_STRING vdvModule, "'AudioMute-0'"
    }
    ELSE //Mute
    {
	SEND_STRING dvDevice,"'SET MSCLVL OFF',$0D"
	SEND_STRING vdvModule, "'AudioMute-1'"
    }
}



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

MAX_VOL = 80

//create the polling timeline
timeline_create(TL_POLL,tlPollingIntervals,length_array(tlPollingIntervals),TIMELINE_ABSOLUTE,TIMELINE_REPEAT);
//timeline_pause(TL_POLL);



(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT



data_event [vdvModule]
{
    ONLINE:
    {
	SEND_STRING dvDevice, "'GET MSCLVL',$0D"
    }
    
    command:
    {
	local_var char cData[32],cParse[32],cStringToSend[64],cVolume[4]
	local_var integer nData1,nData2,nChecksum, iVolume
	cData = data.text
	
	//Parse Incoming Commands
	select
	{	
	    active( FIND_STRING (cData, 'MAX_VOL-', 1 )):
	    {
		remove_string( cData, '-', 1 )
		MAX_VOL = ATOI(cData)
		fnMaxVol(ATOF(cData))
	    }
	    
	    
	    //Power Commands
	    active( find_string(  cData, 'Power-', 1 ) ):
	    {
		remove_string( cData, '-', 1 )
		fnDevice(ATOI(cData))
	    }
	    
	    //Input Commands
	    active( find_string(  cData, 'Input-', 1 ) ):
	    {
		remove_string( cData, '-', 1 )
		
		SEND_STRING dvDevice, "'SET SELECT ',cData,$0D"
	    }
	    
	    active( find_string(  cData, 'AudioMute-', 1 ) ):
	    {
		remove_string( cData, '-', 1 )
		if (find_string(cData,'1',1)) { fnAudioMute(SwitchOn) }
		else if (find_string(cData,'0',1)) { fnAudioMute(SwitchOff) }
	    }
	    active( find_string(  cData, 'Volume-', 1 ) ):
	    {
		remove_string(cData, '-', 1 )
		fnVolume(atof(cData))
	    }
	    
	    active( find_string(  cData, 'GETVOLUME', 1 ) ):
	    {
		SEND_STRING dvDevice, "'GET MSCLVL',$0D"
	    }
	}
    }
}

DATA_EVENT[dvDevice]
{
    Online:
    {
	SEND_COMMAND dvDevice, "'SET BAUD 19200,N,8,1 485 DISABLE'"
    }
    STRING:
    {
	ON[ vdvModule, DATA_INITIALIZED ]
	
	if ( !FIND_STRING ( DATA.TEXT, 'ERROR:', 1 ) )
	{
	    if ( FIND_STRING ( DATA.TEXT, 'SELECT', 1 ) )
	    {
		//Remove 'SELECT '
		REMOVE_STRING ( DATA.TEXT, 'SELECT ', 1 ) 
		
		SET_LENGTH_STRING ( DATA.TEXT, 1 )
		
		INPUT = DATA.TEXT
		
		SEND_COMMAND vdvModule, "'INPUT-',INPUT"
	    }
	    if ( FIND_STRING ( DATA.TEXT, 'MSCLVL', 1 ) )
	    {
		STACK_VAR FLOAT fVol
		
		if ( FIND_STRING ( DATA.TEXT, 'OFF', 1) )
		{
		    //Reformat number to integer
		    VOLUME_LEVEL = 0
		}
		ELSE
		{
		    
		    //When retrieve a string
		    if ( FIND_STRING ( DATA.TEXT, 'AMSCLVL', 1 ) )
		    {
			//Remove SET MSCLVL$0D
			REMOVE_STRING ( DATA.TEXT, $0D, 1 )
			
			//Remove 0A$AMSCLVL <VOLUME>$0D
			REMOVE_STRING ( DATA.TEXT, $0D, 1 )
		    }
		    ELSE
		    {
			//Remove SET MSCLVL <VOLUME>$0D
			REMOVE_STRING ( DATA.TEXT, $0D, 1 )
		    }
		    
		    //Remove $0D
		    SET_LENGTH_STRING ( DATA.TEXT, ( LENGTH_STRING ( DATA.TEXT ) - 1 ) )
		    
		    //Set Volume Level
		    fVol = ATOF ( DATA.TEXT )
		    
		    //Get to Positive
		    fVol = fVol + 79
			
		    //Scale to AMX Standard
		    fVol = (fVol/79) * 255
		    
		    //Reformat number to integer
		    VOLUME_LEVEL = ATOI ( FORMAT('%3.0f',fVol) )
		
		}
		
		//Send Level to Ether
		SEND_LEVEL vdvModule, VOL_LVL, VOLUME_LEVEL
	    }
	    
	    //Get Power Status
	    if ( FIND_STRING ( DATA.TEXT, 'STANDBY', 1 ) )
	    {
		If ( FIND_STRING ( DATA.TEXT, 'ON', 1 ) )
		{
		    OFF[vdvModule, POWER_FB]
		}
		ELSE If ( FIND_STRING ( DATA.TEXT, 'OFF', 1 ) )
		{
		    ON[vdvModule, POWER_FB]
		}
	    }
	}
    }
}

//Get Channel Events
CHANNEL_EVENT [vdvModule,0] 
{
    ON:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    CASE PWR_OFF:
	    {
		SEND_STRING dvDevice, "'SET STANDBY ON',$0D"
	    }
	    CASE PWR_ON:
	    {
		SEND_STRING dvDevice, "'SET STANDBY OFF',$0D"
	    }
	}
    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

//Ping Device Every 10 Seconds
WAIT 200
{
    SEND_STRING dvDevice, "'Hello'"
}

WAIT 1
{
    if ( [vdvModule, VOL_DN ] )
    {
	SEND_STRING dvDevice, "'DEC MSCLVL',$0D"
    }
    else if ( [vdvModule, VOL_UP ] )
    {
	SEND_STRING dvDevice, "'INC MSCLVL',$0D"
    }
}
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
