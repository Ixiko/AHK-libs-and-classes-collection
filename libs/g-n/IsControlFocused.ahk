; Link:   	https://sites.google.com/site/ahkref/custom-functions/iscontrolfocused
; Author:
; Date:
; for:     	AHK_L

/*

    Gui, Margin, 20, 20
    Gui, Add, Text,, Set focus to one of the fields and press F1
    Gui, Add, Edit, w100 hwndHwndEdit, Test
    Gui, Add, Edit, w100 hwndHwndEdit2, Test2
    Gui, Show, % "x" A_ScreenWidth // 2 - 120
    Gui, 2:Margin, 20, 20
    Gui, 2:Add, Text,, Set focus to one of the fields and press F1
    Gui, 2:Add, Edit, w100 hwndHwndEdit3, Test4
    Gui, 2:Add, Edit, w100 hwndHwndEdit4, Test3
    Gui, 2:Show, % "x" A_ScreenWidth // 2 + 120
    return
    F1:: msgbox % IsControlFocused(HwndEdit) ? "Edit1 is focused." : "Edit1 is not focused."
    GuiClose:
    2GuiClose:
    ExitApp

*/

IsControlFocused(hwnd) {
    VarSetCapacity(GuiThreadInfo, 48) , NumPut(48, GuiThreadInfo, 0)
    Return DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo) ? (hwnd = NumGet(GuiThreadInfo, 12)) ? True : False : False
}