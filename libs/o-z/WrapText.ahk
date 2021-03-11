;*****************************************************************************************************************************
;	TEXT WRAP FUNCTIONS BY <DigiDon>		https://autohotkey.com/boards/viewtopic.php?f=6&t=32406
;*****************************************************************************************************************************

/*                                               EXAMPLE
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force

msgbox text by width
;The text that might not wrap correclty
BottomText:= "D:\EverFastAccess\DEV ENV\4.26\Notebooks\MySpace\Software\Soft_.Notepad++-.D--EverFastAccess-DEV ENV-4.25-Lib-InteractiveTutorials_Fct.ahk - Notepad++.rtf"
wFont:="S10,Verdana" ; is the intended font ; Pass "" if approx default (size 10 MS Sans Sherif)
wWidth:=410 ;400 is the intended width
Gui, Font, %wFont% ;Set the font
Gui, Add, Text, xm w430 +Center,  % WrapText_ByWidth(BottomText,wWidth,wFont) ;Display the text that will automatically be wrapped
Gui, Show
;*****************************
msgbox test by len
Gui,Destroy
;The text that might not wrap correclty
BottomText:= "D:\EverFastAccess\DEV ENV\4.26\Notebooks\MySpace\Software\Soft_.Notepad++-.D--EverFastAccess-DEV ENV-4.25-Lib-InteractiveTutorials_Fct.ahk - Notepad++.rtf"
Gui, Font, s10 Verdana
Gui, Add, Text, xm w430 +Center, % WrapText_ByLen(BottomText,53) ;53 chars max by lines
Gui, Show
return

Esc::ExitApp


*/


WrapText_ByWidth(TextToWrap,P_MaxWidth,P_Font="",P_Delim="[]/\.-_") {
;we round the LengthLim
LengthLim:=Round(LengthLim)
;if P_MaxLen too small or TextToWrap<P_MaxLen we return the original text
;if no specific delimiters were specified we assign the default ones
P_Delim:= RegExReplace(P_Delim, "[\^\-\]\\]", "\$0")
TextSize:=GetTextSize(TextToWrap,P_Font)
; msgbox TextSize %TextSize%
	if !TextSize
		return TextToWrap
TextSplitLen:=Round(P_MaxWidth/TextSize*StrLen(TextToWrap))
; msgbox TextSplitLen %TextSplitLen%
return WrapText_ByLen(TextToWrap,TextSplitLen,P_Delim)
}

WrapText_ByLen(TextToWrap,LengthLim,P_Delim="[]/\.-_") {
;we round the LengthLim
LengthLim:=Round(LengthLim)
;if LengthLim too small or TextToWrap<LengthLim we return the original text
if LengthLim<1
	return TextToWrap
if (StrLen(TextToWrap)<LengthLim)
	return TextToWrap
;if no specific delimiters were specified we assign the default ones
P_RegexDelim:= "[" RegExReplace(P_Delim, "[\[\]\\\/\.\-\_]", "\$0") "]"
CurrPos:=1
TextToWrapNew:=TextToWrap
; msgbox % "text is of size " StrLen(TextToWrapNew))
	While (StrLen(SubStr(TextToWrapNew,CurrPos))>LengthLim) {

		; msgbox current pos CurrPos %CurrPos%
		; msgbox % StrLen(SubStr(TextToWrapNew,CurrPos)) " char remaining"
		TempFoundPos:=regexmatch(TextToWrapNew,"\s",,CurrPos)
		FoundPos:=0
		while (TempFoundPos and TempFoundPos<=LengthLim) {
			FoundPos:=TempFoundPos
			CurrPos:=FoundPos+1
			TempFoundPos:=regexmatch(TextToWrapNew,"\s",,CurrPos)
			}
		if (FoundPos) {
			; msgbox found space at pos %FoundPos%
			TextToWrapNew:=SubStr(TextToWrapNew,1,FoundPos-1) "`n" SubStr(TextToWrapNew,FoundPos+1)
			continue
			}
		; msgbox no space found try delim
		TempFoundPos:=regexmatch(TextToWrapNew,P_RegexDelim,,CurrPos)
		FoundPos:=0
		while (TempFoundPos and TempFoundPos<=LengthLim) {
			FoundPos:=TempFoundPos
			CurrPos:=FoundPos+1
			TempFoundPos:=regexmatch(TextToWrapNew,P_RegexDelim,,CurrPos)
		}
		if (FoundPos) {
			; msgbox found delim at pos %FoundPos% LengthLim %LengthLim% CurrPos %CurrPos%
			TextToWrapNew:=SubStr(TextToWrapNew,1,FoundPos) "`n" SubStr(TextToWrapNew,FoundPos+1)
			continue
		}
		; else
		; msgbox % "no delim neither split text at pos " LengthLim
		TextToWrapNew:=SubStr(TextToWrapNew,1,CurrPos+LengthLim) "`n" SubStr(TextToWrapNew,CurrPos+LengthLim+1)
		CurrPos+=LengthLim
	}
	return TextToWrapNew
}

