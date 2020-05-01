; ===============================================================================================================================
; Function......: MoveFile
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: MoveFileW (Unicode) and MoveFileA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/desktop/aa365239.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa365239.aspx
; ===============================================================================================================================
MoveFile(ExistingFileName, NewFileName)
{
    if !(DllCall("kernel32.dll\MoveFile", "Str", ExistingFileName, "Str", NewFileName))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

MoveFile("C:\Temp\TestFile.txt", "C:\Temp\TestFile_Move.txt")





/* C++ ==========================================================================================================================
BOOL WINAPI MoveFile(                                                                // UInt
    _In_  LPCTSTR lpExistingFileName,                                                // Str
    _In_  LPCTSTR lpNewFileName                                                      // Str
);
============================================================================================================================== */