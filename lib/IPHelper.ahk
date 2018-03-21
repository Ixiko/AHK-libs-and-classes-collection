/*
    IPHelper by jNizM
    https://github.com/jNizM/AHK_Scripts/blob/master/src/net/Class_IPHelper.ahk

    MsgBox % IPHelper.ResolveHostname("google-public-dns-a.google.com")    ; -> 8.8.8.8
    MsgBox % IPHelper.ReverseLookup("8.8.8.8")                             ; -> google-public-dns-a.google.com
    MsgBox % IPHelper.Ping("8.8.8.8")                                      ; -> 24

    MsgBox % IPHelper.ResolveHostname("autohotkey.com")                    ; -> 104.24.122.247
    MsgBox % IPHelper.ReverseLookup("104.24.122.247")                      ; -> 104.24.122.247 (because no reverse pointer is set)
    MsgBox % IPHelper.Ping("autohotkey.com")                               ; -> 129

*/

class IPHelper
{
    static hWS2_32   := DllCall("LoadLibrary", "str", "ws2_32.dll",   "ptr")
    static hIPHLPAPI := DllCAll("LoadLibrary", "str", "iphlpapi.dll", "ptr")

    Ping(addr, timeout := 1000)
    {
        if !(RegExMatch(addr, "^((|\.)\d{1,3}){4}$"))
            addr := this.ResolveHostname(addr)
        in_addr := this.inet_addr(addr)
        hICMP := this.IcmpCreateFile()
        rtt := this.IcmpSendEcho(hICMP, in_addr, timeout)
        return rtt, this.IcmpCloseHandle(hICMP)
    }

    ResolveHostname(hostname)
    {
        this.WSAStartup()
        ip_addr := this.getaddrinfo(hostname)
        return ip_addr, this.WSACleanup()
    }

    ReverseLookup(ip_addr)
    {
        this.WSAStartup()
        in_addr := this.inet_addr(ip_addr)
        hostname := this.getnameinfo(in_addr)
        return hostname, this.WSACleanup()
    }

