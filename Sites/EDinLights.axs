MODULE_NAME='EDinLights' (dev vdvLights, dev dvLights)

#INCLUDE 'SNAPI.axi'
#INCLUDE 'Utilities.axi'

DEFINE_TYPE

STRUCTURE _DIMMER_CHANNEL
{
    INTEGER ID
    CHAR LABEL[16]
    sINTEGER VALUE
    INTEGER RAMP_UP
    INTEGER RAMP_DOWN
}

STRUCTURE _LIGHTING_PRESETS
{
    INTEGER ID
    CHAR LABEL[32]
    sINTEGER VALUE[4]
}

DEFINE_VARIABLE

VOLATILE char IP_ADDRESS[255]
VOLATILE INTEGER IP_PORT = 23
VOLATILE INTEGER IP_CONNECTION 

VOLATILE _DIMMER_CHANNEL DIMMER_CHANNEL[4]
VOLATILE _LIGHTING_PRESETS PRESETS[8]

VOLATILE CHAR LIGHT_FILE_BUFFER[20000]

VOLATILE INTEGER SELECTED_SCENE

DEFINE_MUTUALLY_EXCLUSIVE


//opens IP connection to Lighting Dimmer
DEFINE_FUNCTION openIPConnection()
{
    //Show Waiting Popup
    ip_client_open(dvLights.port,IP_ADDRESS,IP_PORT,1) 
} 

//closes IP connection to Lighting Dimmer
DEFINE_FUNCTION closeIPConnection()
{
    ip_client_close(dvLights.port)
}


//Ramps any active channels
DEFINE_FUNCTION rampChannels()
{
    STACK_VAR INTEGER i
    
    FOR ( i=1; i<5; i++ )
    {
	if ( DIMMER_CHANNEL[i].RAMP_UP )
	{
	    if ( DIMMER_CHANNEL[i].VALUE < 100 )
	    {
		DIMMER_CHANNEL[i].VALUE = DIMMER_CHANNEL[i].VALUE + 2
		
		//Send Level value to Lights
		SEND_STRING dvLights, "'M002D14C0',ITOA( i ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[i].VALUE ),'GO',$0D"
		
		//Send to debug for monitoring
		SEND_STRING 0, "'M002D14C0',ITOA( i ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[i].VALUE ),'GO',$0D"
		
		//Send Level
		SEND_LEVEL vdvLights, i, DIMMER_CHANNEL[i].VALUE
	    }
	}
	ELSE if ( DIMMER_CHANNEL[i].RAMP_DOWN )
	{
	    if ( DIMMER_CHANNEL[i].VALUE > 0 )
	    {
		DIMMER_CHANNEL[i].VALUE = DIMMER_CHANNEL[i].VALUE - 2
		
		//Send Level value to Lights
		SEND_STRING dvLights, "'M002D14C0',ITOA( i ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[i].VALUE ),'GO',$0D"
		
		//Send to debug for monitoring
		SEND_STRING 0, "'M002D14C0',ITOA( i ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[i].VALUE ),'GO',$0D"
		
		//Send Level
		SEND_LEVEL vdvLights, i, DIMMER_CHANNEL[i].VALUE
	    }
	}
    }
}


//Set Absolute leve
DEFINE_FUNCTION SetLightLevel(integer dimmerChannel, sinteger lev)
{
    //reset levels to lev
    DIMMER_CHANNEL[dimmerChannel].VALUE = lev
    
    //Send Level value to Lights
    SEND_STRING dvLights, "'M002D14C0',ITOA( dimmerChannel ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[dimmerChannel].VALUE ),'GO',$0D"
    
    //Send to debug for monitoring
    SEND_STRING 0, "'M002D14C0',ITOA( dimmerChannel ),'L',FORMAT ( '%03d',DIMMER_CHANNEL[dimmerChannel].VALUE ),'GO',$0D"
    
    //Send Level
    SEND_LEVEL vdvLights, dimmerChannel, DIMMER_CHANNEL[dimmerChannel].VALUE
}


