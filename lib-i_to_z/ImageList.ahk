; © Drugwash, February-August 2011
; Set of ImageList functions that allow custom icon sizes
; Many thanks to SKAN for fixing bitmap stretch issue under XP

; default: 16x16 ILC_COLOR24 ILC_MASK
; M=ILC_MASK P=ILC_PALETTE D=ILC_COLORDDB accepted colors: 4 8 16 24 32

ILC_Create(i, g="1", s="16x16", f="M24")
{
if i<1
	return 0
StringSplit, s, s, x
s2 := s2 ? s2 : s1
c=
Loop, Parse, f
	if A_LoopField is digit
		c .= A_LoopField
StringReplace, f, f, c,,
m := c|(InStr(f, "M") ? 0x1 : 0)|(InStr(f, "P") ? 0x800 : 0)|(InStr(f, "D") ? 0xFE : 0)
return DllCall("ImageList_Create", "Int", s1, "Int", s2, "UInt", m, "Int", i, "Int", g)	; ILC_COLOR24 ILC_MASK
}

ILC_List(cx, file, idx="100", cd="1")	; cd=color depth 32bit, set 0 for 24bit or lower
{
mask := cd ? 0xFF000000 : 0xFFFFFFFF
Loop, %file%
	if A_LoopFileExt in exe,dll
		{
		if !hInst := DllCall("GetModuleHandle", "Str", file)
			hL := hInst := DllCall("LoadLibrary", "Str", file)
		if idx is not integer
			i := &idx
		else i := idx
		hIL := DllCall("ImageList_LoadImage", "UInt", hInst, "UInt", i, "Int", cx, "Int", 1, "UInt", mask, "UInt", 0, "UInt", 0x2000)
		}
	else if A_LoopFileExt in bmp
		hIL := DllCall("ImageList_LoadImage", "UInt", 0, "Str", file, "Int", cx, "Int", 1, "UInt", mask, "UInt", 0, "UInt", 0x2010)
if (hInst && hL)
	DllCall("FreeLibrary", "UInt", hInst)
return hIL
}

ILC_FitBmp(hPic, hIL, idx="1")
{
WinGetPos,,, W1, H1, ahk_id %hPic%
if (W1 && H1)
	{
	W := W1
	H := H1
	}
hBmp := ILC_ImageResize(hIL, idx, W "x" H)
hP := DllCall("SendMessage", "UInt", hPic, "UInt", 0x172, "UInt", 0, "UInt", hBmp)	; STM_SETIMAGE, IMAGE_BITMAP
return hBmp	; requires cleanup on exit!
}

ILC_ImageResize(hIL, idx, sz="")
{
DllCall("ImageList_GetIconSize", "UInt", hIL, "UIntP", bw, "UIntP", bh)
if !sz
	{
	s1 := bw
	s2 := bh
	}
else StringSplit, s, sz, x
hDC := DllCall("CreateCompatibleDC", "UInt", 0)
hBmp := DllCall("CreateBitmap" , "Int", bw, "Int", bh, "UInt", 1, "UInt", 0x18, "UInt", 0)	; 1color plane, 24bit
hBmp2 := DllCall("CopyImage", "UInt", hBmp, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2004, "UInt")	; 0=IMAGE_BITMAP
DllCall("DeleteObject", "UInt", hBmp)
hBo := DllCall("SelectObject", "UInt", hDC, "UInt", hBmp2)
DllCall("ImageList_Draw", "UInt", hIL, "Int", idx-1, "UInt", hDC, "Int", 0, "Int", 0, "UInt", 0x0) ; ILD_NORMAL
DllCall("SelectObject", "UInt", hDC, "UInt", hBo)
DllCall("DeleteDC", "UInt", hDC)
hBmp := ResizeBmp(hBmp2, s1, s2)
DllCall("DeleteObject", "UInt", hBmp2)
return hBmp
}

