; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.
;#NoTrayIcon

#INCLUDE %A_ScriptDir%\..\MsgBox2_AHK-V1.ahk

Global MainHwnd
MsgBox2ExGui()

MsgBox2ExGui() {
	Gui, New, +HwndMainHwnd +LabelMsgBox2Ex
	Gui, Add, Button, gExample1, Ex #1
	Gui, Add, Button, gExample2 x+0, Ex #2
	Gui, Add, Button, gExample3 x+0, Ex #3
	Gui, Add, Button, gExample4 x+0, Ex #4
	Gui, Add, Button, gExample5 x+0, Ex #5
	Gui, Add, Button, gExample6 x+0, Ex #6
	Gui, Add, Button, gExample7 x+0, Ex #7
	Gui, Add, Button, gExample8 x+0, Ex #8
	Gui, Add, Button, gExample9 x+0, Ex #9
	Gui, Add, Button, gExample10 x+0, Ex #10
	Gui, Show
}

Example1() {
	sTitle := "this is a title"
	sMsg := "Delete file?`r`nYay red text!"
	result := MsgBox2(sMsg,sTitle,"txtColor:cRed")
	MsgBox2("button clicked:`r`n          " result)
}

Example2() {
	sTitle := "this is a title"
	sMsg := "BLAH blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah"
	result := MsgBox2(sMsg,sTitle)
	MsgBox2("button clicked`r`n          " result)
}

Example3() {
	sTitle := "this is a title"
	sMsg := "Delete file?"
	sOptions := "icon:warning,opt:4"
	result := MsgBox2(sMsg,sTitle,sOptions)
	MsgBox2("button clicked:`r`n          " result)
}

Example4() {
	sTitle := "this is a title"
	sMsg := "Try clicking the main window`r`n`r`n100 pixels left of center.`r`n`r`nThis dialog is modal."
	x := -100
	sOptions := "icon:warning,opt:4,modal:" MainHwnd ",x:" x ",y:"
	result := MsgBox2(sMsg,sTitle,sOptions)
	MsgBox2("button clicked:`r`n          " result)
}

Example5() {
	sTitle := "this is a title"
	sMsg := "Try clicking the main window`r`n`r`n100 pixels down from center.`r`n`r`nThis dialog is modal."
	y := "+100"
	sOptions := "icon:imageres.dll/55,opt:4,modal:" MainHwnd ",x:,y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; shows a padlock icon
	MsgBox2("button clicked:`r`n          " result)
}

Example6() {
	sTitle := "this is a title"
	sMsg := "Background at text colors set.`r`n`r`nCan't change buttons though..."
	x := 200, y:= 200
	sOptions := "txtColor:c00AAAA,bgColor:Blue,buttons:OK|Cancel|Still Thinking|Can't Decide,icon:imageres.dll/55,modal:" MainHwnd
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + padlock icon
	MsgBox2("button clicked:`r`n          " result)
}

Example7() {
	sTitle := "this is a title"
	sMsg := "Default is [Can't Decide]`r`n`r`nPress ENTER now to see default button.`r`n`r`nThis dialog has a help button."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" MainHwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example8() {
	sTitle := "this is a title"
	sMsg := "Default is [Can't Decide]`r`n`r`nPress ENTER now to see default button.`r`n`r`nHere you see custom help button text."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:Dear god i need help,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" MainHwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example9() {
	sTitle := "this is a title"
	sMsg := "This example returns ClassNN instead of button text.`r`n`r`nPress ENTER now to see default button."
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "help:help?,btnID:,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" MainHwnd ",x:" x ",y:" y
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

Example10() {
	sTitle := "this is a title"
	sMsg := "Select this text now!`r`n`r`nRight-click > copy ... or CTRL+C`r`n`r`nand red text!`r`n`r`ncool huh?"
	x := (A_ScreenWidth/2) - 100, y := A_ScreenHeight/2
	sOptions := "txtColor:cRed,bgColor:00AAAA,help:help?,buttons:Still Thinking|Can't Decide[d],icon:imageres.dll/30,modal:" MainHwnd ",selectable:"
	result := MsgBox2(sMsg,sTitle,sOptions) ; custom buttons + chip icon + help button
	MsgBox2("button clicked:`r`n          " result)
}

MsgBox2ExClose(this) {
	ExitApp
}