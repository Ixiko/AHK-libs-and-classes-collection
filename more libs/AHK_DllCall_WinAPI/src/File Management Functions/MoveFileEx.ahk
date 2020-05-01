; ===============================================================================================================================
; Function......: MoveFileEx
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: MoveFileExW (Unicode) and MoveFileExA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa365240.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa365240.aspx
; ===============================================================================================================================
MoveFileEx(ExistingFileName, NewFileName, Flags)
{
    if !(DllCall("kernel32.dll\MoveFileEx", "Str", ExistingFileName, "Str", NewFileName, "UInt", Flags))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

MoveFileEx("C:\Temp\TestFile.txt", "C:\Temp\TestFile_MoveEx.txt", 2)





/* C++ ==========================================================================================================================
BOOL WINAPI MoveFileEx(                                                              // UInt
    _In_      LPCTSTR lpExistingFileName,                                            // Str
    _In_opt_  LPCTSTR lpNewFileName,                                                 // Str
    _In_      DWORD dwFlags                                                          // UInt
);
============================================================================================================================== */