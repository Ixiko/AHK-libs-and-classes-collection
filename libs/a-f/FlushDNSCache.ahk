;#include updates.ahk

FlushDNScache(v="2.0")
{
Global
Static vr, sz, WSADATA
if v not in 1.0,1.1,2.0,2.1,2.2
	return 1
vr := SubStr(v, 1, 1) + (SubStr(v, -1) << 8)
sz := VarSetCapacity(WSADATA, 2+2+257+129+2+2+A_PtrSize, 0)
;if DllCall("Ws2_32\WSAStartup", "UShort", vr, Ptr, &WSADATA)
if DllCall("WSOCK32\WSAStartup", "UShort", vr, Ptr, &WSADATA)
	return 2
if r := DllCall("WSOCK32\WsControl"
			, "UInt", 0xFFFFFFFF	; protocol (IPPROTO_*)
			, "UInt", 6			; action
			, Ptr, 0				; pRequestInfo
			, "UInt", 0			; pcbRequestInfoLen
			, Ptr, 0				; pResponseInfo
			, "UInt", 0)			; pcbResponseInfoLen
	{
	if DllCall("WSOCK32\WSACleanup")
		return 5
	return r
	}
;if DllCall("Ws2_32\WSACleanup")
if DllCall("WSOCK32\WSACleanup")
	return 4
}

/*
WSCNTL_AFD_FLUSH_RESOLVER_CACHE	6
WSCNTL_COUNT_INTERFACES			1
WSCNTL_COUNT_ROUTES				2
*/
