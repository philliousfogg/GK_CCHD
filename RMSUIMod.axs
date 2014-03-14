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

MODULE_NAME='RMSUIMod' (DEV     vdvRMSEngine,
			DEV	vdvSystem,
                        DEV     dvTP[],
			DEV     dvTP_Base[],
                        DEV     dvTPWelcome[],
			DEV     dvTPWelcome_Base[],
			CHAR    strDefaultSubject[],
			CHAR    strDefaultMsg[])
			
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 1                                *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Version For Code
CHAR __RMS_UI_NAME__[]      = 'RMSUIMod'
CHAR __RMS_UI_VERSION__[]   = '3.2.31'

//
// The following constants allow
// code initiated touch panel beeps
// to be enabled or disabled.
//
RMS_BEEP_DOORBELL_REQUEST    = 1
RMS_BEEP_DOORBELL_RECEIPT    = 0
RMS_BEEP_PRESET_RUN          = 1


//
// the nunmber of minutes ahead 
// to prepare for the next meeting.
//
RMS_WELCOME_PREP_TIME_MIN    = 15   

//
// the number of minutes before a 
// meeting ends to display a warning dialog
//
RMS_WARN_TIME_MIN            = 5    

//
// the number of minutes to extend a 
// meeting when using the EXTEND meeting
// button
//
RMS_EXTEND_TIME_MIN          = 15


//
// Colors for appointment blocks in
// the touch panel daily schedule listing
//
RMS_G4_USER_SCHEDULE_COLOR_0[9] = '#EEEEEE00' //73 w/ transparency
RMS_G4_USER_SCHEDULE_COLOR_1[9] = '#007F407F' //34 w/ transparency
RMS_G4_USER_SCHEDULE_COLOR_2[9] = '#0070DF7F' //43 w/ transparency



//
// This array of times defines the time at which the panels
// will change the schedule view to the appropriate time 
// window.  Format is {'hh:mm:ss','Popup Page Command'}
//
RMSScheduleTimeView[][2][30] = {{'00:00:00','@PPN-rmsViewSchedule1'},
                                {'07:00:00','@PPF-rmsViewSchedule1'},
                                {'14:00:00','@PPN-rmsViewSchedule3'},
                                {'20:00:00','@PPN-rmsViewSchedule4'}}


//
// This array of time blocks define the actual time
// value for each block element in the daily view 
// schedule table on the touch panels.
// format: 'hh:mm:ss'
//
RMSTimeBlocks[][8]           = {'00:00:00',
				'00:15:00',
				'00:30:00',
				'00:45:00',
				'01:00:00',
				'01:15:00',
				'01:30:00',
				'01:45:00',
				'02:00:00',
				'02:15:00',
				'02:30:00',
				'02:45:00',
				'03:00:00',
				'03:15:00',
				'03:30:00',
				'03:45:00',
				'04:00:00',
				'04:15:00',
				'04:30:00',
				'04:45:00',
				'05:00:00',
				'05:15:00',
				'05:30:00',
				'05:45:00',
				'06:00:00',
				'06:15:00',
				'06:30:00',
				'06:45:00',
				'07:00:00',
				'07:15:00',
				'07:30:00',
				'07:45:00',
				'08:00:00',
				'08:15:00',
				'08:30:00',
				'08:45:00',
				'09:00:00',
				'09:15:00',
				'09:30:00',
				'09:45:00',
				'10:00:00',
				'10:15:00',
				'10:30:00',
				'10:45:00',
				'11:00:00',
				'11:15:00',
				'11:30:00',
				'11:45:00',
                                '12:00:00',
				'12:15:00',
				'12:30:00',
				'12:45:00',
				'13:00:00',
				'13:15:00',
				'13:30:00',
				'13:45:00',
				'14:00:00',
				'14:15:00',
				'14:30:00',
				'14:45:00',
				'15:00:00',
				'15:15:00',
				'15:30:00',
				'15:45:00',
				'16:00:00',
				'16:15:00',
				'16:30:00',
				'16:45:00',
				'17:00:00',
				'17:15:00',
				'17:30:00',
				'17:45:00',
				'18:00:00',
				'18:15:00',
				'18:30:00',
				'18:45:00',
				'19:00:00',
				'19:15:00',
				'19:30:00',
				'19:45:00',
				'20:00:00',
				'20:15:00',
				'20:30:00',
				'20:45:00',
				'21:00:00',
				'21:15:00',
				'21:30:00',
				'21:45:00',
				'22:00:00',
				'22:15:00',
				'22:30:00',
				'22:45:00',
				'23:00:00',
				'23:15:00',
				'23:30:00',
				'23:45:00'
				}
				
	

