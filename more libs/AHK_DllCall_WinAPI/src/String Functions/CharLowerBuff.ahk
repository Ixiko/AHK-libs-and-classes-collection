; ===============================================================================================================================
; Function......: CharLowerBuff
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........: CharLowerBuffW (Unicode) and CharLowerBuffA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms647468.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms647468.aspx
; ===============================================================================================================================
CharLowerBuff(str, len)
{
    if (DllCall("user32.dll\CharLowerBuff", "Ptr", &str, "UInt", len) = len)
        return StrGet(&str)
}
; ===============================================================================================================================

MsgBox % CharLowerBuff("UPPER_TO_LOWER", 5)





/* C++ ==========================================================================================================================
DWORD WINAPI CharLowerBuff(                                                          // UInt
    _Inout_  LPTSTR lpsz,                                                            // Str
    _In_     DWORD cchLength                                                         // UInt
);
============================================================================================================================== */