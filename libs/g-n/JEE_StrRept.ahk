; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

q:: ;test - align text, add tabs
;vText := JEE_GetSelectedText()
ControlGet, vText, Selected,, Edit1, A

SendMessage, 0x31, 0, 0, Edit1, A ;WM_GETFONT := 0x31
hFont2 := ErrorLevel
hFont := JEE_FontClone(hFont2)
Clipboard := JEE_StrAlignText(vText, hFont)
return

;==================================================

w:: ;test - align text, add tabs
vRange1 := 1, vRange2 := 34
vRange3 := 97, vRange4 := 122
vText := ""
VarSetCapacity(vText, 1000000*2)
Loop, % 100
{
	Random, vCount1, % vRange1, % vRange2
	Random, vCount2, % vRange1, % vRange2
	Random, vCount3, % vRange1, % vRange2
	Random, vCount4, % vRange1, % vRange2

	Random, vOrd1, % vRange3, % vRange4
	Random, vOrd2, % vRange3, % vRange4
	Random, vOrd3, % vRange3, % vRange4
	Random, vOrd4, % vRange3, % vRange4

	vText .= JEE_StrRept(Chr(vOrd1), vCount1) "`t" JEE_StrRept(Chr(vOrd2), vCount2) "`t" JEE_StrRept(Chr(vOrd3), vCount3) "`t" JEE_StrRept(Chr(vOrd4), vCount4) "`r`n"
}
;vText .= JEE_StrRept("a", 40) "`t" "b"

SendMessage, 0x31, 0, 0, Edit1, A ;WM_GETFONT := 0x31
hFont2 := ErrorLevel
hFont := JEE_FontClone(hFont2)
Clipboard := JEE_StrAlignText(vText, hFont)
return

;==================================================

JEE_StrRept(vText, vNum)
{
	if (vNum <= 0)
		return
	return StrReplace(Format("{:" vNum "}","")," ",vText)
	;return StrReplace(Format("{:0" vNum "}",0),0,vText)
}

;==================================================

;e.g. hFontNew := JEE_FontClone(hFont)
JEE_FontClone(hFont)
{
	VarSetCapacity(LOGFONT, 92, 0) ;LOGFONT (Unicode)
	vSize := DllCall("gdi32\GetObject", Ptr,hFont, Int,0, Ptr,0)
	DllCall("gdi32\GetObject", Ptr,hFont, Int,vSize, Ptr,&LOGFONT)
	return DllCall("gdi32\CreateFontIndirect", Ptr,&LOGFONT, Ptr)
}

;==================================================

;add tabs so that strings are aligned as columns
;vMin: minimum gap in pixels between tabs
JEE_StrAlignText(vText, hFont:="", vMin:=1)
{
	vTabWidth := JEE_FontGetAvgCharWidthABC(hFont)*8
	;get column count and get largest column width in pixels for each column
	vCount := 1, oMax := [0]
	Loop, Parse, vText, `n, `r
	{
		oTemp := StrSplit(A_LoopField, "`t")
		if (vCount < oTemp.Length())
			Loop, % oTemp.Length() - vCount
				vCount += 1, oMax[vCount] := 0
		Loop, % oTemp.Length()
		{
			JEE_StrGetDim(oTemp[A_Index], hFont, vWidth, vHeight)
			if (oMax[A_Index] < vWidth)
				oMax[A_Index] := vWidth
		}
	}

	;add tabs as appropriate to each column
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	Loop, Parse, vText, `n, `r
	{
		oTemp := StrSplit(A_LoopField, "`t")
		if (oTemp.Length() = 1)
		{
			vOutput .= A_LoopField "`r`n"
			continue
		}
		Loop, % oTemp.Length() - 1
		{
			JEE_StrGetDim(oTemp[A_Index], hFont, vWidth, vHeight)
			vColWidth := Ceil(oMax[A_Index]/vTabWidth)*vTabWidth ;width from start of column to start of next column
			vTabCount := Ceil((vColWidth-vWidth)/vTabWidth) ;tabs needed from end of text to start of next column
			vAdjust := (Mod(oMax[A_Index], vTabWidth) < vMin) ;if end of longest string in column and start of next column too close, append an extra tab to all items in column
			vOutput .= oTemp[A_Index]
			Loop, % vTabCount + vAdjust
				vOutput .= "`t"
		}
		vOutput .= oTemp[oTemp.Length()] "`r`n"
	}
	return SubStr(vOutput, 1, -2)
}

