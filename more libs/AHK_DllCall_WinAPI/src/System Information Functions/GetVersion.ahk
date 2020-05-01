; ===============================================================================================================================
; Function......: GetVersion
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724439.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724439.aspx
; ===============================================================================================================================
GetVersion()
{
    return { 1 : LOBYTE(LOWORD(DllCall("kernel32.dll\GetVersion")))
           , 2 : HIBYTE(LOWORD(DllCall("kernel32.dll\GetVersion")))
           , 3 : HIWORD(DllCall("kernel32.dll\GetVersion")) }
}
LOWORD(l)
{
    return l & 0xffff
}
HIWORD(l)
{
    return (l >> 16) & 0xffff
}
LOBYTE(w)
{
    return w & 0xff
}
HIBYTE(w)
{
    return (w >> 8) & 0xff
}
; ===============================================================================================================================

GetVersion := GetVersion()
MsgBox % "Major:`t"     GetVersion[1]   "`n"
       . "Minor:`t"     GetVersion[2]   "`n"
       . "Build:`t"     GetVersion[3]


MajorVersion := DllCall("kernel32.dll\GetVersion") & 0xff
MinorVersion := DllCall("kernel32.dll\GetVersion") >> 8 & 0xff
BuildVersion := DllCall("kernel32.dll\GetVersion") >> 16 & 0xffff

MsgBox % MajorVersion "." MinorVersion "." BuildVersion

MsgBox % ((GV := DllCall("kernel32.dll\GetVersion") & 0xFFFF) & 0xFF) (GV >> 8)
MsgBox % ((m := (b := DllCall("kernel32.dll\GetVersion")) & 0xFFFF) & 0xFF) "." (m >> 8) "." (b >> 16)





/* C++ ==========================================================================================================================
DWORD WINAPI GetVersion(void);                                                       // UInt


void main()
{
    DWORD dwVersion = 0;
    DWORD dwMajorVersion = 0;
    DWORD dwMinorVersion = 0;
    DWORD dwBuild = 0;

    dwVersion = GetVersion();

    // Get the Windows version.
    dwMajorVersion = (DWORD)(LOBYTE(LOWORD(dwVersion)));
    dwMinorVersion = (DWORD)(HIBYTE(LOWORD(dwVersion)));

    // Get the build number.
    if (dwVersion < 0x80000000)
        dwBuild = (DWORD)(HIWORD(dwVersion));

    printf("Version is %d.%d (%d)\n", dwMajorVersion, dwMinorVersion, dwBuild);
}
============================================================================================================================== */