    ; ===========================================================================================================================
    ; WSAStartup                                                  https://msdn.microsoft.com/en-us/library/ms742213(v=vs.85).aspx
    ; ===========================================================================================================================
    WSAStartup()
    {
        static WSASIZE := 394 + (A_PtrSize - 2) + A_PtrSize
        VarSetCapacity(WSADATA, WSASIZE, 0)
        if (DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", &WSADATA) != 0)
            throw Exception("WSAStartup failed", -1)
        return true
    }

    ; ===========================================================================================================================
    ; WSACleanup                                                  https://msdn.microsoft.com/en-us/library/ms741549(v=vs.85).aspx
    ; ===========================================================================================================================
    WSACleanup()
    {
        if (DllCall("ws2_32\WSACleanup") != 0)
            throw Exception("WSACleanup failed: " DllCall("ws2_32\WSAGetLastError"), -1)
        return true
    }

    ; ===========================================================================================================================
    ; getaddrinfo                                                 https://msdn.microsoft.com/en-us/library/ms738520(v=vs.85).aspx
    ; ===========================================================================================================================
    getaddrinfo(hostname)
    {
        VarSetCapacity(addrinfo, 16 + 4 * A_PtrSize, 0)
        NumPut(2, addrinfo, 4, "int") && NumPut(1, addrinfo, 8, "int") && NumPut(6, addrinfo, 12, "int")
        if (DllCall("ws2_32\getaddrinfo", "astr", hostname
                                        , "ptr",  0
                                        , "ptr",  &addrinfo
                                        , "ptr*", result) != 0)
            throw Exception("getaddrinfo failed: " DllCall("ws2_32\WSAGetLastError"), -1), this.WSACleanup()
        addr := StrGet(this.inet_ntoa(NumGet(NumGet(result+0, 16 + 2 * A_PtrSize) + 4, 0, "uint")), "cp0")
        return addr, this.freeaddrinfo(result)
    }

    ; ===========================================================================================================================
    ; freeaddrinfo                                                https://msdn.microsoft.com/en-us/library/ms737931(v=vs.85).aspx
    ; ===========================================================================================================================
    freeaddrinfo(addrinfo)
    {
        DllCall("ws2_32\freeaddrinfo", "ptr", addrinfo)
    }

    ; ===========================================================================================================================
    ; getnameinfo                                                 https://msdn.microsoft.com/en-us/library/ms738532(v=vs.85).aspx
    ; ===========================================================================================================================
    getnameinfo(in_addr)
    {
        static NI_MAXHOST := 1025
        size := VarSetCapacity(sockaddr, 16, 0), NumPut(2, sockaddr, 0, "short") && NumPut(in_addr, sockaddr, 4, "uint")
        VarSetCapacity(hostname, NI_MAXHOST, 0)
        if (DllCall("ws2_32\getnameinfo", "ptr",  &sockaddr
                                        , "int",  size
                                        , "ptr",  &hostname
                                        , "uint", NI_MAXHOST
                                        , "ptr",  0
                                        , "uint", 0
                                        , "int",  0))
            throw Exception("getnameinfo failed: " DllCall("ws2_32\WSAGetLastError"), -1), this.WSACleanup()
        return StrGet(&hostname+0, NI_MAXHOST, "cp0")
    }

    ; ===========================================================================================================================
    ; inet_addr                                                   https://msdn.microsoft.com/en-us/library/ms738563(v=vs.85).aspx
    ; ===========================================================================================================================
    inet_addr(ip_addr)
    {
        in_addr := DllCall("ws2_32\inet_addr", "astr", ip_addr, "uint")
        if !(in_addr) || (in_addr = 0xFFFFFFFF)
            throw Exception("inet_addr failed", -1)
        return in_addr
    }

    ; ===========================================================================================================================
    ; inet_ntoa                                                   https://msdn.microsoft.com/en-us/library/ms738564(v=vs.85).aspx
    ; ===========================================================================================================================
    inet_ntoa(in_addr)
    {
        if !(buf := DllCall("ws2_32\inet_ntoa", "uint", in_addr, "ptr"))
            throw Exception("inet_ntoa failed", -1)
        return buf
    }

    ; ===========================================================================================================================
    ; IcmpCreateFile                                              https://msdn.microsoft.com/en-us/library/aa366045(v=vs.85).aspx
    ; ===========================================================================================================================
    IcmpCreateFile()
    {
        if !(hIcmpFile := DllCall("iphlpapi\IcmpCreateFile", "ptr"))
            throw Exception("IcmpCreateFile failed", -1)
        return hIcmpFile
    }

    ; ===========================================================================================================================
    ; IcmpSendEcho                                                https://msdn.microsoft.com/en-us/library/aa366050(v=vs.85).aspx
    ; ===========================================================================================================================
    IcmpSendEcho(hIcmpFile, in_addr, timeout)
    {
        size := VarSetCapacity(buf, 32 + 8, 0)
        if !(DllCall("iphlpapi\IcmpSendEcho", "ptr",    hIcmpFile
                                            , "uint",   in_addr
                                            , "ptr",    0
                                            , "ushort", 0
                                            , "ptr",    0
                                            , "ptr",    &buf
                                            , "uint",   size
                                            , "uint",   timeout
                                            , "uint"))
            throw Exception("IcmpSendEcho failed", -1)
        return (rtt := NumGet(buf, 8, "uint")) < 1 ? 1 : rtt
    }

    ; ===========================================================================================================================
    ; IcmpCloseHandle                                             https://msdn.microsoft.com/en-us/library/aa366043(v=vs.85).aspx
    ; ===========================================================================================================================
    IcmpCloseHandle(hIcmpFile)
    {
        if !(DllCall("iphlpapi\IcmpCloseHandle", "ptr", hIcmpFile))
            throw Exception("IcmpCloseHandle failed", -1)
        return true
    }
}