//Switch Off all Lights
DEFINE_FUNCTION SetAllLightsLevel(sinteger lev)
{
    STACK_VAR INTEGER i
    
    FOR ( i=1; i<=4; i++ )
    {
	//Set Lighting Level
	SetLightLevel(i, lev)
    }
}

//Recall Lighting Scene
DEFINE_FUNCTION RecallLightingScene( integer preset )
{
    STACK_VAR INTEGER i
    
    SELECTED_SCENE = preset
    
    FOR ( i=1; i<=4; i++ )
    {
	//Set Lighting Level
	SetLightLevel(i, PRESETS[preset-13].VALUE[i] )
    }
}

DEFINE_FUNCTION PresetFeedback()
{
    STACK_VAR INTEGER i 
    
    FOR ( i=10; i<=24; i++ )
    {
	if ( SELECTED_SCENE )
	{
	    [vdvLights, i] = SELECTED_SCENE == i
	}
    }
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

//Maintain Connection
ON[IP_CONNECTION] 

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT [vdvLights, 0]
{
    ON:
    {
	//Reset Ligt Scene
	SELECTED_SCENE = 0
	
	SWITCH ( CHANNEL.CHANNEL )
	{
	    //Ramp individual Channels UP
	    CASE 1:
	    CASE 2:
	    CASE 3:
	    CASE 4:
	    {
		ON[DIMMER_CHANNEL[CHANNEL.CHANNEL].RAMP_UP]
	    }
	    
	    //Ramp individual Channels Down
	    CASE 5:
	    CASE 6:
	    CASE 7:
	    CASE 8:
	    {
		ON[DIMMER_CHANNEL[CHANNEL.CHANNEL-4].RAMP_DOWN]
	    }
	}
	
	//Initial ramp to cause one iteration
	rampChannels()
    }
    
    OFF:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    //Ramp individual Channels UP
	    CASE 1:
	    CASE 2:
	    CASE 3:
	    CASE 4:
	    {
		OFF[DIMMER_CHANNEL[CHANNEL.CHANNEL].RAMP_UP]
	    }
	    
	    //Ramp individual Channels Down
	    CASE 5:
	    CASE 6:
	    CASE 7:
	    CASE 8:
	    {
		OFF[DIMMER_CHANNEL[CHANNEL.CHANNEL-4].RAMP_DOWN]
	    }
	}
    }
}


//data_events
data_event[dvLIGHTS]
{
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
	SEND_STRING 0, "'Lights - Connection Error: ',Error"
    }
	
    online:
    {
	SEND_STRING 0, "'Lights - Connected'"
	
	
    }
    
    offline:
    {  
	SEND_STRING 0, "'Lights - Disconnected'"
	OFF[vdvLights, DEVICE_COMMUNICATING] 
	OFF[vdvLights, DATA_INITIALIZED]
    }
	
    STRING:
    {
	SEND_STRING 0, "'Lights - Response: ',DATA.TEXT"
	IF ( FIND_STRING ( DATA.TEXT, 'EVORDY', 1 ) )
	{
	    ON[vdvLights, DEVICE_COMMUNICATING]
	    ON[vdvLights, DATA_INITIALIZED]
	    
	    //Load Lighting Presets from Disk
	    ReadFile('LightingPreset.txt', LIGHT_FILE_BUFFER)
	    
	    //Convert String to Presets variable
	    XML_TO_VARIABLE ( PRESETS, LIGHT_FILE_BUFFER, 1, 0 )
	}
    }
}

