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
DEFINE_DEVICE

vdvSystem1 	= 33050:1:1
vdvSystem2 	= 33050:1:2
vdvSystem3 	= 33050:1:3
vdvSystem4 	= 33050:1:4
vdvSystem5 	= 33050:1:5
vdvSystem6 	= 33050:1:6
vdvSystem7 	= 33050:1:7
vdvSystem8 	= 33050:1:8
vdvSystem9 	= 33050:1:9
vdvSystem10 	= 33050:1:10

vdvSystem11 	= 33050:1:11
vdvSystem12 	= 33050:1:12
vdvSystem13	= 33050:1:13
vdvSystem14 	= 33050:1:14
vdvSystem15 	= 33050:1:15
vdvSystem16 	= 33050:1:16
vdvSystem17	= 33050:1:17
vdvSystem18 	= 33050:1:18
vdvSystem19 	= 33050:1:19
vdvSystem20	= 33050:1:20

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


volatile dev vdvSystems[] = {

    vdvSystem1, 	
    vdvSystem2, 	
    vdvSystem3, 	
    vdvSystem4, 	
    vdvSystem5, 	
    vdvSystem6, 	
    vdvSystem7, 	
    vdvSystem8, 
    vdvSystem9, 	
    vdvSystem10, 	
    
    vdvSystem11,	
    vdvSystem12,	
    vdvSystem13,
    vdvSystem14, 	
    vdvSystem15, 	
    vdvSystem16, 	
    vdvSystem17,	
    vdvSystem18, 	
    vdvSystem19, 	
    vdvSystem20
} 


//Save Camera Preset to disk
DEFINE_FUNCTION integer SaveFile(Char Path[255], CHAR FILE_DATA[])
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
	
	SEND_STRING 0, saveText
	
	SaveFile('diagnostic.txt', saveText)
    }
    
    OFFLINE:
    {	
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="offline">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Offline </li>',$0D"
	
	SEND_STRING 0, saveText
	
	SaveFile('diagnostic.txt', saveText)
    }
    
    COMMAND:
    {
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="dataCommand">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Data ',DATA.TEXT ,'</li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveFile('diagnostic.txt', saveText)
    }
    
    STRING:
    {
	STACK_VAR CHAR saveText[255] 
	
	saveText = "'<li class="dataString">',TIME,' - ',LDATE,' - System: ',ITOA ( DATA.DEVICE.SYSTEM ),' Data ',DATA.TEXT ,'</li>',$0D"
	
	//SEND_STRING 0, saveText
	
	SaveFile('diagnostic.txt', saveText)
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

