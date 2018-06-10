#NoEnv
SetBatchLines, -1
Clipboard := ""
Gui, Margin, 20, 20
Gui, Add, Text, , Open an Explorer window and copy a file to the clipboard.
Gui, Add, Text, xm wp hp+6 Center +0x200 gDragDrop +Border, Then click here and drag.
Gui, Show, , IDropSource Test
Return

GuiClose:
ExitApp

DragDrop:
   Cursors := []
   Cursors[1] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "UPtr") ; DROPEFFECT_COPY = IDC_CROSS
   Cursors[2] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32516, "UPtr") ; DROPEFFECT_MOVE = IDC_UPARROW
   Cursors[3] := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32648, "UPtr") ; Copy or Move = IDC_NO
   MsgBox, % DoDragDrop(Cursors)
Return

#Include DoDragDrop.ahk