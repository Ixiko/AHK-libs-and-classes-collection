#NoEnv
#SingleInstance Force
SetWinDelay -1
SetBatchLines -1
#include %A_ScriptDir%\..\Class_ScrollGUI.ahk
#include %A_ScriptDir%\..\Class_expandView.ahk

Gui New, HwndhParent +labelParent_, Window
exp := new expandView( hParent, 10, 10, 300, 400 )		; new expandView( Hwnd of parent GUI, x position, y position, width, height )
_e := 0, _b := 0, _t := 0
Loop 30 {
	_hwnd := exp.newExpandable(,, A_Index )		; newExpandable(height of expandable ( not including caption ), height of caption, caption text )
	if InStr( A_Index / 2, .5 )
		Gui %_hwnd%:Add, Edit, x0 y16 w200 h200, % "Edit " ++_e		; all controls added to the expandable should have a y value >= height of caption
	else if InStr( A_Index / 3, .3 )
		Gui %_hwnd%:Add, Button, x54 y76 w60 h50, % "Button " ++_b
	else
		Gui %_hwnd%:Add, Text, +Border x5 y26 w190 h40, % "Text " ++_t
}
exp.Show()
Gui %hParent%:Show, center w600 h600
return

Parent_Close() {
	global exp
	exp.Destroy()
	exitapp
}


