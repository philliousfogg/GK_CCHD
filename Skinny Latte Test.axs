PROGRAM_NAME='Skinny Latte Test'

DEFINE_DEVICE

dvCodec		= 0:5:0

vdvCodec	= 33001:1:0

vdvDevice1	= 33001:1:0
vdvDevice2	= 33001:2:0
vdvDevice3	= 33001:3:0
vdvDevice4	= 33001:4:0
vdvDevice5	= 33001:5:0
vdvDevice6	= 33001:6:0
vdvDevice7	= 33001:7:0
vdvDevice8	= 33001:8:0

dvTP		= 10001:1:0
dvTPVC		= 10001:2:0

//User Interface_______________________________________________________________

#INCLUDE 'SNAPI.axi'

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

DEFINE_CONSTANT

CHAR CONF_STATE_IDLE[] = 'Idle'
CHAR CONF_STATE_NEG[]  = 'Negotiating'
CHAR CONF_STATE_CONN[] = 'Connected'
CHAR CONF_STATE_RING[] = 'Ringing'
CHAR CONF_STATE_DIAL[] = 'Dialing'
CHAR CONF_STATE_ONHOLD[] = 'OnHold'

INTEGER MAX_CALLS = 4

DEFINE_VARIABLE

_Codec Codec
_CALLS Calls[4]

VOLATILE DEV vdvDevices[] = {
    
    vdvDevice1,
    vdvDevice2,
    vdvDevice3,
    vdvDevice4,
    vdvDevice5,
    vdvDevice6,
    vdvDevice7,
    vdvDevice8
}

VOLATILE INTEGER UIBtn[] = {

    89,		//1 Vol Up
    90,		//2 Vol Down
    16,		//3 Mic Mute
    
    66,67,	//4,5 Zoom In and Out
    68,69,70,71,//6,7,8,9 PTZ
    
    124,	//10 Camera 1
    125,        //11 Camera 2
    
    15,		//12 Selfview Cycle
    
    17,		//13 Presentation Cycle
    18,		//14 OSDs
    
    19,		//15 Auto Answer
    132		//16 Far End
} 

VOLATILE INTEGER SELECTED_CAMERA = 1
VOLATILE INTEGER SELFVIEW_POSITION

DEFINE_FUNCTION char[255] getDelimitedData(char aData[255], char delimiter[1])
{
    STACK_VAR Char sData[255]
    
    //get <data><delimiter>
    sData = REMOVE_STRING ( aData, delimiter, 1 )
    
    //remove <delimiter>
    SET_LENGTH_STRING ( sData, ( LENGTH_STRING( sData ) - 1 ) )
    
    return sData
}

//Strip last byte
DEFINE_FUNCTION char[255] removeLastbyte( char pString[255] )
{
    SET_LENGTH_STRING ( pString, ( LENGTH_STRING ( pString ) - 1 ) )
    RETURN pString
}


DEFINE_MODULE 'CiscoTCThinClient' m( dvCodec, vdvDevices )

DEFINE_EVENT

DATA_EVENT [vdvDevices]
{
    ONLINE:
    {
	//Set IP Address
	SEND_COMMAND vdvDevice1, "'PROPERTY-IP_Address,10.115.8.3'"
	
	//Set Password
	SEND_COMMAND vdvDevice1, "'PROPERTY-Password,TANDBERG'"
	
	//Reinitialise
	SEND_COMMAND vdvDevice1, "'REINIT'"
    }
}

