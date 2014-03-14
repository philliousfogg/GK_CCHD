(*********************************************************************)
(*                                                                   *)
(*                     Time/Date Lib   (2.0.2)                       *)
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

PROGRAM_NAME='TimeDateLib'
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 1                                *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)
#IF_NOT_DEFINED __TIME_DATE_LIB__
#DEFINE __TIME_DATE_LIB__

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Version For Code 
CHAR __TIME_DATE_LIB_NAME__[]       = 'TimeDateLib.axi'
CHAR __TIME_DATE_LIB_VERSION__[]    = '2.0.2'

// Length for storage
TDL_DATE_LEN    = 20
TDL_TIME_LEN    = 10

// Days Of The Week 
TDL_SUNDAY      = 1
TDL_MONDAY      = 2
TDL_TUESDAY     = 3
TDL_WEDNESDAY   = 4
TDL_THURSDAY    = 5
TDL_FRIDAY      = 6
TDL_SATURDAY    = 7

// Some Handy Numbers 
INTEGER TDL_SECONDS_PER_MINUTE = 60
INTEGER TDL_MINUTES_PER_HOUR   = 60
INTEGER TDL_HOURS_PER_DAY      = 24
INTEGER TDL_SECONDS_PER_HOUR   = TDL_SECONDS_PER_MINUTE * TDL_MINUTES_PER_HOUR
INTEGER TDL_MINUTES_PER_DAY    = TDL_MINUTES_PER_HOUR   * TDL_HOURS_PER_DAY
INTEGER TDL_SECONDS_PER_DAY    = TDL_SECONDS_PER_HOUR   * TDL_HOURS_PER_DAY
INTEGER TDL_MONTHS_PER_YEAR    = 12
INTEGER TDL_DAYS_PER_YEAR      = 365

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

#IF_NOT_DEFINED bTDDebug
bTDDebug = 0
#END_IF

(***********************************************************)
(*           SUBROUTINE DEFINITIONS GO BELOW               *)
(***********************************************************)

