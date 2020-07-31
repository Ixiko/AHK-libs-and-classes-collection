; AddClearBtnToEdit_Sample.ahk

#NoEnv
#SingleInstance Force
SetBatchLines -1

Gui, +Resize
Gui, Add, Edit, hwndHEDIT w200
	AddClearBtnToEdit(HEDIT)

Gui, Add, Edit, y+30 w135 hwndHEDIT2  r4, Click Me --->
	AddClearBtnToEdit(HEDIT2, { c      : "White", cBG    : "008000"
	                          , c_hot  : "008000", cBG_hot: "White"
	                          , tooltip: "Clear text", onClick: "ClickedFunc" } )

Gui, Add, Edit, x+30 w135 hwndHEDIT3  r4
	AddClearBtnToEdit(HEDIT3, { c    : "Black", cBG    : "White", border: True
	                          , c_hot: "White", cBG_hot: "Black"
	                          , w: 30, left: -20, top: 10 } )

Gui, Add, Edit, xm w300 h200 hwndHEDIT4
	AddClearBtnToEdit(HEDIT4, { c:     "Red",   cBG: "White"
	                          , c_hot: "White", cBG_hot: "Red", w: 50, h: 50, round_hot: "w"})
Gui, Show
Return

/*
GuiSize:
	AutoXYWH("w", HEDIT) ; http://ahkscript.org/boards/viewtopic.php?f=6&t=1079&start=20#p20635

	; Note: Only edit control has width changing needs to call "AutoMove"
	AddClearBtnToEdit.AutoMove(HEDIT)
Return
*/

GuiClose:
ExitApp

ClickedFunc(ParentHEDIT) {
	MsgBox, % ParentHEDIT " clicked."
}