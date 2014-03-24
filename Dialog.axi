PROGRAM_NAME='Dialog'


DEFINE_CONSTANT

VOLATILE INTEGER LENGTH_DIALOGS = 20
VOLATILE INTEGER LENGTH_KEY_FIELDS = 40


DEFINE_TYPE 

STRUCTURE _OPTION_DIALOG 
{
    integer ID
    char title[32]
    char message[128]
    char response[4][16]
    char ref[16]
    integer showing
}

DEFINE_VARIABLE 

VOLATILE _OPTION_DIALOG dialogs[LENGTH_DIALOGS]
VOLATILE INTEGER CURRENT_DIALOG
VOLATILE INTEGER PANEL_ONLINE

//Hides a range of buttons 
DEFINE_FUNCTION UI_HideShowButtons(Integer btns[], Integer Start, Integer Finish, integer func) {
    
    STACK_VAR Integer i 
    
    FOR ( i=Start; i<=Finish; i++ )
    {
	SEND_COMMAND dvTP, "'^SHO-',ITOA(Btns[i]),',',ITOA( Func )"
    }
}

//OPTION_DIALOG Functions Go Below_____________________________________________

//Finds next available slot in the dialog buffer
DEFINE_FUNCTION integer Dialog_getNextId ( ) {

    stack_var integer i
    
    for ( i=1; i<LENGTH_DIALOGS; i++ ) {
	
	if ( !dialogs[i].ID ) {
	    
	    return i
	    break
	}
    }
    
    return 0
}

//Get Dialog id by ref
DEFINE_FUNCTION integer Dialog_getIdfromRef( Char Ref[16] )
{
    STACK_VAR integer i 
    
    //loop through dialogs until finding ref  
    for ( i=1; i<=LENGTH_DIALOGS; i++ )
    {
	if ( DIALOGS[i].ID ) {
	    
	    if ( DIALOGS[i].REF == Ref ) {
		
		return i 
	    }	    
	}
	else
	{
	    break
	}
    }

    return 0
}

//Adds a new dialog to the dialog buffer
DEFINE_FUNCTION Dialog_Add(_COMMAND parser) {

    STACK_VAR integer id
    STACK_VAR integer exists
    
    if ( ATOI ( GetAttrValue( 'norepeat', parser ) ) )
    {
	//See if the Dialog already exists
	exists = Dialog_getIdfromRef( GetAttrValue( 'ref', parser ) )
    }
    
    if ( !exists ) {
	
	if ( Dialog_getNextId() ) {
	    id = Dialog_getNextId()
	    dialogs[id].id = id
	    dialogs[id].title = GetAttrValue( 'title', parser ) 
	    dialogs[id].message = GetAttrValue( 'message', parser )
	    dialogs[id].ref = GetAttrValue( 'ref', parser )
	    dialogs[id].response[1] = GetAttrValue( 'res1', parser )
	    dialogs[id].response[2] = GetAttrValue( 'res2', parser )
	    dialogs[id].response[3] = GetAttrValue( 'res3', parser )
	    dialogs[id].response[4] = GetAttrValue( 'res4', parser )
	    dialogs[id].showing = 0
	}
    }
    //if it does exist then update 
    else
    {
	dialogs[exists].title = GetAttrValue( 'title', parser ) 
	dialogs[exists].message = GetAttrValue( 'message', parser )
	dialogs[exists].ref = GetAttrValue( 'ref', parser )
	dialogs[exists].response[1] = GetAttrValue( 'res1', parser )
	dialogs[exists].response[2] = GetAttrValue( 'res2', parser )
	dialogs[exists].response[3] = GetAttrValue( 'res3', parser )
	dialogs[exists].response[4] = GetAttrValue( 'res4', parser )
	
	//Updates the the UI if showing 
	if ( dialogs[exists].showing )
	{
	    Dialog_updateUI(exists)
	}
    }
}

//Reshows Show Dialog
DEFINE_FUNCTION Dialog_ShowCurrentDialog()
{
    STACK_VAR INTEGER DialogIndex
    
    //Show Dialog Box if any
    DialogIndex = Dialog_getShowing()
    
    //if dialog is showing show dialog
    if ( DialogIndex )
    {
	Dialog_updateUI( DialogIndex)
    }
}

