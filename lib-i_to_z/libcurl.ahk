CurlGlobalInit( Location = "", flags = 3 )
{
	global hCurlModule := DllCall( "LoadLibrary", "str", Location = "" ? "libcurl.dll" : (Location . ".dll") )
	if ( !hCurlModule || ErrorLevel )
		return -1

	global CurlDllName
	if ( Location = "" )
		CurlDllName = libcurl
	else
	{
		StringGetPos, Pos, Location, \, R ; Find the last slash.
		if ( ErrorLevel )
			CurlDllName := Location ; No path specified.
		else
			CurlDllName := SubStr( Location, Pos + 2 )
	}

	; #define CURL_GLOBAL_SSL (1<<0)
	; #define CURL_GLOBAL_WIN32 (1<<1)
	; #define CURL_GLOBAL_ALL (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32)
	; #define CURL_GLOBAL_NOTHING 0
	; #define CURL_GLOBAL_DEFAULT CURL_GLOBAL_ALL
	global CurlShowErrors
	code := DllCall( "libcurl\curl_global_init", "UInt", flags )
	if ( code != 0 && CurlShowErrors )
		MsgBox, 16, Error, % "curl_global_init: " CurlEasyStrError( code ) ;%
	return code
}


CurlFreeLibrary()
{
	global hCurlModule
	return DllCall( "FreeLibrary", "UInt", hCurlModule )
}


CurlEasyInit()
{
	global CurlDllName
	return DllCall( CurlDllName "\curl_easy_init" )
}


CurlEasyReset( EasyHandle )
{
	global CurlDllName
	DllCall( CurlDllName "\curl_easy_reset", "UInt", EasyHandle )
}


CurlEasyCleanup( EasyHandle )
{
	global CurlDllName
	DllCall( CurlDllName "\curl_easy_cleanup", "UInt", EasyHandle )
}


CurlShowErrors( Yes = true )
{
	global CurlShowErrors := Yes
}


CurlEasySetOption( EasyHandle, Option, Parameter )
{
	global CurlDllName
	; For a list of options, go to http://curl.haxx.se/libcurl/c/curl_easy_setopt.html
	If Parameter is integer
		return DllCall( CurlDllName "\curl_easy_setopt", "UInt", EasyHandle, "UInt", Option, "UInt", Parameter, "Cdecl" )
	else
		return DllCall( CurlDllName "\curl_easy_setopt", "UInt", EasyHandle, "UInt", Option, "UInt", &Parameter, "Cdecl" )
}


CurlSlistAppend( ByRef pSlist, String )
{
	if ( pSlist = "" )
		pSlist = 0

	global CurlDllName
	pSlist := DllCall( CurlDllName "\curl_slist_append", "UInt", pSlist, "UInt", &String, "Cdecl" )
	return pSlist
}


CurlSlistFreeAll( ByRef pSlist )
{
	global CurlDllName
	DllCall( CurlDllName "\curl_slist_free_all", "UInt", pSlist, "Cdecl" )
	pSlist = 0
}


CurlFormAdd( ByRef pFirstItem, ByRef pLastItem, Option1, Value1, Option2, Value2 = 0, Option3 = 0, Value3 = 0, Option4 = 0, Value4 = 0, Option5 = 0, Value5 = 0, Option6 = 0, Value6 = 0, Option7 = 0, Value7 = 0, Option8 = 0, Value8 = 0 )
{
	if ( pFirstItem = 0 || pLastItem = 0 )
	{
		VarSetCapacity( pFirstItem, 4, 0 )
		VarSetCapacity( pLastItem, 4, 0 )
	}
	Loop, 8
	{
		if Value%A_Index% is not integer
		{
			; Convert strings to string pointers.
			Value%A_Index%String := Value%A_Index%
			Value%A_Index% := &Value%A_Index%String
		}
	}
	global CurlDllName
	;global CurlShowErrors
	; No need to omit empty variables here. It is unaware of all parameters after CURLFORM_END.
	RetVal := DllCall( CurlDllName "\curl_formadd", "UInt", &pFirstItem, "UInt", &pLastItem, "UInt", Option1, "UInt", Value1, "UInt", Option2, "UInt", Value2, "UInt", Option3, "UInt", Value3, "UInt", Option4, "UInt", Value4, "UInt", Option5, "UInt", Value5, "UInt", Option6, "UInt", Value6, "UInt", Option7, "UInt", Value7, "UInt", Option8, "UInt", Value8, "Cdecl" )
;	if ( ErrorLevel && CurlShowErrors )
;		MsgBox, 16, Error, %CurlDllName%\curl_formadd() failed with error level %ErrorLevel%.
		
	return RetVal
}


