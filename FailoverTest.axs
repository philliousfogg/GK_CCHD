PROGRAM_NAME='URL_Handler'

#INCLUDE 'DeviceDefinitions.axi'

DEFINE_VARIABLE 

VOLATILE URL_STRUCT URL_ENTRY
VOLATILE INTEGER URL_ENTRY_SYSTEM_NUM
PERSISTENT URL_STRUCT GATEWAYS[2]
VOLATILE URL_STRUCT DEFAULT_GATEWAYS[2]
PERSISTENT INTEGER GW_SYSTEM_NUM[2]
VOLATILE INTEGER DEFAULT_GW_SYSTEM_NUM[2]
VOLATILE INTEGER GW_ONLINE[2]
VOLATILE URL_STRUCT URL_LIST[20]
VOLATILE URL_STRUCT _URL_LIST[20]  // Comparer 

VOLATILE SLONG URL_LIST_LENGTH
VOLATILE SLONG _URL_LIST_LENGTH

VOLATILE INTEGER URL_UI_LIST
VOLATILE INTEGER GW_TIME_OUT[2]

VOLATILE INTEGER FLASH
VOLATILE INTEGER LISTS_LENGTH = 1

// URL UI Btns
VOLATILE INTEGER URL_UI_BTNS[] = {
    
    41, // 1: Add GW1 
    42, // 2: Add GW2
    43, // 3: Refresh URL List
    44, // 4: Assign URL Entry to GW1
    45, // 5: Assign URL Entry to GW2
    46, // 6: Restore to Default Hard Coded Gateways
    47, // 7: Switch to GW1
    48, // 8: Switch to GW2
    49, // 9: Increment URL UI List
    50, // 10: Decrement URL UI List
    51,52,53,54,55,56,57,58,59, // 11->19 URL UI Entry
    60, // 20: Spare
    61,62,63,64,65,66,67,68,69, // 21->29 URL UI Entry Remove
    70, // 30: Spare
    71,72,73,74,75,76,77,78,79, // 31->39 URL UI Connection Status
    80, // 40: URL_Entry.Url Field
    81, // 41: URL_Entry.User Field
    82, // 42: URL_Entry.Password Field
    83, // 43: Add URL_ENTRY to URL List
    84  // 44: URL_Entry.SystemNumber Field
}

// Utilities
#INCLUDE 'Utilities.axi'

// Include Lists
#INCLUDE 'UI_Tools.axi'

// Include Keyboard Fields Handler
#INCLUDE 'Keyboard.axi'

// User Interface Feedback
DEFINE_FUNCTION URL_UI_feedback()
{
    STACK_VAR INTEGER i
    
    // Get list
    URL_LIST_LENGTH = GET_URL_LIST( dvSystem, URL_LIST, 1 )
    
    // Check for difference in list length
    if  ( URL_LIST_LENGTH != _URL_LIST_LENGTH )
    {
	// if difference refresh UI list
	URL_UI_getURList(UIList[URL_UI_LIST].Position)
	
	_URL_LIST_LENGTH = URL_LIST_LENGTH
    }
    ELSE
    {
	FOR ( i=1; i<=UIList[URL_UI_LIST].displaySize; i++ )
	{
	    STACK_VAR INTEGER urlIndex
	    
	    urlIndex = GetDataIDFromDataSet ( URL_UI_LIST, i )
	    
	    if ( urlIndex )
	    {
		// Is Connected?
		[dvTP, URL_UI_BTNS[i + 10]] =   ( URL_LIST[urlIndex].Flags == 227 ) OR
						( URL_LIST[urlIndex].Flags == 225 )
		
		
		// Check for flag differences
		if ( URL_LIST[urlIndex].Flags != _URL_LIST[urlIndex].Flags )
		{
		    // Update list buttons to 
		    URL_UI_getURList(UIList[URL_UI_LIST].Position)
		    
		    _URL_LIST[urlIndex].Flags = URL_LIST[urlIndex].Flags
		}
	    }
	    ELSE
	    {
		// Clear Field Status
		[dvTP, URL_UI_BTNS[i + 10]] = 0 
	    }
	}
    }
    
    // Use IO indicators on Front Panel to indicate gateway
    [dvIO, 4] = URL_UI_getActiveGW() == 1
    [dvIO, 4] = ( URL_UI_getActiveGW() == 2 ) AND FLASH
}

