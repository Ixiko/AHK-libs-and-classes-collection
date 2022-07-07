﻿/*
  ListView function library by Solar. Version 1.01
  
  Flag reference:
	flag  constant  description
	-
	LVIS_FOCUSED         1       The item has the focus, so it is surrounded by a standard focus rectangle. Although more than one item may be selected, only one item can have the focus.
	LVIS_SELECTED        2       The item is selected. The appearance of a selected item depends on whether it has the focus and also on the system colors used for selection.
	LVIS_CUT             4       The item is marked for a cut-and-paste operation.
	LVIS_DROPHILITED     8       The item is highlighted as a drag-and-drop target.
	LVIS_ACTIVATING      0x20    Not currently supported.
	LVIS_UNCHECKED       0x1000  Undocumented.
	LVIS_CHECKED         0x2000  Undocumented.
	LVIS_OVERLAYMASK     0xF00   Use this mask to retrieve the item's overlay image index.
	LVIS_STATEIMAGEMASK  0xF000  Use this mask to retrieve the item's state image index.
	-
	LVNI_ALL            0      Searches for a subsequent item by index, the default value.
	LVNI_FOCUSED        1      The item has the LVIS_FOCUSED state flag set.
	LVNI_SELECTED       2      The item has the LVIS_SELECTED state flag set.
	LVNI_CUT            4      The item has the LVIS_CUT state flag set.
	LVNI_DROPHILITED    8      The item has the LVIS_DROPHILITED state flag set
	LVNI_STATEMASK      0xf    Microsoft Windows Vista and later: A state flag mask with value as follows: LVNI_FOCUSED | LVNI_SELECTED | LVNI_CUT | LVNI_DROPHILITED.
	LVNI_VISIBLEORDER   0x10   Searches for a subsequent item by index, the default value.
	LVNI_PREVIOUS       0x20   Microsoft Windows Vista and later: Searches for an item that is ordered before the item specified in plvii. The LVNI_PREVIOUS flag is not directional (LVNI_ABOVE will find the item positioned above, while LVNI_PREVIOUS will find the item ordered before.) The LVNI_PREVIOUS flag basically reverses the logic of the search performed by the LVM_GETNEXTITEM or LVM_GETNEXTITEMINDEX messages.
	LVNI_VISIBLEONLY    0x40   Microsoft Windows Vista and later: Search the visible items.
	LVNI_SAMEGROUPONLY  0x80   Microsoft Windows Vista and later: Search the current group.
	LVNI_ABOVE          0x100  Searches for an item that is above the specified item.
	LVNI_BELOW          0x200  Searches for an item that is below the specified item.
	LVNI_TOLEFT         0x400  Searches for an item to the left of the specified item.
	LVNI_TORIGHT        0x800  Searches for an item to the right of the specified item.
	LVNI_DIRECTIONMASK  0xf00  Microsoft Windows Vista and later: A directional flag mask with value as follows: LVNI_ABOVE | LVNI_BELOW | LVNI_TOLEFT | LVNI_TORIGHT.
*/


;  h = ListView handle.
LVM_GetCount(h)
{
	Return DllCall("SendMessage", "uint", h, "uint", 4100, "uint", 0, "uint", 0) ; LVM_GETITEMCOUNT
}

; h = ListView handle.
LVM_GetColOrder(h)
{
	hdrH := DllCall("SendMessage", "uint", h, "uint", 4127) ; LVM_GETHEADER
	hdrC := DllCall("SendMessage", "uint", hdrH, "uint", 4608) ; HDM_GETITEMCOUNT
	VarSetCapacity(o, hdrC * A_PtrSize)
	DllCall("SendMessage", "uint", h, "uint", 4155, "uint", hdrC, "ptr", &o) ; LVM_GETCOLUMNORDERARRAY
	Loop, % hdrC
		result .= NumGet(&o, (A_Index - 1) * A_PtrSize) + 1 . ","
	StringTrimRight, result, result, 1
	Return result
}

