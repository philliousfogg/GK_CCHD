PROGRAM_NAME='MobileConnectionManager'

DEFINE_DEVICE 

DEFINE_CONSTANT

MAX_HTTP_MEMORY = 5120

DEFINE_VARIABLE

VOLATILE char MCM_WebsiteIP[255] = 'www.google.com';
VOLATILE INTEGER MCM_HttpPort = 80
VOLATILE char MCM_Buffer[MAX_HTTP_MEMORY]

VOLATILE CHAR MCM_GET[255]

define_function MCM_OpenConnection()
{    
    ip_client_open(INTERNET.port,MCM_WebsiteIP,MCM_HttpPort,1) 
} 

define_function MCM_CloseConnection()
{
    ip_client_close(INTERNET.PORT)
}


DEFINE_FUNCTION char[255] MCM_getHost(char url[255])
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

//DATA_EVENT___________________________________________________________________
data_event[INTERNET]
{
    online:
    {
	    send_string data.device, "'GET /',MCM_GET,' HTTP/1.1',13,10,
			     'Content-Type: text/html',13,10,
			     'Host: ',MCM_getHost(MCM_WebsiteIP),13,10,
			     'Connection: Close',13,10,
			     13,10"
    }
    offline:
    {  
	if ( FIND_STRING ( MCM_Buffer, 'HTTP/1.1 302 Found', 1 ) )
	{
	    ON [dvIO, 1]
	}
	
	CLEAR_BUFFER MCM_Buffer
    }
}

DEFINE_START

create_buffer INTERNET,MCM_Buffer

DEFINE_EVENT

CHANNEL_EVENT [vdvRMSEngine, 250]
{
    ON:
    {
	// If RMS Connection is live then we are connected to the internet and 
	// the gateway
	ON[dvIO, 1]
    }
    OFF:
    {
	OFF[dvIO, 1]
    }
}

DEFINE_PROGRAM

WAIT 200 {
    
    if ( ![ vdvRMSEngine, 250 ] )
    {
	// Check Internet Connection
	if ( ![dvIO, 1] )
	{
	    OFF[dvIO, 1] 
	    
	    SEND_COMMAND 0, 'Trying Internet Connection'
	    
	    MCM_OpenConnection()
	}
	
	//Check Gateway Connection
	else if ( 1 ) 
	{
	    SEND_COMMAND 0, 'Check RMS Server is online'
	}
    }
}

[dvIO, 2] = FLASH AND ![dvIO, 1]