// Adds additional elements to the list (this is called from UI_TOOLs)
DEFINE_FUNCTION UI_TOOLS_DisplayListElement( integer List, char ref[], integer pData, integer BtnIndex, integer TPport )
{
    // Check to see we are using the correct list.
    if ( list == URL_UI_LIST )
    {
	IF ( pData )
	{
	    // Show Remove Entry Button
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( URL_UI_BTNS[BtnIndex + 20] ),',1'"
	    
	    if ( URL_LIST[pData].Flags == 227 )
	    {
		// Show Remove Entry Button
		SEND_COMMAND dvTP, "'^SHO-',ITOA ( URL_UI_BTNS[BtnIndex + 30] ),',1'"
	    }
	}
	
	// If Clearing List
	ELSE
	{
	    // Hide Remove Entry
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( URL_UI_BTNS[BtnIndex + 20] ),',0'"
	    
	    // Hide Remove Entry
	    SEND_COMMAND dvTP, "'^SHO-',ITOA ( URL_UI_BTNS[BtnIndex + 30] ),',0'"
	}
    }
}


// Returns the entry index for a given gateway
DEFINE_FUNCTION INTEGER URL_UI_getURLIndexForGW(integer GW)
{
    STACK_VAR INTEGER i
    
    // Cycle through all the URL Entries
    for ( i=1; i<=20; i++ )
    {
	// Does Entry exist
	if ( URL_LIST[i].Port )
	{
	    // Does gateway URL match the entry URL
	    if ( GATEWAYS[GW].Url == URL_LIST[i].Url )
	    {
		return i 
	    }
	}
	else
	{
	    return 0
	}
    }
}


DEFINE_FUNCTION sLONG URL_UI_getURList(INTEGER position)
{
    STACK_VAR URL_STRUCT blank[20]
    
    // Clear URL List
    URL_LIST = blank   
    
    // Clear List Elements
    clearListElements(URL_UI_LIST)
    
    // Get list
    URL_LIST_LENGTH = GET_URL_LIST( dvSystem, URL_LIST, 1 )
    
    // If device online
    if ( URL_LIST_LENGTH > -1 )
    {
	if ( URL_LIST_LENGTH == 0 )
	{
	    addListElement( 
		URL_UI_LIST, 
		'No URL Entries', 
		1, 
		0 
	    ) 
	}
	else
	{
	    STACK_VAR INTEGER i
	    
	    // Cycle through each URL Entry and add to UI List
	    for ( i=1; i <= TYPE_CAST ( URL_LIST_LENGTH ); i++ )
	    {
		if ( URL_LIST[i].Port )
		{
		    addListElement( 
			URL_UI_LIST, 
			URL_LIST[i].URL, 
			i, 
			i 
		    ) 
		}
	    }
	}
	
	// Display List
	displayListData( URL_UI_LIST, position, URL_UI_BTNS, 0 )
    }
    
    return URL_LIST_LENGTH
} 

// Switches between stored gateway and 
DEFINE_FUNCTION URL_UI_switchGateways(INTEGER RemoveGW, INTEGER AddGW)
{
    STACK_VAR INTEGER URLIndex
    
    URLIndex = URL_UI_getURLIndexForGW(RemoveGW) 
    
    // remove gateway is active then remove
    if ( URLIndex )
    {
	// Remove Gateway
	DELETE_URL_ENTRY ( dvSystem, URL_LIST[URLIndex] )
    }
    
    // Add stored Gateway to URL List 2 secs after removing the previous gateway 
    WAIT 20 ADD_URL_ENTRY( dvSystem, GATEWAYS[AddGW] )
}

// Updates URL Entry Fields
DEFINE_FUNCTION URL_UI_updateURLEntryFields()
{
    // Show/Hide Add Button
    if ( !LENGTH_STRING ( URL_ENTRY.URL ) )
    {
	// If Blank remove add button from UI
	SEND_COMMAND dvTP, "'^SHO-',ITOA( URL_UI_BTNS[43] ),',0'"
    }
    ELSE
    {
	// If not Blank show add button from UI
	SEND_COMMAND dvTP, "'^SHO-',ITOA( URL_UI_BTNS[43] ),',1'"
    }
    
    // Show/Hide Assign Buttons
    if ( !LENGTH_STRING ( URL_ENTRY_SYSTEM_NUM ) )
    {
	// If Blank remove add button from UI
	SEND_COMMAND dvTP, "'^SHO-',ITOA( URL_UI_BTNS[4] ),',0'"
    }
    ELSE
    {
	// If not Blank show add button from UI
	SEND_COMMAND dvTP, "'^SHO-',ITOA( URL_UI_BTNS[4] ),',1'"
    }
    
    // Update Text: URL
    SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[40] ),'-',URL_ENTRY.URL"
    
    // Update Text: User
    SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[41] ),'-',URL_ENTRY.USER"
    
    if ( LENGTH_STRING ( URL_ENTRY.Password ) )
    {
	// Update Text and Shrowd: Password
	SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[42] ),'-',UTILITIES_shrowdPassword ( URL_ENTRY.Password )"
    }
    ELSE
    {
	// Clear Password Field
	SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[42] ),'-'"
    }
}