ResizeBmp(hBmp, w, h="")
{
h := h ? h : w
if hBmp	; LR_CRATEDIBSECTION LR_COPYRETURNORG
	return DllCall("CopyImage", "UInt", hBmp, "UInt", 0, "Int", w, "Int", h, "UInt", 0x2004, "UInt")	; 0=IMAGE_BITMAP
; requires cleanup on exit!
}

; sz=individual image width, file=file path or ImageList handle
; res=resource index in file, cd=color depth (1-32bit, 0-lower)
GetBmp(idx, sz, ByRef file, res="", cd="1")
{
if file is integer
	hIL := file
else IfExist, %file%
	{
	if !hIL := ILC_List(sz, file, res, cd)
		return 0
	file := hIL
	}
else return 0
return ILC_ImageResize(hIL, idx)
}

GetPixelColor(hBmp, px, py)
{
ofi := A_FormatInteger
SetFormat, Integer, H
hDC := DllCall("CreateCompatibleDC", "UInt", 0)
hBo := DllCall("SelectObject", "UInt", hDC, "UInt", hBmp)
sz := DllCall("GetPixel", "UInt", hDC, "Int", px, "Int", py, "UInt")
DllCall("SelectObject", "UInt", hDC, "UInt", hBo)
DllCall("DeleteDC", "UInt", hDC)
SetFormat, Integer, %ofi%
return sz
}

SetBmp(hDest, hBmp)
{
return DllCall("SendMessage", "UInt", hDest, "UInt", 0x172, "UInt", 0, "UInt", hBmp)	; STM_SETIMAGE, IMAGE_BITMAP
}

ILC_Count(hwnd)
{
if hwnd
	return DllCall("ImageList_GetImageCount", "UInt", hwnd)
}

ILC_Destroy(hwnd)
{
return DllCall("ImageList_Destroy", "UInt", hwnd)
}

; LR_CREATEDIBSECTION=0x2000 LR_LOADFROMFILE=0x10 LR_LOADTRANSPARENT=0x20 LR_SHARED=0x8000
; IMAGE_BITMAP=0x0 IMAGE_ICON=0x1 IMAGE_CURSOR=0x2
ILC_Add(hIL, icon, idx="1")
{
Static it="BIC"
StringLeft, t, icon, 1
StringTrimLeft, icon, icon, 1
t := InStr(it, t)-1
if t<0 OR hIL=0
	return 0
hInst=0
if icon is integer
	hIcon := icon
else
	{
	Loop, %icon%
		if A_LoopFileExt in exe,dll
			{
			if !hInst := DllCall("GetModuleHandle", "Str", icon)
				hL := hInst := DllCall("LoadLibrary", "Str", icon)
			flags=0x2000
		; need to use MAKEINTRESOURCE here
			if idx is not integer
				i := &idx
			else i := idx
			hIcon := DllCall("LoadImage", "UInt", hInst, "UInt", i, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
		else if A_LoopFileExt in bmp,ico,cur,ani
			{
			flags=0x2010
			hIcon := DllCall("LoadImage", "UInt", hInst, "Str", icon, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
		else
			{
			i := idx
			flags=0x8000
			hIcon := DllCall("LoadImage", "UInt", hInst, "UInt", i, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
	}
if (hInst && hL)
	DllCall("FreeLibrary", "UInt", hInst)
if t=0
	{
	DllCall("ImageList_Add", "UInt", hIL, "UInt", hIcon, "UInt", 0)
	DllCall("DeleteObject", "UInt", hIcon)
	}
if t=1
	{
	DllCall("ImageList_ReplaceIcon", "UInt", hIL, "UInt", -1, "UInt", hIcon)
	DllCall("DestroyIcon", "UInt", hIcon)
	}
if t=2
	{
	DllCall("ImageList_ReplaceIcon", "UInt", hIL, "UInt", -1, "UInt", hIcon)
	DllCall("DestroyCursor", "UInt", hIcon)
	}
}
