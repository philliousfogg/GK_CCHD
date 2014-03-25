PROGRAM_NAME='Devices'


DEFINE_VARIABLE

VOLATILE INTEGER ct[LENGTH_DEVICES]
VOLATILE INTEGER PIC_MUTE_TIMEOUT = 3600
VOLATILE INTEGER PIC_MUTE_MESSAGE_TIMEOUT = 60
VOLATILE INTEGER SCREEN_CONTROL

DEFINE_FUNCTION DEVICES_MaintainConnection()
{
    STACK_VAR INTEGER i 
    
    //Cycle through all devices and return the index that matches DPS 
    for(i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( DEVICES[i].id )
	{
	    if ( ![DEVICES[i].vDevice, DATA_INITIALIZED] ) 
	    { 
		SEND_COMMAND 0, "DEVICES[i].name,' OFFLINE'"
		DEVICES_Connect(i)
	    }
	}
    }
}


//Get device Index from DEV
DEFINE_FUNCTION integer DEVICES_getDeviceIDFromDev( dev Device )
{
    STACK_VAR INTEGER i 
    
    //Cycle through all devices and return the index that matches DPS 
    for(i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( DEVICES[i].id )
	{
	    if ( DEVICES[i].vDevice == Device ) 
	    { 
		return i
		break
	    }
	}
    }
    
    //Return 0 if not found
    return 0
}

//Set Duet / Netlinx Module settings and attempt connection
DEFINE_FUNCTION DEVICES_Connect(integer deviceIndex)
{
    //If Device is registered in the system
    if ( deviceIndex > 0 )
    {
	SEND_STRING 0, "'Connecting ',DEVICES[deviceIndex].name"
	
	if ( !FIND_STRING( DEVICES[deviceIndex].IPAddress, 'null', 1 ) )
	{			    
	    //Set IP Address of the device within the Duet/NetLinx Module
	    SEND_COMMAND DEVICES[deviceIndex].vDevice, "'PROPERTY-IP_Address,',DEVICES[deviceIndex].IPAddress"
	}
	ELSE IF ( LENGTH_STRING ( DEVICES[deviceIndex].BaudRate ) )
	{
	    //Set IP Address of the device within the Duet/NetLinx Module
	    SEND_COMMAND DEVICES[deviceIndex].vDevice, "'PROPERTY-Baud,',DEVICES[deviceIndex].Baudrate"
	}
	ELSE IF ( !FIND_STRING( DEVICES[deviceIndex].Password, 'null', 1 ) )
	{
	    //Send Password
	    SEND_COMMAND DEVICES[deviceIndex].vDevice, "'PROPERTY-Password,',DEVICES[deviceIndex].Password"
	}
	
	SYSTEM_addSplashScreenText("'Attempting to Connect to ',DEVICES[deviceIndex].Name")
	
	//Set the REINT Command / Attempt connection
	SEND_COMMAND DEVICES[deviceIndex].vDevice, "'REINIT'"
    }
}

//Checks that all devices are connected to the system
DEFINE_FUNCTION INTEGER DEVICES_isAllConnected()
{
    STACK_VAR INTEGER result, i 
    
    //Set result to on
    ON[result]
    
    //Cycle through all the devices to see if the data has been initialised
    for ( i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( DEVICES[i].id )
	{
	    if ( ![DEVICES[i].vDevice, DATA_INITIALIZED] )
	    {
		OFF[result]
		break
	    }
	}
    }

    //return result
    return result
}

DEFINE_FUNCTION DEVICES_register( CHAR name[64],
				    CHAR manufacturer[64],
				    CHAR model[64],
				    CHAR serialNumber[64],
				    CHAR IPAddress[64],
				    CHAR BaudRate[64],
				    CHAR Password[64],
				    DEV vDevice,
				    DEV pDevice
				    )
{
    STACK_VAR _devices device
    
    device.Name			= name
    device.Manufacturer		= manufacturer
    device.Model		= model
    device.SerialNumber		= serialNumber
    device.IPAddress		= IPAddress
    device.BaudRate		= BaudRate
    device.Password		= Password
    device.vDevice		= vDevice
    device.pDevice		= pDevice
    
    //Add device to device list
    DEVICES_Add( device )
}

//Adds device to Device List
DEFINE_FUNCTION INTEGER DEVICES_Add(_DEVICES device )
{
    STACK_VAR INTEGER i 
    
    //Cycle through all devices until find a spare slot
    for (i=1; i<=LENGTH_DEVICES; i++)
    {
	if ( !DEVICES[i].Id )
	{
	    //Add device into spare slot
	    device.id = i
	    DEVICES[i] = device
	    
	    //Returns deviceId
	    return i
	}
    }
    
    //Return 0 if there is no space left
    return 0
}

