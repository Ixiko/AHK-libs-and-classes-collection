; ===============================================================================================================================
; Function......: GetTempPath
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetTempPathW (Unicode) and GetTempPathA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364992.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364992.aspx
; ===============================================================================================================================
GetTempPath()
{
    static len := 260 + 1, init := VarSetCapacity(buf, len * (A_IsUnicode ? 2 : 1))
    if !(DllCall("kernel32.dll\GetTempPath", "UInt", len, "Ptr", &buf))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf)
}
; ===============================================================================================================================

MsgBox % GetTempPath()





/* C++ ==========================================================================================================================
DWORD WINAPI GetTempPath(                                                            // UInt
    _In_   DWORD nBufferLength,                                                      // UInt
    _Out_  LPTSTR lpBuffer                                                           // Ptr
);
============================================================================================================================== */