; ==========
; Origional FTP Functions by Olfen & Andreone
; See the following post:
; http://www.autohotkey.com/forum/viewtopic.php?t=10393
; ==========
; WININET_UrlGetContents() is based on heresy & DerRaphael's script here:
; http://www.autohotkey.com/forum/viewtopic.php?t=33506
; ==========
; by ahklerner
; ==========


WININET_Init(){
	global
	WININET_hModule := DllCall("LoadLibrary", "Str", "WinInet.Dll")
}

WININET_UnInit(){
	global
	DllCall("FreeLibrary", "UInt", WININET_hModule)
}

WININET_InternetOpenA(lpszAgent,dwAccessType=1,lpszProxyName=0,lpszProxyBypass=0,dwFlags=0){
	;http://msdn.microsoft.com/en-us/library/aa385096(VS.85).aspx
	return DllCall("WinINet\InternetOpenA"
				, "Str"		,lpszAgent
				, "UInt"	,dwAccessType
				, "Str"		,lpszProxyName
				, "Str"		,lpszProxyBypass
				, "Uint"	,dwFlags )
}

WININET_InternetConnectA(hInternet,lpszServerName,nServerPort=80,lpszUsername=""
					,lpszPassword="",dwService=3,dwFlags=0,dwContext=0){
	;http://msdn.microsoft.com/en-us/library/aa384363(VS.85).aspx
	; INTERNET_SERVICE_FTP = 1
	; INTERNET_SERVICE_HTTP = 3
	return DllCall("WinINet\InternetConnectA"
				, "uInt"	,hInternet
				, "Str"		,lpszServerName
				, "Int"		,nServerPort
				, "Str"		,lpszUsername
				, "Str"		,lpszPassword
				, "uInt"	,dwService
				, "uInt"	,dwFlags
				, "uInt*"	,dwContext )
}

WININET_HttpOpenRequestA(hConnect,lpszVerb,lpszObjectName,lpszVersion="HTTP/1.1"
				,lpszReferer="",lplpszAcceptTypes="",dwFlags=0,dwContext=0){
	;http://msdn.microsoft.com/en-us/library/aa384233(VS.85).aspx
	return DllCall("WinINet\HttpOpenRequestA"
				, "uInt"	,hConnect
				, "Str"		,lpszVerb
				, "Str"		,lpszObjectName
				, "Str"		,lpszVersion
				, "Str"		,lpszReferer
				, "Str"		,lplpszAcceptTypes
				, "uInt"	,dwFlags
				, "uInt"	,dwContext )
}

WININET_HttpSendRequestA(hRequest,lpszHeaders="",lpOptional=""){
	;http://msdn.microsoft.com/en-us/library/aa384247(VS.85).aspx
	return DllCall("WinINet\HttpSendRequestA"
				, "uInt"	,hRequest
				, "Str"		,lpszHeaders
				, "uInt"	,Strlen(lpszHeaders)
				, "Str"		,lpOptional
				, "uInt"	,Strlen(lpOptional) )
}

