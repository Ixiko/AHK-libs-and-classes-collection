; ===============================================================================================================================
; Function......: GetComputerName
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetComputerNameW (Unicode) and GetComputerNameA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724295.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724295.aspx
; ===============================================================================================================================
GetComputerName()
{
    static size := 31 + 1 * (A_IsUnicode ? 2 : 1), init := VarSetCapacity(buf, size, 0)
    if !(DllCall("kernel32.dll\GetComputerName", "Ptr", &buf, "UInt*", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetComputerName()





/* C++ ==========================================================================================================================
BOOL WINAPI GetComputerName(                                                         // UInt
    _Out_    LPTSTR lpBuffer,                                                        // Ptr
    _Inout_  LPDWORD lpnSize                                                         // UInt*
);
============================================================================================================================== */