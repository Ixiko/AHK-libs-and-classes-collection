; Link:   	https://gist.github.com/tmplinshi/ccd11fae4953a27b9d04db6ef10bc3de
; Author:	
; Date:   	
; for:     	AHK_L


GetAllResponseHeaders(Url, RequestHeaders := "", NO_AUTO_REDIRECT := false, NO_COOKIES := false) {
	static INTERNET_OPEN_TYPE_DIRECT := 1
	     , INTERNET_SERVICE_HTTP := 3
	     , HTTP_QUERY_RAW_HEADERS_CRLF := 22
	     , CP_UTF8 := 65001
	     , Default_UserAgent := "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"

	hModule := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")

	if !hInternet := DllCall("wininet\InternetOpen", "ptr", &Default_UserAgent, "uint", INTERNET_OPEN_TYPE_DIRECT
		, "str", "", "str", "", "uint", 0)
		return
	; -----------------------------------------------------------------------------------
	if !InStr(Url, "://")
		Url := "http://" Trim(Url)

	regex := "(?P<protocol>\w+)://((?P<user>\w+):(?P<pwd>\w+)@)?(?P<host>[\w.]+)(:(?P<port>\d+))?(?P<path>.*)"
	RegExMatch(Url, regex, v_)

	if (v_protocol = "ftp") {
		throw, "ftp is not supported."
	}
	if (v_port = "") {
		v_port := (v_protocol = "https") ? 443 : 80
	}
	; -----------------------------------------------------------------------------------
	Internet_Flags := 0
	                | 0x400000   ; INTERNET_FLAG_KEEP_CONNECTION
	                | 0x80000000 ; INTERNET_FLAG_RELOAD
	                | 0x20000000 ; INTERNET_FLAG_NO_CACHE_WRITE
	if (v_protocol = "https") {
		Internet_Flags |= 0x1000  ; INTERNET_FLAG_IGNORE_CERT_CN_INVALID
		               | 0x2000   ; INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
		               | 0x800000 ; INTERNET_FLAG_SECURE ; Technically, this is redundant for https
	}
	if NO_AUTO_REDIRECT
		Internet_Flags |= 0x00200000 ; INTERNET_FLAG_NO_AUTO_REDIRECT
	if NO_COOKIES
		Internet_Flags |= 0x00080000 ; INTERNET_FLAG_NO_COOKIES
	; -----------------------------------------------------------------------------------
	hConnect := DllCall("wininet\InternetConnect", "ptr", hInternet, "ptr", &v_host, "uint", v_port
		, "ptr", &v_user, "ptr", &v_pwd, "uint", INTERNET_SERVICE_HTTP, "uint", Internet_Flags, "uint", 0, "ptr")

	hRequest := DllCall("wininet\HttpOpenRequest", "ptr", hConnect, "str", "HEAD", "ptr", &v_path
		, "str", "HTTP/1.1", "ptr", 0, "ptr", 0, "uint", Internet_Flags, "ptr", 0, "ptr")

	nRet := DllCall("wininet\HttpSendRequest", "ptr", hRequest, "ptr", &RequestHeaders, "int", -1
		, "ptr", 0, "uint", 0)

	Loop, 2 {
		DllCall("wininet\HttpQueryInfoA", "ptr", hRequest, "uint", HTTP_QUERY_RAW_HEADERS_CRLF
			, "ptr", &pBuffer, "uint*", bufferLen, "uint", 0)
		if (A_Index = 1)
			VarSetCapacity(pBuffer, bufferLen, 0)
	}
	; -----------------------------------------------------------------------------------
	output := StrGet(&pBuffer, "UTF-8")
	; -----------------------------------------------------------------------------------
	DllCall("wininet\InternetCloseHandle", "ptr", hRequest)
	DllCall("wininet\InternetCloseHandle", "ptr", hConnect)
	DllCall("wininet\InternetCloseHandle", "ptr", hInternet)
	DllCall("FreeLibrary", "Ptr", hModule)

	return output
}