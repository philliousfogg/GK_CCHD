PROGRAM_NAME='Diagnostic'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


//Save Camera Preset to disk
DEFINE_FUNCTION integer SaveDFile(Char Path[255], CHAR FILE_DATA[])
{
    STACK_VAR SLONG File
    STACK_VAR SLONG BytesRead
    STACK_VAR INTEGER Result
    
    File = FILE_OPEN(Path, FILE_RW_APPEND)
    
    IF ( File < 0 )
    {
	File = (File * -1)
	
	//Catch File Open Error
	SWITCH ( File )
	{
	    CASE 2: SEND_STRING 0, "'INVALID FILE PATH OR NAME'"
	    CASE 3: SEND_STRING 0, "'INVALID VALUE SUPPLIED FOR IO FLAG'"
	    CASE 5: SEND_STRING 0, "'DISK I/O ERROR'"
	    CASE 14: SEND_STRING 0, "'MAXIMUM NUMBER OF FILES ARE ALREADY OPEN (MAX IS 10)'"
	    CASE 15: SEND_STRING 0, "'INVALID FILE FORMAT'"
	}
	
	Result = 0
    }
    ELSE
    {
	//Read File Contents to Buffer
	BytesRead = FILE_WRITE( File, FILE_DATA, 100000 )
	
	IF ( BytesRead < 0 )
	{
	    BytesRead = BytesRead * -1
	    
	    //Catch Read Errors
	    SWITCH ( BytesRead )
	    {
		CASE 1: SEND_STRING 0, "'INVALID FILE HANDLE'"
		CASE 11: SEND_STRING 0, "'DISK FULL'"
		CASE 5: SEND_STRING 0, "'DISK I/O ERROR'"
		CASE 6: SEND_STRING 0, "'INVALID PARAMETER-', ITOA ( LENGTH_STRING ( FILE_DATA ) ) "
	    }
	    
	    Result = 0
	}
	ELSE
	{
	    SEND_STRING 0, "'FILE READ: ',ITOA ( BytesRead ),' Bytes'" 
	    Result = 1
	}
    }
    FILE_CLOSE(File)
    
    RETURN Result
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [vdvSystems]
{
    ONLINE:
    {
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="online">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Online </li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveDFile('diagnostic.txt', saveText)
    }
    
    OFFLINE:
    {	
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="offline">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Offline </li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveDFile('diagnostic.txt', saveText)
    }
    
    COMMAND:
    {
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="dataCommand">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Data ',DATA.TEXT ,'</li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveDFile('diagnostic.txt', saveText)
    }
    
    STRING:
    {
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="dataString">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Data ',DATA.TEXT ,'</li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveDFile('diagnostic.txt', saveText)
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

