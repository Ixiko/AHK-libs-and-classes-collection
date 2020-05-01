; ===============================================================================================================================
; Function......: GetVersionEx
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetVersionExW (Unicode) and GetVersionExA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724451.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724451.aspx
; ===============================================================================================================================
GetVersionEx()
{
    static OSVEREX, init := VarSetCapacity(OSVEREX, 284, 0) && NumPut(284, OSVEREX, "UInt")
    if !(DllCall("kernel32.dll\GetVersionEx", "Ptr", &OSVEREX))
        return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(OSVEREX,   0, "UInt"  ),  2 : NumGet(OSVEREX,         4, "UInt"  )
           , 3 : NumGet(OSVEREX,   8, "UInt"  ),  4 : NumGet(OSVEREX,        12, "UInt"  )
           , 5 : NumGet(OSVEREX,  16, "UInt"  ),  6 : StrGet(&OSVEREX + 20, 128, "UTF-16")
           , 7 : NumGet(OSVEREX, 276, "UShort"),  8 : NumGet(OSVEREX,       278, "UShort")
           , 9 : NumGet(OSVEREX, 280, "UShort"), 10 : NumGet(OSVEREX,       282, "UChar" ) }
}
; ===============================================================================================================================

GetVersionEx := GetVersionEx()

MsgBox % "GetVersionEx function`n"
       . "OSVERSIONINFOEX structure`n`n"
       . "OSVersionInfoSize:`t`t"     GetVersionEx[1]   "`n"
       . "MajorVersion:`t`t"          GetVersionEx[2]   "`n"
       . "MinorVersion:`t`t"          GetVersionEx[3]   "`n"
       . "BuildNumber:`t`t"           GetVersionEx[4]   "`n"
       . "PlatformId:`t`t"            GetVersionEx[5]   "`n"
       . "CSDVersion:`t`t"            GetVersionEx[6]   "`n"
       . "ServicePackMajor:`t`t"      GetVersionEx[7]   "`n"
       . "ServicePackMinor:`t`t"      GetVersionEx[8]   "`n"
       . "SuiteMask:`t`t"             GetVersionEx[9]   "`n"
       . "ProductType:`t`t"           GetVersionEx[10]





/* C++ ==========================================================================================================================
BOOL WINAPI GetVersionEx(                                                            // UInt
    _Inout_  LPOSVERSIONINFO lpVersionInfo                                           // Ptr        (284)
);


typedef struct _OSVERSIONINFOEX {
    DWORD dwOSVersionInfoSize;                                                       // UInt        4          =>   0
    DWORD dwMajorVersion;                                                            // UInt        4          =>   4
    DWORD dwMinorVersion;                                                            // UInt        4          =>   8
    DWORD dwBuildNumber;                                                             // UInt        4          =>  12
    DWORD dwPlatformId;                                                              // UInt        4          =>  16
    TCHAR szCSDVersion[128];                                                         // UTF-16    128          => 128
    WORD  wServicePackMajor;                                                         // UShort      2          => 276
    WORD  wServicePackMinor;                                                         // UShort      2          => 278
    WORD  wSuiteMask;                                                                // UShort      2          => 280
    BYTE  wProductType;                                                              // UChar       2          => 282
    BYTE  wReserved;                                                                 // Reserved for future use.
} OSVERSIONINFOEX, *POSVERSIONINFOEX, *LPOSVERSIONINFOEX;
============================================================================================================================== */