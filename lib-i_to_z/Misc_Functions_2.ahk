AddGraphicButton(VariableName, ImgPath, Options="", bHeight=32, bWidth=32) {
Global
Local ImgType, ImgType1, ImgPath0, ImgPath1, ImgPath2, hwndmode
; BS_BITMAP := 128, IMAGE_BITMAP := 0, BS_ICON := 64, IMAGE_ICON := 1
Static LR_LOADFROMFILE := 16
Static BM_SETIMAGE := 247
Static NULL
SplitPath, ImgPath,,, ImgType1
If ImgPath is float
{
  ImgType1 := (SubStr(ImgPath, 1, 1)  = "0") ? "bmp" : "ico"
  StringSplit, ImgPath, ImgPath,`.
  %VariableName%_img := ImgPath2
  hwndmode := true
}
ImgTYpe := (ImgType1 = "bmp") ? 128 : 64
If (%VariableName%_img != "") AND !(hwndmode)
  DllCall("DeleteObject", "UInt", %VariableName%_img)
If (%VariableName%_hwnd = "")
  Gui, 80: Add, Button,  v%VariableName% hwnd%VariableName%_hwnd +%ImgTYpe% %Options%
ImgType := (ImgType1 = "bmp") ? 0 : 1
If !(hwndmode)
  %VariableName%_img := DllCall("LoadImage", "UInt", NULL, "Str", ImgPath, "UInt", ImgType, "Int", bWidth, "Int", bHeight, "UInt", LR_LOADFROMFILE, "UInt")
DllCall("SendMessage", "UInt", %VariableName%_hwnd, "UInt", BM_SETIMAGE, "UInt", ImgType,  "UInt", %VariableName%_img)
Return, %VariableName%_img ; Return the handle to the image
}

;//******************* Functions *******************
;//Sun, Jul 13, 2008 --- 7/13/08, 7:19:19pm
;//Function: ListView_HeaderFontSet
;//Params...
;//		p_hwndlv    = ListView hwnd
;//		p_fontstyle = [b[old]] [i[talic]] [u[nderline]] [s[trike]]
;//		p_fontname  = <any single valid font name = Arial, Tahoma, Trebuchet MS>
ListView_HeaderFontSet(p_hwndlv="", p_fontstyle="", p_fontname="") {
	static hFont1stBkp
	method:="CreateFont"
	;//method="CreateFontIndirect"
	WM_SETFONT:=0x0030
	WM_GETFONT:=0x0031

	LVM_FIRST:=0x1000
	LVM_GETHEADER:=LVM_FIRST+31

	;// /* Font Weights */
	FW_DONTCARE:=0
	FW_THIN:=100
	FW_EXTRALIGHT:=200
	FW_LIGHT:=300
	FW_NORMAL:=400
	FW_MEDIUM:=500
	FW_SEMIBOLD:=600
	FW_BOLD:=700
	FW_EXTRABOLD:=800
	FW_HEAVY:=900

	FW_ULTRALIGHT:=FW_EXTRALIGHT
	FW_REGULAR:=FW_NORMAL
	FW_DEMIBOLD:=FW_SEMIBOLD
	FW_ULTRABOLD:=FW_EXTRABOLD
	FW_BLACK:=FW_HEAVY
	/*
	parse p_fontstyle for...
		cBlue	color	*** Note *** OMG can't set ListView/SysHeader32 font/text color??? ***
		s19		size
		b		bold
		w500	weight?
	*/
	;//*** Note *** yes I will allow mixed types later!...this was quick n dirty...
	;//*** Note *** ...it now supports bold italic underline & strike-thru...all at once
	style:=p_fontstyle
	;//*** Note *** change RegExReplace to RegExMatch
	style:=RegExReplace(style, "i)\s*\b(?:I|U|S)*B(?:old)?(?:I|U|S)*\b\s*", "", style_bold)
	style:=RegExReplace(style, "i)\s*\b(?:B|U|S)*I(?:talic)?(?:B|U|S)*\b\s*", "", style_italic)
	style:=RegExReplace(style, "i)\s*\b(?:B|I|S)*U(?:nderline)?(?:B|I|S)*\b\s*", "", style_underline)
	style:=RegExReplace(style, "i)\s*\b(?:B|I|U)*S(?:trike)?(?:B|I|U)*\b\s*", "", style_strike)
	;//style:=RegExReplace(style, "i)\s*\bW(?:eight)(\d+)\b\s*", "", style_weight)
	if (style_bold)
		fnWeight:=FW_BOLD
	if (style_italic)
		fdwItalic:=1
	if (style_underline)
		fdwUnderline:=1
	if (style_strike)
		fdwStrikeOut:=1
	;//if (mweight)
	;//	fnWeight:=mweight
	lpszFace:=p_fontname

	ret:=hHeader:=SendMessage(p_hwndlv, LVM_GETHEADER, 0, 0)
	el:=Errorlevel
	le:=A_LastError
	;//msgbox, 64, , SendMessage LVM_GETHEADER: ret(%ret%) el(%el%) le(%le%)

	ret:=hFontCurr:=SendMessage(hHeader, WM_GETFONT, 0, 0)
	el:=Errorlevel
	le:=A_LastError
	;//msgbox, 64, , SendMessage WM_GETFONT: ret(%ret%) el(%el%) le(%le%)
	if (!hFont1stBkp) {
		hFont1stBkp:=hFontCurr
	}

	if (method="CreateFont") {
		if (p_fontstyle!="" || p_fontname!="") {
			ret:=hFontHeader:=CreateFont(nHeight, nWidth, nEscapement, nOrientation
										, fnWeight, fdwItalic, fdwUnderline, fdwStrikeOut
										, fdwCharSet, fdwOutputPrecision, fdwClipPrecision
										, fdwQuality, fdwPitchAndFamily, lpszFace)
			el:=Errorlevel
			le:=A_LastError
			;//msgbox, 64, , CreateFont: ret(%ret%) el(%el%) le(%le%)
		} else hFontHeader:=hFont1stBkp
		ret:=SendMessage(hHeader, WM_SETFONT, hFontHeader, 1)
		;//ret:=SendMessage(hHeader, WM_SETFONT, hFontHeader, 0)
		;//ret:=SendMessage(hHeader, WM_SETFONT, &0, 1)
		el:=Errorlevel
		le:=A_LastError
		;//msgbox, 64, , SendMessage WM_SETFONT: ret(%ret%) el(%el%) le(%le%)
	}
}

/*
HFONT CreateFont(
  int nHeight,               // height of font
  int nWidth,                // average character width
  int nEscapement,           // angle of escapement
  int nOrientation,          // base-line orientation angle
  int fnWeight,              // font weight
  DWORD fdwItalic,           // italic attribute option
  DWORD fdwUnderline,        // underline attribute option
  DWORD fdwStrikeOut,        // strikeout attribute option
  DWORD fdwCharSet,          // character set identifier
  DWORD fdwOutputPrecision,  // output precision
  DWORD fdwClipPrecision,    // clipping precision
  DWORD fdwQuality,          // output quality
  DWORD fdwPitchAndFamily,   // pitch and family
  LPCTSTR lpszFace           // typeface name
);
*/
CreateFont(               nHeight                   , nWidth                  , nEscapement
						, nOrientation              , fnWeight                , fdwItalic
						, fdwUnderline              , fdwStrikeOut            , fdwCharSet
						, fdwOutputPrecision        , fdwClipPrecision        , fdwQuality
						, fdwPitchAndFamily         , lpszFace) {
	return DllCall("CreateFont"
				, "Int" , nHeight           , "Int" , nWidth          , "Int" , nEscapement
				, "Int" , nOrientation      , "Int" , fnWeight        , "UInt", fdwItalic
				, "UInt", fdwUnderline      , "UInt", fdwStrikeOut    , "UInt", fdwCharSet
				, "UInt", fdwOutputPrecision, "UInt", fdwClipPrecision, "UInt", fdwQuality
				, "UInt", fdwPitchAndFamily , "Str" , lpszFace)
}

SendMessage(p_hwnd, p_msg, p_wParam="", p_lParam="") {
	return DllCall("SendMessage", "UInt", p_hwnd, "UInt", p_msg, "UInt", p_wParam, "UInt", p_lParam)
}

;//           Msg [, wParam     , lParam     , Control  , WinTitle  , WinText  , ExcludeTitle     , ExcludeText
A_SendMessage(p_msg, p_wParam="", p_lParam="", p_ctrl="", p_title="", p_text="", p_excludetitle="", p_excludetext="") {
	SendMessage, p_msg, p_wParam, p_lParam, %p_ctrl%, %p_title%, %p_text%, %p_excludetitle%, %p_excludetext%
	return errorlevel
}
;//******************* /Functions *******************

ControlFocused() {
    ControlGetFocus, Control, A
    Return Control
}


;************************
; Edit Control Functions
;************************
;
; http://www.autohotkey.com/forum/topic22748.html
;
; Standard parameters:
;   Control, WinTitle   If WinTitle is not specified, 'Control' may be the
;                       unique ID (hwnd) of the control.  If "A" is specified
;                       in Control, the control with input focus is used.
;
; Standard/default return value:
;   true on success, otherwise false.


Edit_Standard_Params(ByRef Control, ByRef WinTitle) {  ; Helper function.
    if (Control="A" && WinTitle="") { ; Control is "A", use focused control.
        ControlGetFocus, Control, A
        WinTitle = A
    } else if (Control+0!="" && WinTitle="") {  ; Control is numeric, assume its a ahk_id.
        WinTitle := "ahk_id " . Control
        Control =
    }
}

; Returns true if text is selected, otherwise false.
;
Edit_TextIsSelected(Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    return Edit_GetSelection(start, end, Control, WinTitle) and (start!=end)
}

; Gets the start and end offset of the current selection.
;
Edit_GetSelection(ByRef start, ByRef end, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    VarSetCapacity(start, 4), VarSetCapacity(end, 4)
    SendMessage, 0xB0, &start, &end, %Control%, %WinTitle%  ; EM_GETSEL
    if (ErrorLevel="FAIL")
        return false
    start := NumGet(start), end := NumGet(end)
    return true
}

; Selects text in a text box, given absolute character positions (starting at 0.)
;
; start:    Starting character offset, or -1 to deselect.
; end:      Ending character offset, or -1 for "end of text."
;
Edit_Select(start=0, end=-1, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    SendMessage, 0xB1, start, end, %Control%, %WinTitle%  ; EM_SETSEL
    return (ErrorLevel != "FAIL")
}

; Selects a line of text.
;
; line:             One-based line number, or 0 to select the current line.
; include_newline:  Whether to also select the line terminator (`r`n).
;
Edit_SelectLine(line=0, include_newline=false, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)

    ControlGet, hwnd, Hwnd,, %Control%, %WinTitle%
    if (!WinExist("ahk_id " hwnd))
        return false

    if (line<1)
        ControlGet, line, CurrentLine

    SendMessage, 0xBB, line-1, 0  ; EM_LINEINDEX
    offset := ErrorLevel

    SendMessage, 0xC1, offset, 0  ; EM_LINELENGTH
    lineLen := ErrorLevel

    if (include_newline) {
        WinGetClass, class
        lineLen += (class="Edit") ? 2 : 1 ; `r`n : `n
    }

    ; Select the line.
    SendMessage, 0xB1, offset, offset+lineLen  ; EM_SETSEL
    return (ErrorLevel != "FAIL")
}

; Deletes a line of text.
;
; line:     One-based line number, or 0 to delete current line.
;
Edit_DeleteLine(line=0, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    ; Select the line.
    if (Edit_SelectLine(line, true, Control, WinTitle))
    {   ; Delete it.
        ControlSend, %Control%, {Delete}, %WinTitle%
        return true
    }
    return false
}