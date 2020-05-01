; ===============================================================================================================================
; Function......: GetMaximumProcessorCount
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/dd405489.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/dd405489.aspx
; ===============================================================================================================================
GetMaximumProcessorCount(ProcessId := 0)
{
    if !(ret := DllCall("Kernel32.dll\GetMaximumProcessorCount", "UInt", ProcessId))
        return DllCall("kernel32.dll\GetLastError")
    return ret
}
; ===============================================================================================================================

MsgBox % GetMaximumProcessorCount()





/* C++ ==========================================================================================================================
DWORD WINAPI GetProcessVersion(                                                      // UInt
    _In_  DWORD ProcessId                                                            // UInt
);
============================================================================================================================== */