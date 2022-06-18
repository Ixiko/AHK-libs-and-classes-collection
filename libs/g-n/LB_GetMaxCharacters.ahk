;Used to retrieve the number of characters that can fit in a given width
LB_GetMaxCharacters(hLB, iWidth) { ;We need the listbox to get the font used

	;Declare variables (for clarity's sake)
	hDCListBox := 0
	hFontOld := 0
	hFontNew := 0
	VarSetCapacity(lptm, A_IsUnicode ? 60 : 56)

	;Use GetDC to retrieve handle to the display context for the list box and store it in hDCListBox
	hDCListBox := DllCall("GetDC", "Ptr", hLB, "Ptr")

	;Send the list box a WM_GETFONT message to retrieve the handle to the
	;font that the list box is using, and store this handle in hFontNew
	SendMessage 49, 0, 0,, ahk_id %hLB%
	hFontNew := ErrorLevel

	;Use SelectObject to select the font into the display context.
	;Retain the return value from the SelectObject call in hFontOld
	hFontOld := DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontNew, "Ptr")

	;Call GetTextMetrics to get additional information about the font being used
	DllCall("GetTextMetrics", "Ptr", hDCListBox, "Ptr", &lptm)
	tmAveCharWidth := NumGet(lptm, 20, "UInt")

	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontOld)
	DllCall("ReleaseDC", "Ptr", hLB, "Ptr", hDCListBox)

	Return Floor(iWidth / tmAveCharWidth)
}