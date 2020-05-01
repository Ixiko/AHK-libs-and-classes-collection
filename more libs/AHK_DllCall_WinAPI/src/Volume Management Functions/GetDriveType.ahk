; ===============================================================================================================================
; Function......: GetDriveType
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetDriveTypeW (Unicode) and GetDriveTypeA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364939.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364939.aspx
; ===============================================================================================================================
GetDriveType(path, convert := 0)
{
    static DriveType := { 0 : "DRIVE_UNKNOWN", 1 : "DRIVE_NO_ROOT_DIR", 2 : "DRIVE_REMOVABLE"
                    , 3 : "DRIVE_FIXED", 4 : "DRIVE_REMOTE", 5 : "DRIVE_CDROM", 6 : "DRIVE_RAMDISK" }
    ret := DllCall("kernel32.dll\GetDriveType", "Ptr", &path)
    return convert ? DriveType[ret] : ret
}
; ===============================================================================================================================

MsgBox % GetDriveType("C:\")           ; ==> 3
MsgBox % GetDriveType("C:\", 1)        ; ==> DRIVE_FIXED





/* C++ ==========================================================================================================================
UINT WINAPI GetDriveType(                                                            // UInt
    _In_opt_  LPCTSTR lpRootPathName                                                 // Ptr
);



0 = DRIVE_UNKNOWN        // The drive type cannot be determined.
1 = DRIVE_NO_ROOT_DIR    // The root path is invalid; for example, there is no volume mounted at the specified path.
2 = DRIVE_REMOVABLE      // The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
3 = DRIVE_FIXED          // The drive has fixed media; for example, a hard disk drive or flash drive.
4 = DRIVE_REMOTE         // The drive is a remote (network) drive.
5 = DRIVE_CDROM          // The drive is a CD-ROM drive.
6 = DRIVE_RAMDISK        // The drive is a RAM disk.
============================================================================================================================== */