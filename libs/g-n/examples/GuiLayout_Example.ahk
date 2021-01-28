; -- Script directives
; -----------------------------------------------------------------

#NoEnv
#Warn, , StdOut
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
SetControlDelay -1
SetWinDelay -1
StringCaseSense On

#Include %A_ScriptDir%\..\GuiLayout.ahk
;~ #Include ..\Debug.ahk

; -- Auto-execute
; -----------------------------------------------------------------

Gui New, Resize
Gui Add, Edit, HwndEditHwnd Multi, Testing
Gui Add, Button, HwndBtnAddHwnd, Add
Gui Add, Button, HwndBtnRemoveHwnd, Remove
Gui Add, Button, HwndBtnUpHwnd, Up
Gui Add, Button, HwndBtnDownHwnd, Down
Gui Add, GroupBox, HwndGroupBoxTopHwnd, Right Top Panel
Gui Add, Edit, HwndRightPanelEditHwnd,
Gui Add, Button, HwndRightPanelBtnHwnd, Click
Gui Add, GroupBox, HwndGroupBoxBottomHwnd, Right Bottom Panel
Gui Show, w480 h360, GuiLayout

; Create a "root" component which will correpsond to the window client area
LayoutRoot := GuiLayout_Create()
	; Create two container components for the left and right columns for convenience
	LayoutLeft := GuiLayout_Create(0, LayoutRoot, "l6 t6 r150 b6")
		GuiLayout_Create(EditHwnd, LayoutLeft, "l0 t0 r0 b30")
		; Create a row of buttons, only specify the r rule for the first button, then r>6 for the following buttons to automatically position them 6 pixels from the previous one
		GuiLayout_Create(BtnAddHwnd, LayoutLeft, "r0 b0")
		GuiLayout_Create(BtnRemoveHwnd, LayoutLeft, "r>6 b0")
		GuiLayout_Create(BtnUpHwnd, LayoutLeft, "r>6 b0")
		GuiLayout_Create(BtnDownHwnd, LayoutLeft, "r>6 b0")
	LayoutRightTop := GuiLayout_Create(GroupBoxTopHwnd, LayoutRoot, "w138 r6 t6 b50%-3") ; b50%-3 is used to give a 6 pixel spacing between this component and the one below it
		GuiLayout_Create(RightPanelEditHwnd, LayoutRightTop, "l6 r6 t20")
		GuiLayout_Create(RightPanelBtnHwnd, LayoutRightTop, "r6 b6")
	LayoutRightBottom := GuiLayout_Create(GroupBoxBottomHwnd, LayoutRoot, "w138 r6 t50%+3 b6")

return

; -- Events, Functions
; -----------------------------------------------------------------

GuiSize:
	GuiLayout_SetSize(LayoutRoot, 0, 0, A_GuiWidth, A_GuiHeight)
return

GuiClose:
GuiEscape:
	ExitApp
return