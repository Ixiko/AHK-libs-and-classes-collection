; ===============================================================================================================================
; Function......: SetLocalTime
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724936.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724936.aspx
; ===============================================================================================================================
SetLocalTime(Year := 1601, Month := 1, DayOfWeek := 0, Day := 1, Hour := 0, Minute := 0, Second := 0, Milliseconds := 0)
{
    static VarSetCapacity(SYSTEMTIME, 16)
    , NumPut(Year,      SYSTEMTIME,  0, "UShort"), NumPut(Month,        SYSTEMTIME,  2, "UShort")
    , NumPut(DayOfWeek, SYSTEMTIME,  4, "UShort"), NumPut(Day,          SYSTEMTIME,  6, "UShort")
    , NumPut(Hour,      SYSTEMTIME,  8, "UShort"), NumPut(Minute,       SYSTEMTIME, 10, "UShort")
    , NumPut(Second,    SYSTEMTIME, 12, "UShort"), NumPut(Milliseconds, SYSTEMTIME, 14, "UShort")
    if !(DllCall("kernel32.dll\SetLocalTime", "Ptr", &SYSTEMTIME))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

SetLocalTime(2015, 1, 25, 7, 13, 37, 27, 724)





/* C++ ==========================================================================================================================
BOOL WINAPI SetLocalTime(                                                            // UInt
    _In_  const SYSTEMTIME *lpSystemTime                                             // Ptr        (16)
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