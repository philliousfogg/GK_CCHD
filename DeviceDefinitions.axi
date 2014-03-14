PROGRAM_NAME='DeviceDefinitions'

//Define all virtual and duet devices in the Estate
DEFINE_DEVICE

//Physical Devices RS232
dvAmplifier 	= 5001:1:0

//Relay Ports
dvRelay		= 5001:4:0 //5001:4:0

//I/O Ports
dvIO 		= 5001:9:0

//Ethernet Ports

dvRMSSocket	= 0:3:0
dvVRMSSocket 	= 0:4:0

dvCodec 	= 0:5:0
dvProjector1 	= 0:6:0
dvProjector2	= 0:7:0
dvProjector3	= 0:8:0

dvLights 	= 0:9:0

dvIP		= 0:10:0


vdvProjector1 	= 33011:1:0
vdvProjector2 	= 33012:1:0
vdvProjector3 	= 33013:1:0
vdvAmplifier 	= 33014:1:0
vdvLight	= 33015:1:0

vdvLog 		= 33051:1:0

//Define Virtual Devices
vdvSystem       = 33050:1:0
vdvVSystem	= 33055:1:0

vdvRMSEngine	= 33003:1:0
vdvCLActions	= 33004:1:0
vdvVRMSEngine	= 33005:1:0
vdvVCLActions	= 33006:1:0

//User Interfaces
dvTP 		= 10001:1:0
dvTPCodec	= 10001:2:0
dvTPRMS		= 10001:3:0
dvTPLights 	= 10001:4:0

dvTPRMS_Welcome = 10001:10:0

/*
//Duet Devices

vdvCodec 	= 41001:1:0
vdvCodecPres	= 41001:2:0

vdvCodec1  	= 41001:1:1
vdvCodec2  	= 41001:1:2
vdvCodec3  	= 41001:1:3
vdvCodec4  	= 41001:1:4
vdvCodec5  	= 41001:1:5
vdvCodec6  	= 41001:1:6
vdvCodec7 	= 41001:1:7
vdvCodec8  	= 41001:1:8
vdvCodec9  	= 41001:1:9
vdvCodec10 	= 41001:1:10

vdvCodec11 	= 41001:1:11
vdvCodec12 	= 41001:1:12
vdvCodec13 	= 41001:1:13
vdvCodec14 	= 41001:1:14
vdvCodec15 	= 41001:1:15
vdvCodec16 	= 41001:1:16
vdvCodec17 	= 41001:1:17
vdvCodec18 	= 41001:1:18
vdvCodec19 	= 41001:1:19
vdvCodec20 	= 41001:1:20

//Camera 2
vdvCodec1_Cam2 	= 41001:2:1
vdvCodec2_Cam2 	= 41001:2:2
vdvCodec3_Cam2  = 41001:2:3
vdvCodec4_Cam2  = 41001:2:4
vdvCodec5_Cam2  = 41001:2:5
vdvCodec6_Cam2  = 41001:2:6
vdvCodec7_Cam2 	= 41001:2:7
vdvCodec8_Cam2  = 41001:2:8
vdvCodec9_Cam2  = 41001:2:9
vdvCodec10_Cam2 = 41001:2:10

vdvCodec11_Cam2 = 41001:2:11
vdvCodec12_Cam2 = 41001:2:12
vdvCodec13_Cam2	= 41001:2:13
vdvCodec14_Cam2 = 41001:2:14
vdvCodec15_Cam2 = 41001:2:15
vdvCodec16_Cam2 = 41001:2:16
vdvCodec17_Cam2 = 41001:2:17
vdvCodec18_Cam2 = 41001:2:18
vdvCodec19_Cam2 = 41001:2:19
vdvCodec20_Cam2 = 41001:2:20

//Far End Cam
vdvCodecFar1	= 41001:8:1
vdvCodecFar2	= 41001:8:2
vdvCodecFar3	= 41001:8:3
vdvCodecFar4	= 41001:8:4
vdvCodecFar5	= 41001:8:5
vdvCodecFar6	= 41001:8:6
vdvCodecFar7	= 41001:8:7
vdvCodecFar8	= 41001:8:8
vdvCodecFar9	= 41001:8:9
vdvCodecFar10	= 41001:8:10

vdvCodecFar11	= 41001:8:11
vdvCodecFar12	= 41001:8:12
vdvCodecFar13	= 41001:8:13
vdvCodecFar14	= 41001:8:14
vdvCodecFar15	= 41001:8:15
vdvCodecFar16	= 41001:8:16
vdvCodecFar17	= 41001:8:17
vdvCodecFar18	= 41001:8:18
vdvCodecFar19	= 41001:8:19
vdvCodecFar20	= 41001:8:20

*/
vdvCodec 	= 33001:1:0
vdvCodecPres	= 33001:2:0

