; TreeList Control Class (v1.1.1)

Class TreeList {
    Static TLM_INSERTITEM := 0x401
    , TLM_DELETEITEM := 0x402
    , TLM_DELETEALLITEMS := 0x403
    , TLM_GETITEM := 0x404
    , TLM_SETITEM := 0x405
    , TLM_GETITEMCOUNT := 0x406
    , TLM_GETNEXTITEM := 0x407
    , TLM_EXPAND := 0x408
    , TLM_SETIMAGELIST := 0x409
    , TLM_GETIMAGELIST := 0x40A
    , TLM_INSERTCOLUMN := 0x40B
    , TLM_DELETECOLUMN := 0x40C
    , TLM_SELECTITEM := 0x40D
    , TLM_REDRAWWINDOW := 0x40E
    , TLM_ISEXPANDED := 0x40F
    , TLM_GETCOLUMNWIDTH := 0x410
    , TLM_SETCOLUMNWIDTH := 0x411

    __New(hWndParent := 0, X := 0, Y := 0, Width := 300, Height := 200, Style := 0x5001000D, ExStyle := 0) {
        hMod := DllCall("LoadLibrary", "Str", "rasdlg.dll", "Ptr")
        If (!hMod) {
            MsgBox 0x10, Error, Failed to load library rasdlg.dll.
            Return
        }

        this.hWnd := DllCall("CreateWindowEx"
                     , "Uint" , ExStyle
                     , "Str"  , "TreeList"
                     , "Str"  , ""
                     , "UInt" , Style
                     , "Int"  , X
                     , "Int"  , Y
                     , "Int"  , Width
                     , "Int"  , Height
                     , "Ptr" , hWndParent
                     , "UInt" , 0
                     , "Ptr" , hMod
                     , "UInt" , 0, "Ptr")

        If (!this.hWnd) {
            MsgBox 0x10, Error, Failed to create the TreeList control.
            Return
        }

        Ptr := A_PtrSize == 8 ? "Ptr" : ""
        this.OldWndProc := DllCall("GetWindowLong" . Ptr, "Ptr", this.hWnd, "Int", -4, "Ptr") ; GWL_WNDPROC
        _TreeListHandler(this.OldWndProc, -1, 0, 0)
        this.NewWndProc := RegisterCallback("_TreeListHandler", "", 4)
        this.OldWndProc := DllCall("SetWindowLong" . Ptr, "Ptr", this.hWnd, "Int", -4, "Ptr", this.NewWndProc, "Ptr")

        this.hLV  := this.GetListView()
        this.hHdr := this.GetHeader()
        this.hMod := hMod

        WinSet Style, +0x800000, % "ahk_id" this.hLV ; WS_BORDER
    }

    AddColumn(Text, Width := 100, Align := "", Pos := -1) {
        Static fmt := {"Left": 0, "Center": 2, "Right": 1}

        VarSetCapacity(LVCOLUMN, A_PtrSize == 8 ? 56 : 44, 0)

        Mask := 0x6 ; (LVCF_TEXT := 0x4, LVCF_WIDTH := 0x2)
        If (fmt[Align] != "") {
            Mask |= 0x1 ; LVCF_FMT
            NumPut(fmt[Align], LVCOLUMN, 4, "Int") ; fmt
        }
        pszText := A_IsUnicode ? &Text : This.WStr(Text, WText)
        NumPut(Mask, LVCOLUMN, 0, "UInt") ; mask
        NumPut(Width, LVCOLUMN, 8, "Int") ; cx
        NumPut(pszText, LVCOLUMN, A_PtrSize == 8 ? 16 : 12, "Ptr") ; pszText
        NumPut(iImage := 1, LVCOLUMN, A_PtrSize == 8 ? 32 : 24, "Int")

        If (Pos == -1) {
            Pos := this.GetColumnCount()
        }

        SendMessage, % this.TLM_INSERTCOLUMN, %Pos%, % &LVCOLUMN,, % "ahk_id" this.hWnd
    }

    SetColumnText(ColN, NewText) {
        VarSetCapacity(LVCOLUMN, A_PtrSize == 8 ? 56 : 44, 0)
        NumPut(0x4, LVCOLUMN, 0, "UInt") ; mask (LVCF_TEXT)
        NumPut(&NewText, LVCOLUMN, A_PtrSize == 8 ? 16 : 12, "Ptr") ; pszText
        SendMessage % A_IsUnicode ? 0x1060 : 0x101A, ColN - 1, &LVCOLUMN,, % "ahk_id" . this.hLV ; LVM_SETCOLUMN
        Return ErrorLevel
    }

    DeleteColumn(ColN) {
        SendMessage % this.TLM_DELETECOLUMN, ColN - 1,,, % "ahk_id" . this.hWnd
        Return ErrorLevel
    }

    Add(ParentID := 0, Icon := "", Fields*) {
        Static TVI_LAST := -65534 & 0xFFFFFFFF 

        Mask := Icon != "" ? 0x3 : 0x1 ; LVIF_TEXT = 1, LVIF_IMAGE = 0x2
        Text := Fields[1]
        pszText := A_IsUnicode ? &Text : This.WStr(Text, WText)
        VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
        NumPut(Mask, LVITEM, 0, "UInt") ; mask
        NumPut(0, LVITEM, 4, "Int") ; iItem
        NumPut(pszText, LVITEM, A_PtrSize == 8 ? 24 : 20, "Ptr") ; pszText
        If (Icon != "") {
            NumPut(Icon - 1, LVITEM, A_PtrSize == 8 ? 36 : 28, "Int") ; iImage
        }

        ; TL_INSERTSTRUCT
        VarSetCapacity(TVINSERTSTRUCT, A_PtrSize == 8 ? 104 : 68, 0)
        NumPut(ParentID, TVINSERTSTRUCT, 0, "Ptr") ; hParent
        NumPut(TVI_LAST, TVINSERTSTRUCT, A_PtrSize == 8 ? 8 : 4, "Ptr") ; hInsertAfter
        NumPut(&LVITEM, TVINSERTSTRUCT, A_PtrSize == 8 ? 16 : 8, "Ptr")

        iItem := this.Send(this.TLM_INSERTITEM, 0, &TVINSERTSTRUCT)

        ; Sub items
        For Each, Field in Fields {
            If (A_Index == 1) {
                Continue
            }
            pszText := A_IsUnicode ? &Field : This.WStr(Field, WText)
            NumPut(iItem, LVITEM, 4, "Int") ; iItem
            NumPut(A_Index - 1, LVITEM, 8, "Int") ; iSubItem
            NumPut(pszText, LVITEM, A_PtrSize == 8 ? 24 : 20, "Ptr") ; pszText
            this.Send(this.TLM_SETITEM, 0, &LVITEM)
        }

        Return iItem
    }

    Delete(ItemID := "") {
        If (ItemID == "") {
            Return this.Send(this.TLM_DELETEALLITEMS, 0, 0)
        } Else {
            Return this.Send(this.TLM_DELETEITEM, 0, ItemID)
        }
    }

    Select(ItemID) {
        Return this.Send(this.TLM_SELECTITEM, 9, ItemID) ; TLGN_CARET
    }

    Expand(ItemID) {
        Return this.Send(this.TLM_EXPAND, 1, ItemID) ; 0 = toggle
    }

    IsExpanded(ItemID) {
        Return this.Send(this.TLM_ISEXPANDED, 0, ItemID)
    }

    Collapse(ItemID) {
        Return this.Send(this.TLM_EXPAND, 2, ItemID)
    }

    SetImageList(ImageListID) {
        Return this.Send(this.TLM_SETIMAGELIST, 0, ImageListID)
    }

    GetImageList() {
        Return this.Send(this.TLM_GETIMAGELIST, 0, 0)
    }

    GetCount() {
        Return this.Send(this.TLM_GETITEMCOUNT, 0, 0)
    }

    GetColumnCount() {
        SendMessage 0x1200, 0, 0,, % "ahk_id" . this.hHdr ; HDM_GETITEMCOUNT
        Return ErrorLevel
    }

    GetColumnWidth(ColN) {
        Return this.Send(this.TLM_GETCOLUMNWIDTH, ColN - 1, 0)
    }

    ; LVSCW_AUTOSIZE (-1) Automatically sizes the column.
    ; LVSCW_AUTOSIZE_USEHEADER (-2): Automatically sizes the column to fit the header text.
    ; If you use this value with the last column, its width is set to fill the remaining width of the list-view control.
    SetColumnWidth(ColN, Width := -1) {
        Static AutoSize := {"Auto": -1, "AutoHdr": -2}
        If (AutoSize[Width] != "") {
            Width := AutoSize[Width]
        }
        Return this.Send(this.TLM_SETCOLUMNWIDTH, ColN - 1, Width)
    }

    GetListView() {
        Return DllCall("GetWindow", "Ptr", this.hWnd, "UInt", 5, "Ptr") ; GW_CHILD
    }

    GetHeader() {
        SendMessage 0x101F, 0, 0,, % "ahk_id" . this.hLV ; LVM_GETHEADER
        Return ErrorLevel
    }

    GetSelection() {
        Return this.Send(this.TLM_GETNEXTITEM, 32, 0)
    }

    GetRoot() {
        Return this.Send(this.TLM_GETNEXTITEM, 0, 0) ; TLGN_ROOT
    }

    GetChild(ParentItemID) {
        Return this.Send(this.TLM_GETNEXTITEM, 2, ParentItemID) ; TLGN_CHILD
    }

    GetNext(ItemID := "") {
        If (ItemID == "") {
            Return this.GetRoot()
        } Else {
            Return this.Send(this.TLM_GETNEXTITEM, 4, ItemID) ; TLGN_NEXT
        }
    }

    GetPrev(ItemID) {
        Return this.Send(this.TLM_GETNEXTITEM, 8, ItemID) ; TLGN_PREVIOUS
    }

    GetParent(ItemID) {
        Return this.Send(this.TLM_GETNEXTITEM, 1, ItemID) ; TLGN_PARENT
    }

    SetText(ItemID, ColN, NewText) {
        pszText := A_IsUnicode ? &NewText : This.WStr(NewText, WText)
        VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
        NumPut(0x1, LVITEM, 0, "UInt") ; mask (TLIF_TEXT)
        NumPut(ItemID, LVITEM, 4, "Int") ; iItem
        NumPut(ColN - 1, LVITEM, 8, "Int") ; iSubItem
        NumPut(pszText, LVITEM, A_PtrSize == 8 ? 24 : 20, "Ptr") ; pszText

        Return this.Send(this.TLM_SETITEM, 0, &LVITEM)
    }

    GetText(ItemID, ColN := 1) {
        VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
        NumPut(0x1, LVITEM, 0, "UInt") ; mask (TLIF_TEXT)
        NumPut(ItemID, LVITEM, 4, "Int") ; iItem
        NumPut(ColN - 1, LVITEM, 8, "Int") ; iSubItem
        VarSetCapacity(pszText, 256, 0)
        NumPut(&pszText, LVITEM, A_PtrSize == 8 ? 24 : 20, "Ptr")
        NumPut(256, LVITEM, A_PtrSize == 8 ? 32 : 24, "Int") ; cchTextMax

        this.Send(this.TLM_GETITEM, 0, &LVITEM)
        Return StrGet(NumGet(LVITEM, A_PtrSize == 8 ? 24 : 20, "Ptr"), "UTF-16") ; pszText
    }

    SetIcon(ItemID, IconIndex) {
        VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
        NumPut(0x2, LVITEM, 0, "UInt") ; mask (TLIF_IMAGE)
        NumPut(ItemID, LVITEM, 4, "Int") ; iItem
        NumPut(IconIndex, LVITEM, A_PtrSize == 8 ? 36 : 28, "Int") ; iImage

        Return this.Send(this.TLM_SETITEM, 0, &LVITEM)
    }

    ; Get icon index in the image list
    GetIcon(ItemID) {
        VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
        NumPut(0x2, LVITEM, 0, "UInt") ; mask (TLIF_IMAGE)
        NumPut(ItemID, LVITEM, 4, "Int") ; iItem
        this.Send(this.TLM_GETITEM, 0, &LVITEM)
        Return NumGet(LVITEM, A_PtrSize == 8 ? 36 : 28, "Int") + 1
    }

    Redraw() {
        Return this.Send(this.TLM_REDRAWWINDOW, 0, 0)
    }

    SetEventHandler(EventHandler) {
        _TreeListStorage(this.hWnd, EventHandler)
    }

    Send(Msg, wParam, lParam) {
        SendMessage Msg, wParam, lParam,, % "ahk_id" . this.hWnd
        Return ErrorLevel
    }

    WStr(ByRef AStr, ByRef WStr) {
        Size := StrPut(AStr, "UTF-16")
        VarSetCapacity(WStr, Size * 2, 0)
        StrPut(ASTr, &WStr, "UTF-16")
        Return &Wstr
    }
}

