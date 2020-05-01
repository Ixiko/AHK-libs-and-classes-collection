; ===============================================================================================================================
; Function......: GetCursorPos
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms648390.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa969464.aspx
; ===============================================================================================================================
GetCursorPos()
{
    static POINT, init := VarSetCapacity(POINT, 8, 0) && NumPut(8, POINT, "Int")
    if !(DllCall("user32.dll\GetCursorPos", "Ptr", &POINT))
        return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(POINT, 0, "Int"), 2 : NumGet(POINT, 4, "Int") }
}
; ===============================================================================================================================

GetCursorPos := GetCursorPos()

MsgBox % "GetCursorPos function`n"
       . "POINT structure`n`n"
       . "x-coordinate:`t`t"    GetCursorPos[1] "`n"
       . "y-coordinate:`t`t"    GetCursorPos[2]





/* C++ ==========================================================================================================================
BOOL WINAPI GetCursorPos(                                                            // UInt
    _Out_  LPPOINT lpPoint                                                           // Ptr        (8)
);


typedef struct tagPOINT {
    LONG x;                                                                          // Int         4          =>   0
    LONG y;                                                                          // Int         4          =>   4
} POINT, *PPOINT;
============================================================================================================================== */