; #Include SB.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui,add,text,w280 center,Some text for the gui!
Gui,add,statusbar
Gui,show,w300,Statusbar with Progress

SB_SetParts(20,200,100) ; Make 3 different parts
SB_SetText("demotext",2) ; Set a text segment 2
SB_SetIcon(A_AhkPath,1,1) ; Set an Icon to 1st segment
; create a 50% progressbar with yellow background and blue bar
hwnd := SB_SetProgress(50,3,"BackgroundYellow cBlue")
return