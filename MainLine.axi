PROGRAM_NAME='MainLine'

DEFINE_VARIABLE

VOLATILE INTEGER FLASH

DEFINE_PROGRAM

//Flashing FeedBack

WAIT 10
{
    FLASH = !FLASH
}

//Devices______________________________________________________________________

[dvTP, UIBtns[71]] = [vdvProjector1, POWER_FB] 
[dvTP, UIBtns[72]] = [vdvProjector2, POWER_FB] 
[dvTP, UIBtns[73]] = [vdvProjector3, POWER_FB]

[dvTP, UIBtns[74]] = ( [vdvProjector1, LAMP_WARMING_FB] OR [vdvProjector1, LAMP_COOLING_FB] ) AND FLASH
[dvTP, UIBtns[75]] = ( [vdvProjector2, LAMP_WARMING_FB] OR [vdvProjector2, LAMP_COOLING_FB] ) AND FLASH
[dvTP, UIBtns[76]] = ( [vdvProjector3, LAMP_WARMING_FB] OR [vdvProjector3, LAMP_COOLING_FB] ) AND FLASH

[dvTP, UIBtns[77]] = [vdvProjector1, PIC_MUTE_FB] 
[dvTP, UIBtns[78]] = [vdvProjector2, PIC_MUTE_FB] 
[dvTP, UIBtns[79]] = [vdvProjector3, PIC_MUTE_FB]

//Codec________________________________________________________________________
if (ACTIVE_SYSTEM)
{
    //Active Camera Feedback
    [dvTPCodec, VCCameraBtns[7]] = ACTIVE_CAMERA[ACTIVE_SYSTEM] == 1
    [dvTPCodec, VCCameraBtns[8]] = ACTIVE_CAMERA[ACTIVE_SYSTEM] == 2
}


[dvTPCodec, VCVolumeControls[1]] = [ vdvCodecs[ACTIVE_SYSTEM], VCONF_PRIVACY_FB ]
[dvTPCodec, VCVolumeControls[4]] = [ vdvCodecs[ACTIVE_SYSTEM], VOL_MUTE_FB ]

[dvTPCodec, VCCameraBtns[9] ] = [ vdvCodecs[ACTIVE_SYSTEM], 305 ]
[dvTPCodec, VCCameraBtns[30]] = [ vdvCodec, 303 ]

if ( ACTIVE_CAMERA[ACTIVE_SYSTEM] != 0 )
{
    [ dvTPCodec, VCCameraBtns[10] ] = CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] == 1
    [ dvTPCodec, VCCameraBtns[11] ] = CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] == 2
    [ dvTPCodec, VCCameraBtns[12] ] = CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] == 3
    [ dvTPCodec, VCCameraBtns[13] ] = CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] == 4
    [ dvTPCodec, VCCameraBtns[14] ] = CAMERA_PRESET_ACTIVE[ACTIVE_SYSTEM] == 5
}


//RMS__________________________________________________________________________

//Loop to prevent multiple refresh requests
WAIT 20
{
    if ( RMS_REFRESH_DATA )
    {
	//Refreshes Current lesson data
	RMS_RefreshLessonData()
	
	//Reset Flag
	OFF[RMS_REFRESH_DATA]
    }
}



