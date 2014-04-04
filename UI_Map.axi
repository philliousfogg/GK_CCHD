PROGRAM_NAME='UI_Map'


DEFINE_VARIABLE 

VOLATILE INTEGER MOBILE_MAP_POINT[3]

DEFINE_FUNCTION UI_MAP_clearPoints()
{
    STACK_VAR INTEGER i
    
    // Hide all sites on the map
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[i], false )
    }
}

DEFINE_FUNCTION UI_Map_attendingSites( integer lesson )
{
    STACK_VAR INTEGER i 
    STACK_VAR INTEGER mobileCt
    STACK_VAR CHAR site[255]
    
    UI_MAP_clearPoints()
    
    //Cycle through each system and find the sites in this lesson
    for ( i=1; i<LENGTH_SYSTEMS; i++ )
    {
	//if the system exists in the slot
	if ( SYSTEMS[i].SystemNumber )
	{
	    if ( lesson == cNEXT )
	    {
		//is the system attending the next lesson
		if ( SYSTEMS[i].nextLesson )
		{
		    if ( SYSTEMS[i].mobile )
		    {
			mobileCt ++
			
			if ( mobileCt <= 3 )
			{
			    MOBILE_MAP_POINT[mobileCt] = SYSTEMS[i].systemNumber 
			    SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[mobileCt + 30], true )
			    SEND_COMMAND dvTP, "'TEXT',ITOA( SiteMapBtns[mobileCt + 30] ),'-',SYSTEMS[i].name"
			}
		    }
		    else
		    {
			SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[SYSTEMS[i].systemNumber], true )
		    }
		}
	    }
	    ELSE if ( lesson == cLIVE )
	    {
		//is the system attending the current lesson
		if ( SYSTEMS[i].liveLesson )
		{
		    if ( SYSTEMS[i].mobile )
		    {
			mobileCt ++
			
			if ( mobileCt <= 3 )
			{
			    MOBILE_MAP_POINT[mobileCt] = SYSTEMS[i].systemNumber 
			    SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[mobileCt + 30], true )
			    SEND_COMMAND dvTP, "'TEXT',ITOA( SiteMapBtns[mobileCt + 30] ),'-',SYSTEMS[i].name"
			}
		    }
		    else
		    {
			SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[SYSTEMS[i].systemNumber], true )
		    }
		}
	    }
	}
	ELSE
	{
	    break
	}
    }
    
    // Check for external sites
    /*if ( lesson == cNEXT )
    {
	if ( LENGTH_STRING( NEXT_LESSON.external ) )
	{
	    mobileCt ++
	    
	    if ( mobileCt <= 3 )
	    {
		MOBILE_MAP_POINT[mobileCt] = 1001
		SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[mobileCt + 30], true )
		
		site = NEXT_LESSON.external
		
		SEND_COMMAND dvTP, "'TEXT',ITOA( SiteMapBtns[mobileCt + 30] ),'-External'"
	    }
	}
    }
    
    // Check for external sites
    ELSE IF ( lesson == cLIVE )
    {
	if ( LENGTH_STRING( LIVE_LESSON.external ) )
	{
	    mobileCt ++
	    
	    if ( mobileCt <= 3 )
	    {
		MOBILE_MAP_POINT[mobileCt] = 1001
		SYSTEM_setBtnVisibility( dvTP, SiteMapBtns[mobileCt + 30], true )
		
		site = LIVE_LESSON.external
		
		SEND_COMMAND dvTP, "'TEXT',ITOA( SiteMapBtns[mobileCt + 30] ),'-External'"
	    }
	}
    }*/
}

DEFINE_FUNCTION UI_MAP_feedback()
{
    STACK_VAR INTEGER i 
    
    // Cycle through CCHD Rooms and set this System
    FOR ( i=1; i<=30; i++ )
    {
	STACK_VAR INTEGER index
	
	index = SYSTEM_getIndexFromSysNum(i)
	
	if ( index )
	{
	    if ( SYSTEMS[index].systemNumber )
	    {
		[dvTP, SiteMapBtns[i] ] = SYSTEMS[index].thisSystem
	    }
	}
    }
    
    // Cycle through mobile units and set this System
    FOR ( i=1; i<=3; i++ )
    {
	STACK_VAR INTEGER index
	
	index = SYSTEM_getIndexFromSysNum(MOBILE_MAP_POINT[i])
	
	if ( index )
	{	
	    if ( SYSTEMS[index].systemNumber )
	    {
		[dvTP, SiteMapBtns[i + 30] ] = SYSTEMS[index].thisSystem
	    }
	}
    }	
}



