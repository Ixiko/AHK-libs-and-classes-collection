; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77311
; Author:
; Date:
; for:     	AHK_L

/*
Gui, Color, Black
SetBatchLines -1
hGui := WinExist()
Gui, +Lastfound

size=75 ; Works best between 35 and 150
PotNow = 0

Gui, add, Text, x2 y5 h%size% w%size% hwndhText1 gt1,
Gui, Add, Progress, x5 y+5 w%size% cBlue Range0-360 vp1, %PotNow%

Gui, Show,  , 1 Pot

RotaryKnob(hText1,size,PotNow,1)
Return

t1:
MouseGetPos, , OutY
StartPoint := OutY
Loop,
	{
	KeyIsDown := GetKeyState("LButton")
	If KeyIsDown = 1
		{
		MouseGetPos, , OutY
		PotSet := StartPoint-OutY+PotNow

		If PotSet < 0
			PotSet = 0
		If PotSet > 360
			PotSet = 360
		RotaryKnob(hText1,size,PotSet,1)
		GuiControl, , p1, %PotSet%
		Sleep, 50
		}
	If KeyIsDown = 0
		{
		PotNow := PotSet
		Break
		}
	}
Return

*/

; Oringal concept by ahklerner
; https://autohotkey.com/board/topic/64700-rotary-knob-for-a-gui/#entry408451
; Edited to be used as a library function by x32
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77311

RotaryKnob(hWnd,Size,angle,tn) 	{
	Global
	x = 1
	y = 1
	canvas_size := Size
	knob_size := canvas_size * 1.05
	indicator_size := canvas_size /9
	GetXY(pos_x := x+(knob_size/2)-4,pos_y := y+(knob_size/2)-4, knob_size / 3, angle)
	hDc := DllCall("GetDC", "uint", hText%tn%)
	DllCall("Ellipse", "uint", hDc, "int", x, "int", y, "int", knob_size, "int", knob_size)
	DllCall("Ellipse", "uint", hDc, "int", x+2, "int", y+2, "int", knob_size-2, "int", knob_size-2)
	DllCall("Ellipse", "uint", hDc, "int", pos_x, "int", pos_y, "int", pos_x + indicator_size, "int", pos_y + indicator_size)
	}

GetXY(Byref x0, byref y0, r, angle) 	{
	x0 := x0-sin(angle*4*ATan(1)/180)*r
	y0 := y0+cos(angle*4*ATan(1)/180)*r
	}