vdvCodec1  	= 33001:1:1
vdvCodec2  	= 33001:1:2
vdvCodec3  	= 33001:1:3
vdvCodec4  	= 33001:1:4
vdvCodec5  	= 33001:1:5
vdvCodec6  	= 33001:1:6
vdvCodec7 	= 33001:1:7
vdvCodec8  	= 33001:1:8
vdvCodec9  	= 33001:1:9
vdvCodec10 	= 33001:1:10

vdvCodec11 	= 33001:1:11
vdvCodec12 	= 33001:1:12
vdvCodec13 	= 33001:1:13
vdvCodec14 	= 33001:1:14
vdvCodec15 	= 33001:1:15
vdvCodec16 	= 33001:1:16
vdvCodec17 	= 33001:1:17
vdvCodec18 	= 33001:1:18
vdvCodec19 	= 33001:1:19
vdvCodec20 	= 33001:1:20

//Camera 2
vdvCodec1_Cam2 	= 33001:2:1
vdvCodec2_Cam2 	= 33001:2:2
vdvCodec3_Cam2  = 33001:2:3
vdvCodec4_Cam2  = 33001:2:4
vdvCodec5_Cam2  = 33001:2:5
vdvCodec6_Cam2  = 33001:2:6
vdvCodec7_Cam2 	= 33001:2:7
vdvCodec8_Cam2  = 33001:2:8
vdvCodec9_Cam2  = 33001:2:9
vdvCodec10_Cam2 = 33001:2:10

vdvCodec11_Cam2 = 33001:2:11
vdvCodec12_Cam2 = 33001:2:12
vdvCodec13_Cam2	= 33001:2:13
vdvCodec14_Cam2 = 33001:2:14
vdvCodec15_Cam2 = 33001:2:15
vdvCodec16_Cam2 = 33001:2:16
vdvCodec17_Cam2 = 33001:2:17
vdvCodec18_Cam2 = 33001:2:18
vdvCodec19_Cam2 = 33001:2:19
vdvCodec20_Cam2 = 33001:2:20




//Far End Non Duet
vdvCodecFar1	= 33001:8:1
vdvCodecFar2	= 33001:8:2
vdvCodecFar3	= 33001:8:3
vdvCodecFar4	= 33001:8:4
vdvCodecFar5	= 33001:8:5
vdvCodecFar6	= 33001:8:6
vdvCodecFar7	= 33001:8:7
vdvCodecFar8	= 33001:8:8
vdvCodecFar9	= 33001:8:9
vdvCodecFar10	= 33001:8:10

vdvCodecFar11	= 33001:8:11
vdvCodecFar12	= 33001:8:12
vdvCodecFar13	= 33001:8:13
vdvCodecFar14	= 33001:8:14
vdvCodecFar15	= 33001:8:15
vdvCodecFar16	= 33001:8:16
vdvCodecFar17	= 33001:8:17
vdvCodecFar18	= 33001:8:18
vdvCodecFar19	= 33001:8:19
vdvCodecFar20	= 33001:8:20

vdvCodecP1	= 33001:1:0
vdvCodecP2	= 33001:2:0
vdvCodecP3	= 33001:3:0
vdvCodecP4	= 33001:4:0
vdvCodecP5	= 33001:5:0
vdvCodecP6	= 33001:6:0
vdvCodecP7	= 33001:7:0
vdvCodecP8	= 33001:8:0


vdvSystem1 	= 33050:1:1
vdvSystem2 	= 33050:1:2
vdvSystem3 	= 33050:1:3
vdvSystem4 	= 33050:1:4
vdvSystem5 	= 33050:1:5
vdvSystem6 	= 33050:1:6
vdvSystem7 	= 33050:1:7
vdvSystem8 	= 33050:1:8
vdvSystem9 	= 33050:1:9
vdvSystem10 	= 33050:1:10

vdvSystem11 	= 33050:1:11
vdvSystem12 	= 33050:1:12
vdvSystem13	= 33050:1:13
vdvSystem14 	= 33050:1:14
vdvSystem15 	= 33050:1:15
vdvSystem16 	= 33050:1:16
vdvSystem17	= 33050:1:17
vdvSystem18 	= 33050:1:18
vdvSystem19 	= 33050:1:19
vdvSystem20	= 33050:1:20


//Virtual Rooms
vdvVSystem1	= 33055:1:1
vdvVSystem2	= 33055:1:2
vdvVSystem3	= 33055:1:3
vdvVSystem4	= 33055:1:4

