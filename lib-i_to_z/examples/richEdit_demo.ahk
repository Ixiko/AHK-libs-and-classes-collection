#Include %A_ScriptDir%\..\RichEdit.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetKeyDelay, 20, 20

Gui, +LastFound -DPIScale
hwnd := WinExist()
hRichEdit := RichEdit_Add(hwnd, 5, 5, 200, 300)
RichEdit_SetBgColor(hRichEdit, "0x661122")
RichEdit_SetCharFormat(hRichEdit, "courier new", "bold", "0x3366ff", "0x333333")
Gui, Show, w210 h310

BlockInput, Send
Sleep, 500
SendEvent, RichEdit
BlockInput, Off
Return

GuiClose:
ExitApp