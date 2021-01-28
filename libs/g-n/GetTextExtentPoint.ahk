;https://autohotkey.com/board/topic/27393-resize-text-control-to-fit-new-contents/
/*
Gui, 1: Font, s20, Arial
Gui, 1: Add, Text, x0 y0 vText hwndText, Hello
Gui, 1: Show, x0 y0 AutoSize
SetTimer, Resize, 2000
Return

Resize:
SetTimer, Resize, Off
NewMsg := "Message to say bye"
GuiControl, Move, Text, % "w" GetTextExtentPoint(NewMsg, "Arial", 20)		;%
GuiControl,, Text, %NewMsg%

;Code here to set up gui
;Destroy 1st text control
SendMessage, 0x10,,, Static1, ahk_id %hwnd%
WinSet, Redraw,, ahk_id %hwnd%
;Code here to add control again to the gui

Return
*/

GetTextExtentPoint(sString, sFaceName, nHeight = 9, bBold = False, bItalic = False, bUnderline = False, bStrikeOut = False, nCharSet = 0) {
   hDC := DllCall("GetDC", "Uint", 0)
   nHeight := -DllCall("MulDiv", "int", nHeight, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

   hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 400 + 300 * bBold, "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", sFaceName)
   hFold := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

   DllCall("GetTextExtentPoint32", "Uint", hDC, "str", sString, "int", StrLen(sString), "int64P", nSize)

   DllCall("SelectObject", "Uint", hDC, "Uint", hFold)
   DllCall("DeleteObject", "Uint", hFont)
   DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

   nWidth  := nSize & 0xFFFFFFFF
   nHeight := nSize >> 32 & 0xFFFFFFFF

   Return, nWidth
}