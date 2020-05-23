#Include JavaAccessBridge.ahk
#Include ObjectHandling.ahk

JAB:=new JavaAccessBridge()
return

F11::
	main:=JAB.GetAccessibleContextFromHWND(WinExist("A"))
	ccount:=main.GetVisibleChildrenCount()
	Children:=main.GetVisibleChildren()
	Gui, New
	Gui, Add, ListView, r20 w700, Number|Name|Role
	for index, child in Children
	{
		Info:=child.GetAccessibleContextInfo()
    LV_Add("", index, Info.Name, Info.Role)
	}

	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	LV_ModifyCol(1, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.
	Gui, Show
return

F12::
	main:=JAB.GetAccessibleContextWithFocus(WinExist("A"))
	Info:=main.GetAccessibleContextInfo()
	ToolTip, % Info.Name ";" Info.Role
return