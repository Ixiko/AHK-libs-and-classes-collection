; ===============================================================================================================================
; Function......: GetFileSizeEx
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/windows/desktop/aa364957(v=vs.85).aspx
; ===============================================================================================================================
GetFileSizeEx(File)
{
    static FileSize, init := VarSetCapacity(FileSize, 1048576, 0)
    if ((hFile := DllCall("kernel32.dll\CreateFile", "Str", File, "UInt", 0x80000000, "UInt", 1, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0)) = -1 )
        return DllCall("kernel32.dll\GetLastError")
    if !(DllCall("kernel32.dll\GetFileSizeEx", "UInt", hFile, "UInt", &FileSize))
        return DllCall("kernel32.dll\GetLastError")
    FileSize := NumGet(FileSize, 0, "Int64*")
    DllCall("kernel32.dll\CloseHandle", "UInt", hFile)
    return FileSize
}
; ===============================================================================================================================

MsgBox % GetFileSizeEx("C:\Windows\notepad.exe") " Bytes"





/* C++ ==========================================================================================================================
BOOL WINAPI GetFileSizeEx(                                                           // UInt
    _In_   HANDLE hFile,                                                             // UInt
    _Out_  PLARGE_INTEGER lpFileSize                                                 // Int64*
);
============================================================================================================================== */