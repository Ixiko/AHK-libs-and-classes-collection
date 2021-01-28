; Sets cue banner for (almost) any control. Cue text may have blurred shadow on Win98+.
; Requires comctl32 v4.72+
; v2.6.1
; © Drugwash, 2017.07.26
; hwnd - handle to the control that will display the cue banner
; pTxt - pointer to the text string that will be set as cue banner
; opt - options string. Possible values are 'p' (persistent caret), 's' (drop shadow), 'r' (right-aligned text),
; 	'c' (centered text), 'a' (left-to-right text), 'm' (multiline text) and 'u' (UTF-8 text)
; 	DON'T MIX r AND c OPTIONS IN SAME CONTROL !
; clr - color of the cue banner text (0x BB GG RR)
; sh - color of the cue banner text shadow (0x BB GG RR), x and y offsets, intensity, all separated by |.
; Shadow offsets may be negative. Don't use large values, a range of [-5 to +5] should be enough.
; Shadow intensity is only usable in Win9x, since the function uses other algorithms than DrawShadowText.
; example: CueBanner(hEdit1, &cueText1, "psc", 0xFFFFFF, "0x404040|3|2|128")
; on exit: CueBanner(0) - this will unload comctl32 and/or usp10 if loaded by this script.
;================================================================
CueBanner(hwnd, pTxt=0, opt="", clr="", sh="")				; Generic subclass function
;================================================================
{
Static
Global Ptr, AW, w9x
if !hwnd
	{
	if hUSP
		DllCall("FreeLibrary", Ptr, hUSP)	; call CueBanner(0) to unload usp10 if loaded
	if hCC
		DllCall("FreeLibrary", Ptr, hCC)	; call CueBanner(0) to unload comctl32 if loaded
	return
	}
if !SWS
	{
	SWS := CueBanner_GPA("comctl32.dll", "SetWindowSubclass", 410, hCC)
	RWS := CueBanner_GPA("comctl32.dll", "RemoveWindowSubclass", 412, hCC)
	cb := RegisterCallback("CueBanner_CB")
	SWL := CueBanner_GPA("user32.dll", "SetWindowLongPtr" AW, "", hUsr)
		 ? "SetWindowLongPtr" AW : "SetWindowLong" AW
	if !(SWS && RWS && cb && SWL)
		{
		OutputDebug, %A_ThisFunc%() error: SWS=%SWS% RWS=%RWS% cb=%cb% SWL=%SWL%
		return
		}
	if w9x
		hUSP := DllCall("LoadLibrary", "Str", "usp10.dll")
	defShC := 0xC8C8C8	; default shadow color
	}
CueBanner_Fix(hwnd)		; This can modify hwnd so don't move it below !!!
if pTxt
	{
	clr := clr="" ? DllCall("GetSysColor", "Int", 17) : (clr & 0xFFFFFF) 	; COLOR_GRAYTEXT
	sh1 := sh2 := sh3 := sh4 := ""
	if (sh != "")
		{
		StringSplit, sh, sh, |, %A_Space%%A_Tab%
		sh1 := (sh1!="" ? sh1 : (sh2!="" OR sh3!="" OR sh4!="") ? defShC : sh) & 0xFFFFFF
		sh2 := sh2!="" ? sh2 : 0
		sh3 := sh3!="" ? sh3 : 0
		sh4 := sh4!="" ? sh4&0xFF : 0xFF
		}
	else
		{
		sh1 := defShC, sh2 := 0, sh3 := 0, sh4 := 0xFF
		}
	; 		DT_WORDBREAK <=> DT_SINGLELINE|DT_VCENTER
	data := (InStr(opt, "m") ? 0x10 : 0x24)
		+ (InStr(opt, "r") ? 0x2 : 0)		; DT_RIGHT
		+ (InStr(opt, "c") ? 0x1 : 0)		; DT_CENTER
		+ (InStr(opt, "a") ? 0x20000 : 0)	; DT_RTLREADING
	VarSetCapacity(buf%hwnd%, 16, 0)
	if InStr(opt, "p")
		NumPut(1, buf%hwnd%, 0, "UChar")		; persistent caret flag
	if InStr(opt, "s")
		NumPut(sh4, buf%hwnd%, 1, "UChar")		; drop shadow flag
	if InStr(opt, "u")
		NumPut(65001, buf%hwnd%, 12, "UInt")	; UTF-8 flag
	NumPut(sh2	, buf%hwnd%, 2, "Char")		; shadow X offset [px]
	NumPut(sh3	, buf%hwnd%, 3, "Char")		; shadow Y offset [px]
	NumPut(clr	, buf%hwnd%, 4, "UInt")		; text color [BGR]
	NumPut(sh1	, buf%hwnd%, 8, "UInt")		; shadow color [BGR]
	DllCall(SWL, Ptr, hwnd, "UInt", -21, Ptr, pTxt)	; GWL_USERDATA
	if !r := DllCall(SWS				; SetWindowSubclass
		, Ptr		, hwnd			; hwnd
		, Ptr		, cb				; pfnSubclass
		, Ptr		, &buf%hwnd%	; uIdSubclass
		, "UInt"	, data)			; dwRefData
		OutputDebug, % "SetWindowSubclass() failed with error " DllCall("GetLastError", "UInt")
	DllCall("RedrawWindow", Ptr, hwnd, Ptr, 0, Ptr, 0, "UInt", 0x101)	; RDW_INVALIDATE,UPDATENOW
	return r
	}
if VarSetCapacity(buf%hwnd%)
	if !r := DllCall(RWS, Ptr, hwnd, Ptr, cb, Ptr, &buf%hwnd%)	; RemoveWindowSubclass
		OutputDebug, % "RemoveWindowSubclass() failed with error " DllCall("GetLastError", "UInt")
	else VarSetCapacity(buf%hwnd%, 0)
DllCall("RedrawWindow", Ptr, hwnd, Ptr, 0, Ptr, 0, "UInt", 0x101)	; RDW_INVALIDATE,UPDATENOW
return r
}
;================================================================
CueBanner_CB(hwnd, msg, wP, lP, ID, data)		; Cue Banner subclass procedure
;================================================================
{
Global Ptr, AW, w9x
Static len, DSP, ver, hOff, tFmt, Draw9x
Critical
if !(DSP && len)
	{
	DSP := CueBanner_GPA("comctl32.dll", "DefSubclassProc", 413, hCC)
	len := "msvcrt\" (A_IsUnicode ? "wcslen" : "strlen")
	VarSetCapacity(DVI, 20, 0), NumPut(20, DVI, 0, "UInt"), DllCall("comctl32\DllGetVersion", Ptr, &DVI)
	ver := NumGet(DVI, 4, "UInt") "." NumGet(DVI, 8, "UInt")	; file version
	VarSetCapacity(DVI, 0)
	hOff := 6		; set a horizontal offset of 6px to accomodate the caret in persistent mode
	; DT_WORD_ELLIPSIS|DT_END_ELLIPSIS|DT_EDITCONTROL|DT_NOPREFIX|
	; DT_EXPANDTABS (this one is not correctly calculated)
	tFmt := 0x4A840
	Draw9x := w9x ? "DrawShadowText9x" : ""
	if !(DSP && len)
		{
		OutputDebug, %A_ThisFunc%() error: DSP=%DSP% len=%len%, comctl32 v%ver%
		return
		}
	}
if msg=130	; WM_NCDESTROY=0x82 WM_DESTROY=0x2
	{	; https://blogs.msdn.microsoft.com/oldnewthing/20031111-00/?p=41883
	CueBanner(hwnd)	; remove window subclass
	return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
	}
if msg=20	; WM_ERASEBKGND=0x14
	{
	return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
	}
; WM_PRINTCLIENT|PAINT|KILLFOCUS|SETFOCUS|KEYUP|KEYDOWN|WM_WINDOWPOSCHANGING
if msg in 792,15,8,7,257,256,657,656,70,641,642
	{
	isTxt := DllCall("GetWindowTextLength" AW, Ptr, hwnd), isFocus := (DllCall("GetFocus", Ptr)=hwnd)
	p := NumGet(ID+0, 0, "UChar")	; 'persistent' flag

	if msg=8		; kill focus
		{
		DllCall("InvalidateRect", Ptr, hwnd, Ptr, 0, "UInt", 1)
		if isTxt
			return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
		}
	else if msg=7	; set focus
		{
		DllCall("InvalidateRect", Ptr, hwnd, Ptr, 0, "UInt", 1)
		if (isTxt OR !p)
			return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
		}
	else if msg in 257,256,657,656	; keyup keydown ime_keyup ime_keydown
		{
		if isTxt
			return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
		DllCall("InvalidateRect", Ptr, hwnd, Ptr, 0, "UInt", 1)
		return 0
		}
	else if (isTxt OR (isFocus && !p))
		return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)	; DefSubclassProc
	else DllCall("InvalidateRect", Ptr, hwnd, Ptr, 0, "UInt", 1)

	; DCX_INTERSECTUPDATE|DCX_CLIPSIBLINGS|DCX_CLIPCHILDREN|DCX_CACHE
	hDC := msg=0x318 ? wP : DllCall("GetDCEx", Ptr, hwnd, Ptr, 0, "UInt", 0x21A, Ptr)
	; added DCX_VALIDATE|DCX_NORESETATTRS
;	hDC := msg=0x318 ? wP : DllCall("GetDCEx", Ptr, hwnd, Ptr, 0, "UInt", 0x20021E, Ptr)
	res := DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)
