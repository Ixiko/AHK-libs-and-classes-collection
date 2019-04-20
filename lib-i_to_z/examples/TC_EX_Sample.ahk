#NoEnv
#Warn
#Include TC_EX.ahk
; Create an ImageList (sample in the manual)
HIL := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
Loop 10  ; Load the ImageList with a series of icons from the DLL.
    IL_Add(HIL, "shell32.dll", A_Index)  ; Omits the DLL's path so that it works on Windows 9x too.

; Create a GUI
Gui, Margin, 10, 10
Gui, Add, Tab2, w400 h200 HwndHTC, Tab 1|Tab 2|Tab 3
; TC_EX_SetPadding(10, 10)
Loop, % TC_EX_GetCount(HTC) {
   Gui, Tab, %A_Index%
   Gui, Add, Text, , This is Tab %A_Index%!
}
TC_EX_SetImageList(HTC, HIL)
Loop, % TC_EX_GetCount(HTC)
   TC_EX_SetIcon(HTC, A_Index, A_Index)
Gui, Add, StatusBar, , % "   TC_EX_GetText(HTC, 3) -> " . TC_EX_GetText(HTC, 3)
Gui, Show, , Class GuiControlTabEx
WinGet, Styles, Style, ahk_id %HTC%
WinGet, ExStyles, ExStyle, ahk_id %HTC%
MsgBox, 0, Styles & ExStyles, %Styles%`r`n%ExStyles%
; Demonstrate some methods
; TC_EX_SetMinWidth(100)
TC_EX_GetInterior(HTC, X, Y, W, H)
MsgBox, 0, GetInterior(HTC), X: %X% - Y: %Y% - W: %W% - H: %H%
SB_SetText("   TC_EX_HighLight(HTC, 2)")
TC_EX_HighLight(HTC, 2)
Sleep, 2000
TC_EX_HighLight(HTC, 2, False)
SB_SetText("   TC_EX_SetText(HTC, 3, ""Tab 4"")")
TC_EX_SetText(HTC, 3, "Tab 4")
Sleep, 2000
SB_SetText("   TC_EX_SetSel(HTC, 3)")
TC_EX_SetSel(HTC, 3)
Sleep, 2000
SB_SetText("   TC_EX_RemoveLast(HTC)")
TC_EX_RemoveLast(HTC)
Sleep, 2000
SB_SetText("   Thanks for your attention!")
Return

GuiClose:
   IL_Destroy(HIL)  ; Required for image lists used by tab controls.
ExitApp