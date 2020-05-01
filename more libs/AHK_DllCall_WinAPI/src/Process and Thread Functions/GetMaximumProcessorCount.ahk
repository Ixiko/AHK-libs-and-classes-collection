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
GetMaximumProcessorCount(GroupNumber)
{
    if !(ret := DllCall("kernel32.dll\GetMaximumProcessorCount", "UShort", GroupNumber))
        return DllCall("kernel32.dll\GetLastError")
    return ret
}
; ===============================================================================================================================

MsgBox % GetMaximumProcessorCount(0xffff)





/* C++ ==========================================================================================================================
DWORD GetMaximumProcessorCount(                                                      // UInt
    _In_  WORD GroupNumber                                                           // UShort
);
============================================================================================================================== */