DATA_EVENT [vdvLights]
{
    command:
    {	
	#INCLUDE 'EventCommandParser.axi'
	
	//Registers Dimmer Channel
	If ( FIND_STRING(data.text, 'REGISTER_CHANNEL-', 1 ) )
	{
	    STACK_VAR INTEGER id
	    
	    //get channel id
	    id = ATOI ( getAttrValue('channel',aCommand ) )
	    
	    //Set Dimmer channel data
	    DIMMER_CHANNEL[id].ID = id
	    DIMMER_CHANNEL[id].LABEL = getAttrValue('label', aCommand ) 
	}
	
	//Returns all the levels
	If ( find_string(data.text, 'GET_LEVELS', 1 ) )
	{
	    STACK_VAR INTEGER i 
	    
	    FOR ( i=1; i<5; i++ )
	    {
		if ( DIMMER_CHANNEL[i].ID )
		{
		    //Send current Dimmer Level
		    SEND_LEVEL vdvLights, i, DIMMER_CHANNEL[i].VALUE
		    
		    //Send Dimmer Information
		    SEND_COMMAND vdvLights, "'CHANNEL-channel=',ITOA ( i ),
					     '&active=1',
					     '&label=',DIMMER_CHANNEL[i].Label"
		}
		ELSE
		{
		    //Flag as not active
		    SEND_COMMAND vdvLights, "'CHANNEL-channel=',ITOA ( i ),'&active=0'"
		}
	    }
	}
	
	//Saves Preset
	IF ( FIND_STRING ( data.text, 'SET_PRESET-', 1 ) )
	{
	    STACK_VAR INTEGER PresetId
	    
	    PresetId = AtoI ( GetAttrValue('preset', aCommand) )
	    
	    //Set Current lighting values to preset
	    PRESETS[PresetId].Value[1] = DIMMER_CHANNEL[1].Value
	    PRESETS[PresetId].Value[2] = DIMMER_CHANNEL[2].Value
	    PRESETS[PresetId].Value[3] = DIMMER_CHANNEL[3].Value
	    PRESETS[PresetId].Value[4] = DIMMER_CHANNEL[4].Value
	    
	    //Convert to String
	    VARIABLE_TO_XML( PRESETS, LIGHT_FILE_BUFFER, 1, 0 )
	    
	    //Save to Disk
	    SaveFile('LightingPreset.txt', LIGHT_FILE_BUFFER)
	    
	    //Return Respone to program
	    SEND_COMMAND vdvLights, "'PRESET_SET-preset=',ITOA ( PresetId )"
	}
	
	//Recall Preset
	IF ( FIND_STRING ( data.text, 'RECALL_PRESET-', 1 ) )
	{
	    STACK_VAR INTEGER PresetId
	    
	    PresetId = AtoI ( GetAttrValue('preset', aCommand) )
	    
	    SWITCH ( PresetId )
	    {
		//Set Light Level
		CASE 10: 
		{
		    SetAllLightsLevel(0)
		    
		    SELECTED_SCENE = PresetId
		}
		CASE 11: 
		{
		    SetAllLightsLevel(33)
		    
		    SELECTED_SCENE = PresetId
		}
		CASE 12: 
		{
		    SetAllLightsLevel(66)
		    
		    SELECTED_SCENE = PresetId
		}
		CASE 13: 
		{
		    SetAllLightsLevel(100)
		    
		    SELECTED_SCENE = PresetId
		}
		
		//Trigger Sceces
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
		    
		    RecallLightingScene( PresetId )
		    
		    (*
		    //Show in Debug
		    SEND_STRING dvLights, "'SCENE',ITOA(CHANNEL.CHANNEL - 10),'GO',$0D"
		    
		    //Show in Debug
		    SEND_STRING 0, "'SCENE',ITOA(CHANNEL.CHANNEL - 10),'GO',$0D"
		    
		    *)
		}
	    }
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

    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

WAIT 30
{
    //Maitain lighting connection
    IF ( IP_CONNECTION AND ![vdvLights, DATA_INITIALIZED] )
    {
	openIPConnection()
    }
}

PresetFeedback()

WAIT 1.5
{
    rampChannels()
}


