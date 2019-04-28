;--------------------------------------------------------------------------
; Function:  CreateFont
;			 Creates font in memory which can be used with any API function accepting font handles.
;
; Parameters: 
;			pFont	- AHK font description, "style, face"
;
; Returns:
;			Font handle
;
; Example:
;>			hFont := CreateFont("s12 italic, Courier New")
;>			SendMessage, 0x30, %hFont%, 1,, ahk_id %hGuiControl%  ;WM_SETFONT = 0x30

CreateFont(pFont="") {

	;parse font 
	italic      := InStr(pFont, "italic")    ?  1    :  0 
	underline   := InStr(pFont, "underline") ?  1    :  0 
	strikeout   := InStr(pFont, "strikeout") ?  1    :  0 
	weight      := InStr(pFont, "bold")      ? 700   : 400 

	;height 
	RegExMatch(pFont, "(?<=[S|s])(\d{1,2})(?=[ ,])", height)
	if (height = "")
	  height := 10
	RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels
	height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72)

	;face 
	RegExMatch(pFont, "(?<=,).+", fontFace)
	if (fontFace != "")
	   fontFace := RegExReplace( fontFace, "(^\s*)|(\s*$)")      ;trim
	else fontFace := "MS Sans Serif"

	;create font
	hFont   := DllCall("CreateFont", "int",  height, "int",  0, "int",  0, "int", 0
					  ,"int",  weight,   "Uint", italic,   "Uint", underline
					  ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontFace)

	return hFont
}