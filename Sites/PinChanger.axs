PROGRAM_NAME='PinChanger'

DEFINE_DEVICE

dvIP		= 0:3:0
vdvSystem 	= 33050:1:0

#INCLUDE 'Utilities.axi'

DEFINE_CONSTANT

MAX_XML_MEMORY = 5120

DEFINE_VARIABLE
/////////////////////////////////////////////////////////////

VOLATILE char sWebsiteIP[255] = '10.100.16.41/amx';
VOLATILE INTEGER nHttpPort = 80
VOLATILE char sBuffer[MAX_XML_MEMORY]
VOLATILE INTEGER APP_ID

VOLATILE CHAR S_GET[255]

VOLATILE CHAR sSYSTEM_PIN[4]

VOLATILE INTEGER PIN_COMMS

define_function fnOpenConnection()
{    
    ip_client_open(dvIP.port,sWebsiteIP,nHttpPort,1) 
} 


define_function fnCloseConnection()
{
    ip_client_close(dvIP.PORT)
}


DEFINE_FUNCTION char[255] getHost(char url[255])
{
    STACK_VAR char Result[255]
    STACK_VAR char sUrl[255]
    
    sUrl = url
    
    //Remove '<protocol>://'
    If ( FIND_STRING ( sUrl, '//', 1 ) )
    {
	REMOVE_STRING ( sUrl, '//', 1 ) 
    }

    //Remove '<host>/'
    If (find_string ( sUrl, '/', 1  ) )
    {
	result = REMOVE_STRING ( sUrl, '/', 1 )
	result = SET_LENGTH_STRING ( result, ( LENGTH_STRING ( result ) - 1 ) )  
    }
    ELSE
    {
	result = sUrl
    }
    return result
}

DEFINE_EVENT

DATA_EVENT [vdvSystem]
{
    ONLINE:
    {
	STACK_VAR CHAR svPin[5]
	
	S_GET = "'amx/?GetPin=true'"
	
	fnOpenConnection()
    }
    
    COMMAND:
    {
	#INCLUDE 'EventCommandParser.axi'
	
	//Set the data for the responding system
	if ( FIND_STRING ( DATA.TEXT, 'SET_PIN-', 1 ))
	{
	    STACK_VAR CHAR pin[4]
	    
	    pin = GetAttrValue('pin', aCommand )
	    
	    S_GET = "'amx/?SetPin=',pin" 
	    
	    fnOpenConnection()
	}
	
	//Return system pin
	if ( FIND_STRING ( DATA.TEXT, 'GET_PIN-', 1 ) )
	{
	    S_GET = "'amx/?GetPin=true'"
	    
	    fnOpenConnection()
	}
    }
}

//DATA_EVENT___________________________________________________________________
data_event[dvIP]
{
	ONERROR:
	{
	    STACK_VAR Char Error[64]
	    
	    SWITCH ( DATA.NUMBER )
	    {
		CASE 2: Error =  "'2: General failure (out of memory)'"
		CASE 4: Error =  "'4: Unknown host'"
		CASE 6: Error =  "'6: Connection refused'"
		CASE 7: Error =  "'7: Connection timed out'"
		CASE 8: Error =  "'8: Unknown connection error'"
		CASE 9: Error =  "'9: Already closed'"
		CASE 14: Error =  "'14: Local port already used'"
		CASE 16: Error =  "'16: Too many open sockets'"
		CASE 17: Error =  "'17: Local Port Not Open'"
	    }
	    
	    //SEND_STRING 0, "'Connection Error: ',Error"
	}
	
	online:
	{
		send_string data.device, "'GET /',S_GET,' HTTP/1.1',13,10,
				 'Content-Type: text/html',13,10,
				 'Host: ',getHost(sWebsiteIP),13,10,
				 'Connection: Close',13,10,
				 13,10"
		/*send_string 0, "'GET /',S_GET,' HTTP/1.1',13,10,
				 'Content-Type: text/html',13,10,
				 'Host: ',getHost(sWebsiteIP),13,10,
				 'Connection: Close',13,10,
				 13,10"*/
				 
		ON[PIN_COMMS]
	}
	offline:
	{  
	    if ( FIND_STRING ( sBuffer, 'Current Pin:', 1 ) )
	    {
		REMOVE_STRING ( sBuffer, '<div>Current Pin: ', 1 )
		
		sSYSTEM_PIN = sBuffer
		
		//SEND_STRING 0, "'Pin Found!', SYSTEM_PIN"
	    }
	    
	    CLEAR_BUFFER sBuffer
	    
	    OFF[PIN_COMMS]
	}
}

DEFINE_START

create_buffer dvIP,sBuffer

DEFINE_PROGRAM

WAIT 300
{
    if ( !PIN_COMMS )
    {
	S_GET = "'amx/?GetPin=true'"
	
	fnOpenConnection()
    }
}