; ===============================================================================================================================
; Function......: GetSystemTime
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724390.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724390.aspx
; ===============================================================================================================================
GetSystemTime()
{
    static SYSTEMTIME, init := VarSetCapacity(SYSTEMTIME, 16, 0) && NumPut(16, SYSTEMTIME, "UShort")
    DllCall("kernel32.dll\GetSystemTime", "Ptr", &SYSTEMTIME, "Ptr")
    return { 1 : NumGet(SYSTEMTIME,  0, "UShort"), 2 : NumGet(SYSTEMTIME,  2, "UShort")
           , 3 : NumGet(SYSTEMTIME,  4, "UShort"), 4 : NumGet(SYSTEMTIME,  6, "UShort")
           , 5 : NumGet(SYSTEMTIME,  8, "UShort"), 6 : NumGet(SYSTEMTIME, 10, "UShort")
           , 7 : NumGet(SYSTEMTIME, 12, "UShort"), 8 : NumGet(SYSTEMTIME, 14, "UShort") }
}
; ===============================================================================================================================

GetSystemTime := GetSystemTime()

MsgBox % "GetSystemTime function`n"
       . "SYSTEMTIME structure`n`n"
       . "wYear:`t`t"                GetSystemTime[1]   "`n"
       . "wMonth:`t`t"               GetSystemTime[2]   "`n"
       . "wDayOfWeek:`t"             GetSystemTime[3]   "`n"
       . "wDay:`t`t"                 GetSystemTime[4]   "`n"
       . "wHour:`t`t"                GetSystemTime[5]   "`n"
       . "wMinute:`t`t"              GetSystemTime[6]   "`n"
       . "wSecond:`t`t"              GetSystemTime[7]   "`n"
       . "wMilliseconds:`t"          GetSystemTime[8]





/* C++ ==========================================================================================================================
void WINAPI GetSystemTime(                                                           // Ptr
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