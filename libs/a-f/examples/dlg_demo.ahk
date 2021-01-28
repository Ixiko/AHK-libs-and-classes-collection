; #Include Dlg.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

 ;basic usage
if Dlg_Icon(icon, idx := 4)
	msgbox Icon:   %icon%`nIndex:  %idx%

if Dlg_Color( color := 0xFF00AA )
	msgbox Color:  %color%

if Dlg_Font( font := "Courier New", style := "s16 bold underline italic", color:=0x80)
	msgbox Font:  %font%`nStyle:  %style%`nColor:  %color%

res := Dlg_Open("", "Select several files", "", "", "c:\Windows\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
IfNotEqual, res, , MsgBox, %res%

ExitApp