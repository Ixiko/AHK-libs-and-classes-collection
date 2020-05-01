; ===============================================================================================================================
; Function......: GetDiskFreeSpace
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetDiskFreeSpaceW (Unicode) and GetDiskFreeSpaceA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364935.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364935.aspx
; ===============================================================================================================================
GetDiskFreeSpace(path)
{
    if !(DllCall("kernel32.dll\GetDiskFreeSpace", "Str", path, "UInt*", sector, "UInt*", bytes, "UInt*", free, "UInt*", total))
        return DllCall("kernel32.dll\GetLastError")
    return (sector * bytes * free)
}
; ===============================================================================================================================

MsgBox % GetDiskFreeSpace("C:\") " Bytes`n"
       . Round(GetDiskFreeSpace("C:\") / 1024, 2) " KB`n"
       . Round(GetDiskFreeSpace("C:\") / 1024**2, 2) " MB`n"
       . Round(GetDiskFreeSpace("C:\") / 1024**3, 2) " GB"





/* C++ ==========================================================================================================================
BOOL WINAPI GetDiskFreeSpace(                                                        // UInt
    _In_   LPCTSTR lpRootPathName,                                                   // Str
    _Out_  LPDWORD lpSectorsPerCluster,                                              // UInt*
    _Out_  LPDWORD lpBytesPerSector,                                                 // UInt*
    _Out_  LPDWORD lpNumberOfFreeClusters,                                           // UInt*
    _Out_  LPDWORD lpTotalNumberOfClusters                                           // UInt*
);
============================================================================================================================== */