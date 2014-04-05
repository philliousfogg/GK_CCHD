 PROGRAM_NAME='dotone'

DEFINE_DEVICE

vdvRMSEngine	= 33103:1:101
vdvCLActions	= 33203:1:101
vdvLesson	= 33303:1:101

dvCodec		= 5001:2:0


#INCLUDE 'CCHDMobile.axi'

// AXIs for Mobile Units
#INCLUDE 'MobileConnectionManager.axi'

DEFINE_START

// Register Room
SYSTEMS_thisSystem ( 	'Mobile Unit 1',	//Room Name
			'Mobile', 		//Location
			'Global Knowledge', 	//Company
			false,			//Camera Inverse
			true,			//Mobile Room
			false			//Receive Only Room
)

//Codec
DEVICES_register( 	'Codec',	//Device Name
			'Cisco',	//Manufacturer
			'C40',		//Model
			'',		//Serial Number
			'',		//IP Address
			'38400',	//Baud Rate
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




