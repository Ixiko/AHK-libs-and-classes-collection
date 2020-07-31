#NoEnv
#Warn
#Include %A_ScriptDir%\..\classes\Class_GuiTabEx.ahk
; Create an ImageList (sample in the manual)
HIL := IL_Create(10) ; Create an ImageList to hold 10 small icons.
Loop 10 ; Load the ImageList with a series of icons from the DLL.
IL_Add(HIL, "shell32.dll", A_Index) ; Omits the DLL's path so that it works on Windows 9x too.

; Create a GUI
Gui, Margin, 10, 10
Gui, Add, Tab2, w400 h200 HwndHWND, Tab 1|Tab 2|Tab 3
MyTab := New GuiTabEx(HWND)
; MyTab.SetPadding(10, 10)
Loop, % MyTab.GetCount() {
Gui, Tab, %A_Index%
Gui, Add, Text, , This is Tab %A_Index%!
}
MyTab.SetImageList(HIL)
Loop, % MyTab.GetCount()
MyTab.SetIcon(A_Index, A_Index)
Gui, Add, StatusBar, , % " MyTab.GetText(3) -> " . MyTab.GetText(3)
Gui, Show, , Class GuiControlTabEx
; Demonstrate some methods
; MyTab.SetMinWidth(100)
MyTab.GetInterior(X, Y, W, H)
MsgBox, 0, GetInterior(), X: %X% - Y: %Y% - W: %W% - H: %H%
SB_SetText(" MyTab.HighLight(2)")
MyTab.HighLight(2)
Sleep, 2000
MyTab.HighLight(2, False)
SB_SetText(" MyTab.SetText(3, ""Tab 4"")")
MyTab.SetText(3, "Tab 4")
Sleep, 2000
SB_SetText(" MyTab.SetSel(3)")
MyTab.SetSel(3)
Sleep, 2000
SB_SetText(" MyTab.RemoveLast()")
MyTab.RemoveLast()
Sleep, 2000
SB_SetText(" Thanks for your attention!")
Return

GuiClose:
IL_Destroy(HIL) ; Required for image lists used by tab controls.
ExitApp