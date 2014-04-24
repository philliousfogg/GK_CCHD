PROGRAM_NAME='dotone'

#INCLUDE 'CCHD.axi'

//RMS Virtual Room Comment out if not required
#INCLUDE 'RMSVirtualRoom.axi'

DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'Oslo - Room 2', 	//Room Name
			'Oslo', 		//Location
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
			'10.47.43.12',		//IP Address
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
			'10.47.43.13',		//IP Address
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
			'10.47.43.14',		//IP Address
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
			'10.47.43.11',	//IP Address
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
			'10.47.43.17',	//IP Address
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
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Front Right'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Students'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=4&label=Front Left'"
    }
}