CurlFormFree( pFirstItem )
{
	global CurlDllName
	DllCall( CurlDllName "\curl_formfree", "UInt", pFirstItem, "Cdecl" )
}


CurlEasyPerform( EasyHandle )
{
	global CurlDllName
	return DllCall( CurlDllName "\curl_easy_perform", "UInt", EasyHandle, "Cdecl" )
}


CurlEasyGetinfo( EasyHandle, Information )
{
	global ; May be unneeded now. I used to use the CURLINFO variables directly.
	local Type := CurlGetInfoType( Information )
	
	local Value
	; Everything but double is 4 bytes.
	VarSetCapacity( Value, Type = 0x300000 ? 8 : 4 ) ; CURLINFO_DOUBLE

	local Error := DllCall( CurlDllName "\curl_easy_getinfo", "UInt", EasyHandle, "UInt", Information, "UInt", &Value, "Cdecl" )
	if ( ErrorLevel )
		return ""

	if ( Error != 0 )
	{
		if ( CurlShowErrors )
			MsgBox, 16, Error, % "curl_easy_getinfo: " CurlEasyStrError( Error ) ;%
		return ""
	}

	
	if ( Information < 0x200000 ) ; CURLINFO_LONG
		return DllCall( "MulDiv", "Int", NumGet( Value ), "Int", 1, "Int", 1, "Str" ) ; STRING
	else
	{
		if ( Information < 0x300000 ) ; CURLINFO_DOUBLE
			return NumGet( Value ) ; LONG
		else
		{
			if ( Information < 0x400000 ) ; CURLINFO_SLIST
				return NumGet( Value, 0, "Double" ) ; DOUBLE
			else
				return NumGet( Value ) ; SLIST
		}
	}
}


CurlEasyStrError( ErrorCode )
{
	global CurlDllName
	return DllCall( CurlDllName "\curl_easy_strerror", "UInt", ErrorCode, "Cdecl Str" )
}


CurlEasyEscape( EasyHandle, URL )
{
	global CurlDllName
	return CurlFreeGet( DllCall( CurlDllName "\curl_easy_escape", "UInt", EasyHandle, "Str", URL, "UInt", 0, "Cdecl" ) )
	; "If the length argument is set to 0 (zero), curl_easy_escape() uses strlen() on the input url to find out the size."
}


CurlEasyUnescape( EasyHandle, URL )
{
	global CurlDllName
	return CurlFreeGet( DllCall( CurlDllName "\curl_easy_unescape", "UInt", EasyHandle, "Str", URL, "UInt", 0, "UInt", 0, "Cdecl" ) )
}


CurlVersion()
{
	global CurlDllName
	; lol?
;	Return DllCall( "MulDiv", "Int", DllCall( CurlDllName "\curl_version" ), "Int",1, "Int",1, "str" ) 
	Return DllCall( CurlDllName "\curl_version", "Str" )
}


