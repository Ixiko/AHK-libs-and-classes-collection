; Title:   	RemapRange library function
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=77307
; 				autohotkey.com/boards/viewtopic.php?f=76&t=77304
; Author:
; Date:		14.06.2020
; for:     	AHK_L

/*

; Originally created by Spawnova.
; Edited for use as a library function by x32.
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77307

	Gui, Add, Slider, x5 y5 w100 h25 AltSubmit Range0-360 vs1 gs1,
	Gui, Add, Progress, x5 y+5 w100 h25 Range0-100 vp1,
	Gui, Add, Edit, x5 y+5 w100 h25 ve1,
	Gui, Add, CheckBox, x5 y+5 w100 h25 Checked vc1, Round

	Gui, Show,  , Remap
Return

s1:
	Gui, Submit, NoHide
	mapval:= RemapRange(s1,0,360,0,100)
	If (c1 = 1)
		mapval := Round(mapval)
	GuiControl, , p1, % mapval
	GuiControl, , e1, % mapval
Return

*/


RemapRange(x,in_min,in_max,out_min,out_max) 	{
return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
}