Gui +HwndHGUI
	SysMenuItems := "
	(LTrim
		-----------------------------
		item 1, 1234, test_function
		item 2, 2222, test_lable
	)"
	Menu_SetSysMenu( HGUI, SysMenuItems, "Reset" )
Gui, Show, W400 h300
Return

test_function() {
	MsgBox, % A_ThisFunc
}

test_lable:
	MsgBox, % A_ThisLabel
Return

GuiClose:
ExitAPP