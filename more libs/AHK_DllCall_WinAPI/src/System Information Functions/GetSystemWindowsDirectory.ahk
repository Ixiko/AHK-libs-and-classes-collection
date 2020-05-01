; ===============================================================================================================================
; Function......: GetSystemWindowsDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetSystemWindowsDirectoryW (Unicode) and GetSystemWindowsDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724403.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724403.aspx
; ===============================================================================================================================
GetSystemWindowsDirectory()
{
    static size := VarSetCapacity(buf, 260, 0)
    if !(DllCall("kernel32.dll\GetSystemWindowsDirectory", "Ptr", &buf, "UInt", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetSystemWindowsDirectory()





/* C++ ==========================================================================================================================
UINT WINAPI GetSystemWindowsDirectory(                                               // UInt
    _Out_  LPTSTR lpBuffer,                                                          // Ptr (Str)
    _In_   UINT uSize                                                                // UInt
);
============================================================================================================================== */