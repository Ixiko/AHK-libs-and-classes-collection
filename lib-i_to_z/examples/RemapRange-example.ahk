#Include, RemapRange.ahk

Gui, Add, Slider, x5 y5 w100 h25 AltSubmit Range0-360 vs1 gs1, 
Gui, Add, Progress, x5 y+5 w100 h25 Range0-100 vp1, 
Gui, Add, Edit, x5 y+5 w100 h25 ve1, 
Gui, Add, CheckBox, x5 y+5 w100 h25 Checked vc1, Round

Gui, Show,  , Remap 
Return

s1:
Gui, Submit, NoHide
mapval:= RemapRange(s1,0,60,0,100)
If c1 = 1
	mapval := Round(mapval)
GuiControl, , p1, %mapval%
GuiControl, , e1, %mapval%
Return