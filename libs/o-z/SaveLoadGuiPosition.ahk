; Link:
; Author:
; Date:
; for:     	AHK_L

/*
	Gui +HwndMainGuiHwnd
	Gui +Resize -DPIScale
	Gui, Add, text, x+10  w280  , Position und Größe beider Guis werden als "Alternate Data Stream" gespeichert. Nach einem Neustart werden die Guis mit den gespeicherten Werten positioniert.
	Gui, Add, Button,x10 greset, Position dieses Guis zurücksetzen
	Gui, Add, Button,x10 greload, Beenden und Neustart
	Gui, show, , Gui position and size

	loadGP(200,200,300,240,"MainGuiHwnd")

	Gui MyGui:+HwndMyGuiHwnd +Resize -DPIScale
	Gui, MyGui:Add, Text,, Reset setzt die Position und Größe auf einen neuen Wert
	Gui, MyGui:Add, Button, greset, Position dieses Guis zurücksetzen
	Gui, MyGui:Add, Button,x10 greload, Beenden und Neustart
	Gui, MyGui:Show,,Gui position and size

	loadGP(800,200,400,150,"MyGuiHwnd")

	return


	MyGuiGuiEscape:
	MyGuiGuiClose:
	GuiEscape:
	GuiClose:
	saveGP("MainGuiHwnd")
	saveGP("MyGuiHwnd")
	ExitApp

	reload:
	saveGP("MainGuiHwnd")
	saveGP("MyGuiHwnd")
	Reload
	return

	reset:
	if (a_gui="1")
	{
		WinMove,ahk_id  %MainGuiHwnd%, , 200,200,300,240
		saveGP("MainGuiHwnd")
	}
	else if (a_gui="MyGui")
	{
		WinMove,ahk_id %MyGuiHwnd%, , 800,200,400,150
		saveGP("MyGuiHwnd")
	}
	return


*/

saveGP(GuiID := "a"){
	title:=GuiID
	if (SubStr(%GuiID%, 1 , 2)="0x")
		if %GuiID% is xdigit
			title:="ahk_id " %GuiID%

	WinGetPos, x, y, w, h, %title%
	stream_1:=A_ScriptFullPath ":sfGuiPos"
	if InStr(A_ScriptName, "reset"){
		filedelete,%stream_1%
		return
	}
	IniWrite, %x%, %stream_1%, %GuiID%, x
	IniWrite, %y%, %stream_1%, %GuiID%, y
	IniWrite, %w%, %stream_1%, %GuiID%, w
	IniWrite, %h%, %stream_1%, %GuiID%, h
	return
}

loadGP(x,y,w,h,GuiID := "a"){
	; title kann a oder ein hwnd variablenname sein
	; "a" oder zB. "MainGuihwnd"
	; x,y,w,h standardgrößen bei erststart oder reset
	; 200,200,400,400
	stream_1:=A_ScriptFullPath ":sfGuiPos" ;man kann mehr als einen ADS speichern
	if InStr(A_ScriptName, "reset"){
		filedelete,%stream_1%
		return
	}

	title:=GuiID
	if (SubStr(%GuiID%, 1 , 2)="0x")
		if %GuiID% is xdigit
			title:="ahk_id " %GuiID%

	IniRead, xx, %stream_1%, %GuiID%, x, %x%
	IniRead, yy, %stream_1%, %GuiID%, y, %y%
	IniRead, ww, %stream_1%, %GuiID%, w, %w%
	IniRead, hh, %stream_1%, %GuiID%, h, %h%
	WinMove,%title%, , %xx%, %yy%, %ww%, %hh%
	return
}
