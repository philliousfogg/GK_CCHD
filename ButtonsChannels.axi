PROGRAM_NAME='ButtonsChannels'

DEFINE_CONSTANT

VOLATILE INTEGER LISTS_LENGTH = 2

DEFINE_VARIABLE

VOLATILE INTEGER UIBtns[] = {

    1,  //Status Bar
    2,  //Active Room Name
    3,	//Splash Screen Status 1
    4,	//Connected Site
    5,	//System Ready Indicator
    6,  //Logout of Session
    7,	//Switch Resident PC
    8,	//Switch Laptop
    9,	//Increment Room List
    10, //Decrement Room List
    11,12,13,14,15,16,17,18,19,20, //Room List Items
    21,22,23,24,25,26,27,28,29,30, //Connected Sites 
    31,32,33,34,35,36,37,38,39,40, //Room Mic Mute Status
    41,42,43,44,45,46,47,48,49,50, //Call/Disconnect Icon
    
    //Room Control Menu Simple
    51, //Lesson Options
    52, //Camera Control
    53, //Presentation Control
    54,	//Lights Control
    55, //Site List
    56, //Device Control
    57, //Admin Settings (DEPRECATED)
    58,	//Screen Layout
    59, 
    60, //60 Volume/Mic Disable
    
    //Alert Boxes
    61, //Alert Title
    62, //Alert Message
    63, //Alert Ok
    64,65,66,67,68,69,70, //Spares
    
    71, //Projector 1 Power
    72, //Projector 2 Power
    73, //Projector 3 Power
    74, //Projector 1 Warming/Cooling
    75, //Projector 2 Warming/Cooling
    76, //Projector 3 Warming/Cooling
    77, //Projector 1 Picture Mute
    78, //Projector 2 Picture Mute
    79, //Projector 3 Picture Mute
    
    80, //This Room Name
    81,	//Reset call attempts (Retry Call Connection)
    82, //Override RMS Levels for maintance and Reset
    83, //Set room for Teacher
    84, //Set room for Student Only
    85, //Set room for Offline mode
    86, //Start Offline Lesson
    87, //Filter: Sites
    88, //Filter: Virtual
    89, //Filter: Mobile
    
    90, //90 Refresh System List
    91, //91 Use BridgeIt
    92, //92 Use Codec
    93,	//93 Change PIN
    94,95,96,97,98,99, //93->99 Spare
    100, //100 Amp Volume Up 
    101,  //101 Amp Volume Dn
    102,103,104,105,106,107,108,109,110, //Spares
    111,112,113,114,115,116,117,118,119,120, //Offline Notification Buttons
    
    121, //Filter: All
    122	 //Filtered Menu
}

VOLATILE INTEGER SiteMapBtns[] = {
    
    401,402,403,404,405,406,407,408,409,410, // CCHD Rooms
    411,412,413,414,415,416,417,418,419,420, // CCHD Rooms
    421,422,423,424,425,426,427,428,429,430, // CCHD Rooms
    431,432,433,434,435,436,437,438,439,440  // CCHD Mobile Units
}

VOLATILE INTEGER DialogsBtns[] = {

    101, //Option 1
    102, //Option 2
    103, //Option 3
    104, //Option 4
    105, //Title
    106	 //Message
}


