PROGRAM_NAME='RMSMain'

(***********************************************************)
(*              CONSTANT DEFINITIONS GO BELOW              *)
(***********************************************************)
DEFINE_CONSTANT

//Max String/Enum Param Length
RMS_MAX_PARAM_LEN 	  = 100

//TimeLine

RMS_DEVICE_LAMP[]            = 'Lamp Hours'
RMS_DEVICE_STATUS_ZERO       = 0


//TimeLine
CheckStatusTL	= 1
PingTimeLine 	= 2


(***********************************************************)
(*              VARIABLE DEFINITIONS GO BELOW              *)
(***********************************************************)
DEFINE_VARIABLE

///////////////////////////////////////////////////////
// Devices
///////////////////////////////////////////////////////
// i-ConnectLinx paramater storage
VOLATILE SLONG   asnNumberLevelArgValues[3]
VOLATILE CHAR    acStringEnumArgValues[3][50]

VOLATILE INTEGER nRMSTCMicMute
VOLATILE INTEGER nRMSInCall
VOLATILE INTEGER nRMSPresent
VOLATILE INTEGER nRMSCamera
VOLATILE INTEGER nRMSStandby
VOLATILE INTEGER nRMSConnection
VOLATILE INTEGER nVOL_LEVEL
VOLATILE INTEGER nMUTE_STATUS
VOLATILE INTEGER nGW_ACTIVE

VOLATILE INTEGER PROJ_STATUS
VOLATILE INTEGER PROJ_PICTURE_MUTE
VOLATILE INTEGER PROJ_INITIALISED
VOLATILE INTEGER PROJ_CONNECTED
VOLATILE INTEGER LampTime

// dvTP
VOLATILE INTEGER    nRMSTouchPanelSystemStatus  // System Status

VOLATILE INTEGER    nDockingStationPresent 

//dvTP
VOLATILE INTEGER    nRMSDockStatus //Docking Status

// dvTP
VOLATILE SLONG      slRMSTouchPanelBatteryLevel  // Battery Level

//Devices

VOLATILE SLONG      slRMSProjectorLampHours  // Lamp Hours


// TimeLineVariable
VOLATILE LONG TimeArrayCS[100]
VOLATILE LONG PingTimeLineArray[2] = { 20000, 10000 }  

(***********************************************************)
(*             SUBROUTINE DEFINITIONS GO BELOW             *)
(***********************************************************)

(***************************************)
(* Call Name: RMSDevMonSetParamCallback*)
(* Function:  Reset parameters         *)
(* Param:     DPS, Name, Value         *)
(* Return:    None                     *)
(* Note:      Caller must define this  *)
(***************************************)
DEFINE_FUNCTION RMSDevMonSetParamCallback(DEV dvTPMaster, CHAR cName[], CHAR cValue[])
{
}

