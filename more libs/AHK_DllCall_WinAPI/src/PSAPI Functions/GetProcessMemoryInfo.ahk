; =================================================================================================
; Function......: GetProcessMemoryInfo
; DLL...........: Kernel32.dll / Psapi.dll
; Library.......: Kernel32.lib / Psapi.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: http://msdn.microsoft.com/en-us/library/windows/desktop/ms683219(v=vs.85).aspx
; =================================================================================================
GetProcessMemoryInfo_PMCEX(PID)
{
    pu := ""
    hProcess := DllCall("Kernel32.dll\OpenProcess", "UInt", 0x001F0FFF, "UInt", 0, "UInt", PID)
    if (hProcess)
    {
        static PMCEX, size := (A_PtrSize = 8 ? 80 : 44), init := VarSetCapacity(PMCEX, size, 0) && NumPut(size, PMCEX)
        if (DllCall("Kernel32.dll\K32GetProcessMemoryInfo", "Ptr", hProcess, "UInt", &PMCEX, "UInt", size))
        {
            pu := {  1 : NumGet(PMCEX, 0, "UInt"),                         2 : NumGet(PMCEX, 4, "UInt")
                  ,  3 : NumGet(PMCEX, 8, "Ptr"),                          4 : NumGet(PMCEX, (A_PtrSize = 8 ? 16 : 12), "Ptr")
                  ,  5 : NumGet(PMCEX, (A_PtrSize = 8 ? 24 : 16), "Ptr"),  6 : NumGet(PMCEX, (A_PtrSize = 8 ? 32 : 20), "Ptr")
                  ,  7 : NumGet(PMCEX, (A_PtrSize = 8 ? 40 : 24), "Ptr"),  8 : NumGet(PMCEX, (A_PtrSize = 8 ? 48 : 28), "Ptr")
                  ,  9 : NumGet(PMCEX, (A_PtrSize = 8 ? 56 : 32), "Ptr"), 10 : NumGet(PMCEX, (A_PtrSize = 8 ? 64 : 36), "Ptr")
                  , 11 : NumGet(PMCEX, (A_PtrSize = 8 ? 72 : 40), "Ptr") }
        }
        DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess)
    }
    return pu
}
GetProcessMemoryInfo_PMC(PID)
{
    pu := ""
    hProcess := DllCall("Kernel32.dll\OpenProcess", "UInt", 0x001F0FFF, "UInt", 0, "UInt", PID)
    if (hProcess)
    {
        static PMC, size := (A_PtrSize = 8 ? 72 : 40), init := VarSetCapacity(PMC, size, 0) && NumPut(size, PMC)
        if (DllCall("Psapi.dll\GetProcessMemoryInfo", "Ptr", hProcess, "UInt", &PMC, "UInt", size))
        {
            pu := { 1 : NumGet(PMC, 0, "UInt"),                         2 : NumGet(PMC, 4, "UInt")
                  , 3 : NumGet(PMC, 8, "Ptr"),                          4 : NumGet(PMC, (A_PtrSize = 8 ? 16 : 12), "Ptr")
                  , 5 : NumGet(PMC, (A_PtrSize = 8 ? 24 : 16), "Ptr"),  6 : NumGet(PMC, (A_PtrSize = 8 ? 32 : 20), "Ptr")
                  , 7 : NumGet(PMC, (A_PtrSize = 8 ? 40 : 24), "Ptr"),  8 : NumGet(PMC, (A_PtrSize = 8 ? 48 : 28), "Ptr")
                  , 9 : NumGet(PMC, (A_PtrSize = 8 ? 56 : 32), "Ptr"), 10 : NumGet(PMC, (A_PtrSize = 8 ? 64 : 36), "Ptr") }
        }
        DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess)
    }
    return pu
}
; ===================================================================================

ownPID := DllCall("GetCurrentProcessId")
BuildVersion := DllCall("GetVersion") >> 16 & 0xffff

