#Include Class_CustomFont.ahk
font1 := New CustomFont("res:moonhouse.ttf", "moonhouse", 50)
font2 := New CustomFont("res:Selavy.otf", "Selavy-Regular", 20)

Gui, Color, Black
Gui, Add, Text, hwndhText1 w500 h50 c00FF00 Center, AutoHotkey
Gui, Add, Text, hwndhText2 wp hp cWhite Center, https://www.autohotkey.com/
Gui, Add, Button, xm gRemoveFont1, Remove Font1

font1.applyTo(hText1)
font2.applyTo(hText2)

Gui, Show
Return

RemoveFont1:
	font1 := ""
	WinSet, Redraw,, A
Return

GuiClose:
ExitApp

FileInstall, moonhouse.ttf, -
FileInstall, Selavy.otf, -