; If the manual says a function must "must curl_free() the returned string when you're done with it,"
; set the call to return as a pointer instead of a string, then wrap this function around it.
CurlFreeGet( pString )
{
	; AHK needz a string dereferencing operator. Why do I have to trick it with a dllcall?
	LocalCopy := DllCall( "MulDiv", "Int", pString, "Int", 1, "Int", 1, "Str" )
	global CurlDllName
	DllCall( CurlDllName "\curl_free", "UInt", pString, Cdecl )
	return LocalCopy
}


MergeDouble( l, h )
{
	VarSetCapacity( Value, 8, 0 )
	NumPut( l, Value, 0 ), NumPut( h, Value, 4 )
	return NumGet( Value, 0, "Double" )
}


CurlGetInfoType( Information )
{
	if ( Information < 0x200000 ) ; CURLINFO_LONG
		return 0x100000 ; CURLINFO_STRING
	else
	{
		if ( Information < 0x300000 ) ; CURLINFO_DOUBLE
			return 0x200000 ; CURLINFO_LONG
		else
		{
			if ( Information < 0x400000 ) ; CURLINFO_SLIST
				return 0x300000 ; CURLINFO_DOUBLE
			else
				return 0x400000 ; CURLINFO_SLIST
		}
	}
}


CurlGetInfoDefine( All = true )
{
	global

	CURLINFO_STRING   := 0x100000
	CURLINFO_LONG     := 0x200000
	CURLINFO_DOUBLE   := 0x300000
	CURLINFO_SLIST    := 0x400000

	if ( !All )
		return

	CURLINFO_EFFECTIVE_URL           = 1048577 ; CURLINFO_STRING + 1
	CURLINFO_RESPONSE_CODE           = 2097154 ; CURLINFO_LONG   + 2
	CURLINFO_TOTAL_TIME              = 3145731 ; CURLINFO_DOUBLE + 3
	CURLINFO_NAMELOOKUP_TIME         = 3145732 ; CURLINFO_DOUBLE + 4
	CURLINFO_CONNECT_TIME            = 3145733 ; CURLINFO_DOUBLE + 5
	CURLINFO_PRETRANSFER_TIME        = 3145734 ; CURLINFO_DOUBLE + 6
	CURLINFO_SIZE_UPLOAD             = 3145735 ; CURLINFO_DOUBLE + 7
	CURLINFO_SIZE_DOWNLOAD           = 3145736 ; CURLINFO_DOUBLE + 8
	CURLINFO_SPEED_DOWNLOAD          = 3145737 ; CURLINFO_DOUBLE + 9
	CURLINFO_SPEED_UPLOAD            = 3145738 ; CURLINFO_DOUBLE + 10
	CURLINFO_HEADER_SIZE             = 2097163 ; CURLINFO_LONG  + 11
	CURLINFO_REQUEST_SIZE            = 2097164 ; CURLINFO_LONG  + 12
	CURLINFO_SSL_VERIFYRESULT        = 2097165 ; CURLINFO_LONG  + 13
	CURLINFO_FILETIME                = 2097166 ; CURLINFO_LONG  + 14
	CURLINFO_CONTENT_LENGTH_DOWNLOAD = 3145743 ; CURLINFO_DOUBLE + 15
	CURLINFO_CONTENT_LENGTH_UPLOAD   = 3145744 ; CURLINFO_DOUBLE + 16
	CURLINFO_STARTTRANSFER_TIME      = 3145745 ; CURLINFO_DOUBLE + 17
	CURLINFO_CONTENT_TYPE            = 1048594 ; CURLINFO_STRING + 18
	CURLINFO_REDIRECT_TIME           = 3145747 ; CURLINFO_DOUBLE + 19
	CURLINFO_REDIRECT_COUNT          = 2097172 ; CURLINFO_LONG   + 20
	CURLINFO_PRIVATE                 = 1048597 ; CURLINFO_STRING + 21
	CURLINFO_HTTP_CONNECTCODE        = 2097174 ; CURLINFO_LONG   + 22
	CURLINFO_HTTPAUTH_AVAIL          = 2097175 ; CURLINFO_LONG   + 23
	CURLINFO_PROXYAUTH_AVAIL         = 2097176 ; CURLINFO_LONG   + 24
	CURLINFO_OS_ERRNO                = 2097177 ; CURLINFO_LONG   + 25
	CURLINFO_NUM_CONNECTS            = 2097178 ; CURLINFO_LONG   + 26
	CURLINFO_SSL_ENGINES             = 4194331 ; CURLINFO_SLIST  + 27
	CURLINFO_COOKIELIST              = 4194332 ; CURLINFO_SLIST  + 28
	CURLINFO_LASTSOCKET              = 2097181 ; CURLINFO_LONG   + 29
	CURLINFO_FTP_ENTRY_PATH          = 1048606 ; CURLINFO_STRING + 30
}


