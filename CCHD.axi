PROGRAM_NAME='CCHD'

#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'ButtonsChannels.axi'
#INCLUDE 'SNAPI.axi'
#INCLUDE 'Utilities.axi'
#INCLUDE 'UI_Tools.axi'
#INCLUDE 'Dialog.axi'
#INCLUDE 'Keyboard.axi'
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

//Define Device Modules
DEFINE_MODULE 'NECPROJECTOR' proj1(vdvProjector1, dvProjector1)
DEFINE_MODULE 'NECPROJECTOR' proj2(vdvProjector2, dvProjector2)
DEFINE_MODULE 'NECPROJECTOR' proj3(vdvProjector3, dvProjector3)

DEFINE_MODULE 'EDinLights' lights(vdvLight, dvLights)
DEFINE_MODULE 'APART_CONCEPT1' amp( vdvAmplifier, dvAmplifier )

//Define RMS Modules
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvProjector1, dvProjector1, vdvRMSEngine)
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvProjector2, dvProjector2, vdvRMSEngine)
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvProjector3, dvProjector3, vdvRMSEngine)
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvAmplifier, dvAmplifier, vdvRMSEngine)
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvLight, dvLights, vdvRMSEngine)

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


DEFINE_EVENT

DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'SERVER-10.255.33.21'"
    }
}