_TreeListStorage(hWnd, Callback := "") {
    Static o := {}
    Return (o[hWnd] != "") ? o[hWnd] : o[hWnd] := Callback
}

_TreeListHandler(hWnd, msg, wParam, lParam) {
    Static n := {-2: "Click", -3: "DoubleClick", -5: "RightClick", -7: "SetFocus", -8: "KillFocus", -155: "KeyDown"}
    Static OldWndProc
    If (msg == -1) {
        OldWndProc := hWnd
    }

    If (msg == 78) { ; WM_NOTIFY (0x4E)
        hWndFrom := NumGet(lParam + 0)
        idFrom := NumGet(lParam + 4)
        Code := NumGet(lParam + 0, A_PtrSize * 2, "Int")

        If (Code > -7) { ; NM_CLICK, NM_DBLCLK, NM_RCLICK
            Row := NumGet(lParam + 0, A_PtrSize == 8 ? 24 : 12, "Int") + 1 ; NMITEMACTIVATE iItem
            Col := NumGet(lParam + 0, A_PtrSize == 8 ? 28 : 16, "Int") + 1 ; NMITEMACTIVATE iSubItem
        } Else If (Code == -155) { ; LVN_KEYDOWN
            Key := NumGet(lParam + 0, A_PtrSize == 8 ? 24 : 12, "Short") ; NMLVKEYDOWN wVKey (key code)
        }

        Handler := _TreeListStorage(hWnd)
        If (Handler != "") {
            Event := (n[Code] != "") ? n[Code] : Code
            %Handler%(hWnd, Event, Row, Col, Key)
        }
    }

    Return DllCall("CallWindowProcA", "Ptr", OldWndProc, "Ptr", hWnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}
