PROGRAM_NAME='Utilities'

DEFINE_TYPE

//API Handler
STRUCTURE _ATTRIBUTE
{
    INTEGER ID
    CHAR Name[255]
    CHAR Value[512]
}

STRUCTURE _COMMAND
{	
    INTEGER ID
    CHAR CommandName[255]
    _ATTRIBUTE Attributes[50]
}
 
DEFINE_CONSTANT 

//Strip last byte
DEFINE_FUNCTION char[255] removeLastbyte( char pString[255] )
{
    SET_LENGTH_STRING ( pString, ( LENGTH_STRING ( pString ) - 1 ) )
    RETURN pString
}

//gets Attr from GET Method
DEFINE_FUNCTION Char[255] GetAttrValue(Char Attr[64], _COMMAND parser)
{	
    STACK_VAR integer  i 
    
    FOR ( i=1; i<=50; i++ )
    {
	IF ( parser.Attributes[i].id )
	{
	    IF ( FIND_STRING ( parser.Attributes[i].Name, Attr, 1) )
	    {
		return parser.Attributes[i].Value
		break
	    }
	}
	ELSE
	{
	    return 'null'
	    Break
	}
    }
}

//Save Camera Preset to disk
DEFINE_FUNCTION integer SaveFile(Char Path[255], CHAR FILE_DATA[1024])
{
    STACK_VAR SLONG File
    STACK_VAR SLONG BytesRead
    STACK_VAR INTEGER Result
    
    File = FILE_OPEN(Path, FILE_RW_NEW)
    
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
	BytesRead = FILE_WRITE( File, FILE_DATA, LENGTH_STRING ( FILE_DATA ) )
	
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

//Load Data
DEFINE_FUNCTION integer ReadFile(Char Path[255], CHAR FILE_DATA[1024])
{
    STACK_VAR SLONG File
    STACK_VAR SLONG BytesRead
    STACK_VAR INTEGER Result
    
    //Clear File Data before update file
    SET_LENGTH_STRING ( FILE_DATA, 0 )
    
    File = FILE_OPEN(Path, FILE_READ_ONLY)
    
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
	SEND_STRING 0, "'FILE OPEN: ',ITOA( File ),' Bytes'"
	
	//Read File Contents to Buffer
	BytesRead = FILE_READ( File, FILE_DATA, 25600 )
	
	IF ( BytesRead < 0 )
	{
	    BytesRead = BytesRead * -1
	    
	    //Catch Read Errors
	    SWITCH ( BytesRead )
	    {
		CASE 1: SEND_STRING 0, "'INVALID FILE HANDLE'"
		CASE 9: SEND_STRING 0, "'END OF FILE REACHED'"
		CASE 5: SEND_STRING 0, "'DISK I/O ERROR'"
		CASE 6: SEND_STRING 0, "'INVALID PARAMETER'"
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