; #Include Win.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Text, vh1, hello
Gui, Add, Text, vh2, majkinetor
Gui, Add, Text, vh3, thx

Msgbox,, %A_ScriptName%, Close Gui with a 2.5 second blend effect and exit
Gui, Show
Gui, +LastFound
hwnd := WinExist("A")
Sleep, 1500

Win_Animate(hwnd, "hide blend", 2500)
ExitApp