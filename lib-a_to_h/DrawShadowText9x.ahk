; Function to draw shadowed text in Win9x
; Uses Laszlo's MCode() ; http://www.autohotkey.com/forum/viewtopic.php?p=135302#135302
; Code is an adaptation of some functions found in RP8.dll pertaining to Revolutions Pack by Tihiy
;================================================================
DrawShadowText9x(hDC, pTxt, sz, pRect, flags, cTxt=0, cShdw=0xC8C8C8, xOff=0, yOff=0, si=0xFF, e="A")
;================================================================
{
Global Ptr, PtrP, AW
Static Blur, Blend
if !Blur
	{	; Initialize machine code functions Blur() and Blend()
	f1=
	(LTrim Join
	558BEC518B4514884516886515C1E810538845148B451085C0568B750C8D48FB578D7EFB894DFC7E
	428B4D0883C1088945108B41FC0341048D51F80301030285FF7E19897D0C8B5A102B1A03C38BD8C1
	FB02891A83C204FF4D0C75EA8BC6C1E00203C8FF4D1075CA8B4DFC0FEFC00FEFC90FEFED0F6E651
	40F6F35D0849BBF0F6F3DD8849BBF85C90F8E990000008B45088BFEC1E702894508894D1085F68B4
	D08894D147E7589750C8B040F8D14360304918D14760304918BD6C1E202030491BAFF0000000301C
	1E8023BC276028BC20FB6C089018B55148B1A8BC30BC0742EC1E3080BC3C1E3080BC3C1E3080F6E
	C00F7FE10F60C50F60CD0FD5C80FDDCE0F71D1080FDDCF0F67CD0F7EC80BC3890283C104FF4D0C
	894D14758E017D08FF4D100F8575FFFFFF0F775F5E5BC9C21000
	)

	f2=
	(LTrim Join
	558BEC515356578B4508C1E0028945FC8B4508D1E889450856578B7D148B75108B550C0FEFF60FEFF
	F33C08B4D0833DB0F6F24DE0F6F2CDF0F7FE00F7FE90F60C633C08A44DE030FEFFF0F6EF80F73F71
	80F60CE0F6ED00F7FCB0F61D20FF9C10F62D20F71F3080FD5C20FFDC30F71D0080F67C60F68E633
	C08A44DE070FEFFF0F6EF80F73F7180F68EE0F6ED00F7FEB0F61D20FF9E50F62D20F71F3080FD5E2
	0FFDE30F71D4080F67E60F62C40F7F04DF434985C90F8575FFFFFF8B5DFC03F303FB4A0F8562FFFF
	FF5F5E0F775F5E5B8BE55DC3
	)
	MCode(Blur, f1), MCode(Blend, f2), VarSetCapacity(f1, 0), VarSetCapacity(f2, 0)
	}
if !pRect
	{
	if !hwnd := DllCall("WindowFromDC", Ptr, hDC, Ptr)
		return
	VarSetCapacity(rect, 16, 0), DllCall("GetClientRect", Ptr, hwnd, Ptr, &rect), pRect := &rect
	}
cx := NumGet(pRect+0, 8, "Int") - (ocx := NumGet(pRect+0, 0, "Int"))
cy := NumGet(pRect+0, 12, "Int") - (ocy := NumGet(pRect+0, 4, "Int"))
if (!hDC OR !pTxt OR !sz OR cx<4 OR cy<4)
	return
cxS := (cx+8+5)&~3, cyS := (cy+6+5)&~3
VarSetCapacity(bmi, 44, 0)	; BITMAPINFO struct
NumPut(40, bmi, 0, "UInt")	; biSize
NumPut(cxS, bmi, 4, "Int"), NumPut(cyS+1, bmi, 8, "Int")
NumPut(1, bmi, 12, "UShort"), NumPut(32, bmi, 14, "UShort")
hBMShadow := DllCall("CreateDIBSection"
	, Ptr		, hDC	; hdc
	, Ptr		, &bmi	; pbmi
	, "UInt"	, 0		; iUsage [DIB_RGB_COLORS]
	, PtrP	, bSh	; ppvBits
	, Ptr		, 0		; hSection
	, "UInt"	, 0		; dwOffset
	, Ptr)
hBMBack := DllCall("CreateDIBSection"
	, Ptr		, hDC	; hdc
	, Ptr		, &bmi	; pbmi
	, "UInt"	, 0		; iUsage [DIB_RGB_COLORS]
	, PtrP	, bBk	; ppvBits
	, Ptr		, 0		; hSection
	, "UInt"	, 0		; dwOffset
	, Ptr)
if (bSh && bBk)
	{
	bSize := cxS*cyS*4
	if bSize < 10000
		DllCall("ZeroMemory", Ptr, bSh, "UInt", bSize)
	hTDC := DllCall("CreateCompatibleDC", Ptr, hDC)
	hObm := DllCall("SelectObject", Ptr, hTDC, Ptr, hBMShadow)
	hOft := DllCall("SelectObject", Ptr, hTDC, Ptr, DllCall("GetCurrentObject", Ptr, hDC, "UInt", 6))
	VarSetCapacity(tRC, 16, 0)
	NumPut(7+xOff, tRC, 0, "Int"), NumPut(5+yOff, tRC, 4, "Int")
	NumPut(cx+7+xOff, tRC, 8, "Int"), NumPut(cy+5+yOff, tRC, 12, "Int")
	DllCall("SetTextColor", Ptr, hTDC, "UInt", (si<<16))	; blur color, originally 0xFF0000; add 0x100.
	DllCall("SetBkColor", Ptr, hTDC, "UInt", 0)
	DrawText%e%(hTDC, pTxt, sz, &tRC, flags, 1)
	DllCall(&Blur, Ptr, bSh, "Int", cxS, "Int", cyS, "UInt", cShdw, "CDecl UInt")
	DllCall("SelectObject", Ptr, hTDC, Ptr, hBMBack)
	DllCall("BitBlt"
		, Ptr		, hTDC
		, "Int"	, 0
		, "Int"	, 0
		, "Int"	, cxS
		, "Int"	, cyS
		, Ptr		, hDC
		, "Int"	, ocx-4
		, "Int"	, ocy-7
		, "UInt"	, 0xCC0020)	; SRCCOPY
	DllCall(&Blend, "Int", cxS, "Int", cyS, Ptr, bSh, Ptr, bBk, "CDecl UInt")
	DllCall("BitBlt"
		, Ptr		, hDC
		, "Int"	, ocx-4
		, "Int"	, ocy-7
		, "Int"	, cxS
		, "Int"	, cyS
		, Ptr		, hTDC
		, "Int"	, 0
		, "Int"	, 0
		, "UInt"	, 0xCC0020)	; SRCCOPY
	DllCall("SetTextColor", Ptr, hDC, "UInt", cTxt)
	DrawText%e%(hDC, pTxt, sz, pRect, flags)
	DllCall("SelectObject", Ptr, hTDC, Ptr, hObm)
	DllCall("SelectObject", Ptr, hTDC, Ptr, hOft)
	DllCall("DeleteDC", Ptr, hTDC)
	}
DllCall("DeleteObject", Ptr, hBMShadow), DllCall("DeleteObject", Ptr, hBMBack)
}
;================================================================
DrawTextW(hdc, pstr, sz, rc, flags, s=0)
;================================================================
{
Global Ptr
ta := DllCall("GetTextAlign", Ptr, hdc)
if (flags & 0x20002)	; Right OR RTL
	{
	x := NumGet(rc+0, 8, "Int")
	DllCall("SetTextAlign", Ptr, hdc, "UInt", (ta|2)&~1)	; TA_RIGHT
	;DllCall("SetTextAlign", Ptr, hdc, "UInt", 256)	; TA_RTLREADING, not working in English 9x
	}
else if (flags & 0x1)	; Center
	{
	x := (NumGet(rc+0, 8, "Int")-NumGet(rc+0, 0, "Int"))//2
	DllCall("SetTextAlign", Ptr, hdc, "UInt", (ta|6)&~1)	; TA_CENTER
	}
else x := NumGet(rc+0, 0, "Int")
y := NumGet(rc+0, 12, "Int")
if !(ta&24)	; don't center vertically if original alignment is Baseline or Bottom
	{
	VarSetCapacity(size, 8, 0)
	if !DllCall("GetTextExtentPoint32W", Ptr, hdc, Ptr, pstr, "UInt", sz, Ptr, &size)
		outputdebug, % "GetTextExtentPoint32W error " DllCall("GetLastError", "UInt")
	th := NumGet(size, 4, "UInt")
	y := (y-th)//2 + NumGet(rc+0, 4, "Int")
	}
if s
	{
	x--, y-=2	; correction for shadow placement
	}

VarSetCapacity(sc, 4, 0)	; SCRIPT_CONTROL struct
VarSetCapacity(ss, 2, 0)	; SCRIPT_STATE struct
;r0 := ScriptIsComplex(pstr)					; SSA_GLYPHS|SSA_FALLBACK
r1 := ScriptStringAnalyse(hdc, pstr, sz, 2*sz, -1, 0xA0, 0, &sc, &ss, 0, 0, 0, ssa)
r2 := ScriptStringOut(ssa, x, y, 4, rc, 1, 0, 0)	; ETO_CLIPPED
r3 := ScriptStringFree(ssa)
DllCall("SetTextAlign", Ptr, hdc, "UInt", ta)		; Restore text alignment
return r1|r2|r3		; if any of them not zero count result as an error
}
;================================================================
DrawTextA(hdc, pstr, sz, rc, flags)
;================================================================
{
Global Ptr
DllCall("DrawTextExA"			; DrawTextExA/W
	, Ptr		, hdc			; hdc
	, Ptr		, pstr			; lpchText
	, "UInt"	, sz				; cchText (may try -1, max. 8192 in Win9x)
	, Ptr		, rc				; lprc
	, "UInt"	, flags			; dwDTFormat
	, Ptr		, 0)				; lpDTParams
}
;================================================================
MCode(ByRef code, hx)
;================================================================
{
len := StrLen(hx)/2
VarSetCapacity(code, len)
Loop, %len%
	{
	n := "0x" SubStr(hx, 2*A_Index-1, 2)
	NumPut(n+0, code, A_Index-1, "UChar")
	}
}
;================================================================
#include extra\uniscribe.ahk
