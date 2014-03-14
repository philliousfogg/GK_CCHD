PROGRAM_NAME='TestAMp'

#INCLUDE 'SNAPI.axi'

DEFINE_DEVICE 

dvLights = 0:2:0
vdvLights = 33011:1:0

DEFINE_VARIABLE


DEFINE_START

DEFINE_MODULE 'NECPROJECTOR' proj1 ( vdvLights, dvLights )

DEFINE_EVENT

DATA_EVENT [vdvLights]
{
    ONLINE:
    {
	SEND_COMMAND vdvLights, "'PROPERTY-IP_Address,10.49.43.12'"
    }
}

