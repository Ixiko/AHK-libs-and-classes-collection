; ===============================================================================================================================
; Function......: GetActiveProcessorGroupCount
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/dd405486.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/dd405486.aspx
; ===============================================================================================================================
GetActiveProcessorGroupCount()
{
    if !(ret := DllCall("kernel32.dll\GetActiveProcessorGroupCount"))
        return DllCall("kernel32.dll\GetLastError")
    return ret
}
; ===============================================================================================================================

MsgBox % GetActiveProcessorGroupCount()





/* C++ ==========================================================================================================================
WORD GetActiveProcessorGroupCount(void);                                             // UShort
============================================================================================================================== */