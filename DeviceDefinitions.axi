PROGRAM_NAME='DeviceDefinitions'

//Define all virtual and duet devices in the Estate
DEFINE_DEVICE

//Master
dvSystem 	= 0:1:0

//Physical Devices RS232
dvAmplifier 	= 5001:1:0

//Relay Ports
dvRelay		= 5001:4:0 //5001:4:0

//I/O Ports
dvIO_700	= 5001:4:0
dvIO_2100	= 5001:9:0
dvIO_3100	= 5001:17:0

//Ethernet Ports
dvVRMSSocket 	= 0:4:0

#IF_NOT_DEFINED dvRMSSocket

dvRMSSocket 	= 0:13:0

#END_IF

#IF_NOT_DEFINED dvCodec

dvCodec 	= 0:5:0

#END_IF

dvProjector1 	= 0:6:0
dvProjector2	= 0:7:0
dvProjector3	= 0:8:0

dvLights 	= 0:9:0

dvIP		= 0:10:0

INTERNET	= 0:20:0
GW1_COMMS	= 0:21:0
GW2_COMMS	= 0:22:0

vdvProjector1 	= 33011:1:0
vdvProjector2 	= 33012:1:0
vdvProjector3 	= 33013:1:0
vdvAmplifier 	= 33014:1:0
vdvLight	= 33015:1:0

vdvLog 		= 33051:1:0

//Define Virtual Devices
vdvSystem       = 33050:1:0
vdvVSystem	= 33055:1:0

#IF_NOT_DEFINED vdvRMSEngine 

vdvRMSEngine	= 33003:1:0
vdvCLActions	= 33004:1:0

vdvVRMSEngine	= 33005:1:0
vdvVCLActions	= 33006:1:0

// Lesson Virtual Device
vdvLesson	= 33006:1:0
vdvVLesson	= 33007:1:0

#END_IF

//User Interfaces
dvTP 		= 10001:1:0
dvTPCodec	= 10001:2:0
dvTPRMS		= 10001:3:0
dvTPLights 	= 10001:4:0
dvTPSettings	= 10001:5:0 //> v2 User Interface
dvTPUrl		= 10001:6:0 //> v2 User Interface

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

vdvCodec21 	= 33001:1:21
vdvCodec22 	= 33001:1:22
vdvCodec23 	= 33001:1:23
vdvCodec24 	= 33001:1:24
vdvCodec25 	= 33001:1:25
vdvCodec26 	= 33001:1:26
vdvCodec27 	= 33001:1:27
vdvCodec28 	= 33001:1:28
vdvCodec29 	= 33001:1:29
vdvCodec30 	= 33001:1:30

vdvCodec31 	= 33001:1:31
vdvCodec32 	= 33001:1:32
vdvCodec33 	= 33001:1:33
vdvCodec34 	= 33001:1:34
vdvCodec35 	= 33001:1:35
vdvCodec36 	= 33001:1:36
vdvCodec37 	= 33001:1:37
vdvCodec38 	= 33001:1:38
vdvCodec39 	= 33001:1:39
vdvCodec40 	= 33001:1:40

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

vdvCodec21_Cam2 = 33001:2:21
vdvCodec22_Cam2 = 33001:2:22
vdvCodec23_Cam2	= 33001:2:23
vdvCodec24_Cam2 = 33001:2:24
vdvCodec25_Cam2 = 33001:2:25
vdvCodec26_Cam2 = 33001:2:26
vdvCodec27_Cam2 = 33001:2:27
vdvCodec28_Cam2 = 33001:2:28
vdvCodec29_Cam2 = 33001:2:29
vdvCodec30_Cam2 = 33001:2:30

vdvCodec31_Cam2 = 33001:2:31
vdvCodec32_Cam2 = 33001:2:32
vdvCodec33_Cam2	= 33001:2:33
vdvCodec34_Cam2 = 33001:2:34
vdvCodec35_Cam2 = 33001:2:35
vdvCodec36_Cam2 = 33001:2:36
vdvCodec37_Cam2 = 33001:2:37
vdvCodec38_Cam2 = 33001:2:38
vdvCodec39_Cam2 = 33001:2:39
vdvCodec40_Cam2 = 33001:2:40


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

vdvCodecFar21	= 33001:8:21
vdvCodecFar22	= 33001:8:22
vdvCodecFar23	= 33001:8:23
vdvCodecFar24	= 33001:8:24
vdvCodecFar25	= 33001:8:25
vdvCodecFar26	= 33001:8:26
vdvCodecFar27	= 33001:8:27
vdvCodecFar28	= 33001:8:28
vdvCodecFar29	= 33001:8:29
vdvCodecFar30	= 33001:8:30

vdvCodecFar31	= 33001:8:31
vdvCodecFar32	= 33001:8:32
vdvCodecFar33	= 33001:8:33
vdvCodecFar34	= 33001:8:34
vdvCodecFar35	= 33001:8:35
vdvCodecFar36	= 33001:8:36
vdvCodecFar37	= 33001:8:37
vdvCodecFar38	= 33001:8:38
vdvCodecFar39	= 33001:8:39
vdvCodecFar40	= 33001:8:40


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