//
// New Appointment Default Duration Index 
//  (used with the 'RMSAppointmentDuration' array below )
//
RMSAppointmentDurationDefaultIndex = 4   // Index #4 = 1 hour

//
// New Appoitnment Duration Elements : {Number of Minutes, Text Display Interval}
//
RMSAppointmentDuration[][2][25] =    {{'15', '15 minutes'},
                                      {'30', '30 minutes'},
				      {'45', '45 minutes'}, 
				      {'60', '1 hour'},
				      {'75', '1 hour 15 minutes'},
				      {'90', '1 hour 30 minutes'},
				      {'105','1 hour 45 minutes'},
				      {'120','2 hours'},
				      {'135','2 hours 15 minutes'},
				      {'150','2 hours 30 minutes'},
				      {'165','2 hours 45 minutes'},
				      {'180','3 hours'},
				      {'195','3 hours 15 minutes'},
				      {'210','3 hours 30 minutes'},
				      {'225','3 hours 45 minutes'},
				      {'240','4 hours'},
				      {'255','4 hours 15 minutes'},
				      {'270','4 hours 30 minutes'},
				      {'285','4 hours 45 minutes'},
				      {'300','5 hours'},
				      {'315','5 hours 15 minutes'},
				      {'330','5 hours 30 minutes'},
				      {'345','5 hours 45 minutes'},
				      {'360','6 hours'},
				      {'375','6 hours 15 minutes'},
				      {'390','6 hours 30 minutes'},
				      {'405','6 hours 45 minutes'},
				      {'420','7 hours'},
				      {'435','7 hours 15 minutes'},
				      {'450','7 hours 30 minutes'},
				      {'465','7 hours 45 minutes'},
				      {'480','8 hours'}				      
				      }



