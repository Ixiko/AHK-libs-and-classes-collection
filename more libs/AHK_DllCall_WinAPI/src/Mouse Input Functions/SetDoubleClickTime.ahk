; ===============================================================================================================================
; Function......: SetDoubleClickTime
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms646263.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms646263.aspx
; ===============================================================================================================================
SetDoubleClickTime(Interval)
{
    if !(DllCall("user32.dll\SetDoubleClickTime", "UInt", Interval))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

SetDoubleClickTime(500)





/* C++ ==========================================================================================================================
BOOL WINAPI SetDoubleClickTime(                                                      // UInt
    _In_  UINT uInterval                                                             // UInt
);
============================================================================================================================== */