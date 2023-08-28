; All things mouse cursor images - a2 standard lib
;
; I really like explicit code! All this DLLCall stuff is quite some voodoo and
; should go into a lib and not into scripts and tools. Some interesting links:
; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadcursora
;

cursor_set(target_id, system_id = 0) {
    if (system_id == 0)
        system_id := A_Cursor == "IBeam" ? 32513 : 32512
    DllCall("SetSystemCursor", "Uint", target_id, "Int", system_id)
}

cursor_set_cross() {
    win_cross := A_WinDir . "\cursors\" . "cross_rl.cur"
    IfExist, %win_cross%
        cursor_id := cursor_load_file(win_cross)
    Else
        cursor_id := cursor_load_id(IDC_CROSS)
    cursor_set(cursor_id)
}

cursor_reset() {
    ; Reset the system mouse cursor image.
    ; This used to be way more complicated. With changing the current image to a
    ; remembered one..? This all broke down as soon as one tried to more/resize a
    ; frozen window and the main loop got stuck.
    ; Well. This solves it pretty nicely! And it seems to be really fast!
    SPI_SETCURSORS := 0x57
    DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
}

cursor_load_id(cursor_id) {
    result_id := DllCall("LoadCursor", "UInt", NULL, "Int", cursor_id)
    Return result_id
}

cursor_load_file(path) {
    result_id := DllCall("LoadCursorFromFile", Str, path)
    return result_id
}