(***************************************)
(* Call Name: RMSDevMonRegisterCallback*)
(* Function:  time to register devices *)
(* Param:     None                     *)
(* Return:    None                     *)
(* Note:      Caller must define this  *)
(***************************************)
DEFINE_FUNCTION RMSDevMonRegisterCallback()
{
    STACK_VAR INTEGER i 

    RMSNetLinxDeviceOnline(dvTP,"'User Interface'")
   
    //System Parameter Registration____________________________________________
    
    RMSRegisterDeviceIndexParam(dvSystem,'Active Gateway',
      1,RMS_COMP_GREATER_THAN,RMS_STAT_CONTROLSYSTEM_ERR,
      FALSE,0,
      RMS_PARAM_SET,nGW_ACTIVE,
      'None|Primary|Secondary') 
    
    //End of System Parameter__________________________________________________
    
    //Codec Parameter Registration_____________________________________________
    
    RMSRegisterDeviceIndexParam(dvCodec,'Mic Mute Status',
      0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
      FALSE,0,
      RMS_PARAM_SET,nRMSTCMicMute,
      'UnMuted|Muted')
      
    RMSRegisterDeviceIndexParam(dvCodec,'Call Status',
      0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
      FALSE,0,
      RMS_PARAM_SET,nRMSInCall,
      'Idle|In Call')
      
    RMSRegisterDeviceIndexParam(dvCodec,'Presenting Status',
      0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
      FALSE,0,
      RMS_PARAM_SET,nRMSPresent,
      'Not Presenting|Presenting')
      
    RMSRegisterDeviceIndexParam(dvCodec,'Camera Status',
      1,RMS_COMP_LESS_THAN,RMS_STAT_CONTROLSYSTEM_ERR,
      FALSE,0,
      RMS_PARAM_SET,nRMSCamera,
      'Not Connected|Connected') 
      
    
    RMSRegisterDeviceIndexParam(dvCodec,'Standby Status',
      0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
      FALSE,0,
      RMS_PARAM_SET,nRMSStandby,
      'Standby|On') 
    
    //Register Device Parameter
    RMSRegisterDeviceNumberParamWithUnits(dvCodec,
	'Volume Level','',
	0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
	FALSE,0,
	RMS_PARAM_SET,nVOL_LEVEL,
	0,0)
	
    RMSRegisterDeviceIndexParam(dvCodec,'Mute State',
	0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
	FALSE,0,
	RMS_PARAM_SET,nMUTE_STATUS,
	'UnMuted|Muted') 
	
    //End Of Codec Parameter Registration______________________________________
    
    //Projector Parameter Registration_________________________________________
    
    FOR ( i=1; i<=LENGTH_DEVICES; i++ )
    {
	if ( DEVICES[i].ID )
	{
	    RMSSetDeviceInfo(Devices[i].pDevice, Devices[i].name, Devices[i].manufacturer, Devices[i].Model)
	    
	    if ( ( Devices[i].pDevice.port > 5 ) AND ( Devices[i].pDevice.port < 9 ) )
	    {
		//Register Power Status
		RMSRegisterDeviceIndexParam(
		    Devices[i].pDevice, 		//Logical Device
		    'Power Status', 	  	//Parameter Name
		    0, 				//Threshold
		    RMS_COMP_NONE,  		//Threshold Compare
		    RMS_STAT_EQUIPMENT_USAGE, 	//Threshold Status
		    FALSE,				//Can be Reset
		    0,				//Reset Value
		    RMS_PARAM_SET,			//Initial Operation
		    0,				//Initial Value		
		    'Off|On|Warming|Cooling')
		
		RMSRegisterDeviceIndexParam(Devices[i].pDevice,'Picture Mute',
		    0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
		    FALSE,0,
		    RMS_PARAM_SET,0,
		    'Off (Displaying)|On (Not Displaying)') 
		    
		RMSRegisterDeviceIndexParam(Devices[i].pDevice,'Input',
		    0,RMS_COMP_NONE,RMS_STAT_EQUIPMENT_USAGE,
		    FALSE,0,
		    RMS_PARAM_SET,0,
		    'VGA 1|VGA 2|HDMI|Composite') 
		
		RMSRegisterStockNumberParam(
				Devices[i].pDevice, 
				RMS_DEVICE_LAMP, 
				RMS_UNIT_HOURS, 
				RMS_TRACK_CHANGES, 
				2500, 
				RMS_COMP_GREATER_THAN, 
				RMS_STAT_MAINTENANCE, 
				RMS_PARAM_CANNOT_RESET, 
				RMS_DEVICE_STATUS_ZERO, 
				RMS_PARAM_SET, 
				0, 
				0, 
				0
			    )
	    }
	    //Amplifier Parameters
	    Else if ( ( DEVICES[i].pDevice.number == 5001 ) )
	    {
		//Register Device Parameter
		RMSRegisterDeviceNumberParamWithUnits(Devices[i].pDevice,
		    'Volume Level','',
		    189,RMS_COMP_LESS_THAN,RMS_STAT_CONTROLSYSTEM_ERR,
		    FALSE,0,
		    RMS_PARAM_SET,0,
		    0,0)
		    
		RMSRegisterDeviceIndexParam(Devices[i].pDevice,'Input',
		    0,RMS_COMP_GREATER_THAN,RMS_STAT_CONTROLSYSTEM_ERR,
		    FALSE,0,
		    RMS_PARAM_SET,nRMSCamera,
		    'A (System)|B|C|D') 
	    }
	}
    }
}