WrapText_Force(TextToWrap,LengthLim,delims="") {

	; DESCRIPTION
	;Returns a new wrapped text variables
	;delimiters can be specified in delims array parameters, or will be ["[","/","\",A_Space,A_Tab,".","-","_"] by default


;we round the LengthLim
LengthLim:=Round(LengthLim)
;if LengthLim too small or TextToWrap<LengthLim we return the original text
if LengthLim<1
	return TextToWrap
if (TextToWrap<LengthLim)
	return TextToWrap
;if no specific delimiters were specified we assign the default ones
if !isObject(delims)
		{
		delims:=["[","/","\",A_Space,A_Tab,".","-","_"]
		}
TextToWrap_Arr:=[]
TextWrapedFinal:=""
;the next 2 lines will split TextToWrap along with the current lines it contains
stringreplace,TextToWrap,TextToWrap,`r,,all
StringSplit, TextToWrap_Arr, TextToWrap, `n
;we loop through each lines to wrap them
Loop, %TextToWrap_Arr0%
	{
	;the current line is assigned to TextToWrap
	TextToWrap:=TextToWrap_Arr%A_Index%
	count:=1, TextWraped:="", TextWraped_Arr:=[], LengthLimVar="", Delim_Pos_Arr:=[]
	if (count=1)
		{
		;if the line is already <LengthLim we put it as it is in the TextWrapedFinal string
		if (StrLen(TextToWrap)<LengthLim)
			{
			TextWrapedFinal .= TextWraped . "`n"
			continue
			}
		;otherwise we put it in the TextWraped_Arr
		TextWraped_Arr[count]:=TextToWrap
		}
	;we start wrapping
	WrapText_Force_Recurse:
	loop 1
		{
		;if the current TextWraped_Arr<LengthLim we build the TextWraped and we break the loop
		;to append the current wrapped part to the TextWrapedFinal var and continue to next line
		Text_StrLen := StrLen(TextWraped_Arr[count])
		if (Text_StrLen<LengthLim)
			{
			loop % TextWraped_Arr.MaxIndex()
				{
				TextWraped.=TextWraped_Arr[A_Index]
				}
			break
			}
		;Otherwise
		;[OPTIONAL - can be replaced by] LengthLimVar:=LengthLim
		;We Check if the current part is at least >1.5*LengthLim, otherwise we assign a new LengthLim of LengthLim//2
		if (Text_StrLen<(LengthLim*1.5))
			LengthLimVar:=LengthLim//2
		else
			LengthLimVar:=LengthLim

		;we look in the current remaining part the positions of delimiters until LengthLim
		PartToLookDelim:=SubStr(TextWraped_Arr[count], 1, LengthLimVar)
		for index,delim in delims
			{
			Delim_Pos_Arr[index]:=InStr(PartToLookDelim, delim,,0)
			}

		;We get the farest delimiter pos into Delim_Pos
		Delim_Pos:=0
		for k,v in Delim_Pos_Arr
			if (v > Delim_Pos)
				Delim_Pos := v

		;if no delimiter was found or its position is not close enough to the intended Length (set to 90%)
		if (Delim_Pos=0 or Delim_Pos<(LengthLimVar*0.9))
			{
			;We split the Current part to LengthLimVar and we assign the rest to the next part
			TextWraped_Arr[count+1]:=SubStr(TextWraped_Arr[count], LengthLimVar)
			TextWraped_Arr[count]:=SubStr(TextWraped_Arr[count], 1 , LengthLimVar - 1) . "`n"
			}
		;If a delimiter was found close enough to the intended Length
		Else
			{
			;We split the Current part to LengthLimVar and we assign the rest to the next part
			TextWraped_Arr[count+1]:=SubStr(TextWraped_Arr[count], Delim_Pos+1)
			TextWraped_Arr[count]:=SubStr(TextWraped_Arr[count], 1, Delim_Pos)
			if (SubStr(TextWraped_Arr[count], 0 , 1)!=" ")
				TextWraped_Arr[count].="`n"
			}
		;In both cases we then restart the WrapText_Force_Recurse Label with he next part
		count++
		GoTo WrapText_Force_Recurse
		}
	;When we have finished wrapping a line we add the TextWraped to the TextWrapedFinal, including its original new line char
	TextWrapedFinal .= TextWraped . "`n"
	}
;When we have finished with all lines we can delete the last new line char
if (SubStr(TextWrapedFinal, -1 , 2)="`n")
	TextWrapedFinal:=SubStr(TextWrapedFinal, 1 , -2)
	;And we return the TextWrapedFinal
	return TextWrapedFinal
}


;********* depending functions from majkinetor
GetTextSize(pStr, pFont="", pHeight=false, pAdd=0) {
	local height, weight, italic, underline, strikeout , nCharSet
	local hdc := DllCall("GetDC", "Uint", 0)
	local hFont, hOldFont
	local resW, resH, SIZE

 ;parse font
	italic		:= InStr(pFont, "italic")	 ?  1	:  0
	underline	:= InStr(pFont, "underline") ?  1	:  0
	strikeout	:= InStr(pFont, "strikeout") ?  1	:  0
	weight		:= InStr(pFont, "bold")		 ? 700	: 400

	;height
	RegExMatch(pFont, "(?<=[S|s])(\d{1,2})(?=[ ,])", height)
	if (height = "")
		height := 10


	RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels
	Height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72)
	;face
	RegExMatch(pFont, "(?<=,).+", fontFace)
	if (fontFace != "")
		 fontFace := RegExReplace( fontFace, "(^\s*)|(\s*$)")		;trim
	else fontFace := "MS Sans Serif"

 ;create font
	hFont	:= DllCall("CreateFont", "int",  height,	"int",  0,		  "int",  0, "int", 0
									,"int",  weight,	"Uint", italic,   "Uint", underline
									,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontFace)
	hOldFont := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

	VarSetCapacity(SIZE, 16)
	curW=0
	Loop,  parse, pStr, `n
	{
		DllCall("DrawTextA", "Uint", hDC, "str", A_LoopField, "int", StrLen(pStr), "uint", &SIZE, "uint", 0x400)
		resW := ExtractInteger(SIZE, 8)
		curW := resW > curW ? resW : curW
	}
	DllCall("DrawTextA", "Uint", hDC, "str", pStr, "int", StrLen(pStr), "uint", &SIZE, "uint", 0x400)
 ;clean

	DllCall("SelectObject", "Uint", hDC, "Uint", hOldFont)
	DllCall("DeleteObject", "Uint", hFont)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

	resW := ExtractInteger(SIZE, 8) + pAdd
  	resH := ExtractInteger(SIZE, 12) + pAdd


	if (pHeight)
		resW = W%resW% H%resH%

	return	%resW%
}

ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4) {
    Loop %pSize%
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
        return result
    return -(0xFFFFFFFF - result + 1)
}