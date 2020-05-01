; ===============================================================================================================================
; Function......: SetPhysicalCursorPos
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/desktop/aa969465.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa969465.aspx
; ===============================================================================================================================
SetPhysicalCursorPos(X, Y)
{
    if !(DllCall("user32.dll\SetPhysicalCursorPos", "Int", X, "Int", Y))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

SetPhysicalCursorPos(750, 500)





/* C++ ==========================================================================================================================
BOOL WINAPI SetPhysicalCursorPos(                                                    // UInt
    _In_  int X,                                                                     // Int
    _In_  int Y                                                                      // Int
);
============================================================================================================================== */