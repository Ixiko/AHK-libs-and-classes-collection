; ======================================================================================================================
; Namespace:      LVEDIT_
; AHK version:    AHK 1.1.5.+ (required)
; Function:       Helper functions for in-cell ListView editing
; Language:       English
; Tested on:      Win XPSP3, Win VistaSP2 (U32) / Win 7 (U64)
; Version:        0.1.00.02/2012-01-04/just me
; ======================================================================================================================
; ----------------------------------------------------------------------------------------------------------------------
; Define LVEDIT_ as super-global
; ----------------------------------------------------------------------------------------------------------------------
Global LVEDIT_
; ----------------------------------------------------------------------------------------------------------------------
; Register ListView for in-cell editing
; Parameter:   
;     LVHWND         -  ListView's HWND
;     BlankSubItem   -  Optional: Blank out subitem's text before editing
;                       Values:  True / False
;                       Default: False
; Return values:
;     On success: True
;     On failure: False - ErrorLevel contains an additional description
; Special features:
;     LVEDIT_NOTIFY will be installed as handler for WM_NOTIFY notifications. If there is another existing handler
;     in-cell editing won't be activated.
; ----------------------------------------------------------------------------------------------------------------------
LVEDIT_INIT(LVHWND, BlankSubItem = False) {
   Static WM_NOTIFY := 0x4E
   Static SubClassProc := 0
   If !IsObject(LVEDIT_)
      LVEDIT_ := {HWND: 0, HEDIT: 0, SIL: 0, SIT: 0, SIH: 0, EditMode: False}
   MsgHandler := OnMessage(WM_NOTIFY)
   If (MsgHandler <> "") && (MsgHandler <> "LVEDIT_NOTIFY") {
      ErrorLevel := "WM_NOTIFY is already monitored!`nCell editing is not activated!"
      Return False
   }
   If !(SubClassProc) {
      If !(SubclassProc := RegisterCallback("LVEDIT_SUBCLASSPROC", "", 6)) {
         ErrorLevel := "RegisterCallback failed -> Errorlevel: " . ErrorLevel . " - A_LastError: " . A_LastError
         Return False
      }
   }
   If !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", LVHWND, "Ptr", SubclassProc, "Ptr", LVHWND, "Ptr", 0) {
      ErrorLevel := "SetWindowSubclass failed -> Errorlevel: " . ErrorLevel . " - A_LastError: " . A_LastError
      Return False
   }
   OnMessage(WM_NOTIFY, "LVEDIT_NOTIFY")
   ; Store HWND in super-global object LVEdit
   LVEDIT_[LVHWND] := BlankSubItem ? True : False
   Return True
}
; ----------------------------------------------------------------------------------------------------------------------
; ListView Subclassproc
; ----------------------------------------------------------------------------------------------------------------------
LVEDIT_SUBCLASSPROC(H, M, W, L, I, D) {
   Static EN_SETFOCUS := 0x0100
   Static EN_CHANGE := 0x0300
   Static EN_UPDATE := 0x0400
   Static EM_SETSEL := 0x00B1
   Static EM_SCROLLCARET := 0x00B7
   Static WM_COMMAND := 0x0111
   Static LVM_GETSTRINGWIDTHA := 0x1011
   Static LVM_GETSTRINGWIDTHW := 0x1057
   Static LVM_GETSTRINGWIDTH := A_IsUnicode ? LVM_GETSTRINGWIDTHW : LVM_GETSTRINGWIDTHA
   Critical
   If (LVEDIT_.EditMode) && (H = LVEDIT_.HWND) && (M = WM_COMMAND) && (L = LVEDIT_.HEDIT) {
      N := (W >> 16)
      If (N = EN_CHANGE) || (N = EN_SETFOCUS) {
         ControlGetText, EDITTEXT, , % "ahk_id " . LVEDIT_.HEDIT
         SendMessage, LVM_GETSTRINGWIDTH, 0, &EDITTEXT, , % "ahk_id " . H
         EW := ErrorLevel + 15
         EX := LVEDIT_.SIL + 6
         EY := LVEDIT_.SIT + 2
         EH := LVEDIT_.SIH
         ControlMove, , EX, EY, EW, EH, % "ahk_id " . LVEDIT_.HEDIT
         ; PostMessage, EM_SETSEL, -2, -1, , % "ahk_id " . LV.HEDIT
      }
   }
   Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L)
}
; ----------------------------------------------------------------------------------------------------------------------
; Handler for ListView notifications
; ----------------------------------------------------------------------------------------------------------------------
LVEDIT_NOTIFY(W, L) {
   Static ITEM := -1
   Static SITEM := -1
   Static ITEMTEXT := ""
   Static LVIF_TEXT := 0x01
   Static LVM_EDITLABELA := 0x1017
   Static LVM_EDITLABELW := 0x1076
   Static LVM_EDITLABEL := A_IsUnicode ? LVM_EDITLABELW : LVM_EDITLABELA
   Static LVM_SETITEMA := 0x1006
   Static LVM_SETITEMW := 0x104C
   Static LVM_SETITEM := A_IsUnicode ? LVM_SETITEMW : LVM_SETITEMA
   Static LVM_GETEDITCONTROL := 0x1018
   Static LVM_GETSUBITEMRECT := 0x1038
   Static LVN_BEGINLABELEDITA := -105
   Static LVN_BEGINLABELEDITW := -175
   Static LVN_BEGINLABELEDIT := A_IsUnicode ? LVN_BEGINLABELEDITW : LVN_BEGINLABELEDITA
   Static LVN_ENDLABELEDITA := -106
   Static LVN_ENDLABELEDITW := -176
   Static LVN_ENDLABELEDIT := A_IsUnicode ? LVN_ENDLABELEDITW : LVN_ENDLABELEDITA
   Static NM_CLICK := -2
   Static NM_DBLCLICK := -3
   Static NOTIFICATIONS := {(NM_CLICK): 1, (NM_DBLCLICK): 1, (LVN_BEGINLABELEDIT): 1, (LVN_ENDLABELEDIT): 1}
   Static LVITEMSize := (13 * 4) + (A_PtrSize * 2) + (A_PtrSize - 4) ; Size off LVITEM
   Static NMHDRSize := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)         ; Size off NMHDR structure
   Static ITEMTextP := (5 * 4) + (A_PtrSize - 4)                     ; Offset of pszText in LVITEM
   Static ITEMTextL := ITEMTextP + A_PtrSize                         ; Offset of cchTextMax in LVITEM
   Critical
   H := NumGet(L + 0, 0, "UPtr")
   M := NumGet(L + (A_PtrSize * 2), 0, "Int")
   If (LVEDIT_.HasKey(H) && NOTIFICATIONS.HasKey(M)) {
      If (LVEDIT_.EditMode) { 
         ; EndLabelEdit ------------------------------------------------------------------------------------------------
         If (M = LVN_ENDLABELEDIT) {
            If NumGet(L + NMHDRSize, ITEMTextP, "Ptr") {
               Numput(SITEM, L + NMHDRSize, 8, "Int")
            } Else {             ; LABELEDIT was cancelled
               If LVEDIT_[H] {   ; Subitem was blanked out -> restore subitem's text
                  VarSetCapacity(LVITEM, LVITEMSize, 0)
                  NumPut(LVIF_TEXT, LVITEM, 0, "UInt")
                  NumPut(ITEM, LVITEM, 4, "Int")
                  NumPut(SITEM, LVITEM, 8, "Int")
                  NumPut(&ITEMTEXT, LVITEM, ITEMTextP, "Ptr")
                  SendMessage, LVM_SETITEM, 0, &LVITEM, , % "ahk_id " . LVEDIT_.HWND
               }
            }
            ITEM := -1
            SITEM := -1
            ITEMTEXT := ""
            LVEDIT_.HWND := 0
            LVEDIT_.HEDIT := 0
            LVEDIT_.SIL := 0
            LVEDIT_.SIT := 0
            LVEDIT_.SIH := 0
            LVEDIT_.EditMode := False
            Return True
         }
      } Else {
         ; Single click ------------------------------------------------------------------------------------------------
         If (M = NM_CLICK) {
            ITEM := NumGet(L + NMHDRSize, 0, "Int")
            SITEM := NumGet(L + NMHDRSize, 4, "Int")
            If !(ITEM >= 0 && SITEM >= 0)
               ITEM := -1, SITEM := -1
         ; Double click ------------------------------------------------------------------------------------------------
         } Else If (M = NM_DBLCLICK) {
            ITEM := NumGet(L + NMHDRSize, 0, "Int")
            SITEM := NumGet(L + NMHDRSize, 4, "Int")
            If (ITEM >= 0 && SITEM >= 0)
               PostMessage, LVM_EDITLABEL, ITEM, 0, , % "ahk_id " . H
            Else
               ITEM := -1, SITEM := -1
         ; BeginLabelEdit ----------------------------------------------------------------------------------------------
         } Else If (M = LVN_BEGINLABELEDIT) {
            LVEDIT_.HWND := H
            ControlGetPos, LX, LY, , , , % "ahk_id " . H
            SendMessage, LVM_GETEDITCONTROL, 0, 0, , % "ahk_id " . H
            LVEDIT_.HEDIT := ErrorLevel
            ControlGet, Columns, List, Selected, , % "ahk_id " . H
            StringSplit, Column, Columns, %A_Tab%, `n
            I := SITEM + 1
            ITEMTEXT := Column%I%
            If (SITEM > 0) {
               ControlSetText, , % ITEMTEXT, % "ahk_id " . LVEDIT_.HEDIT
               If LVEDIT_[H] {   ; Subitem has to be blanked out
                  VarSetCapacity(LVITEM, LVITEMSize, 0)
                  NumPut(LVIF_TEXT, LVITEM, 0, "UInt")
                  NumPut(ITEM, LVITEM, 4, "Int")
                  NumPut(SITEM, LVITEM, 8, "Int")
                  SendMessage, LVM_SETITEM, 0, &LVITEM, , % "ahk_id " . LVEDIT_.HWND
               }
            }
            VarSetCapacity(RECT, 16, 0)
            NumPut(SITEM, RECT, 4, "Int")
            SendMessage, LVM_GETSUBITEMRECT, ITEM, &RECT, , % "ahk_id " . H
            LVEDIT_.SIL := NumGet(RECT, 0, "Int") + LX
            LVEDIT_.SIT := NumGet(RECT, 4, "Int") + LY
            LVEDIT_.SIH := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
            LVEDIT_.EditMode := True
            Return False
         }
      }
   }
}
