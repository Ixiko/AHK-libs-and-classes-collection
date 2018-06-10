; ======================================================================================================================
; Namespace:      LBEX
; Function:       Some functions to use with AHK GUI ListBox controls (LB).
; Tested with:    AHK 1.1.23.01 (A32/U32/U64)
; Tested on:      Win 10 Pro (x64)
; Changelog:
;     1.0.01.00/2016-02-14/just me - added LBEX_SetColumnTabs()
;     1.0.00.00/2014-10-01/just me - initial release
; Common function parameters (not mentioned in the parameter descriptions of functions):
;     HLB         -  Handle to the list box control.
;     Index       -  1-based index of a list box item (line).
; MSDN:           msdn.microsoft.com/en-us/library/bb775146(v=vs.85).aspx
; ======================================================================================================================
; Add             Adds a string to a list box.
;                 If the list box does not have the LBS_SORT style, the string is added to the end of the list.
;                 Otherwise, the string is inserted into the list and the list is sorted.
; Parameters:     String   -  String to be added.
; Return values:  Returns the index of the string in the list box, 0, if an error occurs, or -1, if there
;                 is insufficient space to store the new string.
; ======================================================================================================================
LBEX_Add(HLB, ByRef String) {
   Static LB_ADDSTRING := 0x0180
   SendMessage, % LB_ADDSTRING, 0, % &String, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; CalcIdealWidth  Calculates the ideal width of a list box needed to display the current content.
; Parameters:     HLB         -  Handle to the list box.
;                                If you want to determine the ideal width of an existing control specify its HWND;
;                                all other parameters are ignored in this case.
;                                Otherwise pass 0 and use the other parameters to specify the content and other options.
;                 ------------------------------------------------------------------------------------------------------
;                 Content     -  Content to be displayed in the list box.
;                 Delimiter   -  The field separator to be used.
;                 FontOptions -  The 'Options' parameter to be used for Gui, Font, ...
;                 FontName    -  The 'Name' parameter to be used for Gui, Font, ...
; Return values:  Returns the ideal width of the list box in respect to the content.
; ======================================================================================================================
LBEX_CalcIdealWidth(HLB, Content := "", Delimiter := "|", FontOptions := "", FontName := "") {
   DestroyGui := MaxW := 0
   If !(HLB) {
      If (Content = "")
         Return -1
      Gui, LB_EX_CalcContentWidthGui: Font, %FontOptions%, %FontName%
      Gui, LB_EX_CalcContentWidthGui: Add, ListBox, hwndHLB, %Content%
      DestroyGui := True
   }
   ControlGet, Content, List, , , ahk_id %HLB%
   Items := StrSplit(Content, "`n")
   SendMessage, 0x0031, 0, 0, , ahk_id %HLB% ; WM_GETFONT
   HFONT := ErrorLevel
   HDC := DllCall("User32.dll\GetDC", "Ptr", HLB, "UPtr")
   DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
   VarSetCapacity(SIZE, 8, 0)
   For Each, Item In Items {
      DllCall("Gdi32.dll\GetTextExtentPoint32", "Ptr", HDC, "Ptr", &Item, "Int", StrLen(Item), "UIntP", Width)
      If (Width > MaxW)
         MaxW := Width
   }
   DllCall("User32.dll\ReleaseDC", "Ptr", HLB, "Ptr", HDC)
   If (DestroyGui)
      Gui, LB_EX_CalcContentWidthGui: Destroy
   Return MaxW + 8 ; + 8 for the margins
}
; ======================================================================================================================
; Delete          Deletes an item (row) in a list box.
; Return values:  The return value is a count of the items remaining in the list, or 0, if Index is greater than the
;                 number of items in the list.
; ======================================================================================================================
LBEX_Delete(HLB, Index) {
   Static LB_DELETESTRING := 0x0182
   SendMessage, % LB_DELETESTRING, % (Index - 1), 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; DeleteAll       Removes all items from a list box.
; Return values:  Always True.
; ======================================================================================================================
LBEX_DeleteAll(HLB) {
   Static LB_RESETCONTENT := 0x0184
   SendMessage, % LB_RESETCONTENT, 0, 0, , % "ahk_id " . HLB
   Return True
}
; ======================================================================================================================
; Find            Finds the first string in a list box that begins with the specified string.
; Parameters:     String   -  String to search for.
;                 Index    -  The index of the item before the first item to be searched.
;                             Default: 0 - the entire list box is searched.
; Return values:  The return value is the index of the matching item, or LB_ERR if the search was unsuccessful.
; ======================================================================================================================
LBEX_Find(HLB, ByRef String, Index := 0) {
   Static LB_FINDSTRING := 0x018F
   SendMessage, % LB_FINDSTRING, % (Index - 1), % &String, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; FindExact       Finds the first list box string that exactly matches the specified string.
;                 The search is not case sensitive.
; Parameters:     String   -  String to search for.
;                 Index    -  The index of the item before the first item to be searched.
;                             Default: 0 - the entire list box is searched.
; Return values:  The return value is the index of the matching item, or LB_ERR if the search was unsuccessful.
; ======================================================================================================================
LBEX_FindExact(HLB, ByRef String, Index := 0) {
   Static LB_FINDSTRINGEXACT := 0x01A2
   SendMessage, % LB_FINDSTRINGEXACT, % (Index - 1), % &String, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; GetCount        Gets the number of items in a list box.
; Return values:  The return value is the number of items in the list box, or -1 if an error occurs.
; ======================================================================================================================
LBEX_GetCount(HLB) {
   Static LB_GETCOUNT := 0x018B
   SendMessage, % LB_GETCOUNT, 0, 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetCurrentSel   Gets the index of the currently selected item, if any, in a single-selection list box.
; Return values:  In a single-selection list box, the return value is the index of the currently selected item.
;                 If there is no selection, the return value is 0.
; Remarks:        If sent to a multiple-selection list box, the function returns the index of the item that has the
;                 focus rectangle. If no items are selected, it returns zero.
; ======================================================================================================================
LBEX_GetCurrentSel(HLB) {
   Static LB_GETCURSEL := 0x0188
   SendMessage, % LB_GETCURSEL, 0, 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; GetData         Gets the application-defined value associated with the specified list box item.
; Return values:  The return value is the value associated with the item, or -1 if an error occurs.
; ======================================================================================================================
LBEX_GetData(HLB, Index) {
   Static LB_GETITEMDATA := 0x0199
   SendMessage, % LB_GETITEMDATA, % (Index - 1), 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetFocus        Retrieves the index of the item that has the focus in a multiple-selection list box.
;                 The item may or may not be selected. This function can also be used to get the index of the item
;                 that is currently selected in a single-selection list box.
; Return values:  The return value is the index of the focused item, or 0, if no item has the focus.
; Remarks:        A multiple selection spans all items from the anchor item to the focused item.
; ======================================================================================================================
LBEX_GetFocus(HLB) {
   Static LB_GETCARETINDEX := 0x019F
   SendMessage, % LB_GETCARETINDEX, 0, 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; GetItemHeight   Gets the height of items in a list box.
; Return values:  The return value is the height, in pixels, of each item in the list box, or -1 if an error occurs.
; ======================================================================================================================
LBEX_GetItemHeight(HLB) {
   Static LB_GETITEMHEIGHT := 0x01A1
   SendMessage, % LB_GETITEMHEIGHT, 0, 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetSelCount     Gets the total number of selected items in a multiple-selection list box.
; Return values:  The return value is the count of selected items in the list box.
;                 If the list box is a single-selection list box, the return value is -1.
; ======================================================================================================================
LBEX_GetSelCount(HLB) {
   Static LB_GETSELCOUNT := 0x0190
   SendMessage, % LB_GETSELCOUNT, 0, 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetSelItems     Retrieves an array of selected items in a multiple-selection list box.
; Parameters:     ItemArray   -  Array to fill with the indices of the selected items.
;                 MaxItems    -  The maximum number of selected items whose item numbers are to be placed in the array.
;                                Default: 0 - all selected items.
; Return values:  The return value is the number of items placed in the buffer.
;                 If the list box is a single-selection list box, the return value is -1.
; ======================================================================================================================
LBEX_GetSelItems(HLB, ByRef ItemArray, MaxItems := 0) {
   Static LB_GETSELITEMS := 0x0191
   ItemArray := []
   If (MaxItems = 0)
      MaxItems := LBEX_GetSelCount(HLB)
   If (MaxItems < 1)
      Return MaxItems
   VarSetCapacity(Items, MaxItems * 4, 0)
   SendMessage, % LB_GETSELITEMS, % MaxItems, % &Items, , % "ahk_id " . HLB
   MaxItems := ErrorLevel
   If (MaxItems < 1)
      Return MaxItems
   Loop, % MaxItems
      ItemArray[A_Index] := NumGet(Items, (A_Index - 1) * 4, "UInt") + 1
   Return MaxItems
}
; ======================================================================================================================
; GetSelStart     Gets the index of the anchor item from which a multiple selection starts.
; Return values:  The return value is the index of the anchor item.
; Remarks:        A multiple selection spans all items from the anchor item to the caret item.
; ======================================================================================================================
LBEX_GetSelStart(HLB) {
   Static LB_GETANCHORINDEX := 0x019D
   SendMessage, % LB_GETANCHORINDEX, 0, 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; GetSelState     Gets the selection state of an item.
; Return values:  If the item is selected, the return value is greater than zero; otherwise, it is zero.
;                 If an error occurs, the return value is -1.
; ======================================================================================================================
LBEX_GetSelState(HLB, Index) {
   Static LB_GETSEL := 0x0187
   SendMessage, % LB_GETSEL, % (Index - 1), 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetText         Gets a string from a list box.
; Return values:  The return value is the string contained in the item, or an empty string, if an error occurs.
; ======================================================================================================================
LBEX_GetText(HLB, Index) {
   Static LB_GETTEXT := 0x0189
   Len := LBEX_GetTextLen(HLB, Index)
   If (Len = -1)
      Return ""
   VarSetCapacity(Text, Len << !!A_IsUnicode, 0)
   SendMessage, % LB_GETTEXT, % (Index - 1), % &Text, , % "ahk_id " . HLB
   Return StrGet(&Text, Len)
}
; ======================================================================================================================
; GetTextLen      Gets the length of a string in a list box.
; Return values:  The return value is the length of the string, in characters, excluding the terminating null character.
;                 If an error occurs, the return value is -1.
; ======================================================================================================================
LBEX_GetTextLen(HLB, Index) {
   Static LB_GETTEXTLEN := 0x018A
   SendMessage, % LB_GETTEXTLEN, % (Index - 1), 0, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; GetTopIndex     Gets the index of the first visible item in a list box.
; Return values:  The return value is the index of the first visible item in the list box.
; ======================================================================================================================
LBEX_GetTopIndex(HLB, Index) {
   Static LB_GETTOPINDEX := 0x018E
   SendMessage, % LB_GETTOPINDEX, 0, 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; Insert          Inserts a string into a list box.
;                 Unlike LV_EX_Add(), this function does not cause a list box with the LBS_SORT style to be sorted.
; Parameters:     Index    -  The index of the position at which to insert the string.
;                             If this parameter is 0, the string is added to the end of the list.
;                 String   -  String to be added.
; Return values:  The return value is the index of the string in the list box, 0, if an error occurs, or -1, if there
;                 is insufficient space to store the new string.
; ======================================================================================================================
LBEX_Insert(HLB, Index, ByRef String) {
   Static LB_INSERTSTRING := 0x0181
   SendMessage, % LB_INSERTSTRING, % (Index - 1), % &String, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; ItemFromPoint   Gets the index of the item nearest the specified point in a list box.
; Parameters:     X  -  The X-coordinate, relative to the upper-left corner of the client area of the list box.
;                 Y  -  The Y-coordinate, relative to the upper-left corner of the client area of the list box..
; Return values:  The return value contains the index of the nearest item in the LOWORD. The HIWORD is zero if the
;                 specified point is in the client area of the list box, or one if it is outside the client area.
; ======================================================================================================================
LBEX_ItemFromPoint(HLB, X, Y) {
   Static LB_ITEMFROMPOINT := 0x01A9
   X &= 0xFFFF
   Y &= 0xFFFF
   SendMessage, % LB_ITEMFROMPOINT, 0, % (X | (Y << 16)), , % "ahk_id " . HLB
   Return ((ErrorLevel & 0xFFFF) + 1) | (ErrorLevel & 0xFFFF0000)
}
; ======================================================================================================================
; SelectRange     Selects or deselects one or more consecutive items in a multiple-selection list box.
; Parameters:     First    -  The index of the first item to select/deselect.
;                 Last     -  The index of the last item to select/deselect.
;                 Select   -  True to select the range of items, or False to deselect it.
;                             Default: True - select.
; Return values:  If an error occurs, the return value is False.
; Remarks:        Use this function only with multiple-selection list boxes. This function can select a range only
;                 within the first 65,536 items.
; ======================================================================================================================
LBEX_SelectRange(HLB, First, Last, Select := True) {
   Static LB_SELITEMRANGE := 0x019B
   First &= 0xFFFF
   Last &= 0xFFFF
   SendMessage, % LB_SELITEMRANGE, % !!Select, % (First - 1) | ((Last - 1) << 16), , % "ahk_id " . HLB
   Return (ErrorLevel > 0x7FFFFFFF ? False : True)
}
; ======================================================================================================================
; SelectString    Searches a list box for an item that begins with the characters in a specified string.
;                 If a matching item is found, the item is selected.
; Parameters:     String   -  String to search for.
;                 Index    -  The index of the item before the first item to be searched.
;                             Default: 0 - the entire list box is searched.
; Return values:  If the search is successful, the return value is the index of the selected item.
;                 If the search is unsuccessful, the return value is 0 and the current selection is not changed.
; Remarks:        The list box is scrolled, if necessary, to bring the selected item into view.
;                 Do not use this function with a list box that has the LBS_MULTIPLESEL or the LBS_EXTENDEDSEL styles.
; ======================================================================================================================
LBEX_SelectString(HLB, ByRef String, Index := 0) {
   Static LB_SELECTSTRING := 0x018C
   SendMessage, % LB_SELECTSTRING, % (Index - 1), % &String, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetColumnTabs   Sets the tab stop positions according to the columns of a list box.
; Parameters:     ColGap   -  The amount of average characters widths used to separate the columns as an integer or
;                             floating point number. The minimum is 1.
;                             Default: 2
; Return values:  True if successful; otherwise False.
; Remarks:        The list box must have been created with the LBS_USETABSTOPS style.
;                 Columns must be separated by exactly one tab.
; Credits:        Original idea by jballi - autohotkey.com/boards/viewtopic.php?p=69544#p69544
; ======================================================================================================================
LBEX_SetColumnTabs(HLB, ColGap := 2) {
   Static StrDBU := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
   Static LenDBU := StrLen(StrDBU)
   ; Get the items
   ControlGet, Items, List, , , ahk_id %HLB%
   If (Items = "") ; error or empty list box
      Return False
   ; Check ColGap parameter
   If ((ColGap + 0) < 1)
      ColGap := 1
   ; Get the font
   HFONT := DllCall("SendMessage", "Ptr", HLB, "UInt", 0x0031, "Ptr", 0, "Ptr", 0, "UPtr")
   ; Get the DC
   HDC := DllCall("GetDC", "Ptr", HLB, "UPtr")
   ; Select the font
   DllCall("SelectObject", "Ptr", HDC, "Ptr", HFONT)
   ; Get the horizontal dialog base units
   VarSetCapacity(SIZE, 8, 0)
   DllCall("GetTextExtentPoint32", "Ptr", HDC, "Str", StrDBU, "Int", LenDBU, "Ptr", &SIZE)
   HDBU := Round(NumGet(SIZE, "Int") / LenDBU)
   ; Calculate the tab stop units per column
   ColUnits := []
   Loop, Parse, Items, `n
   {
      Loop, Parse, A_LoopField, `t
      {
         If (ColUnits[A_Index] = "")
            ColUnits[A_Index] := 0
         If !(Len := StrLen(A_LoopField))
            Continue
         DllCall("GetTextExtentPoint32", "Ptr", HDC, "Str", A_LoopField, "Int", Len, "Ptr", &SIZE)
         Units := Round((NumGet(SIZE, 0, "Int") / HDBU * 4) + (4 * ColGap))
         If (Units > ColUnits[A_Index])
            ColUnits[A_Index] := Units
      }
   }
   ; Release the DC
   DllCall("ReleaseDC", "Ptr", HLB, "Ptr", HDC)
   ; If less than two columns were found, reset the tab stops to their default
   TabCount := ColUnits.Length()
   If (TabCount < 2)
      Return LBEX_SetTabStops(HLB, 0)
   ; Build the LB_SETTABSTOPS message array parameter
   VarSetCapacity(TabArray, TabCount * 4, 0)
   TabAddr := &TabArray
   TabPos := 0
   For Index, Units In ColUnits
      TabAddr := NumPut(TabPos += Units, TabAddr + 0, "UInt")
   ; Set the tab stops - LB_SETTABSTOPS = 0x0192
   Return DllCall("SendMessage", "Ptr", HLB, "UInt", 0x0192, "Ptr", TabCount, "Ptr", &TabArray, "UInt")
}
; ======================================================================================================================
; SetCurSel       Selects an item and scrolls it into view, if necessary.
; Parameters:     Index    -  If set to 0, the list box is set to have no selection.
; Return values:  If the function succeeds, the return value is True; otherwise 0.
; Remarks:        Use this function only with single-selection list boxes.
; ======================================================================================================================
LBEX_SetCurSel(HLB, Index) {
   Static LB_SETCURSEL := 0x0186
   SendMessage, % LB_SETCURSEL, % (Index - 1), 0, , % "ahk_id " . HLB
   Return (Index = 0 ? True : ErrorLevel + 1)
}
; ======================================================================================================================
; SetFocus        Sets the focus rectangle to the specified item in a multiple-selection list box.
;                 If the item is not visible, it is scrolled into view.
; Return values:  If the function succeeds, the return value is True; otherwise 0.
; Remarks:        A multiple selection spans all items from the anchor item to the caret item.
; ======================================================================================================================
LBEX_SetFocus(HLB, Index) {
   Static LB_SETCARETINDEX := 0x019E
   SendMessage, % LB_SETCARETINDEX, % (Index - 1), 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetItemData     Sets a value associated with the specified item in a list box.
; Parameters:     Data     -  Specifies the numeric value to be associated with the item.
; Return values:  If an error occurs, the return value is False.
; ======================================================================================================================
LBEX_SetItemData(HLB, Index, Data) {
   Static LB_SETITEMDATA := 0x019A
   SendMessage, % LB_SETITEMDATA, % (Index - 1), % Data, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetItemHeight   Sets the height, in pixels, of items in a list box.
; Parameters:     Height   -  Specifies the height, in pixels, of the item. The maximum height is 255 pixels.
; Return values:  If an error occurs, the return value is False.
; ======================================================================================================================
LBEX_SetItemHeight(HLB, Index, Height) {
   Static LB_SETITEMHEIGHT := 0x01A0
   SendMessage, % LB_SETITEMHEIGHT, % (Index - 1), % Height, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetSel          Selects an item in a multiple-selection list box and scrolls the item into view, if necessary.
; Parameters:     Index    -  If set to 0, the selection is added to or removed from all items.
;                 Select   -  True to select the items, or False to deselect them.
;                             Default: True - select.
; Return values:  If the function succeeds, the return value is True; otherwise 0.
; Remarks:        Use this function only with multiple-selection list boxes.
; ======================================================================================================================
LBEX_SetSel(HLB, Index, Select := True) {
   Static LB_SETSEL := 0x0185
   SendMessage, % LB_SETSEL, % Select, % (Index - 1), , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetSelStart     Sets the anchor item, that is, the item from which a multiple selection starts.
; Return values:  If the function succeeds, the return value is True; otherwise 0.
; Remarks:        A multiple selection spans all items from the anchor item to the caret item.
; ======================================================================================================================
LBEX_SetSelStart(HLB, Index) {
   Static LB_SETANCHORINDEX := 0x019C
   SendMessage, % LB_SETANCHORINDEX, % (Index - 1), 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; SetTabStops     Sets the tab-stop positions in a list box.
; Parameters:     TabArray -  Array of integers or floating point numbers containing the tab stops as character
;                             positions according to the average character width of the used font.
;                             The tab stops must be sorted in ascending order; backward tabs are not allowed.
;                             If only one value is passed, the list box will have tab stops separated by this distance.
;                             If TabArray is set to 0, the list box will be reset to the default tab stops.
; Return values:  If all the specified tabs are set, the return value is True; otherwise, it is False.
; Remarks:        The list box must have been created with the LBS_USETABSTOPS style.
; ======================================================================================================================
LBEX_SetTabStops(HLB, TabArray) {
   Static LB_SETTABSTOPS := 0x0192
   If (TabArray = 0) {
      TabCount := 0
      TabsAddr := 0
   }
   Else {
      TabCount := TabArray.MaxIndex()
      VarSetCapacity(Tabs, TabCount * 4, 0)
      For Each, TabPos in TabArray
         NumPut(TabPos * 4, Tabs, (A_Index - 1) * 4, "UInt")
      TabsAddr := &Tabs
   }
   SendMessage, % LB_SETTABSTOPS, % TabCount, % TabsAddr, , % "ahk_id " . HLB
   Return ErrorLevel
}
; ======================================================================================================================
; SetTopIndex     Ensures that the specified item in a list box is visible.
; Return values:  If the function succeeds, the return value is True; otherwise, it is 0.
; Remarks:        The system scrolls the list box contents so that either the specified item appears at the top of the
;                 list box or the maximum scroll range has been reached.
; ======================================================================================================================
LBEX_SetTopIndex(HLB, Index) {
   Static LB_SETTOPINDEX := 0x0197
   SendMessage, % LB_SETTOPINDEX, % (Index - 1), 0, , % "ahk_id " . HLB
   Return (ErrorLevel + 1)
}