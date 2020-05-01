; ===============================================================================================================================
; Function......: GetSystemWow64Directory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetSystemWow64DirectoryW (Unicode) and GetSystemWow64DirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724405.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724405.aspx
; ===============================================================================================================================
GetSystemWow64Directory()
{
    static size := VarSetCapacity(buf, 260, 0)
    if !(DllCall("kernel32.dll\GetSystemWow64Directory", "Ptr", &buf, "UInt", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetSystemWow64Directory()





/* C++ ==========================================================================================================================
UINT WINAPI GetSystemWow64Directory(                                                 // UInt
  _Out_  LPTSTR lpBuffer,                                                            // Ptr (Str)
  _In_   UINT uSize                                                                  // UInt
);
============================================================================================================================== */