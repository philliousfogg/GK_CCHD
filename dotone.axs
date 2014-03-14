PROGRAM_NAME='dotone'

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
#INCLUDE 'Events.axi'
#INCLUDE 'MainLine.axi'

//RMS Virtual Room Comment out if not required
#INCLUDE 'RMSVirtualRoom.axi'

DEFINE_START

//Define Device Modules
DEFINE_MODULE 'NEC_NPP420X_Comm_dr1_0_0' proj(vdvProjector1, dvProjector1)
DEFINE_MODULE 'NEC_NPP420X_Comm_dr1_0_0' proj(vdvProjector2, dvProjector2)
DEFINE_MODULE 'NEC_NPP420X_Comm_dr1_0_0' proj(vdvProjector3, dvProjector3)

//Define RMS Modules
DEFINE_MODULE 'RMSBasicDeviceMod' mRMSProj(vdvProjector1, dvProjector1, vdvRMSEngine)


DEFINE_EVENT

DATA_EVENT [ vdvSystem ]
{
    ONLINE:
    {	
	SEND_COMMAND vdvSystem,"'SetRMSServer-url='" //Set RMS Server
	
	SEND_COMMAND vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER),
				'&name=Brunswick',
				'&loc=London',
				'&comp=Global Knowledge'"
	
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Projector',
				'&man=NEC',
				'&model=U310W',
				'&sn=',
				'&ip=10.115.2.16', //Change IP
				'&devd=41011',
				'&devp=1',
				'&devs=0'"
	
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Projector',
				'&man=NEC',
				'&model=U310W',
				'&sn=',
				'&ip=10.115.2.16', //Change IP
				'&devd=41012',
				'&devp=1',
				'&devs=0'"
	
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Projector',
				'&man=NEC',
				'&model=U310W',
				'&sn=',
				'&ip=10.115.2.16', //Change IP
				'&devd=41013',
				'&devp=1',
				'&devs=0'"
				
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Codec',
				'&man=Cisco',
				'&model=C20',
				'&sn=FN092183',
				'&ip=10.115.8.11', //Change IP
				'&devd=41001',
				'&devp=1',
				'&devs=0'"	
    }
}