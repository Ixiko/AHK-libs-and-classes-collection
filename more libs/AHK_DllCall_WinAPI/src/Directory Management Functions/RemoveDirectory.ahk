; ===============================================================================================================================
; Function......: RemoveDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: RemoveDirectoryW (Unicode) and RemoveDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa365488.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa365488.aspx
; ===============================================================================================================================
RemoveDirectory(PathName)
{
    if !(DllCall("kernel32.dll\RemoveDirectory", "Str", PathName))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

RemoveDirectory("C:\Temp\Directory")





/* C++ ==========================================================================================================================
BOOL WINAPI RemoveDirectory(                                                         // UInt
    _In_  LPCTSTR lpPathName                                                         // Str
);
============================================================================================================================== */