(**************************************)
(* Call Name: TDLLongDayName          *)
(* Function:  Day Name                *)
(* Param:     Day Idx                 *)
(* Return:    Name                    *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLLongDayName (SLONG slDOW)
{
  SELECT
  {
    ACTIVE (slDOW = TDL_SUNDAY):    RETURN 'Sunday';
    ACTIVE (slDOW = TDL_MONDAY):    RETURN 'Monday';
    ACTIVE (slDOW = TDL_TUESDAY):   RETURN 'Tuesday';
    ACTIVE (slDOW = TDL_WEDNESDAY): RETURN 'Wednesday';
    ACTIVE (slDOW = TDL_THURSDAY):  RETURN 'Thursday';
    ACTIVE (slDOW = TDL_FRIDAY):    RETURN 'Friday';
    ACTIVE (slDOW = TDL_SATURDAY):  RETURN 'Saturday';
  }
  RETURN "";
}

(**************************************)
(* Call Name: TDLShortDayName         *)
(* Function:  Day Name                *)
(* Param:     Day Idx                 *)
(* Return:    Name                    *)
(**************************************)
DEFINE_FUNCTION CHAR[3] TDLShortDayName (SLONG slDOW)
{
  RETURN LEFT_STRING(TDLLongDayName(slDOW),3)
}

(**************************************)
(* Call Name: TDLLongMonthName        *)
(* Function:  Long Month Name         *)
(* Param:     Month Idx               *)
(* Return:    Name                    *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLLongMonthName (SLONG slMonth)
{
  SELECT
  {
    ACTIVE (slMonth = 1):  RETURN 'January'
    ACTIVE (slMonth = 2):  RETURN 'February'
    ACTIVE (slMonth = 3):  RETURN 'March'
    ACTIVE (slMonth = 4):  RETURN 'April'
    ACTIVE (slMonth = 5):  RETURN 'May'
    ACTIVE (slMonth = 6):  RETURN 'June'
    ACTIVE (slMonth = 7):  RETURN 'July'
    ACTIVE (slMonth = 8):  RETURN 'August'
    ACTIVE (slMonth = 9):  RETURN 'September'
    ACTIVE (slMonth = 10): RETURN 'October'
    ACTIVE (slMonth = 11): RETURN 'November'
    ACTIVE (slMonth = 12): RETURN 'December'
  }
  RETURN "";
}

(**************************************)
(* Call Name: TDLShortMonthName       *)
(* Function:  Short Month Name        *)
(* Param:     Month Idx               *)
(* Return:    Name                    *)
(**************************************)
DEFINE_FUNCTION CHAR[3] TDLShortMonthName (SLONG slMonth)
{
  RETURN LEFT_STRING(TDLLongMonthName(slMonth),3);
}

(**************************************)
(* Call Name: TDLGetFormalDateDay     *)
(* Function:  Return Formal Date Day  *)
(* Param:     Day                     *)
(* Return:    Formal Day String       *)
(**************************************)
DEFINE_FUNCTION CHAR[10] TDLGetFormalDateDay(SLONG  slDay)
{
  // Valid? 
  IF (slDay <= 0 || slDay > 31)
    RETURN "";

  SWITCH (slDay)
  {
    CASE  1: RETURN "ITOA(slDay),'st'";
    CASE 21: RETURN "ITOA(slDay),'st'";
    CASE 31: RETURN "ITOA(slDay),'st'";
    CASE  2: RETURN "ITOA(slDay),'nd'";
    CASE 22: RETURN "ITOA(slDay),'nd'";
    CASE  3: RETURN "ITOA(slDay),'rd'";
    CASE 23: RETURN "ITOA(slDay),'rd'";
    DEFAULT: RETURN "ITOA(slDay),'th'";
  }
}

(**************************************)
(* Call Name: TDLGetFormalDayOffset   *)
(* Function:  Return Formal Date Day  *)
(* Param:     Day                     *)
(* Return:    Formal Day String       *)
(**************************************)
DEFINE_FUNCTION CHAR[10] TDLGetFormalDayOffset(SLONG  slOffset)
{
  // Valid? 
  IF (slOffset <= 0 || slOffset > 5)
    RETURN "";

  SWITCH (slOffset)
  {
    CASE  1: RETURN "'First'";
    CASE  2: RETURN "'Second'";
    CASE  3: RETURN "'Third'";
    CASE  4: RETURN "'Fourth'";
    CASE  5: RETURN "'Last'";
  }
  RETURN "";
}

(**************************************)
(* Call Name: TDLGetFormalDate        *)
(* Function:  Return Formal Date      *)
(* Param:     Date String             *)
(* Return:    Formal Date String      *)
(**************************************)
DEFINE_FUNCTION CHAR[50] TDLGetFormalDate (CHAR cDate[], CHAR bUKDate)
STACK_VAR
SLONG slMonth
SLONG slDay
SLONG slYear
{
  // Anything To Do? 
  IF (LENGTH_STRING(cDate) == 0)
    RETURN "";

  // Parts 
  slMonth = DATE_TO_MONTH(cDate)
  slDay = DATE_TO_DAY(cDate)
  slYear = DATE_TO_YEAR(cDate)
  IF (slMonth <= 0 || slDay <= 0 || slYear <= 0)
    RETURN "";
  IF (slMonth > 12 || slDay > TDlDaysPerMonth(slMonth,slYear))
    RETURN "";

  // Do It 
  IF (bUKDate)
    RETURN "TDLGetFormalDateDay(slDay),' ',TDLLongMonthName(slMonth),', ',ITOA(slYear)"
  RETURN "TDLLongMonthName(slMonth),' ',TDLGetFormalDateDay(slDay),', ',ITOA(slYear)"
}

(**************************************)
(* Call Name: TdlDayspermonth         *)
(* Function:  Return Just 'dat        *)
(* Param:     Month, Year             *)
(* Return:    Days Per Month          *)
(* Note:      Super Hack! Allows      *)
(*            Month To Be Outisde     *)
(*            Normal Range And New    *)
(*            Year Is Calc'ed         *)
(**************************************)
DEFINE_FUNCTION CHAR TdlDaysPerMonth(SLONG slMonth, SLONG slYear)
STACK_VAR
SLONG slTempYear
SLONG slTempMonth
{
  // Use This Year If Not Supplied 
  slTempYear = slYear
  IF (slTempYear = 0)
    slTempYear = DATE_TO_YEAR(LDATE)

  // Special Month Adjuster 
  slTempMonth = slMonth
  WHILE (slTempMonth > 12)
  {
    slTempMonth = slTempMonth - 12
    slTempYear++
  }
  WHILE (slTempMonth <= 0)
  {
    slTempMonth = slTempMonth + 12
    slTempYear--
  }

  // Do It 
  SELECT
  {
    ACTIVE (slTempMonth = 2 && (slTempYear%4) = 0):  RETURN 29; (* LEAP YEAR *)
    ACTIVE (slTempMonth = 2):                         RETURN 28;
    ACTIVE (slTempMonth = 4):                         RETURN 30;
    ACTIVE (slTempMonth = 6):                         RETURN 30;
    ACTIVE (slTempMonth = 9):                         RETURN 30;
    ACTIVE (slTempMonth = 11):                        RETURN 30;
    ACTIVE (1):                                        RETURN 31;
  }
  RETURN 0;
}

(**************************************)
(* Call Name: TDLTimeSerial           *)
(* Function:  Serialize Time          *)
(* Param:     Hour, On, Sec           *)
(* Return:    Time                    *)
(**************************************)
DEFINE_FUNCTION CHAR[TDL_TIME_LEN] TDLTimeSerial (SLONG slHour, SLONG slMin, SLONG slSec)
{
  // Sanity 
  IF (slHour > 23 || slMin > 59 || slSec > 59)
    RETURN "";

  RETURN "FORMAT('%02d',slHour),':',FORMAT('%02d',slMin),':',FORMAT('%02d',slSec)"
}

(**************************************)
(* Call Name: TDLDateSerial           *)
(* Function:  Serialize Date          *)
(* Param:     Month, Day, Year        *)
(*            Year Length             *)
(* Return:    Date                    *)
(**************************************)
DEFINE_FUNCTION CHAR[TDL_DATE_LEN] TDLDateSerial (SLONG slMonth, SLONG slDay, SLONG slYear, INTEGER nYrLen, CHAR bUKDate)
LOCAL_VAR
SLONG slNowYear
INTEGER nYearLen
{
  // Sanity 
  IF (slMonth == 0 || slMonth > 12 || slDay == 0)
    RETURN "";
  IF (slDay > TDlDaysPerMonth(slMonth,slYear))
    RETURN "";

  // Do Year Length 
  nYearLen = nYrLen
  IF (nYearLen <> 2 && nYearLen <> 4)
    nYearLen = 4
  slNowYear = slYear
  SELECT
  {
    // 2 Digit Year 
    ACTIVE (nYearLen = 2 && slNowYear >= 100):
      slNowYear = slNowYear % 100
    ACTIVE (nYearLen = 2): {}
    // 4 Digit Year 
    ACTIVE (slNowYear <= 70):
      slNowYear = TYPE_CAST(slNowYear) + 2000
    ACTIVE (slNowYear <= 99):
      slNowYear = slNowYear + 199
    ACTIVE (slNowYear == 100):
      slNowYear = 2000
  }
  IF (bUKDate)
    RETURN "FORMAT('%02d',slDay),'/',FORMAT('%02d',slMonth),'/',FORMAT("'%0',ITOA(nYearLen),'d'",slNowYear)"
  RETURN "FORMAT('%02d',slMonth),'/',FORMAT('%02d',slDay),'/',FORMAT("'%0',ITOA(nYearLen),'d'",slNowYear)"
}

(**************************************)
(* Call Name: TDLLocalizedDate        *)
(* Function:  Return Date In Us Or Uk *)
(*            Format                  *)
(* Param:     Date                    *)
(* Return:    Date                    *)
(**************************************)
DEFINE_FUNCTION CHAR[TDL_DATE_LEN] TDLLocalizedDate (CHAR cDate[], CHAR bUKDate)
STACK_VAR
SLONG slMonth
SLONG slDay
SLONG slYear
{
  // Anything To Do? 
  IF (LENGTH_STRING(cDate) == 0)
    RETURN "";

  // Parts 
  slMonth = DATE_TO_MONTH(cDate)
  slDay = DATE_TO_DAY(cDate)
  slYear = DATE_TO_YEAR(cDate)
  IF (slMonth <= 0 || slDay <= 0 || slYear <= 0)
    RETURN "";
  IF (slMonth > 12 || slDay > TDlDaysPerMonth(slMonth,slYear))
    RETURN "";

  // Netlinx Is Native MM/DD/YYYY 
  // Go ahead and let this be serialzed. TDLLocalizedDate() can then validate a date 
  //IF (!bUKDate)
  //  RETURN cDate;

  // Return DD/MM/YYYY 
  RETURN TDLDateSerial(slMonth,slDay,slYear,4,bUKDate);
}

(**************************************)
(* Call Name: TDLTimeAdd              *)
(* Function:  Adjust Times            *)
(* Param:     Time, Sec, Min, Hour,   *)
(*            Day Offset              *)
(* Return:    New Time                *)
(**************************************)
DEFINE_FUNCTION CHAR[TDL_TIME_LEN] TDLTimeAdd (CHAR cTime[], SLONG slSec, SLONG slMin, SLONG slHour, SLONG slDayOffset)
STACK_VAR
CHAR cTempTime[TDL_TIME_LEN]
SLONG slNowMin
SLONG slNowHour
SLONG slNowSec
{
  // Get Time 
  slDayOffset = 0
  cTempTime = cTime
  IF (LENGTH_STRING(cTempTime) == 0)
    cTempTime = TIME
  IF (LENGTH_STRING(cTempTime) <= 5)
    cTempTime = "cTempTime,':00'"

  // Break Up Components 
  slNowSec  = TIME_TO_SECOND(cTempTime)
  slNowMin  = TIME_TO_MINUTE(cTempTime)
  slNowHour = TIME_TO_HOUR(cTempTime)
  IF (slNowHour < 0 || slNowMin < 0 || slNowSec < 0)
    RETURN "";

  // Anything To Do? 
  IF (slSec == 0 && slMin == 0 && slHour == 0)
    RETURN cTempTime;

  // Now, Adjust Sec 
  slDayOffset = 0
  slNowSec = slNowSec + slSec
  WHILE (slNowSec >= 60)
  {
    slNowSec = slNowSec - 60
    slNowMin++
  }
  WHILE (slNowSec < 0)
  {
    slNowSec = slNowSec + 60
    slNowMin--
  }

  // Now, Adjust Min 
  slNowMin = slNowMin + slMin
  WHILE (slNowMin >= 60)
  {
    slNowMin = slNowMin - 60
    slNowHour++
  }
  WHILE (slNowMin < 0)
  {
    slNowMin = slNowMin + 60
    slNowHour--
  }

  // Now, Adjust Hour 
  slNowHour = slNowHour + slHour
  WHILE (slNowHour >= 24)
  {
    slNowHour = slNowHour - 24
    slDayOffset++
  }
  WHILE (slNowHour < 0)
  {
    slNowHour = slNowHour + 24
    slDayOffset--
  }
  
  // Now, Put It Back Together 
  cTempTime = TDLTimeSerial (slNowHour,slNowMin,slNowSec)
  IF (LENGTH_STRING(cTime))
    SET_LENGTH_STRING(cTempTime,LENGTH_STRING(cTime))
  RETURN cTempTime;
}

(**************************************)
(* Call Name: Time Diff               *)
(* Function:  Difference Between Times*)
(* Param:     Time1, Time2, Sec, Min, *)
(*            Hour, Ctime, T1 < T2    *)
(* Return:    0 = Good                *)
(*           -1 = Time1 Invalid       *)
(*           -2 = Time2 Invalid       *)
(* Notes:    Nsec, Nmin And nHour     *)
(*           Are Totals,  cTimeDiff   *)
(*           Is A Difference Time Str *)
(**************************************)
DEFINE_FUNCTION SINTEGER TDLTimeDiff (CHAR cTime1[], CHAR cTime2[], LONG lSec, LONG lMin, LONG lHour, CHAR cTimeDiff[], CHAR bOneLtTwo)
STACK_VAR
CHAR cTempTime[TDL_TIME_LEN]
SLONG slNowMin1
SLONG slNowHour1
SLONG slNowSec1
SLONG slNowMin2
SLONG slNowHour2
SLONG slNowSec2
SLONG slMin
SLONG slHour
SLONG slSec
{
  // Get Time1 
  cTempTime = cTime1
  IF (cTime1 < cTime2)
    cTempTime = cTime2
  IF (LENGTH_STRING(cTempTime) == 0)
    cTempTime = TIME
  IF (LENGTH_STRING(cTempTime) <= 5)
    cTempTime = "cTempTime,':00'"

  // Break Up Components 
  slNowSec1  = TIME_TO_SECOND(cTempTime)
  slNowMin1  = TIME_TO_MINUTE(cTempTime)
  slNowHour1 = TIME_TO_HOUR(cTempTime)
  IF (slNowHour1 < 0 || slNowMin1 < 0 || slNowSec1 < 0)
    RETURN -1;

  // Get Time2 
  cTempTime = cTime2
  IF (cTime1 < cTime2)
    cTempTime = cTime1
  IF (LENGTH_STRING(cTempTime) == 0)
    cTempTime = TIME
  IF (LENGTH_STRING(cTempTime) <= 5)
    cTempTime = "cTempTime,':00'"

  // Break Up Components 
  slNowSec2  = TIME_TO_SECOND(cTempTime)
  slNowMin2  = TIME_TO_MINUTE(cTempTime)
  slNowHour2 = TIME_TO_HOUR(cTempTime)
  IF (slNowHour2 < 0 || slNowMin2 < 0 || slNowSec2 < 0)
    RETURN -2;

  // Now Calc Diff 
  // Hour Will Not Be - 
  slHour        = slNowHour1 - slNowHour2
  slMin         = slNowMin1  - slNowMin2
  IF (slMin < 0)
  {
    slHour--   // If This Happens, It Is Because slHour >= 1 
    slMin = slMin + 60
  }
  slSec         = slNowSec1  - slNowSec2
  IF (slSec < 0)
  {
    slMin--
    IF (slMin < 0)
    {
      slHour--   // If This Happens, It Is Because slHour >= 1 
      slMin = slMin + 60
    }
    slSec = slSec + 60
  }
  cTimeDiff  = TDLTimeSerial (slHour, slMin, slSec)
  slSec         = slSec   + (slMin * 60)  + (slHour * 60 * 60)
  slMin         = slMin   + (slHour * 60)
  lHour         = TYPE_CAST(slHour)
  lMin          = TYPE_CAST(slMin)
  lSec          = TYPE_CAST(slSec)
  OFF[bOneLtTwo]
  IF (cTime1 < cTime2)
    ON[bOneLtTwo]
  RETURN 0;
}

(**************************************)
(* Call Name: TDLDateAdd              *)
(* Function:  Adjust Dates            *)
(* Param:     Date, Day, Month, Year  *)
(* Return:    New Date                *)
(**************************************)
DEFINE_FUNCTION CHAR[TDL_DATE_LEN] TDLDateAdd (CHAR cDate[], SLONG slDay, SLONG slMonth, SLONG slYear)
STACK_VAR
CHAR cTempDate[TDL_DATE_LEN]
SLONG slNowDay
SLONG slNowMonth
SLONG slNowYear
INTEGER nYearLen
{
  // Get Date 
  cTempDate = cDate
  IF (LENGTH_STRING(cTempDate) == 0)
    cTempDate = LDATE

  // Break Up Components 
  slNowDay   = DATE_TO_DAY(cTempDate)
  slNowMonth = DATE_TO_MONTH(cTempDate)
  slNowYear  = DATE_TO_YEAR(cTempDate)
  IF (slNowYear <= 0 || slNowMonth <= 0 || slNowDay <= 0)
    RETURN "";

  // Anything To Do? 
  IF (slDay == 0 && slMonth == 0 && slYear == 0)
    RETURN cTempDate;

  // Do Months 
  slNowMonth = slNowMonth + slMonth
  WHILE (slNowMonth > 12)
  {
    slNowMonth = slNowMonth - 12
    slNowYear++
  }
  WHILE (slNowMonth <= 0)
  {
    slNowYear--
    slNowMonth = slNowMonth + 12
  }

  // Check Year - If We Had 2 Digits And Went To The Past, Adjust Back To "19Xx' 
  slNowYear  = slNowYear + slYear
  IF (slNowYear < 0)
    slNowYear = slNowYear + 100

  (* NOW, ADJUST DAYS *)
  slNowDay   = slNowDay + slDay
  WHILE (slNowDay > TDlDaysPerMonth(slNowMonth,slNowYear))
  {
    slNowDay = slNowDay - TDlDaysPerMonth(slNowMonth,slNowYear)
    slNowMonth++
    WHILE (slNowMonth > 12)
    {
      slNowMonth = slNowMonth - 12
      slNowYear++
    }
  }
  WHILE (slNowDay <= 0)
  {
    slNowMonth--
    WHILE (slNowMonth <= 0)
    {
      slNowYear--
      slNowMonth = slNowMonth + 12
    }
    slNowDay = slNowDay + TDlDaysPerMonth(slNowMonth,slNowYear)
  }

  // Check Year - If We Had 2 Digits And Went To The Past, Adjust Back To "19Xx' 
  nYearLen = 4
  IF (LENGTH_STRING(cDate) <= 8)
    nYearLen = 2

  // Now, Put It Back Together 
  RETURN TDLDateSerial(slNowMonth,slNowDay,slNowYear,nYearLen,0);
}

(**************************************)
(* Call Name: TDLDateCompare          *)
(* Function:  Compare Dates           *)
(* Param:     Date1, Date2            *)
(* Return:    0 = Equal               *)
(*           -1 = Date1 < Date2       *)
(*            1 = Date2 < Date1       *)
(* Notes:    Date Are Not Check For   *)
(*           Validity                 *)
(**************************************)
DEFINE_FUNCTION SINTEGER TDLDateCompare (CHAR cDate1[], CHAR cDate2[])
STACK_VAR
SLONG slNowDay1
SLONG slNowMonth1
SLONG slNowYear1
SLONG slNowDay2
SLONG slNowMonth2
SLONG slNowYear2
{
  // Break Up Components 
  slNowDay1   = DATE_TO_DAY(cDate1)
  slNowMonth1 = DATE_TO_MONTH(cDate1)
  slNowYear1  = DATE_TO_YEAR(cDate1)

  // Break Up Components 
  slNowDay2   = DATE_TO_DAY(cDate2)
  slNowMonth2 = DATE_TO_MONTH(cDate2)
  slNowYear2  = DATE_TO_YEAR(cDate2)

  // Compare 
  IF (slNowYear1  < slNowYear2)  RETURN -1;
  IF (slNowYear2  < slNowYear1)  RETURN  1;
  IF (slNowMonth1 < slNowMonth2) RETURN -1;
  IF (slNowMonth2 < slNowMonth1) RETURN  1;
  IF (slNowDay1   < slNowDay2)   RETURN -1;
  IF (slNowDay2   < slNowDay1)   RETURN  1;
  RETURN 0;
}


(**************************************)
(* Call Name: TDLTimeCompare          *)
(* Function:  Compare Times           *)
(* Param:     Time1, Time2            *)
(* Return:    0 = Equal               *)
(*           -1 = Time1 < Time2       *)
(*            1 = Time2 < Time1       *)
(* Notes:    Times Are Not Check For  *)
(*           Validity                 *)
(**************************************)
DEFINE_FUNCTION SINTEGER TDLTimeCompare (CHAR cTime1[], CHAR cTime2[])
STACK_VAR
SLONG slHour1
SLONG slMinute1
SLONG slSecond1
SLONG slHour2
SLONG slMinute2
SLONG slSecond2
{
  // Break Up Components 
  slHour1   = TIME_TO_HOUR(cTime1)
  slMinute1 = TIME_TO_MINUTE(cTime1)
  slSecond1 = TIME_TO_SECOND(cTime1)
  
  // Break Up Components 
  slHour2   = TIME_TO_HOUR(cTime2)
  slMinute2 = TIME_TO_MINUTE(cTime2)
  slSecond2 = TIME_TO_SECOND(cTime2)

  // Compare 
  IF (slHour1   < slHour2)    RETURN -1;
  IF (slHour2   < slHour1)    RETURN  1;
  IF (slMinute1 < slMinute2)  RETURN -1;
  IF (slMinute2 < slMinute1)  RETURN  1;  
  IF (slSecond1 < slSecond2)  RETURN -1;
  IF (slSecond2 < slSecond1)  RETURN  1;
  RETURN 0;
}


(**************************************)
(* Call Name: TDLDateDiff             *)
(* Function:  Subtract Dates          *)
(* Param:     Date1, Date2, Day, Mon, *)
(*            Year,  T1 < T2          *)
(* Return:    0 = Good                *)
(*           -1 = Date1 Invalid       *)
(*           -2 = Date2 Invalid       *)
(* Notes:    Nsec, Nmin And nHour     *)
(*           Are Totals               *)
(**************************************)
DEFINE_FUNCTION SINTEGER TDLDateDiff (CHAR cDate1[], CHAR cDate2[], LONG lDay, LONG lMonth, LONG lYear, CHAR bOneLtTwo)
STACK_VAR
CHAR cTempDate[12]
SLONG slNowDay1
SLONG slNowMonth1
SLONG slNowYear1
SLONG slNowDay2
SLONG slNowMonth2
SLONG slNowYear2
SLONG slDay
SLONG slMonth
SLONG slYear
{
  // Get Date1 
  cTempDate = cDate1
  IF (TDLDateCompare (cDate1, cDate2) < 0)
    cTempDate = cDate2
  IF (LENGTH_STRING(cTempDate) == 0)
    cTempDate = LDATE

  // Break Up Components 
  slNowDay1   = DATE_TO_DAY(cTempDate)
  slNowMonth1 = DATE_TO_MONTH(cTempDate)
  slNowYear1  = DATE_TO_YEAR(cTempDate)
  IF (slNowYear1 <= 0 || slNowMonth1 <= 0 || slNowDay1 <= 0)
    RETURN -1;

  // Get Date2 
  cTempDate = cDate2
  IF (TDLDateCompare (cDate1, cDate2) < 0)
    cTempDate = cDate1
  IF (LENGTH_STRING(cTempDate) == 0)
    cTempDate = LDATE

  // Break Up Components 
  slNowDay2   = DATE_TO_DAY(cTempDate)
  slNowMonth2 = DATE_TO_MONTH(cTempDate)
  slNowYear2  = DATE_TO_YEAR(cTempDate)
  IF (slNowYear2 <= 0 || slNowMonth2 <= 0 || slNowDay2 <= 0)
    RETURN -2;
    
  // Make Sure Years Are Both Same Length 
  IF (slNowYear1 > 100 && slNowYear2 <= 100)  
  {
    SELECT
    {
      // 4 Digit Year 
      ACTIVE (slNowYear2 <= 70):
        slNowYear2 = TYPE_CAST(slNowYear2) + 2000
      ACTIVE (slNowYear2 <= 99):
        slNowYear2 = slNowYear2 + 199
      ACTIVE (slNowYear2 == 100):
        slNowYear2 = 2000  
    }
  }
  IF (slNowYear2 > 100 && slNowYear1 <= 100)  
  {
    SELECT
    {
      // 4 Digit Year 
      ACTIVE (slNowYear1 <= 70):
        slNowYear1 = TYPE_CAST(slNowYear1) + 2000
      ACTIVE (slNowYear1 <= 99):
        slNowYear1 = slNowYear1 + 199
      ACTIVE (slNowYear1 == 100):
        slNowYear1 = 2000
    }
  }

  // Now Calc Diff 
  // Year Will Not Be - 
  slYear         = slNowYear1   - slNowYear2
  slMonth        = slNowMonth1  - slNowMonth2
  IF (slMonth < 0)
  {
    slYear--   // If This Happends, It Is Because slYear >= 1 
    slMonth = slMonth + 12
  }
  slDay          = slNowDay1    - slNowDay2
  slMonth        = slMonth       + (slYear * 12)
  IF (slDay < 0)   slMonth--
  IF (slMonth < 0) slYear--

  // Wow, Days Is A Bit Harder Than Those... Why Is There A Variable Number Of Days Per Month? 
  // Negative slDay Get Fixed Here Since We Include Days Per Month Of This Month... 
  WHILE (slNowYear2 < slNowYear1 || slNowMonth2 < slNowMonth1)
  {
    slDay = slDay + TDlDaysPerMonth(slNowMonth2,slNowYear2)
    slNowMonth2++
    IF (slNowMonth2 > 12)
    {
      slNowMonth2 = 1
      slNowYear2++
    }
  }
  // Copy 
  lDay   = TYPE_CAST(slDay)
  lMonth = TYPE_CAST(slMonth)
  lYear  = TYPE_CAST(slYear)

  // Diff? 
  OFF[bOneLtTwo]
  IF (TDLDateCompare (cDate1, cDate2) < 0)
    ON[bOneLtTwo]
  RETURN 0;
}

(**************************************)
(* Call Name: TDLAmPmTime             *)
(* Function:  Return Am/Pm Time Str   *)
(* Param:     Time                    *)
(* Return:    Am/Pm Time              *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLAmPmTime (CHAR cTime[])
LOCAL_VAR
INTEGER nHour
CHAR    cTemp[20]
{
  // Get Time 
  nHour = ATOI(LEFT_STRING(cTime,2))

  // Figure It Out! 
  SELECT
  {
    ACTIVE (nHour = 0):
      cTemp = "'12',RIGHT_STRING(cTime,LENGTH_STRING(cTime)-2),' AM'"
    ACTIVE (nHour = 12):
      cTemp = "'12',RIGHT_STRING(cTime,LENGTH_STRING(cTime)-2),' PM'"
    ACTIVE (nHour > 12):
      cTemp = "ITOA(nHour-12),RIGHT_STRING(cTime,LENGTH_STRING(cTime)-2),' PM'"
    ACTIVE (1):
      cTemp = "ITOA(nHour),RIGHT_STRING(cTime,LENGTH_STRING(cTime)-2),' AM'"
  }
  RETURN cTemp
}

(**************************************)
(* Call Name: TDLShortAmPmTime        *)
(* Function:  Return Am/Pm Time Str   *)
(* Param:     Time                    *)
(* Return:    Am/Pm Time              *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLShortAmPmTime (CHAR cTime[])
STACK_VAR CHAR cTempTime[20] INTEGER nPos
{
  cTempTime = TDLAmPmTime(cTime)
  nPos = Find_String(cTempTime,':',1)
  If (nPos)
    nPos = Find_String(cTempTime,':',nPos+1)
  If (nPos)
    RETURN "LEFT_STRING(cTempTime,nPos-1),RIGHT_STRING(cTempTime,3)"
  RETURN cTempTime;
}


(**************************************)
(* Call Name: TDLLocalizedTime        *)
(* Function:  Return Time In 12 Or 24 *)
(*            Hour Format             *)
(* Param:     Time                    *)
(* Return:    Time                    *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLLocalizedTime (CHAR cTime[], CHAR bMilitary)
STACK_VAR
SLONG slHour
SLONG slMinute
SLONG slSecond
{
  // Anything To Do? 
  IF (LENGTH_STRING(cTime) == 0)
    RETURN "";

  // Parts 
  slHour = TIME_TO_HOUR(cTime)
  slMinute = TIME_TO_MINUTE(cTime)
  slSecond = TIME_TO_SECOND(cTime)
  IF (slHour < 0 || slMinute < 0 || slSecond < 0)
    RETURN "";
  IF (slHour > 23 || slMinute > 59 || slSecond > 59)
    RETURN "";

  // Netlinx Is Native HH/MM/SS In 24 Hour Format 
  // However, serialize it so as to validate it.
  IF (bMilitary)
    RETURN TDLTimeSerial (slHour,slMinute,slSecond);

  // Return HH/MM/SS Am/Pm 
  RETURN TDLAmPmTime (cTime);
}

(**************************************)
(* Call Name: TDLShortLocalizedTime   *)
(* Function:  Return Time In 12 Or 24 *)
(*            Hour Format             *)
(* Param:     Time                    *)
(* Return:    Time                    *)
(**************************************)
DEFINE_FUNCTION CHAR[20] TDLShortLocalizedTime (CHAR cTime[], CHAR bMilitary)
STACK_VAR
SLONG slHour
SLONG slMinute
{
  // Anything To Do? 
  IF (LENGTH_STRING(cTime) == 0)
    RETURN "";

  // Parts 
  slHour = TIME_TO_HOUR(cTime)
  slMinute = TIME_TO_MINUTE(cTime)
  IF (slHour < 0 || slMinute < 0)
    RETURN "";
  IF (slHour > 23 || slMinute > 59)
    RETURN "";

  // Netlinx Is Native HH/MM In 24 Hour Format 
  IF (bMilitary)
    RETURN LEFT_STRING(TDLTimeSerial(slHour,slMinute,0),5);

  // Return HH/MM Am/Pm 
  RETURN TDLShortAmPmTime (cTime);
}

(*****************************************)
(* Call Name: TDLCalcFloatingDate        *)
(* Function:  Calculate Date For A       *)
(*            Floating Date Spec         *)
(* Param:     Day Offset (1,2,3,4,5=Last *)
(*            Day Of Week (1=Sun)        *)
(*            Month                      *)
(*            Year                       *)
(* Return:    Date (4 Digit Year)        *)
(*****************************************)
DEFINE_FUNCTION CHAR[TDL_DATE_LEN] TDLCalcFloatingDate(SINTEGER snDayOfMonthOffset, SINTEGER snDayOfMonthDay, SINTEGER snMonth, SINTEGER snYear)
STACK_VAR
CHAR cTempDate[TDL_DATE_LEN]
SINTEGER snDOW
SINTEGER snPos
{
  // Get 1st Day Of This Month 
  cTempDate = TDLDateSerial(snMonth,1,snYear,4,0)

  // Debug 
  IF (bTDDebug)
    SEND_STRING 0,"__TIME_DATE_LIB_NAME__,': Floating Day: snDayOfMonthDay',ITOA(snDayOfMonthDay),'; snDayOfMonthOffset=',ITOA(snDayOfMonthOffset)"

  // What Day Of Week That Is  
  snDOW = DAY_OF_WEEK(cTempDate)

  // Figure Out You Many Days From Start Of Month To Our Desired Day 
  snPos = TYPE_CAST(snDayOfMonthDay)

  // If Our Desird Is A Daw Week Before Dow For 1St Of The Month, Give Us And Exra 7 Days To Next Calc Is Right 
  IF (snPos < snDOW) snPos = snPos + 7

  // Number Of Days To Get The First Occurance Of Our Desired Day Of Week 
  snPos = snPos - snDOW

  // Add Number Of Days To Our Date - First Of Our Target Month 
  IF (snPos)
    cTempDate = TDLDateAdd(cTempDate,snPos,0,0)

  // Debug 
  IF (bTDDebug)
    SEND_STRING 0,"__TIME_DATE_LIB_NAME__,': Adding ',ITOA(snPos),' Days For DOW To Get:',cTempDate"

  // Now If It Is A Multiple Offset (Like Second, Third, Fourth, Or Last, Add That Many * 7 
  IF (snDayOfMonthOffset > 1)
  {
    // Start At 1 Less (We Already Have The First 
    // Is Last A Fifth Or Fourth? 
    snDOW = snDayOfMonthOffset - 1
    IF (snDOW == 4)
    {
      // snPos Hodls Date Of First Occurance Of Deired Day So Add 4 Weeks To See Where We Land 
      // If This Date Is Higher Than Number Of Days In Month Then Last Is The Fourth Occurance 
      snPos = snPos + 28
      IF (snPos > TDlDaysPerMonth (snMonth,snYear))
        snDOW--
    }
    // Now, Calc Number Of Days To Add And Do It 
    snPos = TYPE_CAST(snDOW * 7)
    cTempDate = TDLDateAdd(cTempDate,snPos,0,0)

    // Debug 
    IF (bTDDebug)
      SEND_STRING 0,"__TIME_DATE_LIB_NAME__,': Adding ',ITOA(snPos),' Days For Offset To Get:',cTempDate"
  }

  // Done 
  RETURN cTempDate;
}

(*****************************************)
(* Function: TDPrintVersion              *)
(* Purpose:  Print version               *)
(*****************************************)
DEFINE_FUNCTION TDLPrintVersion()
{
  SEND_STRING 0,"'  Running ',__TIME_DATE_LIB_NAME__,', v',__TIME_DATE_LIB_VERSION__"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// What Version? 
TDLPrintVersion()

#END_IF
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)