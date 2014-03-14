PROGRAM_NAME='XMLMethods'

//XML FUNCTIONS________________________________________________________________

//Finds Every Instance of the Element with TagName and returns it to an array
DEFINE_FUNCTION CHAR[MAX_FILE_MEMORY] GetElementFromTagName( char TagName[32], CHAR Instance[4], CHAR FileData[MAX_FILE_MEMORY], INTEGER InnerXml  )
{
    STACK_VAR Char ReturnData[MAX_FILE_MEMORY]
    STACK_VAR INTEGER ct
    STACK_VAR Char svFileData[MAX_FILE_MEMORY]
    
    
    //Make copy of svFileData to prevent FileData from being Altered
    svFileData = FileData
    
    //Search Through all the elements with TagName
    WHILE ( FIND_STRING ( svFileData, "'</',TagName,'>'", 1 ) ) 
    {
	STACK_VAR INTEGER pos
	STACK_VAR INTEGER posTag
	STACK_VAR Integer Check
	STACK_VAR Char CheckTxt[16]
	
	//Reset Return Data
	SET_LENGTH_STRING ( ReturnData, 0 )
	
	//Determine position of Element with Attributes
	Pos = FIND_STRING ( svFileData, "'<',TagName,' '", 1  )
	
	//If no element, try without Attributes
	If ( !Pos )
	{
	    Pos = FIND_STRING ( svFileData, "'<',TagName,'>'", 1  )
	}
	
	    //If Element Exists
	    If ( Pos )
	    {
		//Extract Data
		ReturnData = REMOVE_STRING ( svFileData, "'</',TagName,'>'", pos )
		
		//Find character after Tagname '<TagName'<PosTag>
		posTag = Pos +  LENGTH_STRING ( TagName ) + 1
		
		//Validate TagName to make sure that String pattern is correct <whtSpace> or >
		If ( FIND_STRING ( svFileData, '>', posTag ) OR   FIND_STRING ( svFileData, ' ', posTag  )  )
		{
		    //Increase Instance Counter
		    ct ++
		    
		    //Return this instance
		    if ( ct == ATOI ( instance ) )
		    {
			SET_LENGTH_STRING ( svFileData, 0 )
		    }
		    ELSE
		    {
			//Reset Return Data
			SET_LENGTH_STRING ( ReturnData, 0 )
		    }
		}
	    }
	    ELSE
	    {
		//If element does not exist
		SET_LENGTH_STRING ( svFileData, 0 )
		SET_LENGTH_STRING ( ReturnData, 0 )
	    }
	
    }
    
    //Just returns the data within the tags
    IF ( InnerXml )
    {
	if ( FIND_STRING ( ReturnData, TagName, 1 ) )
	{
	    //Remove the first tags
	    REMOVE_STRING ( ReturnData, "'>'", 1 )
	    
	    //Remove the end tag
	    SET_LENGTH_STRING ( ReturnData, ( LENGTH_STRING ( ReturnData ) - LENGTH_STRING ( TagName ) - 3 ))
	}
    }
    return ReturnData
}

//Remove Element
DEFINE_FUNCTION RemoveElementByTagName(char Element[64], char Instance[4], char FileData[MAX_FILE_MEMORY] )
{
    STACK_VAR CHAR XML[MAX_FILE_MEMORY]
    STACK_VAR INTEGER lengthXML 
    STACK_VAR Char FirstSection[MAX_FILE_MEMORY]
    
    //Get Portion of XML to remove
    XML = GetElementFromTagName( Element, Instance, FileData, 0 )
    
    //Find the Length of the XML
    lengthXML = LENGTH_STRING( XML )
    
    //Split FileData at XML 
    FirstSection = REMOVE_STRING ( FileData, XML, 1 )
    
    //Set First Section Length to its length - length XML Effectively removing the XML from the first section
    SET_LENGTH_STRING ( FirstSection, LENGTH_STRING ( FirstSection ) - lengthXML )
    
    //Knit two sections back together
    FileData = "FirstSection, FileData"
}

//Insert XML Data after Element
DEFINE_FUNCTION InsertNewElementAfterElement(char Element[64], char Instance[4], char newXML[MAX_FILE_MEMORY], char FileData[MAX_FILE_MEMORY] )
{
    STACK_VAR CHAR XML[MAX_FILE_MEMORY]
    STACK_VAR Char FirstSection[MAX_FILE_MEMORY]
    
    //Find XML Element to Insert After
    XML = GetElementFromTagName( Element, Instance, FileData, 0 )
    
    //Split FileData at XML
    FirstSection = REMOVE_STRING ( FileData, XML, 1 )
    
    //Knit two sections back with new XML in the middle
    FileData = "FirstSection, newXML, FileData" 
} 

