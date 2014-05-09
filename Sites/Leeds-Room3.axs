PROGRAM_NAME='dotone'

#INCLUDE 'CCHDReceive.axi'

DEFINE_DEVICE

dvScreens = 5002:1:3

DEFINE_MUTUALLY_EXCLUSIVE

([dvScreens,1],[dvScreens,2])
([dvScreens,3],[dvScreens,4])


DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'Leeds - Room 3', 	//Room Name
			'Leeds', 		//Location
			'Global Knowledge', 	//Company
			true,			//Camera Inverse
			false,			//Mobile Room
			true			//Receive Only Room
)

//Front Smart Board
DEVICES_register( 	'SmartBoard Projector',	//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.116.13',		//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector1,		//Virtual Port
			dvProjector1		//Physical Port
)

//Front Far End
DEVICES_register( 	'Front Far End Projector',//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.116.12',		//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector2,		//Virtual Port
			dvProjector2		//Physical Port
)

//Codec
DEVICES_register( 	'Codec',	//Device Name
			'Cisco',	//Manufacturer
			'C40',		//Model
			'',		//Serial Number
			'10.44.116.11',//IP Address
			'',		//Baud Rate
			'986TjL362Toz',	//Password
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
			'10.44.116.17',//IP Address
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
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Students'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Front Right'"
    }
}

CHANNEL_EVENT [vdvProjector1, PWR_OFF]
{
    ON:
    {
	PULSE[dvScreens, 2]
    }
}
    
CHANNEL_EVENT [vdvProjector1, PWR_ON ]
{
    ON:
    {
	PULSE[dvScreens, 1]
    }
}

CHANNEL_EVENT [vdvProjector2, PWR_OFF]
{
    ON:
    {
	PULSE[dvScreens, 4]
    }
}
    
CHANNEL_EVENT [vdvProjector2, PWR_ON ]
{
    ON:
    {
	PULSE[dvScreens, 3]
    }
}