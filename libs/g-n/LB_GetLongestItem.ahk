GetLongestItem(hLB) { ;We need the listbox to get the font used

	Global sLabels0, sFuncs0, iIncludeMode

	;Declare variables (for clarity's sake)
	dwExtent := 0
	dwMaxExtent := 0
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
	;(eg. to get tmAveCharWidth's value)
	DllCall("GetTextMetrics", "Ptr", hDCListBox, "Ptr", &lptm)
	tmAveCharWidth := NumGet(lptm, 20, "UInt")

	;Now, we need to loop through each label/hotkey/function
	If (iIncludeMode & 0x10000000) { ;Check if we're taking from the _List elements. Split for speed

		Loop %sLabels0% {

			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sLabels%A_Index%_List
										  , "Int", StrLen(sLabels%A_Index%_List), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth

			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}

		Loop %sFuncs0% {

			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sFuncs%A_Index%_List
										  , "Int", StrLen(sFuncs%A_Index%_List), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth

			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
	} Else {

		Loop %sLabels0% {

			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sLabels%A_Index%
										  , "Int", StrLen(sLabels%A_Index%), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth

			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}

		Loop %sFuncs0% {

			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sFuncs%A_Index%
										  , "Int", StrLen(sFuncs%A_Index%), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth

			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
	}

	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontOld)
	DllCall("ReleaseDC", "Ptr", hLB, "Ptr", hDCListBox)

	;Return the longest one found
	Return dwMaxExtent
}
