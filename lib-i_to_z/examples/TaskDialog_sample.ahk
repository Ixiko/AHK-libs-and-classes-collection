#NoEnv
#Include %A_ScriptDir%\..\TaskDialog.ahk
TaskDialogUseMsgBoxOnXP(True)
Gui, +HwndHGUI
Gui, Show, w600 h400, Dummy
Main  := "Some rather long main instruction without any line breaks just to see what happens."
Extra := "The dialog is showing all of the possible buttons. The dialog is showing all of the possible buttons. The dialog is showing all of the possible buttons."
MsgBox, 262144, %A_ScriptName%, % TaskDialog(Main, Extra, , 0x3F, "Green", , HGUI)
ToolTip
Extra := "Short Extra text."
MsgBox, 262144, %A_ScriptName%, % TaskDialog(Main, Extra, , 6, "Question", , -1)
ToolTip
MsgBox, 262144, %A_ScriptName%, % TaskDialog(Main, Extra, , 6, "Question", 700, -1)
ToolTip
Return
GuiClose:
ExitApp
; Show the width and height of the current task dialog
^+w::
HWND := WinExist("A")
VarSetCapacity(RC, 16, 0)
DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RC)
ToolTip, % NumGet(RC, 8, "Int") . " - " . NumGet(RC, 12, "Int")
Return