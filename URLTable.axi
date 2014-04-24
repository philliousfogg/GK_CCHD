PROGRAM_NAME='URLTable'

DEFINE_VARIABLE

VOLATILE INTEGER GW_AVAILABLE[2]
VOLATILE INTEGER GW_ALERT_ON
VOLATILE INTEGER ACTIVE_GW
VOLATILE INTEGER Attempt

// Deletes all entries from URL List
DEFINE_FUNCTION URL_UI_removeAllEntries()
{
    STACK_VAR INTEGER i
    
    // Get list
    URL_LIST_LENGTH = GET_URL_LIST( dvSystem, URL_LIST, 1 )
    
    if ( URL_LIST_LENGTH > 0 )
    {
	FOR ( i=1; i<=TYPE_CAST ( URL_LIST_LENGTH ); i++ )
	{
	    // Remove URL entry
	    DELETE_URL_ENTRY(dvSystem, URL_LIST[i])
	}
    }
}

// User Interface Feedback
DEFINE_FUNCTION URL_UI_feedback()
{
    STACK_VAR INTEGER i
    
    // Get list
    URL_LIST_LENGTH = GET_URL_LIST( dvSystem, URL_LIST, 1 )
    
    // Active Gateway is GW 2
    [dvTPUrl, URL_UI_BTNS[30]] = ACTIVE_GW == 2
    
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
		[dvTPUrl, URL_UI_BTNS[i + 10]] =   ( URL_LIST[urlIndex].Flags == 227 ) OR
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
		[dvTPUrl, URL_UI_BTNS[i + 10]] = 0 
	    }
	}
    }
    
    // Use IO indicators on Front Panel to indicate gateway
    [dvIO, 4] = URL_UI_getActiveGW() == 1
    [dvIO, 4] = ( URL_UI_getActiveGW() == 2 ) AND FLASH
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
    
    ACTIVE_GW = AddGW
    
    RMSSetActiveGateway(AddGW)
    
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
	SEND_COMMAND dvTPUrl, "'^SHO-',ITOA( URL_UI_BTNS[43] ),',0'"
    }
    ELSE
    {
	// If not Blank show add button from UI
	SEND_COMMAND dvTPUrl, "'^SHO-',ITOA( URL_UI_BTNS[43] ),',1'"
    }
    
    // Show/Hide Assign Buttons
    if ( !URL_ENTRY_SYSTEM_NUM )
    {
	// If Blank remove add button from UI
	SEND_COMMAND dvTPUrl, "'^SHO-',ITOA( URL_UI_BTNS[4] ),',0'"
    }
    ELSE
    {
	// If not Blank show add button from UI
	SEND_COMMAND dvTPUrl, "'^SHO-',ITOA( URL_UI_BTNS[4] ),',1'"
    }
    
    // Update Text: URL
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[40] ),'-',URL_ENTRY.URL"
    
    // Update Text: User
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[41] ),'-',URL_ENTRY.USER"
    
    if ( LENGTH_STRING ( URL_ENTRY.Password ) )
    {
	// Update Text and Shrowd: Password
	SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[42] ),'-',UTILITIES_shrowdPassword ( URL_ENTRY.Password )"
    }
    ELSE
    {
	// Clear Password Field
	SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[42] ),'-'"
    }
    
    // Update Text: URL Entry System Number
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[44] ),'-',ITOA ( URL_ENTRY_SYSTEM_NUM )"
}

DEFINE_FUNCTION URL_UI_updateGatewayFields()
{
    // Update GW Fields: GW1
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[1] ),'-',GATEWAYS[1].url"
    
    // Update GW Fields: GW2
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[2] ),'-',GATEWAYS[2].url"
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

// Checks connectivity of the Gateway
DEFINE_FUNCTION INTEGER URL_UI_isEntryConnected(INTEGER Index)
{
    return ( URL_LIST[Index].Flags == 227 ) OR ( URL_LIST[Index].Flags == 225 )
}

