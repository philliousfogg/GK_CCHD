PROGRAM_NAME='dotone'

#INCLUDE 'CCHD.axi'

//RMS Virtual Room Comment out if not required
#INCLUDE 'RMSVirtualRoom.axi'

DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'Leeds - Room 4', 	//Room Name
			'Leeds', 		//Location
			'Global Knowledge', 	//Company
			true,			//Camera Inverse
			false,			//Mobile Room
			false			//Receive Only Room
)

//Front Smart Board
DEVICES_register( 	'SmartBoard Projector',	//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.115.140',	//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector1,		//Virtual Port
			dvProjector1		//Physical Port
)

//Front Smart Board
DEVICES_register( 	'Front Far End Projector',//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.115.141',		//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector2,		//Virtual Port
			dvProjector2		//Physical Port
)

//Front Smart Board
DEVICES_register( 	'Rear Far End Projector',//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.115.142',	//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector3,		//Virtual Port
			dvProjector3		//Physical Port
)

//Codec
DEVICES_register( 	'Codec',	//Device Name
			'Cisco',	//Manufacturer
			'C40',		//Model
			'',		//Serial Number
			'10.44.115.139',//IP Address
			'',		//Baud Rate
			'TANDBERG',	//Password
			vdvCodec,	//Virtual Port
			dvCodec		//Physical Port
)

//Amplifier
DEVICES_register( 	'Amplifier',	//Device Name
			'Apart',	//Manufacturer
			'Concept 1',	//Model
			'',		//Serial Number
			'',		//IP Address
			'',		//Baud Rate
			'',		//Password
			vdvAmplifier,	//Virtual Port
			dvAmplifier	//Physical Port
)


//Lights
DEVICES_register( 	'Lighting Dimmer',//Device Name
			'eDIN',		//Manufacturer
			'NPU/4x3A LE',	//Model
			'',		//Serial Number
			'10.44.115.145',//IP Address
			'',		//Baud Rate
			'',		//Password
			vdvLight,	//Virtual Port
			dvLights	//Physical Port
)

DEFINE_EVENT

DATA_EVENT [ vdvLight ]
{
    ONLINE:
    {
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Front Left'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Front Right'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Students Front'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=4&label=Students Back'"
    }
}

DATA_EVENT [dvTP]
{
    ONLINE:
    {
	//Enable Manual Screen Button
	SEND_COMMAND dvTP, "'^SHO-300,1'"
    }
}

//Manual Control over Screen
BUTTON_EVENT [dvTP, 300 ]
{
    RELEASE:
    {
	if ( SCREEN_CONTROL  )
	{
	    OFF[SCREEN_CONTROL]
	    
	    //Power down projector
	    PULSE[vdvProjector3, PWR_OFF]
	}
	ELSE
	{
	    ON[SCREEN_CONTROL]
	}
    }
}

CHANNEL_EVENT [vdvProjector3, PWR_OFF]
{
    ON:
    {
	OFF[SCREEN_CONTROL]
    }
}
    
CHANNEL_EVENT [vdvProjector3, PWR_ON ]
{
    ON:
    {
	ON[SCREEN_CONTROL]
    }
}

DEFINE_PROGRAM


[dvIO, 2] = !SCREEN_CONTROL
[dvTP, 300] = [dvIO, 2]



