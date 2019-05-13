/* Title:		RichEdit

				This module allows you to create and programmatically set text properties in rich edit control.
				Besides that, it contains functions that work with standard edit controls. Each function contains
				description for which kind of control it can be used - any control supporting edit control interface
				(Edit, RichEdit, HiEdit...) or just rich edit control.
 */

/*
 Function:		Add
				Create rich edit version 4.1 control. (requires at least Windows XP SP1)

 Parameters:
				HParent	- Handle of the parent of the control.
				X..H	- Position.
				Style	- White space separated list of control styles. Any integer style or one of the style keywords (see below).
						  Invalid styles are skipped. "*MULTILINE WANTRETURN VSCROLL*" by default.
				Text	- Control text.
 Styles:
     DISABLENOSCROLL - Disables scroll bars instead of hiding them when they are not needed.
     BORDER			- Displays the control with a sunken border style so that the rich edit control appears recessed into its parent window.
     HIDDEN			- Don't show the control.
     VSCROLL		- Enble vertical scroll bar.
     HSCROLL		- Enable horizontal scroll bar. If this style is present control starts with wrap mode deactivated. Otherwise, wrap mode is active.
     SCROLL			- Enable both scroll bars.
     AUTOHSCROLL	- Automatically scrolls text to the right by 10 characters when the user types a character at the end of the line. When the user presses the ENTER key, the control scrolls all text back to position zero.
     AUTOVSCROLL	- Automatically scrolls text up one page when the user presses the ENTER key on the last line.
     CENTER			- Centers text in a single-line or multiline edit control.
     LEFT			- Left aligns text.
     MULTILINE		- Designates a multiline edit control. The default is single-line edit control.
     NOHIDESEL		- Negates the default behavior for an edit control. The default behavior hides the selection when the control loses the input focus and inverts the selection when the control receives the input focus. If you specify *NOHIDESEL*, the selected text is inverted, even if the control does not have the focus.
     NUMBER			- Allows only digits to be entered into the edit control.
     PASSWORD		- Displays an asterisk (*) for each character typed into the edit control. This style is valid only for single-line edit controls.
     READONLY		- Prevents the user from typing or editing text in the edit control.
     RIGHT			- Right aligns text in a single-line or multiline edit control.
     SELECTIONBAR	- When set, there is small left margin (wider than default) where cursor changes to right-up arrow allowing full line(s) selection. This style also requires use of *MULTILINE* style.
     WANTRETURN		- Specifies that a carriage return be inserted when the user presses the ENTER key while entering text into a multiline edit control in a dialog box. If you do not specify this style, pressing the ENTER key has the same effect as pressing the dialog box's default push button. This style has no effect on a single-line edit control.

 Returns:
	Control's handle or 0. Error message on problem.

 Example:
 (start code)
  Gui, +LastFound
  hwnd := WinExist()
  hRichEdit := RichEdit_Add(hwnd, 5, 5, 200, 300)
  Gui, Show, w210 h310
 (end code)
 */
RichEdit_Add(HParent, X="", Y="", W="", H="", Style="", Text="")  {
  static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
		,ES_DISABLENOSCROLL=0x2000, EX_BORDER=0x200
		,ES_LEFT=0, ES_CENTER=1, ES_RIGHT=2, ES_MULTILINE=4, ES_AUTOVSCROLL=0x40, ES_AUTOHSCROLL=0x80, ES_NOHIDESEL=0x100, ES_NUMBER=0x2000, ES_PASSWORD=0x20,ES_READONLY=0x800,ES_WANTRETURN=0x1000  ;, ES_SELECTIONBAR = 0x1000000
		,ES_HSCROLL=0x100000, ES_VSCROLL=0x200000, ES_SCROLL=0x300000
		,MODULEID

	if !MODULEID
		init := DllCall("LoadLibrary", "Str", "Msftedit.dll", "Uint"), MODULEID := 091009


	ifEqual, Style,, SetEnv, Style, MULTILINE WANTRETURN VSCROLL
	hStyle := InStr(" " Style " ", " hidden ") ? 0 : WS_VISIBLE,  hExStyle := 0
	Loop, parse, Style, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, ,continue
		else if A_LoopField is integer
			 hStyle |= A_LoopField
		else if (v := ES_%A_LOOPFIELD%)
			 hStyle |= v
		else if (v := EX_%A_LOOPFIELD%)
			 hExStyle |= v
		else if (A_LoopField = "SELECTIONBAR")
       selectionbar := true
		else continue
	}
	/*
		class   := A_OSVersion = "WIN_95" ? "RICHEDIT" : "RichEdit20A"
		hModule := DllCall("LoadLibrary", "str",  (class="RichEdit20A" ? "riched20.dll" : "riched32.dll")  )

		http://www.soulfree.net/tag/391
		RE version - DLL (hModule)- class
		1.0	       - Riched32.dll - RichEdit
		2.0	       - Riched20.dll - RichEdit20A or RichEdit20W (ANSI or Unicode window classes)
		3.0	       - Riched20.dll - ?
		4.1	       - Msftedit.dll - RICHEDIT50W

		2.0 not compatible w/ EM_CONVPOSITION, EM_GETIMECOLOR, EM_GETIMEOPTIONS, EM_GETPUNCTUATION,
		  EM_GETWORDWRAPMODE, EM_SETIMECOLOR, EM_SETIMEOPTIONS, EM_SETPUNCTUATION, EM_SETWORDWRAPMODE

		Windows XP SP1	Includes Rich Edit 4.1, Rich Edit 3.0, and a Rich Edit 1.0 emulator.
		Windows XP	Includes Rich Edit 3.0 with a Rich Edit 1.0 emulator.
		Windows Me	Includes Rich Edit 1.0 and 3.0.
		Windows 2000	Includes Rich Edit 3.0 with a Rich Edit 1.0 emulator.
		Windows NT 4.0	Includes Rich Edit 1.0 and 2.0.
		Windows 98	Includes Rich Edit 1.0 and 2.0.
		Windows 95	Includes only Rich Edit 1.0. However, Riched20.dll is compatible with Windows 95 and may be installed by an application that requires it.
     */

	hCtrl := DllCall("CreateWindowEx"
                  , "Uint", hExStyle			; ExStyle
                  , "str" , "RICHEDIT50W"		; ClassName
                  , "str" , Text				; WindowName
                  , "Uint", WS_CHILD | hStyle	; Edit Style
                  , "int" , X					; Left
                  , "int" , Y					; Top
                  , "int" , W					; Width
                  , "int" , H					; Height
                  , "Uint", HParent				; hWndParent
                  , "Uint", MODULEID			; hMenu
                  , "Uint", 0					; hInstance
                  , "Uint", 0, "Uint")			; must return uint.
	return hCtrl,  selectionbar ? RichEdit_SetOptions( hCtrl, "OR", "SELECTIONBAR" ) : ""
}

/*
  Function:  AutoUrlDetect
 			 Enable, disable, or toggle automatic detection of URLs in the RichEdit control.

  Parameters:
 			Flag - Specify true to enable automatic URL detection or false to disable it. Specify
             *"^"* to toggle its current state. Omit to only return current state without any change.

  Returns:
 			If auto-URL detection is active, the return value is 1.
 			If auto-URL detection is inactive, the return value is 0.

 Example:
 (start code)
  MsgBox, % RichEdit_AutoUrlDetect( hRichEdit, true )
  MsgBox, % RichEdit_AutoUrlDetect( hRichEdit, "^" )
  MsgBox, % "Current state: " RichEdit_AutoUrlDetect( hRichEdit )
 (end code)
 */
RichEdit_AutoUrlDetect(HCtrl, Flag="" )  {	;wParam Specify TRUE to enable automatic URL detection or FALSE to disable it.
	static EM_AUTOURLDETECT=0x45B, EM_GETAUTOURLDETECT=0x45C

	If (Flag = "") || (Flag ="^") {
		SendMessage, EM_GETAUTOURLDETECT,,,,ahk_id %HCtrl%
		ifEqual, Flag,, return ERRORLEVEL
		Flag := !ERRORLEVEL
	}
	SendMessage, EM_AUTOURLDETECT, Flag,,, ahk_id %HCtrl%
	return Flag
}

/*
 Function: CanPaste
           Determines whether an Edit control can paste a specified clipboard format.

 Parameters:
           ClipboardFormat - Specifies the Clipboard Formats to try. To try any format currently on the clipboard, set this parameter to zero.
							 The default is 0x1 (CF_TEXT).

 Returns:
           True if the clipboard format can be pasted otherwise false.

 Remarks:
           For additional information on clipboard formats, see the following:
           <http://msdn.microsoft.com/en-us/library/ms649013(VS.85).aspx>

 Related:
		<Paste>, <PasteSpecial>

 Example:
 (start code)
  If RichEdit_CanPaste( hRichEdit, 0 )
    RichEdit_Paste( hRichEdit )
  Else
    MsgBox, Cannot paste your clipboard into control..
 (end code)
 */
RichEdit_CanPaste(hEdit, ClipboardFormat=0x1) {
    Static EM_CANPASTE := 1074
    SendMessage EM_CANPASTE,ClipboardFormat,0,,ahk_id %hEdit%
    return ErrorLevel
}

/*
 Function: CharFromPos
           Gets information about the character closest to a specified point in the client area of the Edit control.

 Parameters:
           X, Y - The coordinates of a point in the Edit control's client area relative to the upper-left corner of the client area.

 Returns:
           The character index of the specified point or the character index to
           the last character if the given point is beyond the last character in the control.
 */
RichEdit_CharFromPos(hEdit,X,Y) {
    Static EM_CHARFROMPOS:=0xD7

	WinGetClass, cls, ahk_id %hEdit%
	if cls in RICHEDIT50W
		 VarSetCapacity(POINTL, 8), lParam := &POINTL, NumPut(X, POINTL), NumPut(Y,POINTL)
	else lParam := (Y<<16)|X

    SendMessage EM_CHARFROMPOS,,lParam,,ahk_id %hEdit%
    return ErrorLevel
}

/*
 Function:	Clear
    Send to an Edit control or combo box to delete (clear) the current selection.

 Remarks:
    To delete the current selection and place the deleted content on the clipboard, use the Cut operation.
			
 Related:
    <Cut>, <Copy>, <Paste>
 */
RichEdit_Clear(hEdit) {
    static WM_CLEAR=0x303
    SendMessage WM_CLEAR,,,,ahk_id %hEdit%
}

/*
 Function:		Convert
				Convert twips to pixels or vice-versa.

 Parameters:
				Input		- Twips (Input>0) or pixels (Input<0).
				Direction	- 0 (default) or 1. Pixels are not always square (the height and width are not the same).
							  Therefore, it is necessary to pass in the desired "direction" to use, horizontal (0) or vertical (1).
 Returns:
				Rounded value.
 */
RichEdit_Convert(Input, Direction=0) {
	static twipsPerInch = 1440, LOGPIXELSX=88, LOGPIXELSY=90, tpi0, tpi1

	if !tpi0
		dc := DllCall("GetDC", "uint", 0, "Uint")
		, tpi0 := DllCall("gdi32.dll\GetDeviceCaps", "uint", dc, "int", LOGPIXELSX)
		, tpi1 := DllCall("gdi32.dll\GetDeviceCaps", "uint", dc, "int", LOGPIXELSY)
		, DllCall("ReleaseDC", "uint", 0, "uint", dc)

   return (Input>0) ? (Input * tpi%Direction%) // twipsPerInch  : (-Input*twipsPerInch) // tpi%Direction%
}

/*
 Function: Copy
    Copy selection of the Edit control.

 Related:
		<Cut>, <Clear>, <Paste>
 */
RichEdit_Copy(hEdit) {
    Static WM_COPY:=0x301
    SendMessage WM_COPY,0,0,,ahk_id %hEdit%
}

/*
 Function: Cut
    Cut selection from the Edit control.

 Related:
    <Copy>, <Clear>, <Paste>
 */
RichEdit_Cut(hEdit) {
    Static WM_CUT:=0x300
    SendMessage WM_CUT,,,,ahk_id %hEdit%
}

