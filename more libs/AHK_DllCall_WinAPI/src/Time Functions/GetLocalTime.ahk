; ===============================================================================================================================
; Function......: GetLocalTime
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724338.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724338.aspx
; ===============================================================================================================================
GetLocalTime()
{
    static SYSTEMTIME, init := VarSetCapacity(SYSTEMTIME, 16, 0) && NumPut(16, SYSTEMTIME, "UShort")
    DllCall("kernel32.dll\GetLocalTime", "Ptr", &SYSTEMTIME, "Ptr")
    return { 1 : NumGet(SYSTEMTIME,  0, "UShort"), 2 : NumGet(SYSTEMTIME,  2, "UShort")
           , 3 : NumGet(SYSTEMTIME,  4, "UShort"), 4 : NumGet(SYSTEMTIME,  6, "UShort")
           , 5 : NumGet(SYSTEMTIME,  8, "UShort"), 6 : NumGet(SYSTEMTIME, 10, "UShort")
           , 7 : NumGet(SYSTEMTIME, 12, "UShort"), 8 : NumGet(SYSTEMTIME, 14, "UShort") }
}
; ===============================================================================================================================

GetLocalTime := GetLocalTime()

MsgBox % "GetLocalTime function`n"
       . "SYSTEMTIME structure`n`n"
       . "wYear:`t`t"                GetLocalTime[1]   "`n"
       . "wMonth:`t`t"               GetLocalTime[2]   "`n"
       . "wDayOfWeek:`t"             GetLocalTime[3]   "`n"
       . "wDay:`t`t"                 GetLocalTime[4]   "`n"
       . "wHour:`t`t"                GetLocalTime[5]   "`n"
       . "wMinute:`t`t"              GetLocalTime[6]   "`n"
       . "wSecond:`t`t"              GetLocalTime[7]   "`n"
       . "wMilliseconds:`t"          GetLocalTime[8]





/* C++ ==========================================================================================================================
void WINAPI GetLocalTime(                                                            // Ptr
    _Out_  LPSYSTEMTIME lpSystemTime                                                 // Ptr        (16)
);


typedef struct _SYSTEMTIME {
    WORD wYear;                                                                      // UShort      2          =>   0
    WORD wMonth;                                                                     // UShort      2          =>   2
    WORD wDayOfWeek;                                                                 // UShort      2          =>   4
    WORD wDay;                                                                       // UShort      2          =>   6
    WORD wHour;                                                                      // UShort      2          =>   8
    WORD wMinute;                                                                    // UShort      2          =>  10
    WORD wSecond;                                                                    // UShort      2          =>  12
    WORD wMilliseconds;                                                              // UShort      2          =>  14
} SYSTEMTIME, *PSYSTEMTIME;
============================================================================================================================== */