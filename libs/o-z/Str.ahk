;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Wrap text in array based on font type and width.
Str_ManuallyWrapArray(ByRef asToWrap, iMaxWidth, hFont)
{
	asTmp := []
	Loop, % asToWrap.MaxIndex()
	{
		; Do this roundabout way because you cannot pass objects inside of objects ByRef.
		sTmp := Str_Wrap(asToWrap[A_Index], iMaxWidth, hFont, true, iTmpH)
		iH += iTmpH
		asTmp.Insert(sTmp)
	}
	asToWrap := asTmp
	return iH
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Special thanks to jballi for his incredibly useful Fnt library! Check it out at http://www.autohotkey.com/board/topic/90481-library-fnt-v03-preview-do-stuff-with-fonts/
;;;;;;;;;;;;;; Manually wraps text
;;;;;;;;;;;;;; s = string to wrap
;;;;;;;;;;;;;; iMaxWidth = maximum width until text should be wrapped. Default value is 336. That number is the width of 56 characters (in pixels) when using default GUI font options.
;;;;;;;;;;;;;; hFont = handle to logical font
;;;;;;;;;;;;;; bCalcH = calculate total height of wrapped string
;;;;;;;;;;;;;; riH = total height of wrapped string. It should only be set when bCalcH is true
;;;;;;;;;;;;;; returns wrapped string
Str_Wrap(s, iMaxWidth=336, hFont="", bCalcH=false, ByRef riH="")
{
	if (s != A_Space)
		s := Trim(s, A_Space)
	s := Trim(s, A_Tab)

	Loop, Parse, s, `n, `r
	{
		sSentence := A_LoopField

		if (Str_MeasureText(sSentence, hFont).right > iMaxWidth)
		{
			StringSplit, aSpaceDelimWords, sSentence, %A_Space%

			if (aSpaceDelimWords0 == 1) ; Single word is too wide and must be hard-wrapped
			{
				sTmp :=Substr(sSentence, 1, StrLen(sSentence) - 1)
				while (Str_MeasureText(sTmp, hFont).right > iMaxWidth)
					sTmp := Substr(sSentence, 1, StrLen(sSentence)-A_Index) ; Single word is too wide. Hard-wrap it. TODO: Binary iteration
				sNew .= sTmp "`n" Str_Wrap(SubStr(sSentence, InStr(sSentence, sTmp) + StrLen(sTmp)), iMaxWidth, hFont)
			}
			else
			{
				Loop, %aSpaceDelimWords0%
				{
					sWord := aSpaceDelimWords%A_Index%

					if (Str_MeasureText(sCompound (sCompound == A_Blank ? "" : " ") sWord, hFont).right > iMaxWidth)
					{
						sNew .= sCompound == A_Blank ? "" : sNew == A_Blank ? sCompound : "`n" sCompound
						sCompound:=
						sTmp := Str_Wrap(sWord, iMaxWidth, hFont)

						StringSplit, aNewlineDelimStr, sTmp, `n
						;~ Msgbox ok`n`n|%sNew%|`n`n|%sCompound%|`n`n|%sWord%|`n`n|%sTmp%|`n`n%aNewlineDelimStr0%
						if (aNewlineDelimStr0 == 1)
							sCompound .= sTmp
						else Loop %aNewlineDelimStr0%
							if (A_Index == aNewlineDelimStr0)
								sCompound := aNewlineDelimStr%A_Index%
							else sNew .= "`n" aNewlineDelimStr%A_Index%
					}
					else sCompound .= A_Index == 1 ? sWord : " " sWord
				}
				if (sCompound)
					sNew .= "`n" sCompound
			}
		}
	}

	sNew := sNew == A_Blank ? s : sNew

	if (bCalcH)
	{
		; Calcuate the height by adding up the font height for each row, and including
		; the space between lines (iExternalLeading) if there is more than one line.
		iFntH := Fnt_GetFontHeight(hFont)
		iExternalLeading := Fnt_GetFontExternalLeading(hFont)
		StringSplit, aNumOfLines, sNew, `n

		; Note: jballi adds += GUI_CTL_VERTICAL_DEADSPACE (= 8) to the calc below. This function intentionally does not do so because it is intended to be used for functions such as calculating height of text controls.
		riH := Floor((iFntH*aNumOfLines0)+(iExternalLeading*(Floor(aNumOfLines0+0.5)-1))+0.5)
	}

	return sNew
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; s = string to measure
;;;;;;;;;;;;;; hFont = handle to logical font
;;;;;;;;;;;;;; returns rect, but top and left will always be 0
Str_MeasureText(s, hFont)
{
	; Not using struct rect because it does not support negative values
	rect := {}
	Fnt_GetStringSize(hFont, s, iW, iH)
	rect.left := rect.top := 0
	rect.right := iW
	rect.bottom := iH
	return rect
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Unlike Str_MeasureText, this function takes into account the fact that a single string may be larger than the caller desires
;;;;;;;;;;;;;; s = string to measure
;;;;;;;;;;;;;; hFont = handle to logical font
;;;;;;;;;;;;;; iMaxWidth = maximum width until text should be wrapped. Default value is 336. That number is the width of 56 characters (in pixels) when using default GUI font options.
;;;;;;;;;;;;;; returns rect, but top and left will always be 0
Str_MeasureTextWrap(s, iMaxWidth, hFont)
{
	; Not using struct rect because it does not support negative values.
	rect := {}

	rect.left := rect.top := 0
	sWrapped := Str_Wrap(s, iMaxWidth, hFont, true, iH)
	StringSplit, aWrapped, sWrapped, `n
	rect.bottom := iH

	Loop, Parse, sWrapped, `n
	{
		vTmpRect :=Str_MeasureText(A_LoopField, hFont)
		if (vTmpRect.right > iGreatestW)
			iGreatestW := vTmpRect.right
	}
	rect.right := iGreatestW

	return rect
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
Str_GetMaxCharsForFont(sChar, iMaxWidth, hFont)
{
	while (true)
	{
		s :=
		Loop %A_Index%
			s .= sChar
		if (Str_MeasureText(s, hFont).right > iMaxWidth)
			return StrLen(s) - 1
	}

	return 0 ; fail
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
Str_MeasureTextOld(Str, FontOpts = "", FontName = "")
{
	Static DT_FLAGS := 0x0520 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400
	Static WM_GETFONT := 0x31
	Size := {}
	Gui, TEMP_GUI: New
	If (FontOpts <> "") || (FontName <> "")
		Gui, Font, %FontOpts%, %FontName%
	Gui, Add, Text, hwndHWND
	SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
	HFONT := ErrorLevel
	HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
	DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)
	VarSetCapacity(RECT, 16, 0)
	DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Str, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
	DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)
	Gui, Destroy
	Size.W := NumGet(RECT,  8, "Int")
	Size.H := NumGet(RECT, 12, "Int")
	Return Size
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Enclose selected text in s -- i.e. sSTRINGs
Str_SurroundWithStr(s) ; May add Bool bUseClipboard
{
	bTargetAppActive := false
	WinGetActiveTitle, sTitle
	WinGetClass, sClass, A

	IfWinActive, ahk_class XLMAIN
		bTargetAppActive := true
	else IfWinActive, ahk_class wndclass_desked_gsk
		bTargetAppActive := true
	else if (InStr(sTitle, "Microsoft Visual Studio") || InStr(sTitle, "Invest.VS2015"))
		bTargetAppActive := true
	else if (InStr(sTitle, "- Remote Desktop"))
		bTargetAppActive := true
	else if (sClass = "Chrome_WidgetWin_1" && (InStr(sTitle, "Edit Style") || InStr(sTitle, "JSFiddle") || InStr(sTitle, "MariaDB 10"))
		&& (s = "(" || s = """"))
	{
		if (s = "(" )
			SendInput %s%)
		else SendInput %s%`"
		SendInput {Left}
		return
	}

	If (bTargetAppActive)
	{
		SendInput %s%
		return
	}

	; Save whatever is currently on the clipboard.
	sOldClipboard := clipboard
	clipboard =
	SendInput ^{c}
	ClipWait, .1

	sSend := st_Pad(clipboard, s, s)
	; TODO: Replace { and }
	StringReplace, sSend, sSend, `#, `{#}, All
	StringReplace, sSend, sSend, `^, `{^}, All
	StringReplace, sSend, sSend, `+, `{+}, All
	StringReplace, sSend, sSend, `!, `{!}, All

	SendInput %sSend%

	if (s = "(")
		SendInput {Backspace}`)

	if (clipboard == A_Blank)
		SendInput {Left}

	clipboard := sOldClipboard ; Restore old clipboard
	return
}

1Str_SurroundWithStr(s)
{
	IfWinActive, ahk_class wndclass_desked_gsk
		bStop := true
	IfWinActive, ahk_class XLMain
		bStop := true
	if (bStop)
	{
		Send %s%
		return
	}

	SavedClip := ClipboardAll
	Clipboard := ""
	Send ^c
	ClipWait .1

	bNoStr := clipboard == A_Blank

	if (!ErrorLevel)
	{
		Clipboard := s . Clipboard . (s = "(" ? ")"
								: s = "{" ? "}"
								: s = "[" ? "]"
								: s)
		Send ^v
	}

	if (bNoStr) ; if there was no string to surround, place the caret inside of the surrounded text
		Send {Left}

	Clipboard := SavedClip
	SavedClip := ""
	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;