DEFINE_FUNCTION URL_UI_updateGatewayFields()
{
    // Update GW Fields: GW1
    SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[1] ),'-',GATEWAYS[1].url"
    
    // Update GW Fields: GW2
    SEND_COMMAND dvTP, "'TEXT',ITOA ( URL_UI_BTNS[2] ),'-',GATEWAYS[2].url"
}


DEFINE_FUNCTION URL_UI_removeDuplicates()
{
    STACK_VAR INTEGER i,GW1,GW2
    
    // Cycle through URL List
    FOR ( i=1; i<=TYPE_CAST ( URL_LIST_LENGTH ); i++ )
    {
	// Find GW 1
	IF ( GATEWAYS[1].url == URL_LIST[i].URL )
	{
	    GW1 = true
	}
	
	// Find GW 2
	ELSE if ( GATEWAYS[2].url == URL_LIST[i].URL )
	{
	    GW2 = true
	}
    }
    
    // if both gateways are active remove GW2
    if ( GW1 AND GW2 )
    {
	// Switch to gateway 1
	URL_UI_switchGateways( 2, 1 )
	
	// update UI
	URL_UI_getURList(UIList[URL_UI_LIST].Position)
    }
}

//Returns Active Gateway Index
DEFINE_FUNCTION integer URL_UI_getActiveGW()
{
    STACK_VAR INTEGER i
    
    // Cycle through URL List
    FOR ( i=1; i<=TYPE_CAST ( URL_LIST_LENGTH ); i++ )
    {
	// Find GW 1
	IF ( GATEWAYS[1].url == URL_LIST[i].URL )
	{
	    return 1
	}
	
	// Find GW 2
	ELSE if ( GATEWAYS[2].url == URL_LIST[i].URL )
	{
	    return 2
	}
    }
    
    return 0
}

// Checks primary gateway availability
DEFINE_FUNCTION URL_UI_failOver()
{
    STACK_VAR INTEGER GW
    
    // Get active GW
    GW = URL_UI_getActiveGW()
    
    // If no active gateway set the promary gateway
    if ( !GW )
    {
	// If not add primary gateway to URL List
	ADD_URL_ENTRY( dvSystem, GATEWAYS[1] )
    }
    
    // if the there is a gateway connection
    ELSE
    {
	STACK_VAR INTEGER urlIndex
	
	// Get the URL List index for the active Gateway
	urlIndex = URL_UI_getURLIndexForGW(GW)
	
	// If gateway is active
	if ( !GW_ONLINE[GW] )
	{
	    // Is this the first time the gateway has dropped out
	    if ( !GW_TIME_OUT[GW] ) 
	    {
		// Check for duplications
		URL_UI_removeDuplicates()
		
		// Set Time out flag so at next pass (10secs) it drops to the else if still not connected
		GW_TIME_OUT[GW] = true
	    }
	    ELSE
	    {	
		// Primary Gateway
		if ( GW == 1 )
		{
		    // Switch to Gateway 2
		    URL_UI_switchGateways( 1, 2 )
		}
		// Secondary Gateway
		else
		{
		    // Switch to Gateway 1
		    URL_UI_switchGateways( 2, 1 )
		}	
	    }
	}
	ELSE
	{
	    GW_TIME_OUT[GW] = false
	}
	
	// If the primary gateway comes online
	IF ( GW_ONLINE[1] AND GW_TIME_OUT[1] ) 
	{
	    // Switch to Gateway 1
	    URL_UI_switchGateways( 2, 1 )
	    
	    // reset timeout
	    GW_TIME_OUT[1] = false
	}
	
	// If the secondary gateway comes online
	ELSE IF ( GW_ONLINE[2] AND GW_TIME_OUT[2] )
	{
	    GW_TIME_OUT[2] = false
	}
    } 
}


DEFINE_START

// Define Gateway 1
DEFAULT_GATEWAYS[1].Flags 	= 3
DEFAULT_GATEWAYS[1].Port 	= 1319
DEFAULT_GATEWAYS[1].URL		= 'amxgw1.training.globalknowledge.net'
DEFAULT_GATEWAYS[1].User	= 'admin'
DEFAULT_GATEWAYS[1].Password	= 'ya73iW7dB7Ed6g5l'
DEFAULT_GW_SYSTEM_NUM[1]	= 101


