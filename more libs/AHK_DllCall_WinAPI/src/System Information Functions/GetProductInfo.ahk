; ===============================================================================================================================
; Function......: GetProductInfo
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms724358.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms724358.aspx
; ===============================================================================================================================
GetProductInfo(OSMaj, OSMin, SpMaj, SpMin)
{
    if !(DllCall("kernel32.dll\GetProductInfo", "UInt", OSMaj, "UInt", OSMin, "UInt", SpMaj, "UInt", SpMin, "UInt*", ProductType))
        return DllCall("kernel32.dll\GetLastError")
    return ProductType
}
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

GetVersionEx := GetVersionEx()

MsgBox % GetProductInfo(GetVersionEx[2], GetVersionEx[3], GetVersionEx[7], GetVersionEx[8])





/* C++ ==========================================================================================================================
BOOL WINAPI GetProductInfo(                                                          // UInt
    _In_   DWORD dwOSMajorVersion,                                                   // UInt
    _In_   DWORD dwOSMinorVersion,                                                   // UInt
    _In_   DWORD dwSpMajorVersion,                                                   // UInt
    _In_   DWORD dwSpMinorVersion,                                                   // UInt
    _Out_  PDWORD pdwReturnedProductType                                             // UInt*
);
============================================================================================================================== */