//Insert XML Data before Element
DEFINE_FUNCTION InsertNewElementBeforeElement(char Element[64], char Instance[4], char newXML[MAX_FILE_MEMORY], char FileData[MAX_FILE_MEMORY] )
{
    STACK_VAR CHAR XML[MAX_FILE_MEMORY]
    STACK_VAR Char FirstSection[MAX_FILE_MEMORY]
    STACK_VAR INTEGER lengthXML 
    
    //Get Portion of XML to insert newXML Before
    XML = GetElementFromTagName( Element, Instance, FileData, 0 )
    
    //Find the Length of the XML
    lengthXML = LENGTH_STRING( XML )
    
    //Split FileData at XML 
    FirstSection = REMOVE_STRING ( FileData, XML, 1 )
    
    //Set First Section Length to its length - length XML Effectively removing the XML from the first section
    SET_LENGTH_STRING ( FirstSection, LENGTH_STRING ( FirstSection ) - lengthXML )
    
    //Knit two sections back with new XML and the existing xml in the middle
    FileData = "FirstSection, newXML, XML, FileData" 
} 

//Builds and XML Element
DEFINE_FUNCTION Char[MAX_FILE_MEMORY] BuildXMLElement( Char Element[64], Char Attr[255], char Value[MAX_FILE_MEMORY] )
{
    STACK_VAR CHAR XML[MAX_FILE_MEMORY]
    
    XML = "'<',Element,Attr,'>',Value,'</',Element,'>'"
    
    RETURN XML
}

DEFINE_FUNCTION char[255] GetElementAttrValue( char Attr[255], Char Element[64], CHAR FileData[MAX_FILE_MEMORY] )
{
    STACK_VAR CHAR Attrs[512]
    STACK_VAR CHAR sData[MAX_FILE_MEMORY]
    
    sData = FileData
    
    if ( FIND_STRING ( sData, "'<',Element", 1 ) )
    {
	REMOVE_STRING( sData, "'<',Element", 1 )
	Attrs = REMOVE_STRING ( sData, '>' , 1 )
	
	IF ( FIND_STRING ( Attrs, Attr, 1 ) )
	{
	    //Remove <Attr>="
	    REMOVE_STRING ( Attrs, "Attr,'="'", 1 )
	    
	    //Remove <Attr Value>"
	    Attrs = REMOVE_STRING ( Attrs, '"', 1 )
	    
	    //Remove "
	    SET_LENGTH_STRING ( Attrs, ( LENGTH_STRING ( Attrs ) - 1 ) )
	    
	    return Attrs
	}
    }	
    return 'No Attributes'
}

DEFINE_FUNCTION char[MAX_FILE_MEMORY] GetElementFromAttrAndTagName( char Attr[128], char AttrData[128], char TagName[128], CHAR FileData[MAX_FILE_MEMORY] )
{
    STACK_VAR Char ReturnData[MAX_FILE_MEMORY]
    
    //Search Through all the elements with TagName
    WHILE ( FIND_STRING ( FileData, "'</',TagName,'>'", 1 ) ) 
    {
	STACK_VAR Char svData[MAX_FILE_MEMORY]
	STACK_VAR Char svTemp[128]
	STACK_VAR INTEGER Pos
	
	//Make a incase we need to return the element
	ReturnData = FileData
	
	//Clean up Beginning of the String
	Pos = FIND_STRING ( ReturnData, "'<',TagName", 1  )
	ReturnData = REMOVE_STRING ( ReturnData, "'</',TagName", pos )
	
	//1: Remove First Element with TagName
	svData = REMOVE_STRING ( FileData, "'</',TagName", 1 )
	
	//2: Remove TagName 
	REMOVE_STRING (svData, "'<',TagName", 1 )
	
	//3: Remove Attributes of Tag to TEMP
	svTemp = REMOVE_STRING ( svData, "'>'", 1 )
	
	//4: If Attribute is found in Tag then parse Data and return
	If ( FIND_STRING ( svTemp, Attr, 1 ) )	
	{
	    //5: Remove Attr from Data
	    REMOVE_STRING ( svTemp, Attr, 1 )
	    
	    //6: Remove '='
	    REMOVE_STRING ( svTemp, '=', 1 )
	    
	    //7: Remove First "
	    REMOVE_STRING ( svTemp, '"', 1 )
	    
	    //8: Remove <data>"
	    svTemp = REMOVE_STRING ( svTemp, '"', 1 )
	    
	    //9: Remove "
	    SET_LENGTH_STRING ( svTemp, ( LENGTH_STRING ( svTemp ) - 1 ) )
	    
	    //Compare requested data String with tag Attribute data
	    IF (  FIND_STRING ( svTemp, AttrData, 1 ) )
	    {
		//If it matches then break loop and return
		SET_LENGTH_STRING ( FileData, 0 )
	    }
	    ELSE
	    {
		//Clean Return Data
		SET_LENGTH_STRING ( ReturnData, 0 )
	    }
	}
    }
    
    //Return Element back
    RETURN ReturnData
}