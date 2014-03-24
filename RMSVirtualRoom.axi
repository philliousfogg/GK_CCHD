PROGRAM_NAME='RMSVirtualRoom'

DEFINE_START

DEFINE_MODULE 'RMSVirtualRoom' vRMSRoom( dvVRMSSocket,
					 vdvVRMSEngine,
					 vdvVCLActions,
					 vdvSystems,
					 vdvVSystem,
					 vdvVLesson)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdVlCL(vdvVCLActions)
DEFINE_MODULE 'RMSEngineMod' mdVlRMSEng(vdvVRMSEngine, dvVRMSSocket, vdvVCLActions)

// RMSUIMod - The RMS User Interface.  Requires KeyboardMod.
// Channel And Variable Text Code Defined Inside The Module
DEFINE_MODULE 'RMSUIMod' mdVlRMSUI(vdvVRMSEngine,
				  vdvVLesson,
                                  dvRMSTP,dvRMSTP_Base,dvRMSTPWelcome,dvRMSTPWelcome_Base,RMS_MEETING_DEFAULT_SUBJECT,RMS_MEETING_DEFAULT_MESSAGE)

