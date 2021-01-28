
/*
#SingleInstance Force
^\::ExitApp

;capturing current mouse cursor and save to "testCursor.bmp"
F11::
	CaptureCursor("testCursor.bmp")
return

;compare to testCursor.bmp and current mouse cursor
F12::
	loop
	{
		ToolTip, % IsMatchCursor("testCursor.bmp")? "match" : "unmatch"
		Sleep, 100
	}
return
*/
;---------------------------------------------------------------
;	CaptureCursor and IsMatchCursor
;---------------------------------------------------------------
;captureTo: "clipboard"=save to clipboard , "bitmap_handle"=return current cursor bitmap handle.
;return: 0=fail , 1=success
CaptureCursor(captureTo="clipboard", cursorSize=32){
	VarSetCapacity(CURSORINFO, A_PtrSize=8? 24:20, 0)
	VarSetCapacity(ICONINFO, A_PtrSize=8? 32:20, 0)
	NumPut(A_PtrSize=8? 24:20, CURSORINFO, 0,"UInt")
	DllCall("GetCursorInfo", "UPTR", &CURSORINFO)
	hCursor := NumGet(CURSORINFO, 8, "UPtr")
	flags := NumGet(CURSORINFO, 4, "UInt")
	if !hCursor or !flags
		return 0
	hCursor := DllCall("CopyIcon", "UPTR", hCursor)
	DllCall("GetIconInfo", "UPTR", hCursor, "UPTR", &ICONINFO)

	mDC := DllCall("CreateCompatibleDC", "UPTR", 0, "UPTR")
	hBM := CreateDIBSection(mDC, cursorSize, cursorSize)
	oBM := DllCall("SelectObject", "UPTR", mDC, "UPTR", hBM, "UPTR")

	DllCall("DrawIcon", "UPTR", mDC, "int",0, "int",0, "UPTR", hCursor)

	DllCall("SelectObject", "UPTR", mDC, "UPTR", oBM)
	DllCall("DeleteDC", "UPTR", mDC)
	DllCall("DestroyIcon", "UPTR", hCursor)
	If hbmMask := NumGet(ICONINFO, A_PtrSize=8? 16:12, "UPtr")
		DllCall("DeleteObject", "UPTR", hbmMask)
	If hbmColor := NumGet(ICONINFO, A_PtrSize=8? 24:16, "UPtr")
		DllCall("DeleteObject", "UPTR", hbmColor)

	if captureTo=bitmap_handle
		return hBM
	If captureTo=clipboard
		SetClipboardData(hBM)
	else
		SaveHBITMAPToFile(hBM, captureTo)
	DllCall("DeleteObject", "UPTR", hBM)
	return 1
}

;compare cursor bmp file to current mouse cursor.
; 1 : cursor image match
; 0 : cursor image unmatch
; ""; hide mouse cursor or can't get cursor handle.
IsMatchCursor(bmpCursorFile){
	if !hCursorBmp := CaptureCursor("bitmap_handle", bmpSize:=32)
		return ""
	hSourceBmp := LoadBMP(bmpCursorFile)
	return !CompareBitmap(hSourceBmp, hCursorBmp, bmpSize)
}


;---------------------------------------------------------------
;	Sub function
;---------------------------------------------------------------
;this function takes two bitmaps and compares the first 32x32 pixel square on them
;hBM1 and hBM2: bitmap handle
;return: 0=match, 1=unmatch
CompareBitmap(hBM1, hBM2, size=32){
	x=0
	mDC1 := DllCall("CreateCompatibleDC", "Uint", 0)			;create DC compatible with screen
	mDC2 := DllCall("CreateCompatibleDC", "Uint", 0)
	oBM1 := DllCall("SelectObject", "UPTR", mDC1, "UPTR", hBM1)	;put the object in the device context
	oBM2 := DllCall("SelectObject", "UPTR", mDC2, "UPTR", hBM2)
	while x < size
	{
		y=0
		while y < size
		{
			color1 := DllCall("GetPixel", "UPTR", mDC1, "int", x, "int",y)	;get the RGB of pixel (x, y)
			color2 := DllCall("GetPixel", "UPTR", mDC2, "int", x, "int",y)
			if color1 <> %color2%	;if colors are different, didn't match
				return 1
			y+=1
		}
		x+=1
	}
	DllCall("SelectObject", "UPTR", mDC1, "UPTR", oBM1)	;put the original contents back in DC
	DllCall("SelectObject", "UPTR", mDC2, "UPTR", oBM2)
	DllCall("DeleteDC", "UPTR", mDC1)					;delete DC (prevent memory leak)
	DllCall("DeleteDC", "UPTR", mDC2)
	DllCall("DeleteObject", "UPTR", hBM1)				;delete the images in memory
	DllCall("DeleteObject", "UPTR", hBM2)
	return 0	;0 return if match
}