//Lights
vdvLights1	= 33015:1:1
vdvLights2	= 33015:1:2
vdvLights3	= 33015:1:3
vdvLights4	= 33015:1:4
vdvLights5	= 33015:1:5
vdvLights6	= 33015:1:6
vdvLights7	= 33015:1:7
vdvLights8	= 33015:1:8
vdvLights9	= 33015:1:9
vdvLights10	= 33015:1:10
vdvLights11	= 33015:1:11
vdvLights12	= 33015:1:12
vdvLights13	= 33015:1:13
vdvLights14	= 33015:1:14
vdvLights15	= 33015:1:15
vdvLights16	= 33015:1:16
vdvLights17	= 33015:1:17
vdvLights18	= 33015:1:18
vdvLights19	= 33015:1:19
vdvLights20	= 33015:1:20




//Create Device Arrays to allow devices to referenced easily
DEFINE_VARIABLE

volatile dev vdvCodecP[] = {

    vdvCodecP1,	
    vdvCodecP2,	
    vdvCodecP3,	
    vdvCodecP4,	
    vdvCodecP5,	
    vdvCodecP6,	
    vdvCodecP7,	
    vdvCodecP8

}

volatile dev vdvVSystems[] = {

    vdvVSystem1,
    vdvVSystem2,
    vdvVSystem3,
    vdvVSystem4	
}

volatile dev vdvCodecFar[] = {

    vdvCodecFar1,
    vdvCodecFar2,
    vdvCodecFar3,
    vdvCodecFar4,
    vdvCodecFar5,
    vdvCodecFar6,
    vdvCodecFar7,
    vdvCodecFar8,
    vdvCodecFar9,
    vdvCodecFar10,
    vdvCodecFar11,
    vdvCodecFar12,
    vdvCodecFar13,
    vdvCodecFar14,
    vdvCodecFar15,
    vdvCodecFar16,
    vdvCodecFar17,
    vdvCodecFar18,
    vdvCodecFar19,
    vdvCodecFar20
}

volatile dev vdvCodecs[] = {

    vdvCodec1,
    vdvCodec2,
    vdvCodec3,
    vdvCodec4,
    vdvCodec5,
    vdvCodec6,
    vdvCodec7,
    vdvCodec8,
    vdvCodec9,
    vdvCodec10,
    
    vdvCodec11,
    vdvCodec12,
    vdvCodec13,
    vdvCodec14,
    vdvCodec15,
    vdvCodec16,
    vdvCodec17,
    vdvCodec18,
    vdvCodec19,
    vdvCodec20
} 

volatile dev vdvCodecs_Cam2[] = {

    vdvCodec1_Cam2,
    vdvCodec2_Cam2,
    vdvCodec3_Cam2,
    vdvCodec4_Cam2,
    vdvCodec5_Cam2,
    vdvCodec6_Cam2,
    vdvCodec7_Cam2,
    vdvCodec8_Cam2,
    vdvCodec9_Cam2,
    vdvCodec10_Cam2,
    
    vdvCodec11_Cam2,
    vdvCodec12_Cam2,
    vdvCodec13_Cam2,
    vdvCodec14_Cam2,
    vdvCodec15_Cam2,
    vdvCodec16_Cam2,
    vdvCodec17_Cam2,
    vdvCodec18_Cam2,
    vdvCodec19_Cam2,
    vdvCodec20_Cam2
} 



volatile dev vdvSystems[] = {

    vdvSystem1, 	
    vdvSystem2, 	
    vdvSystem3, 	
    vdvSystem4, 	
    vdvSystem5, 	
    vdvSystem6, 	
    vdvSystem7, 	
    vdvSystem8, 
    vdvSystem9, 	
    vdvSystem10, 	
    
    vdvSystem11,	
    vdvSystem12,	
    vdvSystem13,
    vdvSystem14, 	
    vdvSystem15, 	
    vdvSystem16, 	
    vdvSystem17,	
    vdvSystem18, 	
    vdvSystem19, 	
    vdvSystem20
} 

VOLATILE dev vdvLights[] = {

    //Lights
    vdvLights1,
    vdvLights2,
    vdvLights3,
    vdvLights4,
    vdvLights5,
    vdvLights6,
    vdvLights7,
    vdvLights8,
    vdvLights9,
    vdvLights10,
    vdvLights11,
    vdvLights12,
    vdvLights13,
    vdvLights14,
    vdvLights15,
    vdvLights16,
    vdvLights17,
    vdvLights18,
    vdvLights19,
    vdvLights20	

}

