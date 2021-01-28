
thumbnailer(_guiID, _percent=.25, _transColor="", _guiNum=99)	;id to thumbnail, _percent of shrinkage, desired gui number of thumbnail	;
{
	global thumb_guiID, thumb_width, thumb_height
	WinGetPos,,,cW,cH,ahk_id %_guiID%
	hdc_kb := DllCall("GetDC", "uint",  _guiID)
	thumb_w:= cW * _percent 	;make thumb a % of original
	thumb_h:= cH * _percent
	use_antialias = 1

	; buffer
	hdc_buffer := 	DllCall("gdi32.dll\CreateCompatibleDC"     	, "uint", hdc_kb)
	hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap" , "uint", hdc_kb, "int", thumb_w, "int", thumb_h)
	r := 				DllCall("gdi32.dll\SelectObject"           		, "uint", hdc_buffer, "uint", hbm_buffer)

	HALFTONE = 4	;set some constants for SetStretchBltMode
	COLORONCOLOR = 3
	If(use_antialias)	;comment this line for speed but less quality
	{	DllCall("gdi32.dll\SetStretchBltMode", "uint", hdc_buffer, "int", HALFTONE)  ; Halftone - better quality with shrink
	}

	oBlue := SubStr(_transColor,7,2)	;reorder from 0xrrggbb to 0x00bbggrr
	oGreen := SubStr(_transColor,5,2)
	oRed := SubStr(_transColor,3,2)
	_transColor_new = 0x00%oBlue%%oGreen%%oRed%

	Gui, %_guiNum%:+LastFound -Caption +ToolWindow +AlwaysOnTop +E0x80000
	showID := WinExist()
	
;~ 	hdc_thumb := DllCall("GetDC", "uint",  showID)	;make bkgnd of dest dc the _transColor
;~ 	DllCall("gdi32.dll\SetBkColor", "uint", hdc_buffer, "uint", _transColor_new)
	
	;shrink to thumb dc
	DllCall("gdi32.dll\StretchBlt"
		, "uint", hdc_buffer,	"int", 0, "int", 0, "int", thumb_w, "int", thumb_h
		, "uint", hdc_kb, "int", 0, "int", 0, "int", cW, "int", cH, "uint", 0xCC0020)

	ULW_COLORKEY=1	;set some constants for UpdateLayeredWindow
	ULW_ALPHA=2
	ULW_OPAQUE=4
	If(_transColor)
	{	crKey:=_transColor_new
		ULW:=ULW_COLORKEY
	}
	Else
	{	crKey=0
		ULW := ULW_OPAQUE
	}
	DllCall("UpdateLayeredWindow", "Uint", showID, "Uint", 0, "Uint", 0, "int64P", thumb_w|thumb_h<<32, "Uint", hdc_buffer, "int64P", 0, "Uint", crKey, "UintP", 0<<16|1<<24, "Uint", ULW)
	DllCall("gdi32.dll\ReleaseDC", "uint", hdc_thumb)
	DllCall("gdi32.dll\ReleaseDC", "uint", hdc_kb)
	DllCall("gdi32.dll\DeleteObject", "uint", hbm_buffer)
	DllCall("gdi32.dll\DeleteDC", "uint", hdc_buffer)

	thumb_guiID := showID	;set the thumb gui id, w, h
	thumb_width := thumb_w
	thumb_height := thumb_h
	
	Gui, %_guiNum%:Show, Hide NA w%thumb_w% h%thumb_h%
	Gui, %_guiNum%:Hide
	Return _guiNum
}

;below is just for testing  -  it is skipped of not standalone
IfNotEqual,A_ScriptName,thumbnailer.ahk, goto skipper	;test gui
DetectHiddenWindows, On
Gui, -Caption +AlwaysOnTop
Gui, Add, Text,, This is a test.
Gui, Add, Button, gguiClose, hello
Gui, Add, Button, gguiClose, hello
Gui, Add, Button, gguiClose, hello
Gui, Add, Button, gguiClose, hello
Gui, Add, Edit,,Testing 1,2,3...
Gui, Color, 0xFF8000
gx := (A_ScreenWidth/2)+65
Gui, +LastFound
guiID := WinExist()
Gui, Show, x%gx% yCenter, Big One
WinGetPos,,,cW,cH,ahk_id %guiID%
WinSet, Region, 0-0 W%cW% H%cH% R20-20, ahk_id %guiID%
Sleep,50
thumb_guiNum := thumbnailer(guiID,".75","")	;make the thumbnail gui
Gui, %thumb_guiNum%:Show, NA
Return

guiClose:
	ExitApp
Return
skipper:


