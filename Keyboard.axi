PROGRAM_NAME='Keyboard'


DEFINE_CONSTANT

integer LENGTH_KEY_FIELDS = 40

DEFINE_TYPE

STRUCTURE _TEXT_FIELDS { 

    integer ID
    integer ButtonNum
    integer focus
    dev UI
    Char Label[64]
}

DEFINE_VARIABLE

_TEXT_FIELDS TEXT_FIELDS[LENGTH_KEY_FIELDS]

//Finds next available slot in the FIELDS Stucture
DEFINE_FUNCTION integer FIELDS_getNextId ( ) {

    stack_var integer i
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( !TEXT_FIELDS[i].ID ) {
	    
	    return i
	    break
	}
    }
    
    return 0
}


//Sets focus onto field and returns focused ID
DEFINE_FUNCTION integer FIELDS_setFocus ( integer btnNum ) {

    stack_var integer i
    stack_var integer id
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	   
	   if ( TEXT_FIELDS[i].ButtonNum == btnNum ) {
		
		ON[TEXT_FIELDS[i].focus]
		id = i
	    }
	    else
	    {
		OFF[TEXT_FIELDS[i].focus]
	    }
	}
    }
    
    return id
}

//Sets focus onto field and returns focused ID using device
DEFINE_FUNCTION integer FIELDS_setFocusDev ( dev UItp, integer btnNum ) {

    stack_var integer i
    stack_var integer id
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	   
	   if ( TEXT_FIELDS[i].UI == UItp AND TEXT_FIELDS[i].ButtonNum == btnNum ) {
		
		ON[TEXT_FIELDS[i].focus]
		id = i
	    }
	    else
	    {
		OFF[TEXT_FIELDS[i].focus]
	    }
	}
    }
    
    return id
}

//Clears focus from field
DEFINE_FUNCTION FIELDS_clearFocus ( ) {

    STACK_VAR INTEGER i 
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	    
	    OFF[TEXT_FIELDS[i].focus]
	}
	ELSE
	{
	    break
	}
    }
}


//Display FIELDS and focus on field
DEFINE_FUNCTION FIELDS_Display( _Command parser ) {
    
    STACK_VAR INTEGER BtnNum
    STACK_VAR INTEGER ID
    STACK_VAR INTEGER uiNumber
    STACK_VAR INTEGER uiPort
    STACK_VAR INTEGER uiSystem
    STACK_VAR DEV UItp
    
    
    //Get Button Number
    BtnNum = ATOI ( GetAttrValue( 'btnnum', parser  ) )
    
    //Cancel any Clear Focus delay 
    CANCEL_WAIT 'clearFocus'   

    //If UI specified
    if ( getAttrValue( 'uinum', parser ) )
    {
	UITp.number = ATOI ( getAttrValue( 'uinum', parser ) )
	UITp.port = ATOI ( getAttrValue( 'uiport', parser ) )
	UITp.system = ATOI ( getAttrValue( 'uisys', parser ) )
	
	TEXT_FIELDS[id].UI = UITp
	
	ID = FIELDS_setFocusDev ( UITp, BtnNum )
    }
    
    //If no UI specified then use default TP
    ELSE
    {
	//Set Field Focus
	ID = FIELDS_setFocus ( BtnNum ) 
    }
    
    //Display FIELDS
    SEND_COMMAND dvTP, "'@AKB-',getAttrValue( 'initialtext', parser ),';',TEXT_FIELDS[id].Label"

}

