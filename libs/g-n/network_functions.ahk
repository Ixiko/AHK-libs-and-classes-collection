; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; Get output of running ipconfig.exe
; http://msdn.microsoft.com/en-us/library/cbxxzwb5%28v=VS.85%29.aspx
; http://technet.microsoft.com/en-us/library/ee156605.aspx
; GetIpConfig() {
; 	objShell := ComObjCreate("WScript.Shell")
; 	objExec := objShell.Exec("ipconfig.exe")
; 	While !objExec.Status
; 		Sleep 100
; 	result := objExec.StdOut.ReadAll()
; 	return result
; }


; Example texts:
; www.itenium.be
; 172.217.17.132

GetMyIps() {
	result .= "Public IP: " GetPublicIP()
	result .= "`nPrivate IP: " GetLocalIPByAdaptor("Ethernet")
	For AdaptorName, IP in GetLocalIPs() {
		result .= "`n" AdaptorName ": " IP
	}
	for i, v in GetDnsAddress()
		result .= "`nDNS: " v

	for i, v in GetMacAddress()
		result .= "`nMAC: " v

	return result
}


ResolveHostname(ip) {
	return ip " => " IPHelper.ResolveHostname(ip)
}

Ping(url) {
	result := url "`nPinged in " IPHelper.Ping(url) " ms"
	return result
}

ReverseLookup(url) {
	return url " => " IPHelper.ReverseLookup(url)
}



GetPublicIP() {
	; IP Services:
	; - https://api.ipify.org
	; - http://www.netikus.net/show_ip.html
	; - https://www.google.com/search?q=what+is+my+ip&num=1 (=html)

	MyExternalIP = 0.0.0.0
	TmpFile = %WinDir%\TEMP\IPAddress.TMP
	UrlDownloadToFile, https://api.ipify.org, %TmpFile%
	FileReadLine, MyExternalIP, %TmpFile%, 1
	FileDelete, %TmpFile%
	return MyExternalIP
}
; GetPublicIPFromGoogle() {
; 	HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
; 	HttpObj.Open("GET", "https://www.google.com/search?q=what+is+my+ip&num=1")
; 	HttpObj.Send()
; 	RegexMatch(HttpObj.ResponseText,"Client IP address: ([\d\.]+)",match)
; 	Return match1
; }


GetLocalIPByAdaptor(adaptorName) {
	objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionID = '" adaptorName "'")._NewEnum, colItems[objItem]
	colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE InterfaceIndex = '" objItem.InterfaceIndex "'")._NewEnum, colItems[objItem]
	Return objItem.IPAddress[0]
}


GetLocalIPs() {
	adaptors := Object()
	ips := Object()
	objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
	colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter")._NewEnum, colItems[objItem]
	While (colItems[objItem])
		adaptors.Insert(objItem.InterfaceIndex,objItem.NetConnectionID)
	For index, name in adaptors {
		colItems := objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE InterfaceIndex = '" index "'")._NewEnum, colItems[objItem]
		If (name && objItem.IPAddress[0])
			ips.Insert(name,objItem.IPAddress[0])
	}
	Return ips
}


; ===============================================================================================================================
; Get a list of DNS servers used by the local computer.
; ===============================================================================================================================
GetDnsAddress() {
    if (DllCall("iphlpapi.dll\GetNetworkParams", "ptr", 0, "uint*", size) = 111) && !(VarSetCapacity(buf, size, 0))
        throw Exception("Memory allocation failed for FIXED_INFO struct", -1)
    if (DllCall("iphlpapi.dll\GetNetworkParams", "ptr", &buf, "uint*", size) != 0)
        throw Exception("GetNetworkParams failed with error: " A_LastError, -1)
    addr := &buf, DNS_SERVERS := []
    DNS_SERVERS[1] := StrGet(addr + 264 + (A_PtrSize * 2), "cp0")
    ptr := NumGet(addr+0, 264 + A_PtrSize, "uptr")
    while (ptr) {
        DNS_SERVERS[A_Index + 1] := StrGet(ptr+0 + A_PtrSize, "cp0")
        ptr := NumGet(ptr+0, "uptr")
    }
    return DNS_SERVERS
}


; ===============================================================================================================================
; Get a list of computers MAC address.
; ===============================================================================================================================
GetMacAddress(delimiter := ":", case := False) {
    if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", 0, "uint*", size) = 111) && !(VarSetCapacity(buf, size, 0))
        throw Exception("Memory allocation failed for IP_ADAPTER_INFO struct", -1)
    if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", &buf, "uint*", size) != 0)
        throw Exception("GetAdaptersInfo failed with error: " A_LastError, -1)
    addr := &buf, MAC_ADDRESS := []
    while (addr) {
        loop % NumGet(addr+0, 396 + A_PtrSize, "uint")
            mac .= Format("{:02" (case ? "X" : "x") "}", NumGet(addr+0, 400 + A_PtrSize + A_Index - 1, "uchar")) "" delimiter ""
        MAC_ADDRESS[A_Index] := SubStr(mac, 1, -1), mac := ""
        addr := NumGet(addr+0, "uptr")
    }
    return MAC_ADDRESS
}


; ===============================================================================================================================
; Flush entire DNS cache, same as [ipconfig /flushdns] in cmd console
; ===============================================================================================================================
FlushDNS() {
    if !(DllCall("dnsapi.dll\DnsFlushResolverCache"))
        throw Exception("DnsFlushResolverCache", -1)
    return 1
}

; ===============================================================================================================================