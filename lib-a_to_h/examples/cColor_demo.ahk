; #Include CColor.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Text, HwndH1 cred, hello
Gui, Add, Text, HwndH2 cred x+8, (de)nick
Gui, Add, Text, HwndH3 cred x+8, thx

MsgBox Proceed further to see what happens if colored with CColor
Gui, Show, h100 w200
Sleep, 1500
CColor(h2, "FFFFFF", "blue")
Gui, 1:+LastFound
WinSet, ReDraw ; Without this redraw, the change does not take effect!
Return

GuiClose:
ExitApp
