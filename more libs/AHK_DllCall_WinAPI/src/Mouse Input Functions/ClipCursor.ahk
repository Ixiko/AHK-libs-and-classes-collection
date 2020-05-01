; ===============================================================================================================================
; Function......: ClipCursor
; DLL...........: User32.dll
; Library.......: User32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms648383.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms648383.aspx
; ===============================================================================================================================
ClipCursor(Confines := True, Left := 100, Top := 200, Right := 800, Bottom := 900)
{
    if !(Confines)
        return DllCall("user32.dll\ClipCursor")
    static RECT, init := VarSetCapacity(RECT, 16, 0)
    NumPut(Left, RECT, 0, "Int"), NumPut(Top, RECT, 4, "Int"), NumPut(Right, RECT, 8, "Int"), NumPut(Bottom, RECT, 12, "Int")
    if !(DllCall("user32.dll\ClipCursor", "Ptr", &RECT))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}
; ===============================================================================================================================

ClipCursor(True, 100, 200, 800, 900)    ; Confines the cursor to a rectangular area on the screen.
Sleep 5000
ClipCursor(False)                       ; Release the confines.





/* C++ ==========================================================================================================================
BOOL WINAPI ClipCursor(                                                              // UInt
    _In_opt_  const RECT *lpRect                                                     // Ptr
);


typedef struct _RECT {
    LONG left;                                                                       // Int         4          =>   0
    LONG top;                                                                        // Int         4          =>   4
    LONG right;                                                                      // Int         4          =>   8
    LONG bottom;                                                                     // Int         4          =>  12
} RECT, *PRECT;
============================================================================================================================== */