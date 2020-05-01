; ===============================================================================================================================
; Function......: GetSystemRegistryQuota
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724387.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724387.aspx
; ===============================================================================================================================
GetSystemRegistryQuota()
{
    if !(DllCall("kernel32.dll\GetSystemRegistryQuota", "UInt*", QuotaAllowed, "UInt*", QuotaUsed))
        return DllCall("kernel32.dll\GetLastError")
    return { 1: QuotaAllowed, 2 : QuotaUsed }
}
; ===============================================================================================================================

GetSystemRegistryQuota := GetSystemRegistryQuota()

MsgBox % "pdwQuotaAllowed:`t" GetSystemRegistryQuota[1] " bytes`n"
       . "pdwQuotaUsed:`t"    GetSystemRegistryQuota[2] " bytes"





/* C++ ==========================================================================================================================
BOOL WINAPI GetSystemRegistryQuota(                                                  // UInt
    _Out_opt_  PDWORD pdwQuotaAllowed,                                               // UInt*
    _Out_opt_  PDWORD pdwQuotaUsed                                                   // UInt*
);
============================================================================================================================== */