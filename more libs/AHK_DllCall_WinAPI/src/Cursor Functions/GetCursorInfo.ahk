; ===============================================================================================================================
; Function......: GetCursorInfo
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms648389.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms648389.aspx
; ===============================================================================================================================
GetCursorInfo()
{
    static PtrSize := A_PtrSize
    static CURSORINFO, size := 16 + PtrSize, init := VarSetCapacity(CURSORINFO, size, 0) && NumPut(size, CURSORINFO, "UInt")
    if !(DllCall("user32.dll\GetCursorInfo", "Ptr", &CURSORINFO))
        return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(CURSORINFO, 0, "UInt"), 2 : NumGet(CURSORINFO, 4, "UInt"), 3 : NumGet(CURSORINFO, 8, "Ptr")
           , 4 : NumGet(CURSORINFO, 8 + PtrSize, "Int"), 5 : NumGet(CURSORINFO, 12 + PtrSize, "Int") }
}
; ===============================================================================================================================

GetCursorInfo := GetCursorInfo()

MsgBox % "GetCursorInfo function`n"
       . "CURSORINFO structure`n"
       . "POINT structure`n`n"
       . "cbSize:`t`t`t"         GetCursorInfo[1]   "`n"
       . "flags:`t`t`t"          GetCursorInfo[2]   "`n"
       . "hCursor:`t`t`t"        GetCursorInfo[3]   "`n"
       . "x-coordinate:`t`t"     GetCursorInfo[4]   "`n"
       . "y-coordinate:`t`t"     GetCursorInfo[5]





/* C++ ==========================================================================================================================
BOOL WINAPI GetCursorInfo(                                                           // UInt
    _Inout_  PCURSORINFO pci                                                         // Ptr        (16 + A_PtrSize)
);


typedef struct {
    DWORD   cbSize;                                                                  // UInt        4          =>   0
    DWORD   flags;                                                                   // UInt        4          =>   4
    HCURSOR hCursor;                                                                 // Ptr         A_PtrSize  =>   8
    POINT   ptScreenPos;                                                             // ==> POINT
} CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

typedef struct tagPOINT {
    LONG x;                                                                          // Int         4          =>   8 + A_PtrSize
    LONG y;                                                                          // Int         4          =>  12 + A_PtrSize
} POINT, *PPOINT;
============================================================================================================================== */

/*

------------------------------------------------------------------------
| Element (Field) Name | Element Type | Element Width | Element Offset |
|----------------------------------------------------------------------|
| hProcess             | HANDLE       |             4 |              0 |
| hThread              | HANDLE       |             4 |              4 |
| dwProcessId          | DWORD        |             4 |              8 |
| dwThreadId           | DWORD        |             4 |             12 |
------------------------------------------------------------------------

*/