; At this point we calculate any clipping required to avoid drawing over control elements
	VarSetCapacity(rect, 16, 0), CueBanner_SetRect(hwnd, rect)
	t := DllCall("GetWindowLong", Ptr, hwnd, "Int", -21), s := NumGet(ID+0, 1, "UChar")
	clr := NumGet(ID+0, 4, "UInt")

	ofont := DllCall("SelectObject"
			, Ptr, hDC
			, Ptr, DllCall("SendMessage" AW
					, Ptr		, hwnd
					, "UInt"	, 0x31		; WM_GETFONT
					, "UInt"	, 0
					, "UInt"	, 0
					, Ptr)
			, Ptr)
	DllCall("SetBkMode", Ptr, hDC, "UInt", 1)	; TRANSPARENT
	cp := NumGet(ID+0, 12, "UInt")			; codepage (currently only UTF-8)

	if (ver < 6.0 OR !s)
		{	; DON'T mention unicows even on Win9x or it leaks memory badly !!!
		DrawText := cp ? "DrawTextExW" : "DrawTextEx" AW
		if cp
			{
			sz := CueBanner_A2U(t, Out, cp), t := &Out
			}
		else sz := DllCall(len, Ptr, t, "CDecl")
		DllCall("SetTextColor", Ptr, hDC, "UInt", clr)
		if (s && w9x)
			{	; Apparently DrawTextShadowEx() uses a very faint shade of the chosen color
			shClr := NumGet(ID+0, 8, "UInt")	; so we just pass it as it is and hope for the best.
			xOff := NumGet(ID+0, 2, "Char"), yOff := NumGet(ID+0, 3, "Char")
			%Draw9x%(hDC, t, sz, &rect, tFmt|data, clr, shClr, xOff, yOff, s, cp ? "W" : "A")
			}
		else if (cp && w9x)
			DrawTextW(hDC, t, sz, &rect, tFmt|data)
		else if !DllCall(DrawText			; DrawTextExA/W
			, Ptr		, hDC			; hdc
			, Ptr		, t				; lpchText
			, "UInt"	, sz				; cchText (may try -1, max. 8192 in Win9x)
			, Ptr		, &rect			; lprc
			, "UInt"	, tFmt|data		; dwDTFormat
			, Ptr, 0)					; lpDTParams
		OutputDebug, % fv "() error " DllCall("GetLastError", "UInt") " in " A_ThisFunc "()"
		}							
	else
		{
		shClr := NumGet(ID+0, 8, "UInt")
		xOff := NumGet(ID+0, 2, "Char"), yOff := NumGet(ID+0, 3, "Char")

		if (!A_IsUnicode OR cp)
			{
			sz := CueBanner_A2U(t, Out, cp), t := &Out
			}
		else sz := DllCall(len, Ptr, t, "CDecl")
		DllCall("DrawShadowText"
			, Ptr		, hDC			; hdc
			, Ptr		, t				; pszText
			, "UInt"	, sz				; cch
			, Ptr		, &rect			; pRect
			, "UInt"	, tFmt|data		; dwFlags [see uFormat above]
			, "UInt"	, clr				; crText
			, "UInt"	, shClr			; crShadow
			, "Int"	, xOff ? xOff : 2	; ixOffset
			, "Int"	, yOff ? yOff : 1)	; iyOffset
		}
	DllCall("SelectObject", Ptr, hDC, Ptr, ofont)
	if hFont
		DllCall("DeleteObject", Ptr, hFont)
	if (msg != 0x318)
		DllCall("ReleaseDC", Ptr, hwnd, Ptr, hDC)
	return res
	}
