; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
;#NoTrayIcon

#INCLUDE %A_ScriptDir%\..\MsgBox2_AHK-V2.ahk

Global mb2ex

StartGui()

StartGui() {
	mb2ex := GuiCreate("","MsgBox2 Examples")
	mb2ex.OnEvent("Close","mb2ex_Close")

	mb2ex.AddButton("","Ex #1").OnEvent("Click","Example1")
	mb2ex.AddButton("x+0","Ex #2").OnEvent("Click","Example2")
	mb2ex.AddButton("x+0","Ex #3").OnEvent("Click","Example3")
	mb2ex.AddButton("x+0","Ex #4").OnEvent("Click","Example4")
	mb2ex.AddButton("x+0","Ex #5").OnEvent("Click","Example5")
	mb2ex.AddButton("x+0","Ex #6").OnEvent("Click","Example6")
	mb2ex.AddButton("x+0","Ex #7").OnEvent("Click","Example7")
	mb2ex.AddButton("x+0","Ex #8").OnEvent("Click","Example8")
	mb2ex.AddButton("x+0","Ex #9").OnEvent("Click","Example9")
	mb2ex.AddButton("x+0","Ex #10").OnEvent("Click","Example10")

	mb2ex.Show("")
}

Example1(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Delete file?`r`nYay red text!"
	result := MsgBox2(sMsg,sTitle,"txtColor:cRed")
	MsgBox2("button clicked:`r`n          " result)
}

Example2(ctl,*) {
	sTitle := "this is a title"
	sMsg := "BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
	result := MsgBox2(sMsg,sTitle)
	MsgBox2("button clicked`r`n          " result)
}

Example3(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Delete file?"
	sOptions := "icon:warning,opt:4"
	result := MsgBox2(sMsg,sTitle,sOptions)
	MsgBox2("button clicked:`r`n          " result)
}

Example4(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Try clicking the main window`r`n`r`n100 pixels left of center.`r`n`r`nThis dialog is modal."
	x := -100

	sOptions := "icon:warning,opt:4,modal:" ctl.Gui.hwnd ",x:" x ",y:"
	result := MsgBox2(sMsg,sTitle,sOptions)
	MsgBox2("button clicked:`r`n          " result)
}

Example5(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Try clicking the main window`r`n`r`n100 pixels down from center.`r`n`r`nThis dialog is modal."
	y := "+100"
	sOptions := "icon:imageres.dll/55,opt:4,modal:" ctl.Gui.hwnd ",x:,y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; shows a padlock icon
	MsgBox2("button clicked:`r`n          " result)
}

Example6(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Background at text colors set.`r`n`r`nCan't change buttons though..."
	x := 200, y:= 200
	sOptions := "txtColor:c00AAAA,bgColor:Blue,buttons:OK|Cancel|Still Thinking|Can't Decide,icon:imageres.dll/55,modal:" ctl.Gui.hwnd
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + padlock icon
	MsgBox2("button clicked:`r`n          " result)
}

Example7(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Default is [Can't Decide]`r`n`r`nPress ENTER now to see default button.`r`n`r`nThis dialog has a help button."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" ctl.Gui.hwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example8(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Default is [Can't Decide]`r`n`r`nPress ENTER now to see default button.`r`n`r`nHere you see custom help button text."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:Dear god i need help,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" ctl.Gui.hwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example9(ctl,*) {
	sTitle := "this is a title"
	sMsg := "This example returns ClassNN instead of button text.`r`n`r`nPress ENTER now to see default button."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:help?,btnID:,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" ctl.Gui.hwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example10(ctl,*) {
	sTitle := "this is a title"
	sMsg := "Select this text now!`r`n`r`nRight-click > copy ... or CTRL+C`r`n`r`nand yellow text!`r`n`r`ncool huh?"
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "txtColor:cYellow,bgColor:008888,help:help?,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" ctl.Gui.hwnd ",selectable:"
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

mb2ex_Close(gui) {
	ExitApp
}