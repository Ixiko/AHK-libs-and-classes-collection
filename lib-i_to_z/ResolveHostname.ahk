; ===============================================================================================================================
; DNS Name Resolution – Gets IP address from hostname
; ===============================================================================================================================

ResolveHostname(hostname) {
    hWS2_32 := DllCall("LoadLibrary", "str", "ws2_32.dll", "ptr")
    VarSetCapacity(WSADATA, 394 + (A_PtrSize - 2) + A_PtrSize, 0)
    if (DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", &WSADATA) != 0)
        throw Exception("Failure in WSAStartup", -1), DllCall("ws2_32\WSACleanup")
    VarSetCapacity(hints, 16 + 4 * A_PtrSize, 0)
    NumPut(2, hints, 4, "int") && NumPut(1, hints, 8, "int") && NumPut(6, hints, 12, "int")
    if (DllCall("ws2_32\getaddrinfo", "astr", hostname, "ptr", 0, "ptr", &hints, "ptr*", result))
        throw Exception("getaddrinfo: " DllCall("ws2_32\WSAGetLastError"), -1) , DllCall("ws2_32\WSACleanup")
    addr := result, IPList := []
    while (addr) {
        ipaddr := DllCall("ws2_32\inet_ntoa", "uint", NumGet(NumGet(addr+0, 16 + 2 * A_PtrSize) + 4, 0, "uint"), "astr")
        IPList[A_Index] := ipaddr, addr := NumGet(addr+0, 16 + 3 * A_PtrSize)
    }
    return IPList, DllCall("ws2_32\WSACleanup") && DllCall("FreeLibrary", "ptr", hWS2_32)
}

; ===============================================================================================================================

for k, v in ResolveHostname("google-public-dns-a.google.com")
    MsgBox % v    ; ==> 8.8.8.8

ExitApp