VOLATILE INTEGER RMSBtns[] = {

    201, //1: RMS Server Socket Connected
    202, //2: RMS DB Online
    203, //3: RMS Server Online
    204,205,206,207,208,209, //4 -> 9 Spare
    
    210, //10: RMS Next meeting - Subject
    211, //11: RMS Next meeting - Instructor
    212, //12: RMS Next meeting - Message
    213, //13: RMS Next meeting - Lesson code
    214, //14: RMS Next meeting - Start Time
    215, //15: RMS Next Meeting - End Time
    216, //16: RMS Next Meeting - Attending Sites
    217, //17: RMS Next Meeting - Next Lesson/No Lesson
    218,219, //16 -> 19 Spare
    
    220, //20: RMS Current meeting - Subject
    221, //21: RMS Current meeting - Instructor
    222, //22: RMS Current meeting - Message
    223, //23: RMS Current meeting - Lesson code
    224, //24: RMS Current meeting - Start Time
    225, //25: RMS Current Meeting - End Time
    226, //26: RMS Current Meeting - Attending Sites
    227,228,229, //27 -> 29: Spare
    
    230, //30: End Lesson
    231, //31: Extend Lesson
    232, //32: Report Fault
    233, //33: Request Help
    234	 //34: Report/Request Title
}

//VC Controls (Port 2)
VOLATILE INTEGER VCCameraBtns[] = {

    //Zoom Controls
    66, //1: Camera Zoom In
    67, //2: Camera Zoom Out
    
    //Pan and Tilt
    68, //3: Camera Tilt Up
    69, //4: Camera Tilt Down
    70, //5: Camera Pan Left
    71, //6: Camera Pan Right
    
    124, //7: Camera 1 ( Student Camera ) 
    125, //8: Camera 2 ( Teacher Camera )
    
    15, //9: Selfview
    
    72,73,74,75,76,77,78,79,80,81, //10->19: Camera Presets
    102,103,104,105,106,107,109,110,111,112, //20->29: Save Camera Preset
    
    18, //30: OSD Cycle
    224,//31: Camera Help Button 1
    225,//32: Camera Help Button 2
    
    //Far/Conference Controls
    56, //33: Camera Zoom In
    57, //34: Camera Zoom Out
    
    //Far/Conference Pan and Tilt
    58, //35: Camera Tilt Up
    59, //36: Camera Tilt Down
    60, //37: Camera Pan Left
    61, //38: Camera Pan Right
    62, //39: MCU Camera Control Disable
    
    //DTMF Tones
    40,41,42,43,44,45,46,47,48,49,
    50, //51: Star
    51, //51: Hash
    
    19, //52: Auto Answer 
    20, //53: IR Disable
    21, //54: Cam 1 Backlight
    22,	//55: Cam 2 Backlight
    25, //56: Auto Answer Mic Mute
    
    30	//57: Camera Presets Tray Button
}

VOLATILE INTEGER VCVolumeControls[] = {
    
    16,	//Microphone Mute
    89,	//Audio Volume (+)
    90, //Audio Volume (-)
    91, //Audio Volume Mute
    92  //Audio Volume Level
}

VOLATILE INTEGER SystemChannels[] = {

    256 //Debug On
}

VOLATILE INTEGER UILightsBtns[] = {

    1, //1: Ramp Ch 1 up 
    2, //2: Ramp Ch 2 up
    3, //3: Ramp Ch 3 up
    4, //4: Ramp Ch 4 up
    5, //5: Ramp Ch 5 Down
    6, //6: Ramp Ch 6 Down
    7, //7: Ramp Ch 7 Down
    8, //8: Ramp Ch 8 Down
    9,
    10, //10: Off
    11, //11: 33%
    12, //12: 50%
    13, //13: 75%
    14, //14: Teacher
    15, //15: Student
    16, //16: Offline Lesson
    17, //17: User Defined
    18, //18: User Defined
    19, //19: Teacher
    20, //20: Student
    21, //21: Offline
    22, //22: 
    23, //23: 
    24, //24:
    25, //25: Increase TimeOut
    26, //26: Decrease TimeOut
    27, //27: Timeout Text
    28,29, //28->29: Spare
    30,31,32,33,34,35,36,37,38,39,40,41,42,43,44 //30->44: Save Preset 1-14
}

// URL UI Btns (Port 6)
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
    84, // 44: URL_Entry.SystemNumber Field
    85, // 45: Add Url Entry Popup
    86  // 46: Cancel URl Entry Popup
}


