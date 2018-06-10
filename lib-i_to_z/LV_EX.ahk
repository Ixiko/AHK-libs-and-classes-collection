; ======================================================================================================================
; Namespace:      LV_EX
; Function:       Some additional functions to use with AHK GUI ListView controls.
; Tested with:    AHK 1.1.13.01 (A32/U32/U64)
; Tested on:      Win 7 (x64)
; Changelog:
;     1.0.00.00/2013-12-30/just me - initial release
; Notes:
;     In terms of Microsoft
;        Item     stands for the whole row or the first column of the row
;        SubItem  stands for the second to last column of a row
;     All functions require the handle to the ListView (HWND). You get this handle using the 'Hwnd' option when
;     creating the control per 'Gui, Add, HwndHwndOfLV ...' or using 'GuiControlGet, HwndOfLV, Hwnd, MyListViewVar'
;     after control creation.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; ======================================================================================================================
; LV_EX_CalcViewSize - Calculates the approximate width and height required to display a given number of items.
; ======================================================================================================================
LV_EX_CalcViewSize(HLV, Rows := 0) {
   Static LVM_APPROXIMATEVIEWRECT := 0x1040
   SendMessage, % LVM_APPROXIMATEVIEWRECT, % (Rows - 1), 0, , % "ahk_id " . HLV
   If (ErrorLevel <> "FAIL")
      Return {W: (ErrorLevel & 0xFFFF), H: (ErrorLevel >> 16) & 0xFFFF}
   Return False
}
; ======================================================================================================================
; LV_EX_FindString - Searches the first column for an item containing the specified string.
; ======================================================================================================================
LV_EX_FindString(HLV, Str, Start := 0, Partial := False) {
   Static LVM_FINDITEM := A_IsUnicode ? 0x1053 : 0x100D ; LVM_FINDITEMW : LVM_FINDITEMA
   Static LVFI_PARTIAL := 0x0008
   Static LVFI_STRING  := 0x0002
   Static LVFISize := 40
   VarSetCapacity(LVFINDINFO, LVFISize, 0)
   Flags := LVFI_STRING
   If (Partial)
      Flags |= LVFI_PARTIAL
   NumPut(Flags, LVFINDINFO, 0, "UInt")
   NumPut(&Str,  LVFINDINFO, A_PtrSize, "Ptr")
   SendMessage, % LVM_FINDITEM, % (Start - 1), % &LVFINDINFO, , % "ahk_id " . HLV
   Return (ErrorLevel > 0x7FFFFFFF ? 0 : ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_FindStringEx - Searches all columns or the specified column for a subitem containing the specified string.
; ======================================================================================================================
LV_EX_FindStringEx(HLV, Str, Column := 0, Start := 0, Partial := False) {
   Len := StrLen(Str)
   Row := Col := 0
   ControlGet, ItemList, List, , , % "ahk_id " . HLV
   Loop, Parse, ItemList, `n
   {
      If (A_Index > Start) {
         Row := A_Index
         Columns := StrSplit(A_LoopField, "`t")
         If (Column + 0) > 0 {
            If (Partial) {
               If (SubStr(Columns[Column], 1, Len) = Str)
                  Col := Column
            }
            Else {
               If (Columns[Column] = Str)
                  Col := Column
            }
         }
         Else {
            For Index, ColumnText In Columns {
               If (Partial) {
                  If (SubStr(ColumnText, 1, Len) = Str)
                     Col := Index
               }
               Else {
                  If (ColumnText = Str)
                     Col := Index
               }
            } Until (Col > 0)
         }
      }
   } Until (Col > 0)
   Return (Col > 0) ? {Row: Row, Col: Column} : 0
}
; ======================================================================================================================
; LV_EX_GetColumnOrder - Gets the current left-to-right order of columns in a list-view control.
; ======================================================================================================================
LV_EX_GetColumnOrder(HLV) {
   Static HDM_GETITEMCOUNT := 0x1200
   Static LVM_GETCOLUMNORDERARRAY := 0x103B
   Header := LV_EX_GetHeader(HLV)
   SendMessage, % HDM_GETITEMCOUNT, 0, 0, , % "ahk_id " . Header
   If (ErrorLevel > 0x7FFFFFFF)
      Return False
   Cols := ErrorLevel
   VarSetCapacity(COA, Cols * 4, 0)
   SendMessage, % LVM_GETCOLUMNORDERARRAY, % Cols, % &COA, , % "ahk_id " . HLV
   If (ErrorLevel = 0) || !(ErrorLevel + 0)
      Return False
   ColArray := []
   Loop, %Cols%
      ColArray.Insert(NumGet(COA, 4 * (A_Index - 1), "Int") + 1)
   Return ColArray
}
; ======================================================================================================================
; LV_EX_GetColumnWidth - Gets the width of a column in report or list view.
; ======================================================================================================================
LV_EX_GetColumnWidth(HLV, Column) {
   Static LVM_GETCOLUMNWIDTH := 0x101D
   SendMessage, % LVM_GETCOLUMNWIDTH, % (Column - 1), 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetExtendedStyle - Gets the extended styles that are currently in use for a given list-view control.
; ======================================================================================================================
LV_EX_GetExtendedStyle(HLV) {
   Static LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037
   SendMessage, % LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetHeader - Retrieves the handle to the header control used by the list-view control.
; ======================================================================================================================
LV_EX_GetHeader(HLV) {
   Static LVM_GETHEADER := 0x101F
   SendMessage, % LVM_GETHEADER, 0, 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetItemParam - Retrieves the value of the item's lParam field.
; ======================================================================================================================
LV_EX_GetItemParam(HLV, Row) {
   Static LVM_GETITEM := A_IsUnicode ? 0x104B : 0x1005 ; LVM_GETITEMW : LVM_GETITEMA
   Static LVITEMSize := 48 + (A_PtrSize * 3)
   Static LVIF_PARAM := 0x00000004
   Static OffParam := 24 + (A_PtrSize * 2)
   VarSetCapacity(LVITEM, LVITEMSize, 0)
   NumPut(LVIF_PARAM, LVITEM, 0, "UInt")
   NumPut(Row - 1, LVITEM, 4, "Int")
   SendMessage, % LVM_SETITEM, 0, % &LVITEM, , % "ahk_id " . HLV
   Return NumGet(LVITEM, OffParam, "UPtr")
}
; ======================================================================================================================
; LV_EX_GetItemRect - Retrieves the bounding rectangle for all or part of an item in the current view.
; ======================================================================================================================
LV_EX_GetItemRect(HLV, Row := 1, LVIR := 0) {
   Static LVM_GETITEMRECT := 0x100E
   VarSetCapacity(RECT, 16, 0)
   NumPut(LVIR, RECT, 0, "Int")
   SendMessage, % LVM_GETITEMRECT, % (Row - 1), % &RECT, , % "ahk_id " . HLV
   If (ErrorLevel = 0) || !(ErrorLevel + 0)
      Return False
   Result := {}
   Result.X := NumGet(RECT,  0, "Int")
   Result.Y := NumGet(RECT,  4, "Int")
   Result.R := NumGet(RECT,  8, "Int")
   Result.B := NumGet(RECT, 12, "Int")
   Result.W := Result.R - Result.X
   Result.H := Result.B - Result.Y
   Return Result
}
; ======================================================================================================================
; LV_EX_GetItemState - Retrieves the state of a list-view item.
; ======================================================================================================================
LV_EX_GetItemState(HLV, Row) {
   Static LVM_GETITEMSTATE := 0x102C
   Static LVIS := {Cut: 0x04, DropHilited: 0x08, Focused: 0x01, Selected: 0x02, Checked: 0x2000}
   Static ALLSTATES := 0xFFFF ; not defined in MSDN
   SendMessage, % LVM_GETITEMSTATE, % (Row - 1), % ALLSTATES, , % "ahk_id " . HLV
   If (ErrorLevel + 0) {
      States := ErrorLevel
      Result := {}
      For Key, Value In LVIS
         Result[Key] := !!(States & Value)
      Return Result
   }
   Return False
}
; ======================================================================================================================
; LV_EX_GetRowHeight - Gets the height of the specified row.
; ======================================================================================================================
LV_EX_GetRowHeight(HLV, Row := 1) {
   Return LV_EX_GetItemRect(HLV, Row).H
}
; ======================================================================================================================
; LV_EX_GetRowsPerPage - Calculates the number of items that can fit vertically in the visible area of a list-view
;                        control when in list or report view. Only fully visible items are counted.
; ======================================================================================================================
LV_EX_GetRowsPerPage(HLV) {
   Static LVM_GETCOUNTPERPAGE := 0x1028
   SendMessage, % LVM_GETCOUNTPERPAGE, 0, 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetSubItemRect - Retrieves information about the bounding rectangle for a subitem in a list-view control.
; ======================================================================================================================
LV_EX_GetSubItemRect(HLV, Column, Row := 1, LVIR := 0) {
   Static LVM_GETSUBITEMRECT := 0x1038
   VarSetCapacity(RECT, 16, 0)
   NumPut(LVIR, RECT, 0, "Int")
   NumPut(Column - 1, RECT, 4, "Int")
   If (Column = 1)
      W := LV_EX_GetColumnWidth(HLV, 1)
   SendMessage, % LVM_GETSUBITEMRECT, % (Row - 1), % &RECT, , % "ahk_id " . HLV
   If (ErrorLevel = 0) || !(ErrorLevel + 0)
      Return False
   Result := {}
   Result.X := NumGet(RECT,  0, "Int")
   Result.Y := NumGet(RECT,  4, "Int")
   Result.R := Column = 1 ? Result.X + W : NumGet(RECT,  8, "Int")
   Result.B := NumGet(RECT, 12, "Int")
   Result.W := Column = 1 ? W : Result.R - Result.X
   Result.H := Result.B - Result.Y
   Return Result
}
; ======================================================================================================================
; LV_EX_GetTopIndex - Retrieves the index of the topmost visible item when in list or report view.
; ======================================================================================================================
LV_EX_GetTopIndex(HLV) {
   Static LVM_GETTOPINDEX := 0x1027
   SendMessage, % LVM_GETTOPINDEX, 0, 0, , % "ahk_id " . HLV
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_GetView - Retrieves the current view of a list-view control.
; ======================================================================================================================
LV_EX_GetView(HLV) {
   Static LVM_GETVIEW := 0x108F
   Static Views := {0x00: "Icon", 0x01: "Report", 0x02: "IconSmall", 0x03: "List", 0x04: "Tile"}
   SendMessage, % LVM_GETVIEW, 0, 0, , % "ahk_id " . HLV
   Return Views[ErrorLevel]
}
; ======================================================================================================================
; LV_EX_IsRowChecked - Indicates if a row in the list-view control is checked.
; ======================================================================================================================
LV_EX_IsRowChecked(HLV, Row) {
   Return LV_EX_GetItemState(HLV, Row).Checked
}
; ======================================================================================================================
; LV_EX_IsRowFocused - Indicates if a row in the list-view control is focused.
; ======================================================================================================================
LV_EX_IsRowFocused(HLV, Row) {
   Return LV_EX_GetItemState(HLV, Row).Focused
}
; ======================================================================================================================
; LV_EX_IsRowSelected - Indicates if a row in the list-view control is selected.
; ======================================================================================================================
LV_EX_IsRowSelected(HLV, Row) {
   Return LV_EX_GetItemState(HLV, Row).Selected
}
; ======================================================================================================================
; LV_EX_IsRowVisible - Indicates if a row in the list-view control is visible.
; ======================================================================================================================
LV_EX_IsRowVisible(HLV, Row) {
   Static LVM_ISITEMVISIBLE := 0x10B6
   SendMessage, % LVM_ISITEMVISIBLE, % (Row - 1), 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; CommCtrl.h:
; These next to methods make it easy to identify an item that can be repositioned within listview.
; For example:
; Many developers use the lParam to store an identifier that is unique. Unfortunatly, in order to find this item,
; they have to iterate through all of the items in the listview.
; Listview will maintain a unique identifier. The upper bound is the size of a DWORD.
; ======================================================================================================================
; LV_EX_MapIDToIndex - Maps the ID of an item to an index.
; ======================================================================================================================
LV_EX_MapIDToIndex(HLV, ID) {
   Static LVM_MAPIDTOINDEX := 0x10B5
   SendMessage, % LVM_MAPIDTOINDEX, % ID, 0, , % "ahk_id " . HLV
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_MapIndexToID - Maps the index of an item to a unique ID.
; ======================================================================================================================
LV_EX_MapIndexToID(HLV, Index) {
   Static LVM_MAPINDEXTOID := 0x10B4
   SendMessage, % LVM_MAPINDEXTOID, % (Index - 1), 0, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_RedrawRows - Forces a list-view control to redraw a range of items.
; ======================================================================================================================
LV_EX_RedrawRows(HLV, FirstRow, LastRow := -1) {
   Static LVM_GETITEMCOUNT := 0x1004
   Static LVM_REDRAWITEMS := 0x1015
   If (LastRow = -1) {
      SendMessage, % LVM_GETITEMCOUNT, 0, 0, , % "ahk_id " . HLV
      LastRow := Errorlevel
   }
   SendMessage, % LVM_REDRAWITEMS, % (FirstRow - 1), % (LastRow - 1), , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetBkImage - Sets the background image in a list-view control.
; ======================================================================================================================
LV_EX_SetBkImage(HLV, ImagePath, Width := "", Height := "") {
   Static KnownControls := []
   Static LVM_SETBKIMAGE := A_IsUnicode ? 0x108A : 0x1044 ; LVM_SETBKIMAGEW : LVM_SETBKIMAGEA
   Static LVS_EX_DOUBLEBUFFER := 0x00010000
   Static LVBKIF_TYPE_WATERMARK   := 0x10000000
   Static LVBKIF_FLAG_ALPHABLEND  := 0x20000000
   Static OSVERSION := (V := DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) . "." . ((V >> 8) & 0xFF)
   Static STM_GETIMAGE := 0x0173
   HBITMAP := 0
   If (ImagePath) && FileExist(ImagePath) {
      W := H := ""
      If (Width = "") && (Height = "") {
         VarSetCapacity(RECT, 16, 0)
         DllCall("User32.dll\GetClientRect", "Ptr", HLV, "Ptr", &RECT)
         ControlGetPos, , , , HH, , % "ahk_id " . LV_EX_GetHeader(HLV)
         Width := NumGet(RECT, 8, "Int")
         Height := NumGet(RECT, 12, "Int") - HH
      }
      HMod := 	DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
      VarSetCapacity(SI, 24, 0), NumPut(1, SI, "UInt")
      DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", Token, "Ptr", &SI, "Ptr", 0)
      DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", ImagePath, "PtrP", Bitmap)
      DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", Bitmap, "PtrP", HBITMAP, "UInt", 0x00FFFFFF)
      DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", Bitmap)
      DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", Token)
      DllCall("Kernel32.dll\FreeLibrary", "Ptr", HMod)
      HBITMAP := DllCall("User32.dll\CopyImage"
                       , "Ptr", HBITMAP, "UInt", 0, "Int", Width, "Int", Height, "UInt", 0x2008, "UPtr")
      If !(HBITMAP)
         Return False
   }
   ; Set extended style LVS_EX_DOUBLEBUFFER to avoid drawing issues
   If !KnownControls.HasKey(HLV) {
      LV_EX_SetExtendedStyle(HLV, LVS_EX_DOUBLEBUFFER, LVS_EX_DOUBLEBUFFER)
      KnownControls[HLV] := True
   }
   Flags := LVBKIF_TYPE_WATERMARK
   If (OSVERSION >= 6) ; LVBKIF_FLAG_ALPHABLEND prevents to show the image on WinXP
      Flags |= LVBKIF_FLAG_ALPHABLEND
   LVBKIMAGESize :=  A_PtrSize = 8 ? 40 : 24
   VarSetCapacity(LVBKIMAGE, LVBKIMAGESize, 0)
   NumPut(Flags, LVBKIMAGE, 0, "UInt")
   NumPut(HBITMAP, LVBKIMAGE, A_PtrSize, "UPtr")
   SendMessage, % LVM_SETBKIMAGE, 0, % &LVBKIMAGE, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetColumnOrder - Sets the left-to-right order of columns in a list-view control.
; ======================================================================================================================
LV_EX_SetColumnOrder(HLV, ColArray) {
   Static LVM_SETCOLUMNORDERARRAY := 0x103A
   Cols := ColArray.MaxIndex()
   VarSetCapacity(COA, Cols * 4, 0)
   For I, R In ColArray
      NumPut(R - 1, COA, (A_Index - 1) * 4, "Int")
   SendMessage, % LVM_SETCOLUMNORDERARRAY, % Cols, % &COA, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetExtendedStyle - Sets extended styles in list-view controls.
; ======================================================================================================================
LV_EX_SetExtendedStyle(HLV, StyleMask, Styles) {
   Static LVM_SETEXTENDEDLISTVIEWSTYLE := 0x1036
   SendMessage, % LVM_SETEXTENDEDLISTVIEWSTYLE, % StyleMask, % Styles, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetItemIndent - Sets the indent of the first column to the specified number of icon widths.
; ======================================================================================================================
LV_EX_SetItemIndent(HLV, Row, NumIcons) {
   Static LVM_SETITEM := A_IsUnicode ? 0x104C : 0x1006 ; LVM_SETITEMW : LVM_SETITEMA
   Static LVITEMSize := 48 + (A_PtrSize * 3)
   Static LVIF_INDENT := 0x00000010
   Static OffIndent := 24 + (A_PtrSize * 3)
   VarSetCapacity(LVITEM, LVITEMSize, 0)
   NumPut(LVIF_INDENT, LVITEM, 0, "UInt")
   NumPut(Row - 1, LVITEM, 4, "Int")
   NumPut(NumIcons, LVITEM, OffIndent, "Int")
   SendMessage, % LVM_SETITEM, 0, % &LVITEM, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetItemParam - Sets the lParam field of the item to the specified value.
; ======================================================================================================================
LV_EX_SetItemParam(HLV, Row, Value) {
   Static LVM_SETITEM := A_IsUnicode ? 0x104C : 0x1006 ; LVM_SETITEMW : LVM_SETITEMA
   Static LVITEMSize := 48 + (A_PtrSize * 3)
   Static LVIF_PARAM := 0x00000004
   Static OffParam := 24 + (A_PtrSize * 2)
   VarSetCapacity(LVITEM, LVITEMSize, 0)
   NumPut(LVIF_PARAM, LVITEM, 0, "UInt")
   NumPut(Row - 1, LVITEM, 4, "Int")
   NumPut(Value, LVITEM, OffParam, "UPtr")
   SendMessage, % LVM_SETITEM, 0, % &LVITEM, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetSubItemImage - Assigns an image from the list-view's image list to this subitem.
; ======================================================================================================================
LV_EX_SetSubItemImage(HLV, Row, Column, ImageIndex) {
   Static KnownControls := []
   Static LVS_EX_SUBITEMIMAGES := 0x00000002
   Static LVM_SETITEM := A_IsUnicode ? 0x104C : 0x1006 ; LVM_SETITEMW : LVM_SETITEMA
   Static LVITEMSize := 48 + (A_PtrSize * 3)
   Static LVIF_IMAGE := 0x00000002
   Static OffImage := 20 + (A_PtrSize * 2)
   If !KnownControls.HasKey(HLV) {
      LV_EX_SetExtendedStyle(HLV, LVS_EX_SUBITEMIMAGES, LVS_EX_SUBITEMIMAGES)
      KnownControls[HLV] := True
   }
   VarSetCapacity(LVITEM, LVITEMSize, 0)
   NumPut(LVIF_IMAGE, LVITEM, 0, "UInt")
   NumPut(Row - 1, LVITEM, 4, "Int")
   NumPut(Column - 1, LVITEM, 8, "Int")
   NumPut(ImageIndex - 1, LVITEM, OffImage, "Int")
   SendMessage, % LVM_SETITEM, 0, % &LVITEM, , % "ahk_id " . HLV
   Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SubItemHitTest - Gets the column (subitem) at the passed coordinates or the position of the mouse cursor.
; ======================================================================================================================
LV_EX_SubItemHitTest(HLV, X := -1, Y := -1) {
   Static LVM_SUBITEMHITTEST := 0x1039
   VarSetCapacity(POINT, 8, 0)
   If (X = -1) || (Y = -1) {
      DllCall("User32.dll\GetCursorPos", "Ptr", &POINT)
      DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", &POINT)
      VarSetCapacity(LVHITTESTINFO, 24, 0)
      NumPut(NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0, "Int")
      NumPut(NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4, "Int")
   } Else {
      NumPut(X, LVHITTESTINFO, 0, "Int")
      NumPut(Y, LVHITTESTINFO, 4, "Int")
   }
   SendMessage, % LVM_SUBITEMHITTEST, 0, % &LVHITTESTINFO, , % "ahk_id " . HLV
   Return ErrorLevel > 0x7FFFFFFF ? 0 : (NumGet(LVHITTESTINFO, 16, "Int") + 1)
}
; ======================================================================================================================