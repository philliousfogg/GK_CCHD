PROGRAM_NAME='IP_Table'

DEFINE_VARIABLE

VOLATILE URL_STRUCT CCHD_ENTRIES[22]
 
DEFINE_START

// London - Brunswick
/*CCHD_ENTRIES[1].Flags 	= 1
CCHD_ENTRIES[1].Port 	= 1319
CCHD_ENTRIES[1].URL	= '10.44.84.15'*/

// Copenhagen - Room: Stockholm
CCHD_ENTRIES[2].Flags 	= 1
CCHD_ENTRIES[2].Port 	= 1319
CCHD_ENTRIES[2].URL	= '10.46.43.15'

// Leeds - Room 3
/*CCHD_ENTRIES[3].Flags 	= 1
CCHD_ENTRIES[3].Port 	= 1319
CCHD_ENTRIES[3].URL	= '10.44.116.15'

// Dublin
CCHD_ENTRIES[4].Flags 	= 1
CCHD_ENTRIES[4].Port 	= 1319
CCHD_ENTRIES[4].URL	= '10.35.43.15'

// Leeds - Room 4
CCHD_ENTRIES[5].Flags 	= 1
CCHD_ENTRIES[5].Port 	= 1319
CCHD_ENTRIES[5].URL	= '10.44.115.143'

// London - Kensington
CCHD_ENTRIES[6].Flags 	= 1
CCHD_ENTRIES[6].Port 	= 1319
CCHD_ENTRIES[6].URL	= '10.44.83.143'

// Wokingham - Monza
CCHD_ENTRIES[7].Flags 	= 1
CCHD_ENTRIES[7].Port 	= 1319
CCHD_ENTRIES[7].URL	= '10.44.43.15'*/

// Stockholm - Room: New York
CCHD_ENTRIES[8].Flags 	= 1
CCHD_ENTRIES[8].Port 	= 1319
CCHD_ENTRIES[8].URL	= '10.45.43.15'

// Oslo - Room 2
CCHD_ENTRIES[9].Flags 	= 1
CCHD_ENTRIES[9].Port 	= 1319
CCHD_ENTRIES[9].URL	= '10.47.43.15'

// Mobile Gateway 1 (System 101)
CCHD_ENTRIES[21].Flags 		= 3
CCHD_ENTRIES[21].Port 		= 1319
CCHD_ENTRIES[21].URL		= '10.255.62.22'
CCHD_ENTRIES[21].User		= 'admin'
CCHD_ENTRIES[21].Password	= 'ya73iW7dB7Ed6g5l'

// Mobile Gateway 2 (System 102)
/*CCHD_ENTRIES[22].Flags 		= 3
CCHD_ENTRIES[22].Port 		= 1319
CCHD_ENTRIES[22].URL		= '10.253.33.22'
CCHD_ENTRIES[22].User		= 'admin'
CCHD_ENTRIES[22].Password	= 'ya73iW7dB7Ed6g5l'*/


// Makes This System the Master System by adding all the other systems, except itself to the URL Table
DEFINE_FUNCTION IP_TABLE_setMaster()
{
    STACK_VAR INTEGER i 
    
    FOR ( i=1; i<=22; i++ )
    {
	// Make sure it is not itself
	if ( i != SYSTEM_NUMBER )
	{
	    if ( CCHD_ENTRIES[i].Port )
	    {
		// Add system to IP Table
		ADD_URL_ENTRY ( dvSystem, CCHD_ENTRIES[i] )
	    }
	}
    }	
}


DEFINE_EVENT 

BUTTON_EVENT [dvTPUrl, URL_UI_BTNS]
{
    RELEASE:
    {
	STACK_VAR INTEGER svButton
	
	svButton = GET_LAST( URL_UI_BTNS )
	
	SWITCH ( svButton )
	{
	    // Make this system the master system
	    CASE 48:
	    {
		IP_TABLE_setMaster()
	    }
	}
    }
}


