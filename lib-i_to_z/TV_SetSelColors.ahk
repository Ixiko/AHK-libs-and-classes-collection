; ==================================================================================================================================
; Sets the colors for the focused (selected) item of a TreeView.
; Parameters:
;     HTV      -  handle (HWND) of the TreeView control.
;     BkgClr   -  background color as RGB integer value (0xRRGGBB).
;                 If omitted or empty the TreeViews's background color will be used.
;     TxtClr   -  text color as RGB integer value (0xRRGGBB).
;                 If omitted or empty the TreeView's text color will be used.
;                 If both BkgColor and TxtColor are omitted or empty the control will be reset to use the default colors.
;     Dummy    -  must be omitted or empty!!!
; Return value:
;     No return value.
; Remarks:
;     The function adds a handler for WM_NOTIFY messages to the chain of existing handlers. You cannot use it if you need
;     to process NM_CUSTOMDRAW notification from the TreeView controls for other purposes.
; ==================================================================================================================================
TV_SetSelColors(HTV, BkgClr := "", TxtClr := "*Default", Dummy := "") {
   Static OffCode := A_PtrSize * 2              ; offset of code        (NMHDR)
        , OffStage := A_PtrSize * 3             ; offset of dwDrawStage (NMCUSTOMDRAW)
        , OffItem := (A_PtrSize * 5) + 16       ; offset of dwItemSpec  (NMCUSTOMDRAW)
        , OffItemState := OffItem + A_PtrSize   ; offset of uItemState  (NMCUSTOMDRAW)
        , OffClrText := (A_PtrSize * 8) + 16    ; offset of clrText     (NMTVCUSTOMDRAW)
        , OffClrTextBk := OffClrText + 4        ; offset of clrTextBk   (NMTVCUSTOMDRAW)
        , Controls := {}
        , MsgFunc := Func("TV_SetSelColors")
        , IsActive := False
   Local Item, H, TV, Stage
   If (Dummy = "") { ; user call ------------------------------------------------------------------------------------------------------
      If (BkgClr = "") && (TxtClr = "")
         Controls.Delete(HTV)
      Else {
         If (BkgClr <> "")
            Controls[HTV, "B"] := ((BkgClr & 0xFF0000) >> 16) | (BkgClr & 0x00FF00) | ((BkgClr & 0x0000FF) << 16) ; RGB -> BGR
         Else
            Controls[HTV, "B"] := DllCall("SendMessage", "Ptr", HTV, "UInt", 0x111F, "Ptr", 0, "Ptr", 0, "UInt") ; TVM_GETBKCOLOR
         If (TxtClr <> "")
            Controls[HTV, "T"] := ((TxtClr & 0xFF0000) >> 16) | (TxtClr & 0x00FF00) | ((TxtClr & 0x0000FF) << 16) ; RGB -> BGR
         Else
            Controls[HTV, "T"] := DllCall("SendMessage", "Ptr", HTV, "UInt", 0x1120, "Ptr", 0, "Ptr", 0, "UInt") ; TVM_GETTEXTCOLOR
      }
      If (Controls.MaxIndex() = "") {
         If (IsActive) {
            OnMessage(0x004E, MsgFunc, 0)
            IsActive := False
      }  }
      Else If !(IsActive) {
         OnMessage(0x004E, MsgFunc)
         IsActive := True
   }  }
   Else { ; system call ------------------------------------------------------------------------------------------------------------
      ; HTV : wParam, BkgClr : lParam, TxtClr : uMsg, Dummy : hWnd
      H := NumGet(BkgClr + 0, "UPtr")
      If (TV := Controls[H]) && (NumGet(BkgClr + OffCode, "Int") = -12) { ; NM_CUSTOMDRAW
         Stage := NumGet(BkgClr + OffStage, "UInt")
         If (Stage = 0x00010001) { ; CDDS_ITEMPREPAINT
            If (NumGet(BkgClr + OffItemState, "UInt") & 0x0010) { ; CDIS_FOCUS (0x0010)
               ; Remove the CDIS_FOCUS (0x0010) state from uItemState to supress the focus rectangle
               NumPut(NumGet(BkgClr + OffItemState, "UInt") & ~0x0010, BkgClr + OffItemState, "UInt")
               , NumPut(TV.B, BkgClr + OffClrTextBk, "UInt")
               , NumPut(TV.T, BkgClr + OffClrText, "UInt")
               Return 0x00 ; CDRF_NEWFONT
         }  }
         Else If (Stage = 0x00000001) ; CDDS_PREPAINT
            Return 0x20 ; CDRF_NOTIFYITEMDRAW
         Return 0x00 ; CDRF_DODEFAULT
}  }  }