// Gateway Changes
DEFINE_FUNCTION RMSSetActiveGateway(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nGW_ACTIVE <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvSystem,'Active Gateway',nValue)
  nGW_ACTIVE = nValue
  bInit = TRUE
}

//Codec Parameter Changes
DEFINE_FUNCTION RMSSetMicMuteStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSTCMicMute <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Mic Mute Status',nValue)
  nRMSTCMicMute = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetCallStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSInCall <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Call Status',nValue)
  nRMSInCall = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetPowerStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSStandby <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec, 'Standby Status',nValue)
  nRMSStandby = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetPresentingStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSPresent <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Presenting Status',nValue)
  nRMSPresent = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetCameraStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSCamera <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Camera Status',nValue)
  nRMSCamera = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetStandbyStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSStandby <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Standby Status',nValue)
  nRMSStandby = nValue
  bInit = TRUE
}

DEFINE_FUNCTION RMSSetAMXConnectionStatus(INTEGER nValue)
LOCAL_VAR CHAR bInit
{
  IF (nRMSConnection <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvCodec,'Connected to AMX',nValue)
  nRMSConnection = nValue
  bInit = TRUE
}

//Set Volume Level on Channel
DEFINE_FUNCTION RMSSetVolumeLevel(INTEGER chlevel)
{
    RMSChangeIndexParam(dvCodec,
	'Volume Level',chlevel)
}

//Set Volume Level on Channel
DEFINE_FUNCTION RMSSetMuteStatus(INTEGER func)
{
    RMSChangeIndexParam(dvCodec,
	"'Mute State'",func)
}


DEFINE_FUNCTION RMSSetTouchPanelSystemStatus(INTEGER nValue)
LOCAL_VAR
CHAR bInit
{
  IF (nRMSTouchPanelSystemStatus <> nValue || bInit = FALSE)
    RMSChangeIndexParam(dvTP,'System Status',nValue)
  nRMSTouchPanelSystemStatus = nValue
  bInit = TRUE
}


DEFINE_FUNCTION fnCheckStatus() //Sets Up time line to check the status of the system
{
    TimeArrayCS[1] = 1000
    TIMELINE_CREATE(CheckStatusTL, TimeArrayCS, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT)
}

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                  THE EVENTS GOES BELOW                  *)
(***********************************************************)
DEFINE_EVENT



(*******************************************)
(* DATA: RMS Engine                        *)
(*******************************************)
DATA_EVENT[vdvRMSEngine]
{
    ONLINE:
    {
	WAIT 450 'RMSDevice Timeout'
	{
	    SEND_STRING 0, "'RMS Timeout'"
	    
	    RMSDevMonRegisterCallback()
	    
	    //Get Values
	    SEND_COMMAND vdvDevices, "'?LAMPTIME'"
	}
    }
    
    STRING:
    {
	STACK_VAR
	CHAR    cTemp[1000]
	CHAR    cTrash[10]
	
	IF (FIND_STRING(DATA.TEXT, 'MESG-',1))
	{
	    cTemp = DATA.Text
	    cTrash = REMOVE_STRING(cTemp,',',1)
	    SYSTEM_sendCommand ( vdvSystem, "'RMSReply-',cTemp" )
	}
    }
}

(*******************************************)
(* DATA: Touch Panel                       *)
(*******************************************)
DATA_EVENT [dvTP]
{
    ONLINE:
    {  
	RMSNetLinxDeviceOnline(dvTP,"'User Interface'")
    }
    OFFLINE:
    { 
	RMSNetLinxDeviceOffline(dvTP)
    }
}


