/*
    OpenProcess function
    https://msdn.microsoft.com/en-us/library/windows/desktop/ms684320(v=vs.85).aspx
    PROCESS_VM_READ = 0x0010 | PROCESS_QUERY_INFORMATION = 0x0400
*/
GetAddressOfData(hProcess, Data, Size)
{
    ; SYSTEM_INFO structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724958(v=vs.85).aspx
    local SYSTEM_INFO := ""
    VarSetCapacity(SYSTEM_INFO, A_PtrSize == 4 ? 36 : 48)
    ; GetSystemInfo function
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724381(v=vs.85).aspx
    DllCall("Kernel32.dll\GetSystemInfo", "UPtr", &SYSTEM_INFO)
    local                   Address := NumGet(&SYSTEM_INFO + 8)                ; LPVOID lpMinimumApplicationAddress   (the lowest memory address accessible to applications and DLLs)
        , MaximumApplicationAddress := NumGet(&SYSTEM_INFO + 8 + A_PtrSize)    ; LPVOID lpMaximumApplicationAddress   (the highest memory address accessible to applications and DLLs)

    ; MEMORY_BASIC_INFORMATION structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366775(v=vs.85).aspx
    local sizeof_MEMORY_BASIC_INFORMATION := A_PtrSize == 4 ? 28 : 48
    VarSetCapacity(MEMORY_BASIC_INFORMATION, sizeof_MEMORY_BASIC_INFORMATION)

    local RegionSize := 0, State := 0, Protect := 0
    local Buffer := "", BytesRead := 0
    while (Address < MaximumApplicationAddress)
    {
        ; VirtualQueryEx function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa366907(v=vs.85).aspx
        if (DllCall("Kernel32.dll\VirtualQueryEx", "Ptr", hProcess, "UPtr", Address, "UPtr", &MEMORY_BASIC_INFORMATION, "UPtr", sizeof_MEMORY_BASIC_INFORMATION, "UPtr") == sizeof_MEMORY_BASIC_INFORMATION)
        {
            Address    := NumGet(&MEMORY_BASIC_INFORMATION)                            ; PVOID  BaseAddress    (base address of the region of pages)
          , RegionSize := NumGet(&MEMORY_BASIC_INFORMATION + 3*A_PtrSize)              ; SIZE_T RegionSize     (size of the region beginning at the base address in which all pages have identical attributes)
          , State      := NumGet(&MEMORY_BASIC_INFORMATION + 4*A_PtrSize, "UInt")      ; DWORD  State          (the state of the pages in the region)
          , Protect    := NumGet(&MEMORY_BASIC_INFORMATION + 4*A_PtrSize + 4, "UInt")  ; DWORD  Protect        (access protection of the pages in the region)

            if (State == 0x1000 && Protect == 0x04)    ; MEM_COMMIT = 0x1000 | PAGE_READWRITE = 0x04
            {
                ; ReadProcessMemory function
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680553(v=vs.85).aspx
                VarSetCapacity(Buffer, RegionSize)
                if (DllCall("Kernel32.dll\ReadProcessMemory", "Ptr", hProcess, "UPtr", Address, "UPtr", &Buffer, "UPtr", RegionSize, "UPtrP", BytesRead))
                {
                    loop (RegionSize-Size)
                    {
                        ; https://msdn.microsoft.com/es-es/library/zyaebf12.aspx
                        if (!DllCall("msvcrt.dll\memcmp", "UPtr", Data, "UPtr", &Buffer+A_Index, "UPtr", Size, "CDecl"))
                            return Address + A_Index
                    }
                }
            }
            Address += RegionSize
        }
    }

    Return FALSE
} ; https://www.codeproject.com/Articles/716227/Csharp-How-to-Scan-a-Process-Memory