/*
 Function:	FindText
			Find desired text in the Edit control.

 Parameters:
			Text	- Text to be searched for.
			CpMin	- Start searching at this character position. By default 0.
			CpMax	- End searching at this character position. When searching forward, a value of –1 extends the search range to the end of the text.
			Flags	- Space separated combination of search flags. See below.

 Flags:
			WHOLEWORD	- If set, the operation searches only for whole words that match the search string. If not set, the operation also searches for word fragments that match the search string.
			MATCHCASE	- If set, the search operation is case-sensitive. If not set, the search operation is case-insensitive.
			DOWN		- Rich Edit only: If set, the search is from the end of the current selection to the end of the document.
						  If not set, the search is from the end of the current selection to the beginning of the document.
			UNICODE		- Transforms Text into the Unicode charset before searching for it.
 Returns:
			The zero-based character position of the next match, or -1 if there are no more matches.

 Remarks
			The *CpMin* member always specifies the starting-point of the search, and *CpMax* specifies the end point.
			When searching backward, *CpMin* must be equal to or greater than *CpMax*.

 Example:
 (start code)
  ^f::
    RichEdit_HideSelection( hRichEdit, false )
    Dlg_Find( hwnd, "OnFind", "d" )
  return

  OnFind(Event, Flags, FindText, ReplaceText)  {
    global hRichEdit

    IfNotEqual, Event, F,  return
    RichEdit_GetSel(hRichEdit, min, max)
    word := InStr(Flags,"w") ? " WHOLEWORD" : ""
    case := InStr(Flags,"c") ? " MATCHCASE" : ""
    InStr( Flags, "d" ) ? (pos:=max+1 , direction:=" DOWN")
                        : (pos:=max-1)

    ; search control for word
    pos:=RichEdit_FindText(hRichEdit,FindText,pos,-1,"unicode" direction word case)

    ; highlight found match
  	if pos != -1
  		RichEdit_SetSel(hRichEdit, pos, pos+StrLen(FindText))

  	Else
      MsgBox, no matches found..
  }
  return
 (end code)
 */
RichEdit_FindText(hEdit, Text, CpMin=0, CpMax=-1, Flags="UNICODE") {
	static EM_FINDTEXT=1080, FR_DOWN=1, FR_WHOLEWORD=2, FR_MATCHCASE=4, FR_UNICODE=0
	hFlags := 0
	loop, parse, Flags, %A_Tab%%A_Space%,
		ifEqual, A_LoopField,,continue
		else hFlags |= FR_%A_LOOPFIELD%

	If InStr(Flags, "Unicode") {
		VarSetCapacity( uText, (len:=StrLen(Text))*2+1), DllCall( "MultiByteToWideChar", "Int",0,"Int",0,"Str",Text,"UInt",len,"Str", uText, "UInt", len )
		txtAdr := &uText
	} else txtAdr := &Text

	VarSetCapacity(FT, 12)
	NumPut(CpMin,   FT, 0)
	NumPut(CpMax,   FT, 4)
	NumPut(txtAdr,  FT, 8)

	SendMessage, EM_FINDTEXT, hFlags, &FT,, ahk_id %hEdit%
	Return ErrorLevel=4294967295 ? -1 : ErrorLevel
}

/*
 Function:	FindWordBreak
			Finds the next word break in rich edit conttrol, before or after the specified character position or retrieves information about the character at that position.

 Parameters:
		    CharIndex	- Zero-based character starting position.
			Flag		- One of the flags list below.

 Flag:
			CLASSIFY	- Returns the character class and word-break flags of the character at the specified position.
			ISDELIMITER - Returns true if the character at the specified position is a delimiter, or false otherwise.
			LEFT		- Finds the nearest character before the specified position that begins a word.
			LEFTBREAK	- Finds the next word end before the specified position. This value is the same as PREVBREAK.
			MOVEWORDLEFT  - Finds the next character that begins a word before the specified position. This value is used during CTRL+LEFT ARROW key processing.
			MOVEWORDRIGHT - Finds the next character that begins a word after the specified position. This value is used during CTRL+right key processing.
			RIGHT		- Finds the next character that begins a word after the specified position.
			RIGHTBREAK	- Finds the next end-of-word delimiter after the specified position. This value is the same as NEXTBREAK.

 Returns:
		  The message returns a value based on the wParam parameter.
			o CLASSIFY		- Returns the character class and word-break flags of the character at the specified position.
			o ISDELIMITER	- Returns true if the character at the specified position is a delimiter, otherwise it returns false.
			o Other			- Returns the character index of the word break.
 */
