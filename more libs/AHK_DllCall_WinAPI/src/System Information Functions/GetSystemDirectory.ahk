; ===============================================================================================================================
; Function......: GetSystemDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetSystemDirectoryW (Unicode) and GetSystemDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724373.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724373.aspx
; ===============================================================================================================================
GetSystemDirectory()
{
    static size := VarSetCapacity(buf, 260, 0)
    if !(DllCall("kernel32.dll\GetSystemDirectory", "Ptr", &buf, "UInt", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetSystemDirectory()





/* C++ ==========================================================================================================================
UINT WINAPI GetSystemDirectory(                                                      // UInt
    _Out_  LPTSTR lpBuffer,                                                          // Ptr (Str)
    _In_   UINT uSize                                                                // UInt
);
============================================================================================================================== */