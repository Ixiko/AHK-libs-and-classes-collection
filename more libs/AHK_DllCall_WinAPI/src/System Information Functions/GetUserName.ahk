; ===============================================================================================================================
; Function......: GetUserName
; DLL...........: Advapi32.dll
; Library.......: Advapi32.lib
; U/ANSI........: GetUserNameW (Unicode) and GetUserNameA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724432.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724432.aspx
; ===============================================================================================================================
GetUserName()
{
    static size := VarSetCapacity(buf, 256, 0) + 1
    if !(DllCall("advapi32.dll\GetUserName", "Ptr", &buf, "UInt*", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetUserName()





/* C++ ==========================================================================================================================
BOOL WINAPI GetUserName(                                                             // UInt
    _Out_    LPTSTR lpBuffer,                                                        // Ptr (Str)
    _Inout_  LPDWORD lpnSize                                                         // UInt*
);
============================================================================================================================== */