    
	STACK_VAR INTEGER ct
	STACK_VAR INTEGER dataType //0 is expecting Attr name 1 is expecting Attr Value
	STACK_VAR _COMMAND aCommand
	STACK_VAR Char sData[255]
	
	sData = DATA.TEXT
	
	//Remove any unwanted <LF><CR>
	if ( FIND_STRING ( RIGHT_STRING( sData, 2 ), "$0D,$0A", 1 ) )
	{
	    SET_LENGTH_STRING( sData, LENGTH_STRING( sData ) - 2 )
	}
	
	//Remove <Tag>-
	aCommand.CommandName = REMOVE_STRING ( sData, '-', 1 ) 
	
	#if_defined println
	    println (aCommand.CommandName)
	#end_if
	
	//Remove -
	SET_LENGTH_STRING ( aCommand.CommandName, ( LENGTH_STRING ( aCommand.CommandName ) - 1 ) ) 
	
	ct = 1
	
	WHILE ( length_string(sData) )
	{
	    If ( !dataType )
	    {
		If ( FIND_STRING( sData, '=', 1 )  )
		{
		    //Add Key
		    aCommand.Attributes[ct].ID = ct
		    
		    //Remove Element 
		    aCommand.Attributes[ct].Name = REMOVE_STRING ( sData, '=' ,1 )
			    
		    //Remove ,
		    SET_LENGTH_STRING ( aCommand.Attributes[ct].Name, ( LENGTH_STRING ( aCommand.Attributes[ct].Name ) - 1 ) )
		    
		    ON[dataType]
		}
		//No Attributes
		ELSE
		{
		    //Add last Element
		    aCommand.Attributes[ct].Value = sData
		    
		    //End Loop 
		    sData = ''
		    break
		}
	    }
	    ELSE 
	    {
		//Last element
		IF ( !FIND_STRING( sData, '&', 1 ) )
		{
		    //Add last Element
		    aCommand.Attributes[ct].Value = sData
		    
		    //End Loop 
		    sData = ''
		    break
		}
		ELSE 
		{
		    //Remove Element 
		    aCommand.Attributes[ct].Value = REMOVE_STRING ( sData, '&' ,1 )
			    
		    //Remove ,
		    SET_LENGTH_STRING ( aCommand.Attributes[ct].Value, ( LENGTH_STRING ( aCommand.Attributes[ct].Value ) - 1 ) )
		    
		    //Go to next attribute
		    OFF[dataType]
		    ct++
		}
	    }
	}