; h = ListView handle.
; c = 1 based indexed comma delimited list of the new column order.
LVM_SetColOrder(h, c)
{
	StringSplit, c, c, `,
	VarSetCapacity(c, c0 * A_PtrSize)
	Loop, % c0
		NumPut(c%A_Index% - 1, c, (A_Index - 1) * A_PtrSize)
	Return DllCall("SendMessage", "uint", h, "uint", 4154, "uint", c0, "ptr", &c) ; LVM_SETCOLUMNORDERARRAY
}

; h = ListView handle.
; c = 1 based column index to get width of.
LVM_GetColWidth(h, c)
{
	Return DllCall("SendMessage", "uint", h, "uint", 4125, "uint", c-1, "uint", 0) ; LVM_GETCOLUMNWIDTH
}

; h = ListView handle.
; c = 1 based column index to get width of.
; w = New width of the column in pixels. Defaults to -1. The following values are supported in report-view mode:
;	"-1" - Automatically sizes the column.
;	"-2" - Automatically sizes the column to fit the header text. If you use this value with the last column, its width is set to fill the remaining width of the list-view control.
LVM_SetColWidth(h, c, w=-1)
{
	Return DllCall("SendMessage", "uint", h, "uint", 4126, "uint", c-1, "int", w) ; LVM_SETCOLUMNWIDTH
}

; h = ListView handle.
; r = 1 based index of the starting row for the flag search. Omit or 0 to find first occurance specified flags.
; o = Combination of one or more LVNI flags. See reference above.
LVM_GetNext(h, r=0, o=0)
{
	Return DllCall("SendMessage", "uint", h, "uint", 4108, "uint", r-1, "uint", o) + 1 ; LVM_GETNEXTITEM
}

; h = ListView handle.
; r = 1 based index of the row to retrieve the text from.
; c = 1 based index of the column to retrieve the text from.
LVM_GetText(h, r, c=1)
{
	r -= 1 ; convert to 0 based index
	VarSetCapacity(t, 511, 1)
	VarSetCapacity(lvItem, A_PtrSize * 7)
	NumPut(1, lvItem, "uint") ; mask
	NumPut(r, lvItem, A_PtrSize, "int") ; iItem
	NumPut(c-1, lvItem, A_PtrSize * 2, "int") ; iSubItem
	NumPut(&t, lvItem, A_PtrSize * 5, "ptr") ; pszText
	NumPut(512, lvItem, A_PtrSize * 6) ; cchTextMax
	If (A_IsUnicode)
		DllCall("SendMessage", "uint", h, "uint", 4211, "uint", r, "ptr", &lvItem) ; LVM_GETITEMTEXTW
	Else
		DllCall("SendMessage", "uint", h, "uint", 4141, "uint", r, "ptr", &lvItem) ; LVM_GETITEMTEXTA
	Return t
}

; h = ListView handle.
; i = 1 based index of item to delete. Omit to delete all items.
LVM_Delete(h, i=0)
{
	If (i)
		DllCall("SendMessage", "uint", h, "uint", 4104, "uint", i-1, "uint", 0) ; LVM_DELETEITEM
	Else
		DllCall("SendMessage", "uint", h, "uint", 4105, "uint", 0, "uint", 0) ; LVM_DELETEALLITEMS
}

; h = ListView handle.
; r = 1 based index of the row to be modified.
; c = 1 based index of the starting column.
; o = Combination of LVIS flags (see above).
; f* = Fields to modify each column. Each field will be modified in subsequent order starting with the c param. This param is variadic. See: http://www.autohotkey.net/~Lexikos/AutoHotkey_L/docs/Functions.htm#Variadic
LVM_Modify(h, r, c=1, o=0, f*)
{
	c -= 1 ; convert to 0 based index
	VarSetCapacity(lvItem, A_PtrSize * 6, 0)
	NumPut(9, lvItem, "uint")   ; mask
	NumPut(r-1, lvItem, A_PtrSize, "int") ; iItem
	NumPut(o, lvItem, A_PtrSize * 3, "uint") ; state
	NumPut(1, lvItem, A_PtrSize * 4, "uint") ; stateMask
	For index,field in f
	{
		NumPut(c + A_Index - 1, lvItem, A_PtrSize * 2, "int") ; iSubItem
		NumPut(&field, lvItem, A_PtrSize * 5, "ptr") ; pszText
		If (A_IsUnicode)
			DllCall("SendMessage", "uint", h, "uint", 4172, "uint", 0, "ptr", &lvItem) ; LVM_SETITEMW
		Else
			DllCall("SendMessage", "uint", h, "uint", 4171, "uint", 0, "ptr", &lvItem) ; LVM_SETITEMA
	}
}

; h = ListView handle.
; r = 1 based index position of the newly inserted row. Omit or 0 to add to bottom of list.
; c = 1 based index of the starting column.
; o = Multiple of one or more of the LVIS flags listed above.
; f* = Fields to fill each column. Each field will be inserted in subsequent order starting with the c param. This param is variadic. See: http://www.autohotkey.net/~Lexikos/AutoHotkey_L/docs/Functions.htm#Variadic
LVM_Insert(h, r=0, c=1, o=0, f*)
{
	c -= 1 ; convert to 0 based index
	If (r = 0)
		r := (DllCall("SendMessage", "uint", h, "uint", 4100, "uint", 0, "uint", 0) = -1 ? 0) + 1 ; LVM_GETITEMCOUNT
	VarSetCapacity(lvItem, A_PtrSize * 6, 0)
	NumPut(9, lvItem, "uint")   ; mask
	NumPut(r-1, lvItem, A_PtrSize, "int") ; iItem
	NumPut(o, lvItem, A_PtrSize * 3, "uint")  ; state
	NumPut(1, lvItem, A_PtrSize * 4, "uint")  ; stateMask
	DllCall("SendMessage", "uint", h, "uint", 4103, "uint", 0, "uint", &lvItem)	; LVM_INSERTITEM
	For index,field in f
	{
		NumPut(c + A_Index - 1, lvItem, A_PtrSize * 2, "int") ; iSubItem
		NumPut(&field, lvItem, A_PtrSize * 5, "ptr") ; pszText
		If (A_IsUnicode)
			DllCall("SendMessage", "uint", h, "uint", 4172, "uint", 0, "ptr", &lvItem) ; LVM_SETITEMW
		Else
			DllCall("SendMessage", "uint", h, "uint", 4171, "uint", 0, "ptr", &lvItem) ; LVM_SETITEMA
	}
}