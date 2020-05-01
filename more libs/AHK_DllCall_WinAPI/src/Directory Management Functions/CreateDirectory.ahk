; ===============================================================================================================================
; Function......: CreateDirectory
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: CreateDirectoryW (Unicode) and CreateDirectoryA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa363855.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa363855.aspx
; ===============================================================================================================================
CreateDirectory(PathName)
{
    if !(DllCall("kernel32.dll\CreateDirectory", "Str", PathName, "Ptr", 0))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

CreateDirectory("C:\Temp\Directory")





/* C++ ==========================================================================================================================
BOOL WINAPI CreateDirectory(                                                         // UInt
    _In_      LPCTSTR lpPathName,                                                    // Str
    _In_opt_  LPSECURITY_ATTRIBUTES lpSecurityAttributes                             // Ptr
);
============================================================================================================================== */