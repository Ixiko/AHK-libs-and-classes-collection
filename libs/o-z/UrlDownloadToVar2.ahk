; code cleanup and AHK_L compatibility by Drugwash
; updated 2016.03.20 (working version)
; requires updates.ahk
; Use a user-defined function name for 'prc' to retrieve the downloaded percent

;INTERNET_OPEN_TYPE_PRECONFIG						0   // use registry configuration
;INTERNET_OPEN_TYPE_DIRECT							1   // direct to net
;INTERNET_OPEN_TYPE_PROXY							3   // via named proxy
;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY	4   // prevent using java/script/INS
;INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item

UrlDownloadToVar(ByRef res, URL, prc="", Proxy="", ProxyBypass="", limit="", UA="", hdrs="")
{
Global AW, Ptr, PtrP, AStr
Static buff
at := A_AutoTrim
AutoTrim, Off
AccessType := (Proxy != "") ? 0x3 : 0x1
hlen := (hdrs != "") ? 0xFFFFFFFF : 0x0
hModule := DllCall("LoadLibrary" AW, "Str", "wininet.dll")
io_hInternet := DllCall("wininet\InternetOpen" AW
				, "Str"	, UA			; lpszAgent
				, "UInt"	, AccessType	; dwAccessType
				, "Str"	, Proxy		; lpszProxyName
				, "Str"	, ProxyBypass	; lpszProxyBypass
				, "UInt"	, 0)			; dwFlags

iou := DllCall("wininet\InternetOpenUrl" AW
				, Ptr		, io_hInternet
				, "Str"	, URL
				, "Str"	, hdrs		; lpszHeaders
				, "UInt"	, hlen		; dwHeadersLength
				, "UInt"	, 0x84000000	; dwFlags: INTERNET_FLAG_RELOAD/-NO_CACHE_WRITE/-SECURE
;				, "UInt"	, 0x8C800200	; dwFlags: INTERNET_FLAG_RELOAD/NO_UI/NO_AUTH/PRAGMA_NOCACHE/NO_CACHE_WRITE/SECURE
				, "UInt"	, 0)			; dwContext
e := ErrorLevel
If (e != 0 or iou = 0)
	{
	res=0
	msgbox, Error %e% in %A_ThisFunc%().`nURL=%URL%`nio_hInternet=%io_hInternet%`niou=%iou%`n`nUA="%UA%"`nhlen=%hlen%`nheaders:`n"%hdrs%"
	goto close
	}
infobuf=0
infobufsz=4
bufsz=128
if DllCall("wininet\HttpQueryInfo" AW
			, Ptr, iou				; hFile
			, "UInt", 0x20000005	; dwInfoLevel HTTP_QUERY_CONTENT_LENGTH=5|HTTP_QUERY_FLAG_NUMBER
			, PtrP, infobuf			; lpvBuffer
			, PtrP, infobufsz		; lpdwBufferLength
			, Ptr, 0)				; lpdwIndex
	{
	VarSetCapacity(buff, bufsz, 0)
	VarSetCapacity(res, infobuf, 0)
	VarSetCapacity(NumberOfBytesRead, 4, 0)
	obr=0
	Loop
		{
		if !irf := DllCall("wininet\InternetReadFile"
				, Ptr		, iou
				, Ptr		, &buff
				, "UInt"	, bufsz
				, Ptr		, &NumberOfBytesRead)
			msgbox, Error %ErrorLevel% in %A_ThisFunc%() -> InternetReadFile()
			Sleep, -1
		if irf && !r := NumGet(NumberOfBytesRead, 0, "UInt")
			break
		Sleep, -1
		dest := &res + obr
		DllCall("RtlMoveMemory", Ptr, dest, Ptr, &buff, "UInt", r)
		obr += r
		%prc%((obr*100)//infobuf)
		}
	infobuf := obr
	}
else
	{
	VarSetCapacity(res, bufsz, 0)
	VarSetCapacity(buff, bufsz, 0)
	VarSetCapacity(NumberOfBytesRead, 4, 0)
	osz=0
	Loop
		{
		irf := DllCall("wininet\InternetReadFile"
				, Ptr		, iou
				, Ptr		, &buff
				, "UInt"	, bufsz
				, Ptr		, &NumberOfBytesRead)
		if !r := NumGet(NumberOfBytesRead, 0, "UInt")
			break
		Sleep, -1
		if osz
			{
			VarSetCapacity(buf2, osz, 0)
			DllCall("RtlMoveMemory", Ptr, &buf2, Ptr, &res, "UInt", osz)
			}
		VarSetCapacity(res, 0), VarSetCapacity(res, osz+r, 0)
		if osz
			DllCall("RtlMoveMemory", Ptr, &res, Ptr, &buf2, "UInt", osz)
		DllCall("RtlMoveMemory", Ptr, &res+osz, Ptr, &buff, "UInt", r)
		osz+=r
		if (limit <> "" && InStr(res, limit))
			break
		}
	VarSetCapacity(buff, 0)
	VarSetCapacity(buf2, 0)
	infobuf := osz+r
	}
DllCall("wininet\InternetCloseHandle",  Ptr, iou)
close:
DllCall("wininet\InternetCloseHandle",  Ptr, io_hInternet)
DllCall("FreeLibrary", Ptr, hModule)
AutoTrim, %at%
return infobuf
}
