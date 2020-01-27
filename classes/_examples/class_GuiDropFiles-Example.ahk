; Example - Drag and drop highlight

#NoEnv
#Include %A_ScriptDir%\..\class_GuiDropFiles.ahk

; =================================
; Interface
; =================================
Gui, +HwndHGUI +AlwaysOnTop
Gui, Add, Edit, w300 HwndHEdit1,
Gui, Add, Edit, w300 HwndHEdit2, Do not accept drag and drop here
Gui, Add, Edit, w300 HwndHEdit3,
Gui, Show,, Drag and Drop

GuiDropFiles.config(HGUI, "GuiDropFiles_Begin", "GuiDropFiles_End")
Return

; =================================
; Start dragging
; =================================
GuiDropFiles_Begin:
CoverControl(HEdit1 "," HEdit3)
Return

; =================================
; Drag and drop ends
; =================================
GuiDropFiles_End:
CoverControl()

If GuiDropFiles_FileName {
MouseGetPos,,,, hwnd, 2
If hwnd in %HEdit1%,%HEdit3%
GuiControl,, %hwnd%, % GuiDropFiles_FileName
}
Return

; =================================
; drop out
; =================================
GuiClose:
ExitApp

; ================================================= ==============================================
CoverControl(hwnd_CsvList = "") {
Static handler := {__New: "test"}
Static _ := new handler
Static HGUI2
If !HGUI2 {
Gui, New, +LastFound +hwndHGUI2 -Caption +E0x20 +ToolWindow +AlwaysOnTop -DPIScale
Gui, Color, 00FF00
Gui, 1:Default
WinSet, Transparent, 50
}

If (hwnd_CsvList = "") {
Gui, %HGUI2%: Cancel
Return
}

Static lastHwnd

MouseGetPos,,,, hwnd, 2

If hwnd not in %hwnd_CsvList%
{
Gui, %HGUI2%: Cancel
lastHwnd := ""
Return
}
If (hwnd = lastHwnd)
Return

WinGetPos, x, y, w, h, ahk_id %hwnd%
Gui, %HGUI2%:Show, X%x% Y%y% w%w% h%h% NA

lastHwnd := hwnd
}