// Gets the entry index of the GW in the URL_LIST
DEFINE_FUNCTION INTEGER URL_UI_getIndexOfGW(INTEGER GW)
{
    STACK_VAR INTEGER i
    
    // Cycle through URL List
    FOR ( i=1; i<=TYPE_CAST ( URL_LIST_LENGTH ); i++ )
    {
	// Find GW 1
	IF ( GATEWAYS[GW].url == URL_LIST[i].URL )
	{
	    return i
	}
    }
    
    return 0
}

// Sets GW Alert with Text
DEFINE_FUNCTION URL_UI_setGWAlert( Char message[255])
{
    
    SEND_COMMAND dvTPUrl, "'TEXT',ITOA ( URL_UI_BTNS[20] ),'-',message"
    
    // if UI alert not displaying
    if ( !GW_ALERT_ON )
    {
	SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Admin'"
	SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Login'"
	SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Settings'"
	
	ON[GW_ALERT_ON]
    }
}

// Clear GW Alert 
DEFINE_FUNCTION URL_UI_clearGWAlert()
{
    if ( GW_ALERT_ON )
    {
	WAIT 50
	{
	    SEND_COMMAND dvTPURL, "'@PPK-_GWStatus'"
	    
	    OFF[GW_ALERT_ON]
	}
    }
}

// Checks primary gateway availability
DEFINE_FUNCTION URL_UI_failOver()
{
    STACK_VAR INTEGER GW
    STACK_VAR INTEGER GWIndex
    
    // Get Currently active gateway
    GW = ACTIVE_GW
    
    // Get the Index of the currently active index
    GWIndex = URL_UI_getIndexOfGW(GW)
     
    // Is the primary gateway active
    if ( GW == 1 )
    {
	// Is the active gateway connected 
	if ( !URL_UI_isEntryConnected(GWIndex) )
	{
	    URL_UI_setGWAlert("'Waiting to Connect to Primary Gateway - ',ITOA ( Attempt ),' secs'")
	    
	    // If it has checked the connection 3 times
	    if ( Attempt <= 20 )
	    {
		// Increment attempt counter
		Attempt ++
	    }
	    
	    ELSE
	    {
		// See if the GW is physically available
		if ( GW_AVAILABLE[2] )
		{
		    URL_UI_setGWAlert ( "'Switching to Secondary Gateway...'" )
		    
		    // Swap to GW 2
		    URL_UI_switchGateways( 1, 2 )
		    
		    // Reset GW_AVAILABLE flag
		    GW_AVAILABLE[2] = 0
		    
		    // Reset attempt counter
		    Attempt = 0
		}
		else 
		{
		    URL_UI_setGWAlert ( "'Checking Secondary Gateway Availability - ',ITOA ( Attempt - 20 ),' secs'" )
		    
		    // Try the secondary gateway for 30
		    if ( Attempt <= 30 )
		    {
			Attempt ++
		    }
		    
		    // Reset and try gateway 1
		    else
		    {
			Attempt = 0
		    }
		    
		    // Attempts a connections with Gateway 2
		    IP_CLIENT_OPEN ( GW2_COMMS.Port, GATEWAYS[2].url, 1319, IP_TCP )  
		}
	    }
	}
	ELSE
	{
	    // Clear any alerts
	    URL_UI_clearGWAlert()
	    
	    // reset attempt counter
	    ATTEMPT = 0
	}
    }
    
    // Is the secondary gateway active
    ELSE IF ( GW == 2 )
    {
	// Is the active gateway connected 
	if ( !URL_UI_isEntryConnected(GWIndex) )
	{
	    URL_UI_setGWAlert("'Waiting to Connect to Secondary Gateway - ',ITOA ( Attempt ),' secs'")
	    
	    // If it has checked the connection 3 times
	    if ( Attempt <= 20 )
	    {
		// Increment attempt counter
		Attempt ++
	    }
	    ELSE
	    {
		// See if the GW 1 is physically available
		if ( GW_AVAILABLE[1] )
		{
		    URL_UI_setGWAlert ( "'Switching to Primary Gateway...'" )
		    
		    // Swap to GW 2
		    URL_UI_switchGateways( 2, 1 )
		    
		    // Reset GW_AVAILABLE flag
		    GW_AVAILABLE[1] = 0
		    
		    // Reset attempt counter
		    Attempt = 0
		}
		else 
		{
		    URL_UI_setGWAlert ( "'Checking Primary Gateway Availability...'" )
		    
		    // Attempts a connections with Gateway 1
		    IP_CLIENT_OPEN ( GW1_COMMS.Port, GATEWAYS[1].url, 1319, IP_TCP )  
		}
	    }
	}
	
	// Keep trying primary gateway
	ELSE
	{
	    // Clear Alert
	    URL_UI_clearGWAlert()
	    
	    // See if the GW 1 is physically available
	    if ( GW_AVAILABLE[1] )
	    {
		// Swap to GW 2
		URL_UI_switchGateways( 2, 1 )
		
		// Reset GW_AVAILABLE flag
		GW_AVAILABLE[1] = 0
	    }
	    else 
	    {
		if ( Attempt > 3 )
		{
		    // Attempts a connections with Gateway 1
		    IP_CLIENT_OPEN ( GW1_COMMS.Port, GATEWAYS[1].url, 1319, IP_TCP )  
		    
		    Attempt = 0
		}
		else
		{
		    Attempt ++
		}
	    }
	}
    }
    
    // Is neither gateway active
    ELSE
    {
	URL_UI_setGWAlert ( "'Connecting to Primary Gateway...'" )
	
	// Switch to GW 1
	URL_UI_switchGateways( 2, 1 )
    }
}


