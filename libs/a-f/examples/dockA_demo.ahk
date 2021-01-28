; #Include DockA.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, 2:Add, Text, HwndH2, client
Gui, 2:Show, h100 w200
Gui, 2:+LastFound
cGui := WinExist("A")

Gui, 1:Add, Text, HwndH1, host
Gui, 1:Show, h100 w200
Gui, 1:+LastFound
hGui := WinExist("A")

DockA(hGui, cGui, "x(1) y()")
Return

GuiClose:
ExitApp
