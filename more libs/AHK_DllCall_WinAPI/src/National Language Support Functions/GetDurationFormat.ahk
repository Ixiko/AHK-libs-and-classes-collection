; =================================================================================================
; Function......: GetDurationFormat
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: http://msdn.microsoft.com/en-us/library/windows/desktop/dd318091(v=vs.85).aspx
; =================================================================================================
GetDurationFormat(ullDuration, lpFormat := "d'd':hh:mm:ss")
{
    VarSetCapacity(lpDurationStr, 128, 0)
    DllCall("Kernel32.dll\GetDurationFormat"
	                     , "UInt",  0x400
                         , "UInt",  0
                         , "Ptr",   0
                         , "Int64", ullDuration * 10000000    ; Number of Seconds
                         , "WStr",  lpFormat
                         , "WStr",  lpDurationStr
                         , "Int",   64)
    return lpDurationStr
}
; ===================================================================================

MsgBox, % GetDurationFormat(421337) "`n"
        . GetDurationFormat(421337, "d:hh:mm:ss") "`n"
        . GetDurationFormat(4213.37, "hh:mm:ss:ff")





/* C++ ==============================================================================
int GetDurationFormat(                              // Int
    _In_       LCID Locale,                         // UInt
    _In_       DWORD dwFlags,                       // UInt
    _In_opt_   const SYSTEMTIME *lpDuration,        // Ptr
    _In_       ULONGLONG ullDuration,               // Int64
    _In_opt_   LPCWSTR lpFormat,                    // WStr
    _Out_opt_  LPWSTR lpDurationStr,                // WStr
    _In_       int cchDuration                      // Int
);
================================================================================== */