// Define Gatway 2
DEFAULT_GATEWAYS[2].Flags 	= 3
DEFAULT_GATEWAYS[2].Port 	= 1319
DEFAULT_GATEWAYS[2].URL		= 'amxgw2.training.globalknowledge.net'
DEFAULT_GATEWAYS[2].User	= 'admin'
DEFAULT_GATEWAYS[2].Password	= 'ya73iW7dB7Ed6g5l'
DEFAULT_GW_SYSTEM_NUM[2]	= 102


// Create a URL UI list
URL_UI_LIST = NewList(dvTP, 10, 4, 'urlist')

DEFINE_EVENT

BUTTON_EVENT [dvTP, URL_UI_BTNS]
{
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST( URL_UI_BTNS )
	
	SWITCH ( svButton )
	{
	    // Set GW1
	    CASE 1:
	    {
		// Add Gateway 1 to URL List
		ADD_URL_ENTRY( dvSystem, GATEWAYS[1] )
		
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)	    
	    }
	    
	    // Set GW2
	    CASE 2:
	    {
		// Add Gateway 2 to URL List
		ADD_URL_ENTRY( dvSystem, GATEWAYS[2] )
		
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)	    
	    }
	    
	    // Refresh URL UI List
	    CASE 3:
	    {
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)
	    }	
	    
	    // Assign User URL Entry to GW1
	    CASE 4:
	    CASE 5:
	    {
		// Is there a URL
		if ( LENGTH_STRING ( URL_ENTRY.URL ) )
		{
		    // Authentication Required
		    if ( LENGTH_STRING ( URL_ENTRY.User ) AND LENGTH_STRING ( URL_ENTRY.Password ) )
		    {
			URL_ENTRY.Flags = 3
		    }
		    ELSE
		    {
			URL_ENTRY.Flags = 1
		    }
		    
		    // Set Port Number to 1319
		    URL_ENTRY.Port = 1319
		    
		    // Assign URL Entry to GW X
		    GATEWAYS[svButton - 3] = URL_ENTRY
		    
		    // Clear Password from list
		    URL_ENTRY.Password = ''
		}
		ELSE
		{
		    // Warn User No URL
		    SEND_STRING 0, "'No Url'"
		}
		
		// Update Gatway fields
		URL_UI_updateGatewayFields()
	    }
	    
	    //Restore Default Gateways
	    CASE 6:
	    {
		GATEWAYS = DEFAULT_GATEWAYS
		GW_SYSTEM_NUM = DEFAULT_GW_SYSTEM_NUM
		
		// Update Gatway fields
		URL_UI_updateGatewayFields()
	    }
	    
	    // Switch to GW1
	    CASE 7:
	    {
		// Switch Gateways
		URL_UI_switchGateways(2,1)
		
		// Refresh List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)
	    }
	    
	    // Switch to GW2
	    CASE 8:
	    {
		// Switch Gateways
		URL_UI_switchGateways(1,2)	
		
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)
	    }
	    
	    //IncrementList
	    CASE 9:
	    {
		incrementList( URL_UI_LIST, 1, URL_UI_BTNS )
	    }
	    //DecrementList
	    CASE 10:
	    {
		decrementList( URL_UI_LIST, 1, URL_UI_BTNS )
	    }
	    
	    CASE 21:
	    CASE 22:
	    CASE 23:
	    CASE 24:
	    {
		STACK_VAR INTEGER URLIndex
		
		// Get URL Index
		URLIndex = GetDataIDFromDataSet ( URL_UI_LIST, svButton - 20 )
		
		// Remove Gateway 1 
		DELETE_URL_ENTRY ( dvSystem, URL_LIST[URLIndex] )
		
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)
	    }
	    
	    // URL
	    CASE 40:
	    {
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',URL_ENTRY.URL,
				     '&uinum=',ITOA ( dvTP.Number ),
				     '&uiport=',ITOA ( dvTP.Port ),
				     '&uisys=',ITOA ( dvTP.System )"
	    }
	    
	    // Username
	    CASE 41:
	    {
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',URL_ENTRY.User,
				     '&uinum=',ITOA ( dvTP.Number ),
				     '&uiport=',ITOA ( dvTP.Port ),
				     '&uisys=',ITOA ( dvTP.System )"
	    }
	    
	    // Password
	    CASE 42:
	    {
		//Display Keybard Field
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',UTILITIES_shrowdPassword( URL_ENTRY.Password ),
				     '&uinum=',ITOA ( dvTP.Number ),
				     '&uiport=',ITOA ( dvTP.Port ),
				     '&uisys=',ITOA ( dvTP.System )"
	    }
	    
	    // System Number
	    CASE 44:
	    {
		//Display Keybard Field
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',URL_ENTRY_SYSTEM_NUM,
				     '&uinum=',ITOA ( dvTP.Number ),
				     '&uiport=',ITOA ( dvTP.Port ),
				     '&uisys=',ITOA ( dvTP.System )"
	    }
	    
	    // Add URLENTRY to URL List
	    CASE 43:
	    {
		// Is there a URL
		if ( LENGTH_STRING ( URL_ENTRY.URL ) )
		{
		    // Authentication Required
		    if ( LENGTH_STRING ( URL_ENTRY.User ) AND LENGTH_STRING ( URL_ENTRY.Password ) )
		    {
			URL_ENTRY.Flags = 3
		    }
		    ELSE
		    {
			URL_ENTRY.Flags = 1
		    }
		    
		    // Set Port Number to 1319
		    URL_ENTRY.Port = 1319
		    
		    // Add URL Entry
		    ADD_URL_ENTRY ( dvSystem, URL_ENTRY )
		    
		    // Clear Password from list
		    URL_ENTRY.Password = ''
		    
		    // Refresh URL_LIST
		    URL_UI_getURList(UIList[URL_UI_LIST].Position)
		}
		ELSE
		{
		    // Warn User No URL
		    SEND_STRING 0, "'No Url'"
		}
	    }
	}
    }
}