vdvSystem21 	= 33050:1:21
vdvSystem22 	= 33050:1:22
vdvSystem23	= 33050:1:23
vdvSystem24 	= 33050:1:24
vdvSystem25 	= 33050:1:25
vdvSystem26 	= 33050:1:26
vdvSystem27	= 33050:1:27
vdvSystem28 	= 33050:1:28
vdvSystem29 	= 33050:1:29
vdvSystem30	= 33050:1:30

vdvSystem31 	= 33050:1:31
vdvSystem32 	= 33050:1:32
vdvSystem33	= 33050:1:33
vdvSystem34 	= 33050:1:34
vdvSystem35 	= 33050:1:35
vdvSystem36 	= 33050:1:36
vdvSystem37	= 33050:1:37
vdvSystem38 	= 33050:1:38
vdvSystem39 	= 33050:1:39
vdvSystem40	= 33050:1:40

vdvSystem101	= 33050:1:101
vdvSystem102	= 33050:1:102

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

vdvLights21	= 33015:1:21
vdvLights22	= 33015:1:22
vdvLights23	= 33015:1:23
vdvLights24	= 33015:1:24
vdvLights25	= 33015:1:25
vdvLights26	= 33015:1:26
vdvLights27	= 33015:1:27
vdvLights28	= 33015:1:28
vdvLights29	= 33015:1:29
vdvLights30	= 33015:1:30
vdvLights31	= 33015:1:31
vdvLights32	= 33015:1:32
vdvLights33	= 33015:1:33
vdvLights34	= 33015:1:34
vdvLights35	= 33015:1:35
vdvLights36	= 33015:1:36
vdvLights37	= 33015:1:37
vdvLights38	= 33015:1:38
vdvLights39	= 33015:1:39
vdvLights40	= 33015:1:40



//Create Device Arrays to allow devices to referenced easily
DEFINE_VARIABLE

volatile dev dvIO = dvIO_2100

//VOLATILE dev dvRMSSocket = 0:3:0

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
    vdvCodecFar20,
    
    vdvCodecFar21,
    vdvCodecFar22,
    vdvCodecFar23,
    vdvCodecFar24,
    vdvCodecFar25,
    vdvCodecFar26,
    vdvCodecFar27,
    vdvCodecFar28,
    vdvCodecFar29,
    vdvCodecFar30,
    
    vdvCodecFar31,
    vdvCodecFar32,
    vdvCodecFar33,
    vdvCodecFar34,
    vdvCodecFar35,
    vdvCodecFar36,
    vdvCodecFar37,
    vdvCodecFar38,
    vdvCodecFar39,
    vdvCodecFar40
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
    vdvCodec20,
    
    vdvCodec21,
    vdvCodec22,
    vdvCodec23,
    vdvCodec24,
    vdvCodec25,
    vdvCodec26,
    vdvCodec27,
    vdvCodec28,
    vdvCodec29,
    vdvCodec30,
    
    vdvCodec31,
    vdvCodec32,
    vdvCodec33,
    vdvCodec34,
    vdvCodec35,
    vdvCodec36,
    vdvCodec37,
    vdvCodec38,
    vdvCodec39,
    vdvCodec40
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
    vdvCodec20_Cam2,
    
    vdvCodec21_Cam2,
    vdvCodec22_Cam2,
    vdvCodec23_Cam2,
    vdvCodec24_Cam2,
    vdvCodec25_Cam2,
    vdvCodec26_Cam2,
    vdvCodec27_Cam2,
    vdvCodec28_Cam2,
    vdvCodec29_Cam2,
    vdvCodec30_Cam2,
    
    vdvCodec31_Cam2,
    vdvCodec32_Cam2,
    vdvCodec33_Cam2,
    vdvCodec34_Cam2,
    vdvCodec35_Cam2,
    vdvCodec36_Cam2,
    vdvCodec37_Cam2,
    vdvCodec38_Cam2,
    vdvCodec39_Cam2,
    vdvCodec40_Cam2
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
    vdvSystem20,
    
    vdvSystem21, 	
    vdvSystem22, 	
    vdvSystem23, 	
    vdvSystem24, 	
    vdvSystem25, 	
    vdvSystem26, 	
    vdvSystem27, 	
    vdvSystem28, 
    vdvSystem29, 	
    vdvSystem30, 	
    
    vdvSystem31,	
    vdvSystem32,	
    vdvSystem33,
    vdvSystem34, 	
    vdvSystem35, 	
    vdvSystem36, 	
    vdvSystem37,	
    vdvSystem38, 	
    vdvSystem39, 	
    vdvSystem40,
    
    vdvSystem101,
    vdvSystem102
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
    vdvLights20,

    vdvLights21,
    vdvLights22,
    vdvLights23,
    vdvLights24,
    vdvLights25,
    vdvLights26,
    vdvLights27,
    vdvLights28,
    vdvLights29,
    vdvLights30,
    vdvLights31,
    vdvLights32,
    vdvLights33,
    vdvLights34,
    vdvLights35,
    vdvLights36,
    vdvLights37,
    vdvLights38,
    vdvLights39,
    vdvLights40	    

}

