; ===============================================================================================================================
; Function......: GetActiveProcessorCount
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/dd405485.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/dd405485.aspx
; ===============================================================================================================================
GetActiveProcessorCount(GroupNumber := 0xFFFF)
{
    if !(ret := DllCall("kernel32.dll\GetActiveProcessorCount", "UShort", GroupNumber))
        return DllCall("kernel32.dll\GetLastError")
    return ret
}
; ===============================================================================================================================

MsgBox % GetActiveProcessorCount()





/* C++ ==========================================================================================================================
DWORD GetActiveProcessorCount(                                                       // UInt
    _In_  WORD GroupNumber                                                           // UShort
);
============================================================================================================================== */