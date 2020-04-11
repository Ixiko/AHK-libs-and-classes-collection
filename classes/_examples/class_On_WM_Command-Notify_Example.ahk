#NoEnv
#Include %A_ScriptDir%\..\Class_On_WM_COMMAND.ahk
#Include %A_ScriptDir%\..\Class_On_WM_NOTIFY.ahk
SetBatchLines, -1

EN_SETFOCUS    := 0x0100
EN_KILLFOCUS   := 0x0200
EN_UPDATE      := 0x0400
NM_SETFOCUS    := -7
NM_KILLFOCUS   := -8
WM_NOTIFY      := 0x004E
WM_COMMAND     := 0x0111

Gui, Margin, 20, 20
Gui, Add, Text, xm w300, Edit:
Gui, Add, Edit, xm y+2 wp r5 vVEDIT hwndHEDIT
Gui, Add, Text, xm wp, LV:
Gui, Add, ListView, xm y+2 r5 wp Grid vLVV hwndHLV, Column1
LV_Add("", "Row 1")
LV_ModifyCol(1, "AutoHdr")
Gui, Add, Text, xm wp, Focus:
Gui, Add, Edit, xm y+2 wp vVEDIT1,
Gui, Add, Text, xm wp, EN_UPDATE notifications:
Gui, Add, Edit, xm y+2 wp vVEDIT2
Gui, Add, Button, xm wp vVBUTTON gGBUTTON, Unregister EN_UPDATE
Gui, Show, , Notifications
On_WM_COMMAND.Attach(HEDIT, EN_KILLFOCUS, "On_EN_KILLFOCUS")
On_WM_COMMAND.Attach(HEDIT, EN_SETFOCUS, "On_EN_SETFOCUS")
On_WM_COMMAND.Attach(HEDIT, EN_UPDATE, "On_EN_UPDATE")
On_WM_NOTIFY.Attach(HLV, NM_KILLFOCUS, "On_LV_KILLFOCUS" )
On_WM_NOTIFY.Attach(HLV, NM_SETFOCUS, "On_LV_SETFOCUS" )
GuiControl, Focus, VBUTTON
GuiControl, Focus, VEDIT
Return

GuiClose:
GuiEscape:
ExitApp

GBUTTON:
   GuiControlGet, Cap, , VBUTTON, Text
   If (Cap = "Unregister EN_UPDATE") {
      On_WM_COMMAND.Detach(HEDIT, EN_UPDATE)
      GuiControl, , VBUTTON, Register EN_UPDATE
   } ELse {
      On_WM_COMMAND.Attach(HEDIT, EN_UPDATE, "On_EN_UPDATE")
      GuiControl, , VBUTTON, Unregister EN_UPDATE
   }
Return
; ======================================================================================================================
On_EN_KILLFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, cC00000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, Edit lost focus!
}
On_EN_SETFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, c008000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, Edit got focus!
}
On_EN_UPDATE(Hwnd, Message, wParam, lParam) {
   Static I := 0
   I++
   GuiControl, , VEDIT2, %A_ThisFunc% was called %I% times.
}
On_LV_KILLFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, cC00000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, LV lost focus!
}
On_LV_SETFOCUS(Hwnd, Message, wParam, lParam) {
   Gui, Font, c008000
   GuiControl, Font, VEDIT1
   GuiControl, , VEDIT1, LV got focus!
}
; ======================================================================================================================