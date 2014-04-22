PROGRAM_NAME='CCHDMobile'

#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'ButtonsChannels.axi'
#INCLUDE 'SNAPI.axi'
#INCLUDE 'Utilities.axi'
#INCLUDE 'UI_Tools.axi'
#INCLUDE 'Dialog.axi'
#INCLUDE 'System.axi'
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

DEFINE_EVENT

DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'SERVER-bookings.training.globalknowledge.net'"
    }
}