PROGRAM_NAME='MobileGateway'

DEFINE_DEVICE

// RMS Sockets_________________________________________________________________
dvRMSSocket1	= 0:11:0
dvRMSSocket2	= 0:12:0
dvRMSSocket3	= 0:13:0

// RMS Virtual Devices (This is what the mobile gateways talk to_______________

vdvRMSEngine1 	= 33101:1:0
vdvRMSEngine2 	= 33102:1:0
vdvRMSEngine3 	= 33103:1:0

vdvCLActions1 	= 33201:1:0
vdvCLActions2 	= 33202:1:0
vdvCLActions3 	= 33203:1:0


// System Virtual Device_______________________________________________________
vdvSystem	= 33050:1:0



DEFINE_START

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL1(vdvCLActions1)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng1(vdvRMSEngine1, dvRMSSocket1, vdvCLActions1)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL2(vdvCLActions2)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng2(vdvRMSEngine2, dvRMSSocket2, vdvCLActions2)

//Define RMS Modules
DEFINE_MODULE 'i!-ConnectLinxEngineMod' mdlCL3(vdvCLActions3)
DEFINE_MODULE 'RMSEngineMod' mdlRMSEng3(vdvRMSEngine3, dvRMSSocket3, vdvCLActions3)



DEFINE_EVENT

DATA_EVENT[vdvRMSEngine1]
DATA_EVENT[vdvRMSEngine2]
DATA_EVENT[vdvRMSEngine3]
{
    ONLINE:
    {
	SEND_COMMAND DATA.DEVICE, "'SERVER-classroommanager.amx.com'"
    }
}
