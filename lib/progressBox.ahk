progressBox(input="", title:="") {
	static _display
	
	If !(input) {
		_display := ""
		gui box: destroy
		return
	}
	
	If (_display) { ; gui already exists
		gui box: +lastfound
		GuiControl box: , % _display, % input
		If (title)
			WinSetTitle, % title
	}
	else { ; setup gui
		; properties
		gui box: new
		gui box: margin, 20, 20
		gui box: +LabelguiProgressBox_ +LastFound
		
		; controls
		gui box: font, s15
		gui box: add, text, w300 0x200 center hwnd_display, % input
		
		; show
		gui box: show, autosize noactivate, % title
	}
	return
	
	guiProgressBox_close:
		msgbox, 68, % A_ScriptName, Are you sure?
		IfMsgBox, No
			return
		exitapp
	return
}