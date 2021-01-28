; ===============================================================================================================================
; Retrieves the IPv4 User Datagram Protocol (UDP) listener table
; ===============================================================================================================================

GetUdpTable()
{
    static hIPHLPAPI := DllCall("LoadLibrary", "str", "iphlpapi.dll", "ptr"), table := []
    VarSetCapacity(TBL, 4 + (s := (8 * 32)), 0)
    while (DllCall("iphlpapi\GetUdpTable", "ptr", &TBL, "uint*", s, "uint", 1) = 122)
        VarSetCapacity(TBL, 4 + s, 0)

    table := {}, index := 1
    loop % NumGet(TBL, 0, "uint") {
        o := 4 + ((index - 1) * 8)
        table[index, "LocalIP"]   := (( ROW := NumGet(TBL, o,   "uint"))&0xff) "." ((ROW&0xff00)>>8) "." ((ROW&0xff0000)>>16) "." ((ROW&0xff000000)>>24)
        table[index, "LocalPort"] := (((ROW := NumGet(TBL, o+4, "uint"))&0xff00)>>8) | ((ROW&0xff)<<8)
        index++
    }
    return table, DllCall("FreeLibrary", "ptr", hIPHLPAPI)
}

; ===============================================================================================================================

for i, v in GetUdpTable()
    MsgBox % v.LocalIP ":" v.LocalPort
; 192.168.0.1:138

ExitApp

/* ===============================================================================================================================
References:
- https://msdn.microsoft.com/en-us/library/aa366033(v=vs.85).aspx    GetUdpTable function
- https://msdn.microsoft.com/en-us/library/aa366930(v=vs.85).aspx    MIB_UDPTABLE structure
- https://msdn.microsoft.com/en-us/library/aa366926(v=vs.85).aspx    MIB_UDPROW structure
=============================================================================================================================== */