DATA_EVENT [ dvTP ]
{
    ONLINE:
    {
	// Update Gatway fields
	URL_UI_updateGatewayFields()
	
	// Update URL Entry Fields
	URL_UI_updateURLEntryFields()
	
	// Refresh list when panel comes online
	URL_UI_getURList(1)
    }
}

//Add Keyboard Functions
DATA_EVENT [vdvSystem]
{
    ONLINE:
    {
	//Add Focusable fields for the Keyboard processor: URL_Entry.Url
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=URL &uinum=',ITOA ( dvTP.number ),
							    '&uiport=',ITOA ( dvTP.Port ),
							    '&uisys=',ITOA ( dvTP.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[40] )"
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.User
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=Username &uinum=',ITOA ( dvTP.number ),
							    '&uiport=',ITOA ( dvTP.Port ),
							    '&uisys=',ITOA ( dvTP.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[41] )"
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.Password
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=Password &uinum=',ITOA ( dvTP.number ),
							    '&uiport=',ITOA ( dvTP.Port ),
							    '&uisys=',ITOA ( dvTP.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[42] )" 
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.SystemNum
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=System Number &uinum=',ITOA ( dvTP.number ),
							    '&uiport=',ITOA ( dvTP.Port ),
							    '&uisys=',ITOA ( dvTP.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[44] )" 
    }
    
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Field Value Listener
	IF ( FIND_STRING ( aCommand.CommandName, 'FIELDS_Response', 1 ) )
	{
	    STACK_VAR INTEGER svButton
	    STACK_VAR CHAR svData[255]
	    
	    //Get button number
	    svButton = ATOI ( getAttrValue( 'btnnum', aCommand ) )
	    
	    //Get user response
	    svData = getAttrValue( 'data', aCommand ) 
	    
	    //Evaluate Button Numbers
	    if ( ( ATOI ( getAttrValue( 'uinum', aCommand ) ) == dvTP.number ) AND 
			( ATOI ( getAttrValue( 'uiport', aCommand ) ) == dvTP.port ) AND 
			( ATOI ( getAttrValue( 'uisys', aCommand ) ) == dvTP.system ) )
	    {
		// URL Entry URL field
		if ( svButton == URL_UI_BTNS[40] )
		{
		    // URL Entry Url
		    URL_ENTRY.URL = svData
		}
		
		// URL Entry User field
		if ( svButton == URL_UI_BTNS[41] )
		{
		    // URL Entry User
		    URL_ENTRY.User = svData
		}
		
		// URL Entry Password field
		if ( svButton == URL_UI_BTNS[42] )
		{
		    // URL Entry User
		    URL_ENTRY.Password = svData
		}
		
		// URL Entry System Number
		if ( svButton == URL_UI_BTNS[44] )
		{
		    // URL Entry System Number
		    URL_ENTRY_SYSTEM_NUM = ATOI ( svData )
		}
		
		// Check Entry
		URL_UI_updateURLEntryFields()
	    }
	}
    }
}



DEFINE_PROGRAM

URL_UI_feedback()

WAIT 5
{
    FLASH = !FLASH
}