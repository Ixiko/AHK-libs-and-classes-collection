; Title:   	https://gist.github.com/hoppfrosch/11242617
; Link:
; Author:
; Date:
; for:     	AHK_L ANSI

/*
	; Set Icon for row "subItem" within Listview
	;
	; Author: Tseug (http://www.autohotkey.com/board/topic/72072-listview-icons-in-more-than-first-column-example/)
	;
	; example for adding icons to listview columns > the first
	; after Drugwash: http://www.autohotkey.com/forum/post-234198.html#234198

	#Include LV_SetSI.ahk

	Gui, add, ListView,	w600 h400		+LV0x2 HwndHLV, Name|Size|Ext
	ImageListID := IL_Create(10)
	LV_SetImageList(ImageListID)
	Loop 10
		IL_Add(ImageListID, "shell32.dll", A_Index)

	Loop, %A_WinDir%\*.*				; fill Listview
	{	if a_Index > 100
			break
		i := Mod(a_index,10)+1			; since I only added 10 icons
		LV_Add("icon" i, A_LoopFileName, A_LoopFileSize, A_LoopFileExt)
		LV_SetSI(hLV, A_Index, 3, i)	; now add icons (i) to the rows of the third column
				; can also call function later for individual cells
	}
	LV_ModifyCol()

	Gui, Show,	, Icons in more than 1 Listview column
	return

	GuiClose:
	ExitApp

*/

; Set Icon for row "subItem" within Listview
;
; Author: Tseug (http://www.autohotkey.com/board/topic/72072-listview-icons-in-more-than-first-column-example/)
;
LV_SetSI(hList, iItem, iSubItem, iImage){
	VarSetCapacity(LVITEM, 60, 0)
	LVM_SETITEM := 0x1006 , mask := 2   ; LVIF_IMAGE := 0x2
	iItem-- , iSubItem-- , iImage--		; Note first column (iSubItem) is #ZERO, hence adjustment
	NumPut(mask, LVITEM, 0, "UInt")
	NumPut(iItem, LVITEM, 4, "Int")
	NumPut(iSubItem, LVITEM, 8, "Int")
	NumPut(iImage, LVITEM, 28, "Int")
	result := DllCall("SendMessageA", UInt, hList, UInt, LVM_SETITEM, UInt, 0, UInt, &LVITEM)
	return result
}