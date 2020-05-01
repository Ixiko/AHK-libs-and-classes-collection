; ===============================================================================================================================
; Function......: GetFileSize
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364955.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364955.aspx
; ===============================================================================================================================
GetFileSize(File)
{
    if ((hFile := DllCall("kernel32.dll\CreateFile", "Str", File, "UInt", 0x80000000, "UInt", 1, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0)) = -1 )
        return DllCall("kernel32.dll\GetLastError")
    if !(ret := DllCall("kernel32.dll\GetFileSize", "UInt", hFile, "Ptr", 0))
        return DllCall("kernel32.dll\GetLastError")
    DllCall("kernel32.dll\CloseHandle", "UInt", hFile)
    return ret
}
; ===============================================================================================================================

MsgBox % GetFileSize("C:\Windows\Notepad.exe") " Bytes"





/* C++ ==========================================================================================================================
DWORD WINAPI GetFileSize(                                                            // UInt
    _In_       HANDLE hFile,                                                         // UInt
    _Out_opt_  LPDWORD lpFileSizeHigh                                                // Ptr
);
============================================================================================================================== */