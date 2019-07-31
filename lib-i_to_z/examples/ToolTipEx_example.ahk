#NoEnv
#Persistent
SetBatchLines, -1
If !FileExist("wink.gif")
   UrlDownloadToFile, http://ahkscript.org/boards/images/smilies/icon_e_wink.gif, Wink.gif
HIL := IL_Create(1, 1, 0) ; large icons are only supported on Vista+
IL_Add(HIL, "Wink.gif", 0xFFFFFF, 1)
HICON := IL_EX_GetHICON(HIL, 1, 0)
CoordMode, Mouse, Screen
Menu, Tray, Tip, Press Esc to exit!
MouseGetPos, X, Y
HFONT := GetHFONT("s12", "Tahoma")
; ToolTip number 1 will follow the mouse
ToolTipEx(X . " - " . Y, , , , HFONT, "Black", "White")
; ToolTip number 2 will stay
ToolTipEx("Press Esc to exit!",  A_ScreenWidth // 2, A_ScreenHeight // 2, 2, HFONT, "White", "Navy", HICON, "S")
PX := "", PY := ""
Loop {
   MouseGetPos, X, Y
   If (PX <> X) || (PY <> Y)
      ToolTipEx(X . " - " . Y)
   PX := X, PY := Y
   Sleep, 10
}
Return
Esc::
ExitApp
; ======================================================================================================================
GetHFONT(Options := "", Name := "") {
   Gui, New
   Gui, Font, % Options, % Name
   Gui, Add, Text, +hwndHTX, Dummy
   HFONT := DllCall("User32.dll\SendMessage", "Ptr", HTX, "UInt", 0x31, "Ptr", 0, "Ptr", 0, "UPtr") ; WM_GETFONT
   Gui, Destroy
   Return HFONT
}
; ======================================================================================================================
; IL_EX -> http://ahkscript.org/boards/viewtopic.php?f=6&t=1273
IL_EX_GetHICON(ILID, Index, Styles := 0x20) {
   Return DllCall("ComCtl32.dll\ImageList_GetIcon", "Ptr", ILID, "Int", Index - 1, "UInt", Styles, "UPtr")
}
; ======================================================================================================================
#Include %A_ScriptDir%\..\ToolTipEx.ahk