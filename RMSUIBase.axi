(*********************************************************************)
(*                                                                   *)
(*             AMX Resource Management Suite  (3.2.31)               *)
(*                                                                   *)
(*********************************************************************)
/*
 *  Legal Notice :
 * 
 *     Copyright, AMX LLC, 2008
 *
 *     Private, proprietary information, the sole property of AMX LLC.  The
 *     contents, ideas, and concepts expressed herein are not to be disclosed
 *     except within the confines of a confidential relationship and only
 *     then on a need to know basis.
 * 
 *     Any entity in possession of this AMX Software shall not, and shall not
 *     permit any other person to, disclose, display, loan, publish, transfer
 *     (whether by sale, assignment, exchange, gift, operation of law or
 *     otherwise), license, sublicense, copy, or otherwise disseminate this
 *     AMX Software.
 * 
 *     This AMX Software is owned by AMX and is protected by United States
 *     copyright laws, patent laws, international treaty provisions, and/or
 *     state of Texas trade secret laws.
 * 
 *     Portions of this AMX Software may, from time to time, include
 *     pre-release code and such code may not be at the level of performance,
 *     compatibility and functionality of the final code. The pre-release code
 *     may not operate correctly and may be substantially modified prior to
 *     final release or certain features may not be generally released. AMX is
 *     not obligated to make or support any pre-release code. All pre-release
 *     code is provided "as is" with no warranties.
 * 
 *     This AMX Software is provided with restricted rights. Use, duplication,
 *     or disclosure by the Government is subject to restrictions as set forth
 *     in subparagraph (1)(ii) of The Rights in Technical Data and Computer
 *     Software clause at DFARS 252.227-7013 or subparagraphs (1) and (2) of
 *     the Commercial Computer Software Restricted Rights at 48 CFR 52.227-19,
 *     as applicable.
*/

PROGRAM_NAME='RMSUIBase'
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 1                                *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

// This file is the implmentation of the RMSUI
// It can be used for main and welcome panels or welcome
// panels only.
//
// The reason there is not two modules, one for main and one for
// welcome, is that is wastes memory.  A set of todays appointments
// must be maintained for both panels; two modules would create
// two copies of these appointments.
//
// To compile only the welcome panel code, define this symbol
//#DEFINE RMS_UI_WELCOME_CODE_ONLY

// This file can also be used for Help functions only.  This
// includes help and maintenece UI's, help response and Help Desk
// questions.
//
// To compile only the help panel code, define this symbol
//#DEFINE RMS_UI_HELP_CODE_ONLY

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Version For Code
CHAR __RMS_UI_BASE_NAME__[]      = 'RMSUIBase'
CHAR __RMS_UI_BASE_VERSION__[]   = '3.2.31'

// Stuff
RMS_MAX_APPTS                = 40 
RMS_TIME_SLOT_SPAN_MIN       = 15 
RMS_MAX_APPTS_SLOTS          = 96 
RMS_MAX_APPTS_DISPLAY_SLOTS  = 96 

// G4 Target Build for Dynamic Images
// Minor build number 12 correct dynamic image support
RMS_G4_TARGET_MINOR          = 12

// ConnectLinx Info
CL_MAX_NAME_LEN              = 50
CL_MAX_UUID_LEN              = 40
CL_MAX_HELP_LEN              = 100

// Help response message length
RMS_MAX_LINE_SIZE            = 40

// Appointment Field Enumerations
RMS_APPT_FIELD_ALL = 0
RMS_APPT_FIELD_START_DATE = 1
RMS_APPT_FIELD_START_TIME = 2
RMS_APPT_FIELD_DURATION = 3
RMS_APPT_FIELD_SUBJECT = 4
RMS_APPT_FIELD_MESSAGE = 5

//
// Required Touch Panels Pages
//
RMSRoomMain[]                = 'Main'
RMSRoomPage[]                = 'rmsRoomPage'
RMSWelcomePage[]             = 'rmsWelcomePage'

//
// Required Touch Panels Popup Pages
//
RMSPopupDoNotDisturb[]       = 'rmsDoNotDisturb'
RMSPopupMtgInfo[]            = 'rmsMeetingInfo'
RMSPopupExtendWarning[]      = 'rmsMeetingExtendWarning'
RMSPopupEndWarning[]         = 'rmsMeetingEndWarning'
RMSPopupHelpResponse[]       = 'rmsHelpResponse'
RMSPopupHelpQuestion[]       = 'rmsHelpQuestion'
RMSPopupDoorbell[]           = 'rmsDoorbell'
RMSPopupMtgDoesNotExist[]    = 'rmsMeetingDoesNotExist'
RMSPopupMtgDetails[]         = 'rmsMeetingDetails'
RMSPopupMtgRequest[]         = 'rmsMeetingRequest'
RMSPopupHelpRequest[]        = 'rmsHelpRequest'
RMSPopupServiceRequest[]     = 'rmsServiceRequest'
RMSPopupServerOffline[]      = 'rmsServerOffline'

//meeting request failed has different functionality on ok and has cancel button to do what ok does in other messages
RMSPopupMtgRequestFailed[]   = 'rmsMeetingRequestFailed' 


RMSPopupMessage[]	   = 'rmsMessage'
RMSMsgMtgRequestPending[]  = 'Please Wait...|Requesting Meeting Reservation'  
RMSMsgMtgRequestConfirmed[]= 'Meeting Reservation|Confirmed' 
RMSMsgMtgExtendPending[]   = 'Please Wait...|Requesting Meeting Extension' 
RMSMsgMtgExtendConfirmed[] = 'Meeting Extension|Confirmed' 
RMSMsgMtgExtendFailed[]    = 'Meeting Extension|Unsuccessful' 
RMSMsgMtgEndNowPending[]   = 'Please Wait...|Requesting Meeting to End Now' 
RMSMsgMtgEndNowConfirmed[] = 'Meeting Ended|Successfully' 
RMSMsgMtgEndNowFailed[]    = 'Meeting Request|to End Now Failed' 
RMSMsgHelpRequestSubmitted[]    = 'Help Request|Submitted' 
RMSMsgServiceRequestSubmitted[] = 'Service Request|Submitted' 

//
// Required Welcome Image Buttons
//
RMSDynImgWelcomeImage[]      = 'rmsWelcomeImage'
RMSDynImgSelWelcomeImage[]   = 'rmsSelectedWelcomeImage'


RMSMessageIconNone = 0
RMSMessageIconCheck = 1
RMSMessageIconX = 2

RMSMessageTypeGeneral = 0
RMSMessageTypeConfirm = 1
RMSMessageTypePending = 2
RMSMessageTypeFailed = 3






(***********************************************************)
(*                   INCLUDE FILES GO BELOW                *)
(***********************************************************)
#DEFINE RMS_DEV_MON_DEFS_ONLY
#INCLUDE 'RMSCommon.axi'

#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
#INCLUDE 'TimeDateLib.axi'
#END_IF // RMS_UI_HELP_CODE_ONLY


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

// Appointment
// This is defined in RMSDeviceMonitor since it gets serialized
// and is decoded by other programs

// Appointment Collection
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
STRUCTURE _sRMSApptCollection
{
  // Sent In XML
  CHAR              cDate[12]
  INTEGER           nTotalAppointments
  CHAR              bMonthOnly
  CHAR              chMonthlyAppts[31]
  _sRMSAppointment  sAppts[RMS_MAX_APPTS]

  // Calculated After XML
  CHAR              chApptList[RMS_MAX_APPTS_SLOTS]

  // Receive Index - Used to receive appointments in correct order
  INTEGER           nReceiveIndex
}
#END_IF // RMS_UI_HELP_CODE_ONLY

// Calendar Structure
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
STRUCTURE _sRMSCalendar
{
  INTEGER    nSelCalendarIdx        //Current Selected Calendar Day Index
  INTEGER    nCalendarStartIdx      //Current Month Start Day Index
  INTEGER    nCalendarEndIdx        //Current Month End Day Index
  INTEGER    nNumDaysinMonth        //Current Month Total Days in Month
  INTEGER    nYear                  //Current Year
  INTEGER    nMonth                 //Current Month
  INTEGER    nDay                   //Current Day
  INTEGER    nDayofWeek             //Current Day of Week (1-7)
  INTEGER    nYearIdx               //Current Selected Year Index
  INTEGER    nBaseYear              //Current Year
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
STRUCTURE _sRMSNewAppointment
{
  INTEGER    nDurationIdx           // Duration Index
  CHAR       cSubject[100]          // Subject
  CHAR       cMessage[500]          // Message  
  CHAR       cStartDate[12]         // Start Date
  CHAR       cStartTime[12]         // Start Time
}
#END_IF // RMS_UI_HELP_CODE_ONLY

// Service Description
STRUCTURE _sCLSerDesc
{
  CHAR    cUUID[CL_MAX_UUID_LEN]
  CHAR    cName[CL_MAX_NAME_LEN]
  CHAR    cOwner[CL_MAX_HELP_LEN]
  CHAR    cLocation[CL_MAX_HELP_LEN]
  CHAR    cURL[CL_MAX_HELP_LEN]
  INTEGER nTimezoneID
  CHAR    cCLRoot[CL_MAX_NAME_LEN]
}

// Appointment Stats
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
STRUCTURE _sRMSApptStatistics
{
  INTEGER nCurrentApptIndex         // The appointment that is active right now
  INTEGER nMinutesTillEnd           // Minutes till this appointment ends

  INTEGER nNextApptIndex            // Next appointment to run (after active or next from now)
  INTEGER nMinutesTillNext          // Time till next appotinment

  INTEGER nFirstApptIndex           // First appointment of the day
  INTEGER nLastApptIndex            // Last appointment of the day
  INTEGER nApptsRemain              // Number of appts left today

  INTEGER nHistCurApptIndex         // History of nCurrentApptIndex
  INTEGER nHistNextApptIndex        // History of nNextApptIndex
  INTEGER nPrepApptIndex            // Appointment we are itchin to start (we posted the welcome message already)
  CHAR    bMeetingEndWarned         // On if Meeting End has been warned
  CHAR    bMeetingEndAcked          // On if Meeting End Warning has been acked
  LONG    lCurrentAppointmentID     // current appointment ID
}
#END_IF //RMS_UI_HELP_CODE_ONLY

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// Socket Info
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
VOLATILE CHAR                   cServerHostPort[100]
VOLATILE CHAR                   cServerWebRoot[100]
#END_IF // RMS_UI_HELP_CODE_ONLY

// Room Details
VOLATILE _sCLSerDesc            sRoomInfo
VOLATILE CHAR                   bDoNotDisturb 
 
// Appointment Checking
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
VOLATILE _sRMSApptStatistics     sCurrentApptStats
VOLATILE _sRMSApptCollection     sTodaysAppts
VOLATILE _sRMSApptCollection     sCalendarAppts
VOLATILE _sRMSCalendar           sCalendar
CONSTANT INTEGER                TL_APPT_CHECK = 2
CONSTANT LONG                   alTLApptCheckTimes[] = { 60000 } // Every 60 Sec
VOLATILE CHAR                   bUKDate
VOLATILE CHAR                   bMilitaryTime
#END_IF // RMS_UI_HELP_CODE_ONLY

// Help Desk Question
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
VOLATILE INTEGER                nHDQuestionID
VOLATILE INTEGER                nHDQuestionFlags
VOLATILE CHAR                   cHDQuestion[500]
VOLATILE CHAR                   cHDAnswers[4][60]
#END_IF // RMS_UI_WELCOME_CODE_ONLY

// Panel Inactivity Timelines
CONSTANT INTEGER                TL_SCH_VIEW_TIME_ROOM    = 3
CONSTANT INTEGER                TL_SCH_VIEW_TIME_WELCOME = 4
CONSTANT LONG                   alTLSchViewTimes[] = { 300000 }  // Every 5 minutes; if the panel is inactive, update the view schedule page
#END_IF // RMS_UI_HELP_CODE_ONLY

// Debug
#IF_NOT_DEFINED bRMSDebug
VOLATILE CHAR bRMSDebug = 0
#END_IF

// appointment data structure for creating a new meeting/appt
VOLATILE _sRMSNewAppointment    sRMSNewAppointment

// reserving touch panel device
VOLATILE DEV dvReserveTP[1]
VOLATILE DEV dvExtendTP[1]
VOLATILE DEV dvEndNowTP[1]



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// What Version?
SEND_STRING 0,"'Running ',__RMS_UI_NAME__,', v',__RMS_UI_VERSION__"


// Create a panel inactivity timeline
IF(!(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_ROOM)))
   TIMELINE_CREATE(TL_SCH_VIEW_TIME_ROOM,alTLSchViewTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
   
IF(!(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_WELCOME)))
   TIMELINE_CREATE(TL_SCH_VIEW_TIME_WELCOME,alTLSchViewTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)



(***********************************************************)
(*           SUBROUTINE DEFINITIONS GO BELOW               *)
(***********************************************************)


