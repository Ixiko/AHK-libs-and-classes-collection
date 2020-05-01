; ===============================================================================================================================
; Function......: GetWindowsDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetWindowsDirectoryW (Unicode) and GetWindowsDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724454.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724454.aspx
; ===============================================================================================================================
GetWindowsDirectory()
{
    static size := VarSetCapacity(buf, 260, 0)
    if !(DllCall("kernel32.dll\GetWindowsDirectory", "Ptr", &buf, "UInt", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetWindowsDirectory()





/* C++ ==========================================================================================================================
UINT WINAPI GetWindowsDirectory(                                                     // UInt
    _Out_  LPTSTR lpBuffer,                                                          // Ptr (Str)
    _In_   UINT uSize                                                                // UInt
);
============================================================================================================================== */