DATA_EVENT [vdvDevices]
{
    ONLINE:
    {
	//Switch Auto Answer On
	ON[vdvCodec, DIAL_AUTO_ANSWER_ON]
	
	//Switch On Camera Scaling
	ON[vdvCodec, 312]
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
	    
	}
	if ( FIND_STRING ( data.text, 'SIP-', 1) )
	{
	    REMOVE_STRING ( data.text, '-', 1 )
	    
	    Codec.SIPURL = getDelimitedData(DATA.TEXT, ',')
	    Codec.SIPProxy = getDelimitedData(DATA.TEXT, ',')
	    Codec.SIPStatus = Data.TEXT
	}
	
	if ( FIND_STRING ( DATA.TEXT, 'CAMERA_PTZF-', 1 ) )
	{
	    
	}
	
	switch(remove_string(data.text, '-', 1)) {
	    
	    case 'CALL-':
	    {
		CALLS[DATA.DEVICE.PORT].ID = data.device.port
		CALLS[DATA.DEVICE.PORT].CallID 	= ATOI ( removeLastbyte( remove_string(data.text, ',', 1) ) ) // real callId
		CALLS[DATA.DEVICE.PORT].Direction = removeLastbyte( remove_string(data.text, ',', 1) )// direction
		CALLS[DATA.DEVICE.PORT].Type = removeLastbyte( remove_string(data.text, ',', 1) )// calltype
		CALLS[DATA.DEVICE.PORT].rate = removeLastbyte( remove_string(data.text, ',', 1) )// callrate
		CALLS[DATA.DEVICE.PORT].encryption = removeLastbyte ( remove_string(data.text, ',', 1) )// encryption
		CALLS[DATA.DEVICE.PORT].presenting = removeLastbyte ( remove_string(data.text, ',', 1) )// presenting
		CALLS[DATA.DEVICE.PORT].remoteNumber = removeLastbyte( remove_string(data.text, ',', 1) ) //Remote Number
		CALLS[DATA.DEVICE.PORT].callBackNumber = removeLastbyte( remove_string(data.text, ',', 1) )// Call Back Number
		CALLS[DATA.DEVICE.PORT].DisplayName = removeLastbyte( remove_string(data.text, ',', 1) )// Display Name
		CALLS[DATA.DEVICE.PORT].protocol = data.text //Protocol 
		
		//Send Call Details
		SEND_COMMAND dvTP, "'TEXT',ITOA( DATA.DEVICE.PORT + 40 ),'-',CALLS[DATA.DEVICE.PORT].DisplayName"
	    }
	    case 'DIALERSTATUS-':
	    {	
		switch(data.text)
		{
		    case 'NEGOTIATING':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_NEG
		    }
		    case 'RINGING':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_RING
		    }
		    case 'DIALING':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_DIAL
		    }
		    case 'DISCONNECTED':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_IDLE
		    }
		    case 'CONNECTED':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_CONN
		    }
		    case 'ON_HOLD':
		    {
			Calls[DATA.DEVICE.PORT].State = CONF_STATE_ONHOLD
		    }
		}
	    }
	    case 'INCOMINGCALL-':
	    {
	    
	    }
	}
    }
}

LEVEL_EVENT [vdvDevices[1], VOL_LVL]
{
    SEND_LEVEL dvTPVC, 92, LEVEL.VALUE
}

BUTTON_EVENT [dvTP, 3]
{
    PUSH:
    {
	//Set IP Address
	SEND_COMMAND vdvDevice1, "'PROPERTY-IP_Address,10.115.8.5'"
	
	//Set Password
	SEND_COMMAND vdvDevice1, "'PROPERTY-Password,!V1ju13?'"
	
	//Reinitialise
	SEND_COMMAND vdvDevice1, "'REINIT'"
    }	
}

BUTTON_EVENT [dvTP, 4]
{
    PUSH:
    {
	IP_CLIENT_CLOSE(dvCodec.PORT) 
    }	
}

BUTTON_EVENT [dvTP, 6]
{
    PUSH:
    {
	if ( [ vdvDevices[1], POWER_FB ] )
	{
	    PULSE [ vdvDevices[1], PWR_OFF ]
	}
	ELSE
	{
	    PULSE [ vdvDevices[1], PWR_ON ]
	}
    }	
}

