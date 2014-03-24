PROGRAM_NAME='dotone'

#INCLUDE 'CCHD.axi'

DEFINE_START

// Register Room
SYSTEMS[1].SysDev 		= vdvSystem
SYSTEMS[1].systemNumber 	= SYSTEM_NUMBER
SYSTEMS[1].NAME 		= 'Stockholm - New York'
SYSTEMS[1].LOCATION 		= 'Stockholm'
SYSTEMS[1].COMPANY 		= 'Global Knowledge'
SYSTEMS[1].thisSystem		= 1


DEFINE_EVENT

DATA_EVENT [ vdvLight ]
{
    ONLINE:
    {
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=1&label=Front Left'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=2&label=Front Right'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=3&label=Front Students'"
	SEND_COMMAND vdvLight, "'REGISTER_CHANNEL-channel=4&label=Back Students'"
    }
}

DATA_EVENT [ vdvSystem ]
{
    ONLINE:
    {	
	//Front Smart Board
	SYSTEM_sendCommand ( vdvSystem,"'DEVICES_Add-',
				'name=SmartBoard Projector',
				'&man=NEC',
				'&model=NP-U310WG',
				'&sn=',
				'&ip=10.45.43.12', //Change IP
				'&devd=33011',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=6',
				'&pds=0'" )
	
	//Front Far End
	SYSTEM_sendCommand ( vdvSystem,"'DEVICES_Add-',
				'name=Front Far End Projector',
				'&man=NEC',
				'&model=NP-U310WG',
				'&sn=',
				'&ip=10.45.43.13', //Change IP
				'&devd=33012',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=7',
				'&pds=0'" )
				
	SYSTEM_sendCommand ( vdvSystem, "'DEVICES_Add-',
				'name=Rear Far End Projector',
				'&man=NEC',
				'&model=NP-U310WG',
				'&sn=',
				'&ip=10.45.43.14', //Change IP
				'&devd=33013',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=8',
				'&pds=0'" )
	
	//Codec
	SYSTEM_sendCommand ( vdvSystem,"'DEVICES_Add-',
				'name=Video Conference',
				'&man=Cisco',
				'&model=C40',
				'&sn=',
				'&ip=10.45.43.11', //Change IP
				'&devd=33001',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=5',
				'&pds=0'" )
	
	//Amplifier
	SYSTEM_sendCommand ( vdvSystem,"'DEVICES_Add-',
				'name=Amplifier',
				'&man=Apart',
				'&model=Concept 1',
				'&sn=',
				'&devd=33014',
				'&devp=1',
				'&devs=0', 
				
				'&pdd=5001',
				'&pdp=1',
				'&pds=0'" )
				
	//Lights
	SYSTEM_sendCommand ( vdvSystem,"'DEVICES_Add-',
				'name=Lighting Dimmer',
				'&man=eDIN',
				'&model=NPU/4x3A LE',
				'&sn=',
				'&ip=10.45.43.17', //Change IP
				'&devd=33015',
				'&devp=1',
				'&devs=0',
				
				'&pdd=0',
				'&pdp=9',
				'&pds=0'" )
    }
}

DATA_EVENT [vdvCodec]
{
    ONLINE:
    {
	//Set IP Address
	SEND_COMMAND vdvCodec, "'PROPERTY-IP_Address,10.45.43.11'"
	SEND_COMMAND vdvCodec, "'PROPERTY-Password,TANDBERG'"
	SEND_COMMAND vdvCodec, "'REINIT'"
    }
}


