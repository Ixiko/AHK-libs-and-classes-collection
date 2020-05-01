; ===============================================================================================================================
; Function......: BlockInput
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms646290.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms646290.aspx
; ===============================================================================================================================
BlockInput(BlockIt := 0)
{
    if !(DllCall("user32.dll\BlockInput", "UInt", BlockIt))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

BlockInput(1)        ; Keyboard and Mouse input events are blocked.
Sleep 5000
BlockInput(0)        ; Keyboard and Mouse input events are unblocked.





/* C++ ==========================================================================================================================
BOOL WINAPI BlockInput(                                                              // UInt
    _In_  BOOL fBlockIt                                                              // UInt
);
============================================================================================================================== */