/*
else if msg between 0x280 and 0x292		; only for testing purposes
	{
	setformat, integer, h
	msg+=0
	setformat, integer, d
	outputdebug, msg %msg%
	}
*/
return DllCall(DSP, Ptr, hwnd, "UInt", msg, Ptr, wP, Ptr, lP, Ptr)
}
;================================================================
;									HELPER FUNCTIONS
;================================================================
CueBanner_Fix(ByRef hwnd)
;================================================================
{
Global Ptr, PtrSz, AW
WinGetClass, cls, ahk_id %hwnd%
ControlGet, st, Style,,, ahk_id %hwnd%
if (cls="ComboBox" && !(st&1))			; ComboBox (not DropDownList)
	{
	VarSetCapacity(cbi, sz := 40+3*PtrSz, 0)			; COMBOBOXINFO struct
	NumPut(sz, cbi, 0, "UInt")			; cbSize
	if !DllCall("GetComboBoxInfo", Ptr, hwnd, Ptr, &cbi)	; Win98+
		{
		OutputDebug, GetComboBoxInfo() failed in %A_ThisFunc%(). CBI size=%sz% hwnd=%hwnd%
		return 0
		}
;	SendMessage, 0x164, 0, &cbi,, ahk_id %hwnd%	; CB_GETCOMBOBOXINFO (XP+)
	hwnd := NumGet(cbi, 40+PtrSz, Ptr)			; hwndItem
	return 1
	}
else if cls=ComboBoxEx		; for ComboBoxEx use CBEM_GETEDITCONTROL
	{
	hwnd := DllCall("SendMessage" AW, Ptr, hwnd, "UInt", 0x407, "UInt", 0, "UInt", 0, Ptr)
	return 1
	}
return 0
}
;================================================================
CueBanner_SetRect(hwnd, ByRef rect)
;================================================================
{
Global Ptr, w9x
ofi := A_FormatInteger
SetFormat, Integer, H
WinGetClass, cls, ahk_id %hwnd%
ControlGet, st, Style,,, ahk_id %hwnd%
ControlGet, est, ExStyle,,, ahk_id %hwnd%
s := st & 0xF, e := est & 0x403000
SetFormat, Integer, %ofi%
DllCall("GetClientRect", Ptr, hwnd, Ptr, &rect)
w := NumGet(rect, 8, "UInt")
if (cls="ComboBox" && (st&1))			; DropDownList
	{
	SysGet, bw, 2		; SM_CXVSCROLL
	SysGet, he, 45	; SM_CXEDGE
	SysGet, ve, 46	; SM_CYEDGE
	h := NumGet(rect, 12, "UInt")
	NumPut(2+he, rect, 0, "UInt"), NumPut(w-(bw+2*he+2), rect, 8, "UInt")
	NumPut(ve, rect, 4, "UInt"), NumPut(h-2*ve, rect, 12, "UInt")
	}
else if cls=Edit
	{
	SysGet, he, 45	; SM_CXEDGE
	SysGet, ve, 46	; SM_CYEDGE
	r := DllCall("SendMessage" AW
		, Ptr		, hwnd
		, "UInt"	, 0xD4		; EM_GETMARGINS
		, "UInt"	, 0
		, "UInt"	, 0
		, "UInt")
	lm := r&0xFFFF, rm := (r>>16)&0xFFFF
	NumPut(lm+2, rect, 0, "UInt"), NumPut(w-(rm+lm+2), rect, 8, "UInt")
	}
else if cls=Static
	{
	h := NumGet(rect, 12, "UInt")
	NumPut(1, rect, 0, "UInt"), NumPut(w-2, rect, 8, "UInt")
	NumPut(2, rect, 4, "UInt"), NumPut(h-2, rect, 12, "UInt")
	}
else if cls=Button
	{
	if s in 0x2,0x3,0x4,0x9	; checkboxes, radio buttons
		{
		if !w9x
			{
			if e in 0x1000,0x3000,0x400000,0x402000
				NumPut(1, rect, 0, "UInt")
			else NumPut(16, rect, 0, "UInt")
			NumPut(w-15, rect, 8, "UInt")
			}
		else
			{
			if e in 0x1000,0x3000,0x401000,0x403000
				NumPut(1, rect, 0, "UInt")
			else NumPut(15, rect, 0, "UInt")
			NumPut(w-16, rect, 8, "UInt")
			}
		}
	else
		{
		NumPut(1, rect, 0, "UInt"), NumPut(w-2, rect, 8, "UInt")
		}
	}
}
;================================================================
CueBanner_A2U(pIn, ByRef Out, cp=0)
;================================================================
{
Global Ptr, A_CharSize
Static M2W, W2M, badEnc, In
if !M2W
	{
	M2W := "MultiByteToWideChar"
	W2M := "WideCharToMultiByte"
	badEnc := "42,65000,65001,50220,50221,50222,50225,50227,50229,52936,54936
			,57002,57003,57004,57005,57006,57007,57008,57009,57010,57011"
	}
if cp in %badEnc%
	f := 0
else f := 1
if (cp && A_IsUnicode)
	{
	if !sz1 := DllCall(W2M, "UInt", 0, "UInt", 0, Ptr, pIn, "Int", -1, Ptr, 0, "UInt", 0, "UInt", 0, "UInt", 0)
		{
		OutputDebug, cp=%cp% flag=%f% func=%W2M%() failed
		return 0
		}
	VarSetCapacity(In, (sz1+1)*A_CharSize, 0)
	DllCall(W2M, "UInt", 0, "UInt", 0, Ptr, pIn, "Int", -1, Ptr, &In, "UInt", sz1, "UInt", 0, "UInt", 0)
	pIn:=&In
	}
if !sz := DllCall(M2W, "UInt", cp, "UInt", f, Ptr, pIn, "UInt", -1, Ptr, &Out, "UInt", 0)	; CP_UTF8
	{
	OutputDebug, % M2W " no sz, error " DllCall("GetLastError")
	return 0
	}
VarSetCapacity(Out, 2*sz, 0)
if !DllCall(M2W, "UInt", cp, "UInt", f, Ptr, pIn, "UInt", -1, Ptr, &Out, "UInt", sz)	; CP_UTF8 
	OutputDebug, % M2W " conversion error " DllCall("GetLastError")
VarSetCapacity(In, 0)
return sz-1	; if cbMultiByte is -1 the result will be null terminated and sz will include it, so subtract the null
}
;================================================================
CueBanner_GPA(libName, proc="", ord="", ByRef hLib=0)
;================================================================
{
Global Ptr, AStr, AW
if !h := DllCall("GetModuleHandle" AW, "Str", libName, Ptr)		; try if module is already loaded; if not,
	h := hLib := DllCall("LoadLibrary" AW, "Str", libName, Ptr)	; load it and save handle for later cleanup
if proc
	if r := DllCall("GetProcAddress"
			, Ptr, h
			, AStr, proc					; try by procedure name first, if present
			, Ptr)
		return r
if ord is integer
	if r := DllCall("GetProcAddress"
			, Ptr, h
			, "UInt", ord					; otherwise try by ordinal number, if present
			, Ptr)
		return r
if h && hLib && DllCall("FreeLibrary", Ptr, hLib)	; if everything fails, unload library if loaded by us
	hLib := 0
return 0
}
;================================================================
#include *i extra\DrawShadowText9x.ahk
