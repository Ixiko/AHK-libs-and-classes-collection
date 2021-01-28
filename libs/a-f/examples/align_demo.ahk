; #Include Win.ahk
; #Include Align.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Text, HwndH1, hello
Gui, Add, Text, HwndH2 x+8, majkinetor
Gui, Add, Text, HwndH3 x+8, thx

MsgBox Proceed further to see what happens if aligned with Align.
Gui, Show, h100 w200
Gui, +LastFound
hGui := WinExist("A")
Sleep, 1500

Align(h1, "L", 100)	  ;Align this control to the left edge of its parent, set width to 100,
Align(h2, "T")		  ; then align this control to the top minus space taken from previous control, use its own height,
Align(h3, "F")		  ; then set this control to fill remaining space.

Align(hGui)			  ;Re-align hGui
Return

GuiClose:
ExitApp
