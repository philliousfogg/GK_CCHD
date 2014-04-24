PROGRAM_NAME='CCHDMobile'

DEFINE_DEVICE

dvCodec		= 5001:2:0

#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'ButtonsChannels.axi'
#INCLUDE 'SNAPI.axi'
#INCLUDE 'Utilities.axi'
#INCLUDE 'Keyboard.axi'
#INCLUDE 'UI_Tools.axi'
#INCLUDE 'Dialog.axi'
#INCLUDE 'System.axi'
#INCLUDE 'URLTable.axi'
#INCLUDE 'IP_Table.axi'
#INCLUDE 'UISettings.axi'
#INCLUDE 'UI_Map.axi'
#INCLUDE 'CodecSetupClass.axi'
#INCLUDE 'Devices.axi'
#INCLUDE 'RMS.axi'
#INCLUDE 'RMSAsset.axi'
#INCLUDE 'Lights.axi'
#INCLUDE 'Events.axi'
#INCLUDE 'MainLine.axi'
#INCLUDE 'MobileConnectionManager.axi'

DEFINE_START


// Assign IO ports
dvIO = dvIO_700

REBUILD_EVENT()

//Define Device Modules
DEFINE_MODULE 'APART_CONCEPT1' amp( vdvAmplifier, dvAmplifier )

//Define RMS Modules
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvAmplifier, dvAmplifier, vdvRMSEngine)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL(vdvCLActions)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng(vdvRMSEngine, dvRMSSocket, vdvCLActions)

// RMSUIMod - The RMS User Interface.  Requires KeyboardMod.
// Channel And Variable Text Code Defined Inside The Module
DEFINE_MODULE 'RMSUIMod' mdlRMSUI(vdvRMSEngine,
				  vdvLesson,
                                  dvRMSTP,dvRMSTP_Base,
				  dvRMSTPWelcome,
				  dvRMSTPWelcome_Base,
				  RMS_MEETING_DEFAULT_SUBJECT,
				  RMS_MEETING_DEFAULT_MESSAGE)

DEFINE_START

// Define Gateway 1
DEFAULT_GATEWAYS[1].Flags 	= 3
DEFAULT_GATEWAYS[1].Port 	= 1319
DEFAULT_GATEWAYS[1].URL		= 'amxgw1.training.globalknowledge.net'
DEFAULT_GATEWAYS[1].User	= 'admin'
DEFAULT_GATEWAYS[1].Password	= 'ya73iW7dB7Ed6g5l'
DEFAULT_GW_SYSTEM_NUM[1]	= 101

// Define Gatway 2
DEFAULT_GATEWAYS[2].Flags 	= 3
DEFAULT_GATEWAYS[2].Port 	= 1319
DEFAULT_GATEWAYS[2].URL		= 'amxgw2.training.globalknowledge.net'
DEFAULT_GATEWAYS[2].User	= 'admin'
DEFAULT_GATEWAYS[2].Password	= 'ya73iW7dB7Ed6g5l'
DEFAULT_GW_SYSTEM_NUM[2]	= 102

// Register Room
SYSTEMS_thisSystem ( 	"'Mobile Unit ',ITOA(SYSTEM_NUMBER-30)",	//Room Name
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

DEFINE_EVENT

DEFINE_EVENT

// When RMSServer Engine comes online set IP
DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'SERVER-bookings.training.globalknowledge.net'"
    }
}
