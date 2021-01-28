/* Example
#NoEnv
SetBatchLines, -1

Gui, New
Gui, Margin, 20, 20
; Textfeld mit den Dimensionen der "GroupBox" erstellen
Gui, Add, Text, w400 h200 vGB hwndHGB BackGroundTrans Section
; Position holen, um den Titel später zentrieren zu können
GuiControlGet, GB, Pos
; "GroupBox" Rahmen im Textfeld erstellen
HBOX := GuiControlAddBox(HGB, "Green")
; Titel der "GroupBox" zentriert setzen
Gui, Add, Text, xs ys cGreen Center 0x200 vGBTI, % "  Titel  "
GuiControlGet, GBTI, Pos
X := GBX + ((GBW - GBTIW) // 2)
Y := GBTIY - (GBTIH // 2)
GuiControl, Move, GBTI, x%X% y%Y%
; Und ab dafür!
Gui, Add, StatusBar, , % "  Grüner Rahmen"
Gui, Show, , Falsche GroupBox
Sleep, 2000
; "GroupBox" Rahmen entfernen
GuiControlRemoveBox(HBOX)
SB_SetText("  Kein Rahmen")
Sleep, 2000
; Neuen "GroupBox" Rahmen hinzufügen
GuiControlAddBox(HGB, "Red")
SB_SetText("  Roter Rahmen")
Return

GuiClose:
ExitApp
*/


; ======================================================================================================================
; GuiControlAddBox(HCTL[, BC[, BW]]) - "GroupBox" Rahmen in einem Textfeld setzen
; Parameter:
;     HCTL  -  HWND des Textfeldes (Option hwndHCTL)
;     BC    -  Farbe des Rahmens als 6-stelliger RGB Hex-Wert oder HTML-Farbname (Standard: Schwarz)
;     BW    -  Stärke des Rahmens in Pixeln (Standard: 1)
; Rückgabewerte:
;     Im Erfolgsfall -  HWND des Rahmenfensters (wird benötigt, wenn der Rahmen später entfernt werden soll)
;     Im Fehlerfall  -  0
; ======================================================================================================================
GuiControlAddBox(HCTL, BC := "000000", BW := 1) {
   Static Counter := 0
   VarSetCapacity(RECT, 16, 0)
   If !DllCall("User32.dll\GetClientRect", "Ptr", HCTL, "Ptr", &RECT, "UInt")
   || !(HGUI := DllCall("User32.dll\GetParent", "Ptr", HCTL, "UPtr"))
      Return False
   DllCall("User32.dll\LockWindowUpdate", "Ptr", HGUI)
   GuiName := "GuiControlAddBoxGui" . (++Counter)
   W := NumGet(RECT,  8, "Int")
   H := NumGet(RECT, 12, "Int")
   X2 := W - BW
   Y2 := H - BW
   Gui, %GuiName%: -Caption +Disabled +parent%HCTL% +hwndHBOX
   Gui, %GuiName%: Margin, 0, 0
   Gui, %GuiName%: Color, %BC%
   WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %BW%-%BW% %X2%-%BW% %X2%-%Y2% %BW%-%Y2% %BW%-%BW%, ahk_id %HBOX%
   Gui, %GuiName%: Show, x0 y0 w%W% h%H%
   DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
   Return HBOX
}
; ======================================================================================================================
; GuiControlRemoveBox(HBOX) - "GroupBox" Rahmen entfernen
; Parameter:
;     HBOX  -  HWND des Textfeldes (wie von GuiControlAddBox() zurückgegeben)
; Rückgabewerte:
;     Im Erfolgsfall -  1
;     Im Fehlerfall  -  0
; ======================================================================================================================
GuiControlRemoveBox(HBOX) {
   If !(HGUI := DllCall("User32.dll\GetAncestor", "Ptr", HBOX, "UInt", 2, "UPtr"))
      Return False
   DllCall("User32.dll\LockWindowUpdate", "Ptr", HGUI)
   DllCall("User32.dll\DestroyWindow", "Ptr", HBOX)
   DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
   Return True
}