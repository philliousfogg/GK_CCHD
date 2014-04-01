MODULE_NAME='CiscoTCThinClient' ( dev dvCodec, dev vdvDevices[] )

#INCLUDE 'SNAPI.axi'


DEFINE_TYPE

STRUCTURE _Camera 
{
    INTEGER ID
    INTEGER Connected
    CHAR Manufacturer[255]
    CHAR Model[255]
    CHAR SerialNumber[65]
    CHAR pan[6]
    CHAR tilt[6]
    CHAR zoom[6]
    CHAR focus[6]
    INTEGER Ir
    INTEGER backlight
}

STRUCTURE _call 
{
    INTEGER ID     //Index
    INTEGER CallId //Call ID 
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
    CHAR Status[24] //Dialling Status
    INTEGER Changed 
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
    
    INTEGER IrSensor
    INTEGER AutoAnswerMute
    INTEGER AutoAnswer
}

DEFINE_CONSTANT

CHAR CONF_STATE_IDLE[] = 'DISCONNECTED'
CHAR CONF_STATE_NEG[]  = 'NEGOTIATING'
CHAR CONF_STATE_CONN[] = 'CONNECTED'
CHAR CONF_STATE_RING[] = 'RINGING'
CHAR CONF_STATE_DIAL[] = 'DIALING'
CHAR CONF_STATE_ONHOLD[] = 'ON_HOLD'

DEFINE_VARIABLE


VOLATILE _Camera CAMERAS[2]
VOLATILE _CALL CALLS[4]

VOLATILE _Codec Codec

VOLATILE CHAR IP_ADDRESS[16]
VOLATILE CHAR USERNAME[64]
VOLATILE CHAR PA55W0RD[64]
VOLATILE CHAR BAUD_RATE[16] = '38400'

VOLATILE INTEGER RECEIVING_DATA
VOLATILE CHAR BUFFER[7680]

VOLATILE INTEGER VOLUME_LEVEL

VOLATILE CHAR PIP_POSITIONS[7][64] = {

    'UpperLeft',
    'UpperRight',
    'LowerLeft',
    'LowerRight',
    'CenterLeft',
    'CenterRight'
}

VOLATILE INTEGER PIP_POSITION
VOLATILE INTEGER CAM_POSITION_CHANGED[2]
VOLATILE INTEGER SIP_CHANGED
VOLATILE INTEGER H323_CHANGED

VOLATILE CHAR pCallCommand[4][512]
VOLATILE CHAR pStatus[4][24]

// Sets module to offline mode
DEFINE_FUNCTION CISCO_offline()
{
    STACK_VAR INTEGER i
    STACK_VAR _CALL BlankCall
    STACK_VAR _Codec BlankCodec
    
    //Set Offline flag in module
    OFF[ vdvDevices[1], DEVICE_COMMUNICATING ]
    
    //Set Logged in flag to off
    OFF[ vdvDevices[1], DATA_INITIALIZED ]
    
    //Clear all call and Codec Infomation
    Codec = BlankCodec
    
    //Clear Call Data
    FOR ( i=1; i<=4; i++ )
    {
	CALLS[i] = BlankCall
    }
    
    //Switch off all channels in Virtual Device
    FOR ( i=1; i<=400; i++ )
    {
	OFF[ vdvDevices[1], i ]
    }    
}

//Pushes all the calls to up to the top
DEFINE_FUNCTION CISCO_reorderCalls()
{
    STACK_VAR INTEGER i
    
    STACK_VAR _CALL blankCall
    
    blankCall.Status = 'Idle'
    
    FOR ( i=1; i<=4; i++ )
    {
	//if Call slot is blank then pull call below up
	if ( !CALLS[i].CallId )
	{
	    if ( i + 1 <= 4 )
	    {
		CALLS[i] = CALLS[i+1]
		CALLS[i+1] = blankCall
		CALLS[i].Changed = 1
	    }
	}
    }

}

//Returns next free Call Slote
DEFINE_FUNCTION INTEGER CISCO_getCallIndex( INTEGER CallID )
{
    STACK_VAR INTEGER i 
    
    //Does the CallId already exist in a slot
    FOR ( i=1; i<=4; i++ )
    {
	IF ( CALLS[i].CallId == CallID )
	{
	    return i
	}
    }
    
    //Does not exist so find a new slot and return the slot index
    FOR ( i=1; i<=4; i++ )
    {
	IF ( !CALLS[i].CallId )
	{
	    return i 
	}
    }
    
    //return 0 is call slots are MAXXXX out.
    return 0
}

