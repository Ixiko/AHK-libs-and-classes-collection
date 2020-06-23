; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77311
; Author:
; Date:
; for:     	AHK_L

/*


*/

SetBatchLines -1

#Include, %A_ScriptDir%\..\class_Rotary_Knob.ahk

IniRead, PotNow, knobs.ini, vals, pot1, 0
IniRead, PotNow2, knobs.ini, vals, pot2, 0
IniRead, PotNow3, knobs.ini, vals, pot3, 0
IniRead, PotNow4, knobs.ini, vals, pot4, 0

size:=75 ; Works best between 35 and 150

Gui, +Lastfound
Gui, Color, Black
hGui := WinExist()

Gui, add, Text, x2 y5 h%size% w%size% hwndhText1 vknob1 gknob
Gui, add, Text, x+5 y5 h%size% w%size% hwndhText2 vknob2 gknob
Gui, add, Text, x+5 y5 h%size% w%size% hwndhText3 vknob3 gknob
Gui, add, Text, x+5 y5 h%size% w%size% hwndhText4 vknob4 gknob

Gui, Add, Progress, x5 y+5 w%size% cRed Range0-360 vp1, %PotNow%
Gui, Add, Progress, x+5 w%size% cBlue Range0-360 vp2, %PotNow2%
Gui, Add, Progress, x+5 w%size% cLime Range0-360 vp3, %PotNow3%
Gui, Add, Progress, x+5 w%size% c8A457E Range0-360 vp4, %PotNow4%

Gui, Add, Edit, x5 y+5 w%size% ve1, %PotNow%
Gui, Add, Edit, x+5 w%size% ve2, %PotNow2%
Gui, Add, Edit, x+5 w%size% ve3, %PotNow3%
Gui, Add, Edit, x+5 w%size% ve4, %PotNow4%

Gui, Add, Button, x5 y+5 w%size% h20 vbtSet1 gset, Set
Gui, Add, Button, x+5 w%size% h20 vbtSet2 gset, Set
Gui, Add, Button, x+5 w%size% h20 vbtSet3 gset, Set
Gui, Add, Button, x+5 w%size% h20 vbtSet4 gset, Set

Gui, Show,  , Potentiometers

knobs := []
knobs.push(new RotaryKnob(hText1,size,PotNow))
knobs.push(new RotaryKnob(hText2,size,PotNow2))
knobs.push(new RotaryKnob(hText3,size,PotNow3))
knobs.push(new RotaryKnob(hText4,size,PotNow4))
return

guiclose:
exitapp

set:
Gui, Submit, NoHide
if RegExMatch(a_guicontrol,"btSet(\d+)",match) { ;a_guicontrol will contain the variable name of the button control
	knob := match1								 ;use Regular Expression to find the number, ex: btSet1 = 1, btSet2 = 2 etc.
	knobs[knob].draw(e%knob%)
	GuiControl, , p%knob%, % knobs[knob].angle
	IniWrite, % knobs[knob].angle, knobs.ini, vals, pot%knob%
}
Return

knob:
if RegExMatch(a_guicontrol,"knob(\d+)",match) { ;a_guicontrol will contain the variable name of the text control
	knob := match1								;use Regular Expression to find the number, ex: knob1 = 1, knob2 = 2 etc.
	MouseGetPos,, startY
	startAngle := knobs[knob].angle
	While(GetKeyState("LButton")) {
		MouseGetPos,, currentY
		knobs[knob].draw(startY-currentY+startAngle)
		GuiControl, , e%knob%, % knobs[knob].angle
		GuiControl, , p%knob%, % knobs[knob].angle
		Sleep 50
	}
	IniWrite, % knobs[knob].angle, knobs.ini, vals, pot%knob%
}
Return

