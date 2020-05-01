; ===============================================================================================================================
; Function......: SetCurrentDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: SetCurrentDirectoryW (Unicode) and SetCurrentDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa365530.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa365530.aspx
; ===============================================================================================================================
SetCurrentDirectory(PathName)
{
    if !(DllCall("kernel32.dll\SetCurrentDirectory", "Str", PathName))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

SetCurrentDirectory("C:\Temp\Directory")





/* C++ ==========================================================================================================================
BOOL WINAPI SetCurrentDirectory(                                                     // UInt
    _In_  LPCTSTR lpPathName                                                         // Str
);
============================================================================================================================== */