CreateDIBSection(hDC, nW, nH, bpp = 32, ByRef pBits = ""){
	VarSetCapacity(BITMAPINFO, 44, 0)
	NumPut(44, BITMAPINFO, 0,"UInt")
	NumPut(nW, BITMAPINFO, 4,"Int")
	NumPut(nH, BITMAPINFO, 8,"Int")
	NumPut(1, BITMAPINFO, 12,"UShort")
	NumPut(bpp, BITMAPINFO, 14,"UShort")
	Return	DllCall("gdi32\CreateDIBSection", "UPTR", hDC, "UPTR", &BITMAPINFO, "Uint", 0, "UPTR", pBits, "Uint", 0, "Uint", 0)
}

SetClipboardData(hBitmap){
	VarSetCapacity(DIBSECTION, A_PtrSize=8? 104:84, 0)
	NumPut(40, DIBSECTION, A_PtrSize=8? 32:24,"UInt")	;dsBmih.biSize
	DllCall("GetObject", "UPTR", hBitmap, "int", A_PtrSize=8? 104:84, "UPTR", &DIBSECTION)
	biSizeImage := NumGet(DIBSECTION, A_PtrSize=8? 52:44, "UInt")
	hDIB :=	DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+biSizeImage)
	pDIB :=	DllCall("GlobalLock", "UPTR", hDIB)
	DllCall("RtlMoveMemory", "UPTR", pDIB, "UPTR", &DIBSECTION + (A_PtrSize=8? 32:24), "Uint", 40)
	DllCall("RtlMoveMemory", "UPTR", pDIB+40, "Uint", NumGet(DIBSECTION, A_PtrSize=8? 24:20, "UPtr"), "Uint", biSizeImage)
	DllCall("GlobalUnlock", "UPTR", hDIB)
	DllCall("DeleteObject", "UPTR", hBitmap)
	DllCall("OpenClipboard", "Uint", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "Uint", 8, "UPTR", hDIB)
	DllCall("CloseClipboard")
}

LoadBMP(bmpFile){
	bmpFile := GetValidFilePath(bmpFile)
	hBmp := DllCall("LoadImage","Uint", 0, "str", bmpFile, "Uint", 0, "int", 32, "int",32, "Uint", 0x00000010) ;load the image from file
	return hBmp
}

SaveHBITMAPToFile(hBitmap, sFile){
	sFile := GetValidFilePath(sFile)
	VarSetCapacity(DIBSECTION, A_PtrSize=8? 104:84, 0)
	NumPut(40, DIBSECTION, A_PtrSize=8? 32:24,"UInt")	;dsBmih.biSize
	DllCall("GetObject", "UPTR", hBitmap, "int", A_PtrSize=8? 104:84, "UPTR", &DIBSECTION)
	hFile:=	DllCall("CreateFile", "UPTR", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
	DllCall("WriteFile", "UPTR", hFile, "int64P", 0x4D42|14+40+(biSizeImage:=NumGet(DIBSECTION, A_PtrSize=8? 52:44, "UInt"))<<16, "Uint", 6, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "UPTR", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "UPTR", hFile, "UPTR", &DIBSECTION + (A_PtrSize=8? 32:24), "Uint", 40, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "UPTR", hFile, "Uint", NumGet(DIBSECTION, A_PtrSize=8? 24:20, "UPtr"), "Uint", biSizeImage, "UintP", 0, "Uint", 0)
	DllCall("CloseHandle", "UPTR", hFile)
}

GetValidFilePath(filename){
	SplitPath, filename, , sDir, sExt, sName
	IfNotInString, sDir, :
		sDir = %A_ScriptDir%\%sDir%
	filename = %sDir%\%sName%.%sExt%
	StringReplace, filename, filename, \\, \, All
	return filename
}

;---------------------------------------------------------------
;	Struct List
;---------------------------------------------------------------
/*

typedef struct {
  DWORD   cbSize;
  DWORD   flags;
  HCURSOR hCursor;
  POINT   ptScreenPos;
} CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

typedef struct _ICONINFO {
  BOOL    fIcon;
  DWORD   xHotspot;
  DWORD   yHotspot;
  HBITMAP hbmMask;
  HBITMAP hbmColor;
} ICONINFO, *PICONINFO;

typedef struct tagDIBSECTION {
  BITMAP           dsBm;
  BITMAPINFOHEADER dsBmih;
  DWORD            dsBitfields[3];
  HANDLE           dshSection;
  DWORD            dsOffset;
} DIBSECTION, *PDIBSECTION;

typedef struct tagBITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER;

typedef struct tagBITMAP {
  LONG   bmType;
  LONG   bmWidth;
  LONG   bmHeight;
  LONG   bmWidthBytes;
  WORD   bmPlanes;
  WORD   bmBitsPixel;
  LPVOID bmBits;
} BITMAP, *PBITMAP;

typedef struct tagBITMAPINFO {
  BITMAPINFOHEADER bmiHeader;
  RGBQUAD          bmiColors[1];
} BITMAPINFO, *PBITMAPINFO;

typedef struct tagRGBQUAD {
  BYTE rgbBlue;
  BYTE rgbGreen;
  BYTE rgbRed;
  BYTE rgbReserved;
} RGBQUAD;

*/