CurlEasyGetOptionType( Option )
{
	global
	if ( Option < 10000 ) ; CURLOPTTYPE_OBJECTPOINT
		return 0 ; CURLOPTTYPE_LONG
	else
	{
		if ( Option < 20000 ) ; CURLOPTTYPE_FUNCTIONPOINT
			return 10000 ; CURLOPTTYPE_OBJECTPOINT
		else
		{
			if ( Option < 30000 ) ; CURLOPTTYPE_OFF_T
				return 20000 ; CURLOPTTYPE_FUNCTIONPOINT
			else
				return 30000 ; CURLOPTTYPE_OFF_T
		}
	}
}


CurlEasyDefineOptions( All = true )
{
	global

	CURLOPTTYPE_LONG = 0
	CURLOPTTYPE_OBJECTPOINT = 10000
	CURLOPTTYPE_FUNCTIONPOINT = 20000
	CURLOPTTYPE_OFF_T = 30000
	
	CURL_ERROR_SIZE = 256

	if ( !All )
		return

	CURLFORM_COPYNAME       = 1
	CURLFORM_PTRNAME        = 2
	CURLFORM_NAMELENGTH     = 3
	CURLFORM_COPYCONTENTS   = 4
	CURLFORM_PTRCONTENTS    = 5
	CURLFORM_CONTENTSLENGTH = 6
	CURLFORM_FILECONTENT    = 7
	CURLFORM_ARRAY          = 8
	CURLFORM_FILE           = 10
	CURLFORM_BUFFER         = 11
	CURLFORM_BUFFERPTR      = 12
	CURLFORM_BUFFERLENGTH   = 13
	CURLFORM_CONTENTTYPE    = 14
	CURLFORM_CONTENTHEADER  = 15
	CURLFORM_FILENAME       = 16
	CURLFORM_END            = 17

	CURLOPT_FILE                       = 10001 ; 1   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_URL                        = 10002 ; 2   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_PORT                       = 3     ; 3   + CURLOPTTYPE_LONG
	CURLOPT_PROXY                      = 10004 ; 4   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_USERPWD                    = 10005 ; 5   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_PROXYUSERPWD               = 10006 ; 6   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_RANGE                      = 10007 ; 7   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_INFILE                     = 10009 ; 9   + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_ERRORBUFFER                = 10010 ; 10  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_WRITEFUNCTION              = 20011 ; 11  + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_READFUNCTION               = 20012 ; 12  + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_TIMEOUT                    = 13    ; 13  + CURLOPTTYPE_LONG
	CURLOPT_INFILESIZE                 = 14    ; 14  + CURLOPTTYPE_LONG
	CURLOPT_POSTFIELDS                 = 10015 ; 15  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_REFERER                    = 10016 ; 16  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_FTPPORT                    = 10017 ; 17  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_USERAGENT                  = 10018 ; 18  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_LOW_SPEED_LIMIT            = 19    ; 19  + CURLOPTTYPE_LONG
	CURLOPT_LOW_SPEED_TIME             = 20    ; 20  + CURLOPTTYPE_LONG
	CURLOPT_RESUME_FROM                = 21    ; 21  + CURLOPTTYPE_LONG
	CURLOPT_COOKIE                     = 10022 ; 22  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_HTTPHEADER                 = 10023 ; 23  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_HTTPPOST                   = 10024 ; 24  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLCERT                    = 10025 ; 25  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_KEYPASSWD                  = 10026 ; 26  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_CRLF                       = 27    ; 27  + CURLOPTTYPE_LONG
	CURLOPT_QUOTE                      = 10028 ; 28  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_WRITEHEADER                = 10029 ; 29  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_COOKIEFILE                 = 10031 ; 31  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLVERSION                 = 32    ; 32  + CURLOPTTYPE_LONG
	CURLOPT_TIMECONDITION              = 33    ; 33  + CURLOPTTYPE_LONG
	CURLOPT_TIMEVALUE                  = 34    ; 34  + CURLOPTTYPE_LONG
	CURLOPT_CUSTOMREQUEST              = 10036 ; 36  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_STDERR                     = 10037 ; 37  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_POSTQUOTE                  = 10039 ; 39  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_WRITEINFO                  = 10040 ; 40  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_VERBOSE                    = 41    ; 41  + CURLOPTTYPE_LONG
	CURLOPT_HEADER                     = 42    ; 42  + CURLOPTTYPE_LONG
	CURLOPT_NOPROGRESS                 = 43    ; 43  + CURLOPTTYPE_LONG
	CURLOPT_NOBODY                     = 44    ; 44  + CURLOPTTYPE_LONG
	CURLOPT_FAILONERROR                = 45    ; 45  + CURLOPTTYPE_LONG
	CURLOPT_UPLOAD                     = 46    ; 46  + CURLOPTTYPE_LONG
	CURLOPT_POST                       = 47    ; 47  + CURLOPTTYPE_LONG
	CURLOPT_DIRLISTONLY                = 48    ; 48  + CURLOPTTYPE_LONG
	CURLOPT_APPEND                     = 50    ; 50  + CURLOPTTYPE_LONG
	CURLOPT_NETRC                      = 51    ; 51  + CURLOPTTYPE_LONG
	CURLOPT_FOLLOWLOCATION             = 52    ; 52  + CURLOPTTYPE_LONG
	CURLOPT_TRANSFERTEXT               = 53    ; 53  + CURLOPTTYPE_LONG
	CURLOPT_PUT                        = 54    ; 54  + CURLOPTTYPE_LONG
	CURLOPT_PROGRESSFUNCTION           = 20056 ; 56  + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_PROGRESSDATA               = 10057 ; 57  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_AUTOREFERER                = 58    ; 58  + CURLOPTTYPE_LONG
	CURLOPT_PROXYPORT                  = 59    ; 59  + CURLOPTTYPE_LONG
	CURLOPT_POSTFIELDSIZE              = 60    ; 60  + CURLOPTTYPE_LONG
	CURLOPT_HTTPPROXYTUNNEL            = 61    ; 61  + CURLOPTTYPE_LONG
	CURLOPT_INTERFACE                  = 10062 ; 62  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_KRBLEVEL                   = 10063 ; 63  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSL_VERIFYPEER             = 64    ; 64  + CURLOPTTYPE_LONG
	CURLOPT_CAINFO                     = 10065 ; 65  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_MAXREDIRS                  = 68    ; 68  + CURLOPTTYPE_LONG
	CURLOPT_FILETIME                   = 69    ; 69  + CURLOPTTYPE_LONG
	CURLOPT_TELNETOPTIONS              = 10070 ; 70  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_MAXCONNECTS                = 71    ; 71  + CURLOPTTYPE_LONG
	CURLOPT_CLOSEPOLICY                = 72    ; 72  + CURLOPTTYPE_LONG
	CURLOPT_FRESH_CONNECT              = 74    ; 74  + CURLOPTTYPE_LONG
	CURLOPT_FORBID_REUSE               = 75    ; 75  + CURLOPTTYPE_LONG
	CURLOPT_RANDOM_FILE                = 10076 ; 76  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_EGDSOCKET                  = 10077 ; 77  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_CONNECTTIMEOUT             = 78    ; 78  + CURLOPTTYPE_LONG
	CURLOPT_HEADERFUNCTION             = 20079 ; 79  + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_HTTPGET                    = 80    ; 80  + CURLOPTTYPE_LONG
	CURLOPT_SSL_VERIFYHOST             = 81    ; 81  + CURLOPTTYPE_LONG
	CURLOPT_COOKIEJAR                  = 10082 ; 82  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSL_CIPHER_LIST            = 10083 ; 83  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_HTTP_VERSION               = 84    ; 84  + CURLOPTTYPE_LONG
	CURLOPT_FTP_USE_EPSV               = 85    ; 85  + CURLOPTTYPE_LONG
	CURLOPT_SSLCERTTYPE                = 10086 ; 86  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLKEY                     = 10087 ; 87  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLKEYTYPE                 = 10088 ; 88  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLENGINE                  = 10089 ; 89  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSLENGINE_DEFAULT          = 90    ; 90  + CURLOPTTYPE_LONG
	CURLOPT_DNS_USE_GLOBAL_CACHE       = 91    ; 91  + CURLOPTTYPE_LONG
	CURLOPT_DNS_CACHE_TIMEOUT          = 92    ; 92  + CURLOPTTYPE_LONG
	CURLOPT_PREQUOTE                   = 10093 ; 93  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_DEBUGFUNCTION              = 20094 ; 94  + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_DEBUGDATA                  = 10095 ; 95  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_COOKIESESSION              = 96    ; 96  + CURLOPTTYPE_LONG
	CURLOPT_CAPATH                     = 10097 ; 97  + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_BUFFERSIZE                 = 98    ; 98  + CURLOPTTYPE_LONG
	CURLOPT_NOSIGNAL                   = 99    ; 99  + CURLOPTTYPE_LONG
	CURLOPT_SHARE                      = 10100 ; 100 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_PROXYTYPE                  = 101   ; 101 + CURLOPTTYPE_LONG
	CURLOPT_ENCODING                   = 10102 ; 102 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_PRIVATE                    = 10103 ; 103 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_HTTP200ALIASES             = 10104 ; 104 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_UNRESTRICTED_AUTH          = 105   ; 105 + CURLOPTTYPE_LONG
	CURLOPT_FTP_USE_EPRT               = 106   ; 106 + CURLOPTTYPE_LONG
	CURLOPT_HTTPAUTH                   = 107   ; 107 + CURLOPTTYPE_LONG
	CURLOPT_SSL_CTX_FUNCTION           = 20108 ; 108 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_SSL_CTX_DATA               = 10109 ; 109 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_FTP_CREATE_MISSING_DIRS    = 110   ; 110 + CURLOPTTYPE_LONG
	CURLOPT_PROXYAUTH                  = 111   ; 111 + CURLOPTTYPE_LONG
	CURLOPT_FTP_RESPONSE_TIMEOUT       = 112   ; 112 + CURLOPTTYPE_LONG
	CURLOPT_IPRESOLVE                  = 113   ; 113 + CURLOPTTYPE_LONG
	CURLOPT_MAXFILESIZE                = 114   ; 114 + CURLOPTTYPE_LONG
	CURLOPT_INFILESIZE_LARGE           = 30115 ; 115 + CURLOPTTYPE_OFF_T
	CURLOPT_RESUME_FROM_LARGE          = 30116 ; 116 + CURLOPTTYPE_OFF_T
	CURLOPT_MAXFILESIZE_LARGE          = 30117 ; 117 + CURLOPTTYPE_OFF_T
	CURLOPT_NETRC_FILE                 = 10118 ; 118 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_USE_SSL                    = 119   ; 119 + CURLOPTTYPE_LONG
	CURLOPT_POSTFIELDSIZE_LARGE        = 30120 ; 120 + CURLOPTTYPE_OFF_T
	CURLOPT_TCP_NODELAY                = 121   ; 121 + CURLOPTTYPE_LONG
	CURLOPT_FTPSSLAUTH                 = 129   ; 129 + CURLOPTTYPE_LONG
	CURLOPT_IOCTLFUNCTION              = 20130 ; 130 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_IOCTLDATA                  = 10131 ; 131 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_FTP_ACCOUNT                = 10134 ; 134 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_COOKIELIST                 = 10135 ; 135 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_IGNORE_CONTENT_LENGTH      = 136   ; 136 + CURLOPTTYPE_LONG
	CURLOPT_FTP_SKIP_PASV_IP           = 137   ; 137 + CURLOPTTYPE_LONG
	CURLOPT_FTP_FILEMETHOD             = 138   ; 138 + CURLOPTTYPE_LONG
	CURLOPT_LOCALPORT                  = 139   ; 139 + CURLOPTTYPE_LONG
	CURLOPT_LOCALPORTRANGE             = 140   ; 140 + CURLOPTTYPE_LONG
	CURLOPT_CONNECT_ONLY               = 141   ; 141 + CURLOPTTYPE_LONG
	CURLOPT_CONV_FROM_NETWORK_FUNCTION = 20142 ; 142 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_CONV_TO_NETWORK_FUNCTION   = 20143 ; 143 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_CONV_FROM_UTF8_FUNCTION    = 20144 ; 144 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_MAX_SEND_SPEED_LARGE       = 30145 ; 145 + CURLOPTTYPE_OFF_T
	CURLOPT_MAX_RECV_SPEED_LARGE       = 30146 ; 146 + CURLOPTTYPE_OFF_T
	CURLOPT_FTP_ALTERNATIVE_TO_USER    = 10147 ; 147 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SOCKOPTFUNCTION            = 20148 ; 148 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_SOCKOPTDATA                = 10149 ; 149 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSL_SESSIONID_CACHE        = 150   ; 150 + CURLOPTTYPE_LONG
	CURLOPT_SSH_AUTH_TYPES             = 151   ; 151 + CURLOPTTYPE_LONG
	CURLOPT_SSH_PUBLIC_KEYFILE         = 10152 ; 152 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_SSH_PRIVATE_KEYFILE        = 10153 ; 153 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_FTP_SSL_CCC                = 154   ; 154 + CURLOPTTYPE_LONG
	CURLOPT_TIMEOUT_MS                 = 155   ; 155 + CURLOPTTYPE_LONG
	CURLOPT_CONNECTTIMEOUT_MS          = 156   ; 156 + CURLOPTTYPE_LONG
	CURLOPT_HTTP_TRANSFER_DECODING     = 157   ; 157 + CURLOPTTYPE_LONG
	CURLOPT_HTTP_CONTENT_DECODING      = 158   ; 158 + CURLOPTTYPE_LONG
	CURLOPT_NEW_FILE_PERMS             = 159   ; 159 + CURLOPTTYPE_LONG
	CURLOPT_NEW_DIRECTORY_PERMS        = 160   ; 160 + CURLOPTTYPE_LONG
	CURLOPT_POST301                    = 161   ; 161 + CURLOPTTYPE_LONG
	CURLOPT_SSH_HOST_PUBLIC_KEY_MD5    = 10162 ; 162 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_OPENSOCKETFUNCTION         = 20163 ; 163 + CURLOPTTYPE_FUNCTIONPOINT
	CURLOPT_OPENSOCKETDATA             = 10164 ; 164 + CURLOPTTYPE_OBJECTPOINT
	CURLOPT_COPYPOSTFIELDS             = 10165 ; 165 + CURLOPTTYPE_OBJECTPOINT
	; YEA, WUT NAO?
}