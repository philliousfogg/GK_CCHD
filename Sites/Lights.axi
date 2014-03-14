PROGRAM_NAME='Lights'

DEFINE_VARIABLE 

VOLATILE INTEGER LIGHTS_RES_SYS

VOLATILE INTEGER LIGHTS_TIMEOUT_NUM[] = {

    150,
    300,
    600,
    3000,
    9000,
    18000
}

VOLATILE CHAR LIGHTS_TIMEOUT_CHAR[6][3] = {

    '15s',
    '30s',
    '1m',
    '5m',
    '15m',
    '30m'
}

VOLATILE INTEGER LIGHTS_TIMEOUT = 6
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

//Sets lighting scene
DEFINE_FUNCTION LIGHTS_recallPreset(dev device, INTEGER scene )
{
    //Cancel Wait
    CANCEL_WAIT 'Lights'
    
    //Set Flag for Scenes
    SEND_COMMAND device, "'RECALL_PRESET-preset=',ITOA ( scene )"
}


DEFINE_FUNCTION LIGHTS_resetLights(dev device)
{
    WAIT LIGHTS_TIMEOUT_NUM[LIGHTS_TIMEOUT] 'Lights'
    {
	if ( !RMS_LEVELS.Current )  
	{
	    if ( !OVERRIDE_RMS )
	    {
		LIGHTS_recallPreset( device, 10 )
	    }
	}
    }
}

DEFINE_FUNCTION LIGHTS_setPreset( integer presetId, integer System )
{
    SEND_COMMAND vdvLight, "'SET_PRESET-preset=',ITOA(presetId)"
    
    LIGHTS_RES_SYS = System
}


DEFINE_FUNCTION LIGHTS_feedback()
{
    STACK_VAR INTEGER i 
    
    FOR ( i=10; i<=24; i++ )
    {
	[ dvTPLights, i ] = [ vdvLights[ACTIVE_SYSTEM], i ]
    }
}



DEFINE_EVENT

BUTTON_EVENT [dvTPLights, UILightsBtns ]
{
    PUSH:
    {
	STACK_VAR INTEGER svButton
	svButton = GET_LAST ( UILightsBtns )
	
	SWITCH ( svButton )
	{
	    //Ramp Lights Down
	    CASE 1:
	    CASE 2:
	    CASE 3:
	    CASE 4:
	    
	    //Ramp Lights Down
	    CASE 5:
	    CASE 6:
	    CASE 7:
	    CASE 8:
	    {
		ON[vdvLights[ACTIVE_SYSTEM], svButton]
	    }
	}
    }
    
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	svButton = GET_LAST ( UILightsBtns )
	
	SWITCH ( svButton )
	{
	    //Ramp Lights Down
	    CASE 1:
	    CASE 2:
	    CASE 3:
	    CASE 4:
	    
	    //Ramp Lights Down
	    CASE 5:
	    CASE 6:
	    CASE 7:
	    CASE 8:
	    {
		OFF[vdvLights[ACTIVE_SYSTEM], svButton]
	    }
	    
	    //All Off
	    CASE 10:
	    CASE 11:
	    CASE 12:
	    CASE 13:
	    CASE 14:
	    CASE 15:
	    CASE 16:
	    CASE 17:
	    CASE 18:
	    CASE 19:
	    CASE 20:
	    CASE 21:
	    CASE 22:
	    CASE 23:
	    CASE 24:
	    {
		LIGHTS_recallPreset( vdvLights[ACTIVE_SYSTEM], svButton  )
	    }
	    
	    //Increase TimeOut
	    CASE 25:
	    {
		if ( LIGHTS_TIMEOUT >= 6 )
		{
		    LIGHTS_TIMEOUT = 1
		}
		ELSE
		{
		    LIGHTS_TIMEOUT++
		}
		
		//Send to Touch Panel
		SEND_COMMAND dvTPLights, "'TEXT',ITOA ( UILightsBtns[27] ),'-',LIGHTS_TIMEOUT_CHAR[LIGHTS_TIMEOUT]"
		
		//Cancel Wait
		CANCEL_WAIT 'Lights'
	    }
	    
	    CASE 26:
	    {
		if ( LIGHTS_TIMEOUT <= 1 )
		{
		    LIGHTS_TIMEOUT = 6
		}
		ELSE
		{
		    LIGHTS_TIMEOUT--
		}
		
		//Send to Touch Panel
		SEND_COMMAND dvTPLights, "'TEXT',ITOA ( UILightsBtns[27] ),'-',LIGHTS_TIMEOUT_CHAR[LIGHTS_TIMEOUT]"
		
		//Cancel Wait
		CANCEL_WAIT 'Lights'
	    }
	    
	    CASE 30:
	    CASE 31:
	    CASE 32:
	    CASE 34:
	    CASE 35:
	    CASE 36:
	    CASE 37:
	    CASE 38:
	    CASE 39:
	    CASE 40:
	    CASE 41:
	    CASE 42:
	    CASE 43:
	    CASE 44:
	    {
		SEND_COMMAND vdvSystem, "'SET_LIGHTING_PRESET-sysnum=',ITOA(ACTIVE_SYSTEM),'&preset=',ITOA(svButton - 33) "
	    }
	}
    }
}

