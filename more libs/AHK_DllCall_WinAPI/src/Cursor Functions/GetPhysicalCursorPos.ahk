; ===============================================================================================================================
; Function......: GetPhysicalCursorPos
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa969464.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa969464.aspx
; ===============================================================================================================================
GetPhysicalCursorPos()
{
    static POINT, init := VarSetCapacity(POINT, 8, 0) && NumPut(8, POINT, "Int")
    if !(DllCall("user32.dll\GetPhysicalCursorPos", "Ptr", &POINT))
        return DllCall("kernel32.dll\GetLastError")
    return { 1 : NumGet(POINT, 0, "Int"), 2 : NumGet(POINT, 4, "Int") }
}
; ===============================================================================================================================

GetPhysicalCursorPos := GetPhysicalCursorPos()

MsgBox % "GetPhysicalCursorPos function`n"
       . "POINT structure`n`n"
       . "x-coordinate:`t`t"    GetPhysicalCursorPos[1]   "`n"
       . "y-coordinate:`t`t"    GetPhysicalCursorPos[2]





/* C++ ==========================================================================================================================
BOOL WINAPI GetPhysicalCursorPos(                                                    // UInt
    _Out_  LPPOINT lpPoint                                                           // Ptr        (8)
);


typedef struct tagPOINT {
    LONG x;                                                                          // Int         4          =>   0
    LONG y;                                                                          // Int         4          =>   4
} POINT, *PPOINT;
============================================================================================================================== */