PROGRAM_NAME='dottwo'

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
#INCLUDE 'RMSAsset.axi';
#INCLUDE 'Events.axi'
#INCLUDE 'MainLine.axi'

DEFINE_START


REBUILD_EVENT()


DEFINE_EVENT

DATA_EVENT [ vdvSystem ]
{
    ONLINE:
    {
	SEND_cOMMAND vdvSystems,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER),
				'&name=Test Two',
				'&loc=Manchester',
				'&comp=Global Knowledge',
				'&receive=1'"
	
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Codec',
				'&man=Cisco',
				'&model=T1',
				'&sn=FN092183',
				'&ip=10.115.8.12',
				'&devd=41001',
				'&devp=1',
				'&devs=20'"
    }
}