CHANNEL_EVENT [dvIO, 1]
{
    OFF:
    {
	//When PIR is activated set lights to full and Cancel time
	if ( !RMS_LEVELS.Current )  
	{
	    if ( !RMS_LEVELS.NEXT )
	    {
		if ( !OVERRIDE_RMS )
		{
		    LIGHTS_recallPreset(vdvLight, 13 )
		}
	    }
	}
    }
    ON:
    {
	LIGHTS_resetLights(vdvLight)
    }
}

//Set Levels on Touch Panel
LEVEL_EVENT [vdvLights, 1]
LEVEL_EVENT [vdvLights, 2]
LEVEL_EVENT [vdvLights, 3]
LEVEL_EVENT [vdvLights, 4]
{
    if ( LEVEL.INPUT.DEVICE.SYSTEM == ACTIVE_SYSTEM )
    {
	SEND_LEVEL dvTPLights, LEVEL.INPUT.LEVEL, LEVEL.VALUE
    }
}

DATA_EVENT [vdvLights]
{
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Check that we are receiving the correct data
	IF ( DATA.DEVICE.SYSTEM == ACTIVE_SYSTEM )
	{
	    IF ( FIND_STRING( DATA.TEXT, 'CHANNEL-', 1 ) )
	    {
		STACK_VAR INTEGER channelNum
		STACK_VAR INTEGER channelActive
		
		//get the channel number
		channelNum = ATOI ( getAttrValue( 'channel', aCommand ) )
		
		//Does the channel exist?
		channelActive = ATOI ( getAttrValue ( 'active', aCommand ) )
		
		//Show/hide buttons if the channel is active
		if ( channelActive )
		{
		    STACK_VAR CHAR label[16]
		    
		    //get label value
		    label = getAttrValue( 'label', aCommand )
		    
		    //Set label on touch panel
		    SEND_COMMAND dvTPLights, "'TEXT',ITOA( UILightsBtns[ channelNum ] ),'-',label"
		    
		    //Show Buttons
		    SEND_COMMAND dvTPLights, "'^SHO-',ITOA( UILightsBtns[ channelNum ] ),',1'"
		    SEND_COMMAND dvTPLights, "'^SHO-',ITOA( UILightsBtns[ channelNum + 4 ] ),',1'"
		}
		ELSE
		{
		    //Hide Buttons
		    SEND_COMMAND dvTPLights, "'^SHO-',ITOA( UILightsBtns[ channelNum ] ),',0'"
		    SEND_COMMAND dvTPLights, "'^SHO-',ITOA( UILightsBtns[ channelNum + 4 ] ),',0'"
		}
	    }
	}
    
    }
}

DATA_EVENT [vdvLights]
{
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Return Preset save confirmation to system requester
	IF ( FIND_STRING( DATA.TEXT, 'PRESET_SET-', 1 ) )
	{
	    //Alert Sender system that preset has been saved 
	    SEND_COMMAND vdvSystem, "'LIGHTING_PRESET_SAVED-sysnum=',ITOA(LIGHTS_RES_SYS),'&preset=',GetAttrValue('preset',aCommand )"
	}
    }
}

DEFINE_PROGRAM

LIGHTS_feedback()


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

