; ======================================================================================================================
; Namespace:      LV_InCellEdit
; Function:       Support for in-cell ListView editing.
; Tested with:    AHK 1.1.20.03 (1.1.20+ required)
; Tested on:      Win 8.1 Pro (x64)
; Change History: 1.2.00.00/2015-03-29/just me - New version based on AHK 1.1.20+ features.
;                 1.1.04.00/2014-03-22/just me - Added method EditCell
;                 1.1.03.00/2012-05-05/just me - Added back option BlankSubItem for method Attach
;                 1.1.02.00/2012-05-01/just me - Added method SetColumns
;                 1.1.01.00/2012-03-18/just me
; ======================================================================================================================
; CLASS LV_InCellEdit
;
; Unlike other in-cell editing scripts, this class is using the ListViews built-in edit control.
; Advantage:
;     You don't have to care about the font and the GUI, and most of the job can be done by handling common ListView
;     notifications.
; Disadvantage:
;     I've still found no way to prevent the ListView from blanking out the first subitem of the row while editing
;     another subitem. The only known workaround is to add a hidden first column.
;
; The class provides methods to restrict editing to certain columns, to directly start editing of a specified cell,
; and to deactivate/activate the built-in message handler for WM_NOTIFY messages (see below).
;
; The message handler for WM_NOTIFY messages will be activated for the specified ListView whenever a new instance is
; created. As long as the message handler is activated a double-click on any cell will show an Edit control within this
; cell allowing to edit the current content. The default behavior for editing the first column by two subsequent single
; clicks is disabled. You have to press "Esc" to cancel editing, otherwise the content of the Edit will be stored in
; the current cell. ListViews must have the -ReadOnly option to be editable.
;
; While editing, "Esc", "Tab", "Shift+Tab", "Down", and "Up" keys are registered as hotkeys. "Esc" will cancel editing
; without changing the value of the current cell. All other hotkeys will store the content of the edit in the current
; cell and continue editing for the next (Tab), previous (Shift+Tab), upper (Up), or lower (Down) cell. You cannot use
; the keys for other purposes while editing.
;
; All changes are stored in MyInstance.Changed. You may track the changes by triggering (A_GuiEvent == "F") in the
; ListView's gLabel and checking MyInstance["Changed"] as shown in the sample scipt. If "True", MyInstance.Changed
; contains an array of objects with keys "Row" (row number), "Col" (column number), and "Txt" (new content).
; Changed is one of the two keys intended to be accessed directly from outside the class.
;
; If you want to temporarily disable in-cell editing call MyInstance.OnMessage(False). This must be done also before
; you try to destroy the instance. To enable it again, call MyInstance.OnMessage().
;
; To avoid the loss of Gui events and messages the message handler might need to be 'critical'. This can be
; achieved by setting the instance property 'Critical' to the required value (e.g. MyInstance.Critical := 100).
; New instances default to 'Critical, Off'. Though sometimes needed, ListViews or the whole Gui may become
; unresponsive under certain circumstances if Critical is set and the ListView has a g-label.
; ======================================================================================================================
Class LV_InCellEdit {
   ; Instance properties -----------------------------------------------------------------------------------------------
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; META FUNCTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; __New()         Creates a new LV_InCellEdit instance for the specified ListView.
   ; Parameters:     HWND           -  ListView's HWND
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 HiddenCol1     -  ListView with hidden first column
   ;                                   Values:  True / False
   ;                                   Default: False
   ;                 BlankSubItem   -  Blank out subitem's text while editing
   ;                                   Values:  True / False
   ;                                   Default: False
   ; ===================================================================================================================
   __New(HWND, HiddenCol1 := False, BlankSubItem := False) {
      If (This.Base.Base.__Class) ; do not instantiate instances
         Return False
      If This.Attached[HWND] ; HWND is already attached
         Return False
      If !DllCall("IsWindow", "Ptr", HWND) ; invalid HWND
         Return False
      VarSetCapacity(Class, 512, 0)
      DllCall("GetClassName", "Ptr", HWND, "Str", Class, "Int", 256)
      If (Class <> "SysListView32") ; HWND doesn't belong to a ListView
         Return False
      ; ----------------------------------------------------------------------------------------------------------------
      ; Set LVS_EX_DOUBLEBUFFER (0x010000) style to avoid drawing issues.
      SendMessage, 0x1036, 0x010000, 0x010000, , % "ahk_id " . HWND ; LVM_SETEXTENDEDLISTVIEWSTYLE
      This.HWND := HWND
      This.HEDIT := 0
      This.Item := -1
      This.SubItem := -1
      This.ItemText := ""
      This.RowCount := 0
      This.ColCount := 0
      This.Cancelled := False
      This.Next := False
      This.Skip0 := !!HiddenCol1
      This.Blank := !!BlankSubItem
      This.Critical := "Off"
      This.DW := 0
      This.EX := 0
      This.EY := 0
      This.EW := 0
      This.EH := 0
      This.LX := 0
      This.LY := 0
      This.LR := 0
      This.LW := 0
      This.SW := 0
      This.OnMessage()
      This.Attached[HWND] := True
   }
   ; ===================================================================================================================
   __Delete() {
      This.Attached.Remove(This.HWND, "")
      WinSet, Redraw, , % "ahk_id " . This.HWND
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC INTERFACE ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ===================================================================================================================
   ; EditCell        Edit the specified cell, if possible.
   ; Parameters:     Row   -  1-based row number
   ;                 Col   -  1-based column number
   ;                          Default: 0 - edit the first editable column
   ; Return values:  True on success; otherwise False
   ; ===================================================================================================================
   EditCell(Row, Col := 0) {
      If !This.HWND
         Return False
      ControlGet, Rows, List, Count, , % "ahk_id " . This.HWND
      This.RowCount := Rows - 1
      ControlGet, ColCount, List, Count Col, , % "ahk_id " . This.HWND
      This.ColCount := ColCount - 1
      If (Col = 0) {
         If (This["Columns"])
            Col := This.Columns.MinIndex() + 1
         ELse If This.Skip0
            Col := 2
         Else
            Col := 1
      }
      If (Row < 1) || (Row > Rows) || (Col < 1) || (Col > ColCount)
         Return False
      If (Column = 1) && This.Skip0
         Col := 2
      If (This["Columns"])
         If !This.Columns[Col - 1]
            Return False
      VarSetCapacity(LPARAM, 1024, 0)
      NumPut(Row - 1, LPARAM, (A_PtrSize * 3) + 0, "Int")
      NumPut(Col - 1, LPARAM, (A_PtrSize * 3) + 4, "Int")
      This.NM_DBLCLICK(&LPARAM)
      Return True
   }
   ; ===================================================================================================================
   ; SetColumns      Sets the columns you want to edit
   ; Parameters:     ColNumbers* -  zero or more numbers of column which shall be editable. If entirely omitted,
   ;                                the ListView will be reset to enable editing of all columns.
   ; Return values:  True on success; otherwise False
   ; ===================================================================================================================
   SetColumns(ColNumbers*) {
      If !This.HWND
         Return False
      This.Remove("Columns")
      If (ColNumbers.MinIndex() = "")
         Return True
      ControlGet, ColCount, List, Count Col, , % "ahk_id " . This.HWND
      Indices := []
      For Each, Col In ColNumbers {
         If Col Is Not Integer
            Return False
         If (Col < 1) || (Col > ColCount)
            Return False
         Indices[Col - 1] := True
      }
      This["Columns"] := Indices
      Return True
   }
   ; ===================================================================================================================
   ; OnMessage       Activate / deactivate the message handler for WM_NOTIFY messages for this ListView
   ; Parameters:     Apply    -  True / False
   ;                             Default: True
   ; Return Value:   Always True
   ; ===================================================================================================================
   OnMessage(Apply := True) {
      If !This.HWND
         Return False
      If (Apply) && !This.HasKey("NotifyFunc") {
         This.NotifyFunc := ObjBindMethod(This, "On_WM_NOTIFY")
         OnMessage(0x004E, This.NotifyFunc) ; add the WM_NOTIFY message handler
      }
      Else If !(Apply) && This.HasKey("NotifyFunc") {
         OnMessage(0x004E, This.NotifyFunc, 0) ; remove the WM_NOTIFY message handler
         This.NotifyFunc := ""
         This.Remove("NotifyFunc")
      }
      WinSet, Redraw, , % "ahk_id " . This.HWND
      Return True
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE PROPERTIES ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; Class properties --------------------------------------------------------------------------------------------------
   Static Attached := {}
   Static OSVersion := DllCall("GetVersion", "UChar")
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE METHODS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; -------------------------------------------------------------------------------------------------------------------
   ; WM_COMMAND message handler for edit notifications
   ; -------------------------------------------------------------------------------------------------------------------
   On_WM_COMMAND(W, L, M, H) {
      ; LVM_GETSTRINGWIDTHW = 0x1057, LVM_GETSTRINGWIDTHA = 0x1011
      If (L = This.HEDIT) {
         N := (W >> 16)
         If (N = 0x0400) || (N = 0x0300) || (N = 0x0100) { ; EN_UPDATE | EN_CHANGE | EN_SETFOCUS
            If (N = 0x0100) ; EN_SETFOCUS
               SendMessage, 0x00D3, 0x01, 0, , % "ahk_id " . L ; EM_SETMARGINS, EC_LEFTMARGIN
            ControlGetText, EditText, , % "ahk_id " . L
            SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % &EditText, , % "ahk_id " . This.HWND
            EW := ErrorLevel + This.DW
            , EX := This.EX
            , EY := This.EY
            , EH := This.EH + (This.OSVersion < 6 ? 3 : 0) ; add 3 for WinXP
            If (EW < This.MinW)
               EW := This.MinW
            If (EX + EW) > This.LR
               EW := This.LR - EX
            ControlMove, , %EX%, %EY%, %EW%, %EH%, % "ahk_id " . L
            If (N = 0x0400) ; EN_UPDATE
               Return 0
         }
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; WM_HOTKEY message handler
   ; -------------------------------------------------------------------------------------------------------------------
   On_WM_HOTKEY(W, L, M, H) {
      ; LVM_CANCELEDITLABEL = 0x10B3, Hotkeys: 0x801B  (Esc -> cancel)
      If (H = This.HWND) {
         If (W = 0x801B) { ; Esc
            This.Cancelled := True
            PostMessage, 0x10B3, 0, 0, , % "ahk_id " . H
         }
         Else {
            This.Next := True
            SendMessage, 0x10B3, 0, 0, , % "ahk_id " . H
            This.Next := True
            This.NextSubItem(W)
         }
         Return False
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; WM_NOTIFY message handler
   ; -------------------------------------------------------------------------------------------------------------------
   On_WM_NOTIFY(W, L) {
      Critical, % This.Critical
      If (H := NumGet(L + 0, 0, "UPtr") = This.HWND) {
         M := NumGet(L + (A_PtrSize * 2), 0, "Int")
         ; BeginLabelEdit -------------------------------------------------------------------------------------------------
         If (M = -175) || (M = -105) ; LVN_BEGINLABELEDITW || LVN_BEGINLABELEDITA
            Return This.LVN_BEGINLABELEDIT(L)
         ; EndLabelEdit ---------------------------------------------------------------------------------------------------
         If (M = -176) || (M = -106) ; LVN_ENDLABELEDITW || LVN_ENDLABELEDITA
            Return This.LVN_ENDLABELEDIT(L)
         ; Double click ---------------------------------------------------------------------------------------------------
         If (M = -3) ; NM_DBLCLICK
            This.NM_DBLCLICK(L)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; LVN_BEGINLABELEDIT notification
   ; -------------------------------------------------------------------------------------------------------------------
   LVN_BEGINLABELEDIT(L) {
      Static Indent := 4   ; indent of the Edit control, 4 seems to be reasonable for XP, Vista, and 7
      If (This.Item = -1) || (This.SubItem = -1)
         Return True
      H := This.HWND
      SendMessage, 0x1018, 0, 0, , % "ahk_id " . H ; LVM_GETEDITCONTROL
      This.HEDIT := ErrorLevel
      , VarSetCapacity(ItemText, 2048, 0) ; text buffer
      , VarSetCapacity(LVITEM, 40 + (A_PtrSize * 5), 0) ; LVITEM structure
      , NumPut(This.Item, LVITEM, 4, "Int")
      , NumPut(This.SubItem, LVITEM, 8, "Int")
      , NumPut(&ItemText, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
      , NumPut(1024 + 1, LVITEM, 16 + (A_PtrSize * 2), "Int") ; cchTextMax in LVITEM
      SendMessage, % (A_IsUnicode ? 0x1073 : 0x102D), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_GETITEMTEXT
      This.ItemText := StrGet(&ItemText, ErrorLevel)
      ControlSetText, , % This.ItemText, % "ahk_id " . This.HEDIT
      If (This.SubItem > 0) && (This.Blank) {
         Empty := ""
         , NumPut(&Empty, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
         , NumPut(0,LVITEM, 16 + (A_PtrSize * 2), "Int") ; cchTextMax in LVITEM
         SendMessage, % (A_IsUnicode ? 0x1074 : 0x102E), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_SETITEMTEXT
      }
      VarSetCapacity(RECT, 16, 0)
      , NumPut(This.SubItem, RECT, 4, "Int")
      SendMessage, 0x1038, This.Item, &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
      This.EX := NumGet(RECT, 0, "Int") + This.LX + This.DX + Indent
      , This.EY := NumGet(RECT, 4, "Int") + This.LY + This.DY
      If (This.OSVersion < 6)
         This.EY -= 1 ; subtract 1 for WinXP
      If (This.SubItem = 0) {
         SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
         This.EW := ErrorLevel
      }
      Else
         This.EW := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
      This.EW -= Indent
      , This.EH := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
      ; Register WM_COMMAND handler
      , This.CommandFunc := ObjBindMethod(This, "On_WM_COMMAND")
      , OnMessage(0x0111, This.CommandFunc)
      ; Register hotkeys
      If !(This.Next)
         This.RegisterHotkeys()
      This.Cancelled := False
      This.Next := False
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; LVN_ENDLABELEDIT notification
   ; -------------------------------------------------------------------------------------------------------------------
   LVN_ENDLABELEDIT(L) {
      H := This.HWND
      ; Unregister WM_COMMAND handler
      OnMessage(0x0111, This.CommandFunc, 0)
      This.CommandFunc := ""
      ; Unregister hotkeys
      If !(This.Next)
         This.RegisterHotkeys(False)
      ItemText := This.ItemText
      If !(This.Cancelled)
         ControlGetText, ItemText, , % "ahk_id " . This.HEDIT
      If (ItemText <> This.ItemText) {
         If !(This["Changed"])
            This.Changed := []
         This.Changed.Insert({Row: This.Item + 1, Col: This.SubItem + 1, Txt: ItemText})
      }
      ; Restore subitem's text if changed or blanked out
      If (ItemText <> This.ItemText) || ((This.SubItem > 0) && (This.Blank)) {
         VarSetCapacity(LVITEM, 40 + (A_PtrSize * 5), 0) ; LVITEM structure
         , NumPut(This.Item, LVITEM, 4, "Int")
         , NumPut(This.SubItem, LVITEM, 8, "Int")
         , NumPut(&ItemText, LVITEM, 16 + A_PtrSize, "Ptr") ; pszText in LVITEM
         SendMessage, % (A_IsUnicode ? 0x1074 : 0x102E), % This.Item, % &LVITEM, , % "ahk_id " . H ; LVM_SETITEMTEXT
      }
      If !(This.Next)
         This.Item := This.SubItem := -1
      This.Cancelled := False
      This.Next := False
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; NM_DBLCLICK notification
   ; -------------------------------------------------------------------------------------------------------------------
   NM_DBLCLICK(L) {
      H := This.HWND
      This.Item := This.SubItem := -1
      Item := NumGet(L + (A_PtrSize * 3), 0, "Int")
      SubItem := NumGet(L + (A_PtrSize * 3), 4, "Int")
      If (This["Columns"]) {
         If !This["Columns", SubItem]
            Return False
      }
      If (Item >= 0) && (SubItem >= 0) {
         This.Item := Item, This.SubItem := SubItem
         If !(This.Next) {
            ControlGet, V, List, Count, , % "ahk_id " . H
            This.RowCount := V - 1
            ControlGet, V, List, Count Col, , % "ahk_id " . H
            This.ColCount := V - 1
            , NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO)
            , DllCall("GetWindowInfo", "Ptr", H, "Ptr", &WINDOWINFO)
            , This.DX := NumGet(WINDOWINFO, 20, "Int") - NumGet(WINDOWINFO, 4, "Int")
            , This.DY := NumGet(WINDOWINFO, 24, "Int") - NumGet(WINDOWINFO, 8, "Int")
            , Styles := NumGet(WINDOWINFO, 36, "UInt")
            SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % "WWW", , % "ahk_id " . H ; LVM_GETSTRINGWIDTH
            This.MinW := ErrorLevel
            SendMessage, % (A_IsUnicode ? 0x1057 : 0x1011), 0, % "III", , % "ahk_id " . H ; LVM_GETSTRINGWIDTH
            This.DW := ErrorLevel
            , SBW := 0
            If (Styles & 0x200000) ; WS_VSCROLL
               SysGet, SBW, 2
            ControlGetPos, LX, LY, LW, , , % "ahk_id " . H
            This.LX := LX
            , This.LY := LY
            , This.LR := LX + LW - (This.DX * 2) - SBW
            , This.LW := LW
            , This.SW := SBW
            , VarSetCapacity(RECT, 16, 0)
            , NumPut(SubItem, RECT, 4, "Int")
            SendMessage, 0x1038, %Item%, % &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
            X := NumGet(RECT, 0, "Int")
            If (SubItem = 0) {
               SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
               W := ErrorLevel
            }
            Else
               W := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
            R := LW - (This.DX * 2) - SBW
            If (X < 0)
               SendMessage, 0x1014, % X, 0, , % "ahk_id " . H ; LVM_SCROLL
            Else If ((X + W) > R)
               SendMessage, 0x1014, % (X + W - R + This.DX), 0, , % "ahk_id " . H ; LVM_SCROLL
         }
         PostMessage, % (A_IsUnicode ? 0x1076 : 0x1017), %Item%, 0, , % "ahk_id " . H ; LVM_EDITLABEL
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Next subItem
   ; -------------------------------------------------------------------------------------------------------------------
   NextSubItem(K) {
      ; Hotkeys: 0x8009 (Tab -> right), 0x8409 (Shift+Tab -> left), 0x8028  (Down -> down), 0x8026 (Up -> up)
      ; Find the next subitem
      H := This.HWND
      Item := This.Item
      SubItem := This.SubItem
      If (K = 0x8009) ; right
         SubItem++
      Else If (K = 0x8409) { ; left
         SubItem--
         If (SubItem = 0) && This.Skip0
            SubItem--
      }
      Else If (K = 0x8028) ; down
         Item++
      Else If (K = 0x8026) ; up
         Item--
      IF (K = 0x8409) || (K = 0x8009) { ; left || right
         If (This["Columns"]) {
            If (SubItem < This.Columns.MinIndex())
               SubItem := This.Columns.MaxIndex(), Item--
            Else If (SubItem > This.Columns.MaxIndex())
               SubItem := This.Columns.MinIndex(), Item++
            Else {
               While (This.Columns[SubItem] = "") {
                  If (K = 0x8009) ; right
                     SubItem++
                  Else
                     SubItem--
               }
            }
         }
      }
      If (SubItem > This.ColCount)
         Item++, SubItem := This.Skip0 ? 1 : 0
      Else If (SubItem < 0)
         SubItem := This.ColCount, Item--
      If (Item > This.RowCount)
         Item := 0
      Else If (Item < 0)
         Item := This.RowCount
      If (Item <> This.Item)
         SendMessage, 0x1013, % Item, False, , % "ahk_id " . H ; LVM_ENSUREVISIBLE
      VarSetCapacity(RECT, 16, 0), NumPut(SubItem, RECT, 4, "Int")
      SendMessage, 0x1038, % Item, % &RECT, , % "ahk_id " . H ; LVM_GETSUBITEMRECT
      X := NumGet(RECT, 0, "Int"), Y := NumGet(RECT, 4, "Int")
      If (SubItem = 0) {
         SendMessage, 0x101D, 0, 0, , % "ahk_id " . H ; LVM_GETCOLUMNWIDTH
         W := ErrorLevel
      }
      Else
         W := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
      R := This.LW - (This.DX * 2) - This.SW, S := 0
      If (X < 0)
         S := X
      Else If ((X + W) > R)
         S := X + W - R + This.DX
      If (S)
         SendMessage, 0x1014, % S, 0, , % "ahk_id " . H ; LVM_SCROLL
      Point := (X - S + (This.DX * 2)) + ((Y + (This.DY * 2)) << 16)
      SendMessage, 0x0201, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONDOWN
      SendMessage, 0x0202, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONUP
      SendMessage, 0x0203, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONDBLCLK
      SendMessage, 0x0202, 0, % Point, , % "ahk_id " . H ; WM_LBUTTONUP
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Register/UnRegister hotkeys
   ; -------------------------------------------------------------------------------------------------------------------
   RegisterHotkeys(Register = True) {
      ; WM_HOTKEY := 0x0312, MOD_SHIFT := 0x0004
      ; Hotkeys: 0x801B  (Esc -> cancel, 0x8009 (Tab -> right), 0x8409 (Shift+Tab -> left)
      ;          0x8028  (Down -> down), 0x8026 (Up -> up)
      H := This.HWND
      If (Register) { ; Register
         DllCall("RegisterHotKey", "Ptr", H, "Int", 0x801B, "UInt", 0, "UInt", 0x1B)
         , DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8009, "UInt", 0, "UInt", 0x09)
         , DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8409, "UInt", 4, "UInt", 0x09)
         , DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8028, "UInt", 0, "UInt", 0x28)
         , DllCall("RegisterHotKey", "Ptr", H, "Int", 0x8026, "UInt", 0, "UInt", 0x26)
         , This.HotkeyFunc := ObjBindMethod(This, "On_WM_HOTKEY")
         , OnMessage(0x0312, This.HotkeyFunc) ; WM_HOTKEY
      }
      Else { ; Unregister
         DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x801B)
         , DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8009)
         , DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8409)
         , DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8028)
         , DllCall("UnregisterHotKey", "Ptr", H, "Int", 0x8026)
         , OnMessage(0x0312, This.HotkeyFunc, 0) ; WM_HOTKEY
         , This.HotkeyFunc := ""
      }
   }
}