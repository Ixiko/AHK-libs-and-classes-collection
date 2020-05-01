; ===============================================================================================================================
; Function......: GetMaximumProcessorGroupCount
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/dd405490.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/dd405490.aspx
; ===============================================================================================================================
GetMaximumProcessorGroupCount()
{
    if !(ret := DllCall("kernel32.dll\GetMaximumProcessorGroupCount"))
        return DllCall("kernel32.dll\GetLastError")
    return ret
}
; ===============================================================================================================================

MsgBox % GetMaximumProcessorGroupCount()





/* C++ ==========================================================================================================================
WORD GetMaximumProcessorGroupCount(void);                                            // UShort
============================================================================================================================== */