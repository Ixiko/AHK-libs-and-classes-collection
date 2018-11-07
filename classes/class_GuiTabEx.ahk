; ======================================================================================================================
; Namespace:      GuiTabEx
; Function:       Wrapper class to provide additional functions for Tab2/Tab controls.
; AHK version:    1.1.07.03
; Language:       English
; Tested on:      Win XPSP3 & VistaSP2 (x86/U32), 7 (x64/U64)
; Version:        1.0.00.00/2012-04-29/just me
;                 1.0.01.00/2012-04-29/just me - fixed ADD to regard ItemIcon
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class GuiTabEx {
   ; ===================================================================================================================
   ; CONSTRUCTOR
   ; ===================================================================================================================
   __New(HWND) {
      This.HWND := HWND
      This.CID := DllCall("User32.dll\GetDlgCtrlID", "Ptr", HWND, "Int")
      This.Parent := DllCall("User32.dll\GetParent", "Ptr", HWND, "UPtr")
      This.AHKID := "ahk_id " . HWND
      This.Base := This.TabCtrlBase
   }
   ; ===================================================================================================================
   ; Base class for new instances providing all public methods
   ; ===================================================================================================================
   Class TabCtrlBase {
      Static TCIF_TEXT := 0x0001
      Static TCIF_IMAGE := 0x0002
      Static TCM_ADJUSTRECT := 0x1328
      Static TCM_DELETEITEM := 0x1308
      Static TCM_GETCURSEL := 0x130B
      Static TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305   ; TCM_GETITEMW : TCM_GETITEMA
      Static TCM_GETITEMCOUNT := 0x1304
      Static TCM_HIGHLIGHTITEM := 0x1333
      Static TCM_INSERTITEM := A_IsUnicode ? 0x133E : 0x1307   ; TCM_INSERTITEMW : TCM_INSERTITEMA
      Static TCM_SETCURSEL := 0x130C
      Static TCM_SETIMAGELIST := 0x1303
      Static TCM_SETITEM := A_IsUnicode ? 0x133D : 0x1306   ; TCM_SETITEMW : TCM_SETITEMA
      Static TCM_SETMINTABWIDTH := 0x1331
      Static TCM_SETPADDING := 0x132B
      Static OffTxP := (3 * 4) + (A_PtrSize - 4)
      Static OffTxL := (3 * 4) + (A_PtrSize - 4) + A_PtrSize
      Static OffImg := (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
      ; ----------------------------------------------------------------------------------------------------------------
      ; You must not instantiate instances
      ; ----------------------------------------------------------------------------------------------------------------
      __New(P*) {
         Return False
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Add             Inserts a new tab at the end of a tab control.
      ; Parameters:     ItemText -  Caption for the new tab
      ;                 ItemIcon -  1-based index in the tab control's image list, or 0 for no icon
      ; Return values:  Returns the 1-based index of the new tab if successful, or 0 otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      Add(ItemText, ItemIcon = 0) {
         TCITEM := ""
         This.CreateTCITEM(TCITEM)
         Flags := This.TCIF_TEXT
         If (ItemIcon > 0)
            Flags |= This.TCIF_IMAGE
         NumPut(Flags, TCITEM, 0, "UInt")
         NumPut(&ItemText, TCITEM, This.OffTxP, "Ptr")
         If (ItemIcon > 0)
            NumPut(ItemIcon, TCITEM, This.OffImg, "Int")
         SendMessage, This.TCM_INSERTITEM, This.GetCount(), &TCITEM, , % This.AHKID
         If (ErrorLevel = -1)
            Return This.SetError(True, False)
         Return This.SetError(False, ErrorLevel + 1)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; CreateTCITEM    Creates and initializes a TCITEM structure
      ; Parameters:     TCITEM   -  Variable to hold the structure.
      ; Return values:  None.
      ; ----------------------------------------------------------------------------------------------------------------
      CreateTCITEM(ByRef TCITEM) {
         Static Size := (5 * 4) + (2 * A_PtrSize) + (A_PtrSize - 4)
         VarSetCapacity(TCITEM, Size, 0)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; GetCount        Retrieves the number of tabs in a tab control.
      ; Return values:  Returns the number of tabs if successful, or zero otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      GetCount() {
         SendMessage, This.TCM_GETITEMCOUNT, 0, 0, , % This.AHKID
         Return This.SetError(False, ErrorLevel)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; GetIcon         Retrieves the icon assigned to the specified tab in a tab control.
      ; Parameters:     Item     -  1-based index of the tab
      ; Return values:  Returns the 1-based icon index if successful, or False otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      GetIcon(Item) {
         If (Item < 0) or (Item > This.GetCount())
            Return This.SetError(True, False)
         TCITEM := ""
         This.CreateTCITEM(TCITEM)
         NumPut(This.TCIF_IMAGE, TCITEM, 0, "UInt")
         SendMessage, This.TCM_GETITEM, Item - 1, &TCITEM, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetError(True, False)
         ItemIcon := NumGet(TCITEM, OffImg, "Int") + 1
         Return This.SetError(False, ItemIcon)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; GetInterior     Determines the display area of a tab control relative to it's window.
      ; Return values:  Always True.
      ; ----------------------------------------------------------------------------------------------------------------
      GetInterior(ByRef X, ByRef Y, ByRef W, ByRef H) {
         VarSetCapacity(RECT, 16, 0)
         DllCall("User32.dll\GetClientRect", "Ptr", This.HWND, "Ptr", &RECT)
         SendMessage, This.TCM_ADJUSTRECT, 0, &RECT, , % This.AHKID
         X := NumGet(RECT, 0, "Int")
         Y := NumGet(RECT, 4, "Int")
         W := NumGet(RECT, 8, "Int")
         H := NumGet(RECT, 12, "Int")
         Return This.SetError(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; GetSel          Determines the currently selected tab in a tab control.
      ; Return values:  Returns the 1-based index of the selected tab if successful, or 0 if no tab is selected.
      ; ----------------------------------------------------------------------------------------------------------------
      GetSel() {
         SendMessage, This.TCM_GETCURSEL, 0, 0, , % This.AHKID
         Return This.SetError(False, ErrorLevel + 1)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; GetText         Retrieves the label assigned to the specified tab in a tab control.
      ; Parameters:     Item     -  1-based index of the tab
      ; Return values:  Returns the label of the specified tab if successful, or an empty string otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      GetText(Item) {
         Static MaxLength := 256
         If (Item < 0) or (Item > This.GetCount())
            Return This.SetError(True, "")
         VarSetCapacity(ItemText, MaxLength * (A_IsUnicode ? 2 : 1), 0)
         TCITEM := ""
         This.CreateTCITEM(TCITEM)
         NumPut(This.TCIF_TEXT, TCITEM, 0, "UInt")
         NumPut(&ItemText, TCITEM, This.OffTxP, "Ptr")
         NumPut(MaxLength, TCITEM, This.OffTxL, "Int")
         SendMessage, This.TCM_GETITEM, Item - 1, &TCITEM, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetError(True, "")
         TxtPtr := NumGet(TCITEM, This.OffTxP, "UPtr")
         If (TxtPtr = 0)
            Return This.SetError(False, "")
         Return This.SetError(False, StrGet(TxtPtr, MaxLength))
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; HighLight       Sets the highlight state of a tab item.
      ; Parameters:     Item        -  1-based index of the tab
      ;                 HighLight   -  True /False
      ; Return values:  Returns nonzero if successful, or zero otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      HighLight(Item, HighLight = True) {
         If (Item < 0) or (Item > This.GetCount())
            Return This.SetError(True, False)
         SendMessage, This.TCM_HIGHLIGHTITEM, Item - 1, HighLight, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetEnv(True, False)
         Return This.SetEnv(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; RemoveLast      Removes the last tab from a tab control, if it isn't the only one.
      ; Return values:  Returns True if successful, or False otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      RemoveLast() {
         Item := This.GetCount() - 1
         If (Item = 0)
            Return This.SetError(True, False)
         CurSel := This.GetSel() - 1
         SendMessage, This.TCM_DELETEITEM, Item, 0, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetError(True, False)
         If (Item = CurSel)
            This.SetSel(Item)
         Return This.SetError(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetError        Sets ErrorLevel and returns the passed return value, for internal use!!!
      ; Parameters:     ErrVal   -  Value for ErrorLevel
      ;                 RetVal   -  Return value
      ; Return values:  Returns the value passed through RetVal
      ; ----------------------------------------------------------------------------------------------------------------
      SetError(ErrVal, RetVal) {
         ErrorLevel := ErrVal
         Return RetVal
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetIcon         Assigns an icon to the specified tab in a tab control.
      ; Parameters:     Item     -  1-based index of the tab
      ;                 ItemIcon -  1-based index of the icon in the image list, 0 will remove the icon
      ; Return values:  Returns True if successful, or False otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      SetIcon(Item, ItemIcon) {
         If (Item < 0) or (Item > This.GetCount())
            Return This.SetError(True, False)
         TCITEM := ""
         This.CreateTCITEM(TCITEM)
         NumPut(This.TCIF_IMAGE, TCITEM, 0, "UInt")
         NumPut(ItemIcon - 1, TCITEM, This.OffImg, "Int")
         SendMessage, This.TCM_SETITEM, Item - 1, &TCITEM, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetError(True, False)
         Return This.SetError(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetImageList    Assigns an image list to a tab control.
      ; Parameters:     HIL      -  Handle to the image list
      ; Return values:  Always True.
      ; ----------------------------------------------------------------------------------------------------------------
      SetImageList(HIL) {
         SendMessage, This.TCM_SETIMAGELIST, 0, HIL, , % This.AHKID
         Return This.SetError(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetMinWidth     Sets the minimum width of items in a tab control.
      ; Parameters:     Width    -  New minimum width, in pixels
      ; Return values:  Returns an INT value that represents the previous minimum tab width.
      ; ----------------------------------------------------------------------------------------------------------------
      SetMinWidth(Width) {
         SendMessage, This.TCM_SETMINTABWIDTH, 0, Width, , % This.AHKID
         Return This.SetError(False, ErrorLevel)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetPadding      Sets the amount of space (padding) around each tab's icon and label in a tab control.
      ; Parameters:     Horizontal  -  Specifies the amount of horizontal padding, in pixels.
      ;                 Vertical    -  Specifies the amount of vertical padding, in pixels.
      ;                 Redraw      -  True / False - immediately redraw the tab control
      ; Return values:  Always True.
      ; Note:           You should call this method before adding any controls to the Tab to ensure that
      ;                 default positioning will work as expected.
      ;                 AHK seems to use defaults of 6 for horizontal and 3 for vertical padding, so values smaller
      ;                 these will be set to the defaults internally.
      ; ----------------------------------------------------------------------------------------------------------------
      SetPadding(Horizontal, Vertical, Redraw = False) {
         Static DefaultH := 6
         Static DefaultV := 3
         If (Horizontal < DefaultH)
            Horizontal := DefaultH
         If (Vertical < DefaultV)
            Vertical := DefaultV
         Padding := Horizontal | (Vertical << 16)
         SendMessage, This.TCM_SETPADDING, 0, Padding, , % This.AHKID
         If (Redraw)
            This.SetText(1, This.GetText(1))
         Return This.SetError(False, True)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetSel          Selects a tab in a tab control.
      ; Parameters:     Item     -  1-based index of the item
      ; Return values:  Returns the 1-based index of the previously selected tab if successful, or 0 otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      SetSel(Item) {
         Static TCN_SELCHANGE := -551
         Static WM_NOTIFY := 0x004E
         If (Item > This.GetCount() Or (Item < 1))
            Return This.SetError(True, 0)
         SendMessage, This.TCM_SETCURSEL, Item - 1, 0, , % This.AHKID
         If (ErrorLevel = -1)
            Return This.SetError(True, 0)
         RetVal := ErrorLevel + 1
         ; A tab control does not send a TCN_SELCHANGING or TCN_SELCHANGE notification code when a tab is selected
         ; using this message. So it must be done manually, at least for AHK.
         VarSetCapacity(NMHDR, 3 * A_PtrSize, 0)
         NumPut(This.HWND, NMHDR, 0, "Ptr")
         NumPut(This.CID, NMHDR, A_PtrSize, "Ptr")
         NumPut(TCN_SELCHANGE, NMHDR, A_PtrSize * 2, "Int")
         SendMessage, WM_NOTIFY, This.HWND, &NMHDR, , % "ahk_id " . This.Parent
         Return This.SetError(False, RetVal)
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; SetText         Assigns a label to the specified tab in a tab control.
      ; Parameters:     Item     -  1-based index of the tab
      ;                 ItemText -  New label
      ; Return values:  Returns True if successful, or False otherwise.
      ; ----------------------------------------------------------------------------------------------------------------
      SetText(Item, ItemText) {
         If (Item < 0) or (Item > This.GetCount())
            Return This.SetError(True, False)
         TCITEM := ""
         This.CreateTCITEM(TCITEM)
         NumPut(This.TCIF_TEXT, TCITEM, 0, "UInt")
         NumPut(&ItemText, TCITEM, This.OffTxP, "Ptr")
         SendMessage, This.TCM_SETITEM, Item - 1, &TCITEM, , % This.AHKID
         If !(ErrorLevel)
            Return This.SetError(True, False)
         Return This.SetError(False, True)
      }
   }
}