RichEdit_FindWordBreak(hCtrl, CharIndex, Flag="")  {
	static  EM_FINDWORDBREAK=1100
			, WB_CLASSIFY=3, WB_ISDELIMITER=2, WB_LEFT=0, WB_LEFTBREAK=6, WB_MOVEWORDLEFT=4, WB_MOVEWORDNEXT=5, WB_MOVEWORDPREV=4, WB_MOVEWORDRIGHT=5, WB_NEXTBREAK=7, WB_PREVBREAK=6, WB_RIGHT=1, WB_RIGHTBREAK=7

	SendMessage, EM_FINDWORDBREAK, WB_%Flag%, CharIndex,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
 Function: FixKeys
	  	   Fix Tab and Esc key handling in rich edit control.

 Returns:
		  True or false.

 Remarks:
	Whenever you press Escape in a multiline edit control it sends a WM_CLOSE message to its parent. Both the regular edit control and the rich edit control have this problem.
	This is by Microsoft design. There is also similar undesired behavior for {Tab} key which is used by the system to navigate over controls with "tabstop" flag. RichEdit is designed
	to use ^{Tab} instead. This function subclasses the control to prevent such behavior.

	However, before using this function be sure to know what subclassing is and what kind of effects
	it may introduce to your particular script. There is also other method to solve this problem via
	hotkey handling while rich edit control has focus.

 Reference:
	o WM_GETDLGCODE @ MSDN: <http://msdn.microsoft.com/en-us/library/ms645425(VS.85).aspx>
	o William Willing blog: <http://www.williamwilling.com/blog/?p=28>.
	o WinAsm Forum: <http://www.winasm.net/forum/index.php?showtopic=487>.
	o CodeGuru: <http://www.codeguru.com/cpp/controls/editctrl/keyboard/article.php/c513/>.
	o Strange Microsoft solution for VB (that doesn't work): <http://support.microsoft.com/kb/q143273/>.
 */
RichEdit_FixKeys(hCtrl) {
	oldProc := DllCall("GetWindowLong", "uint", hCtrl, "uint", -4)
	ifEqual, oldProc, 0, return 0
	wndProc := RegisterCallback("RichEdit_wndProc", "", 4, oldProc)
	ifEqual, wndProc, , return 0
	return DllCall("SetWindowLong", "UInt", hCtrl, "Int", -4, "Int", wndProc, "UInt")
}

/*
 Function: GetLine
			Get the text of the desired line from an Edit control.

 Parameters:
			LineNumber	- Zero-based index of the line. -1 means current line.

 Returns:
			The return value is the text.
			The return value is empty string if the line number specified by the line parameter is greater than the number of lines in the Edit control.

 Related:
     <GetText>, <LineIndex>, <LineLength>
 */
RichEdit_GetLine(hEdit, LineNumber=-1){
	static EM_GETLINE=196	  ;The return value is the number of characters copied. The return value is zero if the line number specified by the line parameter is greater than the number of lines in the HiEdit control

	if (LineNumber = -1)
		LineNumber := RichEdit_LineFromChar(hEdit, RichEdit_LineIndex(hEdit))
	len := RichEdit_LineLength(hEdit, LineNumber)
	ifEqual, len, 0, return

	VarSetCapacity(txt, len, 0), NumPut(len = 1 ? 2 : len, txt)		; HiEdit bug! if line contains only 1 word SendMessage returns FAIL.
	SendMessage, EM_GETLINE, LineNumber, &txt,, ahk_id %hEdit%
	if ErrorLevel = FAIL
		return "", ErrorLevel := A_ThisFunc "> Failed to get line with code: " A_LastError

	VarSetCapacity(txt, -1)
	return len = 1 ? SubStr(txt, 1, -1) : txt
}

/*
 Function:	GetLineCount
			Gets the number of lines in a multiline Edit control.

 Returns:
			The return value is an integer specifying the total number of text lines in the multiline edit control or rich edit control.
			If the control has no text, the return value is 1. The return value will never be less than 1.

 Remarks:
			The function retrieves the total number of text lines, not just the number of lines that are currently visible.
			If the Wordwrap feature is enabled, the number of lines can change when the dimensions of the editing window change.

 Related:
     <GetTextLength>, <LineLength>
 */
RichEdit_GetLineCount(hEdit){
	static EM_GETLINECOUNT=0xBA
 	SendMessage, EM_GETLINECOUNT,,,, ahk_id %hEdit%
	Return ErrorLevel
}

/*
 Function:	GetOptions
			Get the options for a rich edit control.

 Remarks:
			See <SetOptions> for details.
 */
RichEdit_GetOptions(hCtrl)  {
	static  EM_GETOPTIONS=1102
			,1="AUTOWORDSELECTION", 64="AUTOVSCROLL", 128="AUTOHSCROLL",  256="NOHIDESEL", 2048="READONLY", 4096="WANTRETURN", 16777216="SELECTIONBAR"
			,options="1,64,128,256,2048,4096,16777216"

	if (hCtrl > 1) {
		SendMessage, EM_GETOPTIONS,,,, ahk_id %hCtrl%
		o := ErrorLevel
	} else o := SubStr(hCtrl, 2)

	loop, parse, options, `,
		if (o & A_LoopField)
			res .= %A_LoopField% " "

	return SubStr(res, 1, -1)
}

/*
 Function:	GetCharFormat
			Determines the character formatting in a rich edit control.

 Parameters:
			Face	- Optional byref parameter will contain the name of the font.
			Style	- Optional byref parameter will contain a space separated list
					  of styles. See <SetCharFormat> for list of styles.
			TextColor		- Text forground color. If starts with "-" the color is AUTOCOLOR.
			BackColor		- Text background color. If starts with "-" the color is AUTOCOLOR.
			Mode	- If empty, this optional parameter retrieves the formatting to all text in the
					  control. Otherwise, pass "SELECTION" (default) to get formatting of the current selection. If the selection
					  is empty, the function will get the character of the insertion point.

 Remarks:
		Function will get the attributes of the first character.

 Related:
		<SetCharFormat>, <SetBgColor>
 
 Example:
 (start code)
  RichEdit_GetCharFormat(hRichEdit, face, style, color)
  MsgBox, Face = %Face% `nstyle = %style%  `ncolor = %color%
 (end code)
 */
RichEdit_GetCharFormat(hCtrl, ByRef Face="", ByRef Style="", ByRef TextColor="", ByRef BackColor="", Mode="SELECTION")  {
	static EM_GETCHARFORMAT=1082, SCF_SELECTION=1
  		  , CFM_CHARSET:=0x8000000, CFM_BACKCOLOR=0x4000000, CFM_COLOR:=0x40000000, CFM_FACE:=0x20000000, CFM_OFFSET:=0x10000000, CFM_SIZE:=0x80000000, CFM_WEIGHT=0x400000, CFM_UNDERLINETYPE=0x800000
		  , CFE_HIDDEN=0x100, CFE_BOLD=1, CFE_ITALIC=2, CFE_LINK=0x20, CFE_PROTECTED=0x10, CFE_STRIKEOUT=8, CFE_UNDERLINE=4, CFE_SUPERSCRIPT=0x30000, CFE_SUBSCRIPT=0x30000
		  , CFM_ALL2=0xFEFFFFFF, COLOR_WINDOW=5, COLOR_WINDOWTEXT=8
		  , styles="HIDDEN BOLD ITALIC LINK PROTECTED STRIKEOUT UNDERLINE SUPERSCRIPT SUBSCRIPT"

	VarSetCapacity(CF, 84, 0), NumPut(84, CF), NumPut(CFM_ALL2, CF, 4)
	SendMessage, EM_GETCHARFORMAT, SCF_%Mode%, &CF,, ahk_id %hCtrl%

	Face := DllCall("MulDiv", "UInt", &CF+26, "Int",1, "Int",1, "str")

	Style := "", dwEffects := NumGet(CF, 8, "UInt")
	Loop, parse, styles, %A_SPACE%
		if (CFE_%A_LoopField% & dwEffects)
			Style .= A_LoopField " "
    s := NumGet(CF, 12, "Int") // 20,  o := NumGet(CF, 16, "Int")
	Style .= "s" s (o ? " o" o : "")

	oldFormat := A_FormatInteger
    SetFormat, integer, hex
	
	if (dwEffects & CFM_BACKCOLOR)
		 BackColor := "-" DllCall("GetSysColor", "int", COLOR_WINDOW)
	else BackColor := NumGet(CF, 64), BackColor := (BackColor & 0xff00) + ((BackColor & 0xff0000) >> 16) + ((BackColor & 0xff) << 16)

	if (dwEffects & CFM_COLOR)
		 TextColor := "-" DllCall("GetSysColor", "int", COLOR_WINDOWTEXT)
	else TextColor := NumGet(CF, 20), TextColor := (TextColor & 0xff00) + ((TextColor & 0xff0000) >> 16) + ((TextColor & 0xff) << 16)

    SetFormat, integer, %oldFormat%
}

/*
  Function: GetRedo
 			Determine whether there are any actions in the rich edit control redo queue, and
			optionally retrieve the type of the next redo action.

  Parameters:
 			name - This optional parameter is the name of the variable in which to store the
             type of redo action, if any.

  Name Types:
      UNKNOWN - The type of undo action is unknown.
      TYPING - Typing operation.
      DELETE - Delete operation.
      DRAGDROP - Drag-and-drop operation.
      CUT - Cut operation.
      PASTE - Paste operation.

  Returns:
 			If there are actions in the control redo queue, the return value is a nonzero value.
 			If the redo queue is empty, the return value is zero.

  Related:
		<Redo>, <GetUndo>, <Undo>, <SetUndoLimit>

 Example:
 (start code)
  If RichEdit_GetRedo( hRichEdit, name )
    MsgBox, The next redo is a %name% type
  Else
    MsgBox, Nothing left to redo.
 (end code)
 */
RichEdit_GetRedo(hCtrl, ByRef name="-")  {
	static EM_CANREDO=1109, EM_GETREDONAME=1111,UIDs="UNKNOWN,TYPING,DELETE,DRAGDROP,CUT,PASTE"
	SendMessage, EM_CANREDO,,,, ahk_id %hCtrl%
	nRedo := ErrorLevel

	If ( nRedo && name != "-" )  {
		SendMessage, EM_GETREDONAME,,,, ahk_id %hCtrl%
		Loop, Parse, UIDs, `,
			If (A_Index - 1 = ErrorLevel)  {
				name := A_LoopField
				break
			}
	}
	return nRedo
}

/*
 Function: GetModify
      Gets the state of the modification flag for the Edit control.
      The flag indicates whether the contents of the control has been modified.

 Returns:
      True if the content of Edit control has been modified, false otherwise.
      
  Related:
      <SetModify>, <Save>
 */
RichEdit_GetModify(hEdit)  {
    Static EM_GETMODIFY=0xB8
    SendMessage EM_GETMODIFY,,,,ahk_id %hEdit%
    Return ErrorLevel = 4294967295 ? 1 : 0
}

/*
 Function:	GetParaFormat
			Retrieves the paragraph formatting of the current selection in a rich edit control. (*** not implemented ***)	
 */
; Num,Align,Line,Ident,Space,Tabs
RichEdit_GetParaFormat(hCtrl) {
	static EM_GETPARAFORMAT=1085
		   ,PFM_ALL2=0xc0fffdff
	VarSetCapacity(PF, 188, 0), NumPut(188, PF),  NumPut(PFM_ALL2, PF, 4)
	SendMessage, EM_GETPARAFORMAT,, &PF,, ahk_id %hCtrl%
}

/*
 Function:  GetRect
 			Gets the formatting rectangle of the Edit control.

 Parameters:
			Left..Bottom	- Output variables, can be omitted.

 Returns:
 			Space separated rectangle.
 */
RichEdit_GetRect(hEdit,ByRef Left="",ByRef Top="",ByRef Right="",ByRef Bottom="") {
    static EM_GETRECT:=0xB2

	VarSetCapacity(RECT,16)
    SendMessage EM_GETRECT,0,&RECT,,ahk_id %hEdit%
      Left  :=NumGet(RECT, 0,"Int")
    , Top   :=NumGet(RECT, 4,"Int")
    , Right :=NumGet(RECT, 8,"Int")
    , Bottom:=NumGet(RECT,12,"Int")
    return  Left " " Top " " Right " " Bottom
}

/*
  Function: GetSel
 			Retrieve the starting and ending character positions of the selection in a rich edit control.

  Parameters:
 			cpMin -	The optional name of the variable in which to store the character position index immediately
              preceding the first character in the range.
 			cpMin -	The optional name of the variable in which to store the character position index immediately
              following the last character in the range.

  Returns:
 			Returns *cpMin*. If there is no selection this is cursor position.

  Related:
      <GetText>, <GetTextLength>, <SetSel>, <SetText>, <HideSelection>, <LineFromChar>
 */
RichEdit_GetSel(hCtrl, ByRef cpMin="", ByRef cpMax="" )  {
  static EM_EXGETSEL=0x434
  VarSetCapacity(CHARRANGE, 8)
  SendMessage, EM_EXGETSEL, 0,&CHARRANGE,, ahk_id %hCtrl%
  cpMin := NumGet(CHARRANGE, 0, "Int"), cpMax := NumGet(CHARRANGE, 4, "Int")
  return cpMin
}

/*
 Function:  GetText
			Retrieves a specified range of characters from a rich edit control.

 Parameters:
			CpMin -	Beginning of range of characters to retrieve.
			CpMax -	End of range of characters to retrieve.
			CodePage - If *UNICODE* or *U*, this optional parameter will use unicode code page
					in the translation. Otherwise it will default to using ansi. (*** needs rework ***)

 Note:
			If the *CpMin* and *CpMax* are omitted, the current selection is retrieved.
			The range includes everything if *CpMin* is 0 and *CpMax* is –1.

 Returns:
			Returns the retrieved text.

 Related:
			<GetSel>, <GetLine>, <GetTextLength>, <SetText>, <SetSel>, <FindText>
			
 Example:
 (start code)
  MsgBox, % RichEdit_GetText( hRichEdit ) ; get current selection
  MsgBox, % RichEdit_GetText( hRichEdit, 0, -1 ) ; get all
  MsgBox, % RichEdit_GetText( hRichEdit, 4, 10 ) ; get range
 (end code)
 */
RichEdit_GetText(HCtrl, CpMin="-", CpMax="-", CodePage="")  {
	static EM_EXGETSEL=0x434, EM_GETTEXTEX=0x45E, EM_GETTEXTRANGE=0x44B, GT_SELECTION=2

	bufferLength := RichEdit_GetTextLength(hCtrl, "CLOSE", "UNICODE" )

	If (CpMin CpMax = "--")
		MODE := GT_SELECTION, CpMin:=CpMax:=""
	else if (CpMin=0 && CpMax=-1)
		MODE := GT_ALL      , CpMin:=CpMax:=""
	else if (CpMin+0 != "") && (cpMax+0 != "")
	{
		VarSetCapacity(lpwstr, bufferLength), VarSetCapacity(TEXTRANGE, 12)
		NumPut(CpMin, TEXTRANGE, 0, "UInt")
		NumPut(CpMax, TEXTRANGE, 4, "UInt"), NumPut(&lpwstr, TEXTRANGE, 8, "UInt")
		SendMessage, EM_GETTEXTRANGE,, &TEXTRANGE,, ahk_id %hCtrl%
		; If not unicode, return ansi from string pointer..
		if !InStr(RichEdit_TextMode(HCtrl), "MULTICODEPAGE")
			return DllCall("MulDiv", "UInt", &lpwstr, "Int",1, "Int",1, "str")

		;..else, convert Unicode to Ansi..
		nSz := DllCall("lstrlenW","UInt",&lpwstr) + 1, VarSetCapacity( ansi, nSz )
		DllCall("WideCharToMultiByte" , "Int",0       , "Int",0
									,"UInt",&LPWSTR ,"UInt",nSz+1
									, "Str",ansi    ,"UInt",nSz+1
									, "Int",0       , "Int",0 )
		VarSetCapacity(ansi, -1)
		return ansi
	}
	else return "", errorlevel := A_ThisFunc "> Invalid use of cpMin or cpMax parameter."

	VarSetCapacity(GETTEXTEX, 20, 0)          , VarSetCapacity(BUFFER, bufferLength, 0)
	NumPut(bufferLength, GETTEXTEX, 0, "UInt"), NumPut(MODE, GETTEXTEX, 4, "UInt")
	NumPut( (CodePage="unicode" || CodePage="u") ? 1200 : 0  , GETTEXTEX, 8, "UInt")
	SendMessage, EM_GETTEXTEX, &GETTEXTEX, &BUFFER,, ahk_id %hCtrl%
	VarSetCapacity(BUFFER, -1)
	return BUFFER
}

/*
 Function:	GetTextLength
			Calculates text length in various ways for a rich edit control.

 Parameters:
			flag     - Space separated list of one or more options.  See below list.
			codepage - If *UNICODE* or *U*, this optional parameter will use unicode code page
                in the translation. Otherwise it will default to using ansi.

 Flag Options:
     DEFAULT  - Returns the number of characters. This is the default.
     USECRLF  - Computes the answer by using CR/LFs at the end of paragraphs.
     PRECISE  - Computes a precise answer. This approach could necessitate a conversion
                and thereby take longer. This flag cannot be used with the *CLOSE* flag.
     CLOSE    - Computes an approximate (close) answer. It is obtained quickly and can
                be used to set the buffer size. This flag cannot be used with the *PRECISE*
                flag.
     NUMCHARS - Returns the number of characters. This flag cannot be used with the
                *NUMBYTES* flag.
     NUMBYTES - Returns the number of bytes. This flag cannot be used with the *NUMCHARS*
                flag.

 Returns:
     If the operation succeeds, the return value is the number of TCHARs in the edit
     control, depending on the setting of the flags.
     If the operation fails, the return value is blank.

 Remarks:
     This message is a fast and easy way to determine the number of characters in the
     Unicode version of the rich edit control. However, for a non-Unicode target code
     page you will potentially be converting to a combination of single-byte and double-byte
     characters.

 Related:
     <LineLength>, <LimitText>, <GetSel>

 Example:
 (start code)
  MsgBox, % "DEFAULT  = " RichEdit_GetTextLength(hRichEdit, "DEFAULT" )  "`n"
          . "USECRLF  = " RichEdit_GetTextLength(hRichEdit, "USECRLF" )  "`n"
          . "PRECISE  = " RichEdit_GetTextLength(hRichEdit, "PRECISE" )  "`n"
          . "CLOSE    = " RichEdit_GetTextLength(hRichEdit, "CLOSE" )    "`n"
          . "NUMCHARS = " RichEdit_GetTextLength(hRichEdit, "NUMCHARS" ) "`n"
          . "NUMBYTES = " RichEdit_GetTextLength(hRichEdit, "NUMBYTES" ) "`n"
 (end code)
 */
RichEdit_GetTextLength(hCtrl, Flags=0, CodePage="")  {
  static EM_GETTEXTLENGTHEX=95,WM_USER=0x400
  static GTL_DEFAULT=0,GTL_USECRLF=1,GTL_PRECISE=2,GTL_CLOSE=4,GTL_NUMCHARS=8,GTL_NUMBYTES=16

  hexFlags:=0
	Loop, parse, Flags, %A_Tab%%A_Space%
		hexFlags |= GTL_%A_LOOPFIELD%

  VarSetCapacity(GETTEXTLENGTHEX, 4)
  NumPut(hexFlags, GETTEXTLENGTHEX, 0), NumPut((codepage="unicode"||codepage="u") ? 1200 : 1252, GETTEXTLENGTHEX, 4)
  SendMessage, EM_GETTEXTLENGTHEX | WM_USER, &GETTEXTLENGTHEX,0,, ahk_id %hCtrl%
  IfEqual, ERRORLEVEL,0x80070057, return "", errorlevel := A_ThisFunc "> Invalid combination of parameters."
  IfEqual, ERRORLEVEL,FAIL      , return "", errorlevel := A_ThisFunc "> Invalid control handle."
  return ERRORLEVEL
}

/*
 Function:	GetUndo
    Determine whether there are any actions in the Edit control undo queue, and optionally retrieve
    the type of the next undo action.

 Parameters:
    Name - Optional byref parameter will contain the type of undo action, if any.

 Types:
    UNKNOWN	 - The type of undo action is unknown.
    TYPING	 - Typing operation.
    DELETE	 - Delete operation.
    DRAGDROP - Drag-and-drop operation.
    CUT		 - Cut operation.
    PASTE	 - Paste operation.

 Returns:
    If there are actions in the control undo queue, the return value is a nonzero value.
    If the undo queue is empty, the return value is zero.

 Related:
    <Undo>, <SetUndoLimit>, <GetRedo>, <Redo>

 Example:
 (start code)
  If RichEdit_GetRedo( hRichEdit, name )
    MsgBox, The next redo is a %name% type
  Else MsgBox, Nothing left to redo.
 (end code)
 */
RichEdit_GetUndo(hCtrl, ByRef Name="-")  {
  static EM_CANUNDO=0xC6,EM_GETUNDONAME=86,WM_USER=0x400
        ,UIDs="UNKNOWN,TYPING,DELETE,DRAGDROP,CUT,PASTE"
  SendMessage, EM_CANUNDO, 0,0,, ahk_id %hCtrl%
  nUndo := ERRORLEVEL

  If ( nUndo && name != "-" )  {
    SendMessage, WM_USER | EM_GETUNDONAME, 0,0,, ahk_id %hCtrl%
    Loop, Parse, UIDs, `,
      If (A_Index - 1 = errorlevel)  {
        name := A_LoopField
        break
      }
  }
  return nUndo
}

/*
 Function:  HideSelection
    Hides or shows the selection in a rich edit control.

 Parameters:
    State - True or false.

 Remarks:
    This function is noticeable when it is set to false and the rich edit control isn't the active control or window.  The example included in <FindText> demonstrates use.

 Related:
			<SetSel>, <GetSel>
 */
RichEdit_HideSelection(hCtrl, State=true)  {
  static EM_HIDESELECTION = 1087
  SendMessage, EM_HIDESELECTION,%State%,0,, ahk_id %hCtrl%
}

/*
 Function:  LineFromChar
			Determines which line contains the specified character in a rich edit control.

 Parameters:
			CharIndex -	Zero-based integer index of the character. -1 (default) means current line.

 Returns:
			Zero-based index of the line.

 Related:
			<LineIndex>, <GetLineCount>
 */
RichEdit_LineFromChar(hCtrl, CharIndex=-1)  {
  static EM_EXLINEFROMCHAR=1078
  SendMessage, EM_EXLINEFROMCHAR,,CharIndex,, ahk_id %hCtrl%
  return ERRORLEVEL
}

/*
 Function:	LineIndex
			Returns the character index of the first character of a specified line in an Edit control.

 Parameters:
			LineNumber	- Line number for which to retreive character index. -1 (default) means current line.

 Returns:
			The character index of the line specified, or -1 if the specified line number is greater than the number of lines.

 Related:
			<LineLength>, <LineFromChar>, <GetLine>, <GetLineCount>
 */
RichEdit_LineIndex(hEdit, LineNumber=-1) {
	static EM_LINEINDEX=187
 	SendMessage, EM_LINEINDEX, LineNumber,,, ahk_id %hEdit%
	Return ErrorLevel
}

/*
 Function:	LineLength
			Returns the length of a line in an Edit control.

 Parameters:
			LineNumber	- Line number for which to retreive line length. -1 (default) means current line.

 Returns:
			The length (in characters) of the line.
			
 Related:
			<GetTextLength>, <LineIndex>, <LineFromChar>
 */
RichEdit_LineLength(hEdit, LineNumber=-1) {
	static EM_LINELENGTH=193
	SendMessage, EM_LINELENGTH, RichEdit_LineIndex(hEdit, LineNumber),,, ahk_id %hEdit%
	Return ErrorLevel
}

/*
 Function: LineScroll
			Scrolls the text in the Edit control.

 Parameters:
			XScroll -	The number of characters to scroll horizontally.  Use a
								negative number to scroll to the left and a positive number to
								scroll to the right.
			YScroll -	The number of lines to scroll vertically.  Use a negative
						    number to scroll up and a positive number to scroll down.
 Remarks:
			This message does not move the caret.
			This function can be used to scroll horizontally past the last character of any line.
 */
RichEdit_LineScroll(hEdit,XScroll=0,YScroll=0){
    Static EM_LINESCROLL:=0xB6
    SendMessage EM_LINESCROLL, XScroll, YScroll,,ahk_id %hEdit%
}

/*
 Function:  LimitText
			Sets an upper limit to the amount of text the user can type or paste into a rich edit control.

 Parameters:
			txtSize -	Specifies the maximum amount of text that can be entered. If this parameter is zero,
               the default maximum is used, which is 64K characters. A Component Object Model (COM)
               object counts as a single character.

 Returns:
			This function does not return a value.

 Remarks:
     Before LimitText is called, the default limit to the amount of text a user can enter is
     32,767 characters.
 */
RichEdit_LimitText(hCtrl,txtSize=0)  {
  static EM_EXLIMITTEXT=53,WM_USER=0x400
  SendMessage, WM_USER | EM_EXLIMITTEXT, 0,%txtSize%,, ahk_id %hCtrl%
}

/*
 Function: Paste
		   Paste clipboard into the Edit control.

 Related:
		<CanPaste>, <PasteSpecial>, <Cut>, <Copy>, <Clear>
 */
RichEdit_Paste(hEdit) {
    Static WM_PASTE:=0x302
    SendMessage WM_PASTE,0,0,,ahk_id %hEdit%
}

/*
 Function:	PasteSpecial
      Pastes a specific clipboard format in a rich edit control.

 Parameters:
			Format	- One of the clipboard formats. See <http://msdn.microsoft.com/en-us/library/bb774214(VS.85).aspx>

 Related:
		<CanPaste>, <Paste>
 */
RichEdit_PasteSpecial(HCtrl, Format)  {
  static EM_PASTESPECIAL=0x440
		,CF_BITMAP=2,CF_DIB=8,CF_DIBV5=17,CF_DIF=5,CF_DSPBITMAP=0x82,CF_DSPENHMETAFILE=0x8E,CF_DSPMETAFILEPICT=0x83
        ,CF_DSPTEXT=0x81,CF_ENHMETAFILE=14,CF_GDIOBJFIRST=0x300,CF_GDIOBJLAST=0x3FF,CF_HDROP=15,CF_LOCALE=16
        ,CF_METAFILEPICT=3,CF_OEMTEXT=7,CF_OWNERDISPLAY=0x80,CF_PALETTE=9,CF_PENDATA=10,CF_PRIVATEFIRST=0x200
        ,CF_PRIVATELAST=0x2FF,CF_RIFF=11,CF_SYLK=4,CF_TEXT=1,CF_WAVE=12,CF_TIFF=6,CF_UNICODETEXT=13

  SendMessage, EM_PASTESPECIAL, CF_%Format%, 0,, ahk_id %hCtrl%
}


/*
 Function: PosFromChar
           Gets the client area coordinates of a specified character in an Edit control.

 Parameters:
           CharIndex - The zero-based index of the character.

           X, Y - These parameters, which must contain valid variable names,
           are used to return the x/y-coordinates of a point in the control's client relative to the upper-left corner of the client area.

 Remarks:
           If CharIndex is greater than the index of the last character in the control, the returned coordinates are of the position just past
           the last character of the control.
 */
RichEdit_PosFromChar(hEdit, CharIndex, ByRef X, ByRef Y) {
    Static EM_POSFROMCHAR=0xD6
    VarSetCapacity(POINTL,8,0)
    SendMessage EM_POSFROMCHAR,&POINTL,CharIndex,,ahk_id %hEdit%
    X:=NumGet(POINTL,0,"Int"), Y:=NumGet(POINTL,4,"Int")
}

/*
 Function:	Redo
			Do redo operation.

 Returns:
			True if the Redo operation succeeds, false otherwise.
 */
RichEdit_Redo(hEdit) {
	static EM_REDO := 1108
	SendMessage, EM_REDO,,,, ahk_id %hEdit%
	return ErrorLevel
}

/*
 Function:	ReplaceSel
			Replace selection with desired text in the Edit control.

 Parameters:
			Text - Text to replace selection with.
 */
RichEdit_ReplaceSel(hEdit, Text=""){
	static  EM_REPLACESEL=194
	SendMessage, EM_REPLACESEL,, &text,, ahk_id %hEdit%
}

/*
 Function:	Save
			Save the content of the rich edit control using RT format.

 Parameters:
			FileName	- File name to save RTF file to. If omitted, function will return content.
			
  Related:
      <GetModify>, <SetModify>
      
 Example:
 (start code)
  If !RichEdit_GetModify( hRichEdit )  {
    MsgBox, No changes detected
    return
  }

  RichEdit_Save( hRichEdit, file )
  RichEdit_SetModify( hRichEdit, false )
  MsgBox, File has been saved
 (end code)
 */
RichEdit_Save(hCtrl, FileName="") {
	static EM_STREAMOUT=0x44A

	wbProc := RegisterCallback("RichEdit_editStreamCallBack", "F")
	VarSetCapacity(EDITSTREAM, 16, 0)
	NumPut(RichEdit_GetTextLength(hCtrl, "USECRLF")*2, EDITSTREAM)	;aproximate
	NumPut(wbProc, EDITSTREAM, 8, "UInt")

	SendMessage, EM_STREAMOUT, 2, &EDITSTREAM,, ahk_id %hCtrl%
	return RichEdit_editStreamCallBack("!", FileName, "", "")
}

/*
 Function:	ScrollCaret
			Scroll content of Edit control until caret is visible.
 */
RichEdit_ScrollCaret(hEdit){
	static EM_SCROLLCARET=183
	SendMessage, EM_SCROLLCARET,,,, ahk_id %hEdit%
}

/*
 Function:	ScrollPos
			Obtain the current scroll position, or tell the rich edit control to scroll to a particular point.

 Parameters:
			PosString - String specifying the x/y point in the virtual text space of the document, expressed
					    in pixels. (See example)

 Returns:
     If *posString* is omitted, the return value is the current scroll position.

 Related:
		<ShowScrollBar>, <GetSel>, <LineFromChar>, <SetSel>

 Example:
	> Msgbox, % "scroll pos = " RichRichEdit_ScrollPos( hRichEdit )
	> RichRichEdit_ScrollPos( hRichEdit , "7/22" )
 */
RichEdit_ScrollPos(HCtrl, PosString="" )  {
  static EM_GETSCROLLPOS=1245,EM_SETSCROLLPOS=1246

  VarSetCapacity(POINT, 8, 0)
  If (!PosString)  {
    SendMessage, EM_GETSCROLLPOS, 0,&POINT,, ahk_id %HCtrl%
    return NumGet(POINT, 0, "Int") . "/" . NumGet(POINT, 4, "Int")  ; returns posString
  }

  If RegExMatch( PosString, "^(?<X>\d*)/(?<Y>\d*)$", m )  {
    NumPut(mX, POINT, 0, "Int"), NumPut(mY, POINT, 4, "Int")
    SendMessage, EM_SETSCROLLPOS, 0,&POINT,, ahk_id %HCtrl%
  }
  else return false, errorlevel := "ERROR: '" PosString "' isn't a valid posString."
}

/*
 Function:	SelectionType
			Determines the selection type for a rich edit control.

 Returns:
			If the selection is not empty, the return value is a set of flags containing one or more of the following values:
			TEXT		-	Text.
			OBJECT		-	At least one Component Object Model (COM) object.
			MULTICHAR	-	More than one character of text.
			MULTIOBJECT	-	More than one COM object.

 Remarks:
	This message is useful during WM_SIZE processing for the parent of a bottomless rich edit control.
 */
RichEdit_SelectionType(hCtrl)  {
	static EM_SELECTIONTYPE=1090, 1="TEXT", 2="OBJECT", 4="MULTICHAR", 8="MULTIOBJECT", types="1,2,4,8"

	if hCtrl > 0
	{
		SendMessage, EM_SELECTIONTYPE,,,, ahk_id %hCtrl%
		if !(o := ErrorLevel)
			return
	}
	else o := abs(hCtrl)

	loop, parse, types, `,
		if (o & A_LoopField)
			res .= %A_LoopField% " "

	return SubStr(res, 1, -1)
}

/*
 Function:	SetBgColor
			Sets the background color for a rich edit control.

 Parameters:
			Color -	Color in RGB format (0xRRGGBB) if > 0 or BGR format if < 0.

 Returns:
			Returns the previous background color in RGB format.

 Related:
     <SetCharFormat>, <GetCharFormat>

 Example:
 > Dlg_Color( color, hRichEdit )
 > RichEdit_SetBgColor( hRichEdit, color )
 >
 > RichEdit_SetBgColor( hRichEdit, 0xa9f874 )
 */
RichEdit_SetBgColor(hCtrl, Color)  {
	static EM_SETBKGNDCOLOR=1091

	if (Color < 0) {
		SendMessage, EM_SETBKGNDCOLOR,, abs(Color),, ahk_id %hCtrl%
		return Color
	}

	old := A_FormatInteger
	SetFormat, integer, hex
	RegExMatch( Color, "0x(?P<R>..)(?P<G>..)(?P<B>..)$", _ ) ; RGB2BGR
	Color := "0x00" _B _G _R        ; 0x00bbggrr
	SendMessage, EM_SETBKGNDCOLOR,,Color,, ahk_id %hCtrl%
	RegExMatch( ERRORLEVEL + 0x1000000, "(?P<B>..)(?P<G>..)(?P<R>..)$", _ ) ; RGB2BGR
	pColor := "0x" _R _G _B
	SetFormat, integer, %old%

	return pColor
}

/*
 Function:	SetCharFormat
			Set character formatting in a rich edit control.

 Parameters:
			Face	- Font name. Optional.
			Style	- Space separated list of styles. See below list. Optional.
			TextColor	- Text foreground color. Optional.
			BackColor	- Text backgrond color. Optional.
			Mode	- Character formatting that applies to the control.
					  If omitted, the function changes the default character formatting.
					  It can be one of the values given bellow. Optional.

 Styles:
			s<Num>		- Character size, usual AHK represntation (i.e. s12)
			o<Num>		- Character offset from the baseline, in twips,. If the value of this member is positive, the character is a superscript; if the value is negative, the character is a subscript.
			AUTOBACKCOLOR - The background color is the return value of GetSysColor(COLOR_WINDOW:=5). If this flag is set, BackColor member is ignored.
			AUTOCOLOR	- The text color is the return value of GetSysColor(COLOR_WINDOWTEXT:=8). If this flag is set, the TextColor member is ignored.
			BOLD		- Characters are bold.
			HIDDEN		- Characters are not displayed.
			ITALIC		- Characters are italic.
			LINK		- A rich edit control sends LINK notification messages when it receives mouse messages while the mouse pointer is over text with the LINK effect.
			PROTECTED	- Characters are protected; an attempt to modify them will cause an PROTECTED notification message.
			STRIKEOUT	- Characters are struck out.
			SUBSCRIPT	- Characters are subscript. The SUPERSCRIPT and SUBSCRIPT values are mutually exclusive.
						  For both values, the control automatically calculates an offset and a smaller font size.
			SUPERSCRIPT	- Characters are superscript.
			UNDERLINE	- Characters are underlined.

 Modes:
			DEFAULT		- Changes the formating for the default text in the control. This is also the style used if you don't specify valid style.
			ALL			- Applies the formatting to all text in the control.
			SELECTION	- Applies the formatting to the current selection. If the selection is empty, the character formatting is applied
						  to the insertion point, and the new character format is in effect only until the insertion point changes. 
			WORD		- Applies the formatting to the selected word or words. If the selection is empty but the insertion point is inside a word
						  ,the formatting is applied to the word.
						  
 Returns:
			True or false.

 Remarks:
			This function will fire up SELCHANGE message even if selection isn't changed.
 */
RichEdit_SetCharFormat(HCtrl, Face:="", Style:="", TextColor:="", BackColor:="", Mode:="SELECTION")  {
	static EM_SETCHARFORMAT	:=0x444
			, CFM_CHARSET            	:=0x8000000			
			, CFM_COLOR                	:=0x40000000	
			, CFM_BACKCOLOR        	:=0x4000000
			, CFM_FACE                 	:=0x20000000
			, CFM_OFFSET               	:=0x10000000				
			, CFM_SIZE                   	:=0x80000000		
			, CFM_WEIGHT            	:=0x400000
			, CFM_UNDERLINETYPE	:=0x800000 	
			, CFM_HIDDEN            	:=0x100			
			, CFM_BOLD                 	:=1
			, CFM_ITALIC                	:=2
			, CFM_DISABLED          	:=0x2000
			, CFM_LINK                  	:=0x20
			, CFM_PROTECTED         	:=0x10
			, CFM_STRIKEOUT        	:=8
			, CFM_UNDERLINE        	:=4
			, CFM_SUPERSCRIPT    	:=0x30000
			, CFM_SUBSCRIPT        	:=0x30000
			, CFE_AUTOBACKCOLOR	:=0x4000000
			, CFE_AUTOCOLOR         	:= 0x40000000
			, CFE_HIDDEN              	:=0x100
			, CFE_BOLD                  	:=1
			, CFE_ITALIC                 	:=2
			, CFE_DISABLED            	:=0x2000
			, CFE_LINK                    	:=0x20
			, CFE_PROTECTED        	:=0x10
			, CFE_STRIKEOUT         	:=8
			, CFE_UNDERLINE        	:=4
			, CFE_SUBSCRIPT         	:=0x10000
			, CFE_SUPERSCRIPT     	:=0x20000
			, SCF_ALL                     	:=4
			, SCF_SELECTION         	:=1
			, SCF_WORD                	:=3	
			, SCF_ASSOCIATEFONT	:=0x10

;sz := S(_, "CHARFORMAT2A: cbSize dwMask dwEffects yHeight=.04 yOffset=.04 crTextColor bCharSet=.1 
;bPitchAndFamily=.1 szFaceName wWeight=60.2 sSpacing=.02 crBackColor lcid dwReserved sStyle=.02 wKerning=.2 bUnderlineType=.1 bAnimation=.1 bRevAuthor=.1 bReserved1=.1")

	VarSetCapacity(CF, 84, 0),  NumPut(84, CF)
	hMask := 0
	if (Face != "") && (StrLen(Face) <= 32)
		hMask |= CFM_FACE, DllCall("lstrcpy", "UInt", &CF+26, "Str", Face)

	if (TextColor != "")
		TextColor := ((TextColor & 0xFF) << 16) + (TextColor & 0xFF00) + ((TextColor >> 16) & 0xFF)
		, hMask |= CFM_COLOR, NumPut(TextColor, CF, 20)

	if (BackColor != "")
		BackColor := ((BackColor & 0xFF) << 16) + (BackColor & 0xFF00) + ((BackColor >> 16) & 0xFF)
		, hMask |= CFM_BACKCOLOR,  NumPut(BackColor, CF, 64)

	if (Style != "") {
		hEffects := 0
		loop, parse, Style, %A_Space%
		{
			lf := A_LoopField, c := SubStr(lf, 1, 1)
			if InStr("so", c) && ((j := SubStr(lf, 2)+0) != "", (%c% := j))
				 continue

			if bOff := c = "-"
				lf := SubStr(lf, 2)

			hMask |= CFM_%lf%, hEffects |= bOff ? 0 : CFE_%lf%
		}
	    NumPut(hEffects, CF, 8)
		if (s != "")
			hMask |= CFM_SIZE, NumPut(s*20, CF, 12, "Int")
		if (o != "")
			hMask |= CFM_OFFSET, NumPut(o, CF, 16, "Int")
	}

	NumPut(hMask, CF, 4)
	SendMessage, EM_SETCHARFORMAT, SCF_%Mode%, &CF,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
	Function:	SetEvents
				Set notification events.

	Parameters:
				Handler	- Function that handles events. If empty, any existing handler will be removed.
				Events	- White space separated list of events to monitor.

	Handler:
 >     	Result := Handler(hCtrl, Event, p1, p2, p3 )

		hCtrl	- Handle of richedit control sending the event.
		Event	- Specifies event that occurred. Event must be registered to be able to monitor it.
		Col,Row - Cell coordinates.
		Data	- Numeric data of the cell. Pointer to string for textual cells and DWORD value for numeric.
		Result  - Return 1 to prevent action.

	Events:
		*CHANGE*: Sent when the user has taken an action that may have altered text in an edit control.
				  Sent after the system updates the screen. (***)

		*DRAGDROPDONE*: Notifies a rich edit control's parent window that the drag-and-drop operation has completed.
		 o P1 - Number of characters highlighted in drag-drop operation.
         o P2 - Beginning character position of range.
         o P3 - Ending character position of range.

		*DROPFILES*: Notifies that the user is attempting to drop files into the control.
		 o P1 - Number of files dropped onto rich edit control.
		 o P2 - Newline delimited (`n) list of files dropped onto control.
		 o P3 - Character position files were dropped onto within rich edit control.

		*KEYEVENTS*: Notification of a keyboard or mouse event in the control. To ignore the
					 event, the handler function should return a nonzero value.  (*** needs redone)
		 o P1 - Character position files were dropped onto within rich edit control.

		*MOUSEEVENTS,SCROLLEVENTS,LINK*: A rich edit control sends these messages when it receives various messages, when the
				user clicks the mouse or when the mouse pointer is over text that has the LINK effect.
				(*** expand usefulness)

		*PROTECTED*:	User is taking an action that would change a protected range of text.  To ignore
						the event, the handler function should return a nonzero value.

		*REQUESTRESIZE*: This message notifies a rich edit control's parent window that the control's
						 contents are either smaller or larger than the control's window size.
		 o P1 - Requested new size.

		*SELCHANGE*: The current selection has changed.
		 o P1 - Beginning character position of range.
		 o P2 - Ending character position of range.
		 o P3 - Selection type.

		*LINK*: The hyperlink has been clicked.
		 o P1 - LClick or RClick.
		 o P2 - CpMin.
		 o P3 - CpMax.

 Returns:
		The previous event mask (number).
 */
RichEdit_SetEvents(hCtrl, Handler="", Events="selchange"){
  static ENM_CHANGE=0x1,ENM_DRAGDROPDONE=0x10,ENM_DROPFILES:=0x100000,ENM_KEYEVENTS=0x10000,ENM_LINK=0x4000000,ENM_MOUSEEVENTS=0x20000,ENM_PROTECTED=0x200000,ENM_REQUESTRESIZE=0x40000,ENM_SCROLLEVENTS=0x8,ENM_SELCHANGE=0x80000 ;ENM_OBJECTPOSITIONS=0x2000000,ENM_SCROLL=0x4,ENM_UPDATE=0x2   ***
       , sEvents="CHANGE,DRAGDROPDONE,DROPFILES,KEYEVENTS,LINK,MOUSEEVENTS,PROTECTED,REQUESTRESIZE,SCROLLEVENTS,SELCHANGE,SCROLL"
	   , WM_NOTIFY=0x4E,WM_COMMAND=0x111,EM_SETEVENTMASK=1093, oldNotify, oldCOMMAND

	if (Handler = "")
		return OnMessage(WM_NOTIFY, old != "RichEdit_onNotify" ? old : ""), old := ""

	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

	hMask := 0
	loop, parse, Events, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField,,continue
		if A_LoopField not in %sEvents%
			return A_ThisFunc "> Invalid event: " A_LoopField
		hMask |= ENM_%A_LOOPFIELD%
		If (A_LoopField = "DROPFILES")
			DllCall("shell32.dll\DragAcceptFiles", "UInt", hCtrl, "UInt", true)

		 ; 		if A_LoopField in CHANGE,SCROLL   ; (*** WIP)
		 ;     	if !oldCOMMAND {
		 ;     		oldCOMMAND := OnMessage(WM_COMMAND, "RichEdit_onNotify")
		 ;     		if oldCOMMAND != RichEdit_onNotify
		 ;     			RichEdit("oldCOMMAND", RegisterCallback(oldCOMMAND))
		 ;     	}
	}

	if !oldNotify {
		oldNotify := OnMessage(WM_NOTIFY, "RichEdit_onNotify")
		if oldNotify != RichEdit_onNotify
			RichEdit("oldNotify", RegisterCallback(oldNotify))
	}

	RichEdit(hCtrl "Handler", Handler)
	SendMessage, EM_SETEVENTMASK,,hMask,, ahk_id %hCtrl%
	return ERRORLEVEL  ; This message returns the previous event mask
}

/*
 Function:	SetFontSize
			Sets the font size for the selected text in the rich edit control.

 Parameters:
			Add - Change in point size of the selected text. The change is applied to
					each part of the selection. So, if some of the text is 10pt and some 20pt,
					after a call with wParam set to 1, the font sizes become 11pt and 22pt, respectively.
					
 Returns:
			True if no error occurred, false otherwise.
 */
RichEdit_SetFontSize(hCtrl, Add) {
	static EM_SETFONTSIZE=0x4DF
	SendMessage, EM_SETFONTSIZE,Add,,, ahk_id %hCtrl%
	return ErrorLEvel
}

/*
 Function: SetModify
      Sets or clears the modification flag for an edit control. The modification flag indicates
      whether the text within the edit control has been modified.

  Related:
      <GetModify>, <Save>
 */
RichEdit_SetModify(hEdit, State=true)  {
  Static EM_SETMODIFY = 185
  SendMessage EM_SETMODIFY,%State%,,,ahk_id %hEdit%
}

/*
 Function:	SetOptions
			Sets the options for a rich edit control.


 Parameters:
			Operation	- Specifies the operation.
			Options		- White separted list of option values.

 Operation:
			SET - Sets the options to those specified by Options.
			OR  - Combines the specified options with the current options.
			AND - Retains only those current options that are also specified by Options.
			XOR - Logically exclusive OR the current options with those specified by Options.

 Options:
			AUTOWORDSELECTION - Automatic selection of word on double-click.
			AUTOVSCROLL - Same as AUTOVSCROLL style.
			AUTOHSCROLL - Same as AUTOHSCROLL style.
			NOHIDESEL - Same as NOHIDESEL style.
			READONLY - Same as READONLY style.
			WANTRETURN - Same as WANTRETURN style.
			SELECTIONBAR - Same as SELECTIONBAR style.
 Returns:
			Returns the current options of the edit control.
 */
RichEdit_SetOptions(hCtrl, Operation, Options)  {
	static EM_SETOPTIONS=1101
		, ECOOP_SET=0x1,ECOOP_OR=0x2,ECOOP_AND=0x3,ECOOP_XOR=0x4
		, ECO_AUTOWORDSELECTION=0x1,ECO_AUTOVSCROLL=0x40,ECO_AUTOHSCROLL=0x80,ECO_NOHIDESEL=0x100,ECO_READONLY=0x800,ECO_WANTRETURN=0x1000,ECO_SELECTIONBAR=0x1000000

	operation := ECOOP_%Operation%
	ifEqual, operation,,return A_ThisFunc "> Invalid operation: " Operation

	hOptions := 0
	loop, parse, Options, %A_Tab%%A_Space%,
		ifEqual, A_LoopField,,continue
		else hOptions |= ECO_%A_LOOPFIELD%

	SendMessage, EM_SETOPTIONS, operation, hOptions,, ahk_id %hCtrl%
	return RichEdit_GetOptions( "." ErrorLevel)
}

/*
 Function:	PageRotate
			Rotate page.
 
 Parameters:
		    R	- Can be one of the following: 0,90,180,270. 

 Returns:
			If R is omitted, functin returns current rotation.
 */
RichEdit_PageRotate(hCtrl, R="") {
	static EM_SETPAGEROTATE=1260, EM_GETPAGEROTATE=1259, EPR_270 = 1, EPR_180 = 2, EPR_90 = 3, 1=270, 2=180, 3=90
	
	if (R="") { 
		SendMessage, EM_GETPAGEROTATE,,,, ahk_id %hCtrl%
		return (%ErrorLevel%)
	}
	
	SendMessage, EM_SETPAGEROTATE,EPR_%R%,,, ahk_id %hCtrl%
}

/*
 Function:	SetParaFormat
			Sets the paragraph formatting for the current selection in a rich edit control.

 Parameters:
			o1..o6	- Named arguments: Num, Align, Line, Ident, Space, Tabs. Each named arugment has its own set of
					  parameters (delimited by comma). The syntax is "Name=a1,a2,a3,a4".

 *Num* :

			Type	- EMPTY, BULLET, DECIMAL, LOWER, UPPER, ROMAN_LOWER, ROMAN_UPPER, SEQUENCE (Uses a sequence of characters beginning with the character specified by the start argument).
			Start	- Starting number or starting value used for numbered paragraphs.
			Style	- One of the following :
					  o RP   - Follows the number with a right parenthesis.
					  o P	 - Encloses the number in parentheses.
					  o D	 - Follows the number with a dot.
					  o N	 - Displays only the number.
					  o CONT - Continues a numbered list without applying the next number or bullet.
					  o NEW  - Starts a new number with value of *Start* parameter.
			Offset	- Minimum space between a paragraph number and the paragraph text, in twips.

 *Align* :

			Type	- CENTER, LEFT, RIGHT, JUSTIFY.

 *Line* :

			Rule	- One of the following :
					  o SINGLE	 - Single spacing.
					  o 1ANDHALF - One-and-a-half spacing.
					  o DOUBLE	 - Double spacing.
					  o S1		 - The Spacing specifies the spacing from one line to the next, in twips. However, if Spacing specifies a value that is less than single spacing, the control displays single-spaced text.
					  o S2		 - The Spacing specifies the spacing from one line to the next, in twips. The control uses the exact spacing specified, even if Spacing specifies a value that is less than single spacing.
					  o S3		 - The value of Spacing/20 is the spacing, in lines, from one line to the next. Thus, setting Spacing to 20 produces single-spaced text, 40 is double spaced, 60 is triple spaced, and so on.
			Spacing - Spacing between lines. This value is valid only for S1-S3 Rules.

 *Ident* :

 			First	- Indentation of the paragraph's first line, relative to the paragraph's current indentation, in twips.
					  The indentation of subsequent lines depends on the Offset member.  To see all this in effect you must enable word wrap mode.
					  If starts with ".", it represents absolute indentation from the left margin.
			Offset	- Indentation of the second and subsequent lines, relative to the indentation of the first line, in twips.
					  The first line is indented if this member is negative or outdented if this member is positive.
			Right	- Indentation of the right side of the paragraph, relative to the right margin, in twips.

 *Space* :

			Before	- Size of the spacing above the paragraph, in twips.
			After	- Specifies the size of the spacing below the paragraph, in twips.

 *Tabs* :

			List	- Space separated list of absolute tab stop positions in twips.

 Returns:
			True if succeessiful, false otherwise.

 Remarks:
			Control uses carriage return character (`r) for paragraph markers by default.
 */
RichEdit_SetParaFormat(hCtrl, o1="", o2="", o3="", o4="", o5="", o6="")  {
	;S(_, "PARAFORMAT2: cbSize dwMask wNumbering=.2 wEffects=.2 dxStartIndent=.04 dxRightIndent=.04 dxOffset=.04 wAlignment=.02 cTabCount dySpaceBefore=156.04 dySpaceAfter=.04 dyLineSpacing=.04 sStyle=.02 bLineSpacingRule=.1 bOutlineLevel=.1 wShadingWeight=.2 wShadingStyle=.2 wNumberingStart=.2 wNumberingStyle=.2 wNumberingTab=.2 wBorderSpace=.2 wBorderWidth=.2 wBorders=.2")
	static EM_SETPARAFORMAT=0x447
		,PFM_ALIGNMENT=0x8, PFM_BORDER=0x800, PFM_BOX=0x4000000, PFM_COLLAPSED=0x1000000, PFM_DONOTHYPHEN=0x400000, PFM_KEEP=0x20000, PFM_KEEPNEXT=0x40000, PFM_LINESPACING=0x100, PFM_NOLINENUMBER=0x100000, PFM_NOWIDOWCONTROL=0x200000, PFM_NUMBERING=0x20
		,PFM_NUMBERINGSTART=0x8000, PFM_NUMBERINGSTYLE=0x2000, PFM_NUMBERINGTAB=0x4000, PFM_OFFSET=0x4, PFM_OFFSETINDENT=0x80000000, PFM_OUTLINELEVEL=0x2000000, PFM_PAGEBREAKBEFORE=0x80000, PFM_RIGHTINDENT=0x2, PFM_RTLPARA=0x10000, PFM_SHADING=0x1000
		,PFM_SIDEBYSIDE=0x800000, PFM_SPACEAFTER=0x80, PFM_SPACEBEFORE=0x40, PFM_STARTINDENT=0x1, PFM_STYLE=0x400,PFM_TABLE=0x40000000, PFM_TABSTOPS=0x10, PFN_BULLET=0x1, PFN_LCLETTER=3, PFN_LCROMAN=5, PFN_UCLETTER=4, PFN_UCROMAN=6

	static ALIGN_CENTER=3, ALIGN_LEFT=1, ALIGN_RIGHT=2, ALIGN_JUSTIFY=4
		  ,NUM_TYPE_BULLET=1, NUM_TYPE_DECIMAL=2, NUM_TYPE_LOWER=3, NUM_TYPE_UPPER=4, NUM_TYPE_ROMAN_LOWER=5, NUM_TYPE_ROMAN_UPPER=6, NUM_TYPE_SEQUENCE=7
		  ,NUM_STYLE_P=0X100, NUM_STYLE_D=0X200, NUM_STYLE_N=0X300, NUM_STYLE_CONT=0X400, NUM_STYLE_NEW=0X800
		  ,LINE_RULE_SINGLE=0, LINE_RULE_1ANDHALF=1, LINE_RULE_DOUBLE=2, LINE_RULE_S1=3, LINE_RULE_S2=4, LINE_RULE_S3=5,

	loop {
		ifEqual, o%A_Index%,,break
		else j := InStr( o%A_index%, "=" ), p := SubStr(o%A_index%, 1, j-1 ), v := SubStr( o%A_index%, j+1)
		StringSplit, %p%, v, `,
	}

	;S(PF, "PARAFORMAT2! cbSize dwMask wAlignment", sz, PFM_ALIGNMENT, PFA_RIGHT)
	VarSetCapacity(PF, 188, 0), NumPut(188, PF),  hMask := 0
	if Align0
		hMask |= PFM_ALIGNMENT, NumPut(ALIGN_%Align1%, PF, 24, "UShort")

	;S(PF, "PARAFORMAT2! cbSize dwMask wNumbering wNumberingStart wNumberingStyle wNumberingTab", sz, pm := PFM_NUMBERING | PFM_NUMBERINGSTART | PFM_NUMBERINGSTYLE | PFM_NUMBERINGTAB, p1:=2, p2:=10, p3:=0x200, p4:=20*50)
	if Num0
		hMask |= PFM_NUMBERING, NumPut(NUM_TYPE_%Num1%, PF, 8, "UShort")
		, (Num2 = "") ? "" : (hMask |= PFM_NUMBERINGSTART,  NumPut(Num2, PF, 176, "UShort"))
		, (Num3 = "") ? "" : (hMask |= PFM_NUMBERINGSTYLE,  NumPut(NUM_STYLE_%Num3%, PF, 178, "UShort"))
		, (Num4 = "") ? "" : (hMask |= PFM_NUMBERINGTAB,    NumPut(Num4, PF, 180, "UShort"))

	;S(PF, "PARAFORMAT2! cbSize dwMask bLineSpacingRule dyLineSpacing", sz, PFM_LINESPACING, x:=4, y:=20*50)
	if Line0
		hMask |= PFM_LINESPACING,  NumPut(LINE_RULE_%Line1%, PF, 170, "UChar"),  NumPut(Line2, PF, 164, "Int")

	;S(PF, "PARAFORMAT2! cbSize dwMask dxOffset dxStartIndent dxRightIndent", sz, p:=PFM_OFFSET | PFM_OFFSETINDENT | PFM_RIGHTINDENT, x:=-20*50, y:=20*50, z=x:=20*50)
	if Ident0
		hMask |= 0	;dummy, expression so that bellow works....
		,(Ident1 = "") ? "" : (hMask |= SubStr(Ident1,1,1)!="." ? PFM_OFFSETINDENT : (PFM_STARTINDENT, Ident1 := SubStr(Ident1,2)),  NumPut(Ident1, PF, 12, "Int"))
		,(Ident2 = "") ? "" : (hMask |= PFM_OFFSET,  NumPut(Ident2, PF, 20, "Int"))
		,(Ident3 = "") ? "" : (hMask |= PFM_RIGHTINDENT,  NumPut(Ident3, PF, 16, "Int"))

	;S(PF, "PARAFORMAT2! cbSize dwMask dySpaceAfter dySpaceBefore", sz, p:=PFM_SPACEAFTER | PFM_SPACEBEFORE, x:=20*50, y:=10*50)
	if Space0
		hMask |= 0
		,(Space1 = "") ? "" : (hMask |= PFM_SPACEBEFORE,  NumPut(Space1, PF, 156, "Int"))
		,(Space2 = "") ? "" : (hMask |= PFM_SPACEAFTER,   NumPut(Space2, PF, 160, "Int"))

	;S(PF, "PARAFORMAT2! cbSize dwMask cTabCount rgxTabs", sz, PFM_TABSTOPS, x:=2)		;put 2 tabstops
	;NumPut(20*50, PF, 28+0, "Int"), NumPut(20*250, PF, 28+4, "Int")
	if Tabs0
	{
		loop, parse, Tabs1, %A_Space%%A_Tab%
			NumPut(A_LoopField, PF, 24+(A_Index*4), "Int"), tabCount := A_Index
		NumPut(tabCount, PF, 26, "Short"),  hMask |= PFM_TABSTOPS
	}

	;S(PF, "PARAFORMAT2! cbSize dwMask wBorders wBorderWidth", sz, PFM_BORDER, x:=64, y:=20*5 )	;!!! does not work

    NumPut(hMask, PF, 4)   ; HexView(&PF, sz)
	SendMessage, EM_SETPARAFORMAT,,&PF,,ahk_id %hCtrl%
	return ErrorLevel
}

/*
 Function:	SetEditStyle
			Sets the current edit style flags.

 Parameters:
			Style - One of the styles bellow. Prepend "-" to turn the style off.

 Styles:
			EMULATESYSEDIT	- When this bit is on, rich edit attempts to emulate the system edit control.
			BEEPONMAXTEXT	- Rich Edit will call the system beeper if the user attempts to enter more than the maximum characters.
			EXTENDBACKCOLOR	- Extends the background color all the way to the edges of the client rectangle.
			USEAIMM			- Uses the AIMM input method component that ships with Microsoft Internet Explorer 4.0 or later.
			UPPERCASE		- Converts all input characters to uppercase.
			LOWERCASE		- Converts all input characters to lowercase.
			XLTCRCRLFTOCR	- Turns on translation of CRCRLFs to CRs. When this bit is on and a file is read in, all instances of CRCRLF will be converted to hard CRs internally. This will affect the text wrapping. Note that if such a file is saved as plain text, the CRs will be replaced by CRLFs. This is the .txt standard for plain text.
			SCROLLONKILLFOCUS - When KillFocus occurs, scroll to the beginning of the text.

 Returns:
			State of the edit style flags after rich edit has attempted to implement your edit style changes (number).
 */
RichEdit_SetEditStyle(hCtrl, Style)  {
	static EM_SETEDITSTYLE=0x4CC
		   ,SES_UPPERCASE=512, SES_LOWERCASE=1024, SES_XLTCRCRLFTOCR=16384, SES_EXTENDBACKCOLOR=4, SES_BEEPONMAXTEXT=2, SES_EMULATESYSEDIT=1, SES_USEAIMM=64, SES_SCROLLONKILLFOCUS=8192

	if bOff := (SubStr(Style, 1, 1) = "-")
		Style := SubStr(Style, 2)
	SendMessage, EM_SETEDITSTYLE, bOff ? 0 : SES_%Style%, SES_%Style%,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
 Function:  SetSel
			Selects a range of characters or Component Object Model (COM) objects in a rich edit control.

 Parameters:
			CpMin -	Beginning of range of characters to select.
			CpMax -	End of range of characters to select.

 Remarks:
			If the *cpMin* and *cpMax* members are equal, or *cpMax* is omitted, the cursor will be moved to
			*cpMin*'s position.  The range includes everything if *cpMin* is 0 and *cpMax* is –1.

 Returns:
			The selection that is actually set.

 Related:
			<HideSelection>, <SetText>, <GetSel>, <GetText>, <GetTextLength>

 Example:
 (start code)
  RichEdit_SetSel( hRichEdit, 4, 10 ) ; select range
  RichEdit_SetSel( hRichEdit, 2 )     ; move cursor to right of 2nd character
  RichEdit_SetSel( hRichEdit, 0, -1 ) ; select all
 (end code)
 */
RichEdit_SetSel(hCtrl, CpMin=0, CpMax=0)  {
	static EM_EXSETSEL=1079

	VarSetCapacity(CHARRANGE, 8), NumPut(cpMin, CHARRANGE, 0, "Int"), NumPut(cpMax ? cpMax : cpMin, CHARRANGE, 4, "Int")
	SendMessage, EM_EXSETSEL, , &CHARRANGE,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
 Function:	SetText
			Set text from string or file in rich edit control using either rich text or plain text.

 Parameters:
			Txt		- The text string to set within control. To set RTF mark-up the Txt must be prefixed with "{rtf".
			Flag	- Space separated list of options.  See below list.
			Pos		- This optional parameter allows you to specify a character position you want text inserted to,
					  rather than replacing current selection. To append to the end, use -1.
					  When using SELECTION flag, the position is relative to the current selection text and current selection is expanded to
					  contain new text. If used without SELECTION flag existing selection remains unafected.

 Flags:
			DEFAULT		- Deletes the undo stack, discards rich-text formatting, & replaces all text.
			KEEPUNDO	- Keeps the undo stack.
			SELECTION	- Replaces selection and keeps rich-text formatting. If you don't specify this style entire content of
						  the control will be replaced with the new text.
			FROMFILE	- Load a file into control.  If used, this option expects the *txt* parameter to be
						  a filename. If there is a problem loading the file, *ErrorLevel* will contain message.

 Returns:
		If the operation is setting all of the text and succeeds, the return value is 1.
		If the operation fails, the return value is zero.

 Related:
		<SetSel>, <GetText>, <GetSel>, <TextMode>

 Example:
 (start code)
  FileSelectFile, file,,, Select file, RTF(*.rtf; *.txt)
  RichEdit_SetText(hRichEdit, file, "FROMFILE KEEPUNDO")

  RichEdit_SetText(hRichEdit, "insert..", "SELECTION")

  RichEdit_SetText(hRichEdit, "replace all..")

  RichEdit_SetText(hRichEdit, "append to end of selection..", "SELECTION", -1 )
 (end code)
 */
RichEdit_SetText(HCtrl, Txt="", Flag=0, Pos="" )  {
	static EM_SETTEXTEX=0x461, ST_KEEPUNDO=1, ST_SELECTION=2

	hFlag=0
	If Flag
  		Loop, parse, Flag, %A_Tab%%A_Space%
			If (A_LoopField = "FROMFILE") {
			FileRead, Txt, %Txt%
			IfNotEqual, Errorlevel, 0, return false, ErrorLevel := A_ThisFunc "> Couldn't open file: '" Txt "'"
		} else if A_LoopField in KEEPUNDO,SELECTION
			hFlag |= ST_%A_LoopField%

  ; If specifying a pos, calculate new range for restoring original selection
	if (Pos != "")
		if (hFlag >= ST_SELECTION) {
			RichEdit_GetSel(HCtrl, min, max)
			ifLess, Pos, -1, SetEnv, Pos, 0
			else if (Pos > max-min)
				Pos := max-min

			ifEqual, Pos, -1, SetEnv, Pos, %max%
			else Pos += min

			prevPos := RichEdit_SetSel(HCtrl, Pos)
			max += StrLen(Txt)
		} else {
			hFlag |= ST_SELECTION, len := StrLen(Txt)
			RichEdit_GetSel(HCtrl, min, max)
			prevPos := RichEdit_SetSel(HCtrl, Pos)
			if (Pos < min)
				min += len, max += len
			else if (Pos >= min) && (Pos < max)
				max += len
		}

	VarSetCapacity(SETTEXTEX, 8), NumPut(hFlag, SETTEXTEX)
	NumPut(0, SETTEXTEX, 4)		  ;The code page is used to translate the text to Unicode. If codepage is 1200 (Unicode code page),
								  ; no translation is done. If codepage is CP_ACP (0), the system code page is used.
	SendMessage, EM_SETTEXTEX, &SETTEXTEX, &Txt,, ahk_id %HCtrl%
	return ERRORLEVEL, prevPos != "" ? RichEdit_SetSel(HCtrl, min, max) :
}

/*
 Function:  SetUndoLimit
			Set the maximum number of actions that can stored in the undo queue of the rich edit control.

 Parameters:
			nMax - The maximum number of actions that can be stored in the undo queue.

 Returns:
			The return value is the new maximum number of undo actions for the rich edit control.

 Remarks:
			By default, the maximum number of actions in the undo queue is 100. If you increase
			this number, there must be enough available memory to accommodate the new number.
			For better performance, set the limit to the smallest possible value needed.

 Related:
			<Undo>, <GetUndo>, <Redo>, <GetRedo>

 Example:
		> MsgBox, % RichEdit_SetUndoLimit( hRichEdit, 5 )
 */
RichEdit_SetUndoLimit(hCtrl, nMax)  {
	static EM_SETUNDOLIMIT=82,WM_USER=0x400
	if nMax is not integer
		return false
	SendMessage, WM_USER | EM_SETUNDOLIMIT, %nMax%,0,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
 Function:  ShowScrollBar
			Shows or hides scroll bars for Edit control.

 Parameters:
			Bar - Identifies which scroll bar to display: horizontal or vertical. This parameter must be
				  "*V*", "*H*", or a combination of the two.

			State - True or false.

 Remarks:
     This method is only valid when the control is in-place active. Calls made while the control is inactive may fail.

 Related:
     <ScrollPos>

 Example:
	 > RichEdit_ShowScrollBar( hRichEdit, "VH", false )
	 > Sleep, 3000
	 >
	 > RichEdit_ShowScrollBar( hRichEdit, "V", true )
 */
RichEdit_ShowScrollBar(hCtrl, Bar, State=true)  {
  static EM_SHOWSCROLLBAR=96,WM_USER=0x400,SB_HORZ=0,SB_VERT=1

	If ( StrLen(bar) <= 2)  {
		If InStr( Bar, "H" )
			SendMessage, WM_USER | EM_SHOWSCROLLBAR, SB_HORZ, State,, ahk_id %hCtrl%
		If InStr( Bar, "V" )
			SendMessage, WM_USER | EM_SHOWSCROLLBAR, SB_VERT, State,, ahk_id %hCtrl%
	}
}

/*
 Function:	TextMode
			Get or set the current text mode of a rich edit control.

 Parameters:
			TextMode - Space separated list of options (see below). If omitted, current text mode is returned.

 Options:
		Specify one of the following values to set the text mode parameter.
		If you don't specify a text mode value, the text mode remains at its current setting.

		PLAINTEXT		 - Indicates plain-text mode, in which the control is similar to a standard edit control.
		RICHTEXT		 - Indicates rich-text mode (default text mode).

		Specify one of the following values to set the undo level parameter. If you don't specify an undo level value, the undo level remains at its current setting.

		SINGLELEVELUNDO  - The control allows the user to undo only the last action in the undo queue.
		MULTILEVELUNDO	 - The control supports multiple undo actions (default undo mode).
						   Use <SetUndoLimit> to set the maximum number of undo actions.

		Specify one of the following values to set the code page parameter. If you don't specify an code page value, the code page remains at its current setting.

		SINGLECODEPAGE	 - The control only allows the English keyboard and a keyboard corresponding
						   to the default character set. For example, you could have Greek and
						   English. Note that this prevents Unicode text from entering the control.
						   For example, use this value if a rich edit control must be restricted to ANSI text.
		MULTICODEPAGE	 - The control allows multiple code pages and Unicode text into the control (default code page mode).

 Returns:
		If *TextMode* is omitted, the return value is the current text mode settings.
		When *TextMode* is given, function will return true or false.

 Remarks:
		The control text will be deleted when calling this function.

		In rich text mode, a rich edit control has standard rich edit functionality.
		However, in plain text mode, the control is similar to a standard edit control :

		- The text in a plain text control can have only one format (such as Bold, 10pt Arial).
		- The user cannot paste rich text formats, such as Rich Text Format (RTF) or embedded objects into a plain text control.
		- Rich text mode controls always have a default end-of-document marker or carriage return, to format paragraphs.
		- Plain text controls, on the other hand, do not need the default, end-of-document marker, so it is omitted.

 Related:
		<SetUndoLimit>

 Example:
	(start code)
	  MsgBox, % "mode= " RichEdit_TextMode(hRichEdit)

	  If RichEdit_TextMode( hRichEdit, "PLAINTEXT SINGLELEVELUNDO" )
			MsgBox, % "new mode= " RichEdit_TextMode(hRichEdit)
	  Else	MsgBox, % errorlevel
	(end code)
 */
RichEdit_TextMode(HCtrl, TextMode="")  {
  static EM_SETTEXTMODE=0x459, EM_GETTEXTMODE=0x45A
		,TM_PLAINTEXT=1, TM_RICHTEXT=2, TM_SINGLELEVELUNDO=4, TM_MULTILEVELUNDO=8, TM_SINGLECODEPAGE=16, TM_MULTICODEPAGE=32
		,TEXTMODES="MULTICODEPAGE,SINGLECODEPAGE,MULTILEVELUNDO,SINGLELEVELUNDO,RICHTEXT,PLAINTEXT"

	If (TextMode)  {    ; Setting text mode
		hTextMode := 0
		Loop, parse, TextMode, %A_Tab%%A_Space%
			ifEqual, A_LoopField,,continue
			else hTextMode |= TM_%A_LOOPFIELD%
	    IfEqual, hTextMode,, return false, ErrorLevel := A_ThisFunc "> Some of the options are invalid: " TextMode

		RichEdit_SetText(HCtrl)
		SendMessage, EM_SETTEXTMODE, hTextMode,,, ahk_id %HCtrl%
		return Errorlevel ? False : True
	}
	else  {				; Getting current text mode
		SendMessage, EM_GETTEXTMODE,,,, ahk_id %HCtrl%
		tm := ErrorLevel
		loop, parse, TEXTMODES,`,
			if (TM_%A_LoopField% & tm)
				res .= A_LoopField " "
		return SubStr(res, 1, -1)
	}
}

/*
 Function:		WordWrap
				Set word wrap mode in rich edit control.

 Parameters:
				Flag	- True or false.

 Returns:
				The return value is zero if the operation fails, or nonzero if it succeeds.

 */
RichEdit_WordWrap(HCtrl, Flag)  {
	static EM_SETTARGETDEVICE=0x448
	SendMessage, EM_SETTARGETDEVICE,,!Flag,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
 Function:	Zoom
			Sets the zoom ratio anywhere between 1/64 and 64.

 Parameters:
			zoom - Integer amount to increase or decrease zoom with *+* or *-* infront of it (see examples).

 Returns:
			If the new zoom setting is accepted, the return value is true.
			If the new zoom setting is not accepted, the return value is false.
			If *zoom* param is omitted, current numerator/denominator ratio is returned.

 Examples:
 > Msgbox, % "zoom ratio: " RichEdit_Zoom( hRichEdit )
 >
 > #MaxHotkeysPerInterval 200
 > #IfWinActive ahk_group RichEditGrp
 > ^WheelUp::   RichEdit_Zoom( hRichEdit, +1 )
 > ^WheelDown:: RichEdit_Zoom( hRichEdit, -1 )
 > #IfWinActive
 */
Richedit_Zoom(hCtrl, zoom=0)  {
  static EM_SETZOOM=225,EM_GETZOOM=224,WM_USER=0x400

  ; Get the current zoom ratio
  VarSetCapacity(numer, 4)  , VarSetCapacity(denom, 4)
  SendMessage, WM_USER | EM_GETZOOM, &numer,&denom,, ahk_id %hCtrl%
  numerator := NumGet(numer, 0, "UShort") ;, denominator := NumGet(denom, 0, "UShort")

  If zoom is not integer
    return false, errorlevel := "ERROR: '" zoom "' is not an integer, stupid"
  If (!zoom)
    return numerator "/" denominator

  ; Calculate new numerator value (denominator not currently changed)
  InStr(zoom,"-") ?  numerator-=SubStr(zoom,2)  :  numerator+=zoom

  ; Set the zoom ratio
  SendMessage, WM_USER | EM_SETZOOM, %numerator%, 1,, ahk_id %hCtrl%
  return ERRORLEVEL
}

/*
 Function:	Undo
			Send message to Edit control to undo the next action in the control's undo queue &
		  optionally empty the undo buffer by resetting the undo flag.

 Parameters:
			Reset - Set to true to clear the undo buffer rather than send undo command.

 Returns:
			For a single-line edit control, the return value is always true.
			For a multiline edit control, the return value is true if the undo operation is
			successful, or false if the undo operation fails, or your resetting the undo queue.
 */
RichEdit_Undo(hCtrl, Reset=false)  {
  static EM_UNDO=0xC7,EM_EMPTYUNDOBUFFER=0xCD
  If !reset  {
    SendMessage, EM_UNDO,,,, ahk_id %hCtrl%
    return ERRORLEVEL
  } else SendMessage, EM_EMPTYUNDOBUFFER,,,, ahk_id %hCtrl%
}

;========================================== PRIVATE ===================================================================

RichEdit_add2Form(hParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "x# y# w# h# style", x, y, w, h, style)
	hCtrl := RichEdit_Add(hParent, x, y, w, h, style, Txt)
	return hCtrl
}


RichEdit_onNotify(Wparam, Lparam, Msg, Hwnd) {
	static MODULEID := 091009, oldNotify="*", oldCOMMAND="*"
		  ,ENM_PROTECTED=1796, ENM_REQUESTRESIZE=1793, ENM_SELCHANGE=1794, ENM_DROPFILES=1795, ENM_DRAGDROPDONE=1804, ENM_LINK=1803

	critical		;its OK, always executed in its own thread.
	if (_ := (NumGet(Lparam+4))) != MODULEID
	 ifLess _, 10000, return	;if ahk control, return asap (AHK increments control ID starting from 1. Custom controls use IDs > 10000 as its unlikely that u will use more then 10K ahk controls.
	 else {
		ifEqual, oldNotify, *, SetEnv, oldNotify, % RichEdit("oldNotify")
		if oldNotify !=
			 return DllCall(oldNotify, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
		else return
		;ifEqual, oldCOMMAND, *, SetEnv, oldCOMMAND, % RichEdit("oldCOMMAND")
		;if oldCOMMAND !=
		;	return DllCall(oldCOMMAND, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
	 }

	hw :=  NumGet(Lparam+0), code := NumGet(Lparam+8, 0, "UInt"),  handler := RichEdit(hw "Handler")
	ifEqual, handler,,return code=ENM_PROTECTED ? TRUE : FALSE  ;ENM_PROTECTED msg returns nonzero value to prevent operation

	If (code = 1792) {					;ENM_MOUSEEVENTS ENM_KEYEVENTS ENM_SCROLLEVENTS
		static 258="KEYPRESS_DWN",513="MOUSE_L_DWN",514="MOUSE_L_UP",516="MOUSE_R_DWN",517="MOUSE_R_UP",522="SCROLL_BEGIN",277="SCROLL_END" ;,512="MOUSE_HOVER",256="KEYPRESS_UP"

		umsg := NumGet(lparam+12)		;Keyboard or mouse message identifier.
		key := ((n:=NumGet(lparam+40))>=32) ? Chr(n) : ""
		If (%umsg%)   ;***
			return %handler%(hw, %Umsg%, key, "", "")
	}

	If (code = ENM_REQUESTRESIZE)  {
		rc := NumGet(lparam+24) ;Requested new size.
		return %handler%(hw, "REQUESTRESIZE", rc, "", "")
	}

	if (code = ENM_SELCHANGE)  {
		cpMin := NumGet(lparam+12), cpMax := NumGet(lparam+16), selType := RichEdit_SelectionType(-NumGet(lparam+20))
		return %handler%(hw, "SELCHANGE", cpMin, cpMax, seltype)
	}

	If (code = ENM_DROPFILES)  {          ;
		hDrop := NumGet(lparam+8, 4 , "UInt"), cp := NumGet(lparam+8, 8 , "Int")

		; (thanks DerRaphael!)  http://www.autohotkey.com/forum/post-234905.html&highlight=#234905
		Loop,% file_count := DllCall("shell32.dll\DragQueryFile","uInt",hDrop,"uInt",0xFFFFFFFF,"uInt",0,"uInt",0) {
		   VarSetCapacity(lpSzFile,4096,0)
		   DllCall("shell32.dll\DragQueryFile","uInt",hDrop,"uInt",A_index-1,"uInt",&lpSzFile,"uInt",4096)
		   VarSetCapacity(lpSzFile,-1)
		   files .= ((A_Index>1) ? "`n" : "") lpSzFile
		}
		return %handler%(hw, "DROPFILES", file_count, files, cp)
	}

	If (code = ENM_DRAGDROPDONE)  {
		chars := NumGet(lparam+12), cpMax := NumGet(lparam+16)
		return %handler%(hw, "DRAGDROPDONE", chars, cpMax-chars, cpMax)
	}

	If (code = ENM_PROTECTED)  {
		cpMin := NumGet(lparam+24), cpMax := NumGet(lparam+28)
		return %handler%(hw, "PROTECTED", cpMin, cpMax, "") ; This message returns a nonzero value to prevent the operation.
	}

	If (code = ENM_LINK )  {
		umsg := NumGet(lparam+12)
		If umsg Not In 513,516
			 return
		cpMin := NumGet(lparam+24), cpMax := NumGet(lparam+28)
		return %handler%(hw, "LINK", (Umsg = 513 ? "LClick" : "RClick"), cpMin, cpMax) ; This message returns a nonzero value to prevent the operation.
	}
}

RichEdit_wndProc(hwnd, uMsg, wParam, lParam){

   if (uMsg = 0x87)  ;WM_GETDLGCODE
		return 4	 ;DLGC_WANTALLKEYS

   return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
}

RichEdit_editStreamCallBack(dwCookie, pbBuff, cb, pcb) {
	static s

	if (dwCookie="!") {
		fn := pbBuff
		ifEqual, fn,, return l := s, VarSetCapacity(s,0)
		FileDelete, %fn%
		FileAppend, %s%, %fn%
		return VarSetCapacity(s, 0)
	}

	if s =
		 VarSetCapacity(s, dwCookie)

	s .= DllCall("MulDiv", "Int", pbBuff, "Int",1, "Int", 1, "str")
}

;Mini storage
RichEdit(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") {
	static
	 _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}

/* Group: About
	o Version 1.0b2 by freakkk & majkinetor.
	o MSDN Reference : <http://msdn.microsoft.com/en-us/library/bb787605(VS.85).aspx>.
	o RichEdit control shortcut keys: <http://msdn.microsoft.com/en-us/library/bb787873(VS.85).aspx#rich_edit_shortcut_keys>.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
 */
