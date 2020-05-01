; ===============================================================================================================================
; Function......: GetLastError
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms679360.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms679360.aspx
; ===============================================================================================================================
GetLastError()
{
    return DllCall("kernel32.dll\GetLastError")
}

; ===============================================================================================================================

MsgBox % DeleteFile("C:\Temp\TestFile.txt")

DeleteFile(FileName)
{
    if !(DllCall("kernel32.dll\DeleteFile", "Str", FileName))
        return GetLastError()
    return 1
}





/* C++ ==========================================================================================================================
DWORD WINAPI GetLastError(void);                                                     // UInt
============================================================================================================================== */