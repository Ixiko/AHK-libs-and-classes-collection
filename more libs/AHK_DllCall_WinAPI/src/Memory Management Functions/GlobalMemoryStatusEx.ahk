; ===============================================================================================================================
; Function......: GlobalMemoryStatusEx
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/desktop/aa366589.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa366589.aspx
; ===============================================================================================================================
GlobalMemoryStatusEx()
{
    static MEMORYSTATUSEX, init := VarSetCapacity(MEMORYSTATUSEX, 64, 0) && NumPut(64, MEMORYSTATUSEX, "UInt")
    if !(DllCall("kernel32.dll\GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX))
		return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(MEMORYSTATUSEX,  0, "UInt"),   2 : NumGet(MEMORYSTATUSEX,  4, "UInt")
           , 3 : NumGet(MEMORYSTATUSEX,  8, "UInt64"), 4 : NumGet(MEMORYSTATUSEX, 16, "UInt64")
           , 5 : NumGet(MEMORYSTATUSEX, 24, "UInt64"), 6 : NumGet(MEMORYSTATUSEX, 32, "UInt64")
           , 7 : NumGet(MEMORYSTATUSEX, 40, "UInt64"), 8 : NumGet(MEMORYSTATUSEX, 48, "UInt64")
           , 9 : NumGet(MEMORYSTATUSEX, 56, "UInt64") }
}
; ===============================================================================================================================

GlobalMemoryStatusEx := GlobalMemoryStatusEx()

MsgBox, % "GlobalMemoryStatusEx function`n"
        . "MEMORYSTATUSEX structure`n`n"
        . "Lenght:`t`t`t"                 GlobalMemoryStatusEx[1]   "`n`n"
        . "MemoryLoad:`t`t"               GlobalMemoryStatusEx[2]   " %`n`n"
        . "TotalPhys:`t`t`t"              GlobalMemoryStatusEx[3]   " bytes`n"
        . "AvailPhys:`t`t`t"              GlobalMemoryStatusEx[4]   " bytes`n`n"
        . "TotalPageFile:`t`t"            GlobalMemoryStatusEx[5]   " bytes`n"
        . "AvailPageFile:`t`t"            GlobalMemoryStatusEx[6]   " bytes`n`n"
        . "TotalVirtual:`t`t"             GlobalMemoryStatusEx[7]   " bytes`n"
        . "AvailVirtual:`t`t"             GlobalMemoryStatusEx[8]   " bytes`n`n"
        . "AvailExtendedVirtual:`t`t"     GlobalMemoryStatusEx[9]





/* C++ ==========================================================================================================================
BOOL WINAPI GlobalMemoryStatusEx(                                                    // UInt
    _Inout_  LPMEMORYSTATUSEX lpBuffer                                               // Ptr        (64)
);


typedef struct _MEMORYSTATUSEX {
    DWORD     dwLength;                                                              // UInt        4          =>   0
    DWORD     dwMemoryLoad;                                                          // UInt        4          =>   4
    DWORDLONG ullTotalPhys;                                                          // UInt64      8          =>   8
    DWORDLONG ullAvailPhys;                                                          // UInt64      8          =>  16
    DWORDLONG ullTotalPageFile;                                                      // UInt64      8          =>  24
    DWORDLONG ullAvailPageFile;                                                      // UInt64      8          =>  32
    DWORDLONG ullTotalVirtual;                                                       // UInt64      8          =>  40
    DWORDLONG ullAvailVirtual;                                                       // UInt64      8          =>  48
    DWORDLONG ullAvailExtendedVirtual;                                               // UInt64      8          =>  56
} MEMORYSTATUSEX, *LPMEMORYSTATUSEX;
============================================================================================================================== */