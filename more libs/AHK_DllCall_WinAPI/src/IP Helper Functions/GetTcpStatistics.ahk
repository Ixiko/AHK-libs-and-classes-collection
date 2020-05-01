; ===============================================================================================================================
; Function......: GetTcpStatistics
; DLL...........: Iphlpapi.dll
; Library.......: Iphlpapi.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa366020.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa366020.aspx
; ===============================================================================================================================
GetTcpStatistics()
{
    static MIB_TCPSTATS, init := VarSetCapacity(MIB_TCPSTATS, 60, 0) && NumPut(60, MIB_TCPSTATS, "UInt")
    if (DllCall("iphlpapi.dll\GetTcpStatistics", "Ptr", &MIB_TCPSTATS) != 0)
        return DllCall("kernel32.dll\GetLastError")
    return {  1 : NumGet(MIB_TCPSTATS,  0, "UInt"),  2 : NumGet(MIB_TCPSTATS,  4, "UInt"),  3 : NumGet(MIB_TCPSTATS,  8, "UInt")
           ,  4 : NumGet(MIB_TCPSTATS, 12, "UInt"),  5 : NumGet(MIB_TCPSTATS, 16, "UInt"),  6 : NumGet(MIB_TCPSTATS, 20, "UInt")
           ,  7 : NumGet(MIB_TCPSTATS, 24, "UInt"),  8 : NumGet(MIB_TCPSTATS, 28, "UInt"),  9 : NumGet(MIB_TCPSTATS, 32, "UInt")
           , 10 : NumGet(MIB_TCPSTATS, 36, "UInt"), 11 : NumGet(MIB_TCPSTATS, 40, "UInt"), 10 : NumGet(MIB_TCPSTATS, 44, "UInt")
           , 13 : NumGet(MIB_TCPSTATS, 48, "UInt"), 14 : NumGet(MIB_TCPSTATS, 52, "UInt"), 15 : NumGet(MIB_TCPSTATS, 56, "UInt") }
}
; ===============================================================================================================================

GetTcpStatistics := GetTcpStatistics()

MsgBox % "GetTcpStatistics function`n"
       . "MIB_TCPSTATS structure`n`n"
       . "RtoAlgorithm:`t`t"     GetTcpStatistics[1]    "`n"
       . "RtoMin:`t`t`t"         GetTcpStatistics[2]    "`n"
       . "RtoMax:`t`t`t"         GetTcpStatistics[3]    "`n"
       . "MaxConn:`t`t`t"        GetTcpStatistics[4]    "`n"
       . "ActiveOpens:`t`t"      GetTcpStatistics[5]    "`n"
       . "PassiveOpens:`t`t"     GetTcpStatistics[6]    "`n"
       . "AttemptFails:`t`t"     GetTcpStatistics[7]    "`n"
       . "EstabResets:`t`t"      GetTcpStatistics[8]    "`n"
       . "CurrEstab:`t`t`t"      GetTcpStatistics[9]    "`n"
       . "InSegs:`t`t`t"         GetTcpStatistics[10]   "`n"
       . "OutSegs:`t`t`t"        GetTcpStatistics[11]   "`n"
       . "RetransSegs:`t`t"      GetTcpStatistics[12]   "`n"
       . "InErrs:`t`t`t"         GetTcpStatistics[13]   "`n"
       . "OutRsts:`t`t`t"        GetTcpStatistics[14]   "`n"
       . "NumConns:`t`t"         GetTcpStatistics[15]





/* C++ ==========================================================================================================================
DWORD GetTcpStatistics(                                                              // UInt
    _Out_  PMIB_TCPSTATS pStats                                                      // Ptr        (60)
);


typedef struct _MIB_TCPSTATS {
    DWORD dwRtoAlgorithm;                                                            // UInt        4          =>   0
    DWORD dwRtoMin;                                                                  // UInt        4          =>   4
    DWORD dwRtoMax;                                                                  // UInt        4          =>   8
    DWORD dwMaxConn;                                                                 // UInt        4          =>  12
    DWORD dwActiveOpens;                                                             // UInt        4          =>  16
    DWORD dwPassiveOpens;                                                            // UInt        4          =>  20
    DWORD dwAttemptFails;                                                            // UInt        4          =>  24
    DWORD dwEstabResets;                                                             // UInt        4          =>  28
    DWORD dwCurrEstab;                                                               // UInt        4          =>  32
    DWORD dwInSegs;                                                                  // UInt        4          =>  36
    DWORD dwOutSegs;                                                                 // UInt        4          =>  40
    DWORD dwRetransSegs;                                                             // UInt        4          =>  44
    DWORD dwInErrs;                                                                  // UInt        4          =>  48
    DWORD dwOutRsts;                                                                 // UInt        4          =>  52
    DWORD dwNumConns;                                                                // UInt        4          =>  56
} MIB_TCPSTATS, *PMIB_TCPSTATS;
============================================================================================================================== */