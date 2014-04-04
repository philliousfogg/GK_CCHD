PROGRAM_NAME='dotone'

#INCLUDE 'CCHDReceive.axi'


DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'Dublin',	 	//Room Name
			'Dublin', 		//Location
			'Global Knowledge', 	//Company
			true,			//Camera Inverse
			false,			//Mobile Room
			true			//Receive Only Room
)

//Front Smart Board
DEVICES_register( 	'SmartBoard Projector',	//Device Name
			'NEC',			//Manufacturer
			'M260WS',		//Model
			'',			//Serial Number
			'10.35.43.12',		//IP Address
			'',			//Baud Rate
			'',			//Password
			vdvProjector1,		//Virtual Port
			dvProjector1		//Physical Port
)

//Front Far End
DEVICES_register( 	'Front Far End Projector',//Device Name
			'NEC',			//Manufacturer
			'M260WS',		//Model
			'',			//Serial Number
			'10.35.43.13',		//IP Address
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
			'10.35.43.11',	//IP Address
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
			'eDIN',		  //Manufacturer
			'NPU/4x3A LE',	  //Model
			'',		  //Serial Number
			'10.35.43.17',	  //IP Address
			'',		  //Baud Rate
			'',		  //Password
			vdvLight,	  //Virtual Port
			dvLights	  //Physical Port
)

DEFINE_EVENT

DATA_EVENT [ vdvLight ]
{
    ONLINE:
    {
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Front Left'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Front Right'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Students'"
    }
}