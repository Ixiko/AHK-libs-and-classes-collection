; #Include Font.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Text, HwndH1, hello
Gui, Add, Text, HwndH2 x+8, majkinetor
Gui, Add, Text, HwndH3 x+8, thx

MsgBox Proceed further to see what happens if font changed with Font.
Gui, Show, h100 w200
Sleep, 1500

hCtrl := Font(h2, "s9 italic, Courier New", 1)
Return

GuiClose:
ExitApp
