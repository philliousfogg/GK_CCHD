PROGRAM_NAME='MobileRMSDevices'

DEFINE_DEVICE

// RMS Engine Virtual Devices on Gateway 1
vdvRMSEngine1	= 33101:1:101
vdvRMSEngine2	= 33102:1:101
vdvRMSEngine3	= 33103:1:101
vdvRMSEngine4	= 33104:1:101
vdvRMSEngine5	= 33105:1:101

// ConnectLinx Virtual Devices on Gateway 1
vdvCLActions1	= 33201:1:101
vdvCLActions2	= 33202:1:101
vdvCLActions3	= 33203:1:101
vdvCLActions4	= 33204:1:101
vdvCLActions5	= 33205:1:101

// Lesson event Listener on Gateway 1
vdvLessonM1	= 33301:1:101
vdvLessonM2	= 33302:1:101
vdvLessonM3	= 33303:1:101
vdvLessonM4	= 33304:1:101
vdvLessonM5	= 33305:1:101

DEFINE_VARIABLE

// Array of RMS Engines
VOLATILE DEV vdvMRMSEngines[] = {

    vdvRMSEngine1,
    vdvRMSEngine2,
    vdvRMSEngine3,
    vdvRMSEngine4,
    vdvRMSEngine5
}

// Array of ConnectLinx Action
VOLATILE DEV vdvMCLActions[] = {
    
    vdvCLActions1,
    vdvCLActions2,
    vdvCLActions3,
    vdvCLActions4,
    vdvCLActions5
}

// Array of Lesson event Listeners
VOLATILE DEV vdvMLessons[] = {

    vdvLessonM1,
    vdvLessonM2,
    vdvLessonM3,
    vdvLessonM4,
    vdvLessonM5
}