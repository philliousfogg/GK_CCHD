PROGRAM_NAME='dotone'

#INCLUDE 'CCHD.axi'

DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'London - Brunswick', 	//Room Name
			'London', 		//Location
			'Global Knowledge', 	//Company
			false,			//Camera Inverse
			false,			//Mobile Room
			false			//Receive Only Room
)

//Front Smart Board
DEVICES_register( 	'SmartBoard Projector',	//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.84.13',	//IP Address
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
			'10.44.84.12',		//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector2,		//Virtual Port
			dvProjector2		//Physical Port
)

//Front Back End
DEVICES_register( 	'Rear Far End Projector',//Device Name
			'NEC',			//Manufacturer
			'NP-U310WG',		//Model
			'',			//Serial Number
			'10.44.84.14',		//IP Address
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
			'10.44.84.11',  //IP Address
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
			'10.44.84.17',  //IP Address
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
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Presentation'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Students Back'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Students Front'"
    }
}