if (BuildVersion >= "7600") {
    GPMI := GetProcessMemoryInfo_PMCEX(ownPID)
    MsgBox, % "GetProcessMemoryInfo function`n"
            . "PROCESS_MEMORY_COUNTERS_EX structure`n`n"
            . "cb:`t`t`t`t"                         GPMI[1]  "`n"
            . "PageFaultCount:`t`t`t"               GPMI[2]  " bytes`n"
            . "PeakWorkingSetSize:`t`t`t"           GPMI[3]  " bytes`n"
            . "WorkingSetSize:`t`t`t"               GPMI[4]  " bytes`n"
            . "QuotaPeakPagedPoolUsage:`t`t"        GPMI[5]  " bytes`n"
            . "QuotaPagedPoolUsage:`t`t"            GPMI[6]  " bytes`n"
            . "QuotaPeakNonPagedPoolUsage:`t"       GPMI[7]  " bytes`n"
            . "QuotaNonPagedPoolUsage:`t`t"         GPMI[8]  " bytes`n"
            . "PagefileUsage:`t`t`t"                GPMI[9]  " bytes`n"
            . "PeakPagefileUsage:`t`t`t"            GPMI[10] " bytes`n"
            . "PrivateUsage:`t`t`t"                 GPMI[11] " bytes`n`n"
            . "BUILD: " BuildVersion " | PID: " ownPID "`n"
} else {
    GPMI := GetProcessMemoryInfo_PMC(ownPID)
    MsgBox, % "GetProcessMemoryInfo function`n"
            . "PROCESS_MEMORY_COUNTERS_EX structure`n`n"
            . "cb:`t`t`t`t"                         GPMI[1]  "`n"
            . "PageFaultCount:`t`t`t"               GPMI[2]  " bytes`n"
            . "PeakWorkingSetSize:`t`t"             GPMI[3]  " bytes`n"
            . "WorkingSetSize:`t`t`t"               GPMI[4]  " bytes`n"
            . "QuotaPeakPagedPoolUsage:`t`t"        GPMI[5]  " bytes`n"
            . "QuotaPagedPoolUsage:`t`t"            GPMI[6]  " bytes`n"
            . "QuotaPeakNonPagedPoolUsage:`t"       GPMI[7]  " bytes`n"
            . "QuotaNonPagedPoolUsage:`t`t"         GPMI[8]  " bytes`n"
            . "PagefileUsage:`t`t`t"                GPMI[9]  " bytes`n"
            . "PeakPagefileUsage:`t`t`t"            GPMI[10] " bytes`n`n"
            . "BUILD: " BuildVersion " | PID: " ownPID "`n"
}





/* C++ ==============================================================================
BOOL WINAPI GetProcessMemoryInfo(                          // UInt
    _In_   HANDLE Process,                                 // Ptr
    _Out_  PPROCESS_MEMORY_COUNTERS ppsmemCounters,        // UInt
    _In_   DWORD cb                                        // UInt
);


typedef struct _PROCESS_MEMORY_COUNTERS {
    DWORD  cb;                                             //  0 (40)   |  0 (72)          UInt
    DWORD  PageFaultCount;                                 //  4 =>   4 |  4 =>   4        UInt
    SIZE_T PeakWorkingSetSize;                             //  4 =>   8 |  8 =>   8        Ptr
    SIZE_T WorkingSetSize;                                 //  4 =>  12 |  8 =>  16        Ptr
    SIZE_T QuotaPeakPagedPoolUsage;                        //  4 =>  16 |  8 =>  24        Ptr
    SIZE_T QuotaPagedPoolUsage;                            //  4 =>  20 |  8 =>  32        Ptr
    SIZE_T QuotaPeakNonPagedPoolUsage;                     //  4 =>  24 |  8 =>  40        Ptr
    SIZE_T QuotaNonPagedPoolUsage;                         //  4 =>  28 |  8 =>  48        Ptr
    SIZE_T PagefileUsage;                                  //  4 =>  32 |  8 =>  56        Ptr
    SIZE_T PeakPagefileUsage;                              //  4 =>  36 |  8 =>  64        Ptr
} PROCESS_MEMORY_COUNTERS, *PPROCESS_MEMORY_COUNTERS;

typedef struct _PROCESS_MEMORY_COUNTERS_EX {
    DWORD  cb;                                             //  0 (44)   |  0 (80)          UInt
    DWORD  PageFaultCount;                                 //  4 =>   4 |  4 =>   4        UInt
    SIZE_T PeakWorkingSetSize;                             //  4 =>   8 |  8 =>   8        Ptr
    SIZE_T WorkingSetSize;                                 //  4 =>  12 |  8 =>  16        Ptr
    SIZE_T QuotaPeakPagedPoolUsage;                        //  4 =>  16 |  8 =>  24        Ptr
    SIZE_T QuotaPagedPoolUsage;                            //  4 =>  20 |  8 =>  32        Ptr
    SIZE_T QuotaPeakNonPagedPoolUsage;                     //  4 =>  24 |  8 =>  40        Ptr
    SIZE_T QuotaNonPagedPoolUsage;                         //  4 =>  28 |  8 =>  48        Ptr
    SIZE_T PagefileUsage;                                  //  4 =>  32 |  8 =>  56        Ptr
    SIZE_T PeakPagefileUsage;                              //  4 =>  36 |  8 =>  64        Ptr
    SIZE_T PrivateUsage;                                   //  4 =>  40 |  8 =>  72        Ptr
} PROCESS_MEMORY_COUNTERS_EX, *PPROCESS_MEMORY_COUNTERS_EX;
================================================================================== */