//Sends current Call Status to main program
DEFINE_FUNCTION  CISCO_setDiallerStatus( CHAR Status[], Integer CallIndex, integer request )
{
    STACK_VAR CHAR rStatus[24]
    
    if ( [vdvDevices[1], DATA_INITIALIZED] )
    {
	if ( Status == 'Idle' )
	{
	    rStatus = CONF_STATE_IDLE
	    
	    OFF[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( Status == 'Dialling' )
	{
	    rStatus = CONF_STATE_DIAL
	    
	    ON[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( Status == 'Connecting' )
	{
	    rStatus = CONF_STATE_NEG
	    
	    ON[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( Status == 'Connected' )
	{
	    rStatus = CONF_STATE_CONN
	    
	    ON[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( Status == 'Ringing' )
	{
	    rStatus = CONF_STATE_RING
	    
	    ON[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( Status == 'OnHold' )
	{
	    rStatus = CONF_STATE_ONHOLD
	    
	    ON[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	else if ( !LENGTH_STRING ( status ) )
	{
	    rStatus = CONF_STATE_IDLE
	    
	    OFF[vdvDevices[CallIndex], DIAL_OFF_HOOK_ON]
	}
	
	//If has been updated
	if ( LENGTH_STRING(rStatus) > 0 )
	{
	    // Has the status changed
	    if ( pStatus[CallIndex] != rStatus OR request )
	    {
		//Send Dialer Status to Main Program
		SEND_COMMAND vdvDevices[CallIndex], "'DIALERSTATUS-',rStatus"
		
		pStatus[CallIndex] = rStatus
	    }
	}
    }
}



//Strip last byte
DEFINE_FUNCTION char[255] removeLastbyte( char pString[255] )
{
    SET_LENGTH_STRING ( pString, ( LENGTH_STRING ( pString ) - 1 ) )
    RETURN pString
}

//Evaluates Incoming Data
DEFINE_FUNCTION CISCO_evaluateData(CHAR cData[1024])
{
    ON[ vdvDevices[1], DEVICE_COMMUNICATING ] 
    
    //Stand By
    IF ( FIND_STRING ( cData, 'Standby Active: Off', 1 ) )
    {
	//Codec Awake
	ON [ vdvDevices[1], POWER_FB ]
    }
    ELSE if ( FIND_STRING ( cData, 'Standby Active: On', 1 ) )
    {
	//Codec Sleep
	OFF[ vdvDevices[1], POWER_FB ]
    }
    
    ELSE IF ( FIND_STRING ( cData, 'xConfiguration SystemUnit', 1 ) )
    {
	if ( FIND_STRING ( cData, 'IrSensor', 1 ) )
	{
	    if ( FIND_STRING ( cData,'Auto', 1 ) OR FIND_STRING ( cData, 'On', 1 ) )
	    {
		CODEC.IrSensor = 1
		
		on[ vdvDevices[1], 320 ]
	    }
	    ELSE if ( FIND_STRING ( cData, 'Off', 1 ) )
	    {
		CODEC.IrSensor = 0
		
		off[ vdvDevices[1], 320 ]
	    }
	}
    }
    
    ELSE IF ( FIND_STRING( cData, 'H323', 1 ) )
    {
	//Get E164
	IF ( FIND_STRING( cData, 'H323Alias E164:', 1 ) )
	{
	    //Get E164 Number
	    Codec.E164 =  CISCO_removeWrap( cData, '"', '"' )
	}
	
	//Get H323 Id
	ELSE IF ( FIND_STRING( cData, 'H323Alias ID:', 1 ) )
	{
	    //Get H323 ID Number
	    Codec.H323ID =  CISCO_removeWrap( cData, '"', '"' )
	}
	
	//Get Gatekeeper Address
	ELSE IF ( FIND_STRING( cData, 'Gatekeeper Address:', 1 ) )
	{
	    //Get H323 ID Number
	    Codec.Gatekeeper =  CISCO_removeWrap( cData, '"', '"' )
	}
	
	//Get Gatekeeper Address
	ELSE IF ( FIND_STRING( cData, 'Gatekeeper Status:', 1 ) )
	{
	    //Get H323 ID Number
	    Codec.H323Status =  CISCO_removeWrap( cData, ': ', "$0D" )
	}
	
	//Send H323 Info to Program
	H323_CHANGED = 1
    }
    
    ELSE IF ( FIND_STRING( cData, 'SIP', 1 ) )
    {
	//Get SIP Proxy
	IF ( FIND_STRING( cData, 'Proxy 1 Address:', 1 ) )
	{
	    //Get SIP Proxy
	    Codec.SIPProxy =  CISCO_removeWrap( cData, '"', '"' )
	}
	
	//Get SIP Status
	ELSE IF ( FIND_STRING( cData, 'Registration 1 Status:', 1 ) )
	{
	    //Get H323 ID Number
	    Codec.SIPStatus =  CISCO_removeWrap( cData, ': ', "$0D" )
	}
	
	//Get SIP URI
	ELSE IF ( FIND_STRING( cData, 'Registration 1 URI:', 1 ) )
	{
	    //Get SIP URI
	    Codec.SIPURL =  CISCO_removeWrap( cData, '"', '"' )
	}
	
	SIP_CHANGED = 1
    }
    
    //Audio Microphones
    ELSE if ( FIND_STRING( cData, 'Audio Microphones Mute: Off', 1 ) )
    {
	OFF [vdvDevices[1], ACONF_PRIVACY_FB]
    }
    ELSE if ( FIND_STRING( cData, 'Audio Microphones Mute: On', 1 ) )
    {
	ON  [vdvDevices[1], ACONF_PRIVACY_FB]
    }
    ELSE if ( FIND_STRING( cData, 'Audio Volume:', 1 ) )
    {
	STACK_VAR FLOAT 	fVol
	STACK_VAR INTEGER 	iVol
	
	//Remove 'Audio Volume:'
	REMOVE_STRING ( cData, ': ', 1 )
	
	//Remove '<Vol>$0D'
	cData = REMOVE_STRING ( cData, "$0D", 1 )
	
	//Remove '$0D,$0A'
	SET_LENGTH_STRING ( cData, ( LENGTH_STRING ( cData ) - 1 ) )
	
	fVol = ATOF ( cData )
	
	VOLUME_LEVEL = ATOI ( cData )
	
	fVol = ( fVol / 100 ) * 255
	
	iVol = ATOI ( FORMAT ( '%-3.0f', fVol ) )
	
	SEND_LEVEL vdvDevices[1], VOL_LVL, iVol
    }
    ELSE if ( FIND_STRING( cData, 'Video Selfview Mode: On', 1 ) )
    {
	//Selfview flag on
	ON[vdvDevices[1], 305]
    }
    ELSE if ( FIND_STRING( cData, 'Video Selfview Mode: Off', 1 ) )
    {
	//Selfview flag on
	OFF[vdvDevices[1], 305]
    }
    ELSE if ( FIND_STRING( cData, 'Video Selfview PIPPosition:', 1 ) )
    {
	STACK_VAR INTEGER i 
	
	FOR ( i=2; i<=7; i++ )
	{
	    if ( FIND_STRING ( cData, PIP_POSITIONS[i-1], 1 ) )
	    {
		PIP_POSITION = i
	    }
	}
    }
    
    ELSE if ( FIND_STRING ( cData, 's Conference', 1 ) )
    {
	LOCAL_VAR CHAR mode[16]
	
	//Presenting Off
	If ( FIND_STRING ( cData, 'Presentation Mode: Off', 1 ) )
	{
	    STACK_VAR INTEGER i 
	    
	    FOR ( i=1; i<=4; i++ )
	    {
		CALLS[i].PRESENTING = 'Off'
		
		OFF[ vdvDevices[i], 318 ]
	    }
	    
	    mode = 'Sending'
	    
	    OFF[ vdvDevices[1], 309 ]
	}
	
	//Presenting Receiving
	IF ( FIND_STRING ( cData, 'Presentation Mode: Receiving', 1 ) )
	{
	    mode = 'Receiving'
	}
	
	//Sending Site
	IF ( FIND_STRING ( cData, 'Presentation SiteId:', 1 ) )
	{
	    STACK_VAR INTEGER CallId
	    STACK_VAR INTEGER CallIndex
	    
	    CallId = ATOI ( CISCO_removeWrap(cData, 'SiteId: ', "$0D") )
	    
	    //If CallID is not 0 then find
	    if ( CallId > 1)
	    {
		//Find Call Slot
		CallIndex = CISCO_getCallIndex( CallId )
		
		//Set Sending Presentation Site
		CALLS[CallIndex].presenting = mode
		
		//Set Presenting Flag
		ON[ vdvDevices[CallIndex], 318 ]
	    }
	}
	
	//Presenting Sending
	IF ( FIND_STRING ( cData, 'Presentation Mode: Sending', 1 ) )
	{
	    ON [ vdvDevices[1], 309 ]
	    
	    mode = 'Sending'
	}
    }
    
    ELSE if ( FIND_STRING ( cData, 'xConfiguration Cameras Camera ', 1 ) )
    {
	STACK_VAR CameraIndex
	STACK_VAR _Camera Blank
	
	//Remove 'Camera '
	REMOVE_STRING ( cData, 'Camera ', 1 )
	
	//Get Camera Index
	CameraIndex = ATOI ( REMOVE_STRING ( cData, ' ', 1 ) )
	
	//Only look at 2 cameras
	IF ( CameraIndex <= 2 )
	{   
	    IF ( FIND_STRING ( cData, 'IrSensor', 1 ) )
	    {
		//Ir Sensor On or Off
		if ( FIND_STRING ( cData, 'Off', 1 ) )
		{
		    CAMERAS[CameraIndex].Ir = 0
		    
		    OFF[vdvDevices[CameraIndex], 321]
		}
		ELSE IF ( FIND_STRING ( cData, 'On', 1 ) )
		{
		    CAMERAS[CameraIndex].Ir = 1
		    
		    ON[vdvDevices[CameraIndex], 321]
		}
	    }
	    ELSE IF ( FIND_STRING ( cData, 'Backlight', 1 ) )
	    {
		//Ir Sensor On or Off
		if ( FIND_STRING ( cData, 'Off', 1 ) )
		{
		    CAMERAS[CameraIndex].BackLight = 0
		    
		    OFF[vdvDevices[CameraIndex], 322]
		}
		ELSE IF ( FIND_STRING ( cData, 'On', 1 ) )
		{
		    CAMERAS[CameraIndex].BackLight = 1
		    
		    ON[vdvDevices[CameraIndex], 322]
		}
	    }
	}
    }


    ELSE if ( FIND_STRING ( cData, 's Camera', 1 ) )
    {
	STACK_VAR CameraIndex
	STACK_VAR _Camera Blank
	
	//Remove 'Camera '
	REMOVE_STRING ( cData, 'Camera ', 1 )
	
	//Get Camera Index
	CameraIndex = ATOI ( REMOVE_STRING ( cData, ' ', 1 ) )
	
	//Only look at 2 cameras
	IF ( CameraIndex <= 2 )
	{    
	    //Does Camera Exist and is Connected?
	    IF ( FIND_STRING ( cData, 'Connected: False', 1 ) )
	    {
		CAMERAS[CameraIndex] = Blank
		
		//Set Channel Event
		OFF[vdvDevices[CameraIndex], 304]
	    }
	    ELSE IF ( FIND_STRING ( cData, 'Connected: True', 1 ) )
	    {
		CAMERAS[CameraIndex].Id = CameraIndex
		CAMERAS[CameraIndex].Connected = 1
		
		//Set Channel Event
		ON [vdvDevices[CameraIndex], 304]
	    }
	    
	    //Only Evaluate Cameras if Connected
	    if ( CAMERAS[CameraIndex].Connected )
	    {
		IF ( FIND_STRING ( cData, 'Manufacturer:', 1 ) )
		{
		    CAMERAS[CameraIndex].Manufacturer = CISCO_removeWrap( cData, '"', '"' )
		}
		ELSE IF ( FIND_STRING ( cData, 'Model:', 1 ) )
		{
		    CAMERAS[CameraIndex].Model = CISCO_removeWrap( cData, '"', '"' )
		}
		ELSE IF ( FIND_STRING ( cData, 'SerialNumber:', 1 ) )
		{
		    CAMERAS[CameraIndex].SerialNumber = CISCO_removeWrap( cData, '"', '"' )
		}
		ELSE IF ( FIND_STRING ( cData, 'Position', 1 ) )
		{
		    IF ( FIND_STRING ( cData, 'Pan:', 1 ) )
		    {
			CAMERAS[CameraIndex].PAN = CISCO_removeWrap( cData, ': ', "$0D" )
		    }
		    
		    ELSE IF ( FIND_STRING ( cData, 'Tilt:', 1 ) )
		    {
			CAMERAS[CameraIndex].TILT = CISCO_removeWrap( cData, ': ', "$0D" )
		    }
		    
		    ELSE IF ( FIND_STRING ( cData, 'Zoom:', 1 ) )
		    {
			CAMERAS[CameraIndex].ZOOM = CISCO_removeWrap( cData, ': ', "$0D" )
		    }
		    
		    ELSE IF ( FIND_STRING ( cData, 'Focus:', 1 ) )
		    {
			CAMERAS[CameraIndex].FOCUS = CISCO_removeWrap( cData, ': ', "$0D" )
			
			//Camera Position Changed update Main Code 
			CAM_POSITION_CHANGED[CameraIndex] = 1
		    }
		}
	    }
	}
    }
    
    ELSE IF ( FIND_STRING ( cData, 'Video', 1 ) )
    {
	IF ( FIND_STRING ( cData, 'OSD Mode: On', 1 ) )
	{
	    ON[ vdvDevices[1], 303 ]
	}
	ELSE IF ( FIND_STRING ( cData, 'OSD Mode: Off', 1 ) )
	{
	    OFF[ vdvDevices[1], 303 ]
	}
    }	
    
    IF ( FIND_STRING ( cData, '1 AutoAnswer Mode: On', 1 ) )
    {
	Codec.AutoAnswer = 1
	
	ON[ vdvDevices[1], DIAL_AUTO_ANSWER_ON ]
    }
    ELSE IF ( FIND_STRING ( cData, '1 AutoAnswer Mode: Off', 1 ) )
    {
	Codec.AutoAnswer = 0
	
	OFF[ vdvDevices[1], DIAL_AUTO_ANSWER_ON ]
    }
    
    IF ( FIND_STRING ( cData, '1 AutoAnswer Mute: On', 1 ) )
    {
	Codec.AutoAnswerMute = 1
	
	ON[ vdvDevices[1], 325 ]
    }
    ELSE IF ( FIND_STRING ( cData, '1 AutoAnswer Mute: Off', 1 ) )
    {
	Codec.AutoAnswerMute = 0
	
	OFF[ vdvDevices[1], 325 ]
    }
    
    else if ( FIND_STRING ( cData, 'Status (status=Error):', 1 ) )
    {
	if ( FIND_STRING ( cData, 'XPath: Status/Call[', 1 ) )
	{
	    STACK_VAR INTEGER CallId 
	    STACK_VAR INTEGER CallIndex 
	    STACK_VAR CHAR svData[255]
	    
	    svData = cData
	    
	    CallId = ATOI ( CISCO_removeWrap ( svData, 'Call[', ']' ) )
	    
	    CallIndex = CISCO_getCallIndex( CallId )
	    
	    CALLS[CallIndex].Status = 'Idle'
	    
	    CALLS[CallIndex].Changed = 1
	    
	    CISCO_CallChanges(0)
	}
    }
    
    ELSE IF ( FIND_STRING ( cData, 'Call', 1 ) )
    {
	STACK_VAR INTEGER CallId 
	STACK_VAR INTEGER CallIndex 
	STACK_VAR CHAR svData[255]
	STACK_VAR _CALL BlankCall
	
	svData = cData
	
	CallId = ATOI ( CISCO_removeWrap ( svData, 'Call ', ' ' ) )
	
	CallIndex = CISCO_getCallIndex( CallId )
	
	//Set Call Id to the CALLS slot
	CALLS[CallIndex].CallId = CallId
	
	//Status
	if ( FIND_STRING ( cData, 'Status: ', 1 ) )
	{
	    CALLS[CallIndex].Status = CISCO_removeWrap( cData, ': ', "$0D" )
	    
	    //Send Status Main Program
	    CISCO_setDiallerStatus(CALLS[CallIndex].Status, CallIndex, 0)
	}
	
	else if ( FIND_STRING ( cData, 'Direction: ', 1 ) )
	{
	    CALLS[CallIndex].Direction = CISCO_removeWrap( cData, ': ', "$0D" )
	}
	
	else if ( FIND_STRING ( cData, 'Protocol: ', 1 ) )
	{
	    CALLS[CallIndex].Protocol = CISCO_removeWrap( cData, '"', '"' )
	}
	
	else if ( FIND_STRING ( cData, 'CallType: ', 1 ) )
	{
	    CALLS[CallIndex].Type = CISCO_removeWrap( cData, ': ', "$0D" )
	}
	
	else if ( FIND_STRING ( cData, 'RemoteNumber: ', 1 ) )
	{
	    CALLS[CallIndex].remoteNumber = CISCO_removeWrap( cData, '"', '"' )
	}
	
	else if ( FIND_STRING ( cData, 'CallbackNumber: ', 1 ) )
	{
	    CALLS[CallIndex].callBackNumber = CISCO_removeWrap( cData, '"', '"' )
	}
	
	else if ( FIND_STRING ( cData, 'DisplayName: ', 1 ) )
	{
	    CALLS[CallIndex].DisplayName = CISCO_removeWrap( cData, '"', '"' )
	}
	
	else if ( FIND_STRING ( cData, 'Encryption Type: ', 1 ) )
	{
	    CALLS[CallIndex].ENCRYPTION = CISCO_removeWrap( cData, '"', '"' )
	}
	
	else if ( FIND_STRING ( cData, 'TransmitCallRate: ', 1 ) )
	{
	    CALLS[CallIndex].RATE = CISCO_removeWrap( cData, ': ', "$0D" )
	}
	
	else if ( FIND_STRING ( cData, '(ghost=True):', 1 ) )
	{
	    CALLS[CallIndex].Status = 'Idle'
	}
	
	CALLS[CallIndex].Changed = 1
    }
    
    //Set Logged in flag to on
    ON [ vdvDevices[1], DATA_INITIALIZED ]
}

//Removes Quotes from Returned Codec Data
DEFINE_FUNCTION CHAR[255] CISCO_removeWrap( CHAR cData[255], CHAR Begin[8], CHAR End[8]  )
{
    REMOVE_STRING ( cData, Begin, 1 )
    
    cData = REMOVE_STRING ( cData, End, 1 )
    
    SET_LENGTH_STRING ( cData, ( LENGTH_STRING ( cData ) - 1 ) )
    
    return cData
}

//Establishes comms with Cisco Codec
DEFINE_FUNCTION CISCO_Connect( CHAR ipAddress[16] )
{
    //If RS-232
    if ( dvCodec.Number > 0 )
    {
	SEND_COMMAND dvCodec, "'SET BAUD ',BAUD_RATE,',N,8,1 485 DISABLE'"
	
	//Syncronised Data
	CISCO_sendCommand ('xStatus Standby Active')
	CISCO_sendCommand ('xStatus Audio Microphones Mute')
	CISCO_sendCommand ('xStatus Audio Volume')
	CISCO_sendCommand ('xStatus Video Selfview')
	CISCO_sendCommand ('xStatus Camera')
	CISCO_sendCommand ('xStatus H323')
	CISCO_sendCommand ('xStatus SIP')
	CISCO_sendCommand ('xStatus Call')
	CISCO_sendCommand ('xStatus Conference Presentation')
	
	CISCO_sendCommand ('xConfiguration H323')
	CISCO_sendCommand ('xConfiguration Video OSD Mode')
	CISCO_sendCommand ('xConfiguration Conference 1 AutoAnswer Mode')
	
	//Set Feedback 
	CISCO_registerFeedback()
    }
    ELSE
    {
	//Open Telnet Client with Cisco TC Codec 
	IP_CLIENT_OPEN ( dvCodec.PORT, ipAddress, 23, IP_TCP)
    }
}

DEFINE_FUNCTION CISCO_negotiateConnection( integer key )
{
    STACK_VAR CHAR keyCmd[64]
    
    SWITCH ( key )
    {
	CASE 0: keyCmd = "$FF,$FB,$1F,$FF,$FB,$20,$FF,$FB,$18,$FF,$FB,$27,$FF,$FD,$01,$FF,$FB,$03,$FF,$FD,$03"
	CASE 1: keyCmd = "$FF,$FC,$23"
	CASE 2: keyCmd = "$FF,$FA,$1F,$00,$82,$00,$28"
	CASE 3:	keyCmd = "$FF,$FA,$20,$00,'57400,57400',$FF,$F0,$FF,$FA,$27,$00,$FF,$F0,$FF,$FA,$18,' ',$01,' "',$FF,$F0,$FF,$FC,$2D"
	CASE 4:	keyCmd = "$FF,$FC,$01,$FF,$FE,$05,$FF,$FC,$21"
    }
    
    SEND_STRING dvCodec, "keyCmd"
}

//Register xPaths that the AMX will be listening for
DEFINE_FUNCTION CISCO_registerFeedback()
{
    //Listen for Mic Mute
    CISCO_sendCommand('xFeedback register status/standby/active')
    CISCO_sendCommand('xFeedback register status/audio/microphones')
    CISCO_sendCommand('xFeedback register status/audio/volume')
    CISCO_sendCommand('xFeedback register status/video/selfview')
    CISCO_sendCommand('xFeedback register status/camera')
    CISCO_sendCommand('xFeedback register status/H323/')
    CISCO_sendCommand('xFeedback register status/SIP/')
    CISCO_sendCommand('xFeedback register status/Call/')
    CISCO_sendCommand('xFeedback register status/Conference/Presentation')
    
    CISCO_sendCommand('xFeedback register configuration/H323/')
    CISCO_sendCommand('xFeedback register configuration/Video/OSD/mode')
    CISCO_sendCommand('xFeedback register configuration/Conference')
    CISCO_sendCommand('xFeedback register configuration/camera')
    CISCO_sendCommand('xFeedback register configuration/SystemUnit')
}

//Sends command to the device
DEFINE_FUNCTION CISCO_sendCommand( Char Cmd[255] )
{
    //To Device 
    SEND_STRING dvCodec, "Cmd,$0D,$0A"
    
    //To Debug
    //SEND_STRING 0, "'Tx: ',Cmd,$0D,$0A"
}

//See if there has been any changes to the call
DEFINE_FUNCTION CISCO_CallChanges(INTEGER request)
{
    STACK_VAR INTEGER i
    STACK_VAR _CALL BlankCall
    STACK_VAR CHAR CallCommand[512]
    
    FOR ( i=1; i<=4; i++ )
    {
	//If call data has changed then report to main program
	if ( CALLS[i].Changed OR request )
	{
	    if ( CALLS[i].Status == 'Idle' )
	    {
		//Clear call slot as call has ended
		CALLS[i] = BlankCall
		
		CALLS[i].Status = 'Idle'
	    }
	    
	    callCommand = "'CALL-',
		    ITOA ( CALLS[i].CallID ),',',
		    CALLS[i].Direction,',',
		    CALLS[i].Type,',',
		    CALLS[i].rate,',',
		    CALLS[i].encryption,',',
		    CALLS[i].presenting,',',
		    CALLS[i].remoteNumber,',',
		    CALLS[i].callBackNumber,',',
		    CALLS[i].DisplayName,',',
		    CALLS[i].protocol"
	    
	    
	    // Has the call command changed
	    if ( pCallCommand[i] != callCommand OR request )
	    {
		//Send Call Info to Main Program
		SEND_COMMAND vdvDevices[i], callCommand
		
		pCallCommand[i] = CallCommand
	    }    
	    
	    CISCO_setDiallerStatus( CALLS[i].Status, i, request )
	    
	    //Make changes have been read
	    CALLS[i].Changed = 0
	}
    }	
}

DEFINE_FUNCTION CISCO_checkCallStatus( )
{
    STACK_VAR INTEGER i
    
    FOR ( i=1; i<=4; i++ )
    {
	if ( CALLS[i].CallId )
	{
	    CISCO_sendCommand( "'xStatus Call ',  ITOA ( CALLS[i].CallId )"  )
	}
    }
}

DEFINE_START

SET_VIRTUAL_CHANNEL_COUNT ( vdvDevices[1], 400 )

IP_ADDRESS 	= '0.0.0.0'
USERNAME 	= 'admin'
PA55W0RD	= 'TANDBERG'
CODEC.SWVersion = '1.0.0'

CREATE_BUFFER dvCodec, BUFFER

DEFINE_EVENT 


DATA_EVENT [dvCodec]
{
    ONLINE:
    {
	//Set Online flag in module
	ON [ vdvDevices[1], DEVICE_COMMUNICATING ]
	
	//Send Initial Stuff
	CISCO_negotiateConnection(0)
    }
    OFFLINE:
    {
	CISCO_offline()
    }
    ONERROR:
    {
	STACK_VAR Char Error[64]
	
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
	
	SEND_STRING 0, "'!******************* Connection Error: ',Error"
    }
    STRING:
    {
	// SEND_STRING 0, "'Rx: ', DATA.TEXT"
	
	//if not logged in 
	if ( ![ vdvDevices[1], DATA_INITIALIZED ] )
	{
	    //Find Ack 1
	    if ( FIND_STRING ( DATA.TEXT, "$FF,$FD,$18,$FF,$FD,$20,$FF,$FD,$23,$FF,$FD,$27", 1 ) )
	    {
		//Send Ack 1
		CISCO_negotiateConnection(1)
	    }
	    
	    //Find Ack 2
	    if ( FIND_STRING ( DATA.TEXT, "$FF,$FD,$1F,$FF,$FB,$01,$FF,$FD,$03,$FF,$FB,$03", 1 ) )
	    {
		//Send Ack 2
		CISCO_negotiateConnection(2)
	    }
	    
	    //Find Ack 3
	    if ( FIND_STRING ( DATA.TEXT, "$FF,$FA,' ',$01,$FF,$F0,$FF,$FA,$27,$01,$FF,$F0,$FF,$FA,$18,$01,$FF,$F0", 1 ) )
	    {
		//Send Ack 3
		CISCO_negotiateConnection(3)
	    }
	    
	    //Find Ack 4
	    if ( FIND_STRING ( DATA.TEXT, "$FF,$FD,$01,$FF,$FB,$05,$FF,$FD,$21", 1 ) )
	    {
		//Send Ack 4
		CISCO_negotiateConnection(4)
	    }
	    
	    //listen for Username Prompt
	    if ( FIND_STRING ( DATA.TEXT, 'login:', 1 ) )
	    {
		//Send Username to codec
		SEND_STRING DATA.DEVICE, "USERNAME,$0D,$0A"
	    }
	    //listen for password Prompt
	    else if ( FIND_STRING ( DATA.TEXT, 'Password:', 1 ) )
	    {
		//Send Password to codec
		SEND_STRING DATA.DEVICE, "PA55W0RD,$0D,$0A"
	    }
	}
	
	//When Logged in
	if ( FIND_STRING ( DATA.TEXT, 'Welcome to', 1  ) )
	{
	    //Syncronised Data
	    CISCO_sendCommand ('xStatus Standby Active')
	    CISCO_sendCommand ('xStatus Audio Microphones Mute')
	    CISCO_sendCommand ('xStatus Audio Volume')
	    CISCO_sendCommand ('xStatus Video Selfview')
	    CISCO_sendCommand ('xStatus Camera')
	    CISCO_sendCommand ('xStatus H323')
	    CISCO_sendCommand ('xStatus SIP')
	    CISCO_sendCommand ('xStatus Call')
	    CISCO_sendCommand ('xStatus Conference Presentation')
	    
	    CISCO_sendCommand ('xConfiguration H323')
	    CISCO_sendCommand ('xConfiguration Video OSD Mode')
	    CISCO_sendCommand ('xConfiguration Conference 1 AutoAnswer Mode')
	    
	    //Set Feedback 
	    CISCO_registerFeedback()
	}
	
	//Get Firmware Version
	IF ( FIND_STRING ( DATA.TEXT, 'Release TC', 1 ) )
	{
	    REMOVE_STRING ( DATA.TEXT, 'Release ', 1 )
	    
	    Codec.FWVersion = REMOVE_STRING ( DATA.TEXT, "$0D", 1 )
	    
	    SET_LENGTH_STRING ( Codec.FWVersion, ( LENGTH_STRING ( Codec.FWVersion ) - 1 ) )
	    
	    //Send Firmware version back to Main Program
	    SEND_COMMAND vdvDevices[1], "'FWVERSION-',Codec.FWVersion"
	}
    }
}


DATA_EVENT [vdvDevices]
{
    COMMAND:
    {
	//Get Properties
	IF ( FIND_STRING ( DATA.TEXT, 'PROPERTY', 1 ) )
	{
	    IF ( FIND_STRING ( DATA.TEXT, 'IP_Address', 1 ) )
	    {
		//Remove PROPERTY-IP_Address,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		IP_ADDRESS = DATA.TEXT
	    }
	    
	    IF ( FIND_STRING ( DATA.TEXT, 'Password', 1 ) )
	    {
		//Remove PROPERTY-Password,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		PA55W0RD = DATA.TEXT
	    }
	    
	    IF ( FIND_STRING ( DATA.TEXT, 'Username', 1 ) )
	    {
		//Remove PROPERTY-Password,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		USERNAME = DATA.TEXT
	    }
	    
	    IF ( FIND_STRING ( DATA.TEXT, 'Baud_Rate', 1 ) )
	    {
		//Remove PROPERTY-Baud_Rate,
		REMOVE_STRING ( DATA.TEXT, ',', 1 )
		
		BAUD_RATE = DATA.TEXT
	    }
	}
	
	//Get Firmware 
	IF ( FIND_STRING ( DATA.TEXT, '?FWVERSION', 1 ) )
	{
	    SEND_COMMAND vdvDevices[1], "'FWVERSION-',Codec.FWVersion"
	}
	
	//Get This Module version
	IF ( FIND_STRING ( DATA.TEXT, '?VERSION', 1 ) )
	{
	    SEND_COMMAND vdvDevices[1], "'VERSION-',Codec.SWVersion"
	}
	
	//Get Firmware 
	IF ( FIND_STRING ( DATA.TEXT, '?SIP', 1 ) )
	{
	    SEND_COMMAND vdvDevices[1], "'SIP-',Codec.SIPURL,',',Codec.SIPProxy,',',Codec.SIPStatus"
	}
	
	//Get This Module version
	IF ( FIND_STRING ( DATA.TEXT, '?H323', 1 ) )
	{
	    SEND_COMMAND vdvDevices[1], "'H323-',Codec.E164,',',Codec.H323ID,',',Codec.Gatekeeper,',',Codec.H323Status"
	}
	
	//Connect and Reinitialize
	IF ( FIND_STRING ( DATA.TEXT, 'REINIT', 1 ) )
	{
	    IP_CLIENT_CLOSE ( dvCodec.PORT )
	    
	    CISCO_Connect( IP_ADDRESS )
	}
	
	//Request Camera Data
	IF ( FIND_STRING ( DATA.TEXT, '?CAMERA_PTZF', 1 ) )
	{
	    SEND_COMMAND vdvDevices[DATA.DEVICE.PORT], "'#CAMERA_PTZF-',	CAMERAS[DATA.DEVICE.PORT].PAN,',',
									CAMERAS[DATA.DEVICE.PORT].TILT,',',
									CAMERAS[DATA.DEVICE.PORT].ZOOM,',',
									CAMERAS[DATA.DEVICE.PORT].FOCUS"
	}
	
	IF ( FIND_STRING ( DATA.TEXT, 'CAMERA_PTZF', 1 ) )
	{
	    //See if the Command has come from this module
	    if ( LEFT_STRING ( DATA.TEXT, 1 ) != '#' )
	    {
		STACK_VAR _Camera Position
		
		//Remove CAMERA_PTZF-
		REMOVE_STRING ( DATA.TEXT, '-', 1 )
		
		//Pan
		Position.PAN = REMOVE_STRING ( DATA.TEXT, ',', 1 )
		Position.PAN = removeLastbyte( Position.PAN )
		
		//Tilt
		Position.tilt = REMOVE_STRING ( DATA.TEXT, ',', 1 )
		Position.tilt = removeLastbyte( Position.tilt )
		
		//Zoom
		Position.zoom = REMOVE_STRING ( DATA.TEXT, ',', 1 )
		Position.zoom = removeLastbyte( Position.zoom )
		
		//Focus
		Position.focus = DATA.TEXT
		
		//Set Camera Position
		CISCO_sendCommand (
		"'xCommand Camera PositionSet CameraId: ', ITOA ( DATA.DEVICE.PORT ),
		 ' Pan: ', Position.PAN,
		 ' Tilt: ', Position.TILT,
		 ' Zoom: ', Position.ZOOM,
		 ' Focus: ', Position.focus")
	    }
	}
	
	IF ( FIND_STRING ( DATA.TEXT, '?DIALERSTATUS', 1 ) )
	{
	    CISCO_setDiallerStatus( CALLS[DATA.DEVICE.PORT].Status, DATA.DEVICE.PORT, 1 )
	}
	
	IF ( FIND_STRING ( DATA.TEXT, '?CALL', 1 ) )
	{
	    //Send Call data out to main Program
	    CISCO_CallChanges(1)
	}
	
	//Dial Number
	IF ( FIND_STRING ( DATA.TEXT, 'DIALNUMBER-', 1 ) )
	{	
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    
	    //Dial Number
	    CISCO_sendCommand( "'xCommand Dial Number: ', DATA.TEXT" )
	}
	
	//Change Connector
	IF ( FIND_STRING ( DATA.TEXT, 'INPUT-', 1 ) )
	{
	    If ( DATA.DEVICE.PORT == 1 )
	    {
		REMOVE_STRING (DATA.TEXT, ',', 1 )
		
		CISCO_sendCommand ( "'xConfiguration Video MainVideoSource: ', DATA.TEXT" )
	    }
	    ELSE If ( DATA.DEVICE.PORT == 2 )
	    {
		REMOVE_STRING (DATA.TEXT, ',', 1 )
		
		CISCO_sendCommand ( "'xConfiguration Video DefaultPresentationSource: ', DATA.TEXT" )
	    }
	}
    }	
}


CHANNEL_EVENT [vdvDevices, 0]
{
    ON: 
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	
	    /*xCommand Camera Ramp
	    CameraId(r): <1..7>
	    Pan: <Left/Right/Stop>
	    PanSpeed: <1..15>
	    Tilt: <Down/Stop/Up>
	    TiltSpeed: <1..15>
	    Zoom: <In/Out/Stop>
	    ZoomSpeed: <1..15>
	    Focus: <Far/Near/Stop>*/
	    
	    CASE DIAL_FLASH_HOOK:
	    {
		CISCO_sendCommand("'xCommand Call Disconnect CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT].CallId )")
	    }
	    
	    /*Value(r): <Left/Right/Up/Down/ZoomIn/ZoomOut>*/
	    
	    CASE ZOOM_IN:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Zooming In
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Zoom: In'")
		}
		ELSE
		{
		    //Start Zooming In
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:ZoomIn'")
		}
	    }
	    CASE ZOOM_OUT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Zooming Out
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Zoom: Out'")
		}
		ELSE
		{
		    //Start Zooming Out
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:ZoomOut'")
		}
	    }
	    CASE PAN_LT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Panning Left
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Pan: Left'")
		}
		ELSE
		{
		    //Start Panning Left
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:Left'")
		}
	    }
	    CASE PAN_RT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Panning Right
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Pan: Right'")
		}
		ELSE
		{
		    //Start Panning Right
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:Right'")
		}
	    }
	    CASE TILT_UP:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Tilting Up
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Tilt: Up'")
		}
		ELSE
		{
		    //Start Zooming In
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:Up'")
		}
	    }
	    CASE TILT_DN:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Start Tilting Down
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Tilt: Down'")
		}
		ELSE
		{
		    //Start Tilting Down
		    CISCO_sendCommand("'xCommand FarEndControl Camera Move CallId:',ITOA ( CALLS[CHANNEL.DEVICE.PORT-7].CallId ),' Value:Down'")
		}
	    }
	    
	    //Ir Sensor on Camer
	    CASE 321:
	    {
		if ( !CAMERAS[CHANNEL.DEVICE.PORT].Ir )
		{
		    CISCO_sendCommand("'xConfiguration Cameras Camera[',ITOA( CHANNEL.DEVICE.PORT ),'] IrSensor: On'")
		}
	    }
	    
	    CASE 322:
	    {
		if ( !CAMERAS[CHANNEL.DEVICE.PORT].BACKLIGHT )
		{
		    CISCO_sendCommand("'xConfiguration Cameras Camera[',ITOA( CHANNEL.DEVICE.PORT ),'] Backlight: On'")
		}
	    }
	}
    }
    
    OFF:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    CASE ZOOM_IN:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Zooming In
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Zoom: Stop'")
		}
		ELSE
		{
		    //Stop Zooming In
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}
	    }
	    CASE ZOOM_OUT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Zooming Out
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Zoom: Stop'")
		}
		ELSE
		{
		    //Stop Zooming Out
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}
	    }
	    CASE PAN_LT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Panning Left
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Pan: Stop'")
		}
		ELSE
		{
		    //Stop Panning Left
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}
	    }
	    CASE PAN_RT:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Panning Right
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Pan: Stop'")
		}
		ELSE
		{
		    //Stop Panning Right
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}
	    }
	    CASE TILT_UP:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Tilting Up
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Tilt: Stop'")
		}
		ELSE
		{
		    //Stop Tilting Up
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}
	    }
	    CASE TILT_DN:
	    {
		if ( CHANNEL.DEVICE.PORT < 8 )
		{
		    //Stop Tilting Down
		    CISCO_sendCommand("'xCommand Camera Ramp CameraId: ',ITOA( CHANNEL.DEVICE.PORT ),' Tilt: Stop'")
		}
		ELSE
		{
		    //Stop Tilting Down
		    CISCO_sendCommand("'xCommand FarEndControl Camera Stop CallId: ',ITOA( CALLS[CHANNEL.DEVICE.PORT-7].CallId )")
		}    
	    }
	    
	    //Ir Sensor
	    CASE 321:
	    {
		if ( CAMERAS[CHANNEL.DEVICE.PORT].Ir )
		{
		    CISCO_sendCommand("'xConfiguration Cameras Camera[',ITOA( CHANNEL.DEVICE.PORT ),'] IrSensor: Off'")
		}
	    }
	    
	    //Backlight
	    CASE 322:
	    {
		if ( CAMERAS[CHANNEL.DEVICE.PORT].BACKLIGHT )
		{
		    CISCO_sendCommand("'xConfiguration Cameras Camera[',ITOA( CHANNEL.DEVICE.PORT ),'] Backlight: Off'")
		}
	    }
	}
    }
}


