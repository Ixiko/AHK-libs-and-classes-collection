; AHK v1
#NoEnv
#Include _Class_LV_Colors.ahk
SetBatchLines, -1
Gui, Margin, 20, 20
Gui, Add, ListView, w600 r15 Grid -ReadOnly vVLV hwndHLV
   , Column 1|Column 2|Column 3|Column 4|Column 5|Column6
Loop, 256
   LV_Add("", "Value " . A_Index, "Value " . A_Index, "Value " . A_Index, "Value " . A_Index, "Value "
        . A_Index, "Value " . A_Index)
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, 95)
; Create a new instance of LV_Colors
CLV := New LV_Colors(HLV)
; Set the colors for selected rows
CLV.SelectionColors(0xF0F0F0)
If !IsObject(CLV) {
   MsgBox, 0, ERROR, Couldn't create a new LV_Colors object!
   ExitApp
}
Gui, Add, CheckBox, w120 vColorsOn gSubShowColors Checked, Colors On
Gui, Add, Radio, x+120 yp wp vColors gSubColors, Colors
Gui, Add, Radio, x+0 yp wp vAltRows gSubColors, Alternate Rows
Gui, Add, Radio, x+0 yp wp vAltCols gSubColors, Alternate Columns
Gui, Show, , ListView & Colors
; Redraw the ListView after the first Gui, Show command to show the colors, if any.
WinSet, Redraw, , ahk_id %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
GuiEscape:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
SubShowColors:
Gui, Submit, NoHide
If (ColorsOn)
   CLV.OnMessage()
Else
   CLV.OnMessage(False)
GuiControl, Focus, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
SubColors:
Gui, Submit, NoHide
GuiControl, -Redraw, %HLV%
CLV.Clear(1, 1)
If (Colors)
   GoSub, SetColors
If (AltRows)
   CLV.AlternateRows(0x808080, 0xFFFFFF)
If (AltCols)
   CLV.AlternateCols(0x808080, 0xFFFFFF)
GuiControl, +Redraw, %HLV%
Return
; ----------------------------------------------------------------------------------------------------------------------
SetColors:
Loop, % LV_GetCount() {
   If (A_Index & 1) {
      CLV.Cell(A_Index, 1, 0x808080, 0xFFFFFF)
      CLV.Cell(A_Index, 3, 0x808080, 0xFFFFFF)
      CLV.Cell(A_Index, 5, 0x808080, 0xFFFFFF)
   }
   Else {
      CLV.Cell(A_Index, 2, 0x808080, 0xFFFFFF)
      CLV.Cell(A_Index, 4, 0x808080, 0xFFFFFF)
      CLV.Cell(A_Index, 6, 0x808080, 0xFFFFFF)
   }
}
Return