DEFINE_START

// Removes All Url Entries to prevent duplications
URL_UI_removeAllEntries()

// Create a URL UI list
URL_UI_LIST = NewList(dvTPUrl, 10, 4, 'urlist')

// Initialise Gateway 1 Entry
if ( !GATEWAYS[1].port )
{
    GATEWAYS[1] = DEFAULT_GATEWAYS[1]
    GW_SYSTEM_NUM[1] = DEFAULT_GW_SYSTEM_NUM[1]
}


// Initialise Gateway 2 Entry
if ( !GATEWAYS[2].port )
{
    GATEWAYS[2] = DEFAULT_GATEWAYS[2]
    GW_SYSTEM_NUM[2] = DEFAULT_GW_SYSTEM_NUM[2]
}

DEFINE_EVENT

DATA_EVENT [ GW1_COMMS ]
DATA_EVENT [ GW2_COMMS ]
{
    ONLINE:
    {
	// Set GW_AVAILABLE flag to on
	ON [ GW_AVAILABLE[DATA.DEVICE.PORT - 20] ]
	
	// Close Connection
	IP_CLIENT_CLOSE ( DATA.DEVICE.PORT )
    }
}

BUTTON_EVENT [dvTPUrl, URL_UI_BTNS]
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
		
		// Switch Back to IP Table
		SEND_COMMAND dvTPURl, "'@PPN-[Setup]IPTable'"
	    }
	    
	    // Switch to GW2
	    CASE 8:
	    {
		// Switch Gateways
		URL_UI_switchGateways(1,2)	
		
		// Refresh UI List
		URL_UI_getURList(UIList[URL_UI_LIST].Position)
		
		// Switch Back to IP Table
		SEND_COMMAND dvTPURl, "'@PPN-[Setup]IPTable'"
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
				     '&uinum=',ITOA ( dvTPUrl.Number ),
				     '&uiport=',ITOA ( dvTPUrl.Port ),
				     '&uisys=',ITOA ( dvTPUrl.System )"
	    }
	    
	    // Username
	    CASE 41:
	    {
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',URL_ENTRY.User,
				     '&uinum=',ITOA ( dvTPUrl.Number ),
				     '&uiport=',ITOA ( dvTPUrl.Port ),
				     '&uisys=',ITOA ( dvTPUrl.System )"
	    }
	    
	    // Password
	    CASE 42:
	    {
		//Display Keybard Field
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',UTILITIES_shrowdPassword( URL_ENTRY.Password ),
				     '&uinum=',ITOA ( dvTPUrl.Number ),
				     '&uiport=',ITOA ( dvTPUrl.Port ),
				     '&uisys=',ITOA ( dvTPUrl.System )"
	    }
	    
	    // System Number
	    CASE 44:
	    {
		//Display Keybard Field
		SEND_COMMAND vdvSystem, "'DisplayKeyboard-btnnum=',ITOA( BUTTON.INPUT.CHANNEL ),
				     '&initialtext=',URL_ENTRY_SYSTEM_NUM,
				     '&uinum=',ITOA ( dvTPUrl.Number ),
				     '&uiport=',ITOA ( dvTPUrl.Port ),
				     '&uisys=',ITOA ( dvTPUrl.System )"
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
		    
		    // Switch Back to IP Table
		    SEND_COMMAND dvTPURl, "'@PPN-[Setup]IPTable'"
		}
		ELSE
		{
		    // Warn User No URL
		    SEND_STRING 0, "'No Url'"
		}
	    }
	    
	    // Show Add URL Options
	    CASE 45:
	    {
		SEND_COMMAND dvTPURl, "'@PPN-[Setup]AddUrlEntry'"
	    }
	    
	    // Show IP Table
	    CASE 46:
	    {
		SEND_COMMAND dvTPURl, "'@PPN-[Setup]IPTable'"
	    }
	    
	    // Remove All Entries 
	    CASE 47:
	    {
		// Removes all entries out of the URL Table
		URL_UI_removeAllEntries()
	    }
	}
    }
}