(**************************************)
(* Call Name: RMSSendBMFCommand       *)
(* Function:  Send BMF Command        *)
(* Params:    Panel Array, VT, Cmd    *)
(* Return:    1=G4, 0=G3              *)
(* Note:      Grab my wallet.  It's   *)
(*            the one that says...    *)
(**************************************)
DEFINE_FUNCTION CHAR RMSSendBMFCommand(DEV dvPanel[], INTEGER nVT, CHAR cText[])
{
    // G4 button picture command
    SEND_COMMAND dvPanel,"'^BMF-',ITOA(nVT),',0,',cText"
    RETURN 1;
}

DEFINE_FUNCTION CHAR RMSSendBMFCommandSingle(DEV dvPanel, INTEGER nVT, CHAR cText[])
{
    // G4 button picture command
    SEND_COMMAND dvPanel,"'^BMF-',ITOA(nVT),',0,',cText"
    RETURN 1;
}


(**************************************)
(* Call Name: RMSSendVarTextCommand   *)
(* Function:  Send Var Text Command   *)
(* Params:    Panel Array, VT, Cmd    *)
(* Return:    1=G4, 0=G3              *)
(**************************************)
DEFINE_FUNCTION CHAR RMSSendVarTextCommand(DEV dvPanel[], INTEGER nVT, CHAR cText[])
{ 
    IF(LENGTH_STRING(cText) > 1)
    {
		// Is the last character a space, if so remove it.
		WHILE(cText[LENGTH_STRING(cText)] = $20)
		{
			IF(LENGTH_STRING(cText) > 1)
			{
				SET_LENGTH_STRING(cText,LENGTH_STRING(cText) - 1)
			}
			ELSE
			{
				RETURN 0;
			}
		}
    }
  
    // G4 variable text command
    SEND_COMMAND dvPanel,"'^TXT-',ITOA(nVT),',0,',cText"
    RETURN 1;
}

DEFINE_FUNCTION CHAR RMSSendVarTextCommandSingle(DEV dvPanel, INTEGER nVT, CHAR cText[])
{ 
    IF(LENGTH_STRING(cText) > 1)
    {
		// Is the last character a space, if so remove it.
		WHILE(cText[LENGTH_STRING(cText)] = $20)
		{
			IF(LENGTH_STRING(cText) > 1)
			{
				SET_LENGTH_STRING(cText,LENGTH_STRING(cText) - 1)
			}
			ELSE
			{
				RETURN 0;
			}
		}
    }
  
    // G4 variable text command
    SEND_COMMAND dvPanel,"'^TXT-',ITOA(nVT),',0,',cText"
    RETURN 1;
}

(****************************************)
(* Call Name: RMSMessage                 *)
(* Function:  Set info to RMSMessage page *)
(* Params:    none                       *)
(****************************************)
DEFINE_FUNCTION CHAR RMSMessage(DEV panels[], CHAR message[], integer msgType, CHAR backpage[], CHAR extraText[])
{
	local_var char bmfText[255]
	local_var char bmfImage[128]
	local_var char popup[255]

	if (msgType == RMSMessageTypeGeneral)
	{
		bmfText = "'%T', message,'%CT White'"
		bmfImage = "'%SW1'"
	}
	else if (msgType == RMSMessageTypeConfirm)
	{
		bmfText = "'%T', message,'%CT Green'"
		bmfImage = "'%SW1%Pcheckmark'"
		
	}
	else if (msgType == RMSMessageTypePending)
	{
		bmfText = "'%T', message,'%CT Yellow'"
		bmfImage = "'%SW0'"
	}
	else if (msgType == RMSMessageTypeFailed)
	{
		bmfText = "'%T', message,'%CT Red'"
		bmfImage = "'%SW1%Pxmark'"
	}

	RMSSendBMFCommand(panels, nvtMessageBox[2], bmfText)
	RMSSendBMFCommand(panels, nvtMessageBox[3], bmfImage)

	if (extraText != '')
	{
		bmfText = "'%SW1'"
		RMSSendBMFCommand(panels, nvtMessageBox[1], bmfText)
		RMSSendVarTextCommand(panels, nvtMessageBox[1], extraText)
	}
	else
	{
		bmfText = "'%SW0'"
		RMSSendBMFCommand(panels, nvtMessageBox[1], bmfText)
	}


	SEND_COMMAND panels, "'@PPK-',RMSPopupMessage"
	if (backpage != '')
	{
		popup = "'@PPN-',RMSPopupMessage,';',backpage"
	}
	else
	{
		popup =  "'@PPN-',RMSPopupMessage"
	}
	
	SEND_COMMAND panels, "popup"
}


define_function char RMSMessageSingle(DEV panel, CHAR message[], integer msgType, CHAR backpage[], CHAR extraText[])
{
	local_var char bmfText[255]
	local_var char bmfImage[128]
	local_var char popup[255]

	if (msgType == RMSMessageTypeGeneral)
	{
		bmfText = "'%T', message,'%CT White'"
		bmfImage = "'%SW1'"
	}
	else if (msgType == RMSMessageTypeConfirm)
	{
		bmfText = "'%T', message,'%CT Green'"
		bmfImage = "'%SW1%Pcheckmark'"
		
	}
	else if (msgType == RMSMessageTypePending)
	{
		bmfText = "'%T', message,'%CT Yellow'"
		bmfImage = "'%SW0'"
	}
	else if (msgType == RMSMessageTypeFailed)
	{
		bmfText = "'%T', message,'%CT Red'"
		bmfImage = "'%SW1%Pxmark'"
	}

	RMSSendBMFCommandSingle(panel, nvtMessageBox[2], bmfText)
	RMSSendBMFCommandSingle(panel, nvtMessageBox[3], bmfImage)

	if (extraText != '')
	{
		bmfText = "'%SW1'"
		RMSSendBMFCommandSingle(panel, nvtMessageBox[1], bmfText)
		RMSSendVarTextCommandSingle(panel, nvtMessageBox[1], extraText)
	}
	else
	{
		bmfText = "'%SW0'"
		RMSSendBMFCommandSingle(panel, nvtMessageBox[1], bmfText)
	}


	SEND_COMMAND panel, "'@PPK-',RMSPopupMessage"
	if (backpage != '')
	{
		popup = "'@PPN-',RMSPopupMessage,';',backpage"
	}
	else
	{
		popup =  "'@PPN-',RMSPopupMessage"
	}
	
	SEND_COMMAND panel, "popup"
}


(**************************************)
(* Call Name: RMSGetEngineInfo        *)
(* Function:  Get RMS Engine mod info *)
(* Params:    none                    *)
(**************************************)
DEFINE_FUNCTION CHAR RMSGetEngineInfo()
{
    // get RMS engine module name and version
    SEND_COMMAND vdvRMSEngine,"'RMSENGINEINFO'"
}


(****************************************)
(* Call Name: RMSUpdateScheduleTimeView *)
(* Function:  sets the time view popup  *)
(* Params:    device array              *)
(****************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION CHAR RMSUpdateScheduleTimeView(DEV dvPanel[],CHAR cPage[])
{
  STACK_VAR INTEGER nLoop
  FOR(nLoop = MAX_LENGTH_ARRAY(RMSScheduleTimeView); nLoop > 0; nLoop--)
  {
     IF(TDLTimeCompare(TIME,RMSScheduleTimeView[nLoop][1]) >= 0)
     {
	SEND_COMMAND dvPanel, "'@PPK-',RMSPopupMessage"  //clear off any popups before updating scheduled view...
	SEND_COMMAND dvPanel,"RMSScheduleTimeView[nLoop][2],';',cPage"
        BREAK;
     }
  }
}
#END_IF //RMS_UI_HELP_CODE_ONLY


(**************************************)
(* Call Name: RMSSendSHOCommand       *)
(* Function:  Send SHO Command        *)
(* Params:    Panel Array, VT, State  *)
(* Return:    1=G4, 0=G3              *)
(**************************************)
DEFINE_FUNCTION CHAR RMSSendSHOCommand(DEV dvPanel[], INTEGER nVT, CHAR bState)
{
    // G4 button show/hide command
    SEND_COMMAND dvPanel,"'^SHO-',ITOA(nVT),',',ITOA(bState)"
    RETURN 1;
}


(******************************************************)
(* Call Name: RMSIncrementNewAppointmentDuration      *)
(* Function:  Increment new appoitnemnt duration      *)
(*                                                    *)
(* Return:    None                                    *)
(******************************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSIncrementNewAppointmentDuration(DEV dvPanel[])
{
    // increment duration index
    sRMSNewAppointment.nDurationIdx++

    // upper bounds checking
    IF(sRMSNewAppointment.nDurationIdx > MAX_LENGTH_ARRAY(RMSAppointmentDuration))
       sRMSNewAppointment.nDurationIdx = MAX_LENGTH_ARRAY(RMSAppointmentDuration)

    // update duration display on touch panel
    RMSDisplayNewAppointmentInfo(dvPanel, RMS_APPT_FIELD_DURATION)
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(******************************************************)
(* Call Name: RMSDecrementNewAppointmentDuration      *)
(* Function:  Decrement new appoitnemnt duration      *)
(*                                                    *)
(* Return:    None                                    *)
(******************************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSDecrementNewAppointmentDuration(DEV dvPanel[])
{
    // decrement duration index
    IF(sRMSNewAppointment.nDurationIdx > 1)
      sRMSNewAppointment.nDurationIdx--

    // lower bounds checking
    IF(sRMSNewAppointment.nDurationIdx <= 0)
       sRMSNewAppointment.nDurationIdx = 1

    // update duration display on touch panel
    RMSDisplayNewAppointmentInfo(dvPanel, RMS_APPT_FIELD_DURATION)
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(********************************************)
(* Call Name: RMSDisplayNewAppointmentInfo  *)
(* Function:  Display New Appointment Info  *)
(* Params:    Room Info                     *)
(* Return:    None                          *)
(********************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSDisplayNewAppointmentInfo(DEV dvPanel[], INTEGER nIndex)
{
   IF(nIndex = RMS_APPT_FIELD_ALL || nIndex = RMS_APPT_FIELD_START_DATE) 
     RMSSendVarTextCommand(dvPanel, nvtNewAppointment[1], TDLLocalizedDate(sRMSNewAppointment.cStartDate,bUKDate))
   
   IF(nIndex = RMS_APPT_FIELD_ALL || nIndex = RMS_APPT_FIELD_START_TIME) 
     RMSSendVarTextCommand(dvPanel, nvtNewAppointment[2], TDLShortLocalizedTime(sRMSNewAppointment.cStartTime,bMilitaryTime))
   
   IF(nIndex = RMS_APPT_FIELD_ALL || nIndex = RMS_APPT_FIELD_DURATION) 
     RMSSendVarTextCommand(dvPanel, nvtNewAppointment[3], RMSAppointmentDuration[sRMSNewAppointment.nDurationIdx][2])
   
   IF(nIndex = RMS_APPT_FIELD_ALL || nIndex = RMS_APPT_FIELD_SUBJECT) 
     RMSSendVarTextCommand(dvPanel, nvtNewAppointment[4], sRMSNewAppointment.cSubject)
   
   IF(nIndex = RMS_APPT_FIELD_ALL || nIndex = RMS_APPT_FIELD_MESSAGE) 
     RMSSendVarTextCommand(dvPanel, nvtNewAppointment[5], sRMSNewAppointment.cMessage)      
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(**************************************)
(* Call Name: RMSSetDoNotDisturb      *)
(* Function:  Set Do Not Disturb      *)
(*                                    *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSSetDoNotDisturb(CHAR bEnabled)
{
    // set do not disturb state
    bDoNotDisturb = bEnabled
    
    // Debug
    IF (bRMSDebug)
        SEND_STRING 0,"'RMS-Set Do Not Disturb: ',ITOA(bDoNotDisturb)"
	

    // do not disturb feedback channel
    [dvTPWelcome, nchDoNotDisturb[1]]  = (bDoNotDisturb)                         
	
    // show/hide do not disturb popup page
    IF(bDoNotDisturb)
    {
      SEND_COMMAND dvTPWelcome, "'@PPN-',RMSPopupDoNotDisturb,';',RMSWelcomePage"
    }
    ELSE
    {
      SEND_COMMAND dvTPWelcome, "'@PPF-',RMSPopupDoNotDisturb,';',RMSWelcomePage"
    }

    // show/hide doorbell button    
    #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
	
	// show or hide doorbell button
	RMSSendSHOCommand(dvTPWelcome, nvtDoorbell[1], !(bDoNotDisturb))

	// do not disturb feedback channel
	[dvTP, nchDoNotDisturb[1]]  = (bDoNotDisturb)

    #END_IF // RMS_UI_WELCOME_CODE_ONLY
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSStringReplace        *)
(* Function:  Replace a substring in  *)
(*            a string                *)
(* Params:    String, Search, Replace *)
(* Return:    Replaced String         *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION CHAR[1000] RMSStringReplace(CHAR cOrigStr[],CHAR cSearch[],CHAR cReplace[])
STACK_VAR
INTEGER nPos
CHAR cTrash[1000]
CHAR cTempStr[1000]
CHAR cOutStr[1000]
{
  // Quick Out
  cOutStr = cOrigStr
  nPos = FIND_STRING(cOutStr, "cSearch", 1)
  IF (!nPos)
    RETURN cOutStr;

  // Loop And Replace
  WHILE (nPos)
  {
    // Rebuild String And Replace New Character
    cTempStr = ""
    IF (nPos > 1)
      cTempStr = LEFT_STRING(cOutStr, nPos - 1)
    cTrash = REMOVE_STRING(cOutStr, "cTempStr,cSearch", 1)
    cOutStr = "cTempStr,cReplace,cOutStr"

    // Make We Start At Npos + Len Of Replace Or We Loop Forever
    // And Blow The Stack If We Replace With Portion Of Search!
    nPos = FIND_STRING(cOutStr, "cSearch", nPos + LENGTH_STRING(cReplace))
  }
  RETURN cOutStr;
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSMakeURLString        *)
(* Function:  Encode URL String       *)
(* Params:    String to Encode        *)
(* Return:    Encoded String          *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION CHAR[1000] RMSMakeURLString(CHAR cStr[])
{
  cStr = RMSStringReplace(cStr, '%', '%25')
  cStr = RMSStringReplace(cStr, "34",'%22')
  cStr = RMSStringReplace(cStr, ',', '%2C')
  cStr = RMSStringReplace(cStr, ' ', '%20')
  cStr = RMSStringReplace(cStr, ';', '%3B')
  cStr = RMSStringReplace(cStr, '/', '%2F')
  cStr = RMSStringReplace(cStr, '?', '%3F')
  cStr = RMSStringReplace(cStr, ':', '%3A')
  cStr = RMSStringReplace(cStr, '@', '%40')
  cStr = RMSStringReplace(cStr, '=', '%3D')
  cStr = RMSStringReplace(cStr, '+', '%2B')
  cStr = RMSStringReplace(cStr, '$', '%24')
  cStr = RMSStringReplace(cStr, '<', '%3C')
  cStr = RMSStringReplace(cStr, '>', '%3E')
  cStr = RMSStringReplace(cStr, '#', '%23')
  cStr = RMSStringReplace(cStr, '{', '%7B')
  cStr = RMSStringReplace(cStr, '}', '%7D')
  cStr = RMSStringReplace(cStr, '|', '%7C')
  cStr = RMSStringReplace(cStr, '\', '%5C')
  cStr = RMSStringReplace(cStr, '^', '%5E')
  cStr = RMSStringReplace(cStr, '[', '%5B')
  cStr = RMSStringReplace(cStr, ']', '%5D')
  cStr = RMSStringReplace(cStr, '`', '%60')
  cStr = RMSStringReplace(cStr, '&', '%26')
  RETURN cStr
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(**************************************)
(* Call Name: RMSScheduleDraw         *)
(* Function:  Display Schedule View   *)
(* Params:    Panel, Appointments     *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSScheduleDraw (DEV dvPanel[], INTEGER nPnlIdx, _sRMSApptCollection sAppts)
STACK_VAR
INTEGER nLoop
{
  //Update Selected Date Text
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
  RMSSendVarTextCommand(dvPanel,nvtCurMonthYear[1],TDLLocalizedDate(sAppts.cDate, bUKDate))
#END_IF // RMS_UI_WELCOME_CODE_ONLY

  // Clear out Colors and appt
  ON[dvPanel,nchRetrievingAppts[1]]
  RMSScheduleDrawCmds(dvPanel,nPnlIdx,sAppts,0)

  // G4 panels?  Blast 'em
  FOR(nLoop=1; nLoop <= LENGTH_STRING(sAppts.chApptList); nLoop++)
    RMSScheduleDrawCmds (dvPanel, nPnlIdx, sAppts, nLoop)
  OFF[dvPanel,nchRetrievingAppts[1]]
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSScheduleDrawCmds     *)
(* Function:  Display Schedule View   *)
(* Params:    Panel, Appointments     *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSScheduleDrawCmds (DEV dvPanel[], INTEGER nPnlIdx, _sRMSApptCollection sAppts, INTEGER nIndex)
LOCAL_VAR INTEGER nApptNum[2]
LOCAL_VAR CHAR    nG4CurColor[2][10]
{
  // Clear out?
  IF (nIndex == 0)
  {
    // Clear Colors And Appt
    nApptNum[nPnlIdx] = 0
    nG4CurColor[nPnlIdx] = RMS_G4_USER_SCHEDULE_COLOR_1
    RETURN;
  }


  SELECT
  {
    // If There Is An Entry In Schedule And It A Continuation Of The Last Appointment
    // Set this entry bmp and clear the subject
    ACTIVE (sAppts.chApptList[nIndex] && sAppts.chApptList[nIndex] = nApptNum[nPnlIdx]):
    {
      RMSSendBMFCommand(dvPanel,nvtTimeFields[nIndex],"'%T ','%CF',nG4CurColor[nPnlIdx]")
    }

    // If It Is The Current Appointment
    ACTIVE (sAppts.chApptList[nIndex]):
    {
	  if (sAppts.sAppts[sAppts.chApptList[nIndex]].nApptType == 1)
	  {
		IF (bRMSDebug)
			SEND_STRING 0,"'Skipping MacroEvent'"
		return;
	  }



      // Remember Appointment Number
      nApptNum[nPnlIdx] = sAppts.chApptList[nIndex]



      // Toggle Appointment BMP Color // Based On User Defined Colors
      IF(nG4CurColor[nPnlIdx] = RMS_G4_USER_SCHEDULE_COLOR_1)
      {
         nG4CurColor[nPnlIdx] = RMS_G4_USER_SCHEDULE_COLOR_2
      }
      ELSE
      {
         nG4CurColor[nPnlIdx] = RMS_G4_USER_SCHEDULE_COLOR_1
      }

      // Set this entry bmp and set the subject
      IF(LENGTH_STRING(sAppts.sAppts[nApptNum[nPnlIdx]].cSubject))
        RMSSendBMFCommand(dvPanel,nvtTimeFields[nIndex],"'%T',LEFT_STRING(sAppts.sAppts[nApptNum[nPnlIdx]].cSubject,50),'%CF',nG4CurColor[nPnlIdx]")
      ELSE
        RMSSendBMFCommand(dvPanel,nvtTimeFields[nIndex],"'%TNo Subject','%CF',nG4CurColor[nPnlIdx]")
    }

    // No Entry
    ACTIVE(1):
    {
      RMSSendBMFCommand(dvPanel,nvtTimeFields[nIndex],"'%T ','%CF',RMS_G4_USER_SCHEDULE_COLOR_0")
    }
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSPrepForNextAppt      *)
(* Function:  Prepare for Next Appt   *)
(* Params:    Reset History           *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION INTEGER RMSPrepForNextAppt(CHAR bReset)
STACK_VAR
INTEGER nIndex
INTEGER nPrevCurApptIndex
LOCAL_VAR
CHAR      bInit
CHAR      bActive
{
  // Save this
  nPrevCurApptIndex = sCurrentApptStats.nCurrentApptIndex

  // update meeting control button visibility
  IF(sCurrentApptStats.nCurrentApptIndex) 
  {
     bActive = 1
  }
  ELSE
  {
    bActive = 0
  }

  #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
   
   IF(bActive )
      RMSSendSHOCommand(dvTP,nvtMeetingControl[1], sTodaysAppts.sAppts[sCurrentApptStats.nCurrentApptIndex].bHasPreset)
   ELSE
      RMSSendSHOCommand(dvTP,nvtMeetingControl[1],0)

   RMSSendSHOCommand(dvTP,nvtMeetingControl[4],bActive)
   RMSSendSHOCommand(dvTP,nvtMeetingControl[5],bActive)
   RMSSendSHOCommand(dvTP,nvtMeetingControl[6],bActive)
   RMSSendSHOCommand(dvTP,nvtMeetingControl[7],bActive)
   RMSSendSHOCommand(dvTP,nvtMeetingControl[8],!(bActive))
  #END_IF

   IF(bActive )
      RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[1], sTodaysAppts.sAppts[sCurrentApptStats.nCurrentApptIndex].bHasPreset)
   ELSE
      RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[1],0)

  RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[4],bActive)
  RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[5],bActive)
  RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[6],bActive)
  RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[7],bActive)
  RMSSendSHOCommand(dvTPWelcome,nvtMeetingControl[8],!(bActive))
  
  // Reset All Variables
  IF ((bInit == FALSE) || (bReset))
  {
    sCurrentApptStats.nHistCurApptIndex = 65535
    sCurrentApptStats.nHistNextApptIndex = 65535
    sCurrentApptStats.nPrepApptIndex = 65535
    bInit = TRUE
    
    IF (bReset == FALSE)
      RETURN 0;
  }

  // Display next appointment?
  SELECT
  {
    // Current Appointment is up to date
    ACTIVE (sCurrentApptStats.nHistCurApptIndex == sCurrentApptStats.nCurrentApptIndex): {}

    // We have an active appointment
    ACTIVE (sCurrentApptStats.nCurrentApptIndex):
    {
      // Debug
      IF (bRMSDebug)
        SEND_STRING 0,"'RMSPrepForNextAppt Starting Appt ',ITOA(sCurrentApptStats.nCurrentApptIndex)"

      // Display Basic Details
      nIndex = sCurrentApptStats.nCurrentApptIndex

      // See if maybe we don't need to do this?
      IF (!(bReset = TRUE && nPrevCurApptIndex == sCurrentApptStats.nCurrentApptIndex))
      {
	// if the started appointment is not the current appointment, then reset the DND status and the meeting msg tracking flags
	IF(sCurrentApptStats.lCurrentAppointmentID != sTodaysAppts.sAppts[sCurrentApptStats.nCurrentApptIndex].lAppointmentID)
	{
	  IF (bRMSDebug)
            SEND_STRING 0,"'RMSPrepForNextAppt New Appt ',ITOA(sCurrentApptStats.nCurrentApptIndex)"
      
          RMSSetDoNotDisturb(0)
	  sCurrentApptStats.bMeetingEndWarned = FALSE
          sCurrentApptStats.bMeetingEndAcked = FALSE		
	  
	  // set current appointment ID
         sCurrentApptStats.lCurrentAppointmentID = sTodaysAppts.sAppts[sCurrentApptStats.nCurrentApptIndex].lAppointmentID	  
	}	
      }

      
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
            
      RMSDisplayAppointmentDetails(dvTP,nvtCurNextApptInfo,sTodaysAppts,nIndex)
      OFF[dvTP,nchMeetingStatus[1]]
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTPWelcome,nvtCurNextApptInfo,sTodaysAppts,nIndex)

      // Update welcome image
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTP,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTP,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTPWelcome,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTPWelcome,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)

      // Clear pending
      sCurrentApptStats.nPrepApptIndex = 0

      // Clear next appt?
      IF (sCurrentApptStats.nNextApptIndex == 0)
        RMSUpdateCountDownTimer(nvtCurNextApptInfo[8],0)

      // History
      sCurrentApptStats.nHistCurApptIndex = nIndex
    }
  }

  SELECT
  {
    // We have an active appointment
    ACTIVE (sCurrentApptStats.nCurrentApptIndex): {}
    // Next appointment is up to date
    ACTIVE (sCurrentApptStats.nHistNextApptIndex == sCurrentApptStats.nNextApptIndex): {}

    // Display Next Appointment (even if there is not one...)
    ACTIVE (1):
    {
      // Debug
      IF (bRMSDebug)
        SEND_STRING 0,"'RMSPrepForNextAppt Display Next Appt ',ITOA(sCurrentApptStats.nNextApptIndex)"

      // Display Basic Details
      nIndex = sCurrentApptStats.nNextApptIndex

      // set current appointment ID
     sCurrentApptStats.lCurrentAppointmentID = 0 

      #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
	// turn off do not disturb state
	RMSSetDoNotDisturb(0)
      #END_IF

      
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTP,nvtCurNextApptInfo,sTodaysAppts,nIndex)
      ON[dvTP,nchMeetingStatus[1]]
#END_IF // RMS_UI_WELCOME_CODE_ONLY

      // Timer is not running
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
      OFF[dvTP,nchMeetingStatus[2]]
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      RMSUpdateCountDownTimer(nvtCurNextApptInfo[7],0)

      // Update welcome image
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTP,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTP,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTPWelcome,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTPWelcome,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)

      // Clear next appt?
      IF (nIndex == 0)
        RMSUpdateCountDownTimer(nvtCurNextApptInfo[8],0)

      // History
      sCurrentApptStats.nHistNextApptIndex = nIndex
    }
  }

  // OK, if we have less than 10 minutes to go and no current appointment, display welcome image
  SELECT
  {
    // We have an active appointment
    ACTIVE (sCurrentApptStats.nCurrentApptIndex): {}
    // Nothing to do
    ACTIVE (sCurrentApptStats.nNextApptIndex == 0): {}
    // There is more than 10 minutes until next appointment
    ACTIVE (sCurrentApptStats.nMinutesTillNext > RMS_WELCOME_PREP_TIME_MIN): {}
    // I have already preped this appointment
    ACTIVE (sCurrentApptStats.nPrepApptIndex == sCurrentApptStats.nNextApptIndex): {}
    // Ok, Nothing To Do But Prep This Appointment
    ACTIVE (1):
    {
      // Debug
      IF (bRMSDebug)
        SEND_STRING 0,"'RMSPrepForNextAppt Prepping for Appt ',ITOA(sCurrentApptStats.nNextApptIndex)"

      // Update welcome image
      nIndex = sCurrentApptStats.nNextApptIndex
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTP,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTP,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      RMSDisplayAppointmentDetails(dvTPWelcome,nvtWelcome,sTodaysAppts,nIndex)
      RMSUpdateWelcome (dvTPWelcome,sTodaysAppts,nIndex,nvtWelcome,RMSDynImgWelcomeImage,nchWelcome)

      // History
      sCurrentApptStats.nPrepApptIndex = nIndex
    }
  }

  // Update Timer
  IF (sCurrentApptStats.nNextApptIndex)
    RMSUpdateCountDownTimer(nvtCurNextApptInfo[8],sCurrentApptStats.nMinutesTillNext)

  // Update Timer
  IF (sCurrentApptStats.nCurrentApptIndex)
  {
    RMSUpdateCountDownTimer(nvtCurNextApptInfo[7],sCurrentApptStats.nMinutesTillEnd)
    
    #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
    
    ON[dvTP,nchMeetingStatus[2]]

    // Do I need to extend meeting?
    SELECT
    {
      ACTIVE (sCurrentApptStats.bMeetingEndWarned): {}
      ACTIVE (sCurrentApptStats.bMeetingEndAcked): {}
      ACTIVE (sCurrentApptStats.nMinutesTillEnd <= RMS_WARN_TIME_MIN && sCurrentApptStats.nMinutesTillNext >= (sCurrentApptStats.nMinutesTillEnd+RMS_EXTEND_TIME_MIN)):
      {
        RMSSendVarTextCommand(dvTP,nvtWarn[1],"ITOA(sCurrentApptStats.nMinutesTillEnd)")
	
	SEND_COMMAND dvTP,"'PAGE-',RMSRoomPage"
        SEND_COMMAND dvTP,"'@PPN-',RMSPopupExtendWarning,';',RMSRoomPage"
      }
      ACTIVE (sCurrentApptStats.nMinutesTillEnd <= RMS_WARN_TIME_MIN):
      {
        RMSSendVarTextCommand(dvTP,nvtWarn[1],"ITOA(sCurrentApptStats.nMinutesTillEnd)")
        SEND_COMMAND dvTP,"'PAGE-',RMSRoomPage"
	SEND_COMMAND dvTP,"'@PPN-',RMSPopupEndWarning,';',RMSRoomPage"
      }
    }
    OFF[sCurrentApptStats.bMeetingEndWarned]
    
    #END_IF // RMS_UI_WELCOME_CODE_ONLY    
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSUpdateCountDownTimer *)
(* Function:  Display Timer           *)
(* Params:    Timer Value             *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSUpdateCountDownTimer (INTEGER nVT, LONG lHrMin)
STACK_VAR
CHAR cTime[20]
{
  cTime = "FORMAT('%2d',lHrMin/60),':',FORMAT('%02d',lHrMin%60)"
  IF (lHrMin == 0)
    cTime = ''
    
  #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
    RMSSendVarTextCommand(dvTP,nVT,cTime)
  #END_IF // RMS_UI_WELCOME_CODE_ONLY
  RMSSendVarTextCommand(dvTPWelcome,nVT,cTime)  
}
#END_IF // RMS_UI_HELP_CODE_ONLY



(**************************************)
(* Call Name: RMSUpdateLongMessage    *)
(* Function:  Display Long Msg        *)
(* Params:    Panel, VT, Message      *)
(* Return:    None                    *)
(**************************************)
DEFINE_FUNCTION RMSUpdateLongMessage(DEV dvPanel[], INTEGER nVT[], INTEGER nStart, INTEGER nCount, CHAR cMessage[])
STACK_VAR
LONG    lPos
LONG    lLastSpace
CHAR    cMsg[500]
CHAR    cTemp[RMS_MAX_LINE_SIZE]
INTEGER nVTIdx
INTEGER nVTIdxStop
integer iSpaceLF
{
  // Find Space Sequence 
  // Copy message to temp buffer and start at position 1
  cMsg = cMessage
  lPos = 1
  lLastSpace = 1
  iSpaceLF = 0
  
  // Start as first VT and loop until done
  nVTIdx = nStart
  nVTIdxStop = nVTIdx + nCount - 1
  
  // Bang this out, char by char.
  WHILE (lPos <= LENGTH_STRING(cMsg))
  {
    // Skip Until Next Space
    // Make sure not to pass up max line length
    WHILE (cMsg[lPos] > $20 && lPos < LENGTH_STRING(cMsg) && lPos < RMS_MAX_LINE_SIZE)
      lPos++
      
    // If this is not visible and not a Line feed, make it a space (remove cntrl chars)
    IF (cMsg[lPos] < $20 && cMsg[lPos] <> $0A) cMsg[lPos] = $20

    // Time To Line Wrap
    // Did We Pass Line Length?
    // Are we at a LineFeed?  
    // Are We at the End of the String?
    IF (lPos >= RMS_MAX_LINE_SIZE || cMsg[lPos] == $0A || (cMsg[lPos] == $20 && cMsg[lPos + 1] == $0A) || lPos >= LENGTH_STRING(cMsg))
    {
      SELECT
      {
        // If this is a line feed, clear it //or a space and a line feed
        // And get from 1 to LF
        ACTIVE ((cMsg[lPos] < $20) || (cMsg[lPos] == $20 && cMsg[lPos + 1] == $0A)) :
        {
			if (cMsg[lPos] == $20 && cMsg[lPos + 1] == $0A)
				iSpaceLF = 1
		
          cMsg[lPos] = $20
          cTemp = GET_BUFFER_STRING(cMsg,lPos)

		  if (iSpaceLF == 1)
			REMOVE_STRING(cMsg,"$0A",1)	//Remove the Line Feed if it is still there, it screws up the var text window

          lLastSpace = 1    
          lPos = 1
        }
        
        // If at end, set end to lPos
        ACTIVE (lPos >= LENGTH_STRING(cMsg)):
        {
          cTemp = GET_BUFFER_STRING(cMsg,lPos)
          lLastSpace = 1    
          lPos = 1
        }
        
        // If hit max line length and no spaces, get up to here and add "-"
        // backup one char first so we have MAX_LINE_LENGTH after we add "-"
        ACTIVE (lLastSpace <= 1):
        {
          lPos--
          cTemp = GET_BUFFER_STRING(cMsg,lPos)
          cTemp = "cTemp,'-'"
          lLastSpace = 1    
          lPos = 1
        }
        
        // Other cases, get from 1 to last space
        ACTIVE (1):
        {
          cTemp = GET_BUFFER_STRING(cMsg,lLastSpace)
          lLastSpace = 1    
          lPos = 1
        }
      }
      
      // See if we are totally running out of room to display this message
      IF (nVTIdx = nVTIdxStop && LENGTH_STRING(cMsg))
      {
        cTemp = LEFT_STRING(cTemp,MAX_LENGTH_STRING(cTemp)-3)
        cTemp = "cTemp,'...'"
      }
      
      // Get this chunk and send it
      IF (nVTIdx <= nVTIdxStop)
      {
        RMSSendVarTextCommand(dvPanel,nVT[nVTIdx],cTemp)
        nVTIdx++
      }
    }

    // Remember the last space
    lLastSpace = lPos

    // Keep Removing Spaces Until Next Char Or Length Of String (i.e. trim)
    IF (lPos <= LENGTH_STRING(cMsg))
    {
		  // Changed form <= to == per track ticket 38173.
      WHILE (cMsg[lPos] == $20 && lPos < LENGTH_STRING(cMsg))
        lPos++
    }
  }

  // Clean up remaining text windows
  FOR (; nVTIdx <= nVTIdxStop; nVTIdx++)
    RMSSendVarTextCommand(dvPanel,nVT[nVTIdx],'')
}

(**************************************)
(* Call Name: RMSUpdateWelcome        *)
(* Function:  Display Welcome Stuff   *)
(* Params:    Message, Image          *)
(* Return:    None                    *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSUpdateWelcome (DEV dvPanel[], _sRMSApptCollection sAppointmentCol, INTEGER nIndex, INTEGER nvtVT[], CHAR cDynImg[], INTEGER nchCH[])
STACK_VAR
_sRMSAppointment sAppt
{

  // Sanity
  IF (nIndex > 0 && nIndex <= MAX_LENGTH_ARRAY(sAppointmentCol.sAppts))
    sAppt = sAppointmentCol.sAppts[nIndex]

  if (sAppt.nApptType == 1) //don't display macro
      return;

  // Add some helping hints - Only for regular welcome
  //IF (LENGTH_STRING(sAppt.cStartTime) == 0 && nvtVT[1] == nvtWelcome[1])
    //sAppt.cWelcomeMessage = 'Available'

  // Add some more helping hints
  SELECT
  {
    ACTIVE (LENGTH_STRING(sAppt.cWelcomeMessage) == 0):
      sAppt.cWelcomeMessage = "sAppt.cSubject"
    ACTIVE (sAppt.cWelcomeMessage[1] == 10 && sAppt.cWelcomeMessage[2] == 10 &&
            sAppt.cWelcomeMessage[3] == 10 && sAppt.cWelcomeMessage[4] == 10):
      sAppt.cWelcomeMessage = "sAppt.cSubject"
  }
  
  // Welcome Text
  RMSUpdateLongMessage(dvPanel, nvtVT, 7, 5, sAppt.cWelcomeMessage)


  // Welcome Image
  SELECT
  {
    // Display Image
    ACTIVE (LENGTH_STRING(cServerHostPort) && LENGTH_STRING(sAppt.cWelcomeImageFile)):
    {
      SEND_COMMAND dvPanel,"'^RMF-',cDynImg,',%H',cServerHostPort,'%A',cServerWebRoot,'/dynamicResources%FwelcomeImage.aspx?File=',sAppt.cWelcomeImageFile,'&X=$BX&Y=$BY'"
      IF (bRMSDebug)
      {
        SEND_STRING 0,"'DynImg: ^RMF-',cDynImg,',%H',cServerHostPort,'%A',cServerWebRoot,'/dynamicResources%FwelcomeImage.aspx?File=',sAppt.cWelcomeImageFile,'&X=$BX&Y=$BY'"
      }
      ON[dvPanel,nchCH[1]]
    }
    // No File
    ACTIVE (LENGTH_STRING(cServerHostPort)):
	{
      OFF[dvPanel,nchCH[1]]
	}

    // No Host and RMS is online
    ACTIVE ([vdvRMSEngine,RMS_CH_SERVER_ONLINE]):
      SEND_STRING 0,"'RMSUpdateWelcome: cannot update image, cServerHostPort = ""'"
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**********************************************)
(* Call Name: RMSDisplayAppointmentDetails    *)
(* Function:  Display Details                 *)
(* Params:    Appt Index                      *)
(* Return:    None                            *)
(**********************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSDisplayAppointmentDetails (DEV dvPanel[], INTEGER nVT[], _sRMSApptCollection sAppts, INTEGER nIndex)
STACK_VAR
_sRMSAppointment sAppt
CHAR cDate[12]
CHAR cEDate[12]
{
  // Sanity
  IF (nIndex > 0 && nIndex <= MAX_LENGTH_ARRAY(sAppts.sAppts))
    sAppt = sAppts.sAppts[nIndex]

  if (sAppt.nApptType == 1) //don't display macro
      return;

  // Add some helping hints
  IF (LENGTH_STRING(sAppt.cSubject) == 0)
    sAppt.cSubject = 'No Subject'
  IF (LENGTH_STRING(sAppt.cStartTime) == 0)
    sAppt.cSubject = 'Available'

  // Display Basic Details
  SELECT
  {
    ACTIVE (nVT[1] == 0): {}
    ACTIVE (nVT[2] == 0):
    {
      // Add start date?
      cDate = ""
      IF (sAppt.cEndDate <> sAppt.cStartDate)
      {
        cDate = TDLLocalizedDate(sAppt.cStartDate, bUKDate)
        cDate = "LEFT_STRING(cDate,LENGTH_STRING(cDate)-5),' '"
      }

      // Add end date?
      cEDate = ""
      IF (sAppt.cEndDate <> sAppt.cStartDate)
      {
        cEDate = TDLLocalizedDate(sAppt.cEndDate, bUKDate)
        cEDate = "LEFT_STRING(cEDate,LENGTH_STRING(cEDate)-5),' '"
      }

      // Display
      IF (LENGTH_STRING(sAppt.cStartTime))
        RMSSendVarTextCommand(dvPanel,nVT[1],"cDate,TDLShortLocalizedTime(sAppt.cStartTime,bMilitaryTime),' - ',cEDate,TDLShortLocalizedTime(sAppt.cEndTime,bMilitaryTime)")
      ELSE
        RMSSendVarTextCommand(dvPanel,nVT[1],"")
    }
    ACTIVE (1):
    {
      // Add date?
      cDate = ""
      IF (sAppt.cEndDate <> sAppt.cStartDate)
      {
        cDate = TDLLocalizedDate(sAppt.cStartDate, bUKDate)
        cDate = "LEFT_STRING(cDate,LENGTH_STRING(cDate)-5),' '"
      }
      RMSSendVarTextCommand(dvPanel,nVT[1],"cDate,TDLShortLocalizedTime(sAppt.cStartTime,bMilitaryTime)")
    }
  }
  IF (nVT[2])
  {
    // Add date?
    cDate = ""
    IF (sAppt.cEndDate <> sAppt.cStartDate)
    {
      cDate = TDLLocalizedDate(sAppt.cEndDate, bUKDate)
      cDate = "LEFT_STRING(cDate,LENGTH_STRING(cDate)-5),' '"
    }
    RMSSendVarTextCommand(dvPanel,nVT[2],"cDate,TDLShortLocalizedTime(sAppt.cEndTime,bMilitaryTime)")
  }
  RMSSendVarTextCommand(dvPanel,nVT[3],sAppt.cSubject)
  RMSSendVarTextCommand(dvPanel,nVT[4],sAppt.cScheduler)
  RMSSendVarTextCommand(dvPanel,nVT[5],sAppt.cAttending)
  RMSSendVarTextCommand(dvPanel,nVT[6],sAppt.cDetails)
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(**************************************)
(* Call Name: RMSDisplayRoomInfo      *)
(* Function:  Display Room Info       *)
(* Params:    Room Info               *)
(* Return:    None                    *)
(**************************************)
DEFINE_FUNCTION RMSDisplayRoomInfo (DEV dvPanel[], _sCLSerDesc sRoominfo)
{
  RMSSendVarTextCommand(dvPanel,nvtRoomInfo[1],sRoominfo.cName)
  RMSSendVarTextCommand(dvPanel,nvtRoomInfo[2],sRoominfo.cLocation)
  RMSSendVarTextCommand(dvPanel,nvtRoomInfo[3],sRoominfo.cOwner)
}



(**************************************)
(* Function: RMSSelectCalendarDay     *)
(* Purpose:  Select a new Day         *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSSelectCalendarDay (INTEGER nIdx, CHAR bChannelOnly)
STACK_VAR
INTEGER nDayIdx
CHAR    cDate[12]
INTEGER nMonth
INTEGER nYear
CHAR    bMonthYearChanged
{
  // Today?
  nDayIdx = nIdx
  IF (nDayIdx == 0)
  {
    // Sync month and year?
    bMonthYearChanged = FALSE
    nMonth = TYPE_CAST(DATE_TO_MONTH(LDATE))
    nYear = TYPE_CAST(DATE_TO_YEAR(LDATE))
    IF (nMonth <> sCalendar.nMonth || nYear <> sCalendar.nYear)
    {
      RMSSelectCalendarMonthYear(nMonth,nYear,FALSE)
      bMonthYearChanged = TRUE
    }

    // Update day and day of week
    sCalendar.nDay =  TYPE_CAST(DATE_TO_DAY(LDATE))
    sCalendar.nDayofWeek =  TYPE_CAST(DAY_OF_WEEK(LDATE))
    nDayIdx = (sCalendar.nDay + sCalendar.nCalendarStartIdx - 1)
  }

  //check calendar index bounds in current month
  IF((nDayIdx >= sCalendar.nCalendarStartIdx) AND (nDayIdx <= sCalendar.nCalendarEndIdx))
  {
    //set index to current selected day
    sCalendar.nSelCalendarIdx = nDayIdx

    //update structure
    sCalendar.nDay        =  TYPE_CAST(DATE_TO_DAY ("ITOA(sCalendar.nMonth),'/',ITOA(sCalendar.nSelCalendarIdx - sCalendar.nCalendarStartIdx + 1),'/',ITOA(sCalendar.nYear)"))
    sCalendar.nDayofWeek  =  TYPE_CAST(DAY_OF_WEEK ("ITOA(sCalendar.nMonth),'/',ITOA(sCalendar.nSelCalendarIdx - sCalendar.nCalendarStartIdx + 1),'/',ITOA(sCalendar.nYear)"))

    //get schedule FOR selected day
    cDate = TDLDateSerial(sCalendar.nMonth, sCalendar.nDay, sCalendar.nYear,4, FALSE)
    SEND_COMMAND vdvRMSEngine,"'GET APPTS-',cDate"

    // Do we need a UK date for the screen? - but we already do this in the send_command.
    //IF (bUKDate)
    //  cDate = TDLDateSerial(sCalendar.nMonth, sCalendar.nDay, sCalendar.nYear,4, TRUE)

    // Update Date
    RMSSendVarTextCommand(dvTP,nvtCurMonthYear[1],TDLLocalizedDate(cDate, bUKDate))
    RMSSendVarTextCommand(dvTP,nvtCurMonthYear[3],"'  ',TDLLongMonthName(sCalendar.nMonth)")
    RMSSendVarTextCommand(dvTP,nvtCurMonthYear[2],"'  ',ITOA(sCalendar.nYear)")

    // Draw, Channel Only? - Update Screen
    RMSCalendarDraw(!bMonthYearChanged)
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(***************************************)
(* Function: RMSSelectCalendarMonthYear*)
(* Purpose:  Set Month and Year        *)
(***************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSSelectCalendarMonthYear (INTEGER nMonth, INTEGER nYear, CHAR bReqUpdate)
STACK_VAR
INTEGER nLoop
{
  // Clear Month Appts
  FOR(nLoop = 1; nLoop <= 31; nLoop++)
    sCalendarAppts.chMonthlyAppts[nLoop] = 0

  // Request new values
  IF (bReqUpdate)
    SEND_COMMAND vdvRMSEngine,"'GET APPT COUNT-',ITOA(nMonth),',',ITOA(nYear)"

  // Update Month
  RMSSendVarTextCommand(dvTP,nvtCurMonthYear[3],"'  ',TDLLongMonthName(nMonth)")
  RMSSendVarTextCommand(dvTP,nvtCurMonthYear[2],"'  ',ITOA(nYear)")

  sCalendar.nYear  =  nYear                                                                   //Update Structure Variables
  sCalendar.nMonth =  nMonth
  sCalendar.nDay   = 0
  sCalendar.nSelCalendarIdx = 0    //clear day index

  sCalendar.nCalendarStartIdx =  (TYPE_CAST(DAY_OF_WEEK ("ITOA(nMonth),'/1/',ITOA(nYear)")))  //Set Start Index to First Day of Month
  sCalendar.nNumDaysinMonth   =  TDLDaysPerMonth(nMonth, nYear)
  sCalendar.nCalendarEndIdx   =  sCalendar.nNumDaysinMonth + sCalendar.nCalendarStartIdx - 1  //Calculate Last Day Index in Month

  // Draw
  RMSCalendarDraw(FALSE)

  // Update Feedback - Just in case no server connection
  WAIT 20 'DisplayCalendarIcons'
    RMSCalendarDrawIcons()
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function: RMSCalendarDraw()        *)
(* Purpose:  Calendar Send Commands   *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSCalendarDraw(CHAR bChannelOnly)
{
  STACK_VAR INTEGER nCalDrawScLoop

  // G4 panels?  Blast 'em
  // If channel only, this is not likely to be much traffic so loop it too!
  FOR (nCalDrawScLoop = 1; nCalDrawScLoop <= LENGTH_ARRAY(nvtCalendar); nCalDrawScLoop++)
    RMSCalendarDrawCmds(nCalDrawScLoop,bChannelOnly)
  RETURN;
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function: RMSCalendarDrawCmds()    *)
(* Purpose:  Calendar Send Commands   *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSCalendarDrawCmds (INTEGER nIndex, CHAR bChannelOnly)
{
  IF (nIndex <= LENGTH_ARRAY(nchCalendar))
    [dvTP,nchCalendar[nIndex]] = (sCalendar.nSelCalendarIdx = nIndex)
  IF (bChannelOnly)
    RETURN;

  //Check Bounds Calendar Day Index to Days in Month
  IF((nIndex >= sCalendar.nCalendarStartIdx) AND (nIndex <= sCalendar.nCalendarEndIdx))
  {
    //Un-Hide Calendar Day Button
    IF((nIndex <= 7) OR (nIndex >= 29))
      RMSSendSHOCommand(dvTP, nvtCalendar[nIndex],1)

    //Update Date on Calendar Day Index Button
    RMSSendVarTextCommand(dvTP, nvtCalendar[nIndex], ITOA(nIndex - sCalendar.nCalendarStartIdx + 1))
  }

  //If Index is Not in Month Range, Hide Calendar Day
  ELSE
    RMSSendSHOCommand(dvTP, nvtCalendar[nIndex],0)
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSCalendarDrawIcons    *)
(* Purpose:   Calendar Feedback       *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSCalendarDrawIcons()
{
  STACK_VAR INTEGER nCalDrawIconScLoop
  
  // G4 panels?  Blast 'em
  FOR (nCalDrawIconScLoop = 1; nCalDrawIconScLoop <= LENGTH_ARRAY(nchCalendar); nCalDrawIconScLoop++)
    RMSCalendarDrawIconsCmds (nCalDrawIconScLoop)
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(***************************************)
(* Function:  RMSCalendarDrawIconsCmds *)
(* Purpose:   Calendar Feedback        *)
(***************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSCalendarDrawIconsCmds (INTEGER nIndex)
STACK_VAR
INTEGER nDay
{
  // Sanity
  IF ((nIndex < sCalendar.nCalendarStartIdx) OR (nIndex > sCalendar.nCalendarEndIdx))
  {
    [dvTP,nchCalendarIcons[nIndex]] = 0
    RETURN;
  }

  // Update On/Off State Of Appointment Icon
  nDay = nIndex - sCalendar.nCalendarStartIdx + 1
  [dvTP,nchCalendarIcons[nIndex]] = (sCalendarAppts.chMonthlyAppts[nDay])

  // No Need for Send command?
  IF (sCalendarAppts.chMonthlyAppts[nDay] == 0)
    RETURN;

  // Update Number Of Appts On Calendar Day
  RMSSendVarTextCommand(dvTP, nvtCalendarIcons[nIndex], ITOA(sCalendarAppts.chMonthlyAppts[nDay]))
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSPopulateYears        *)
(* Purpose:   Update Year Values      *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DEFINE_FUNCTION RMSPopulateYears (DEV dvPanel[], SINTEGER snYrIdx)
{
  IF (snYrIdx <= 0)
    RETURN;

  sCalendar.nBaseYear  =  TYPE_CAST(snYrIdx)
  sCalendar.nYearIdx   =  sCalendar.nBaseYear
  RMSSendVarTextCommand(dvTP, nvtCurMonthYear[4],"'  ',ITOA(snYrIdx)")
  RMSSendVarTextCommand(dvTP, nvtCurMonthYear[5],"'  ',ITOA(snYrIdx + 1)")
  RMSSendVarTextCommand(dvTP, nvtCurMonthYear[6],"'  ',ITOA(snYrIdx + 2)")
  RMSSendVarTextCommand(dvTP, nvtCurMonthYear[7],"'  ',ITOA(snYrIdx + 3)")
  RMSSendVarTextCommand(dvTP, nvtCurMonthYear[8],"'  ',ITOA(snYrIdx + 4)")
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSPostHelpResponse     *)
(* Purpose:   Display response        *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
DEFINE_FUNCTION RMSPostHelpResponse (INTEGER nFlags, CHAR cMsg[])
{
  RMSUpdateLongMessage (dvTp, nvtHelpResponse, 1, 5, cMsg)
  SEND_COMMAND dvTP,"'PAGE-',RMSRoomPage"
  SEND_COMMAND dvTp,"'@PPN-',RMSPopupHelpResponse,';',RMSRoomPage"
  SEND_COMMAND dvTP,'WAKE'
}
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSPostHelpQuestion     *)
(* Purpose:   Display question        *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
DEFINE_FUNCTION RMSPostHelpQuestion (INTEGER nFlags, CHAR cQ[], CHAR cAs[4][])
STACK_VAR
CHAR bState
INTEGER nLoop
INTEGER nCount
{
  RMSUpdateLongMessage (dvTp, nvtHelpResponse, 1, 5, cQ)
  FOR (nCount = 0, nLoop = 1; nLoop <= 4; nLoop++)
  {
    bState = (LENGTH_STRING(cAs[nLoop]) > 0)
    RMSSendSHOCommand(dvTp, nvtHelpAnswer[nLoop], bState)
    IF (bState)
    {
      RMSSendVarTextCommand(dvTp, nvtHelpAnswer[nLoop], cAs[nLoop])
      nCount++
    }
  }
  // Need an OK?
  IF (nCount == 0)
  {
    RMSSendSHOCommand(dvTp, nvtHelpAnswer[1], TRUE)
    RMSSendVarTextCommand(dvTp, nvtHelpAnswer[1], 'OK')
  }
  SEND_COMMAND dvTP,"'PAGE-',RMSRoomPage"
  SEND_COMMAND dvTp,"'@PPN-',RMSPopupHelpQuestion,';',RMSRoomPage"
  SEND_COMMAND dvTP,'WAKE'
}
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSPostHelpResponse     *)
(* Purpose:   Display response        *)
(**************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
DEFINE_FUNCTION RMSSendHelpAnswer (INTEGER nAnswer)
{
  IF (nAnswer && nAnswer <= MAX_LENGTH_ARRAY(cHDAnswers))
  {
    IF (LENGTH_STRING(cHDAnswers[nAnswer]) = 0)
      cHDAnswers[nAnswer] = 'OK'
    SEND_COMMAND vdvRMSEngine,"'ANSWER-',ITOA(nHDQuestionID),',',ITOA(nHDQuestionFlags),',',cHDAnswers[nAnswer]"
  }
}
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(**************************************)
(* Function:  RMSGetVersion           *)
(* Purpose:   Get Version             *)
(**************************************)
DEFINE_FUNCTION CHAR[50] RMSGetVersion(DEV dvDev, INTEGER nMajor, INTEGER nMinor, INTEGER nBuild)
LOCAL_VAR
DEV_INFO_STRUCT sDevInfo
CHAR cVer[50]
CHAR cTemp[50]
{
  DEVICE_INFO(dvDev,sDevInfo)
  cVer = sDevInfo.VERSION
  cTemp = REMOVE_STRING(cVer,'.',1)
  nMajor = ATOI(cTemp)
  cTemp = REMOVE_STRING(cVer,'.',1)
  nMinor = ATOI(cTemp)
  nBuild = ATOI(cVer)
  RETURN sDevInfo.VERSION
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT


(*******************************************)
(* BUTTON: Panel Inactivity                *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTPWelcome,0]
{
  PUSH:
  {
      // restart the panel inactivity timeline
      IF(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_WELCOME))
        TIMELINE_KILL(TL_SCH_VIEW_TIME_WELCOME)      
      
      IF(!(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_WELCOME)))
        TIMELINE_CREATE(TL_SCH_VIEW_TIME_WELCOME,alTLSchViewTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)      
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(*******************************************)
(* BUTTON: Panel Inactivity                *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,0]
{
  PUSH:
  {
      // restart the panel inactivity timeline
      IF(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_ROOM))
        TIMELINE_KILL(TL_SCH_VIEW_TIME_ROOM)
      
      IF(!(TIMELINE_ACTIVE(TL_SCH_VIEW_TIME_ROOM)))
        TIMELINE_CREATE(TL_SCH_VIEW_TIME_ROOM,alTLSchViewTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY


(*******************************************)
(* BUTTON: Calendar Selection              *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,nchCalendar]
{
  PUSH:
  {
    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {      
	RMSSelectCalendarDay(GET_LAST(nchCalendar),TRUE)
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }        
  }
}
BUTTON_EVENT[dvTP,nchCalendarIcons]
{
  PUSH:
  {
    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {        
	RMSSelectCalendarDay(GET_LAST(nchCalendarIcons),TRUE)
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }    	
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(*******************************************)
(* BUTTON: Select Today                    *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,nchDaySelect]
{
  PUSH:
  {
    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {   
	IF (GET_LAST(nchDaySelect) == 1)
	  RMSSelectCalendarDay(0,TRUE)
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }    	  
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(*******************************************)
(* BUTTON: Month Selection                 *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,nchMonthSelect]
{
  PUSH:
  {
    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {      
	RMSSelectCalendarMonthYear (GET_LAST(nchMonthSelect), sCalendar.nYear, TRUE)
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }    
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(*******************************************)
(* BUTTON: Year Select                     *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,nchYearSelect]
{
  PUSH:
  {
    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {        
	RMSSelectCalendarMonthYear (sCalendar.nMonth, sCalendar.nBaseYear + GET_LAST(nchYearSelect) - 1, TRUE)
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }    
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY




(*******************************************)
(* BUTTON: Meeting Control                 *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTPWelcome,nchMeetingControl]
#END_IF
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
BUTTON_EVENT[dvTP,nchMeetingControl]
#END_IF // RMS_UI_WELCOME_CODE_ONLY
{
  PUSH :
  {
    STACK_VAR
    INTEGER nIdx
	integer nMacro

    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {      
	// Which button?
	nIdx = GET_LAST(nchMeetingControl)
	SWITCH (nIdx)
	{
	  // Run Preset
	  CASE 1:
	  {
	    // Run Preset
    #IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
	    IF (sCurrentApptStats.nCurrentApptIndex)
	    {
	      // feedback
	      TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]
	      PULSE[vdvRMSEngine,RMS_CH_RUN_PRESET]
	      
	      // beep on button press
	      IF(RMS_BEEP_PRESET_RUN)
	      {
		SEND_COMMAND BUTTON.INPUT.DEVICE,'ADBEEP'
	      }
	    }
    #END_IF // 
	  }
    
    #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
    
	  // Help Message
	  CASE 2:
	  {
	    // feedback
	    TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]
	    
	    // display keyboard page for help request messages
	    SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupHelpRequest"
	  }
    
	  // Maintenance Message
	  CASE 3:
	  {
	    // feedback
	    TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]

	    // display keyboard page for service request messages
	    SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupServiceRequest"
	  }
    
    #END_IF // RMS_UI_WELCOME_CODE_ONLY
    
    #IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
	  // Extend Meeting
	  CASE 4:
	  {
	    // Extend Current
	    IF (sCurrentApptStats.nCurrentApptIndex)
	    {          
	      // feedback
	      TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]
	      
	       // set extend touch panel
	       dvExtendTP[1] = BUTTON.INPUT.DEVICE
	       SET_LENGTH_ARRAY(dvExtendTP,1)
    
	      // display pending page
		  RMSMessageSingle(button.input.device, RMSMsgMtgExtendPending, RMSMessageTypePending, '', '');
    
	      // OK, make this meeting start 15 min later
	      SEND_COMMAND vdvRMSEngine,"'EXTEND-',ITOA(RMS_EXTEND_TIME_MIN)"
	      sCurrentApptStats.bMeetingEndWarned = FALSE
	      sCurrentApptStats.bMeetingEndAcked = FALSE
	    }
	    ELSE
	    {
	      SEND_COMMAND BUTTON.INPUT.DEVICE,'ADBEEP'
	    }
	  }
    
	  // Do Not Extend Meeting
	  CASE 5:
	  {
	    #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
	      SEND_COMMAND dvTP,"'@PPF-',RMSPopupEndWarning"
	      SEND_COMMAND dvTP,"'@PPF-',RMSPopupExtendWarning"
	    #END_IF // RMS_UI_WELCOME_CODE_ONLY
	    sCurrentApptStats.bMeetingEndWarned = TRUE
	    sCurrentApptStats.bMeetingEndAcked = TRUE
	  }
		
	  // End Meeting Now
	  CASE 6:
	  {
	    // End Current
	    IF (sCurrentApptStats.nCurrentApptIndex)
	    {          
	      // feedback
	      TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]
	      
	       // set end now touch panel
	       dvEndNowTP[1] = BUTTON.INPUT.DEVICE
	       SET_LENGTH_ARRAY(dvEndNowTP,1)
	      
	      // display pending page	  
		  RMSMessageSingle(BUTTON.INPUT.DEVICE, RMSMsgMtgEndNowPending, RMSMessageTypePending, '', '');
    
	      // OK, send command to end this meeting
	      SEND_COMMAND vdvRMSEngine,"'ENDNOW'"
	    }
	    ELSE
	      SEND_COMMAND BUTTON.INPUT.DEVICE,'ADBEEP'
	  }      
	  
	  
	  // Display Meeting Details
	  CASE 7:
	  {
	    // feedback
	    TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]
	  
	    // if there is a current meeting at this time, then display the details of this meeting
	    IF(sCurrentApptStats.nCurrentApptIndex)
	    {	
			SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupMtgInfo"	
	    }
	  }
	  
	  // Create Meeting Now
	  CASE 8:
	  {
	    // feedback
	    TO[BUTTON.INPUT.DEVICE,BUTTON.INPUT.CHANNEL]

		//if a macro is active, ok to schedule a new meeting
		nMacro = 0
		IF(sCurrentApptStats.nCurrentApptIndex > 0) 
			nMacro = (sTodaysAppts.sAppts[sCurrentApptStats.nCurrentApptIndex].nApptType == 1)

	    // if there is not a current meeting, display add new meeting popup page
	    IF((sCurrentApptStats.nCurrentApptIndex = 0) || (nMacro == 1))
	    {
	       // set starting default appointment duration
	       sRMSNewAppointment.nDurationIdx = RMSAppointmentDurationDefaultIndex
	   
	       // set starting appointment date, time, subject, & message
	       sRMSNewAppointment.cStartDate = DATE
	       sRMSNewAppointment.cStartTime = TIME
	       sRMSNewAppointment.cSubject = strDefaultSubject
	       sRMSNewAppointment.cMessage = strDefaultMsg
    
	       // set reservation touch panel
	       dvReserveTP[1] = BUTTON.INPUT.DEVICE
	       SET_LENGTH_ARRAY(dvReserveTP,1)
    
	       // set date and time for new appointment
	       RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_ALL)
	       SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupMtgDoesNotExist"
	    }
	  }      
      
	#END_IF // RMS_UI_HELP_CODE_ONLY
	}
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }
  }
}

(*******************************************)
(* BUTTON: Help Desk Quetion               *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
BUTTON_EVENT[dvTP,nchHelpAnswer]
{
  PUSH:
  {
    STACK_VAR
    INTEGER nIdx

    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {    
	// Which button?
	nIdx = GET_LAST(nchHelpAnswer)
	RMSSendHelpAnswer(nIdx)
	SEND_COMMAND dvTp,"'@PPF-',RMSPopupHelpQuestion"
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }    
  }
}
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(*******************************************)
(* BUTTON: Schedule Slots                  *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP,nchTimeFields]
{
  PUSH:
  {
    STACK_VAR
    INTEGER nIdx
    DEV dvPanel[1]
    _sRMSAppointment sAppt

    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {    
	// Which button?
	nIdx = GET_LAST(nchTimeFields)
	nIdx = sCalendarAppts.chApptList[nIdx]
    
	// Sanity
	IF (nIdx > 0 && nIdx <= MAX_LENGTH_ARRAY(sCalendarAppts.sAppts))
	sAppt = sCalendarAppts.sAppts[nIdx]

	// Does this time slot have any appointments?
	IF ((LENGTH_STRING(sAppt.cSubject) == 0 && LENGTH_STRING(sAppt.cStartTime) == 0)
		|| (sAppt.nApptType == 1)) //if the select spot has a macro appointment, ok to schedule a meeting
	{
	   // set starting default appointment duration
	   sRMSNewAppointment.nDurationIdx = RMSAppointmentDurationDefaultIndex
	   
	   // set starting appointment date, time, subject, & message
	   sRMSNewAppointment.cStartDate = sCalendarAppts.cDate
	   sRMSNewAppointment.cStartTime = RMSTimeBlocks[GET_LAST(nchTimeFields)]
	   sRMSNewAppointment.cSubject = strDefaultSubject
	   sRMSNewAppointment.cMessage = strDefaultMsg
    
	   // set date and time for new appointment
	   RMSDisplayNewAppointmentInfo(dvTP,RMS_APPT_FIELD_ALL)
    
	   // no appointment in this time slot; display no appointment popup page
	   SEND_COMMAND BUTTON.INPUT.DEVICE,"'PAGE-',RMSRoomPage"	
	   SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupMtgDoesNotExist,';',RMSRoomPage"
	}
	ELSE
	{
	    // display appointment details
	    dvPanel[1] = Button.Input.Device
	    SET_LENGTH_ARRAY(dvPanel,1)
	    RMSDisplayAppointmentDetails(dvPanel,nvtApptInfo,sCalendarAppts,nIdx)
	    RMSUpdateWelcome (dvPanel,sCalendarAppts,nIdx,nvtApptInfo,RMSDynImgSelWelcomeImage,nchSelectedWelcome)
	   
	    // display appointment details popup page
	    SEND_COMMAND BUTTON.INPUT.DEVICE,"'PAGE-',RMSRoomPage"
	    
	    SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupMtgDetails,';',RMSRoomPage"
	}
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY

#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTPWelcome,nchTimeFields]
{
  PUSH:
  {
    STACK_VAR
    INTEGER nIdx
    DEV dvPanel[1]
    _sRMSAppointment sAppt

    // ensure server is online
    IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
    {    
	// Which button?
	nIdx = GET_LAST(nchTimeFields)
	nIdx = sTodaysAppts.chApptList[nIdx]
	    
	// Sanity
	IF (nIdx > 0 && nIdx <= MAX_LENGTH_ARRAY(sTodaysAppts.sAppts))
	sAppt = sTodaysAppts.sAppts[nIdx]
	
	// Does this time slot have any appointments?
	IF (LENGTH_STRING(sAppt.cSubject) == 0 && LENGTH_STRING(sAppt.cStartTime) == 0)
	{
	   // set starting default appointment duration
	   sRMSNewAppointment.nDurationIdx = RMSAppointmentDurationDefaultIndex
	   
	   // set starting appointment date, time, subject, & message
	   sRMSNewAppointment.cStartDate = Date
	   sRMSNewAppointment.cStartTime = RMSTimeBlocks[GET_LAST(nchTimeFields)]
	   sRMSNewAppointment.cSubject = strDefaultSubject
	   sRMSNewAppointment.cMessage = strDefaultMsg
    
	   // set date and time for new appointment
	   RMSDisplayNewAppointmentInfo(dvTPWelcome,RMS_APPT_FIELD_ALL)
    
	   // no appointment in this time slot; display no appointment popup page
	   SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupMtgDoesNotExist,';',RMSWelcomePage"
	}
	ELSE
	{
	   // display appointment details
	   dvPanel[1] = Button.Input.Device
	   SET_LENGTH_ARRAY(dvPanel,1)
	   RMSDisplayAppointmentDetails(dvPanel,nvtApptInfo,sTodaysAppts,nIdx)
	   RMSUpdateWelcome (dvPanel,sTodaysAppts,nIdx,nvtApptInfo,RMSDynImgSelWelcomeImage,nchSelectedWelcome)
	   
	   // display appointment details popup page
	   
	   SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupMtgDetails,';',RMSWelcomePage"
	}        
    }
    ELSE    
    {
	SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
    }
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(*******************************************)
(* DATA: TP                                *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
DATA_EVENT[dvTP]
{
  ONLINE:
  {
    STACK_VAR
    INTEGER nMaj
    INTEGER nMin
    INTEGER nBuild
    DEV     dvPanel[1]

    // send the version string to the panel
    SEND_COMMAND DATA.DEVICE,"'@TXT',nvtVersionInfo[2],__RMS_UI_NAME__,' v',__RMS_UI_VERSION__"

    // force all popup to close
    SEND_COMMAND DATA.DEVICE,"'@PPA-',RMSRoomPage"	
    
    // this is an "in-room" panel, so display the room panel default page    
    SEND_COMMAND DATA.DEVICE,"'PAGE-',RMSRoomMain"	


    // set temp panel array
    dvPanel[1] = DATA.DEVICE
    SET_LENGTH_ARRAY(dvPanel,1)
    
    // update the current panels schedule time view
    #IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
	RMSUpdateScheduleTimeView(dvPanel,RMSRoomPage)
    #END_IF

    // Enable G4
    IF (DEVICE_ID(DATA.DEVICE) >= 256)
    {
      RMSGetVersion(DATA.DEVICE,nMaj,nMin,nBuild)
      IF (nMin >= RMS_G4_TARGET_MINOR)
        ON[vdvRMSEngine,RMS_CH_SUPPORT_DI]
      ELSE
        SEND_STRING 0,"'RMS: The G4 panel "',RMSDevToString(DATA.DEVICE),'" cannot support dynamic images.  Please upgrade the firmware to 2.',ITOA(RMS_G4_TARGET_MINOR),'.xx'"
    }


    // Update Variable Text
    CANCEL_WAIT 'RMSdvTPOnline'
    WAIT 20 'RMSdvTPOnline'
    {
      RMSDisplayRoomInfo(dvTP,sRoomInfo)
      RMSGetEngineInfo()
      #IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
        RMSPrepForNextAppt(TRUE)
        RMSPopulateYears(dvTP,DATE_TO_YEAR(LDATE))
        sCalendar.nMonth = 13 // Make sure we get an update
        RMSSelectCalendarDay(0,FALSE)
      #END_IF // RMS_UI_HELP_CODE_ONLY
    }
  }
}

//
// KEYBOARD STRING HANDLER for dvTP
//
DATA_EVENT[dvTP_Base]
{  
  STRING:
  {
    STACK_VAR INTEGER nPanelIndex
    nPanelIndex = GET_LAST(dvTP_Base)    

    SELECT
    {
       ACTIVE(DATA.TEXT = 'Help.Request-')        : {}  // ABORT do nothing
       ACTIVE(DATA.TEXT = 'Service.Request-')     : {}  // ABORT do nothing       
       ACTIVE(LEFT_STRING(DATA.TEXT, 25) = 'Reservation.Subject-ABORT') : {}  // ABORT do nothing
       ACTIVE(LEFT_STRING(DATA.TEXT, 25) = 'Reservation.Message-ABORT') : {}  // ABORT do nothing       
       ACTIVE(LEFT_STRING(DATA.TEXT, 18) = 'Help.Request-ABORT')        : {}  // ABORT do nothing
       ACTIVE(LEFT_STRING(DATA.TEXT, 21) = 'Service.Request-ABORT')     : {}  // ABORT do nothing       

       ACTIVE(LEFT_STRING(DATA.TEXT, 13) = 'Help.Request-')        :
       {
           // Get Help Request Message Text
           SEND_COMMAND vdvRMSEngine,"'HELP-',RMSMidString(DATA.TEXT,14,-1)"       

	   // display success popup page
           SEND_COMMAND DATA.DEVICE,"'PAGE-',RMSRoomPage"	     
		   RMSMessageSingle(dvTP[nPanelIndex], RMSMsgHelpRequestSubmitted, RMSMessageTypeConfirm, RMSRoomPage, '');
       }  
       ACTIVE(LEFT_STRING(DATA.TEXT, 16) = 'Service.Request-')     : 
       {
           // Get Service Request Message Text
           SEND_COMMAND vdvRMSEngine,"'MAINT-',RMSMidString(DATA.TEXT,17,-1)"	   
	   
	       // display success popup page
	       SEND_COMMAND dvTP[nPanelIndex], "'PAGE-',RMSRoomPage"
		   RMSMessageSingle(dvTP[nPanelIndex], RMSMsgServiceRequestSubmitted, RMSMessageTypeConfirm, RMSRoomPage, '')
       }       
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY       
       ACTIVE(LEFT_STRING(DATA.TEXT, 20) = 'Reservation.Subject-') :
       {       	   
	   // set meeting reservation subject	   
	   sRMSNewAppointment.cSubject = RMSMidString(DATA.TEXT,21,-1)	   
	
           // set reservation touch panel
	   dvReserveTP[1] = dvTP[nPanelIndex]
	   SET_LENGTH_ARRAY(dvReserveTP,1)

	   // update subject on TP
	   RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_SUBJECT)
       }
       ACTIVE(LEFT_STRING(DATA.TEXT, 20) = 'Reservation.Message-') :
       {
            // set meeting reservation message
	    sRMSNewAppointment.cMessage = RMSMidString(DATA.TEXT,21,-1)

	    // ensure a subject has been entered
	    IF(LENGTH_STRING(sRMSNewAppointment.cSubject) > 0)
	    {
	      // display pending popup page
	      SEND_COMMAND dvTP[nPanelIndex],"'PAGE-',RMSRoomPage"
		  RMSMessageSingle(dvTP[nPanelIndex], RMSMsgMtgRequestPending, RMSMessageTypePending, RMSRoomPage, '')
	    
	      // set reservation touch panel
	      dvReserveTP[1] = dvTP[nPanelIndex]
	      SET_LENGTH_ARRAY(dvReserveTP,1)
	      
	      // update subject on TP
	      RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_MESSAGE)	      

	      // reserve meeting now; send request to RMS engine module
	      SEND_COMMAND vdvRMSEngine,"'RESERVE-',sRMSNewAppointment.cStartDate,',',TDLShortLocalizedTime(sRMSNewAppointment.cStartTime,1),',',RMSAppointmentDuration[sRMSNewAppointment.nDurationIdx][1],',',sRMSNewAppointment.cSubject,',',sRMSNewAppointment.cMessage"
	    }
	    ELSE
	    {
	      RMSSendVarTextCommandSingle(dvTP[nPanelIndex],nvtAddMeetingFailureMessage[1],'A SUBJECT must be included to create a new meeting.')

	      // display failure popup page
	      SEND_COMMAND dvTP[nPanelIndex], "'PAGE-',RMSRoomPage"
		  SEND_COMMAND dvTP[nPanelIndex], "'@PPN-',RMSPopupMtgRequestFailed,';',RMSRoomPage"
		  
	    }
        }
#END_IF // RMS_UI_HELP_CODE_ONLY	
    }
  }
}
#END_IF // RMS_UI_WELCOME_CODE_ONLY

(*******************************************)
(* DATA: Welcome Tp                        *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
DATA_EVENT[dvTPWelcome]
{
  ONLINE:
  {
    STACK_VAR
    INTEGER nMaj
    INTEGER nMin
    INTEGER nBuild
    DEV dvPanel[1]

    // send the version string to the panel
    SEND_COMMAND DATA.DEVICE,"'@TXT',nvtVersionInfo[2],__RMS_UI_NAME__,' v',__RMS_UI_VERSION__"

    // force all popup to close
    SEND_COMMAND DATA.DEVICE,"'@PPA-',RMSWelcomePage"	

    // this is a "wlecome" panel, so display the room panel default page
    SEND_COMMAND DATA.DEVICE,"'PAGE-',RMSWelcomePage"	

    // set temp panel array
    dvPanel[1] = DATA.DEVICE
    SET_LENGTH_ARRAY(dvPanel,1)
    
    // update the current panels schedule time view
    RMSUpdateScheduleTimeView(dvPanel,RMSWelcomePage)

    // Enable G4 Dynamic Images
    RMSGetVersion(DATA.DEVICE,nMaj,nMin,nBuild)
    IF (nMin >= RMS_G4_TARGET_MINOR)
    {
      ON[vdvRMSEngine,RMS_CH_SUPPORT_DI]
    }
    ELSE
    {
      SEND_STRING 0,"'RMS: The G4 panel "',RMSDevToString(DATA.DEVICE),'" cannot support dynamic images.  Please upgrade the firmware to 2.',ITOA(RMS_G4_TARGET_MINOR),'.xx'"
    }

    // Update Variable Text
    CANCEL_WAIT 'RMSdvTPWelcomeOnline'
    WAIT 20 'RMSdvTPWelcomeOnline'
    {
	// hide doorbell button if there is no in-room panel
	#IF_DEFINED RMS_UI_WELCOME_CODE_ONLY    
	    RMSSetDoNotDisturb(0)
	#ELSE
	    RMSSetDoNotDisturb(bDoNotDisturb)
	#END_IF
    
        RMSDisplayRoomInfo(dvTPWelcome,sRoomInfo)
        RMSScheduleDraw(dvTPWelcome,2,sTodaysAppts)
        RMSPrepForNextAppt(TRUE)
        RMSGetEngineInfo()
    }
  }
}
//
// KEYBOARD STRING HANDLER for dvTPWelcome
//
DATA_EVENT[dvTPWelcome_Base]
{  
  STRING:
  {
    STACK_VAR INTEGER nPanelIndex
    nPanelIndex = GET_LAST(dvTPWelcome_Base)    
  
    SELECT
    {
       ACTIVE(LEFT_STRING(DATA.TEXT, 25) = 'Reservation.Subject-ABORT') : {}  // ABORT do nothing
       ACTIVE(LEFT_STRING(DATA.TEXT, 25) = 'Reservation.Message-ABORT') : {}  // ABORT do nothing       
       ACTIVE(LEFT_STRING(DATA.TEXT, 20) = 'Reservation.Subject-') :
       {
       	   // set meeting reservation subject	   
	   sRMSNewAppointment.cSubject = RMSMidString(DATA.TEXT,21,-1)	   
	
           // set reservation touch panel
	   dvReserveTP[1] = dvTPWelcome[nPanelIndex]
	   SET_LENGTH_ARRAY(dvReserveTP,1)

	   // update subject on TP
	   RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_SUBJECT)
       }
       ACTIVE(LEFT_STRING(DATA.TEXT, 20) = 'Reservation.Message-') :
       {
            // set meeting reservation message
	    sRMSNewAppointment.cMessage = RMSMidString(DATA.TEXT,21,-1)

	    // ensure a subject has been entered
	    IF(LENGTH_STRING(sRMSNewAppointment.cSubject) > 0)
	    {
	      // display pending popup page
		  RMSMessageSingle(dvTPWelcome[nPanelIndex], RMSMsgMtgRequestPending, RMSMessageTypePending, RMSWelcomePage, '')
	    
	      // set reservation touch panel
	      dvReserveTP[1] = dvTPWelcome[nPanelIndex]
	      SET_LENGTH_ARRAY(dvReserveTP,1)
	      
	      // update subject on TP
	      RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_MESSAGE)	      

	      // reserve meeting now; send request to RMS engine module
	      SEND_COMMAND vdvRMSEngine,"'RESERVE-',sRMSNewAppointment.cStartDate,',',TDLShortLocalizedTime(sRMSNewAppointment.cStartTime,1),',',RMSAppointmentDuration[sRMSNewAppointment.nDurationIdx][1],',',sRMSNewAppointment.cSubject,',',sRMSNewAppointment.cMessage"
	    }
	    ELSE
	    {
	      RMSSendVarTextCommandSingle(dvTPWelcome[nPanelIndex],nvtAddMeetingFailureMessage[1],'A SUBJECT must be included to create a new meeting.')

	      // display failure popup page
	      SEND_COMMAND dvTPWelcome[nPanelIndex],"'@PPN-', RMSPopupMtgRequestFailed,';',RMSWelcomePage"	
	    }
        }
    }
  }  
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(*******************************************)
(* LEVEL: Engine Virtual Device            *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
CHANNEL_EVENT[vdvRMSEngine,0]
{
  ON:
  {
    SWITCH (CHANNEL.CHANNEL)
    {
      // Server is online
      CASE RMS_CH_SERVER_ONLINE:
      {
      }
    }
  }
  OFF:
  {
    STACK_VAR
    INTEGER nLoop

    SWITCH (CHANNEL.CHANNEL)
    {
      // Server is offline
      CASE RMS_CH_SERVER_ONLINE:
      {

	// clear appointment stats
	sCurrentApptStats.nCurrentApptIndex = 0
	sCurrentApptStats.nMinutesTillEnd = 0
	sCurrentApptStats.nNextApptIndex = 0
	sCurrentApptStats.nMinutesTillNext = 0
	sCurrentApptStats.nFirstApptIndex = 0
	sCurrentApptStats.nLastApptIndex = 0
	sCurrentApptStats.nApptsRemain = 0
	sCurrentApptStats.nHistCurApptIndex = 0
	sCurrentApptStats.nHistNextApptIndex = 0
	sCurrentApptStats.nPrepApptIndex = 0
	sCurrentApptStats.bMeetingEndWarned = 0
	sCurrentApptStats.bMeetingEndAcked = 0

        // Clean up appointments and update
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
	sCalendarAppts.nTotalAppointments = 0
        sCalendarAppts.nReceiveIndex = 0
#END_IF // RMS_UI_WELCOME_CODE_ONLY
        sTodaysAppts.nTotalAppointments = 0
        sTodaysAppts.nReceiveIndex = 0
        FOR(nLoop = 1; nLoop <= MAX_LENGTH_ARRAY(sTodaysAppts.chApptList); nLoop++)
        {	
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
          sCalendarAppts.chApptList[nLoop] = 0
#END_IF // RMS_UI_WELCOME_CODE_ONLY
          sTodaysAppts.chApptList[nLoop] = 0
        }

        // Clear Month Appts
        FOR(nLoop = 1; nLoop <= 31; nLoop++)
        {
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
          sCalendarAppts.chMonthlyAppts[nLoop] = 0
#END_IF // RMS_UI_WELCOME_CODE_ONLY
          sTodaysAppts.chMonthlyAppts[nLoop] = 0
        }

        // Draw Welcome TP
        CANCEL_WAIT 'RMSdvTPWelcomeOnline'
        RMSPrepForNextAppt(TRUE)
        RMSScheduleDraw(dvTpWelcome,2,sTodaysAppts)

        // Draw Main TP
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        CANCEL_WAIT 'RMSdvTPOnline'
        CANCEL_WAIT 'DisplayCalendarIcons'
        RMSCalendarDrawIcons()
        RMSScheduleDraw(dvTp,1,sCalendarAppts)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      }
    }
  }
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(*******************************************)
(* LEVEL: Engine Virtual Device            *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
LEVEL_EVENT[vdvRMSEngine,0]
{
  SWITCH (LEVEL.INPUT.LEVEL)
  {
    // Current Appointment
    CASE RMS_LVL_CUR_APPT_IDX:
      sCurrentApptStats.nCurrentApptIndex = LEVEL.VALUE
    CASE RMS_LVL_MIN_REMAIN:
      sCurrentApptStats.nMinutesTillEnd = LEVEL.VALUE
    // Next Appointment
    CASE RMS_LVL_NEXT_APPT_IDX:
      sCurrentApptStats.nNextApptIndex = LEVEL.VALUE
    CASE RMS_LVL_MIN_TILL_NEXT:
      sCurrentApptStats.nMinutesTillNext = LEVEL.VALUE
    CASE RMS_LVL_FIRST_APPT_IDX:
      sCurrentApptStats.nFirstApptIndex = LEVEL.VALUE
    CASE RMS_LVL_LAST_APPT_IDX:
      sCurrentApptStats.nLastApptIndex = LEVEL.VALUE
    CASE RMS_LVL_APPTS_REMAIN:
      sCurrentApptStats.nApptsRemain = LEVEL.VALUE
  }

  // Prep for appointment
  // Beware - more changes may be on the way so wait till we have them all
  CANCEL_WAIT 'RMSPrepAppt'
  WAIT 5 'RMSPrepAppt'
    RMSPrepForNextAppt(FALSE)
}
#END_IF // RMS_UI_HELP_CODE_ONLY

(*******************************************)
(* DATA: Engine Virtual Device             *)
(*******************************************)
DATA_EVENT[vdvRMSEngine]
{
  // Online
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
  ONLINE:
  {
    STACK_VAR
    INTEGER nLoop
    INTEGER nMaj
    INTEGER nMin
    INTEGER nBuild

    // Dynamic Images
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
    FOR (nLoop = 1; nLoop <= MAX_LENGTH_ARRAY(dvTP); nLoop++)
    {
      IF (DEVICE_ID(dvTP[nLoop]) >= 256)
      {
        RMSGetVersion(dvTP[nLoop],nMaj,nMin,nBuild)
        IF (nMin >= RMS_G4_TARGET_MINOR)
          ON[vdvRMSEngine,RMS_CH_SUPPORT_DI]
        ELSE
          SEND_STRING 0,"'RMS: The G4 panel "',RMSDevToString(dvTP[nLoop]),'" cannot support dynamic images.  Please upgrade the firmware to 2.',ITOA(RMS_G4_TARGET_MINOR),'.xx'"
      }
    }
#END_IF // RMS_UI_WELCOME_CODE_ONLY
    FOR (nLoop = 1; nLoop <= MAX_LENGTH_ARRAY(dvTPWelcome); nLoop++)
    {
      IF (DEVICE_ID(dvTPWelcome[nLoop]) >= 256)
      {
        RMSGetVersion(dvTPWelcome[nLoop],nMaj,nMin,nBuild)
        IF (nMin >= RMS_G4_TARGET_MINOR)
          ON[vdvRMSEngine,RMS_CH_SUPPORT_DI]
        ELSE
          SEND_STRING 0,"'RMS: The G4 panel "',RMSDevToString(dvTPWelcome[nLoop]),'" cannot support dynamic images.  Please upgrade the firmware to 2.',ITOA(RMS_G4_TARGET_MINOR),'.xx'"
      }
    }
  }
#END_IF // RMS_UI_HELP_CODE_ONLY

  // Strings
  STRING :
  {
    STACK_VAR
    CHAR            cTemp[2000]
    CHAR            cTrash[100]
    INTEGER         nMonth
    INTEGER         nYear
    CHAR            cDate[12]
    INTEGER         nTotalAppts
    INTEGER         nIdx
    _sRMSAppointment sAppt

    SELECT
    {
      // Look for room name
      ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'ROOM NAME-'):
        sRoomInfo.cName = RMSMidString(DATA.TEXT,11,-1)

      // Look for room location
      ACTIVE (LEFT_STRING(DATA.TEXT,14) = 'ROOM LOCATION-'):
        sRoomInfo.cLocation = RMSMidString(DATA.TEXT,15,-1)

      // Look for room owner
      ACTIVE (LEFT_STRING(DATA.TEXT,11) = 'ROOM OWNER-'):
      {
        // Get Room Owner
        sRoomInfo.cOwner = RMSMidString(DATA.TEXT,12,-1)

        // Display
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        RMSDisplayRoomInfo(dvTP,sRoomInfo)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
        RMSDisplayRoomInfo(dvTPWelcome,sRoomInfo)
#END_IF // RMS_UI_HELP_CODE_ONLY
      }
      // Look for web server
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(DATA.TEXT,11) = 'WEB SERVER-'):
        cServerHostPort = RMSMidString(DATA.TEXT,12,-1)
#END_IF // RMS_UI_HELP_CODE_ONLY

      // Look for web root
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(DATA.TEXT,9) = 'WEB ROOT-'):
        cServerWebRoot = RMSMidString(DATA.TEXT,10,-1)
#END_IF // RMS_UI_HELP_CODE_ONLY

      // Look for help message
      ACTIVE (LEFT_STRING(DATA.TEXT,5) = 'MESG-'):
      {
        // Get new end time
        cTemp = RMSMidString(DATA.TEXT,6,-1)
        nIdx = ATOI(RMSParseCommaSepString(cTemp))

        // Display Message
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        RMSPostHelpResponse(nIdx,cTemp)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      }

      // Look for questions
      // 'QUESTION-<QID>,<Flags>,<Q>,<A1>,<A2>,<A3>,<A4>'
      ACTIVE (LEFT_STRING(DATA.TEXT,9) = 'QUESTION-'):
      {
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        // Get Question
        cTemp = RMSMidString(DATA.TEXT,10,-1)
        nHDQuestionID = ATOI(RMSParseCommaSepString(cTemp))
        nHDQuestionFlags = ATOI(RMSParseCommaSepString(cTemp))
        cHDQuestion = RMSParseCommaSepString(cTemp)
        cHDAnswers[1]  = RMSParseCommaSepString(cTemp)
        cHDAnswers[2]  = RMSParseCommaSepString(cTemp)
        cHDAnswers[3]  = RMSParseCommaSepString(cTemp)
        cHDAnswers[4]  = RMSParseCommaSepString(cTemp)
        RMSPostHelpQuestion(nHDQuestionFlags,cHDQuestion,cHDAnswers)
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      }

      // Look for appointment changed
      ACTIVE (LEFT_STRING(DATA.TEXT,7) = 'CHANGE-'):
      {
        // Find Date? - Get list.  Engine keep tracks of today so no need to re-request it
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
        cTemp = TDLDateSerial(sCalendar.nMonth, sCalendar.nDay, sCalendar.nYear, 0, FALSE)
        IF (cTemp <> LDATE)
        {
          // Our date is in the list, get new list
          IF (FIND_STRING(DATA.TEXT,cTemp,1))
            SEND_COMMAND vdvRMSEngine,"'GET APPTS-',cTemp"
        }
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY
      }
      // Look for appointment count
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(DATA.TEXT,11) = 'APPT COUNT-'):
      {
        // Get Appointment Count
        cTemp = RMSMidString(DATA.TEXT,12,-1)
        nMonth = ATOI(RMSParseCommaSepString(cTemp))
        nYear = ATOI(RMSParseCommaSepString(cTemp))

        // Copy to calendar
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        IF (nMonth == sCalendar.nMonth && nYear == sCalendar.nYear)
        {
          // Save this
          sCalendarAppts.chMonthlyAppts = cTemp

          // Update Feedback - We may more information in though...
          // However, this is no reason not to display this now.
          CANCEL_WAIT 'DisplayCalendarIcons'
          RMSCalendarDrawIcons()
        }
#END_IF // RMS_UI_WELCOME_CODE_ONLY

        // Copy to today - Not really used but we should keep it
        IF (TYPE_CAST(nMonth) == DATE_TO_MONTH(LDATE) && TYPE_CAST(nYear) == DATE_TO_YEAR(LDATE))
          sTodaysAppts.chMonthlyAppts = cTemp
      }
#END_IF // RMS_UI_HELP_CODE_ONLY

      // Look for appointment list
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'APPT LIST-'):
      {
        // Get Appointment List
        cTemp = RMSMidString(DATA.TEXT,11,-1)
        cDate = RMSParseCommaSepString(cTemp)
        nTotalAppts = ATOI(RMSParseCommaSepString(cTemp))

        // Copy to calendar
        // Save this - Wait to draw since we need actual appointments
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
        IF (cDate = TDLDateSerial(sCalendar.nMonth, sCalendar.nDay, sCalendar.nYear, 0, FALSE))
        {
          sCalendarAppts.cDate = cDate
          sCalendarAppts.chApptList = cTemp
          sCalendarAppts.nTotalAppointments = nTotalAppts
          sCalendarAppts.nReceiveIndex = 1

          // Done?  Draw it!
          IF (sCalendarAppts.nTotalAppointments == 0)
          {
            sCalendarAppts.nReceiveIndex = 0
            RMSScheduleDraw(dvTp,1,sCalendarAppts)
          }
        }
#END_IF // RMS_UI_WELCOME_CODE_ONLY

        // Copy to today
        // Save this - Wait to draw since we need actual appointments
        IF (cDate == LDATE)
        {
          sTodaysAppts.chApptList = cTemp
          sTodaysAppts.nTotalAppointments = nTotalAppts
          sTodaysAppts.nReceiveIndex = 1

          // Done?  Draw it!
          IF (sTodaysAppts.nTotalAppointments == 0)
          {
            sTodaysAppts.nReceiveIndex = 0
            RMSScheduleDraw(dvTpWelcome,2,sTodaysAppts)
	    
            // Display Appt Info & Reset history
            RMSPrepForNextAppt(TRUE)
          }
        }
      }
#END_IF // RMS_UI_HELP_CODE_ONLY

      // Look for appointments
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(DATA.TEXT,5) = 'APPT-'):
      {
        // Get Appointment List
        cTemp = RMSMidString(DATA.TEXT,6,-1)
        nIdx = ATOI(RMSParseCommaSepString(cTemp))

        // Decode and store
        IF (nIdx && RMSDecodeAppointmentString(sAppt,cTemp) >= 0)
        {
          // Copy to calendar
          // Save this - Wait to draw since we need actual appointments
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
          IF (nIdx == sCalendarAppts.nReceiveIndex)
          {
            sCalendarAppts.sAppts[nIdx] = sAppt
            sCalendarAppts.nReceiveIndex++

            // Done?  Draw it!
            IF (sCalendarAppts.nReceiveIndex > sCalendarAppts.nTotalAppointments)
            {
              sCalendarAppts.nReceiveIndex = 0
              RMSScheduleDraw(dvTp,1,sCalendarAppts)
            }
          }
#END_IF // RMS_UI_WELCOME_CODE_ONLY

          // Copy to today
          // Save this - Wait to draw since we need actual appointments
          IF (nIdx == sTodaysAppts.nReceiveIndex)
          {
            sTodaysAppts.sAppts[nIdx] = sAppt
            sTodaysAppts.nReceiveIndex++

            // Done?  Draw it!
            IF (sTodaysAppts.nReceiveIndex > sTodaysAppts.nTotalAppointments)
            {
              sTodaysAppts.nReceiveIndex = 0
              RMSScheduleDraw(dvTpWelcome,2,sTodaysAppts)

              // Display Appt Info & Reset history
              RMSPrepForNextAppt(TRUE)
            }
          }
        }
      }
#END_IF // RMS_UI_HELP_CODE_ONLY

#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY

	(*-- RESERVE-NO,<start date>,<start time>,<duration>,<subject>,<error description> --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,11) = 'RESERVE-NO,'):
	{
	    cTemp  = RMSMidString(DATA.TEXT,12,-1)
	    cTrash = RMSParseCommaSepString(cTemp)
	    cTrash = RMSParseCommaSepString(cTemp)
	    cTrash = RMSParseCommaSepString(cTemp)
	    cTrash = RMSParseCommaSepString(cTemp)

		RMSSendVarTextCommand(dvReserveTP,nvtAddMeetingFailureMessage[1],cTemp)
		SEND_COMMAND dvReserveTP, "'@PPN-', RMSPopupMtgRequestFailed"
	}
	(*-- RESERVE-YES,<start date>,<start time>,<duration>,<subject> --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,12) = 'RESERVE-YES,'):
	{
		RMSMessage(dvReserveTP, RMSMsgMtgRequestConfirmed, RMSMessageTypeConfirm, '', '');
	}
	
	(*-- EXTEND-NO,<error description> --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'EXTEND-NO,'):
	{
	    cTemp  = RMSMidString(DATA.TEXT,11,-1)
		RMSMessage(dvExtendTP, RMSMsgMtgExtendFailed, RMSMessageTypeFailed, '', cTemp);
	}
	(*-- EXTEND-YES > --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'EXTEND-YES'):
	{
		RMSMessage(dvExtendTP, RMSMsgMtgExtendConfirmed, RMSMessageTypeConfirm, '', '');
	    sCurrentApptStats.bMeetingEndWarned = TRUE
	    sCurrentApptStats.bMeetingEndAcked = TRUE	    
	}
	
	(*-- ENDNOW-NO,<error description> --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'ENDNOW-NO,'):
	{
	    cTemp  = RMSMidString(DATA.TEXT,11,-1)
		RMSMessage(dvEndNowTP, RMSMsgMtgEndNowFailed, RMSMessageTypeFailed, '', cTemp);
	}
	(*-- ENDNOW-YES > --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,10) = 'ENDNOW-YES'):
	{
		RMSMessage(dvEndNowTP, RMSMsgMtgEndNowConfirmed, RMSMessageTypeConfirm, '', '');
	}
	
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
	(*-- DATECHANGED-MM/DD/YYYY --*)
	ACTIVE (LEFT_STRING(DATA.TEXT,12) = 'DATECHANGED-'):
	{
	     // if the date changes, make sure the select TODAY on the calendar 	   
	     RMSSelectCalendarDay(0,TRUE) 
	}
	
#END_IF // RMS_UI_WELCOME_CODE_ONLY
#END_IF // RMS_UI_HELP_CODE_ONLY


	(*-- RMSENGINEINFO-Name,Version--*)
	ACTIVE (LEFT_STRING(DATA.TEXT,14) = 'RMSENGINEINFO-'):
	{
	    STACK_VAR 
	      CHAR cEngineName[50]
	      CHAR cEngineVersion[50]
	    
	    cTemp  = RMSMidString(DATA.TEXT,15,-1)
	    
	    // engine name
	    cEngineName = RMSParseCommaSepString(cTemp)	     
	    
	    // engine version	    
	    cEngineVersion = RMSParseCommaSepString(cTemp)	     
	    
	    // update room touch panels with engine info
	    #IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
		SEND_COMMAND dvTP, "'@TXT',nvtVersionInfo[1],cEngineName,' v',cEngineVersion"
	    #END_IF
	    
	    // update welcome touch panels with engine info
	    #IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
		SEND_COMMAND dvTPWelcome, "'@TXT',nvtVersionInfo[1],cEngineName,' v',cEngineVersion"	    
	    #END_IF
	}
    }
  }

  // Commands
  COMMAND:
  {
    // Vars
    STACK_VAR
    CHAR            cCmd[100]
    CHAR            cUpperCmd[100]

    // Process Message
    cUpperCmd = UPPER_STRING(DATA.TEXT)
    cCmd = DATA.TEXT
    SELECT
    {
      (***********************************************************)
      (* DATE/TIME FORMAT *)
      (***********************************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
      ACTIVE (LEFT_STRING(cUpperCmd,9) = 'DFORMAT-D'):
        ON[bUKDate]
      ACTIVE (LEFT_STRING(cUpperCmd,9) = 'DFORMAT-M'):
        OFF[bUKDate]
      ACTIVE (LEFT_STRING(cUpperCmd,9) = 'TFORMAT-2'):
        ON[bMilitaryTime]
      ACTIVE (LEFT_STRING(cUpperCmd,9) = 'TFORMAT-1'):
        OFF[bMilitaryTime]
#END_IF // RMS_UI_HELP_CODE_ONLY
      //**********************************************************
      // Debug
      // 'DEBUGON'
      // 'DEBUGOFF'
      //**********************************************************
      ACTIVE (LEFT_STRING(cUpperCmd,5) = 'DEBUG'):
      {
        OFF[bRMSDebug]
        IF (FIND_STRING(cUpperCmd,'ON',1))
          ON[bRMSDebug]
      }
      //*********************************************************
      // Version Info
      //*********************************************************
      ACTIVE (LEFT_STRING(cUpperCmd,7) = 'VERSION'):
      {
        // What Version?
        SEND_STRING 0,"'Running ',__RMS_UI_NAME__,', v',__RMS_UI_VERSION__"
        SEND_STRING 0,"'  Running ',__RMS_UI_BASE_NAME__,', v',__RMS_UI_BASE_VERSION__"
        RMSDeviceMonitorPrintVersion()
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
        TDLPrintVersion()
#END_IF // RMS_UI_HELP_CODE_ONLY
      }
    }
  }
}


(*******************************************)
(* TIMLINE:  Room Panel Inactivity         *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
TIMELINE_EVENT[TL_SCH_VIEW_TIME_ROOM]
{
    RMSUpdateScheduleTimeView(dvTP,RMSRoomPage)
}
#END_IF // RMS_UI_HELP_CODE_ONLY
#END_IF // RMS_UI_WELCOME_CODE_ONLY


(*******************************************)
(* TIMLINE:  Welcome Panel Inactivity      *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
TIMELINE_EVENT[TL_SCH_VIEW_TIME_WELCOME]
{
    RMSUpdateScheduleTimeView(dvTPWelcome,RMSWelcomePage)
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(*******************************************)
(* BUTTON: Do Not Disturb                  *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTP, nchDoNotDisturb[1]] 
{
  PUSH:
  {
      // toggle do not disturb flag
      RMSSetDoNotDisturb(!(bDoNotDisturb))
  }
}
#END_IF
#END_IF


(*******************************************)
(* WELCOME BUTTON: Ring Doorbell           *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTPWelcome,nchDoorbell[1]]
{
   PUSH:
   {
      // ensure the do not disturb is not in effect
      IF (!(bDoNotDisturb))
      {
         // confirmation beeps on calling welcome panel
	 IF(RMS_BEEP_DOORBELL_REQUEST)
	 {
           SEND_COMMAND BUTTON.INPUT.DEVICE, "'ADBEEP'"
	 }

         // wake up in-room touch panel
         SEND_COMMAND dvTP, "'WAKE'"
	 
         // ring doorbell on in-room touch panel
	 IF(RMS_BEEP_DOORBELL_RECEIPT)
	 {
           SEND_COMMAND dvTP, "'ADBEEP'"
	 }

	 // display doorbell popup page on in-room touch panel
	 SEND_COMMAND dvTP,"'PAGE-',RMSRoomPage"
	 SEND_COMMAND dvTP,"'@PPN-',RMSPopupDoorbell,';',RMSRoomPage"
	 
	 // button feedback
	 ON[BUTTON.INPUT.DEVICE, BUTTON.INPUT.CHANNEL]
      }
   }
   RELEASE:
   {
      // button feedback
      OFF[BUTTON.INPUT.DEVICE, BUTTON.INPUT.CHANNEL]
   }
}
#END_IF
#END_IF


(*******************************************)
(* BUTTON: Reserve New Appointment         *)
(*******************************************)
#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY
BUTTON_EVENT[dvTPWelcome,nchMeetingReserve]
#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY
BUTTON_EVENT[dvTP,nchMeetingReserve]
#END_IF
{
   PUSH:
   {
	STACK_VAR INTEGER nIndex

	// ensure server is online
	IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
	{      
	      // determine button index
	      nIndex = GET_LAST(nchMeetingReserve)
	
	       // set reservation touch panel
	       dvReserveTP[1] = BUTTON.INPUT.DEVICE
	       SET_LENGTH_ARRAY(dvReserveTP,1)
	
	      SWITCH(nIndex)
	      {
		CASE 1 :   // increase duration time
		{
		    // increment duration 
		    RMSIncrementNewAppointmentDuration(dvReserveTP)
		}
		CASE 2 :   // decrease duration time
		{
		    // decrement duration 
		    RMSDecrementNewAppointmentDuration(dvReserveTP)
		}
		CASE 3 :   // display reserve new meeting popup page
		{
		   // set date and time for new appointment
		   RMSDisplayNewAppointmentInfo(dvReserveTP,RMS_APPT_FIELD_ALL)
	
		   // no appointment in this time slot; display no appointment popup page
		   SEND_COMMAND BUTTON.INPUT.DEVICE, "'@PPN-',RMSPopupMtgRequest"
		}
	      }
	}
	ELSE    
	{
	    SEND_COMMAND BUTTON.INPUT.DEVICE,"'@PPN-',RMSPopupServerOffline"
	}    	      
    }
    HOLD[1, REPEAT]:
    {
      STACK_VAR INTEGER nIndex

	// ensure server is online
	IF([vdvRMSEngine,RMS_CH_SERVER_ONLINE])
	{ 
	      // determine button index
	      nIndex = GET_LAST(nchMeetingReserve)
	
	      // set reservation touch panel
	      dvReserveTP[1] = BUTTON.INPUT.DEVICE
	      SET_LENGTH_ARRAY(dvReserveTP,1)
	
	      SWITCH(nIndex)
	      {
		CASE 1 :   // increase duration time
		{
		    // increment duration 
		    RMSIncrementNewAppointmentDuration(dvReserveTP)
		}
		CASE 2 :   // decrease duration time
		{
		    // decrement duration 
		    RMSDecrementNewAppointmentDuration(dvReserveTP)
		}
	      }
	}
    }
}
#END_IF // RMS_UI_HELP_CODE_ONLY


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


#IF_NOT_DEFINED RMS_UI_HELP_CODE_ONLY


(* IN-ROOM PANEL FEEDBACK *)

#IF_NOT_DEFINED RMS_UI_WELCOME_CODE_ONLY    
    //[dvTP, nchMeetingStatus[3]] = (sCurrentApptStats.nCurrentApptIndex)      // meeting in session feedback
#END_IF // RMS_UI_WELCOME_CODE_ONLY


(* WELCOME PANEL FEEDBACK *)
//[dvTPWelcome, nchMeetingStatus[3]] = (sCurrentApptStats.nCurrentApptIndex)   // meeting in session feedback

#END_IF // RMS_UI_HELP_CODE_ONLY

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