//Updates all the text fields in the dialog box
DEFINE_FUNCTION Dialog_updateUI( integer DialogIndex)
{
    //Setup Dialog Box
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[5]),'-',dialogs[DialogIndex].title"
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[6]),'-',dialogs[DialogIndex].message"
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[1]),'-',dialogs[DialogIndex].response[1]"
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[2]),'-',dialogs[DialogIndex].response[2]"
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[3]),'-',dialogs[DialogIndex].response[3]"
    SEND_COMMAND dvTP, "'TEXT',ITOA(DialogsBtns[4]),'-',dialogs[DialogIndex].response[4]"
    
    //Show Dialog on Touch Panel
    SEND_COMMAND dvTP, "'@PPN-_OptionDialogOkCancel'"
    
    //Wake UI and send Audio Notification
    SEND_COMMAND dvTP, "'WAKE'"
    wait 5 SEND_COMMAND dvTP, "'ADBEEP'"
}

//Remove a dialog from the Dialog Buffer 
DEFINE_FUNCTION Dialog_Remove(integer index) {

    STACK_VAR _OPTION_DIALOG Blank
    STACK_VAR integer i
    
    if ( dialogs[index].showing )
    {
	//Show Dialog on Touch Panel
	SEND_COMMAND dvTP, "'@PPK-_OptionDialogOkCancel'"
    }
    
    dialogs[index] = Blank
    
    for ( i=index+1; i<length_dialogs; i++ )
    {
	//Shuffle rows up
	if ( dialogs[i].id ) {
	    
	    dialogs[i-1] = dialogs[i]
	}
	//Delete last row
	else {
	    
	    dialogs[i-1] = blank
	    break
	}
    }
}

//Get the dialog that is currently showing
DEFINE_FUNCTION integer Dialog_getShowing() {

    STACK_VAR i
    for ( i=1; i<LENGTH_DIALOGS; i++ )
    {
	if ( dialogs[i].showing ) {
	    
	    return i
	    break
	}
    }    
    return 0
}

//Show next Dialog
DEFINE_FUNCTION integer Dialog_setNextDialog() {
    
    STACK_VAR integer length
    
    if ( !dialog_getShowing() )
    {
	if ( dialogs[CURRENT_DIALOG].id AND PANEL_ONLINE )
	{
	    STACK_VAR integer i
	    
	    //Hide All Buttons
	    UI_HideShowButtons(DialogsBtns, 1,4,0)
	    
	    //Show Correct buttons
	    for ( i=1; i<=4; i++) {
		
		if ( dialogs[CURRENT_DIALOG].response[i] != 'null' ) {
		    UI_HideShowButtons(DialogsBtns, i, i, 1)
		}
	    }
	    
	    //update UI
	    Dialog_updateUI(CURRENT_DIALOG)
	    
	    ON[dialogs[CURRENT_DIALOG].showing]
	}
    }
    
    length = dialogs_length()
    
    //iterate to next dialog
    if ( CURRENT_DIALOG <= length )
    {
	CURRENT_DIALOG ++
    }
    ELSE
    {
	CURRENT_DIALOG = 1
    }
}

DEFINE_FUNCTION integer dialogs_length() {

    STACK_VAR integer i 
    
    for ( i=1; i<LENGTH_DIALOGS; i++ )
    {
	if ( !dialogs[i].id )
	{
	    return i - 1
	}
    }
    return 0
}

DEFINE_EVENT

//Touch Panel
DATA_EVENT [dvTP]
{
    ONLINE:
    {
	ON[PANEL_ONLINE]
    }
    OFFLINE:
    {
	OFF[PANEL_ONLINE]
    }
}

//User Interface Shell
BUTTON_EVENT [dvTP, DialogsBtns]
{
    PUSH:
    {
	STACK_VAR INTEGER svButton
	svButton = GET_LAST ( DialogsBtns )
	
	TO[dvTP, BUTTON.INPUT.CHANNEL]
    }
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	svButton = GET_LAST ( DialogsBtns )
	
	SWITCH ( svButton )
	{ 
	    //Dialog Responses
	    CASE 1:
	    CASE 2:
	    CASE 3:
	    CASE 4:
	    {
		STACK_VAR integer id
		
		//Get Currently Showing Dialog
		id = Dialog_getShowing()
		
		//Send Response Data
		SEND_STRING vdvSystem, "'Dialog-ref=',dialogs[id].ref,'&res=',ITOA(svButton)"
		
		//Dismiss Popup
		SEND_COMMAND dvTP, "'@PPK-_OptionDialogOkCancel'" 
		
		//Remove from dialog buffer
		Dialog_Remove(id)
	    }
	}
    }
}

DEFINE_PROGRAM

if ( PANEL_ONLINE )
{
    Dialog_setNextDialog()
}