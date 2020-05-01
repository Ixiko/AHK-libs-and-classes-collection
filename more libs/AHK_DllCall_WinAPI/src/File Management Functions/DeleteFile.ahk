; ===============================================================================================================================
; Function......: DeleteFile
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: DeleteFileW (Unicode) and DeleteFileA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa363915.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa363915.aspx
; ===============================================================================================================================
DeleteFile(FileName)
{
    if !(DllCall("kernel32.dll\DeleteFile", "Str", FileName))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

DeleteFile("C:\Temp\TestFile.txt")





/* C++ ==========================================================================================================================
BOOL WINAPI DeleteFile(                                                              // UInt
    _In_  LPCTSTR lpFileName                                                         // Str
);
============================================================================================================================== */