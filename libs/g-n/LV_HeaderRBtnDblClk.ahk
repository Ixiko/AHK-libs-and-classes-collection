; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=21502
; Author:
; Date:
; for:     	AHK_L

/*
   #NoEnv
   SetBatchLines, -1

   Gui, Add, ListView, w600 r5 gLVLabel hwndHLV AltSubmit, Column 1|Column 2|Column 3
   LVHeader := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr")
   Loop, 5
      LV_Add("", "Row " . A_Index . " Col 1", "Row " . A_Index . " Col 2", "Row " . A_Index . " Col 3")
   LV_ModifyCol()
   Gui, Show, , ListView

   ; 0x0204 = WM_RBUTTONDOWN
   ; 0x0206 = WM_RBUTTONDBLCLK
   RBtnDlbClkFunc := Func("HeaderRBtnDblClk").Bind(LVHeader)
   OnMessage(0x0206, RBtnDlbClkFunc)
   Return

   GuiClose:
   ExitApp

   LVLabel:
   ToolTip, %A_GuiEvent% - %A_EventInfo% - %ErrorLevel%
   Return

*/

HeaderRBtnDblClk(HHD, wParam, lParam, Msg, Hwnd) {
   ; msdn.microsoft.com/en-us/library/bb775349(v=vs.85).aspx
   If (Hwnd = HHD) {
      VarSetCapacity(HDHTI, 16, 0) ; HDHITTESTINFO structure
      NumPut(lParam & 0xFFFF, HDHTI, "Int")
      NumPut((lParam >> 16) & 0xFFFF, HDHTI, 4, "Int")
      Item := DllCall("SendMessage", "Ptr", Hwnd, "UInt", 0x1206, "Ptr", 0, "Ptr", &HDHTI, "Int") + 1 ; HDM_HITTEST
      ToolTip, RDblClk on column %Item%
   }
}