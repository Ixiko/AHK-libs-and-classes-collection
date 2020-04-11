; ===============================================================================================================================
; Reverse lookup – Gets hostname by IP address
; ===============================================================================================================================

ReverseLookup(ipaddr) {
    hWS2_32 := DllCall("LoadLibrary", "str", "ws2_32.dll", "ptr")
    VarSetCapacity(WSADATA, 394 + (A_PtrSize - 2) + A_PtrSize, 0)
    if (DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", &WSADATA) != 0)
        throw Exception("Failure in WSAStartup", -1), DllCall("ws2_32\WSACleanup")
    inaddr := DllCall("ws2_32\inet_addr", "astr", ipaddr, "uint")
    if !(inaddr) || (inaddr = 0xFFFFFFFF)
        throw Exception("inet_addr", -1), DllCall("ws2_32\WSACleanup")
    size := VarSetCapacity(sockaddr, 16, 0), NumPut(2, sockaddr, 0, "short") && NumPut(inaddr, sockaddr, 4, "uint")
    VarSetCapacity(hostname, 1025 * (A_IsUnicode ? 2 : 1))
    if (DllCall("ws2_32\getnameinfo", "ptr", &sockaddr, "int", size, "ptr", &hostname, "uint", 1025, "ptr", 0, "uint", 32, "int", 0))
        throw Exception("getnameinfo: " DllCall("ws2_32\WSAGetLastError"), -1) , DllCall("ws2_32\WSACleanup")
    return StrGet(&hostname+0, 1025, "cp0"), DllCall("ws2_32\WSACleanup") && DllCall("FreeLibrary", "ptr", hWS2_32)
}

; ===============================================================================================================================

;MsgBox % ReverseLookup("8.8.8.8")        ; ==> google-public-dns-a.google.com

ExitApp