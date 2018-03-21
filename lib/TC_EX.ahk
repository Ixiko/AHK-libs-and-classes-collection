; ======================================================================================================================
; Namespace:      TC_EX
; Function:       Some functions to use with AHK GUI Tab2 controls (TC).
; Tested with:    AHK 1.1.13.01 (A32/U32/U64)
; Tested on:      Win 7 (x64)
; Changelog:
;     1.0.01.00/2014-01-06/just me - changed function name Delete to RemoveLast.
;     1.0.00.00/2014-01-04/just me - initial release
; Common function parameters:
;     HTC         -  Handle to the tab control.
;     TabIndex    -  1-based index of the tab.
;     TabText     -  Text of the tab's label.
;     IconIndex   -  1-based index of the icon in the tab control's image list. Specify 0 for no icon.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; Add             Adds a new tab at the end of the tabs control.
; Return values:  Returns the 1-based index of the new tab if successful, or 0 otherwise.
; ======================================================================================================================
TC_EX_Add(HTC, TabText, IconIndex := 0) {
   Static TCIF_TEXT := 0x0001
   Static TCIF_IMAGE := 0x0002
   Static TCM_INSERTITEM := A_IsUnicode ? 0x133E : 0x1307 ; TCM_INSERTITEMW : TCM_INSERTITEMA
   Static OffImg := (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
   Static OffTxP := (3 * 4) + (A_PtrSize - 4)
   TC_EX_CreateTCITEM(TCITEM)
   Flags := TCIF_TEXT
   If (ItemIcon > 0)
      Flags |= TCIF_IMAGE
   NumPut(Flags, TCITEM, 0, "UInt")
   NumPut(&TabText, TCITEM, OffTxP, "Ptr")
   If (ItemIcon > 0)
      NumPut(IconIndex - 1, TCITEM, OffImg, "Int")
   SendMessage, % TCM_INSERTITEM, % TC_EX_GetCount(HTC), % &TCITEM, , % "ahk_id " . HTC
   Return ErrorLevel + 1
}
; ======================================================================================================================
; CreateTCITEM    >>> For internal use! <<< Creates and initializes a TCITEM structure.
; ======================================================================================================================
TC_EX_CreateTCITEM(ByRef TCITEM) {
   Static Size := (5 * 4) + (2 * A_PtrSize) + (A_PtrSize - 4)
   VarSetCapacity(TCITEM, Size, 0)
}
; ======================================================================================================================
; GetCount        Retrieves the number of tabs in a tab control.
; Return values:  Returns the number of tabs if successful, or zero otherwise.
; ======================================================================================================================
TC_EX_GetCount(HTC) {
   Static TCM_GETITEMCOUNT := 0x1304
   SendMessage, % TCM_GETITEMCOUNT, 0, 0, , % "ahk_id " . HTC
   Return ErrorLevel
}
; ======================================================================================================================
; GetFocus        Returns the index of the tab that has the focus.
; Return values:  Returns the index of the tab that has the focus.
; ======================================================================================================================
TC_EX_GetFocus(HTC) {
   Static TCM_GETCURFOCUS := 0x132F
   SendMessage, % TCM_GETCURFOCUS, 0, 0, , % "ahk_id " . HTC
   Return ErrorLevel + 1
}
; ======================================================================================================================
; GetIcon         Retrieves the icon assigned to the specified tab in a tab control.
; Return values:  Returns the 1-based icon index if successful, or False otherwise.
; ======================================================================================================================
TC_EX_GetIcon(HTC, TabIndex) {
   Static TCIF_IMAGE := 0x0002
   Static TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305 ; TCM_GETITEMW : TCM_GETITEMA
   Static OffImg := (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   TC_EX_CreateTCITEM(TCITEM)
   NumPut(TCIF_IMAGE, TCITEM, 0, "UInt")
   SendMessage, % TCM_GETITEM, % (TabIndex - 1), % &TCITEM, , % "ahk_id " . HTC
   If (ErrorLevel = 0)
      Return False
   Return NumGet(TCITEM, OffImg, "Int") + 1
}
; ======================================================================================================================
; GetInterior     Retrieves the display area of a tab control relative to it's window.
; Return values:  Always True.
; ======================================================================================================================
TC_EX_GetInterior(HTC, ByRef X, ByRef Y, ByRef W, ByRef H) {
   Static TCM_ADJUSTRECT := 0x1328
   X := Y := W := H := 0
   VarSetCapacity(RECT, 16, 0)
   DllCall("User32.dll\GetClientRect", "Ptr", HTC, "Ptr", &RECT)
   SendMessage, % TCM_ADJUSTRECT, 0, % &RECT, , % "ahk_id " . HTC
   X := NumGet(RECT, 0, "Int")
   Y := NumGet(RECT, 4, "Int")
   W := NumGet(RECT, 8, "Int")
   H := NumGet(RECT, 12, "Int")
   Return True
}
; ======================================================================================================================
; GetRect         Retrieves the bounding rectangle for a tab in a tab control.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
TC_EX_GetRect(HTC, TabIndex, ByRef X, ByRef Y, ByRef W, ByRef H) {
   Static TCM_GETITEMRECT := 0x130A
   X := Y := W := H := 0
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   VarSetCapacity(RECT, 16, 0)
   SendMessage, % TCM_GETITEMRECT, % (TabIndex - 1), % &RECT, , % "ahk_id " . HTC
   If (ErrorLevel = 0)
      Return False
   X := NumGet(RECT, 0, "Int")
   Y := NumGet(RECT, 4, "Int")
   W := NumGet(RECT, 8, "Int")
   H := NumGet(RECT, 12, "Int")
   Return True
}
; ======================================================================================================================
; GetSel          Determines the currently selected tab in a tab control.
; Return values:  Returns the 1-based index of the selected tab if successful, or 0 if no tab is selected.
; ======================================================================================================================
TC_EX_GetSel(HTC) {
   Static TCM_GETCURSEL := 0x130B
   SendMessage, % TCM_GETCURSEL, 0, 0, , % "ahk_id " . HTC
   Return ErrorLevel + 1
}
; ======================================================================================================================
; GetText         Retrieves the label assigned to the specified tab in a tab control.
; Return values:  Returns the label of the specified tab if successful, or an empty string otherwise.
; ======================================================================================================================
TC_EX_GetText(HTC, TabIndex) {
   Static TCIF_TEXT := 0x0001
   Static TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305 ; TCM_GETITEMW : TCM_GETITEMA
   Static OffTxL := (3 * 4) + (A_PtrSize - 4) + A_PtrSize
   Static OffTxP := (3 * 4) + (A_PtrSize - 4)
   Static MaxLength := 256
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return
   VarSetCapacity(ItemText, MaxLength * (A_IsUnicode ? 2 : 1), 0)
   TC_EX_CreateTCITEM(TCITEM)
   NumPut(TCIF_TEXT, TCITEM, 0, "UInt")
   NumPut(&ItemText, TCITEM, OffTxP, "Ptr")
   NumPut(MaxLength, TCITEM, OffTxL, "Int")
   SendMessage, % TCM_GETITEM, % (TabIndex - 1), % &TCITEM, , % "ahk_id " . HTC
   If (ErrorLevel = 0)
      Return
   TxtPtr := NumGet(TCITEM, OffTxP, "UPtr")
   If (TxtPtr = 0)
      Return
   Return StrGet(TxtPtr, MaxLength)
}
; ======================================================================================================================
; HighLight       Sets the highlight state of a tab in a tab control.
; Parameters:     HighLight -  True /False
; Return values:  Returns nonzero if successful, or zero otherwise.
; ======================================================================================================================
TC_EX_HighLight(HTC, TabIndex, HighLight := True) {
   Static TCM_HIGHLIGHTITEM := 0x1333
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   SendMessage, % TCM_HIGHLIGHTITEM, % (TabIndex - 1), % HighLight, , % "ahk_id " . HTC
   Return ErrorLevel
}
; ======================================================================================================================
; RemoveLast      Removes the last tab of a tab control, if it is not the only one.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
TC_EX_RemoveLast(HTC) {
   Static TCM_DELETEITEM := 0x1308
   TabIndex := TC_EX_GetCount(HTC)
   If (TabIndex < 2)
      Return False
   CurSel := TC_EX_GetSel(HTC)
   SendMessage, % TCM_DELETEITEM, % (TabIndex - 1), 0, , % "ahk_id " . HTC
   If (ErrorLevel = 0)
      Return False
   Items := TC_EX_GetCount(HTC)
   If (CurSel > Items)
      CurSel := Items
   Return TC_EX_SetSel(HTC, CurSel)
}
; ======================================================================================================================
; SetIcon         Assigns an icon to a tab in a tab control.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
TC_EX_SetIcon(HTC, TabIndex, IconIndex) {
   Static TCIF_IMAGE := 0x0002
   Static TCM_SETITEM := A_IsUnicode ? 0x133D : 0x1306 ; TCM_SETITEMW : TCM_SETITEMA
   Static OffImg := (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   TC_EX_CreateTCITEM(TCITEM)
   NumPut(TCIF_IMAGE, TCITEM, 0, "UInt")
   NumPut(IconIndex - 1, TCITEM, OffImg, "Int")
   SendMessage, % TCM_SETITEM, % (TabIndex - 1), % &TCITEM, , % "ahk_id " . HTC
   Return ErrorLevel
}
; ======================================================================================================================
; SetImageList    Assigns an image list to a tab control.
; Parameters:     HIL -  Handle to the image list.
; Return values:  Always True.
; ======================================================================================================================
TC_EX_SetImageList(HTC, HIL) {
   Static TCM_SETIMAGELIST := 0x1303
   SendMessage, % TCM_SETIMAGELIST, 0, % HIL, , % "ahk_id " . HTC
   Return True
}
; ======================================================================================================================
; SetFocus        Sets the focus to a specified tab in a tab control.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
TC_EX_SetFocus(HTC, TabIndex) {
   Static TCM_SETCURFOCUS := 0x1330
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   SendMessage, % TCM_SETCURFOCUS, % (TabIndex - 1), 0, , % "ahk_id " . HTC
   Return True
}
; ======================================================================================================================
; SetMinWidth     Sets the minimum width of items in a tab control.
; Parameters:     Width -  New minimum width, in pixels
;                          If this parameter is set to -1, the control will use the default tab width.
; Return values:  Returns an INT value that represents the previous minimum tab width.
; ======================================================================================================================
TC_EX_SetMinWidth(HTC, Width) {
   Static TCM_SETMINTABWIDTH := 0x1331
   SendMessage, % TCM_SETMINTABWIDTH, 0, % Width, , % "ahk_id " . HTC
   Return ErrorLevel
}
; ======================================================================================================================
; SetPadding      Sets the amount of space (padding) around each tab's icon and label in a tab control.
; Parameters:     Horizontal -  Specifies the amount of horizontal padding, in pixels.
;                 Vertical   -  Specifies the amount of vertical padding, in pixels.
;                 Redraw     -  True / False - immediately redraw the tab control
; Return values:  Always True.
; Note:           You should call this method before adding any controls to the Tab to ensure that
;                 default positioning will work as expected.
;                 AHK seems to use defaults of 6 for horizontal and 3 for vertical padding, so values smaller
;                 these will be set to the defaults internally.
; ======================================================================================================================
TC_EX_SetPadding(HTC, Horizontal, Vertical, Redraw = False) {
   Static TCM_SETPADDING := 0x132B
   Static DefaultH := 6
   Static DefaultV := 3
   If (Horizontal < DefaultH)
      Horizontal := DefaultH
   If (Vertical < DefaultV)
      Vertical := DefaultV
   Padding := Horizontal | (Vertical << 16)
   SendMessage, % TCM_SETPADDING, 0, % Padding, , % "ahk_id " . HTC
   If (Redraw)
      TC_EX_SetText(HTC, 1, TC_EX_GetText(HTC, 1))
   Return True
}
; ======================================================================================================================
; SetSel          Selects a tab in a tab control.
; Return values:  Returns the 1-based index of the previously selected tab if successful, or 0 otherwise.
; ======================================================================================================================
TC_EX_SetSel(HTC, TabIndex) {
   Static TCM_SETCURSEL := 0x130C
   Static TCN_SELCHANGE := -551
   Static WM_NOTIFY := 0x004E
   CurSel := TC_EX_GetSel(HTC) - 1
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   SendMessage, % TCM_SETCURSEL, % (TabIndex - 1), 0, , % "ahk_id " . HTC
   If (ErrorLevel != CurSel)
      Return 0
   RetVal := ErrorLevel + 1
   ; A tab control does not send a TCN_SELCHANGING or TCN_SELCHANGE notification code when a tab is selected
   ; using this message. So it must be done manually, at least for AHK.
   CID := DllCall("User32.dll\GetDlgCtrlID", "Ptr", HTC, "Int")
   Parent := DllCall("User32.dll\GetParent", "Ptr", HTC, "UPtr")
   VarSetCapacity(NMHDR, 3 * A_PtrSize, 0)
   NumPut(HTC, NMHDR, 0, "Ptr")
   NumPut(CID, NMHDR, A_PtrSize, "Ptr")
   NumPut(TCN_SELCHANGE, NMHDR, A_PtrSize * 2, "Int")
   SendMessage, % WM_NOTIFY, % HTC, % &NMHDR, , % "ahk_id " . Parent
   Return RetVal
}
; ======================================================================================================================
; SetSize         Sets the width and height of tabs in a fixed-width or owner-drawn tab control.
; Parameters:     Width  -  New width in pixels
;                 Height -  New height in pixels
; Return values:  Returns True if successful, or False otherwise.
; Note:           The width won't be used unless the tab control has the TCS_FIXEDWIDTH style (0x0400).
; ======================================================================================================================
TC_EX_SetSize(HTC, Width, Height) {
   Static TCM_SETITEMSIZE := 0x1329
   If (Height < 0) || (Height > 0xFFFF)
      Return False
   If (Width < 0) || (Width > 0xFFFF)
      Return False
   Size := Width | (Height << 16)
   SendMessage, % TCM_SETITEMSIZE, 0, % Size, , % "ahk_id " . HTC
   Return True
}
; ======================================================================================================================
; SetText         Assigns a label to the specified tab in a tab control.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
TC_EX_SetText(HTC, TabIndex, TabText) {
   Static TCIF_TEXT := 0x0001
   Static TCM_SETITEM := A_IsUnicode ? 0x133D : 0x1306 ; TCM_SETITEMW : TCM_SETITEMA
   Static OffTxP := (3 * 4) + (A_PtrSize - 4)
   If (TabIndex < 0) or (TabIndex > TC_EX_GetCount(HTC))
      Return False
   TC_EX_CreateTCITEM(TCITEM)
   NumPut(TCIF_TEXT, TCITEM, 0, "UInt")
   NumPut(&TabText, TCITEM, OffTxP, "Ptr")
   SendMessage, % TCM_SETITEM, % (TabIndex - 1), % &TCITEM, , % "ahk_id " . HTC
   Return ErrorLevel
}