//Adds a new FIELDS Field
DEFINE_FUNCTION FIELDS_add( _Command parser ) {

    STACK_VAR INTEGER id
    STACK_VAR INTEGER uiNumber
    STACK_VAR INTEGER uiPort
    STACK_VAR INTEGER uiSystem
    STACK_VAR DEV UItp
    
    id = FIELDS_getNextId()
    
    TEXT_FIELDS[id].ID = id
    TEXT_FIELDS[id].ButtonNum = ATOI ( getAttrValue( 'btnnum', parser  ) )
    TEXT_FIELDS[id].Label = (getAttrValue ( 'label', parser ) )
    
    //If UI specified
    if ( getAttrValue( 'uinum', parser ) )
    {
	UITp.number = ATOI ( getAttrValue( 'uinum', parser ) )
	UITp.port = ATOI ( getAttrValue( 'uiport', parser ) )
	UITp.system = ATOI ( getAttrValue( 'uisys', parser ) )
	
	TEXT_FIELDS[id].UI = UITp
    }
}

//Return the Button Number for the currently focused fields
DEFINE_FUNCTION integer FIELDS_getFocusBtnNum() {
    
    stack_var integer i
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	    
	    if ( TEXT_FIELDS[i].FOCUS ) {
		
		return TEXT_FIELDS[i].ButtonNum
		break
	    }
	}
    }
    
    return 0
}

//Return the ID for the currently focused fields
DEFINE_FUNCTION integer FIELDS_getFocusID() {
    
    stack_var integer i
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	    
	    if ( TEXT_FIELDS[i].FOCUS ) {
		
		return TEXT_FIELDS[i].ID
		break
	    }
	}
    }
    
    return 0
}

//Set feedback for fields
DEFINE_FUNCTION FIELDS_feedback() {

    STACK_VAR integer i
    
    for ( i=1; i<LENGTH_KEY_FIELDS; i++ ) {
	
	if ( TEXT_FIELDS[i].ID ) {
	    
	    [ TEXT_FIELDS[i].UI, TEXT_FIELDS[i].ButtonNum ] = TEXT_FIELDS[i].FOCUS  
	}
    }
} 


//Checks to see if the keyboard action has been cancelled
DEFINE_FUNCTION integer KEYBOARD_isAbort( CHAR sData[255] )
{
    STACK_VAR INTEGER isAbort
    
    //remove KEYB-
    REMOVE_STRING ( sData, '-', 1 )
    
    //Look at the first 5 letters
    if ( LEFT_STRING ( sData, 5 ) )
    {
	//Find Keyword Abort
	if ( FIND_STRING ( sData, 'ABORT', 1 ) )
	{
	    on[isAbort]
	}
    }

    RETURN isAbort
} 

DEFINE_EVENT

//FIELDS Processor
DATA_EVENT[dvTP]
{
    STRING:
    {
	if (find_string(data.text, 'KEYB-', 1))
	{
	    if ( !KEYBOARD_isAbort( DATA.TEXT ) )
	    {
		STACK_VAR INTEGER ID
		
		ID = FIELDS_getFocusID()
		
		SEND_COMMAND vdvSystem, "'FIELDS_Response-btnnum=',ITOA ( TEXT_FIELDS[ID].ButtonNum ),
							'&data=',data.text,
							'&uinum=',ITOA ( TEXT_FIELDS[ID].UI.Number ),
							'&uiport=',ITOA ( TEXT_FIELDS[ID].UI.port ),
							'&uisys=',ITOA ( TEXT_FIELDS[ID].UI.system )"
	    }
	    
	    //Delay clear Focus to help the user find what they have altered.
	    WAIT 20 'clearFocus' {
		
		//Takes focus from the field 
		FIELDS_clearFocus()
	    }
	}
    }
}

//Listen for Events on vdvSystem
DATA_EVENT[vdvSystem]
{
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	
	//Adds a focusable text field to keyboard processor
	IF ( FIND_STRING ( aCommand.CommandName, 'AddKeyboardField', 1 )  )
	{
	    Fields_add( aCommand ) 
	}
	//Display Keyboard using field
	IF ( FIND_STRING ( aCommand.CommandName, 'DisplayKeyboard', 1 )  )
	{
	    Fields_Display( aCommand ) 
	}
    }
}



DEFINE_PROGRAM 

FIELDS_feedback()