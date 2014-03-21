PROGRAM_NAME='CCHD'

#INCLUDE 'DeviceDefinitions.axi'
#INCLUDE 'ButtonsChannels.axi'
#INCLUDE 'SNAPI.axi'
#INCLUDE 'Utilities.axi'
#INCLUDE 'UI_Tools.axi'
#INCLUDE 'Dialog.axi'
#INCLUDE 'System.axi'
#INCLUDE 'CodecSetupClass.axi'
#INCLUDE 'Devices.axi'
#INCLUDE 'RMS.axi'
#INCLUDE 'RMSAsset.axi'
#INCLUDE 'Lights.axi'
#INCLUDE 'Events.axi'
#INCLUDE 'MainLine.axi'

DEFINE_START

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

DEFINE_EVENT

DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'SERVER-10.255.33.21'"
    }
}