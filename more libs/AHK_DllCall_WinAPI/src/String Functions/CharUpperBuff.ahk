; ===============================================================================================================================
; Function......: CharUpperBuff
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........: CharUpperBuffW (Unicode) and CharUpperBuffA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms647475.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms647475.aspx
; ===============================================================================================================================
CharUpperBuff(str, len)
{
    if (DllCall("user32.dll\CharUpperBuff", "Ptr", &str, "UInt", len) = len)
        return StrGet(&str)
}
; ===============================================================================================================================

MsgBox % CharUpperBuff("lower_to_upper", 5)





/* C++ ==========================================================================================================================
DWORD WINAPI CharUpperBuff(                                                          // UInt
    _Inout_  LPTSTR lpsz,                                                            // Str
    _In_     DWORD cchLength                                                         // UInt
);
============================================================================================================================== */