;==================================================

;vLimW and vLimH if present are used as limits
;JEE_DrawText
JEE_StrGetDim(vText, hFont, ByRef vTextW, ByRef vTextH, vDTFormat:=0x400, vLimW:="", vLimH:="")
{
	;DT_EDITCONTROL := 0x2000 ;DT_NOPREFIX := 0x800
	;DT_CALCRECT := 0x400 ;DT_NOCLIP := 0x100
	;DT_EXPANDTABS := 0x40 ;DT_SINGLELINE := 0x20
	;DT_WORDBREAK := 0x10

	;HWND_DESKTOP := 0
	hDC := DllCall("user32\GetDC", Ptr,0, Ptr)
	hFontOld := DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFont, Ptr)
	VarSetCapacity(SIZE, 8, 0)
	vTabLengthText := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	DllCall("gdi32\GetTextExtentPoint32", Ptr,hDC, Str,vTabLengthText, Int,52, Ptr,&SIZE)
	vTabLength := NumGet(&SIZE, 0, "Int") ;cx ;logical units
	vTabLength := Floor((vTabLength/52)+0.5)
	vTabLength := Round(vTabLength*(72/A_ScreenDPI))
	vLen := StrLen(vText)

	VarSetCapacity(DRAWTEXTPARAMS, 20, 0)
	NumPut(20, &DRAWTEXTPARAMS, 0, "UInt") ;cbSize
	NumPut(vTabLength, &DRAWTEXTPARAMS, 4, "Int") ;iTabLength
	;NumPut(0, &DRAWTEXTPARAMS, 8, "Int") ;iLeftMargin
	;NumPut(0, &DRAWTEXTPARAMS, 12, "Int") ;iRightMargin
	NumPut(vLen, &DRAWTEXTPARAMS, 16, "UInt") ;uiLengthDrawn

	VarSetCapacity(RECT, 16, 0)
	if !(vLimW = "")
		NumPut(vLimW, &RECT, 8, "Int")
	if !(vLimH = "")
		NumPut(vLimH, &RECT, 12, "Int")
	DllCall("user32\DrawTextEx", Ptr,hDC, Str,vText, Int,vLen, Ptr,&RECT, UInt,vDTFormat, Ptr,&DRAWTEXTPARAMS)
	DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFontOld, Ptr)
	DllCall("user32\ReleaseDC", Ptr,0, Ptr,hDC)

	vTextW := NumGet(&RECT, 8, "Int")
	vTextH := NumGet(&RECT, 12, "Int")
}

;==================================================

;similar to Fnt_GetDialogBaseUnits
;JEE_StrGetDimTabLength
;JEE_StrGetDimAvgCharWidth
JEE_FontGetAvgCharWidthABC(hFont, vOpt:="")
{
	;HWND_DESKTOP := 0
	hDC := DllCall("user32\GetDC", Ptr,0, Ptr)
	hFontOld := DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFont, Ptr)
	VarSetCapacity(SIZE, 8, 0)
	vWidthText := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	DllCall("gdi32\GetTextExtentPoint32", Ptr,hDC, Str,vWidthText, Int,52, Ptr,&SIZE)
	DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFontOld, Ptr)
	DllCall("user32\ReleaseDC", Ptr,0, Ptr,hDC)

	vWidth := NumGet(&SIZE, 0, "Int") ;cx ;logical units
	vWidth := Floor((vWidth/52)+0.5)
	;vWidth := Floor((vWidth/26+1)/2)
	if InStr(vOpt, "p") ;convert to pixels
		return Round(vWidth*(72/A_ScreenDPI))
	return vWidth
}

;==================================================

;similar to Fnt_GetFontAvgCharWidth
JEE_FontGetAvgCharWidthX(hFont)
{
	;HWND_DESKTOP := 0
	hDC := DllCall("user32\GetDC", Ptr,0, Ptr)
	hFontOld := DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFont, Ptr)
	VarSetCapacity(TEXTMETRIC, 60, 0)
	DllCall("gdi32\GetTextMetrics", Ptr,hDC, Ptr,&TEXTMETRIC)
	DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFontOld, Ptr)
	DllCall("user32\ReleaseDC", Ptr,0, Ptr,hDC)
	return NumGet(TEXTMETRIC, 20, "Int") ;tmAveCharWidth
}

;==================================================