; this works under both ANSI/Unicode build of AHK
CopyFilesToClipboard(arrFilepath, bCopy) {
	; set drop effect to determine whether the files are copied or moved.
	uDropEffect := DllCall("RegisterClipboardFormat", "str", "Preferred DropEffect", "uint")	
	hGblEffect := DllCall("GlobalAlloc", "uint", 0x42, "ptr", 4, "ptr")
	pGblEffect := DllCall("GlobalLock", "ptr", hGblEffect, "ptr")
	; 0x1=DROPEFFECT_COPY, 0x2=DROPEFFECT_MOVE
	NumPut(bCopy ? 1 : 2, pGblEffect+0)

	; Unlock the moveable memory.
	DllCall("GlobalUnlock", "ptr", hGblEffect)


	charsize := A_IsUnicode ? 2 : 1
	AorW := A_IsUnicode ? "W" : "A"

	; calculate the whole size of arrFilepath
	sizeFilepath := charsize*2 ; double null-terminator
	For k, v in arrFilepath {
		sizeFilepath += (StrLen(v)+1)*charsize
	}

	; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
	hPath := DllCall("GlobalAlloc", "uint", 0x42, "ptr", sizeFilepath + 20, "ptr")
	pPath := DllCall("GlobalLock", "ptr", hPath, "ptr")

	NumPut(20, pPath+0) ;pFiles
	NumPut(A_IsUnicode, pPath+16) ;fWide

	pPath += 20

	; Copy the list of files into moveable memory.
	For k, v in arrFilepath {
		DllCall("lstrcpy" . AorW, "ptr", pPath+0, "str", v)
		pPath += (StrLen(v)+1)*charsize
	}

	; Unlock the moveable memory.
	DllCall("GlobalUnlock", "ptr", hPath)
	
	DllCall("OpenClipboard", "ptr", 0)
	; Empty the clipboard, otherwise SetClipboardData may fail.
	DllCall("EmptyClipboard")
	; Place the data on the clipboard. CF_HDROP=0xF
	DllCall("SetClipboardData","uint",0xF,"ptr",hPath)
	DllCall("SetClipboardData","uint",uDropEffect,"ptr",hGblEffect)
	DllCall("CloseClipboard")
}
