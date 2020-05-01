; ===============================================================================================================================
; Function......: CopyFile
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: CopyFileW (Unicode) and CopyFileA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa363851.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa363851.aspx
; ===============================================================================================================================
CopyFile(ExistingFileName, NewFileName, FailIfExists)
{
    if !(DllCall("kernel32.dll\CopyFile", "Str", ExistingFileName, "Str", NewFileName, "UInt", FailIfExists))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

CopyFile("C:\Temp\TestFile.txt", "C:\Temp\TestFile_Copy.txt", 0)





/* C++ ==========================================================================================================================
BOOL WINAPI CopyFile(                                                                // UInt
    _In_  LPCTSTR lpExistingFileName,                                                // Str
    _In_  LPCTSTR lpNewFileName,                                                     // Str
    _In_  BOOL bFailIfExists                                                         // UInt
);
============================================================================================================================== */