(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE



(***********************************************************)
(*       RMS/MeetingManager Channels and Var Text          *)
(***********************************************************)

// Calendar Dates
VOLATILE INTEGER nchCalendar[] =
{
  1 , // Row 1, Column 1
  2 , // Row 1, Column 2
  3 , // Row 1, Column 3
  4 , // Row 1, Column 4
  5 , // Row 1, Column 5
  6 , // Row 1, Column 6
  7 , // Row 1, Column 7
  8 , // Row 2, Column 1
  9 , // Row 2, Column 2
  10, // Row 2, Column 3
  11, // Row 2, Column 4
  12, // Row 2, Column 5
  13, // Row 2, Column 6
  14, // Row 2, Column 7
  15, // Row 3, Column 1
  16, // Row 3, Column 2
  17, // Row 3, Column 3
  18, // Row 3, Column 4
  19, // Row 3, Column 5
  20, // Row 3, Column 6
  21, // Row 3, Column 7
  22, // Row 4, Column 1
  23, // Row 4, Column 2
  24, // Row 4, Column 3
  25, // Row 4, Column 4
  26, // Row 4, Column 5
  27, // Row 4, Column 6
  28, // Row 4, Column 7
  29, // Row 5, Column 1
  30, // Row 5, Column 2
  31, // Row 5, Column 3
  32, // Row 5, Column 4
  33, // Row 5, Column 5
  34, // Row 5, Column 6
  35, // Row 5, Column 7
  36, // Row 6, Column 1
  37  // Row 6, Column 2
}

// Welcome Panel Control Buttons
VOLATILE INTEGER  nchWelcome[] =
{
  54   // Welcome Image
}


// Day Select Buttons
VOLATILE INTEGER  nchDaySelect[] =
{
  55  // Jump To Today
}

// Month Select Buttons
VOLATILE INTEGER  nchMonthSelect[] =
{
  57,  // Jan
  58,  // Feb
  59,  // Mar
  60,  // Apr
  61,  // May
  62,  // Jun
  63,  // Jul
  64,  // Aug
  65,  // Sept
  66,  // Oct
  67,  // Nov
  68   // Dec
}

// Year Select Buttons
VOLATILE INTEGER  nchYearSelect[] =
{
  71,  // Current Year
  72,  // Current Year + 1
  73,  // Current Year + 2
  74,  // Current Year + 3
  75   // Current Year + 4
}

// Reserve Meeting Control Buttons (on Inside Panel Only)
VOLATILE INTEGER nchMeetingReserve[] =
{
  83,   // Increase Duration (+)
  84,   // Decrease Duration (-)
  85    // Reserve Meeting Button
}

// Meeting Control (Main Touch Panel Only)
VOLATILE INTEGER nchMeetingControl[] =
{
  91,  // Run Preset
  92,  // Help Request
  93,  // Maintenence Request
  94,  // Extend Meeting/Yes To Extend
  95,  // Do not Extend Meeting
  96,  // End Meeting Now/Yes To End
  97,  // Display Meeting Info/Details     
  98   // Create Meeting Now
}


// Calendar Icons - Channels for Days
VOLATILE INTEGER nchCalendarIcons[] =
{
  101, // Row 1, Column 1
  102, // Row 1, Column 2
  103, // Row 1, Column 3
  104, // Row 1, Column 4
  105, // Row 1, Column 5
  106, // Row 1, Column 6
  107, // Row 1, Column 7
  108, // Row 2, Column 1
  109, // Row 2, Column 2
  110, // Row 2, Column 3
  111, // Row 2, Column 4
  112, // Row 2, Column 5
  113, // Row 2, Column 6
  114, // Row 2, Column 7
  115, // Row 3, Column 1
  116, // Row 3, Column 2
  117, // Row 3, Column 3
  118, // Row 3, Column 4
  119, // Row 3, Column 5
  120, // Row 3, Column 6
  121, // Row 3, Column 7
  122, // Row 4, Column 1
  123, // Row 4, Column 2
  124, // Row 4, Column 3
  125, // Row 4, Column 4
  126, // Row 4, Column 5
  127, // Row 4, Column 6
  128, // Row 4, Column 7
  129, // Row 5, Column 1
  130, // Row 5, Column 2
  131, // Row 5, Column 3
  132, // Row 5, Column 4
  133, // Row 5, Column 5
  134, // Row 5, Column 6
  135, // Row 5, Column 7
  136, // Row 6, Column 1
  137  // Row 6, Column 2
}

// Selected Welcome Image
VOLATILE INTEGER  nchSelectedWelcome[] =
{
  151  // Welcome Image
}

// Help Response (Main Touch Panel Only)
VOLATILE INTEGER nchHelpAnswer[] =
{
  176,  // Help Answer 1
  177,  // Help Answer 2
  178,  // Help Answer 3
  179   // Help Answer 4
}


// Retrieving Appointments
VOLATILE INTEGER nchRetrievingAppts[]=
{
  249   // Display Busy Indicator
}

// Meeting Control (Main Touch Panel Only)
VOLATILE INTEGER nchMeetingStatus[] =
{
  250, // Displaying Next Appointment
  251, // Timer is Active
  252  // Meeting Is Session/Room In Use
}

// Doorbell Request Button (on Welcome Panel Only)
VOLATILE INTEGER nchDoorbell[] =
{
  253   // Ring Doorbell in Room
}

// Do Not Disturb
VOLATILE INTEGER nchDoNotDisturb[]=
{
  254   // Do Not Disturb Indicator
}


// Appointment Time Fields
VOLATILE INTEGER nchTimeFields[]=
{
  301,  // 00:00
  302,  // 00:15
  303,  // 00:30
  304,  // 00:45
  305,  // 01:00
  306,  // 01:15
  307,  // 01:30
  308,  // 01:45
  309,  // 02:00
  310,  // 02:15
  311,  // 02:30
  312,  // 02:45
  313,  // 03:00
  314,  // 03:15
  315,  // 03:30
  316,  // 03:45
  317,  // 04:00
  318,  // 04:15
  319,  // 04:30
  320,  // 04:45
  321,  // 05:00
  322,  // 05:15
  323,  // 05:30
  324,  // 05:45
  325,  // 06:00
  326,  // 06:15
  327,  // 06:30
  328,  // 06:45
  329,  // 07:00
  330,  // 07:15
  331,  // 07:30
  332,  // 07:45
  333,  // 08:00
  334,  // 08:15
  335,  // 08:30
  336,  // 08:45
  337,	// 09:00
  338,  // 09:15
  339,  // 09:30
  340,  // 09:45
  341,  // 10:00
  342,  // 10:15
  343,  // 10:30
  344,  // 10:45
  345,  // 11:00
  346,  // 11:15
  347,  // 11:30
  348,  // 11:45
  349,  // 12:00
  350,  // 12:15
  351,  // 12:30
  352,  // 12:45
  353,  // 13:00
  354,  // 13:15
  355,  // 13:30
  356,  // 13:45
  357,  // 14:00 
  358,  // 14:15
  359,  // 14:30
  360,  // 14:45
  361,  // 15:00
  362,  // 15:15 
  363,  // 15:30
  364,  // 15:45
  365,  // 16:00
  366,  // 16:15
  367,  // 16:30
  368,  // 16:45
  369,  // 17:00
  370,  // 17:15
  371,  // 17:30
  372,  // 17:45
  373,  // 18:00
  374,  // 18:15
  375,  // 18:30
  376,  // 18:45
  377,  // 19:00
  378,  // 19:15
  379,  // 19:30
  380,  // 19:45
  381,  // 20:00
  382,  // 20:15
  383,  // 20:30
  384,  // 20:45
  385,  // 21:00
  386,  // 21:15
  387,  // 21:30
  388,  // 21:45
  389,  // 22:00
  390,  // 22:15
  391,  // 22:30
  392,  // 22:45
  393,  // 23:00
  394,  // 23:15
  395,  // 23:30
  396   // 23:45
}


////////////////////////////////////////////
// Variable Text Codes
////////////////////////////////////////////



// Calendar Dates
VOLATILE INTEGER nvtCalendar[] =
{
  1 , // Row 1, Column 1
  2 , // Row 1, Column 2
  3 , // Row 1, Column 3
  4 , // Row 1, Column 4
  5 , // Row 1, Column 5
  6 , // Row 1, Column 6
  7 , // Row 1, Column 7
  8 , // Row 2, Column 1
  9 , // Row 2, Column 2
  10, // Row 2, Column 3
  11, // Row 2, Column 4
  12, // Row 2, Column 5
  13, // Row 2, Column 6
  14, // Row 2, Column 7
  15, // Row 3, Column 1
  16, // Row 3, Column 2
  17, // Row 3, Column 3
  18, // Row 3, Column 4
  19, // Row 3, Column 5
  20, // Row 3, Column 6
  21, // Row 3, Column 7
  22, // Row 4, Column 1
  23, // Row 4, Column 2
  24, // Row 4, Column 3
  25, // Row 4, Column 4
  26, // Row 4, Column 5
  27, // Row 4, Column 6
  28, // Row 4, Column 7
  29, // Row 5, Column 1
  30, // Row 5, Column 2
  31, // Row 5, Column 3
  32, // Row 5, Column 4
  33, // Row 5, Column 5
  34, // Row 5, Column 6
  35, // Row 5, Column 7
  36, // Row 6, Column 1
  37  // Row 6, Column 2
}

// Room Info (Main & Welcome Touch Panels)
VOLATILE INTEGER nvtRoomInfo[] =
{
  51,  // Room Name
  52,  // Room Location
  53   // Room Owner
}

// Room Info (Main & Welcome Touch Panels)
VOLATILE INTEGER nvtWelcome[] =
{
  54,  // Welcome Start Time
   0,  // Welcome Stop Time - If 0, Start and End are placed in same field
  56,  // Welcome Subject 
  57,  // Welcome Scheduled By
  58,  // Welcome Attending 
  59,  // Welcome Details 
  60,  // Welcome Text 1
  61,  // Welcome Text 2
  62,  // Welcome Text 3
  63,  // Welcome Text 4
  64   // Welcome Text 5
}

// Warnings (Main Touch Panel Only)
VOLATILE INTEGER nvtWarn[] =
{
  65   // Meeting Ends in xx Minutes
}

// Text Entry Fields (Main Touch Panel Only)
VOLATILE INTEGER nvtMessageEdit[] =
{
  66,   // Help message
  67,   // Maintenance Message
  68,   // Appointment Subject Text
  69    // Appointment Message Text
}

// Current Month and Year Var Text Codes
VOLATILE INTEGER  nvtCurMonthYear[] =
{
  43,  //Current Date
  48,  //Current Selected Year
  49,  //Current Selected Month
  71,  //Current Year + 0
  72,  //Current Year + 1
  73,  //Current Year + 2
  74,  //Current Year + 3
  75   //Current Year + 4
}

// Help Response 
VOLATILE INTEGER nvtNewAppointment[] =
{
  81,  // date
  82,  // time
  83,  // duration (in minutes)
  84,  // subject
  85   // message
}

// Failure Messages 
VOLATILE INTEGER nvtAddMeetingFailureMessage[] =
{
  89   // failure reason
}

// Meeting Control (Main Touch Panel Only)
VOLATILE INTEGER nvtMeetingControl[] =
{
  91,  // Run Preset
  92,  // Help Request
  93,  // Maintenence Request
  94,  // Extend Meeting/Yes To Extend
  95,  // Do not Extend Meeting
  96,  // End Meeting Now/Yes To End
  97,  // Display Meeting Info/Details   
  98   // Create Meeting Now  
}

// Calendar Icons - Number of Appointments per day
VOLATILE INTEGER nvtCalendarIcons[] =
{
  101, // Row 1, Column 1
  102, // Row 1, Column 2
  103, // Row 1, Column 3
  104, // Row 1, Column 4
  105, // Row 1, Column 5
  106, // Row 1, Column 6
  107, // Row 1, Column 7
  108, // Row 2, Column 1
  109, // Row 2, Column 2
  110, // Row 2, Column 3
  111, // Row 2, Column 4
  112, // Row 2, Column 5
  113, // Row 2, Column 6
  114, // Row 2, Column 7
  115, // Row 3, Column 1
  116, // Row 3, Column 2
  117, // Row 3, Column 3
  118, // Row 3, Column 4
  119, // Row 3, Column 5
  120, // Row 3, Column 6
  121, // Row 3, Column 7
  122, // Row 4, Column 1
  123, // Row 4, Column 2
  124, // Row 4, Column 3
  125, // Row 4, Column 4
  126, // Row 4, Column 5
  127, // Row 4, Column 6
  128, // Row 4, Column 7
  129, // Row 5, Column 1
  130, // Row 5, Column 2
  131, // Row 5, Column 3
  132, // Row 5, Column 4
  133, // Row 5, Column 5
  134, // Row 5, Column 6
  135, // Row 5, Column 7
  136, // Row 6, Column 1
  137  // Row 6, Column 2
}

// Appointment Information
VOLATILE INTEGER nvtApptInfo[] =
{
  151,  // Select/Detail Appointment Start Time
  152,  // Select/Detail Appointment End Time
  153,  // Select/Detail Appointment Subject 
  154,  // Select/Detail Appointment Scheduled By
  155,  // Select/Detail Appointment Attending
  156,  // Select/Detail Appointment Details
  181,  // Welcome Text 1
  182,  // Welcome Text 2
  183,  // Welcome Text 3
  184,  // Welcome Text 4
  185   // Welcome Text 5
}

// Appointment Information
VOLATILE INTEGER nvtCurNextApptInfo[] =
{
  161,  // Current Appointment Start Time
  162,  // Current Appointment End Time
  163,  // Current Appointment Subject 
  164,  // Current Appointment Scheduled By
  165,  // Current Appointment Attending 
  166,  // Current Appointment Details 
  167,  // Current Appointment Time Remaining
  168,  // Next Appointment Start Time
  169,  // remaining label
  170   // next label
}

// Help Response (Main Touch Panel Only)
VOLATILE INTEGER nvtHelpResponse[] =
{
  171,  // Help Response Line 1
  172,  // Help Response Line 2
  173,  // Help Response Line 3
  174,  // Help Response Line 4
  175   // Help Response Line 5
}

// Help Response (Main Touch Panel Only)
VOLATILE INTEGER nvtHelpAnswer[] =
{
  176,  // Help Answer 1
  177,  // Help Answer 2
  178,  // Help Answer 3
  179   // Help Answer 4
}

// Doorbell Request Button (on Welcome Panel Only)
VOLATILE INTEGER nvtDoorbell[] =
{
  253   // Doorbell Button
}

// Version Messages 
VOLATILE INTEGER nvtVersionInfo[] =
{
  254,  // RMS engine version info 
  255   // RMS UI version info
}

// Appointment Time Fields
VOLATILE INTEGER nvtTimeFields[]=
{
  301,  // 00:00
  302,  // 00:15
  303,  // 00:30
  304,  // 00:45
  305,  // 01:00
  306,  // 01:15
  307,  // 01:30
  308,  // 01:45
  309,  // 02:00
  310,  // 02:15
  311,  // 02:30
  312,  // 02:45
  313,  // 03:00
  314,  // 03:15
  315,  // 03:30
  316,  // 03:45
  317,  // 04:00
  318,  // 04:15
  319,  // 04:30
  320,  // 04:45
  321,  // 05:00
  322,  // 05:15
  323,  // 05:30
  324,  // 05:45
  325,  // 06:00
  326,  // 06:15
  327,  // 06:30
  328,  // 06:45
  329,  // 07:00
  330,  // 07:15
  331,  // 07:30
  332,  // 07:45
  333,  // 08:00
  334,  // 08:15
  335,  // 08:30
  336,  // 08:45
  337,	// 09:00
  338,  // 09:15
  339,  // 09:30
  340,  // 09:45
  341,  // 10:00
  342,  // 10:15
  343,  // 10:30
  344,  // 10:45
  345,  // 11:00
  346,  // 11:15
  347,  // 11:30
  348,  // 11:45
  349,  // 12:00
  350,  // 12:15
  351,  // 12:30
  352,  // 12:45
  353,  // 13:00
  354,  // 13:15
  355,  // 13:30
  356,  // 13:45
  357,  // 14:00 
  358,  // 14:15
  359,  // 14:30
  360,  // 14:45
  361,  // 15:00
  362,  // 15:15 
  363,  // 15:30
  364,  // 15:45
  365,  // 16:00
  366,  // 16:15
  367,  // 16:30
  368,  // 16:45
  369,  // 17:00
  370,  // 17:15
  371,  // 17:30
  372,  // 17:45
  373,  // 18:00
  374,  // 18:15
  375,  // 18:30
  376,  // 18:45
  377,  // 19:00
  378,  // 19:15
  379,  // 19:30
  380,  // 19:45
  381,  // 20:00
  382,  // 20:15
  383,  // 20:30
  384,  // 20:45
  385,  // 21:00
  386,  // 21:15
  387,  // 21:30
  388,  // 21:45
  389,  // 22:00
  390,  // 22:15
  391,  // 22:30
  392,  // 22:45
  393,  // 23:00
  394,  // 23:15
  395,  // 23:30
  396   // 23:45
}

VOLATILE INTEGER nvtMessageBox[] =
{
	86, //RMSMessageExtraText 
	87, //RMSMessageText
	88  //RMSMessageIcon
}

(***********************************************************)
(*                   INCLUDE FILES GO BELOW                *)
(***********************************************************)
#INCLUDE 'ButtonsChannels.axi'
#INCLUDE 'Utilities.axi'
#INCLUDE 'RMSUIBase.axi'

DEFINE_EVENT

DATA_EVENT [vdvSystem]
{
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Parse Lesson Data
	IF ( REMOVE_STRING ( DATA.TEXT, 'GET_LESSON_DATA', 1 ) )
	{
	    STACK_VAR INTEGER index
	    
	    //Get Index
	    index = ATOI ( GetAttrValue( 'index', aCommand ) )
	    
	    if ( index > 0 )
	    {
		//Send Lesson Data
		SEND_STRING vdvSystem, "'LESSON_DATA-',
		'index=',ITOA(index),
		sTodaysAppts.sAppts[index].cWelcomeMessage,
		'&subjt=',sTodaysAppts.sAppts[index].cSubject,
		'&instr=',sTodaysAppts.sAppts[index].cScheduler,
		'&start=',sTodaysAppts.sAppts[index].cStartTime,
		'&end=',sTodaysAppts.sAppts[index].cEndTime,
		'&message=',sTodaysAppts.sAppts[index].cDetails"
	    }
	}
    }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