//Pings all the registered devices within the system
TIMELINE_EVENT [PingTimeLine]
{
    Switch ( TIMELINE.SEQUENCE )
    {
	//Long Term Pings every 20 Minutes
	CASE 2:  
	{
	    SEND_COMMAND vdvDevices, "'?LAMPTIME'"
	}
    }
}


DATA_EVENT[dvTP]
{    
    STRING:
    {
	SELECT
	{
	   ACTIVE(DATA.TEXT = 'RMSHelp.Request-')        : {}  // ABORT do nothing
	   ACTIVE(DATA.TEXT = 'RMSReport.Fault-')     : {}  // ABORT do nothing              
	   ACTIVE(LEFT_STRING(DATA.TEXT, 21) = 'RMSHelp.Request-ABORT')        : {}  // ABORT do nothing
	   ACTIVE(LEFT_STRING(DATA.TEXT, 21) = 'RMSReport.Fault-ABORT')     : {}  // ABORT do nothing       
    
	   ACTIVE(LEFT_STRING(DATA.TEXT, 16) = 'RMSHelp.Request-')        :
	   {
	       // Get Help Request Message Text
	       SEND_COMMAND vdvRMSEngine,"'HELP-',RMSMidString(DATA.TEXT,17,-1)"       
	   }  
	   ACTIVE(LEFT_STRING(DATA.TEXT, 16) = 'RMSReport.Fault-')     : 
	   {
	       // Get Service Request Message Text
	       SEND_COMMAND vdvRMSEngine,"'MAINT-',RMSMidString(DATA.TEXT,17,-1)"	   
	   } 
	}
    }
}



LEVEL_EVENT [vdvCodec, VOL_LVL]
{
    RMSSetVolumeLevel(LEVEL.VALUE)
}

LEVEL_EVENT [vdvAmplifier, VOL_LVL]
{
    RMSChangeIndexParam(dvAmplifier,'Volume Level',LEVEL.VALUE)
}

CHANNEL_EVENT [vdvCodec, 0]
{	
    ON:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    //Mic Mute Status
	    CASE 146: RMSSetMicMuteStatus([CHANNEL.DEVICE, 146])
	    //Presenting Status
	    CASE 309: RMSSetPresentingStatus([CHANNEL.DEVICE, 309])
	    //Camera Status
	    CASE 304: RMSSetCameraStatus([CHANNEL.DEVICE, 304])
	    //Connection Status
	    CASE 251: RMSSetAMXConnectionStatus([CHANNEL.DEVICE, 251])
	    //Volume Mute Status
	    CASE VOL_MUTE_FB: RMSSetMuteStatus([CHANNEL.DEVICE, VOL_MUTE_FB])
	    //InCall Status
	    CASE 238: RMSSetCallStatus([CHANNEL.DEVICE, 238])
	    //Power Statut
	    CASE 255: RMSSetPowerStatus([CHANNEL.DEVICE, 255])
	}
    }
    OFF:
    {
	SWITCH ( CHANNEL.CHANNEL )
	{
	    //Mic Mute Status
	    CASE 146: RMSSetMicMuteStatus([CHANNEL.DEVICE, 146])
	    //Presenting Status
	    CASE 309: RMSSetPresentingStatus([CHANNEL.DEVICE, 309])
	    //Camera Status
	    CASE 304: RMSSetCameraStatus([CHANNEL.DEVICE, 304])
	    //Connection Status
	    CASE 251: RMSSetAMXConnectionStatus([CHANNEL.DEVICE, 251])
	    //Volume Mute Status
	    CASE VOL_MUTE_FB: RMSSetMuteStatus([CHANNEL.DEVICE, VOL_MUTE_FB])
	    //InCall Mute Status
	    CASE 238: RMSSetCallStatus([CHANNEL.DEVICE,238])
	    //Power Statut
	    CASE 255: RMSSetPowerStatus([CHANNEL.DEVICE, 255])
	}
    }	
}


