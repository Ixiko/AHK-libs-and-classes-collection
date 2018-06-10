; ===============================================================================================================================
; A Process Explorer / Taskmanager written in AutoHotkey
;
; EXPERIMENTAL - USE AT YOUR OWN RISK - TESTED WITH WIN10 64BIT
; ===============================================================================================================================

Class ProcessExplorer
{

    __New()
    {
        if !(this.hADVAPI := DllCall("LoadLibrary", "str", "advapi32.dll", "uptr"))
            throw Exception("LoadLibrary fails to load advapi32.dll: " A_LastError, -1)
        if !(this.hNTDLL  := DllCall("LoadLibrary", "str", "ntdll.dll",    "uptr"))
            throw Exception("LoadLibrary fails to load ntdll.dll: "    A_LastError, -1)
        if !(this.hPSAPI  := DllCall("LoadLibrary", "str", "psapi.dll",    "uptr"))
            throw Exception("LoadLibrary fails to load psapi.dll: "    A_LastError, -1)
        if !(this.hWTSAPI := DllCall("LoadLibrary", "str", "wtsapi32.dll", "uptr"))
            throw Exception("LoadLibrary fails to load wtsapi32.dll: " A_LastError, -1)
    }

    ; ===========================================================================================================================

    AdjustTokenPrivileges(hToken, LUID)                         ; https://msdn.microsoft.com/en-us/library/aa375202(v=vs.85).aspx
    {
        static SE_PRIVILEGE_ENABLED := 0x00000002
        VarSetCapacity(TOKEN_PRIVILEGES, 16, 0)
        NumPut(1,                    TOKEN_PRIVILEGES,  0, "uint")
        NumPut(LUID,                 TOKEN_PRIVILEGES,  4, "int64")
        NumPut(SE_PRIVILEGE_ENABLED, TOKEN_PRIVILEGES, 12, "uint")
        if (DllCall("advapi32\AdjustTokenPrivileges", "ptr", hToken, "int", true, "ptr", &TOKEN_PRIVILEGES, "uint", 0, "ptr", 0, "ptr", 0))
            return true
        return false
    }

    ; ===========================================================================================================================

    CloseHandle(hObject)                                        ; https://msdn.microsoft.com/en-us/library/ms724211(v=vs.85).aspx
    {
        if (DllCall("CloseHandle", "ptr", hObject))
            return true
        return false
    }

    ; ===========================================================================================================================

    GetDurationFormatEx(VarIn, Format := "hh:mm:ss.fff")        ; https://msdn.microsoft.com/en-us/library/dd318092(v=vs.85).aspx
    {
        static LocaleName := "!x-sys-default-locale"
        if (size := DllCall("GetDurationFormatEx", "ptr", &LocaleName, "uint", 0, "ptr", 0, "int64", VarIn, "str", Format, "ptr", 0, "int", 0)) {
            VarSetCapacity(buf, size << !!A_IsUnicode, 0)
            if (DllCall("GetDurationFormatEx", "ptr", &LocaleName, "uint", 0, "ptr", 0, "int64", VarIn, "str", Format, "str", buf, "int", size))
                return buf
        }
        return false
    }

    ; ===========================================================================================================================

    GetNumberFormatEx(VarIn)                                    ; https://msdn.microsoft.com/en-us/library/dd318113(v=vs.85).aspx
    {
        static LocaleName := "!x-sys-default-locale"
        if (size := DllCall("GetNumberFormatEx", "ptr", &LocaleName, "uint", 0, "ptr", &VarIn, "ptr", 0, "ptr", 0, "int", 0)) {
            VarSetCapacity(buf, size << 1, 0)
            if (DllCall("GetNumberFormatEx", "ptr", &LocaleName, "uint", 0, "ptr", &VarIn, "ptr", 0, "str", buf, "int", size))
                return SubStr(buf, 1, -3)
        }
        return false
    }

    ; ===========================================================================================================================

    GetPerformanceInfo()                                        ; https://msdn.microsoft.com/en-us/library/ms683210(v=vs.85).aspx
    {
        static buf, size := NumPut(VarSetCapacity(buf, 8 + (A_PtrSize * 12), 0), buf, "uint")
        if !(DllCall("GetPerformanceInfo", "ptr", &buf, "uint", size))
            if !(DllCall("psapi\GetPerformanceInfo", "ptr", &buf, "uint", size))
                return 0
        PERFORMANCE_INFORMATION := {}
        PERFORMANCE_INFORMATION.HandleCount  := NumGet(buf, (A_PtrSize * 11), "uint")
        PERFORMANCE_INFORMATION.ProcessCount := NumGet(buf, (A_PtrSize * 11) + 4, "uint")
        PERFORMANCE_INFORMATION.ThreadCount  := NumGet(buf, (A_PtrSize * 11) + 8, "uint")
        return PERFORMANCE_INFORMATION
    }

    ; ===========================================================================================================================

    GetProcessMemoryInfo(ProcessID)                             ; https://msdn.microsoft.com/en-us/library/ms683219(v=vs.85).aspx
    {
        static buf, size := NumPut(VarSetCapacity(buf, 8 + (A_PtrSize * 9), 0), buf, "uint")
        hProcess := this.OpenProcess(ProcessID, 0x0410)
        if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &buf, "uint", size))
            if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &buf, "uint", size))
                return 0
        PROCESS_MEMORY_COUNTERS_EX := {}
        PROCESS_MEMORY_COUNTERS_EX.PageFaultCount             := NumGet(buf, 4, "uint")
        PROCESS_MEMORY_COUNTERS_EX.PeakWorkingSetSize         := this.GetNumberFormatEx(Round(NumGet(buf, 8, "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.WorkingSetSize             := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 1), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.QuotaPeakPagedPoolUsage    := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 2), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.QuotaPagedPoolUsage        := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 3), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.QuotaPeakNonPagedPoolUsage := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 4), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.QuotaNonPagedPoolUsage     := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 5), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.PagefileUsage              := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 6), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.PeakPagefileUsage          := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 7), "uptr") / 1024))
        PROCESS_MEMORY_COUNTERS_EX.PrivateUsage               := this.GetNumberFormatEx(Round(NumGet(buf, 8 + (A_PtrSize * 8), "uptr") / 1024))
        return PROCESS_MEMORY_COUNTERS_EX, this.CloseHandle(hProcess)
    }

    ; ===========================================================================================================================

    GetTickCount64()                                            ; https://msdn.microsoft.com/en-us/library/ms724411(v=vs.85).aspx
    {
        return this.GetDurationFormatEx(DllCall("GetTickCount64", "uint64") * 10000, "d:hh:mm:ss")
    }

    ; ===========================================================================================================================

    GlobalMemoryStatusEx()                                      ; https://msdn.microsoft.com/en-us/library/aa366589(v=vs.85).aspx
    {
        static buf, size := NumPut(VarSetCapacity(buf, 64, 0), buf, "uint")
        if !(DllCall("GlobalMemoryStatusEx", "ptr", &buf))
            return 0
        MEMORYSTATUSEX := {}
        MEMORYSTATUSEX.MemoryLoad           := NumGet(buf,  4, "uint")
        MEMORYSTATUSEX.TotalPhys            := NumGet(buf,  8, "uint64")
        MEMORYSTATUSEX.AvailPhys            := NumGet(buf, 16, "uint64")
        MEMORYSTATUSEX.TotalPageFile        := NumGet(buf, 24, "uint64")
        MEMORYSTATUSEX.AvailPageFile        := NumGet(buf, 32, "uint64")
        MEMORYSTATUSEX.TotalVirtual         := NumGet(buf, 40, "uint64")
        MEMORYSTATUSEX.AvailVirtual         := NumGet(buf, 48, "uint64")
        MEMORYSTATUSEX.AvailExtendedVirtual := NumGet(buf, 56, "uint64")
        return MEMORYSTATUSEX
    }

    ; ===========================================================================================================================

    LookupAccountSid(SID)                                       ; https://msdn.microsoft.com/en-us/library/aa379166(v=vs.85).aspx
    {
        DllCall("advapi32\LookupAccountSid", "ptr", 0, "ptr", SID, "ptr", 0, "uint*", SizeName, "ptr", 0, "uint*", SizeDomainName, "uint*", SID_NAME_USE)
        VarSetCapacity(Name,       SizeName       << !!A_IsUnicode, 0)
        VarSetCapacity(DomainName, SizeDomainName << !!A_IsUnicode, 0)
        if (DllCall("advapi32\LookupAccountSid", "ptr", 0, "ptr", SID, "str", Name, "uint*", SizeName, "str", DomainName, "uint*", SizeDomainName, "uint*", SID_NAME_USE))
            return { Name: Name, Domain: DomainName }
        return false
    }

    ; ===========================================================================================================================

    LookupPrivilegeValue(Privilege)                             ; https://msdn.microsoft.com/en-us/library/aa379180(v=vs.85).aspx
    {
        if (DllCall("advapi32\LookupPrivilegeValue", "ptr", 0, "str", Privilege, "int64*", LUID))
            return LUID
        return false
    }

    ; ===========================================================================================================================

    OpenProcess(ProcessID, Access)                              ; https://msdn.microsoft.com/en-us/library/ms684320(v=vs.85).aspx
    {
        if (hProcess := DllCall("OpenProcess", "uint", Access, "int", 0, "uint", ProcessID, "ptr"))
            return hProcess
        return false
    }

    ; ===========================================================================================================================

    OpenProcessToken(hProcess, Access)                          ; https://msdn.microsoft.com/en-us/library/aa379295(v=vs.85).aspx
    {
        if (DllCall("advapi32\OpenProcessToken", "ptr", hProcess, "uint", Access, "ptr*", hToken))
            return hToken
        return false
    }

    ; ===========================================================================================================================

    SetDebugPrivilege()
    {
        static PROCESS_QUERY_INFORMATION := 0x0400, TOKEN_ADJUST_PRIVILEGES := 0x0020
        if (hProcess := this.OpenProcess(DllCall("GetCurrentProcessId"), PROCESS_QUERY_INFORMATION)) {
            if (hToken := this.OpenProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES)) {
                if (LUID := this.LookupPrivilegeValue("SeDebugPrivilege")) {
                    if (this.AdjustTokenPrivileges(hToken, LUID))
                        return true, this.CloseHandle(hToken) && this.CloseHandle(hProcess)
                }
                this.CloseHandle(hToken)
            }
            this.CloseHandle(hProcess)
        }
        return false
    }

    ; ===========================================================================================================================

    WTSEnumerateProcessesEx()                                   ; https://msdn.microsoft.com/en-us/library/ee621013(v=vs.85).aspx
    {
        if (DllCall("wtsapi32\WTSEnumerateProcessesEx", "ptr", 0, "uint*", 1, "uint", 0xFFFFFFFE, "ptr*", buf, "uint*", TTL)) {
            addr := buf, WTS_PROCESS_INFO_EX := []
            loop % TTL {
                WTS_PROCESS_INFO_EX[A_Index, "SessionId"]          := NumGet(addr + 0, "uint")
                WTS_PROCESS_INFO_EX[A_Index, "ProcessId"]          := NumGet(addr + 4, "uint")
                WTS_PROCESS_INFO_EX[A_Index, "ProcessName"]        := StrGet(NumGet(addr + 8, "ptr"))
                WTS_PROCESS_INFO_EX[A_Index, "UserSid"]            := SID := NumGet(addr + 8 + (A_PtrSize), "ptr")
                                                                      LAS := this.LookupAccountSid(SID)
                WTS_PROCESS_INFO_EX[A_Index, "UserName"]           := Las.Name
                WTS_PROCESS_INFO_EX[A_Index, "DomainName"]         := Las.Domain
                WTS_PROCESS_INFO_EX[A_Index, "NumberOfThreads"]    := NumGet(addr +  8 + (A_PtrSize * 2), "uint")
                WTS_PROCESS_INFO_EX[A_Index, "HandleCount"]        := NumGet(addr + 12 + (A_PtrSize * 2), "uint")
                WTS_PROCESS_INFO_EX[A_Index, "PagefileUsage"]      := this.GetNumberFormatEx(Round(NumGet(addr + 16 + (A_PtrSize * 2), "uint") / 1024))
                WTS_PROCESS_INFO_EX[A_Index, "PeakPagefileUsage"]  := this.GetNumberFormatEx(Round(NumGet(addr + 20 + (A_PtrSize * 2), "uint") / 1024))
                WTS_PROCESS_INFO_EX[A_Index, "WorkingSetSize"]     := this.GetNumberFormatEx(Round(NumGet(addr + 24 + (A_PtrSize * 2), "uint") / 1024))
                WTS_PROCESS_INFO_EX[A_Index, "PeakWorkingSetSize"] := this.GetNumberFormatEx(Round(NumGet(addr + 28 + (A_PtrSize * 2), "uint") / 1024))
                WTS_PROCESS_INFO_EX[A_Index, "UserTime"]           := this.GetDurationFormatEx(NumGet(addr + 32 + (A_PtrSize * 2), "int64"))
                WTS_PROCESS_INFO_EX[A_Index, "KernelTime"]         := this.GetDurationFormatEx(NumGet(addr + 40 + (A_PtrSize * 2), "int64"))
                addr += 48 + (A_PtrSize * 2)
            }
            return WTS_PROCESS_INFO_EX, this.WTSFreeMemoryEx(buf, TTL)
        }
        return false
    }

    ; ===========================================================================================================================

    WTSFreeMemoryEx(Memory, NumberOfEntries)                    ; https://msdn.microsoft.com/en-us/library/ee621015(v=vs.85).aspx
    {
        static WTS_TYPE_CLASS := 1
        if (DllCall("wtsapi32\WTSFreeMemoryEx", "int", WTS_TYPE_CLASS, "ptr", Memory, "uint", NumberOfEntries))
            return true
        return false
    }

    ; ===========================================================================================================================

    __Delete()
    {
        if (this.hWTSAPI)
            DllCall("FreeLibrary", "ptr", this.hWTSAPI)
        if (this.hPSAPI)
            DllCall("FreeLibrary", "ptr", this.hPSAPI)
        if (this.hNTDLL)
            DllCall("FreeLibrary", "ptr", this.hNTDLL)
        if (this.hADVAPI)
            DllCall("FreeLibrary", "ptr", this.hADVAPI)
    }
}

; ===============================================================================================================================