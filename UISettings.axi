PROGRAM_NAME='UISettings'

DEFINE_VARIABLE

// Settings User interface buttons
VOLATILE CHAR UI_SETTINGS_POP[][16] = {

    'Scheduling',
    'Room',
    'Codec',
    'CCHD',
    'IPTable'
}

// Settings Buttons for v2 > panel
VOLATILE INTEGER UISettingsBtns[] = {
    
    1, //1: Enter Setting Page
    2,3,4,5,6,7,8,9,10,
    11,12,13,14,15,16,17,18,19 //11->19: Settings sections buttons
}

// Selected Menu Item
VOLATILE INTEGER UI_SETTINGS_SELECTED_ITEM

// Handle button feedback
DEFINE_FUNCTION UISETTINGS_feedback()
{
    STACK_VAR INTEGER i 
    
    // Cycle through each menu button to see if it needs displaying
    FOR ( i=1; i<=9; i++ )
    {
	[dvTPSettings, UISettingsBtns[i+10]] = ( UI_SETTINGS_SELECTED_ITEM == i )
    }
}


DEFINE_EVENT 

BUTTON_EVENT [dvTPSettings, UISettingsBtns]
{
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST ( UISettingsBtns )
	
	SWITCH ( svButton )
	{
	    // Launch Settings Menu Page
	    CASE 1: 
	    {
		// Flip to settings Page
		SEND_COMMAND dvTPSettings, "'PAGE-Settings'"
		
		// Display first popup
		UI_SETTINGS_SELECTED_ITEM = 1
		
		SEND_COMMAND dvTPSettings, "'@PPN-[Setup]',UI_SETTINGS_POP[UI_SETTINGS_SELECTED_ITEM],';Settings'"
	    }
	    
	    CASE 11:
	    CASE 12:
	    CASE 13:
	    CASE 14:
	    CASE 15:
	    CASE 16:
	    CASE 17:
	    CASE 18:
	    CASE 19:
	    {
		// Display Selected popup
		UI_SETTINGS_SELECTED_ITEM = svButton - 10
		
		SEND_COMMAND dvTPSettings, "'@PPN-[Setup]',UI_SETTINGS_POP[UI_SETTINGS_SELECTED_ITEM],';Settings'"
	    }
	}
    }
}

// Events when TP comes online
DATA_EVENT [ dvTPSettings ]
{
    ONLINE:
    {
	// Display the selected popup
	SEND_COMMAND dvTPSettings, "'@PPN-[Setup]',UI_SETTINGS_POP[UI_SETTINGS_SELECTED_ITEM],';Settings'"
    }
}

DEFINE_PROGRAM

// Menu Feedback
UISETTINGS_feedback()