//SNAPI CHANNEL EVENTS
CHANNEL_EVENT [vdvDevices, 0]
{
    ON:
    {
	STACK_VAR INTEGER Index
	
	index = DEVICES_getDeviceIDFromDev( CHANNEL.DEVICE )
	
	SWITCH ( CHANNEL.CHANNEL )
	{
	    CASE POWER_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',1)
	    }
	    CASE DATA_INITIALIZED:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Data Initialised',1)
	    }
	    CASE LAMP_COOLING_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',3)
	    }
	    CASE LAMP_WARMING_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',2)
	    }
	    CASE PIC_MUTE_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Picture Mute',1)
	    }	    
	}
    }
    OFF:
    {
	STACK_VAR INTEGER Index
	
	index = DEVICES_getDeviceIDFromDev( CHANNEL.DEVICE )
	
	SWITCH ( CHANNEL.CHANNEL )
	{
	    CASE POWER_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',0)
	    }
	    CASE DATA_INITIALIZED:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Data Initialised',0)
	    }
	    CASE LAMP_COOLING_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',0)
	    }
	    CASE LAMP_WARMING_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Power Status',1)
	    }
	    CASE PIC_MUTE_FB:
	    {
		RMSChangeIndexParam(Devices[index].pDevice,'Picture Mute',0)
	    }
	}
    }
}

DATA_EVENT [vdvDevices]
{
    COMMAND:
    {
	STACK_VAR INTEGER Index
	
	index = DEVICES_getDeviceIDFromDev( DATA.DEVICE )
	
	if ( FIND_STRING( DATA.TEXT, 'LAMPTIME-', 1) ) {
	    
	    REMOVE_STRING ( DATA.TEXT, '-', 1 )
	    LampTime = ATOI ( DATA.TEXT )
	    
	    RMSChangeNumberParam(Devices[index].pDevice, RMS_DEVICE_LAMP, RMS_PARAM_SET, LampTime)
	}
	
	if( find_string(  DATA.TEXT, 'INPUT-', 1 ) )
	{
	    remove_string( DATA.TEXT, '-', 1 )
	    if (find_string(DATA.TEXT,'VGA,1',1)) 
	    { 
		RMSChangeIndexParam(Devices[index].pDevice,'Input',0)
	    }
	    else if (find_string(DATA.TEXT,'VGA,2',1)) 
	    {  
		RMSChangeIndexParam(Devices[index].pDevice,'Input',1)
	    }
	    else if (find_string(DATA.TEXT,'HDMI,1',1)) 
	    { 
		RMSChangeIndexParam(Devices[index].pDevice,'Input',2)
	    }
	    else if (find_string(DATA.TEXT,'COMPOSITE,1',1)) 
	    { 
		RMSChangeIndexParam(Devices[index].pDevice,'Input',3)
	    }
	    
	    if ( DATA.DEVICE == vdvAmplifier )
	    {
		if (find_string(DATA.TEXT,'A',1)) 
		{ 
		    RMSChangeIndexParam(dvAmplifier,'Input',0)
		}
		else if (find_string(DATA.TEXT,'B',1)) 
		{  
		    RMSChangeIndexParam(dvAmplifier,'Input',1)
		}
		else if (find_string(DATA.TEXT,'C',1)) 
		{ 
		    RMSChangeIndexParam(dvAmplifier,'Input',2)
		}
		else if (find_string(DATA.TEXT,'D',1)) 
		{ 
		    RMSChangeIndexParam(dvAmplifier,'Input',3)
		}
	    }
	}
    }
}


(***********************************************************)
(*              THE ACTUAL PROGRAM GOES BELOW              *)
(***********************************************************)
DEFINE_PROGRAM

WAIT 50 {

    //See if all devices are connected and then connect to RMS
    if ( DEVICES_isAllConnected() )
    {
	if ( ![vdvRMSEngine, 250] )
	{
	    CANCEL_WAIT 'RMSDevice Timeout'
	    
	    RMSDevMonRegisterCallback()
	    
	    //Get Values
	    SEND_COMMAND vdvDevices, "'?LAMPTIME'"
	}
    }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*         DO NOT PUT ANY CODE BELOW THIS COMMENT          *)
(***********************************************************)