WININET_InternetReadFile(hFile){
	;http://msdn.microsoft.com/en-us/library/aa385103(VS.85).aspx
	dwNumberOfBytesToRead := 1024**2
	VarSetCapacity(lpBuffer,dwNumberOfBytesToRead,0)
	VarSetCapacity(lpdwNumberOfBytesRead,4,0)
	Loop {
		if DllCall("wininet\InternetReadFile","uInt",hFile,"uInt",&lpBuffer
				,"uInt",dwNumberOfBytesToRead,"uInt",&lpdwNumberOfBytesRead ) {
			VarSetCapacity(lpBuffer,-1)
			TotalBytesRead := 0
			Loop, 4
				TotalBytesRead += *(&lpdwNumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
			If !TotalBytesRead
				break
			Else
				Result .= SubStr(lpBuffer,1,TotalBytesRead)
		}
	}
	return Result
}


WININET_FtpCreateDirectoryA(hConnect,lpszDirectory) {
   ;http://msdn.microsoft.com/en-us/library/aa384136(VS.85).aspx
   r := DllCall("wininet\FtpCreateDirectoryA", "uint", hConnect, "str", lpszDirectory)
   If (ErrorLevel or !r)
      Return 0
   else
      Return 1
   }


WININET_FtpRemoveDirectoryA(hConnect,lpszDirectory) {
   ;http://msdn.microsoft.com/en-us/library/aa384172(VS.85).aspx
   r := DllCall("wininet\FtpRemoveDirectoryA", "uint", hConnect, "str", lpszDirectory)
   If (ErrorLevel or !r)
      Return 0
   else
      Return 1
   }

WININET_FtpSetCurrentDirectoryA(hConnect,lpszDirectory) {
   ;http://msdn.microsoft.com/en-us/library/aa384178(VS.85).aspx
   r := DllCall("wininet\FtpSetCurrentDirectoryA", "uint", hConnect, "str", lpszDirectory)
   If (ErrorLevel or !r)
      Return 0
   else
      Return 1
   }

WININET_FtpPutFileA(hConnect,lpszLocalFile, lpszNewRemoteFile="", dwFlags=0,dwContext=0) {
	;http://msdn.microsoft.com/en-us/library/aa384170(VS.85).aspx
	If lpszNewRemoteFile =
		lpszNewRemoteFile := lpszLocalFile
	r := DllCall("wininet\FtpPutFileA"
			, "uint"	, hConnect
			, "str"		, lpszLocalFile
			, "str"		, lpszNewRemoteFile
			, "uint"	, dwFlags
			, "uint"	, dwContext )
	If (ErrorLevel or !r)
		Return 0
	else
		Return 1
	}

WININET_FtpGetFileA(hConnect,lpszRemoteFile, lpszNewFile="", fFailIfExists=1
				,dwFlagsAndAttributes=0,dwFlags=0,dwContext=0) {
	;http://msdn.microsoft.com/en-us/library/aa384157(VS.85).aspx
	If lpszNewFile=
		lpszNewFile := lpszRemoteFile
	r := DllCall("wininet\FtpGetFileA"
			, "uint"	, hConnect
			, "str"		, lpszRemoteFile
			, "str"		, lpszNewFile
			, "int"		, fFailIfExists
			, "uint"	, dwFlagsAndAttributes
			, "uint"	, dwFlags
			, "uint"	, dwContext )
	If (ErrorLevel or !r)
	Return 0
	else
	Return 1
}

WININET_FtpOpenFileA(hConnect,lpszFileName,dwAccess=0x80000000,dwFlags=0,dwContext=0){
	;http://msdn.microsoft.com/en-us/library/aa384166(VS.85).aspx
	Result := DllCall("wininet\FtpOpenFileA"
			, "uint"	, hConnect
			, "str"		, lpszFileName
			, "uint"	, dwAccess
			, "uint"	, dwFlags
			, "uint"	, dwContext	) ;dwContext
	If (ErrorLevel or !r)
		Return -1
	Return Result
}

WININET_InternetCloseHandle(hInternet){
	DllCall("wininet\InternetCloseHandle"
			,  "UInt"	, hInternet	)
}

WININET_FtpGetFileSize(hFile,lpdwFileSizeHigh=0) {
	;http://msdn.microsoft.com/en-us/library/aa384159(VS.85).aspx
	return DllCall("wininet\FtpGetFileSize"
					, "uint"	, hFile
					, "uint"	, lpdwFileSizeHigh	)
}

WININET_FtpDeleteFileA(hConnect,lpszFileName) {
   ;http://msdn.microsoft.com/en-us/library/aa384142(VS.85).aspx
   r :=  DllCall("wininet\FtpDeleteFileA"
   				, "uint"	, hConnect
				, "str"		, lpszFileName)
   If (ErrorLevel or !r)
      Return 0
   else
      Return 1
   }

WININET_FtpRenameFileA(hConnect,lpszExisting, lpszNew) {
	;http://msdn.microsoft.com/en-us/library/aa384175(VS.85).aspx
	r := DllCall("wininet\FtpRenameFileA"
				, "uint"	, hConnect
				, "str"		, lpszExisting
				, "str"		, lpszNew	)
	If (ErrorLevel or !r)
		Return 0
	else
		Return 1
}

WININET_FindFirstFile(hConnect, lpszSearchFile, ByRef lpFindFileData,dwFlags=0,dwContext=0) {
	;http://msdn.microsoft.com/en-us/library/aa384146(VS.85).aspx
	SIZE_OF_WIN32_FIND_DATA := ( 4 + (3*8) + (4*4) + (260*4) + (14*4) )
	VarSetCapacity(lpFindFileData, SIZE_OF_WIN32_FIND_DATA, 0)
	hFind := DllCall("wininet\FtpFindFirstFileA"
			, "uint"	, hConnect
			, "str"	, lpszSearchFile
			, "uint"	, &lpFindFileData
			, "uint"	, dwFlags
			, "uint"	, dwContext )

	If(!hFind)
		VarSetCapacity(lpFindFileData, 0)
	Return hFind
}

WININET_FindNextFile(hFind, ByRef lpvFindData) {
;http://msdn.microsoft.com/en-us/library/aa384698(VS.85).aspx
   Return DllCall("wininet\InternetFindNextFileA"
      , "uint", hFind
      , "uint", &lpvFindData)
}
UrlGetContents():
UrlGetContents(sUrl,sUserName="",sPassword="",sPostData="",sUserAgent="Autohotkey"){
	; based on heresy & DerRaphael's script here:
	; http://www.autohotkey.com/forum/viewtopic.php?t=33506

	;default ports
	INTERNET_INVALID_PORT_NUMBER 	= 0
	INTERNET_DEFAULT_HTTP_PORT 		= 80
	INTERNET_DEFAULT_HTTPS_PORT 	= 443

	;ssl flags
	INTERNET_FLAG_SECURE 					= 0x00800000
	SECURITY_FLAG_IGNORE_UNKNOWN_CA 		= 0x00000100
	SECURITY_FLAG_IGNORE_CERT_CN_INVALID 	= 0x00001000
	SECURITY_FLAG_IGNORE_CERT_DATE_INVALID 	= 0x00002000

	SplitPath,sURL,sFileName,sPath,sExt,sNoExt,sServer
	sProtocol := (RegExMatch(sServer,"(^http://|^ftp://|^https://)",pr)) ? pr1 : "unknown"
	if (sProtocol = "http://"){
		nPort := INTERNET_DEFAULT_HTTP_PORT
		dwFlags = 0
	} else if (sProtocol = "https://") {
		nPort := INTERNET_DEFAULT_HTTPS_PORT
		dwFlags := (INTERNET_FLAG_SECURE|SECURITY_FLAG_IGNORE_CERT_CN_INVALID
			|SECURITY_FLAG_IGNORE_CERT_DATE_INVALID|SECURITY_FLAG_IGNORE_UNKNOWN_CA)
	} else {
		nPort := INTERNET_INVALID_PORT_NUMBER
		dwFlags = 0
	}
	sPath := RegExReplace(sPath,"\Q" sServer "\E")
	sServerName := (sProtocol!="unknown") ? RegExReplace(sServer,"\Q" sProtocol "\E") : sServer
	sObjectName := sPath . "/" . sFileName
	hInternet := WININET_InternetOpenA(sUserAgent)
	hConnect := WININET_InternetConnectA(hInternet,sServerName,nPort,sUserName,sPassword)
	if sPostData
		sHTTPVerb:="POST", sHeaders:="Content-Type: application/x-www-form-urlencoded"
	else
		sHTTPVerb:="GET", sHeaders:=""
	sVersion:="HTTP/1.1", sReferer:="", sAcceptTypes:=""
	hRequest := WININET_HttpOpenRequestA(hConnect,sHTTPVerb,sObjectName,sVersion,sReferer,sAcceptTypes,dwFlags)
	if WININET_HttpSendRequestA(hRequest,sHeaders,sPostData)
		sData := WININET_InternetReadFile(hRequest)
	WININET_InternetCloseHandle(hRequest)
	WININET_InternetCloseHandle(hInternet)
	WININET_InternetCloseHandle(hConnect)
	return sData
}A couple test scripts:
;Get Web Page Contents Test
WININET_Init()
MsgBox % UrlGetContents("http://www.autohotkey.net")
WININET_UnInit()
return
;FTP Upload-Download Test
WININET_Init()
OnExit, CleanUp

sHost = autohotkey.net
nPort = 21
sUsername = YourUserName
sPassword = YourPassword
sLocalFile = C:\test_word_document.doc
sRemoteFile = /test_word_document.doc
sNewLocalFile = C:\new_test_word_document.doc
fFailIfExists := True ; False to overwrite existing file on download

INTERNET_OPEN_TYPE_DIRECT 	= 1
INTERNET_SERVICE_FTP 		= 1

; establish connection to FTP server
if hInternet := WININET_InternetOpenA(A_ScriptName,INTERNET_OPEN_TYPE_DIRECT)
	hConnect := WININET_InternetConnectA(hInternet,sHost,nPort,sUserName,sPassword,INTERNET_SERVICE_FTP)
If (ErrorLevel or !hConnect) {
	MsgBox, Error connecting to FTP server.
	ExitApp
	}
MsgBox Connected to Server

;Upload File
if !WININET_FtpPutFileA(hConnect,sLocalFile, sRemoteFile){
	MsgBox, Error uploading file
	ExitApp
	}
MsgBox Upload Complete

; download file
if !WININET_FtpGetFileA(hConnect,sRemoteFile,sNewLocalFile, fFailIfExists){
	MsgBox, Error downloading file
	ExitApp
	}
MsgBox Download Complete

ExitApp

CleanUp:
MsgBox Exiting.
WININET_InternetCloseHandle(hConnect)
WININET_InternetCloseHandle(hInternet)
WININET_UnInit()
ExitAppapi

/* api for wininet.ahk
WININET_FindNextFile( hFind, lpvFindData )
WININET_FindFirstFile( hConnect, lpszSearchFile, lpFindFileData [ , dwFlags, dwContext ] )
WININET_FtpRenameFileA( hConnect, lpszExisting, lpszNew )
WININET_FtpDeleteFileA( hConnect, lpszFileName )
WININET_FtpGetFileSize( hFile [ , lpdwFileSizeHigh ] )
WININET_InternetCloseHandle( hInternet )
WININET_FtpOpenFileA( hConnect, lpszFileName [ , dwAccess, dwFlags, dwContext ] )
WININET_FtpGetFileA( hConnect, lpszRemoteFile [ , lpszNewFile, fFailIfExists, dwFlagsAndAttributes, dwFlags, dwContext ] )
WININET_FtpPutFileA( hConnect, lpszLocalFile [ , lpszNewRemoteFile, dwFlags, dwContext ] )
WININET_FtpSetCurrentDirectoryA( hConnect, lpszDirectory )
WININET_FtpRemoveDirectoryA( hConnect, lpszDirectory )
WININET_FtpCreateDirectoryA( hConnect, lpszDirectory )
WININET_InternetReadFile( hFile )
WININET_HttpSendRequestA( hRequest [ , lpszHeaders, lpOptional ] )
WININET_HttpOpenRequestA( hConnect, lpszVerb, lpszObjectName [ , lpszVersion, lpszReferer, lplpszAcceptTypes, dwFlags, dwContext ] )
WININET_InternetConnectA( hInternet, lpszServerName [ , nServerPort, lpszUsername, lpszPassword, dwService, dwFlags, dwContext ] )
WININET_InternetOpenA( lpszAgent [ , dwAccessType, lpszProxyName, lpszProxyBypass, dwFlags ] )
WININET_UnInit( )
WININET_Init( )
*/