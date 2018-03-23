; HttpQueryInfo - Get HTTP headers by olfen
; http://www.autohotkey.com/forum/topic10510.html
/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HttpQueryInfo ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
QueryInfoFlag:

HTTP_QUERY_RAW_HEADERS = 21
Receives all the headers returned by the server.
Each header is terminated by "\0". An additional "\0" terminates the list of headers.

HTTP_QUERY_CONTENT_LENGTH = 5
Retrieves the size of the resource, in bytes.

HTTP_QUERY_CONTENT_TYPE = 1
Receives the content type of the resource (such as text/html).

Find more at: http://msdn.microsoft.com/library/en-us/wininet/wininet/query_info_flags.asp

Proxy Settings:

INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

*/ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HttpQueryInfo(URL, QueryInfoFlag=21, Proxy="", ProxyBypass="") {
hModule := DllCall("LoadLibrary", "str", "wininet.dll")

If (Proxy != "")
AccessType=3
Else
AccessType=1

io_hInternet := DllCall("wininet\InternetOpenA"
, "str", "" ;lpszAgent
, "uint", AccessType
, "str", Proxy
, "str", ProxyBypass
, "uint", 0) ;dwFlags
If (ErrorLevel != 0 or io_hInternet = 0) {
DllCall("FreeLibrary", "uint", hModule)
return, -1
}

iou_hInternet := DllCall("wininet\InternetOpenUrlA"
, "uint", io_hInternet
, "str", url
, "str", "" ;lpszHeaders
, "uint", 0 ;dwHeadersLength
, "uint", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
, "uint", 0) ;dwContext
If (ErrorLevel != 0 or iou_hInternet = 0) {
DllCall("FreeLibrary", "uint", hModule)
return, -1
}

VarSetCapacity(buffer, 1024, 0)
VarSetCapacity(buffer_len, 4, 0)

Loop, 5
{
  hqi := DllCall("wininet\HttpQueryInfoA"
  , "uint", iou_hInternet
  , "uint", QueryInfoFlag ;dwInfoLevel
  , "uint", &buffer
  , "uint", &buffer_len
  , "uint", 0) ;lpdwIndex
  If (hqi = 1) {
    hqi=success
    break
  }
}

IfNotEqual, hqi, success, SetEnv, res, timeout

If (hqi = "success") {
p := &buffer
Loop
{
  l := DllCall("lstrlen", "UInt", p)
  VarSetCapacity(tmp_var, l+1, 0)
  DllCall("lstrcpy", "Str", tmp_var, "UInt", p)
  p += l + 1 
  res := res  . "`n" . tmp_var
  If (*p = 0)
  Break
}
StringTrimLeft, res, res, 1
}

DllCall("wininet\InternetCloseHandle",  "uint", iou_hInternet)
DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
DllCall("FreeLibrary", "uint", hModule)

return, res
}
