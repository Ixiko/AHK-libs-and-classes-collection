/* Title:	Font
			Font functions.
 */

/*
 Function:  Font
			Creates the font and optinally, sets it for the control.

 Parameters:
			hCtrl - Handle of the control. If omitted, function will create font and return its handle.
			Font  - AHK font defintion ("s10 italic, Courier New"). If you already have created font, pass its handle here.
			bRedraw	  - If this parameter is TRUE, the control redraws itself. By default 1.

 Returns:	
			Font handle.
 */
Font(HCtrl="", Font="", BRedraw=1) {
	static WM_SETFONT := 0x30
	
	if Font is not integer
	{
		StringSplit, Font, Font, `,,%A_Space%%A_Tab%
		fontStyle := Font1, fontFace := Font2

	  ;parse font 
		italic      := InStr(Font1, "italic")    ?  1    :  0 
		underline   := InStr(Font1, "underline") ?  1    :  0 
		strikeout   := InStr(Font1, "strikeout") ?  1    :  0 
		weight      := InStr(Font1, "bold")      ? 700   : 400 

	  ;height 

		RegExMatch(Font1, "(?<=[S|s])(\d{1,2})(?=[ ,]*)", height) 
		ifEqual, height,, SetEnv, height, 10
		RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels 
		height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72) 
	
		IfEqual, Font2,,SetEnv Font2, MS Sans Serif
	 ;create font 
		hFont   := DllCall("CreateFont", "int",  height, "int",  0, "int",  0, "int", 0
						  ,"int",  weight,   "Uint", italic,   "Uint", underline 
						  ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", Font2, "Uint")
	} else hFont := Font
	ifNotEqual, HCtrl,,SendMessage, WM_SETFONT, hFont, BRedraw,,ahk_id %HCtrl%
	return hFont
}

/*
 Function: DrawText
		   Draws text using specified font on device context or calculates width and height of the text.

 Parameters: 
		Text	- Text to be drawn or measured. 
		DC		- Device context to use. If omitted, function will use Desktop's DC.
		Font	- If string, font description in AHK syntax. If number, font handle. If omitted, uses the system font to calculate text metrics.
		Flags	- Drawing/Calculating flags. Space separated combination of flag names. For the description of the flags see <http://msdn.microsoft.com/en-us/library/ms901121.aspx>.
		Rect	- Bounding rectangle. Space separated list of left,top,right,bottom coordinates. 
				  Width could also be used with CALCRECT WORDBREAK style to calculate word-wrapped height of the text given its width.
				
 Flags:
		CALCRECT, BOTTOM, CALCRECT, CENTER, VCENTER, TABSTOP, SINGLELINE, RIGHT, NOPREFIX, NOCLIP, INTERNAL, EXPANDTABS, AHKSIZE.

 Returns:
		Decimal number. Width "." Height of text. If AHKSIZE flag is set, the size will be returned as w%w% h%h%

 */    
Font_DrawText(Text, DC="", Font="", Flags="", Rect="") {
	static DT_AHKSIZE=0, DT_CALCRECT=0x400, DT_WORDBREAK=0x10, DT_BOTTOM=0x8, DT_CALCRECT=0x400, DT_CENTER=0x1, DT_VCENTER=0x4, DT_TABSTOP=0x80, DT_SINGLELINE=0x20, DT_RIGHT=0x2, DT_NOPREFIX=0x800, DT_NOCLIP=0x100, DT_INTERNAL=0x1000, DT_EXPANDTABS=0x40

	hFlag := (Rect = "") ? DT_NOCLIP : 0

	StringSplit, Rect, Rect, %A_Space%
	loop, parse, Flags, %A_Space%
		ifEqual, A_LoopField,,continue
		else hFlag |= DT_%A_LoopField%

	if Font is integer
		hFont := Font, bUserHandle := 1
	else if (Font != "")
		hFont := Font( "", Font) 
	else hFlag |= DT_INTERNAL

	IfEqual, hDC,,SetEnv, hDC, % DllCall("GetDC", "Uint", 0, "Uint")
	ifNotEqual, hFont,, SetEnv, hOldFont, % DllCall("SelectObject", "Uint", hDC, "Uint", hFont)

	VarSetCapacity(RECT, 16)
	if (Rect0 != 0)
		loop, 4
			NumPut(Rect%A_Index%, RECT, (A_Index-1)*4)

	h := DllCall("DrawTextA", "Uint", hDC, "Str", Text, "int", StrLen(Text), "uint", &RECT, "uint", hFlag)

  ;clean
   	ifNotEqual, hOldFont,,DllCall("SelectObject", "Uint", hDC, "Uint", hOldFont) 
	ifNotEqual, bUserHandle, 1, DllCall("DeleteObject", "Uint", hFont)
	ifNotEqual, DC,,DllCall("ReleaseDC", "Uint", 0, "Uint", hDC) 

	return InStr(Flags, "AHKSIZE") ? "w" NumGet(RECT, 8) " h" h : NumGet(RECT, 8) "." h
} 

/* Group: About
	o Version 1.0 by majkinetor.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
 */