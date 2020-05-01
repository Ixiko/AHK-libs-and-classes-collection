; ===============================================================================================================================
; Function......: GetDiskFreeSpaceEx
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetDiskFreeSpaceExW (Unicode) and GetDiskFreeSpaceExA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364937.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364937.aspx
; ===============================================================================================================================
GetDiskFreeSpaceEx(directory)
{
    static size := 8, init := VarSetCapacity(free, size, 0) && VarSetCapacity(total, size, 0) && VarSetCapacity(tfree, size, 0)
    if !(DllCall("kernel32.dll\GetDiskFreeSpaceEx", "Str", directory, "UInt64", &free, "UInt64", &total, "UInt64", &tfree))
        return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(free, 0, "UInt64"), 2 : NumGet(total, 0, "UInt64"), 3 : NumGet(tfree, 0, "UInt64") }
}
; ===============================================================================================================================

GetDiskFreeSpaceEx := GetDiskFreeSpaceEx("C:\")

MsgBox % "FreeBytesAvailable:`t`t"       GetDiskFreeSpaceEx[1]   " Bytes`n"
       . "TotalNumberOfBytes:`t"         GetDiskFreeSpaceEx[2]   " Bytes`n"
       . "TotalNumberOfFreeBytes:`t"     GetDiskFreeSpaceEx[3]   " Bytes"





/* C++ ==========================================================================================================================
BOOL WINAPI GetDiskFreeSpaceEx(                                                      // UInt
    _In_opt_   LPCTSTR lpDirectoryName,                                              // Str
    _Out_opt_  PULARGE_INTEGER lpFreeBytesAvailable,                                 // UInt64
    _Out_opt_  PULARGE_INTEGER lpTotalNumberOfBytes,                                 // UInt64
    _Out_opt_  PULARGE_INTEGER lpTotalNumberOfFreeBytes                              // UInt64
);
============================================================================================================================== */