CHANNEL_EVENT [vdvDevices[1], 0]
{
    ON: 
    {
	SWITCH ( CHANNEL.CHANNEL )
	{	    
	    CASE ACONF_PRIVACY:
	    {
		//Microphones Mute
		if ( [ vdvDevices[1], ACONF_PRIVACY_FB ] )
		{
		    //UnMute Microphones
		    CISCO_sendCommand('xCommand Audio Microphones Unmute') 
		}
		ELSE
		{
		    //Mute Microphones
		    CISCO_sendCommand('xCommand Audio Microphones Mute')
		}
	    }
	    
	    //Case 
	    
	    //Selfview
	    CASE 305:
	    {
		CISCO_sendCommand( 'xCommand Video Selfview Set Mode: On' )
	    }
	    
	    //Cycle Selfview Window Position
	    CASE PIP_POS:
	    {
		
		if ( PIP_POSITION < 7 )
		{
		    //Increment PIP_POSITION Index
		    PIP_POSITION ++
		}
		ELSE
		{
		    PIP_POSITION = 1
		}
		
		IF ( PIP_POSITION == 1 )
		{
		    //Go to Full screen
		    CISCO_sendCommand( "'xCommand Video Selfview Set FullscreenMode: On'")
		}
		ELSE
		{
		    //Go to PIP
		    CISCO_sendCommand( "'xCommand Video Selfview Set FullscreenMode: Off'")
		    
		    //Change PIP_POSITION
		    CISCO_sendCommand( "'xCommand Video Selfview Set PIPPosition: ', PIP_POSITIONS[ PIP_POSITION - 1 ] ")
		}
	    }
	    
	    //Wake Codec
	    CASE PWR_ON:
	    {
		//Deactivate Standby
		CISCO_sendCommand( "'xCommand Standby Deactivate'")
	    }
	    
	    //Slep Codec
	    CASE PWR_OFF:
	    {
		//Activate Standby
		CISCO_sendCommand( "'xCommand Standby Activate'")
	    }
	    
	    //Toggle Standby
	    CASE POWER:
	    {
		if ( [vdvDevices[1], POWER_FB] )
		{
		    PULSE [ vdvDevices[1], PWR_OFF ] 
		}
		ELSE
		{
		    PULSE [ vdvDevices[1], PWR_ON ] 
		}
	    }
	    
	    //Switch the OSD on
	    CASE 303:
	    {
		CISCO_sendCommand( 'xConfiguration Video OSD Mode: On' )
	    }
	    
	    //Start Presenting
	    CASE 309:
	    {
		CISCO_sendCommand( 'xCommand Presentation Start' )
	    }
	    
	    //Auto Answer
	    CASE DIAL_AUTO_ANSWER_ON:
	    {
		if ( !Codec.AutoAnswer )
		{
		    CISCO_sendCommand ( 'xConfiguration Conference 1 AutoAnswer Mode: On' )
		}
	    }
	    
	    //Auto Answer Mute
	    CASE 325:
	    {
		if ( !Codec.AutoAnswerMute )
		{
		    CISCO_sendCommand ( 'xConfiguration Conference 1 AutoAnswer Mute: On' )
		}
	    }
	    
	    //IR Function
	    CASE 320:
	    {
		if ( !Codec.IrSensor )
		{
		    CISCO_sendCommand ( 'xConfiguration SystemUnit IrSensor: Auto' )
		}
	    }
	}
    }
    
    OFF:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    //Switch the OSD Off
	    CASE 303:
	    {
		CISCO_sendCommand( 'xConfiguration Video OSD Mode: Off' )
	    }
	    
	    //Selfview
	    CASE 305:
	    {
		CISCO_sendCommand( 'xCommand Video Selfview Set Mode: Off' )
	    }
	    
	    //Stop Presenting
	    CASE 309:
	    {
		CISCO_sendCommand( 'xCommand Presentation Stop' )
	    }
	    
	    //Auto Answer
	    CASE DIAL_AUTO_ANSWER_ON:
	    {
		if ( Codec.AutoAnswer )
		{
		    CISCO_sendCommand ( 'xConfiguration Conference 1 AutoAnswer Mode: Off' )
		}
	    }
	    
	    //Auto Answer Mute
	    CASE 325:
	    {
		if ( Codec.AutoAnswerMute )
		{
		    CISCO_sendCommand ( 'xConfiguration Conference 1 AutoAnswer Mute: Off' )
		}
	    }
	    
	    //IR Function
	    CASE 320:
	    {
		if ( Codec.IrSensor )
		{
		    CISCO_sendCommand ( 'xConfiguration SystemUnit IrSensor: Off' )
		}
	    }
	}
    }
}