DEFINE_FUNCTION DEVICES_pictureMuteTimeOut( _Command parser )
{
    STACK_VAR char ref[16]
    STACK_VAR integer response
    STACK_VAR integer callIndex
    STACK_VAR integer deviceIndex
    
    //Get id 
    ref = GetAttrValue( 'ref',parser ) 
    
    //If Shutdown Response
    IF ( FIND_STRING ( ref, 'PicMute-', 1 ) )
    {
	//remove 'siteend'
	REMOVE_STRING ( ref, 'PicMute-', 1 )
	
	//Get Response
	response = ATOI ( GetAttrValue ( 'res', parser ) )
	
	//get index from response
	deviceIndex = ATOI ( ref )
	
	Switch ( response )
	{ 
	    //Leave projector on 
	    CASE 1: 
	    {
		SEND_STRING 0, 'Ok'
		ct[deviceIndex] = 0
	    }
	    //Power Off Projector Now
	    CASE 2: 
	    {
		SEND_STRING 0, 'Cancel'
		ct[deviceIndex] = ( PIC_MUTE_TIMEOUT + PIC_MUTE_MESSAGE_TIMEOUT )
	    }
	}
    }
}


//Evaluates the channels (Main Line every second) 
DEFINE_FUNCTION DEVICES_evaluateChannels()
{
    STACK_VAR integer i 
    LOCAL_VAR integer user[LENGTH_DEVICES]
    STACK_VAR integer dialogId
    
    FOR ( i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( ct[i] < PIC_MUTE_TIMEOUT )
	{
	    OFF[user[i]]
	}
	
	//Check Picture Mute
	if ( [DEVICES[i].vDevice, PIC_MUTE_ON] AND [DEVICES[i].vDevice, POWER_FB] )
	{
	    ct[i]++
	    
	    if ( ct[i] >= ( PIC_MUTE_TIMEOUT + PIC_MUTE_MESSAGE_TIMEOUT ) )
	    {
		//Power off Projector
		PULSE[ DEVICES[i].vDevice, PWR_OFF ]
		
		//Reset Timer
		ct[i] = 0
		
		//Reset User flag
		OFF[user[i]]
		
		//Remove Dialog
		dialogId = Dialog_getIdfromRef( "'PicMute-',ITOA( i )" )
		Dialog_Remove(dialogId)
	    }
	    
	    //Show Warning After an hour of picture mute
	    else if ( ct[i] > PIC_MUTE_TIMEOUT AND !user[i] )
	    {
		SYSTEM_sendCommand ( vdvSystem, "'DialogOkCancel-ref=PicMute-',ITOA( i ),
				    '&title=Picture Mute Timout',
				    '&message=Picture mute has been on for too long. ',$0A,$0D,$0A,$0D,
				    DEVICES[i].Name,' will power off automatically.',
				    '&res1=Keep On&res2=Power Off&norepeat=1'")
		//User Warned Flag
		ON[user[i]]
	    }
	}
	ELSE
	{
	    //Reset counter if picture is unmuted
	    ct[i] = 0
	}
    }
}

DEFINE_START

SYSTEM_addSplashScreenText('Starting System...')

DEFINE_EVENT 

//Monitors all the data events on all the Devices
DATA_EVENT [vdvDevices]
{
    //When the Duet Module/Virtual Device comes online
    ONLINE:
    {

    }
    COMMAND:
    {
	//If input command found
	IF ( FIND_STRING ( DATA.TEXT, 'INPUT-', 1 ) )
	{
	    STACK_VAR INTEGER index
	    
	    //Get Device index from the DATA.DEVICE
	    index = DEVICES_getDeviceIDFromDev( DATA.DEVICE )
	    
	    //Remove INPUT-
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    
	    //Set Input field on Devices Structure
	    DEVICES[ index ].input = DATA.TEXT
	}
    }
}

//Listen for Volume Level off amplifier
LEVEL_EVENT [ vdvAmplifier, VOL_LVL ]
{
    SEND_LEVEL dvTP, 1, LEVEL.VALUE
}

//Listen for Device commands
BUTTON_EVENT[ dvTP, UIBtns ]
{
    RELEASE:
    {
	STACK_VAR svButton
	
	svButton = GET_LAST(UIBtns)
	
	SWITCH ( svButton )
	{
	    CASE 71:
	    CASE 72:
	    CASE 73:
	    {
		if ( [ vdvDevices[svButton - 70], POWER_FB ] )
		{
		    PULSE[ vdvDevices[svButton - 70], PWR_OFF ]
		}
		ELSE
		{
		    PULSE[ vdvDevices[svButton - 70], PWR_ON ]
		}
	    }
	    
	    CASE 77:
	    CASE 78:
	    CASE 79:
	    {
		PULSE[ vdvDevices[svButton - 76], PIC_MUTE ]
	    }
	}
    }
}


DEFINE_PROGRAM

WAIT 10
{
    DEVICES_evaluateChannels()
    DEVICES_MaintainConnection()
}