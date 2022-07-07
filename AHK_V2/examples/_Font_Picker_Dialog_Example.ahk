; AHK v2
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

#INCLUDE _Font_Picker_Dialog.ahk
Global fontObj

oGui := Gui.New("","Change Font Example")
oGui.OnEvent("close","gui_exit")
ctl := oGui.AddEdit("w500 h200 vMyEdit1","Sample Text")
ctl.SetFont("bold underline italic strike c0xFF0000")
oGui.AddEdit("w500 h200 vMyEdit2","Sample Text")
oGui.AddButton("Default","Change Font").OnEvent("click","button_click")
oGui.Show()

button_click(ctl,info) {
	If (!isSet(fontObj))
		fontObj := ""
	fontObj := Map("name","Terminal","size",14,"color",0xFF0000,"strike",1,"underline",1,"italic",1,"bold",1) ; init font obj (optional)
	
	fontObj := FontSelect(fontObj,ctl.gui.hwnd) ; shows the user the font selection dialog
	
	If (!fontObj)
		return ; to get info from fontObject use ... bold := fontObject["bold"], fontObject["name"], etc.
	
	ctl.gui["MyEdit1"].SetFont(fontObj["str"],fontObj["name"]) ; apply font+style in one line, or...
	ctl.gui["MyEdit2"].SetFont(fontObj["str"],fontObj["name"])
}

gui_exit(oGui) {
	ExitApp
}