DATA_EVENT [ dvTPUrl ]
{
    ONLINE:
    {
	// Update Gatway fields
	URL_UI_updateGatewayFields()
	
	// Update URL Entry Fields
	URL_UI_updateURLEntryFields()
	
	// Refresh list when panel comes online
	URL_UI_getURList(1)
	
	// if UI alert is supposed to be displaying
	if ( GW_ALERT_ON )
	{		
	    SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Admin'"
	    SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Login'"
	    SEND_COMMAND dvTPUrl, "'@PPN-_GWStatus;Settings'"
	}
    }
}

//Add Keyboard Functions
DATA_EVENT [vdvSystem]
{
    ONLINE:
    {
	//Add Focusable fields for the Keyboard processor: URL_Entry.Url
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=URL &uinum=',ITOA ( dvTPUrl.number ),
							    '&uiport=',ITOA ( dvTPUrl.Port ),
							    '&uisys=',ITOA ( dvTPUrl.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[40] )"
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.User
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=Username &uinum=',ITOA ( dvTPUrl.number ),
							    '&uiport=',ITOA ( dvTPUrl.Port ),
							    '&uisys=',ITOA ( dvTPUrl.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[41] )"
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.Password
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=Password &uinum=',ITOA ( dvTPUrl.number ),
							    '&uiport=',ITOA ( dvTPUrl.Port ),
							    '&uisys=',ITOA ( dvTPUrl.System ),
							    '&btnnum=',ITOA( URL_UI_BTNS[42] )" 
							    
	//Add Focusable fields for the Keyboard processor: URL_Entry.SystemNum
	SEND_COMMAND vdvSystem, "'AddKeyboardField-label=System Number &uinum=',ITOA ( dvTPUrl.number ),
							    '&uiport=',ITOA ( dvTPUrl.Port ),
							    '&uisys=',ITOA ( dvTPUrl.System ),
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
	    if ( ( ATOI ( getAttrValue( 'uinum', aCommand ) ) == dvTPUrl.number ) AND 
			( ATOI ( getAttrValue( 'uiport', aCommand ) ) == dvTPUrl.port ) AND 
			( ATOI ( getAttrValue( 'uisys', aCommand ) ) == dvTPUrl.system ) )
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

WAIT 10
{
    URL_UI_failOver()
}