//UI
BUTTON_EVENT [ dvTPVC, UIbtn ]
{
    PUSH:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( UIbtn )
	
	SWITCH ( svButton )
	{
	    CASE 1: TO[ vdvDevices[1], VOL_UP ]
	    CASE 2: TO[ vdvDevices[1], VOL_DN ]
	    CASE 3: 
	    {
		PULSE [ vdvDevices[1], ACONF_PRIVACY ]
	    }
	    
	    CASE 4: TO[ vdvDevices[SELECTED_CAMERA], ZOOM_IN  ]
	    CASE 5: TO[ vdvDevices[SELECTED_CAMERA], ZOOM_OUT ]
	    
	    CASE 6: TO[ vdvDevices[SELECTED_CAMERA], TILT_UP]
	    CASE 7: TO[ vdvDevices[SELECTED_CAMERA], TILT_DN]
	    CASE 8: TO[ vdvDevices[SELECTED_CAMERA], PAN_LT ]
	    CASE 9: TO[ vdvDevices[SELECTED_CAMERA], PAN_RT ]
	    
	    CASE 10: SELECTED_CAMERA = 1
	    CASE 11: SELECTED_CAMERA = 2
	    
	    CASE 12:
	    {
		//Create Toggle
		IF ( SELFVIEW_POSITION < 7  )
		{
		    //SWITCH ON SELFVIEW 
		    ON[vdvDevices[1], 305 ]
		    
		    //change position
		    PULSE[vdvDevices[1], PIP_POS]
		    
		    //Increment Selfview position
		    SELFVIEW_POSITION++
		    
		}
		ELSE
		{
		    //Set Selfview Position off
		    SELFVIEW_POSITION = 0
		    
		    //Switch Off Selfview
		    OFF[vdvDevices[1], 305 ]
		}
	    }
	    
	    CASE 13:
	    {
		IF ( [vdvCodec, 309] )
		{
		    OFF[vdvCodec, 309]
		}
		ELSE
		{
		    ON [vdvCodec, 309]
		}
	    }
	    
	    CASE 14:
	    {
		IF ( [vdvCodec, 303] )
		{
		    OFF[vdvCodec, 303]
		}
		ELSE
		{
		    ON [vdvCodec, 303]
		}
	    }
	    
	    CASE 15:
	    {
		IF ( [vdvCodec, DIAL_AUTO_ANSWER_FB] )
		{
		    OFF[vdvCodec, DIAL_AUTO_ANSWER_FB]
		}
		ELSE
		{
		    ON [vdvCodec, DIAL_AUTO_ANSWER_FB]
		}
	    }
	    
	    CASE 16:
	    {
		SELECTED_CAMERA = 8
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
		SEND_COMMAND channel.device, "'?FWVERSION'"
		SEND_COMMAND channel.device, "'?VERSION'"
		SEND_COMMAND channel.device, "'?H323'"
		SEND_COMMAND channel.device, "'?SIP'"		
	    }
	}
    }
    OFF:
    {

    }
}

DEFINE_PROGRAM

[dvTP, 1] = [ vdvDevices[1], DATA_INITIALIZED ] 
[dvTP, 2] = [ vdvDevices[1], DEVICE_COMMUNICATING ] 
[dvTP, 5] = [ vdvDevices[SELECTED_CAMERA], 304 ]
[dvTP, 6] = [ vdvDevices[1], POWER_FB ]

[dvTPVC, 16]   = [ vdvDevices[1], ACONF_PRIVACY_FB ]
[dvTPVC, 124]  = ( SELECTED_CAMERA == 1 )
[dvTPVC, 125]  = ( SELECTED_CAMERA == 2 )
[dvTPVC, 132]  = ( SELECTED_CAMERA == 8 )
[dvTPVC, 15]   = [ vdvDevices[1], 305 ]
[dvTPVC, 18]   = [ vdvDevices[1], 303 ]
[dvTPVC, 19]   = [ vdvDevices[1], DIAL_AUTO_ANSWER_FB ]

[dvTP, 10] = [ vdvDevices[1], 309 ]
[dvTP, 11] = [ vdvDevices[1], DIAL_OFF_HOOK_ON ]
[dvTP, 12] = [ vdvDevices[2], DIAL_OFF_HOOK_ON ]
[dvTP, 13] = [ vdvDevices[3], DIAL_OFF_HOOK_ON ]
[dvTP, 14] = [ vdvDevices[4], DIAL_OFF_HOOK_ON ]

[dvTP, 21] = [ vdvDevices[1], 318 ]
[dvTP, 22] = [ vdvDevices[2], 318 ]
[dvTP, 23] = [ vdvDevices[3], 318 ]
[dvTP, 24] = [ vdvDevices[4], 318 ]


