DEFINE_PROGRAM

//Evaluate Buffer
IF ( FIND_STRING ( BUFFER, '*', 1 ) )
{
    CISCO_evaluateData(REMOVE_STRING ( BUFFER, '*', 1 ))
}

//Volume Ramping
WAIT 2
{
    if ( [vdvDevices[1], VOL_DN] )
    {
	CISCO_sendCommand( "'xConfiguration Audio Volume: ',  ITOA ( VOLUME_LEVEL - 5 )"  )
    }
    ELSE if ( [vdvDevices[1], VOL_UP] )
    {
	CISCO_sendCommand( "'xConfiguration Audio Volume: ',  ITOA ( VOLUME_LEVEL + 5 )"  )
    }
}

WAIT 50
{
    CISCO_checkCallStatus()
    
    //If Camera 1 Position has changed
    if ( CAM_POSITION_CHANGED[1] )
    {
	SEND_COMMAND vdvDevices[1], "'#CAMERA_PTZF-',	CAMERAS[1].PAN,',',
							CAMERAS[1].TILT,',',
							CAMERAS[1].ZOOM,',',
							CAMERAS[1].FOCUS"
	
	CAM_POSITION_CHANGED[1] = 0
    }
    
    //If Camera 2 Position has changed
    if ( CAM_POSITION_CHANGED[2] )
    {
	SEND_COMMAND vdvDevices[2], "'#CAMERA_PTZF-',	CAMERAS[2].PAN,',',
							CAMERAS[2].TILT,',',
							CAMERAS[2].ZOOM,',',
							CAMERAS[2].FOCUS"
	
	CAM_POSITION_CHANGED[2] = 0
    }
    
    //If SIP Changed
    if ( SIP_CHANGED )
    {
	SEND_COMMAND vdvDevices[1], "'SIP-',Codec.SIPURL,',',Codec.SIPProxy,',',Codec.SIPStatus"
	
	SIP_CHANGED = 0
    }
    
    //IF H323 Changed
    if ( H323_CHANGED )
    {
	SEND_COMMAND vdvDevices[1], "'H323-',Codec.E164,',',Codec.H323ID,',',Codec.Gatekeeper,',',Codec.H323Status"
	
	H323_CHANGED = 0
    }
}

WAIT 100 {
    
    // Ping for serial number every 10 seconds
    if ( [ vdvDevices[1], DEVICE_COMMUNICATING ]  )
    {
	OFF[ vdvDevices[1], DEVICE_COMMUNICATING ] 
	CISCO_sendCommand ( 'xStatus SystemUnit Hardware Module SerialNumber' )
    }
    
    // If there is still no response set to offline
    else
    {
	CISCO_offline()
    }
}

WAIT 5 {
    CISCO_reorderCalls()
    CISCO_CallChanges(0)
}
