; =================================================================================================
; Function......: GetModuleFileNameEx
; DLL...........: Kernel32.dll / Psapi.dll
; Library.......: Kernel32.lib / Psapi.lib
; U/ANSI........: GetModuleFileNameExW (Unicode) and GetModuleFileNameExA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: http://msdn.microsoft.com/en-us/library/windows/desktop/ms683198(v=vs.85).aspx
; =================================================================================================
GetModuleFileNameEx(PID)
{
    hProcess := DllCall("Kernel32.dll\OpenProcess", "UInt", 0x001F0FFF, "UInt", 0, "UInt", PID)
    if (ErrorLevel || hProcess = 0)
        return
    static lpFilename, nSize := 260, int := VarSetCapacity(lpFilename, nSize, 0)
    DllCall("Psapi.dll\GetModuleFileNameEx", "Ptr", hProcess, "Ptr", 0, "Str", lpFilename, "UInt", nSize)
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hProcess)
    return lpFilename
}
; ===================================================================================

Current_PID := GetCurrentProcessId()
MsgBox, % GetModuleFileNameEx(Current_PID)

GetCurrentProcessId()
{
    return DllCall("Kernel32.dll\GetCurrentProcessId")
}





/* C++ ==============================================================================
DWORD WINAPI GetModuleFileNameEx(        // UInt
    _In_      HANDLE hProcess,           // Ptr
    _In_opt_  HMODULE hModule,           // Ptr
    _Out_     LPTSTR lpFilename,         // Str
    _In_      DWORD nSize                // UInt
);
================================================================================== */