; ===============================================================================================================================
; Function......: GetUserNameEx
; DLL...........: Secur32.dll
; Library.......: Secur32.lib
; U/ANSI........: GetUserNameExW (Unicode) and GetUserNameExA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724435.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724435.aspx
; ===============================================================================================================================
GetUserNameEx(name := 2)
{
    static size := VarSetCapacity(buf, 1023, 0) + 1
    if !(DllCall("secur32.dll\GetUserNameEx", "UInt", name, "Ptr", &buf, "UInt*", size))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf, size, "UTF-16")
}
; ===============================================================================================================================

MsgBox % GetUserNameEx(2)





/* C++ ==========================================================================================================================
BOOLEAN WINAPI GetUserNameEx(                                                        // UChar
    _In_     EXTENDED_NAME_FORMAT NameFormat,                                        // UInt
    _Out_    LPTSTR lpNameBuffer,                                                    // Ptr (Str)
    _Inout_  PULONG lpnSize                                                          // UInt*
);



typedef enum  { 
    NameUnknown           = 0,
    NameFullyQualifiedDN  = 1,     (e.g. CN=Jeff Smith,OU=Users,DC=Engineering,DC=Microsoft,DC=Com)
    NameSamCompatible     = 2,     (e.g. Engineering\JSmith)
    NameDisplay           = 3,     (e.g. Jeff Smith)
    NameUniqueId          = 6,     (e.g. {4fa050f0-f561-11cf-bdd9-00aa003a77b6})
    NameCanonical         = 7,     (e.g. engineering.microsoft.com/software/someone)
    NameUserPrincipal     = 8,     (e.g. someone@example.com)
    NameCanonicalEx       = 9,     (e.g. engineering.microsoft.com/software\nJSmith)
    NameServicePrincipal  = 10,    (e.g. www/www.microsoft.com@microsoft.com)
    NameDnsDomain         = 12     The DNS domain name followed by a backward-slash and the SAM user name.
} EXTENDED_NAME_FORMAT, *PEXTENDED_NAME_FORMAT;
============================================================================================================================== */