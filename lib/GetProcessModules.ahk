; ===============================================================================================================================
; Get all modules loaded in a process.
; ===============================================================================================================================

GetProcessModules(ProcessID)
{
    if !(hProcess := DllCall("OpenProcess", "uint", 0x0410, "int", 0, "uint", ProcessID, "ptr"))
        throw Exception("OpenProcess failed", -1)
    if !(DllCall("psapi\EnumProcessModulesEx", "ptr", hProcess, "ptr", 0, "uint", 0, "uint*", size, "uint", 0x03))
        throw Exception("EnumProcessModulesEx failed", -1)
    cb := VarSetCapacity(hModule, size, 0)
    if !(DllCall("psapi\EnumProcessModulesEx", "ptr", hProcess, "ptr", &hModule, "uint", cb, "uint*", size, "uint", 0x03))
        throw Exception("EnumProcessModulesEx failed", -1)
    MODULES := []
    loop % size // A_PtrSize
    {
        size := VarSetCapacity(buf, 0x0104 << 1, 0)
        if !(DllCall("psapi\GetModuleFileNameEx", "ptr", hProcess, "ptr", NumGet(hModule, (A_Index - 1) * A_PtrSize, "ptr"), "ptr", &buf, "uint", size))
            throw Exception("GetModuleFileNameEx failed", -1)
        MODULES[A_Index] := StrGet(&buf)
    }
    return MODULES, DllCall("CloseHandle", "ptr", hProcess)
}

; ===============================================================================================================================

OwnPID := DllCall("GetCurrentProcessId")
for i, v in GetProcessModules(OwnPID)
    MsgBox % "Module #" i ":`n" v
; -> C:\Program Files\AutoHotkey\AutoHotkey.exe
; -> C:\Windows\SYSTEM32\ntdll.dll
; -> C:\Windows\System32\KERNEL32.DLL
; -> ...