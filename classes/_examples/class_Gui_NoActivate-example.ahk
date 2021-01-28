; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

Gui, +AlwaysOnTop +HwndhGui
Gui, Add, Button,    w150 gSendChr, a
Gui, Add, Button, ys wp   gSendChr, h
Gui, Add, Button, ys wp   gSendChr, k
Gui, Show, NA, On Screen Keyboard Demo
Gui_NoActivate(hGui)
Return

SendChr:
	k := GetKeyState("CapsLock", "T") ? Format("{:U}", A_GuiControl) : A_GuiControl
	SendInput, % "{" k "}"
Return

#Include %A_ScriptDir%\..\class_Gui_NoActivate.ahk