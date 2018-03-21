; ======================================================================================================================
; Namespace:      LV_InCellEdit
; AHK version:    AHK 1.1.5.+ (required)
; Function:       Helper object and functions for in-cell ListView editing
; Language:       English
; Tested on:      Win XPSP3 (ANSI), Win VistaSP2 (U32), Win 7 (U64)
; Version:        1.1.01.00/2012-03-18/just me
; ======================================================================================================================
; CLASS LV_InCellEdit
;
; Unlike all other in-cell editing scripts, this class is using the ListViews built-in edit control. Its advantage
; is that you don't have to care about the font and the GUI, and most of the job can be done by handling common 
; ListView notifications.
; On the other hand the ListViews must be subclassed while editing. Furthermore I've still found no way to prevent them
; from blanking out the first subitem of the row while editing another subitem. The only known workaround is to add a
; hidden first column.
;
; The class provides three public methods to register / unregister in-cell editing for ListView controls and to
; register / unregister the provided message handler function for WM_NOTIFY messages (see below).
;
; If a ListView is registered for in-cell editing a doubleclick on any cell will show an Edit control within this cell
; allowing to edit the current content. The default behavior for editing the first column by two subsequent single
; clicks is disabled. You have to press "Esc" to cancel editing, otherwise the changed content of the Edit will be
; stored in the cell. ListViews must have the -ReadOnly option to be editable.
;
; While editing, "Esc", "Tab", "Shift+Tab", "Down", and "Up" keys are registered as hotkeys. Esc will cancel editing
; without changing the value of the current cell. All other hotkeys will store the changed content of the edit in the
; current cell and continue editing for the next (Tab), previous (Shift+Tab), upper (Up), or lower (Down) cell. You
; must not use this hotkeys for other purposes while editing.
;
; All changes are stored in LV_InCellEdit.Changed per HWND. You may track the changes by triggering (A_GuiEvent == "F")
; in the ListViews gLabels and checking LV_InCellEdit.Changed.HasKey(ListViewHWND) as shown in the sample scipt.
; If "True", LV_InCellEdit.Changed[ListViewHWND] contains an array of objects with keys "Row" (1-based row number),
; "Col" (1-based column number), and "Txt" (new content). LV_InCellEdit.Changed is the one and only key intended to be
; accessed directly from outside the class.
;
; If you want to use the provided message handler you must call LV_InCellEdit.OnMessage() once before editing any
; controls. Otherwise you should integrate the code within LV_InCellEdit_WM_NOTIFY into your own notification handler.
; Without the notification handling editing won't work.
; ======================================================================================================================
Class LV_InCellEdit {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE PROPERTIES ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Static Attached := {}
   Static Changed := {}
   Static LVSubClassProc := RegisterCallback("LV_InCellEdit_LVSUBCLASSPROC", "", 6)
   Static LVIF_TEXT := 0x0001
   Static LVM_GETITEMTEXT := A_IsUnicode ? 0x1073 : 0x102D           ; LVM_GETITEMTEXTW : LVM_GETITEMTEXTA
   Static LVM_SETITEMTEXT := A_IsUnicode ? 0x1074 : 0x102E           ; LVM_SETITEMTEXTW : LVM_SETITEMTEXTA
   Static LVM_SETITEM := A_IsUnicode ? 0x104C : 0x1006               ; LVM_SETITEMW : LVM_SETITEMA
   Static NMHDRSize := (2 * A_PtrSize) + 4 + (A_PtrSize - 4)         ; Size off NMHDR structure
   Static LVITEMSize := (13 * 4) + (A_PtrSize * 2) + (A_PtrSize - 4) ; Size off LVITEM
   Static ITEMTextP := (5 * 4) + (A_PtrSize - 4)                     ; Offset of pszText in LVITEM
   Static ITEMTextL := LV_InCellEdit.ITEMTextP + A_PtrSize           ; Offset of cchTextMax in LVITEM
   Static OSVersion := LV_InCellEdit.GetOsVersion()
   ; Hotkeys
   Static HK_Esc   := 0x801B  ; Esc : cancel
   Static HK_Right := 0x8009  ; Tab : next cell
   Static HK_Left  := 0x8409  ; Shift+Tab : previous cell
   Static HK_Down  := 0x8028  ; Down : lower cell
   Static HK_Up    := 0x8026  ; Up : upper cell
   ; Current values
   Static ITEM := -1
   Static SITEM := -1
   Static ITEMTEXT := ""
   Static HWND := 0
   Static HEDIT := 0
   Static Rows := 0
   Static Cols := 0
   Static Cancelled := False
   Static Next := False
   Static DW := 0
   Static EX := 0
   Static EY := 0
   Static EW := 0
   Static EH := 0
   Static LX := 0
   Static LY := 0
   Static LR := 0
   Static LW := 0
   Static SW := 0
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; META FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   __New(P*) {
      Return False   ; There is no reason to instantiate this class.
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE METHODS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; GetOSVersion
   ; ===================================================================================================================
   GetOsVersion() {
      Return (V := DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) . "." . ((V >> 8) & 0xFF)
   }
   ; ===================================================================================================================
   ; Next subItem
   ; ===================================================================================================================
   NextSubItem(H, K) {
      Static LVM_ENSUREVISIBLE  := 0x1013
      Static LVM_GETCOLUMNWIDTH := 0x101D
      Static LVM_GETSUBITEMRECT := 0x1038
      Static LVM_SCROLL         := 0x1014
      Static WM_LBUTTONDOWN     := 0x0201
      Static WM_LBUTTONUP       := 0x0202
      Static WM_LBUTTONDBLCLK   := 0x0203
      ; OutputDebug, NextSubItem
      ; Find the next subitem
      ITEM := This.ITEM
      SITEM := This.SITEM
      If (K = This.HK_Right) {
         SITEM++
      } Else If (K = This.HK_Left) {
         SITEM--
         If (SITEM = 0) && This.Attached[H].Skip0 {
            SITEM--
         }
      } Else If (K = This.HK_Down) {
         ITEM++
      } Else If (K = This.HK_Up) {
         ITEM--
      }
      If (SITEM > This.Cols) {
         ITEM++
         SITEM := This.Attached[H].Skip0 ? 1 : 0
      } Else If (SITEM < 0) {
         SITEM := This.Cols
         ITEM--
      }
      If (ITEM > This.Rows) {
         ITEM := 0
      } Else If (ITEM < 0) {
         ITEM := This.Rows
      }
      If (ITEM <> This.ITEM) {
         SendMessage, LVM_ENSUREVISIBLE, ITEM, False, , % "ahk_id " . H
      }
      VarSetCapacity(RECT, 16, 0)
      NumPut(SITEM, RECT, 4, "Int")
      SendMessage, LVM_GETSUBITEMRECT, ITEM, &RECT, , % "ahk_id " . H
      X := NumGet(RECT, 0, "Int")
      Y := NumGet(RECT, 4, "Int")
      If (SITEM = 0) {
         SendMessage, LVM_GETCOLUMNWIDTH, 0, 0, , % "ahk_id " . H
         W := ErrorLevel
      } Else {
         W := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
      }
      R := This.LW - (This.DX * 2) - This.SW
      S := 0
      If (X < 0) {
         S := X
      } Else If ((X + W) > R) {
         S := X + W - R + This.DX
      }
      If (S) {
         SendMessage, LVM_SCROLL, S, 0, , % "ahk_id " . H
      }
      Point := (X - S + (This.DX * 2)) + ((Y + (This.DY * 2)) << 16)
      SendMessage, WM_LBUTTONDOWN, 0, Point, , % "ahk_id " . H
      SendMessage, WM_LBUTTONUP, 0, Point, , % "ahk_id " . H
      SendMessage, WM_LBUTTONDBLCLK, 0, Point, , % "ahk_id " . H
      SendMessage, WM_LBUTTONUP, 0, Point, , % "ahk_id " . H
   }
   ; ===================================================================================================================
   ; Register/UnRegister hotkeys
   ; ===================================================================================================================
   RegisterHotkeys(H, Register = True) {
      ; MOD_SHIFT := 0x0004
      If (Register) {   ; Register
         DllCall("User32.dll\RegisterHotKey", "Ptr", H, "Int", This.HK_Esc,   "UInt", 0, "UInt", 0x1B)
         DllCall("User32.dll\RegisterHotKey", "Ptr", H, "Int", This.HK_Right, "UInt", 0, "UInt", 0x09)
         DllCall("User32.dll\RegisterHotKey", "Ptr", H, "Int", This.HK_Left,  "UInt", 4, "UInt", 0x09)
         DllCall("User32.dll\RegisterHotKey", "Ptr", H, "Int", This.HK_Down,  "UInt", 0, "UInt", 0x28)
         DllCall("User32.dll\RegisterHotKey", "Ptr", H, "Int", This.HK_Up,    "UInt", 0, "UInt", 0x26)
      } Else {          ; Unregister
         DllCall("User32.dll\UnregisterHotKey", "Ptr", H, "Int", This.HK_Esc)
         DllCall("User32.dll\UnregisterHotKey", "Ptr", H, "Int", This.HK_Right)
         DllCall("User32.dll\UnregisterHotKey", "Ptr", H, "Int", This.HK_Left)
         DllCall("User32.dll\UnregisterHotKey", "Ptr", H, "Int", This.HK_Down)
         DllCall("User32.dll\UnregisterHotKey", "Ptr", H, "Int", This.HK_Up)
      }
   }
   ; ===================================================================================================================
   ; LVN_BEGINLABELEDIT notification
   ; ===================================================================================================================
   On_LVN_BEGINLABELEDIT(H, L) {
      Static LVM_GETCOLUMNWIDTH := 0x101D
      Static LVM_GETEDITCONTROL := 0x1018
      Static LVM_GETSUBITEMRECT := 0x1038
      Static TBufSize := A_IsUnicode ? 2048 : 1024
      Static Indent := 4   ; indent of the Edit control, 4 seems to be reasonable for XP, Vista, and 7
      ; OutputDebug, % "BEGINLABELEDIT - " . This.Next
      If (This.ITEM = -1) || (This.SITEM = -1)
         Return True
      SendMessage, LVM_GETEDITCONTROL, 0, 0, , % "ahk_id " . H
      This.HEDIT := ErrorLevel
      VarSetCapacity(ITEMTEXT, TBufSize, 0)
      VarSetCapacity(LVITEM, This.LVITEMSize, 0)
      NumPut(This.ITEM, LVITEM, 4, "Int")
      NumPut(This.SITEM, LVITEM, 8, "Int")
      NumPut(&ITEMTEXT, LVITEM, This.ITEMTextP, "Ptr")
      NumPut(1024 + 1, LVITEM, This.ITEMTextL, "Int")
      SendMessage, This.LVM_GETITEMTEXT, This.ITEM, &LVITEM, , % "ahk_id " . H
      This.ITEMTEXT := StrGet(&ITEMTEXT, ErrorLevel)
      ControlSetText, , % This.ITEMTEXT, % "ahk_id " . This.HEDIT
      VarSetCapacity(RECT, 16, 0)
      NumPut(This.SITEM, RECT, 4, "Int")
      SendMessage, LVM_GETSUBITEMRECT, This.ITEM, &RECT, , % "ahk_id " . H
      This.EX := NumGet(RECT, 0, "Int") + This.LX + This.DX + Indent
      This.EY := NumGet(RECT, 4, "Int") + This.LY + This.DY
      If (This.OSVersion < 6)
         This.EY -= 1 ; subtract 1 for WinXP
      If (This.SITEM = 0) {
         SendMessage, LVM_GETCOLUMNWIDTH, 0, 0, , % "ahk_id " . H
         This.EW := ErrorLevel
      } Else {
         This.EW := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
      }
      This.EW -= Indent
      This.EH := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
      ; Register subclass callback
      DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", H, "Ptr", This.LVSubClassProc, "Ptr", H, "Ptr", 0)
      ; Register hotkeys
      If !(This.Next) {
         This.RegisterHotkeys(H)
      }
      This.Cancelled := False
      This.Next := False
      Return False
   }
   ; ===================================================================================================================
   ; LVN_ENDLABELEDIT notification
   ; ===================================================================================================================
   On_LVN_ENDLABELEDIT(H, L) {
      Static ITEMTEXT
      ; OutputDebug, % "ENDLABELEDIT - " . This.Next
      ; Unregister subclass callback
      DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", H, "Ptr", This.LVSubClassProc, "Ptr", H)
      ; Unregister hotkeys
      If !(This.Next) {
         This.RegisterHotkeys(H, False)
      }
      If !(This.Cancelled) {
         ; Store edit's content in subitem if changed
         ControlGetText, ITEMTEXT, , % "ahk_id " . This.HEDIT
         If (ITEMTEXT <> This.ITEMTEXT) {
            If !(This.Changed.HasKey(H))
               This.Changed[H] := []
            This.Changed[H].Insert({Row: This.ITEM + 1, Col: This.SITEM + 1, Txt: ITEMTEXT})
            VarSetCapacity(LVITEM, This.LVITEMSize, 0)
            NumPut(This.ITEM, LVITEM, 4, "Int")
            NumPut(This.SITEM, LVITEM, 8, "Int")
            NumPut(&ITEMTEXT, LVITEM, This.ITEMTextP, "Ptr")
            SendMessage, This.LVM_SETITEMTEXT, This.ITEM, &LVITEM, , % "ahk_id " . H
         }
      }
      If !(This.Next) {
         This.ITEM := This.SITEM := -1
      }
      This.Cancelled := False
      This.Next := False
      Return False
   }
   ; ===================================================================================================================
   ; NM_DBLCLICK notification
   ; ===================================================================================================================
   On_NM_DBLCLICK(H, L) {
      Static LVM_EDITLABELA := 0x1017
      Static LVM_EDITLABELW := 0x1076
      Static LVM_EDITLABEL := A_IsUnicode ? LVM_EDITLABELW : LVM_EDITLABELA
      Static LVM_GETCOLUMNWIDTH := 0x101D
      Static LVM_GETSTRINGWIDTHA := 0x1011
      Static LVM_GETSTRINGWIDTHW := 0x1057
      Static LVM_GETSTRINGWIDTH := A_IsUnicode ? LVM_GETSTRINGWIDTHW : LVM_GETSTRINGWIDTHA
      Static LVM_GETSUBITEMRECT := 0x1038
      Static LVM_SCROLL := 0x1014
      Static WS_VSCROLL := 0x200000
      ; OutputDebug, % "NMDBLCLICK - " . This.Next
      This.ITEM := This.SITEM := -1
      ITEM := NumGet(L + This.NMHDRSize, 0, "Int")
      SITEM := NumGet(L + This.NMHDRSize, 4, "Int")
      If (ITEM >= 0) && (SITEM >= 0) {
         This.ITEM := ITEM
         This.SITEM := SITEM
         If !(This.Next) {
            This.HWND := H
            ControlGet, V, List, Count, , % "ahk_id " . H
            This.Rows := V - 1
            ControlGet, V, List, Count Col, , % "ahk_id " . H
            This.Cols := V - 1
            NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO)
            DllCall("User32.dll\GetWindowInfo", "Ptr", H, "Ptr", &WINDOWINFO)
            This.DX := NumGet(WINDOWINFO, 20, "Int") - NumGet(WINDOWINFO, 4, "Int")
            This.DY := NumGet(WINDOWINFO, 24, "Int") - NumGet(WINDOWINFO, 8, "Int")
            Styles := NumGet(WINDOWINFO, 36, "UInt")
            SendMessage, LVM_GETSTRINGWIDTH, 0, "WW", , % "ahk_id " . H
            This.DW := ErrorLevel
            SBW := 0
            If (Styles & WS_VSCROLL)
               SysGet, SBW, 2
            ControlGetPos, LX, LY, LW, , , % "ahk_id " . H
            This.LX := LX
            This.LY := LY
            This.LR := LX + LW - (This.DX * 2) - SBW
            This.LW := LW
            This.SW := SBW
            VarSetCapacity(RECT, 16, 0)
            NumPut(SITEM, RECT, 4, "Int")
            SendMessage, LVM_GETSUBITEMRECT, ITEM, &RECT, , % "ahk_id " . H
            X := NumGet(RECT, 0, "Int")
            If (SITEM = 0) {
               SendMessage, LVM_GETCOLUMNWIDTH, 0, 0, , % "ahk_id " . H
               W := ErrorLevel
            } Else {
               W := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
            }
            R := LW - (This.DX * 2) - SBW
            If (X < 0) {
               SendMessage, LVM_SCROLL, X, 0, , % "ahk_id " . H
            } Else If ((X + W) > R) {
               SendMessage, LVM_SCROLL, X + W - R + This.DX, 0, , % "ahk_id " . H
            }
         }
         PostMessage, LVM_EDITLABEL, ITEM, 0, , % "ahk_id " . H
      }
      Return False
   }
   ; ===================================================================================================================
   ; SubClassProc for ListViews 
   ; ===================================================================================================================
   SubClassProc(H, M, W, L, I, D) {
      Static EC_LEFTMARGIN := 0x01
      Static EN_SETFOCUS := 0x0100
      Static EN_KILLFOCUS := 0x0200
      Static EN_CHANGE := 0x0300
      Static EN_UPDATE := 0x0400
      Static EM_SETSEL := 0x00B1
      Static EM_SETMARGINS := 0x00D3
      Static WM_COMMAND := 0x0111
      Static WM_HOTKEY  := 0x0312
      Static LVM_CANCELEDITLABEL := 0x10B3
      Static LVM_GETSTRINGWIDTHA := 0x1011
      Static LVM_GETSTRINGWIDTHW := 0x1057
      Static LVM_GETSTRINGWIDTH := A_IsUnicode ? LVM_GETSTRINGWIDTHW : LVM_GETSTRINGWIDTHA
      If (H = This.HWND) {
         If (L = This.HEDIT) && (M = WM_COMMAND) {
            N := (W >> 16)
            If (N = EN_UPDATE) || (N = EN_CHANGE) || (N = EN_SETFOCUS) {
               ; OutputDebug, SubClassProc Edit : %N%
               If (N = EN_UPDATE)
                  Return 0
               If (N = EN_SETFOCUS)
                  SendMessage, EM_SETMARGINS, EC_LEFTMARGIN, 0, , % "ahk_id " . L
               ControlGetText, EDITTEXT, , % "ahk_id " . L
               SendMessage, LVM_GETSTRINGWIDTH, 0, &EDITTEXT, , % "ahk_id " . H
               EW := ErrorLevel + This.DW
               EX := This.EX
               EY := This.EY
               EH := This.OSVersion < 6 ? This.EH + 3 : This.EH ; add 3 for WinXP
               If ((EX + EW) > This.LR) {
                  EW := This.LR - EX
               }
               ControlMove, , EX, EY, EW, EH, % "ahk_id " . L
            }
         } Else If (M = WM_HOTKEY) {
            ; OutputDebug, SubClassProc Hotkey : %W%
            If (W = This.HK_Esc) {
               This.Cancelled := True
               PostMessage, LVM_CANCELEDITLABEL, 0, 0, , % "ahk_id " . H
            } Else {
               This.Next := True
               SendMessage, LVM_CANCELEDITLABEL, 0, 0, , % "ahk_id " . H
               This.Next := True
               This.NextSubItem(H, W)
            }
            Return False
         }
      }
      Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L)
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC INTERFACE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; METHOD OnMessage      Register / unregister LV_InCellEdit message handler for WM_NOTIFY messages
   ; Parameters:           DoIt        -  True / False
   ;                                      Default: True
   ; Return Value:         Always True
   ; ===================================================================================================================
   OnMessage(DoIt = True) {
      Static MessageHandler := "LV_InCellEdit_WM_NOTIFY"
      Static WM_NOTIFY := 0x4E
      If (DoIt) {
         OnMessage(WM_NOTIFY, MessageHandler)
      } Else If (MessageHandler = OnMessage(WM_NOTIFY)) {
         OnMessage(WM_NOTIFY, "")
      }
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Attach         Register ListView for in-cell editing
   ; Parameters:           HWND           -  ListView's HWND                                                (Integer)
   ;                       ----------------  Optional:
   ;                       HiddenCol1     -  ListView with hidden first column                              (Bool)
   ;                                         Values:  True / False
   ;                                         Default: False
   ; Return values:        Always True
   ; ===================================================================================================================
   Attach(HWND, HiddenCol1 = False) {
      ; Store HWND and options
      This.Attached[HWND] := {Skip0: HiddenCol1}
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Detach         Restore ListView's default behavior
   ; Parameters:           HWND           -  ListView's HWND                                                (Integer)
   ; Return values:        Always True
   ; ===================================================================================================================
   Detach(HWND) {
      ; Remove HWND
      This.Attached.Remove(HWND, "")
      Return True
   }
}
; ======================================================================================================================
; PRIVATE ListView subclassproc
; ======================================================================================================================
LV_InCellEdit_LVSUBCLASSPROC(H, M, W, L, I, D) {
   ; Critical
   Return LV_InCellEdit.SubClassProc(H, M, W, L, I, D)
}
; ======================================================================================================================
; PRIVATE ListView notification handler
; ======================================================================================================================
LV_InCellEdit_WM_NOTIFY(W, L) {
   Static LVN_BEGINLABELEDITA := -105
   Static LVN_BEGINLABELEDITW := -175
   Static LVN_ENDLABELEDITA := -106
   Static LVN_ENDLABELEDITW := -176
   Static NM_CLICK := -2
   Static NM_DBLCLICK := -3
   H := NumGet(L + 0, 0, "UPtr")
   M := NumGet(L + (A_PtrSize * 2), 0, "Int")
   If (LV_InCellEdit.Attached.HasKey(H)) {
      ; BeginLabelEdit -------------------------------------------------------------------------------------------------
      If (M = LVN_BEGINLABELEDITW) || (M = LVN_BEGINLABELEDITA) {
         Return LV_InCellEdit.On_LVN_BEGINLABELEDIT(H, L)
      }
      ; EndLabelEdit ---------------------------------------------------------------------------------------------------
      If (M = LVN_ENDLABELEDITW) || (M = LVN_ENDLABELEDITA) {
         Return LV_InCellEdit.On_LVN_ENDLABELEDIT(H, L)
      }
      ; Double click ---------------------------------------------------------------------------------------------------
      If (M = NM_DBLCLICK) {
         LV_InCellEdit.On_NM_DBLCLICK(H, L)
      }
   }
}
; ======================================================================================================================