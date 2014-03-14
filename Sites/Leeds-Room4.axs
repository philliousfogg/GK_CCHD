PROGRAM_NAME='dotone'

#WARN 'This System Requires Multroom Collaborator Dependances'

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

//RMS Virtual Room Comment out if not required
#INCLUDE 'RMSVirtualRoom.axi'

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


DEFINE_EVENT

DATA_EVENT [ vdvLight ]
{
    ONLINE:
    {
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Front Left'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Front Right'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Students Front'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=4&label=Students Back'"
    }
}

DATA_EVENT [ vdvSystem ]
{
    ONLINE:
    {	
	SEND_COMMAND vdvSystem,"'SetRMSServer-url=10.255.33.21'" //Set RMS Server
	SEND_COMMAND vdvVSystem,"'SetRMSServer-url=10.255.33.21'" //Set RMS Server
	
	SEND_COMMAND vdvSystem,"'SetSystemData-',
				'sysnum=',ITOA(SYSTEM_NUMBER),
				'&name=Leeds - Room 4',
				'&loc=Leeds',
				'&comp=Global Knowledge',
				'&invcam=1'"
	
	//Front Smart Board
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=SmartBoard Projector',
				'&man=NEC',
				'&model=NP-U260WG',
				'&sn=',
				'&ip=10.44.115.140', //Change IP
				'&devd=33011',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=6',
				'&pds=0'"
	
	//Front Far End
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Front Far End Projector',
				'&man=NEC',
				'&model=NP-U260WG',
				'&sn=',
				'&ip=10.44.115.141', //Change IP
				'&devd=33012',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=7',
				'&pds=0'"
				
	//Back Far End
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Rear Far End Projector',
				'&man=NEC',
				'&model=M260WS',
				'&sn=',
				'&ip=10.44.115.142', //Change IP
				'&devd=33013',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=8',
				'&pds=0'"
	
	//Codec
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Video Conference',
				'&man=Cisco',
				'&model=C40',
				'&sn=',
				'&ip=10.44.115.139', //Change IP
				'&devd=41001',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=5',
				'&pds=0'"
	
	//Amplifier
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Amplifier',
				'&man=Apart',
				'&model=Concept 1',
				'&sn=',
				'&devd=33014',
				'&devp=1',
				'&devs=0',
				
				'&pdd=5001',
				'&pdp=1',
				'&pds=0'"
	//Lights
	SEND_COMMAND vdvSystem,"'DEVICES_Add-',
				'name=Lighting Dimmer',
				'&man=eDIN',
				'&model=NPU/4x3A LE',
				'&sn=',
				'&ip=10.44.115.145', //Change IP
				'&devd=33015',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=9',
				'&pds=0'"				
    }
}


DEFINE_EVENT 

//
DATA_EVENT [dvTP]
{
    ONLINE:
    {
	//Enable Manual Screen Button
	SEND_COMMAND dvTP, "'^SHO-300,1'"
    }
}

//Manual Control over Screen
BUTTON_EVENT [dvTP, 300 ]
{
    RELEASE:
    {
	if ( SCREEN_CONTROL  )
	{
	    OFF[SCREEN_CONTROL]
	    
	    //Power down projector
	    PULSE[vdvProjector3, PWR_OFF]
	}
	ELSE
	{
	    ON[SCREEN_CONTROL]
	}
    }
}

CHANNEL_EVENT [vdvProjector3, PWR_OFF]
{
    ON:
    {
	OFF[SCREEN_CONTROL]
    }
}
    
CHANNEL_EVENT [vdvProjector3, PWR_ON ]
{
    ON:
    {
	ON[SCREEN_CONTROL]
    }
}

DEFINE_PROGRAM


[dvIO, 2] = !SCREEN_CONTROL
[dvTP, 300] = [dvIO, 2]



