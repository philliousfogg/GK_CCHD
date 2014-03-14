MODULE_NAME='DUMMY_DISPLAY_MODULE' (dev vdvDevice, dev dvDevice)

#INCLUDE 'SNAPI.axi'

DEFINE_EVENT

DATA_EVENT [vdvDevice]
{
    ONLINE:
    {
	ON[vdvDevice, DATA_INITIALIZED]
    }
    COMMAND:
    {
	IF ( FIND_STRING ( DATA.TEXT, 'INPUT-', 1 ) )
	{
	    SEND_STRING vdvDevice, DATA.TEXT
	}
    }
}	

//
CHANNEL_EVENT [vdvDevice, 0]
{
    ON:
    {
	SWITCH( CHANNEL.CHANNEL )
	{
	    CASE PWR_ON:
	    {
		ON [vdvDevice, POWER_FB]
		ON [vdvDevice, LAMP_WARMING_FB]
		WAIT 150
		{	
		    OFF[vdvDevice, LAMP_WARMING_FB]
		}
	    }
	    CASE PWR_OFF:
	    {
		ON[vdvDevice, LAMP_COOLING_FB]
		WAIT 150
		{	
		    OFF[vdvDevice, POWER_FB]
		    OFF[vdvDevice, LAMP_COOLING_FB]
		}
	    }
	    CASE POWER:
	    {
		if ( [vdvDevice, POWER_FB] )
		{
		    PULSE[vdvDevice, PWR_OFF]
		}
		ELSE
		{
		    PULSE[vdvDevice, PWR_ON]
		}
	    }
	    
	    CASE PIC_MUTE:
	    {
		if ( [vdvDevice, PIC_MUTE_ON] )
		{
		    OFF[vdvDevice, PIC_MUTE_ON]
		}
		ELSE
		{
		    ON[vdvDevice, PIC_MUTE_ON]
		}
	    }
	}
    }	
}