WAIT 100
{
    //Check to see if there are any call attempt failures 
    if ( CODECS_CallAttempts() )
    {
	//Show Alert button 
	SEND_COMMAND dvTP, "'^SHO-',ITOA ( UIBtns[81] ),',1'"
    }
    
    //ensure sites are connected
    CODEC_connectSites()

    //If RMS is being overridden
    IF ( OVERRIDE_RMS )
    {
	//if the room needs to be setup
	if ( OVERRIDE_RMS <= 3 )
	{
	    //Setup room
	    SYSTEM_setupRoom( OVERRIDE_RMS )
	}
    }
    
    //Run Room setup
    ELSE if ( RMS_LEVELS.Current AND !RECURRING_SHUTDOWN )
    {
	if ( LIVE_LESSON.Type )
	{
	    //If only participant then setup room as Offline
	    if ( SYSTEM_countLessonSites(cLIVE) < 2 )
	    {
		//Setup room for this lesson
		SYSTEM_setupRoom( OFF_LINE )
	    }
	    ELSE
	    {
		//Setup room for this lesson
		SYSTEM_setupRoom( LIVE_LESSON.Type )
	    }
	    
	    //Switch Camera Once to correct camera
	    IF ( ( SYSTEM_countLessonSites(cLIVE) == 1 ) AND !CAM_LESSON_SWITCHED)
	    {
		//Set Amplifier
		SEND_COMMAND vdvAmplifier, "'Volume-75'"
		
		LIGHTS_recallPreset( vdvLight, 16 )
		ON[CAM_LESSON_SWITCHED]
		
	    }
	    
	    else if ( LIVE_LESSON.Type == TEACHER AND !CAM_LESSON_SWITCHED)
	    {
		CODEC_getCameraPreset(1)
		
		//Set Amplifier
		SEND_COMMAND vdvAmplifier, "'Volume-75'"
		
		LIGHTS_recallPreset( vdvLight, 14 )
		ON[CAM_LESSON_SWITCHED]
		
		//Switch Off OSD
		OFF[vdvCodec, 303]
	    }
	    ELSE if ( LIVE_LESSON.Type == STUDENT AND !CAM_LESSON_SWITCHED)
	    {
		CODEC_getCameraPreset(3)
		
		//Set Amplifier
		SEND_COMMAND vdvAmplifier, "'Volume-75'"
		
		LIGHTS_recallPreset( vdvLight, 15 )
		ON[CAM_LESSON_SWITCHED]
		
		//Switch Off OSD
		OFF[vdvCodec, 303]
	    }
	}
    }    
    
    //Shut Down room
    ELSE 
    {
	SYSTEM_shutDownDevices( )
	
	OFF[CAM_LESSON_SWITCHED]
	
	OFF[PROJECTOR_INIT_START[1]]
	OFF[PROJECTOR_INIT_START[2]]
	OFF[PROJECTOR_INIT_START[3]]
	
	//Reset RECURRING Shut down flag
	if ( !RMS_LEVELS.Current )
	{
	    OFF[ RECURRING_SHUTDOWN ]
	}
    }
    
    //If Connected to the RMS server then evaluate the RMS Levels
    if ( [ vdvRMSEngine, 248 ] AND [ vdvRMSEngine, 249 ] AND [ vdvRMSEngine, 250 ])
    {
	//Revaluate Levels
	RMS_evaluateLevels()
    }
}

//When system should be trying to connect a call
if ( LIVE_LESSON.type == 1 AND !RECURRING_SHUTDOWN )
{
    ON[CONNECT_SITES]
}
ELSE
{
    OFF[CONNECT_SITES]
}

//System_______________________________________________________________________

//User Interface Feedback
[ dvTP, RMSBtns[1] ] = [ vdvRMSEngine, 248 ]
[ dvTP, RMSBtns[2] ] = [ vdvRMSEngine, 249 ]
[ dvTP, RMSBtns[3] ] = [ vdvRMSEngine, 250 ]

//Override Buttons
[ dvTP, UIBtns[82] ] = OVERRIDE_RMS 
[ dvTP, UIBtns[83] ] = OVERRIDE_RMS == TEACHER
[ dvTP, UIBtns[84] ] = OVERRIDE_RMS == STUDENT
[ dvTP, UIBtns[85] ] = OVERRIDE_RMS == OFF_LINE

//Site List Filter Buttons
[ dvTP, UIBtns[87] ] = SITE_LIST_FILTER == SITE
[ dvTP, UIBtns[88] ] = SITE_LIST_FILTER == VIRTUAL

//Transmission Type
[ dvTP, UIBtns[91] ] = ![vdvCodec, 309]
[ dvTP, UIBtns[92] ] = [vdvCodec, 309]

//Feed back for menu buttons
[ dvTP, UIbtns[51] ] = ( SELECTED_MENU == 51 )
[ dvTP, UIbtns[52] ] = ( SELECTED_MENU == 52 )
[ dvTP, UIbtns[53] ] = ( SELECTED_MENU == 53 )
[ dvTP, UIbtns[54] ] = ( SELECTED_MENU == 54 )
[ dvTP, UIbtns[55] ] = ( SELECTED_MENU == 55 )
[ dvTP, UIbtns[56] ] = ( SELECTED_MENU == 56 )
[ dvTP, UIbtns[57] ] = ( SELECTED_MENU == 57 )
[ dvTP, UIbtns[58] ] = ( SELECTED_MENU == 58 )

//Presentation Input UI Feedback
[ dvTP, UIbtns[7 ] ] = [ dvRelay, 1 ]
[ dvTP, UIBtns[8 ] ] = [ dvRelay, 2 ]

//System Ready
[ dvTP, UIBtns[5 ] ]  = [vdvSystem, DATA_INITIALIZED]

//Sets the feedback for the individual mic mutes
SYSTEM_micMuteSiteFB()

//Device maintain Connection___________________________________________________
WAIT 450
{	
    DEVICES_MaintainConnection()
}

//RMS Refresh lesson every 5 mins
WAIT 3000
{
    SEND_COMMAND vdvRMSEngine, "'GET APPTS-',LDATE"
}



