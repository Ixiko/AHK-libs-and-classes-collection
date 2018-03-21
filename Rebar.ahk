/*
  Title:    Rebar
 			Rebar control act as container for child windows. 
 			An application assigns child windows, which are often other controls, to a rebar control band. 
 			Rebar controls contain one or more bands, and each band can have any combination of a gripper bar, a bitmap, a text label, and a child window. 
 			However, bands cannot contain more than one child window. As you dynamically reposition a rebar control band, the rebar control manages the size 
			and position of the child window assigned to that band.
 			(See rebar.png)
 */

/*
  Function: Add
 			Add a rebar to the GUI.
 
  Parameters:
 			hGui	- Handle of the GUI.
 			Style	- White space separated list of styles. See bellow for details. By default "VARHEIGHT DBLCLKTOGGLE". Integer styles are allowed.
 			hIL		- Handle of the image list associated with the control. Optional.
			Pos		- Position of the rebar in usual AHK style. Optional.
			Handler - Notification handler.
 
  Styles:
 			autosize	 - The rebar control will automatically change the layout of the bands when the size or position of the control changes.
 			bandborders  - The rebar control displays narrow lines to separate adjacent bands.
 			dblclktoggle - The rebar band will toggle its maximized or minimized state when the user double-clicks the band. Without this style, the maximized or minimized state is toggled when the user single-clicks on the band.
 			fixedorder	 - The rebar control always displays bands in the same order. You can move bands to different rows, but the band order is static.
 			varheight	 - The rebar control displays bands at the minimum required height, when possible. Without this style, the rebar control displays all bands at the same height, using the height of the tallest visible band to determine the height of other bands.
 			verticalgripper - The size grip will be displayed vertically instead of horizontally in a vertical rebar control.
 			vertical	 - Causes the control to be displayed vertically.
 
  Handler:
	>		Handler(hCtrl, Event)
			
			Event	- C (Chevron click) L (Layout change)  H (Height change).
  
  Returns:
 			Handle to the newly created control or 0 if function failes. Error message is returned on invalid usage.
 */
Rebar_Add(hGui, Style="", hIL="", Pos="", Handler="") {
	static MODULEID, ICC_COOL_CLASSES := 0x400, RB_SETBARINFO=0x404, RB_SETUNICODEFORMAT=0x2005
	static WS_CHILD := 0x40000000, WS_VISIBLE := 0x10000000,  WS_CLIPSIBLINGS = 0x4000000, WS_CLIPCHILDREN = 0x2000000
	static RBS_VERTICALGRIPPER=0x4000, RBS_DBLCLKTOGGLE=0x8000, RBS_AUTOSIZE=0x2000, RBS_VARHEIGHT=0x200, RBS_NODIVIDER=0x40, RBS_BANDBORDERS=0x400, CCS_NORESIZE=0x4, CCS_NOPARENTALIGN=0x8, RBS_VERTICAL=0x80, RBS_BORDER=0x800000, RBS_FIXEDORDER = 0x800
 
	if MODULEID =
	{
		VarSetCapacity(ICC, 8),  NumPut(8, ICC, 0), NumPut(ICC_COOL_CLASSES, ICC, 4)
		if !DllCall("comctl32.dll\InitCommonControlsEx", "uint", &ICC) 
			return A_ThisFunc "> Can't initialize common controls" 

		old := OnMessage(0x4E, "Rebar_onNotify"), 	MODULEID := 30608
		if old != Rebar_onNotify
			Rebar("oldNotify", RegisterCallback(old))
	}
	ifEqual, Style,, SetEnv, Style, VARHEIGHT DBLCLKTOGGLE

	hStyle := 0
	loop, parse, Style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		ifEqual, A_LoopField,,continue
		else hStyle |= A_LoopField+0 ? A_LoopField : RBS_%A_LoopField%

	ifEqual, hStyle, ,return A_ThisFunc "> Some of the styles are invalid: " Style

	if (Pos != ""){
		x := y := 0, w := h := 100
		loop, parse, Pos, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		{
			ifEqual, A_LoopField, , continue
			p := SubStr(A_LoopField, 1, 1)
			if p not in x,y,w,h
				return A_ThisFunc "> Invalid position specifier: " p
			%p% := SubStr(A_LoopField, 2)
		}
		hStyle |= CCS_NOPARENTALIGN | CCS_NORESIZE
	}

	hRebar := DllCall("CreateWindowEx" 
             , "uint", 0
             , "str",  "ReBarWindow32" 
             , "uint", 0 
             , "uint", WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | hStyle
             , "uint", x, "uint", y, "uint", w, "uint", h
             , "uint", hGui 
             , "uint", MODULEID 
             , "uint", 0 
             , "uint", 0, "Uint") 
    ifEqual, hRebar, 0, return 0

	if hIL {
		VarSetCapacity(RBI, 12), NumPut(12, RBI), NumPut(1, RBI, 4), NumPut(hIL, RBI, 8)
		SendMessage, RB_SETBARINFO, 0, &RBI, , ahk_id %hRebar%
	}

	if IsFunc(Handler)
		Rebar(hRebar "handler", Handler)

	SendMessage, RB_SETUNICODEFORMAT,0,,,ahk_id %hRebar%		;!!! doesn't seem have effect, but again, no harm to call it
	return hRebar
}

/*
 Function:  Count
			Retrieves the number of bands in a rebar control.
 */
Rebar_Count(hRebar) {
	static RB_GETBANDCOUNT=0x40C	
    SendMessage, RB_GETBANDCOUNT,,,,ahk_id %hRebar%
	return ErrorLevel
}

/*
 Function:  DeleteBand
 			Deletes a band from a rebar control.
 
 Parameters:
 			WhichBand	- Band position or ID. Leave blank to get dimensions of the rebar control itself.
 
 Returns:
 			Nonzero if successful, or zero otherwise.
 */
Rebar_DeleteBand(hRebar, WhichBand){
	static RB_DELETEBAND = 0x402
	WhichBand := WhichBand >= 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1

  ;free the bitmap if it is set
	if h := Rebar_GetBand(hRebar, WhichBand, "B")
		DllCall("DeleteObject", "uint", h)

	SendMessage, RB_DELETEBAND,WhichBand,,,ahk_id %hRebar%
	return ErrorLevel
}

/*
 Function:  GetBand
 			Get band information.
 
 Parameters:
 			WhichBand	- Band position or ID.
 			pQ			- Query parameter: S (Style), L (Length), C (Color), I (Icon index), T (Text), N (identificatioN), B (Bitmap handle).
			o1..o7		- Reference to output variables.

 Returns:
 			o1
 */ 
Rebar_GetBand(hRebar, WhichBand, pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="") {
	static RBBIM_ID=0x100, RBBIM_COLORS=0x2, RBBIM_IMAGE=0x8, RBBIM_CHILD = 0x10, RBBIM_STYLE = 0x1, RBBIM_TEXT = 0x4, RBBIM_CHILDSIZE = 0x20, RBBIM_SIZE = 0x40, RBBIM_IDEALSIZE = 0x200, RBBIM_BACKGROUND=0X80
	static RB_GETBANDINFO=0x405

	hMask := RBBIM_TEXT | RBBIM_STYLE | RBBIM_SIZE | RBBIM_COLORS | RBBIM_IMAGE | RBBIM_ID
	WhichBand := WhichBand >= 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1 

	
	VarSetCapacity(BAND, 80, 0), NumPut(80,BAND), NumPut(hMask, BAND, 4)
	VarSetCapacity(wTxt, 64), NumPut(&wTxt, BAND, 20), NumPut(64, BAND, 24)
    SendMessage, RB_GETBANDINFO, WhichBand, &BAND, ,ahk_id %hRebar%
	ifEqual, Errorlevel, 0, return A_ThisFunc "> Can't get band info."

	loop, parse, pQ
	{
		if A_LoopField = T
			cch := NumGet(BAND, 24), VarSetCapacity(o%A_Index%, cch)
			, DllCall("WideCharToMultiByte" , "UInt", 0, "UInt", 0, "UInt", &wTxt, "Int", cch, "str", o%A_Index% , "Int", cch , "UInt", 0, "UInt", 0)
		 
		if A_LoopField = S
			o%A_Index% := Rebar_getStyle(NumGet(BAND, 8))

		if A_LoopField = L
			o%A_Index% := NumGet(BAND, 44)
	
		if A_LoopField = I
			img := NumGet(BAND, 28),   o%A_Index% := (pNames ? A_LoopField "=" : "") (img = 4294967295 ? 0 : img+1)

		if A_LoopField = C
			o%A_Index% := Rebar_getColor(NumGet(BAND, 12), 1) " " Rebar_getColor( NumGet(BAND, 16), 1)

		;private, not exposed
		if A_LoopField = N		;id
			o%A_Index% := NumGet(BAND, 52)

		if A_LoopField = B		;handle to bmp, so I can release it if band is deleted
			o%A_Index% := NumGet(BAND, 48)
	}
	
	return o1
}

/*
 Function:  GetLayout
			Get layout of bands in rebar. Layout is single line string containing information about position of bars in the rebar control.
			Return value of this function is fed into <SetLayout> later, to restore layout.
 */
Rebar_GetLayout(hRebar){
	loop, % ReBar_Count(hRebar)
		Rebar_GetBand(hRebar, A_Index, "NLS", n, l, s),  res .= n " " l " " (InStr(s, "break") ? 1 : 0) "|"
	return SubStr(res, 1, -1)
}

/*
 Function:  GetRect
 			Get band rectangle.
 
 Parameters:
 			WhichBand	- Band position or ID. Leave blank to get dimensions of the rebar control itself.
 			pQ			- Query parameter: set x,y,w,h to return appropriate value, or leave blank to return all in single line.
 			o1 .. o4	- Output variables.
 
 Returns:
 			String with 4 values separated by space or requested information.
 */
Rebar_GetRect(hRebar, WhichBand="", pQ="", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="") {
	static RB_GETRECT = 0x409

	if pQ =
		retAll := true, pQ := "xywh"

	VarSetCapacity(RECT, 16)
	if WhichBand =
		 DllCall("GetClientRect", "uint", hRebar, "uint", &RECT)
	else {
		WhichBand := WhichBand >= 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1
	    SendMessage, RB_GETRECT , WhichBand, &RECT, ,ahk_id %hRebar%
		IfEqual, ErrorLevel, 0, return A_ThisFunc "> Can't get band rect."
	}

	xx := NumGet(RECT, 0, "Int"), yy := NumGet(RECT, 4, "Int")
	loop, parse, pQ
		if A_LoopField = x
			o%A_Index% := xx
		else if A_LoopField = y
			o%A_Index% := yy
		else if A_LoopField = w
			o%A_Index% := NumGet(RECT, 8, "Int") - xx
		else if A_LoopField = h
			o%A_Index% := NumGet(RECT, 12, "Int") - yy

	return retAll ? o1 " " o2 " " o3 " " o4 : o1

}

/*
  Function: Height
 			Returns the height of the rebar control.
 */
Rebar_Height(hRebar){
	static RB_GETBARHEIGHT = 0x41B
	SendMessage, RB_GETBARHEIGHT,,,, ahk_id %hRebar%
	return Errorlevel
}


/*
 Function:	Id2Index
			Returns 1 based position of the band with given id.

 Parameters:
			Id	- ID of the band.
 */
Rebar_ID2Index(hRebar, Id){
	static RB_IDTOINDEX=0x410
	SendMessage, RB_IDTOINDEX, Id,,, ahk_id %hRebar%
	return Errorlevel+1
}

/*
 Function:	Insert
 			Inserts a new band in a rebar control.
 
 Parameters:
 			hCtrl			- Control to be hosted by the band.
 			o1 .. o8		- Named parameters. See below.
 
 Named parameters:
 			S				- Band styles separated by white space. By default "gripperalways". See bellow.
 			L				- Length of the band. By default, width of the child control is used + 10px
 			mW				- Minimum width of the child control.
 			mH				- Minimum height of the child control. By default the height of the child control.
 			I				- Header icon index.
 			T				- Header text.
 			C				- Background and foreground color separated by space.
 			BG				- Background bitmap.
 			P				- 1-based position of the band. Set to 0 add the band to the end (default).
 
 Band styles:
 			break			- The band is on a new line.
 			childedge		- The band has an edge at the top and bottom of the child window.
 			fixedbmp		- The background bitmap does not move when the band is resized.
 			fixedsize		- The band can't be sized. With this style, the sizing grip is not displayed on the band.
 			gripperalways	- The band will always have a sizing grip, even if it is the only band in the rebar.
 			hidden			- The band will not be visible. Don't use this flag in Insert function. Instead, insert the band without this flag, then use <SetBand> to hide it. To restore it afterwards, use SetBand with "S show" parameter.
 			nogripper		- The band will never have a sizing grip, even if there is more than one band in the rebar.
 			usechevron		- Show a chevron button if the band is smaller than ideal.
 			novert			- Don't show when vertical.
 			hidetitle		- Keep band title hidden.
 			*				- Default styles for the band. For instance "* break" will set band style to default plus "break" style.
 
 Returns:
 			ID of the newly created band or 0 if it fails.

 Remarks:
			For some reason, using the Gui, Font to change font size before adding ComboBox child to the band will make it buggy in a sense
			that ComboBox list will not be able to show (although you can still select items using arrows). 


	
 */
Rebar_Insert(hRebar, hCtrl, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9=""){
	static RB_INSERTBANDA=0x401

	if !(hCtrl+0)
		return A_ThisFunc "> Invalid child handle: " hCtrl

	pos := Rebar_compileBand(BAND, hCtrl, o1, o2, o3, o4, o5, o6, o7, o8, o9)
	if pos is not Integer
		return pos
	
	SendMessage, RB_INSERTBANDA, pos, &BAND,, ahk_id %hReBar% 
	ifEqual, ErrorLevel, 0, return 0
	return 	NumGet(BAND, 52)   ;return ID
}


/*
  Function: Lock
 			Locks or unlcoks the rebar (sets or removes "nogripper" style for all bands in rebar)
 
  Parameters:
 			Lock - Leave empty to lock, set to "-" to unlock, set to "~" to toggle.
 */
Rebar_Lock(hRebar, Lock="") {
	if Lock !=
		if Lock not in -,~
			return A_ThisFunc "> Invalid parameter: " Lock

	c := Rebar_Count(hRebar)
	if Lock = ~
		Lock := InStr(Rebar_GetBand(hRebar, c, "S"), "nogripper") ? "-" : ""
	
	loop, %c%
		Rebar_SetBandStyle(hRebar, A_Index, Lock "nogripper")
}

/*
 Function:	MoveBand
 			Moves a band from one index to another.
 
 Parameters:
 			From - 1-based index of the band to be moved.
 			To	 - 1-based index of the new band position. By default 1 (i.e. move to top).
 
 Returns:
 			TRUE if successful, or FALSE otherwise.
 */
Rebar_MoveBand(hRebar, From, To=1){
	static RB_MOVEBAND = 0x427
	SendMessage, RB_MOVEBAND, From-1, To-1, ,ahk_id %hRebar%
	res := ErrorLevel
	Rebar_ShowBand(hRebar, 1)		;?! without this it doesn't work ... it doesn't have to be 1, but just one show command. 1 is safe as you will alawyas have 1st band visible.
	return res
}


/*
 Function:	SetBand
			Sets characteristics of an existing band in a rebar control.

 Parameters:
			WhichBand	- Band position or ID that is about to be changed.
			o1 .. o9	- Named parameters. Any named parameter that can be specified in <Add> function can be used here.

 Returns:
			TRUE if successful, FALSE otherwise.

 */
Rebar_SetBand(hRebar, WhichBand, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9=""){
	static RB_SETBANDINFOA = 0x406
	WhichBand := WhichBand > 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1

	p := Rebar_compileBand(BAND, 0, o1, o2, o3, o4, o5, o6, o7, o8, o9)

	SendMessage, RB_SETBANDINFOA, WhichBand, &BAND, ,ahk_id %hRebar%
	if (p != -1)
		Rebar_MoveBand(hRebar, WhichBand+1, p+1)
		
	return ErrorLevel
}

/*
  Function: SetBandState
 			Minimize or maximize the band.
 
  Parameters:
 			WhichBand	- Band position or ID. Leave blank to get dimensions of the rebar control itself.
 			State		- Set "-" to minimize, "+" to maximize to full width, "*" to maximize to ideal width (this is the width of the control when it is added to the band).
 */
Rebar_SetBandState(hRebar, WhichBand, State) {
	static RB_MAXIMIZEBAND=0x41F, RB_MINIMIZEBAND=0x41E
	
	WhichBand := WhichBand > 10000 ? Rebar_Id2Index(hRebar, WhichBand)-1 : WhichBand-1
	if (State = "-")
		SendMessage, RB_MINIMIZEBAND, WhichBand,, , ahk_id %hRebar%
	else if State in +,*
		SendMessage, RB_MAXIMIZEBAND, WhichBand, State = "*" ? 1 : 0, , ahk_id %hRebar%
}

/*
  Function: SetBandWidth
 			Sets the width for a band.
 
  Parameters:
 			WhichBand	- Band position or ID.
 			Width		- Width.
 
  Returns:
 			TRUE if the value was set and FALSE otherwise.
 */	 
Rebar_SetBandWidth(hRebar, WhichBand, Width) {
	static RB_SETBANDINFOA = 0x406
	WhichBand := WhichBand > 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1
	
	VarSetCapacity( BAND, 80 )
	 ,NumPut(80	   ,BAND)
	 ,NumPut(0x40  ,BAND, 4)	;mask
	 ,NumPut(Width ,BAND, 44)    ;cx 
	SendMessage, RB_SETBANDINFOA, WhichBand, &BAND, ,ahk_id %hRebar%
	return ErrorLevel
}

/*
 Function:	SetBandStyle
			Sets the style for a band.

 Parameters:
			WhichBand	- Band position or ID.
			Style		- List of styles to add/remove for the band. Use - prefix to remove the style.

 Returns:
			TRUE if successful, or FALSE otherwise.

 Remarks:
			If you want to to replace band styles completely use <SetBand> function with S parameter.
			This function toggles desired styles.
 */

Rebar_SetBandStyle(hRebar, WhichBand, Style) {
	static RB_SETBANDINFOA = 0x406, RB_GETBANDINFO=0x405
	WhichBand := WhichBand >= 10000 ? Rebar_Id2Index(hrebar, WhichBand)-1 : WhichBand-1

	VarSetCapacity( BAND, 80 ),  NumPut(80 ,BAND),  NumPut(1,BAND, 4)
	StringReplace, Style, Style, ?, ,A
    SendMessage, RB_GETBANDINFO, WhichBand, &BAND, ,ahk_id %hRebar%

	hStyle := Rebar_getStyle( Style, true, hNegStyle) | NumGet(BAND,8),   hStyle &= hNegStyle
	ifEqual, hStyle, ,return A_ThisFunc "> Some of the styles are invalid: " Style

	NumPut(hStyle ,BAND, 8)		;style
	SendMessage, RB_SETBANDINFOA, WhichBand, &BAND, ,ahk_id %hRebar%
	return ErrorLevel
}

/*
 Function:  SetLayout
			Set layout of bands in rebar.

 Parameters:
			Layout	- String with information about position of bands in rebar control.
					  Use <GetLayout> function to get this string. Layout syntax is:
			
			> id1 len1 break1|id2 len2 break2|....|idN lenN breakN

 */
Rebar_SetLayout(hRebar, Layout) {
	loop, parse, Layout, |
	{
		StringSplit, L, A_LoopField, %A_Space%
		pos := Rebar_ID2Index(hRebar, L1)
		, Rebar_SetBandStyle(hRebar, pos, (L3 ? "" : "-") "break")
		, Rebar_SetBandWidth(hRebar, pos, L2)
		, Rebar_MoveBand(hRebar, pos , A_Index)
	}
}

/*
	Function: SizeToRect

	Parameters:
			RECT	- Reference to rectangle structure. If omited, parents rectangle will be used (GetClientRect).

	Remarks:
			The rebar bands will be arranged and wrapped as necessary to fit the rectangle. 
			Bands that have the VARIABLEHEIGHT style will be resized as evenly as possible to fit the rectangle. 
			The height of a horizontal rebar or the width of a vertical rebar may change, depending on the new layout.

 */
Rebar_SizeToRect(hRebar, ByRef RECT="~`a "){
	static RB_SIZETORECT = 0x417
	
	hParent := DllCall("GetParent", "uint", hRebar)
	
	if (RECT != "~`a ")
		VarSetCapacity(RECT, 16),  DllCall("GetClientRect", "uint", hParent, "uint", &RECT)

	SendMessage, RB_SIZETORECT, 0, &RECT, , ahk_id %hRebar%
	return ErrorLevel
}


/*
 Function:  ShowBand
 			Shows or hides the band.
 
 Parameters:
 			WhichBand	- Band position or ID. Leave blank to get dimensions of the rebar control itself.
 			bShow		- True to show the band (default), FALSE to hide it. 
 
 Returns:
 			TRUE if successful, or FALSE otherwise.

 Remarks:
			This function can also be used to resize the band to mach the parents size. 
			Put call to this function inside GuiSize routine. Update to first band will reposition all bands to match the Gui size.
return

 */
Rebar_ShowBand(hRebar, WhichBand, bShow=true) {
	static RB_SHOWBAND=0x423
	WhichBand := WhichBand >= 10000 ? Rebar_Id2Index(hRebar, WhichBand)-1 : WhichBand-1

    SendMessage, RB_SHOWBAND, WhichBand, bShow,,ahk_id %hRebar%
	return Errorlevel
}


;================================== PRIVATE ===========================================

; hCtrl - if 0 band is changing, if handle band is adding
Rebar_compileBand(ByRef BAND, hCtrl, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7="", ByRef o8="", ByRef o9=""){
	static RBBIM_ID=0x100, RBBIM_COLORS=0x2, RBBIM_IMAGE=0x8, RBBIM_CHILD = 0x10, RBBIM_STYLE = 0x1, RBBIM_TEXT = 0x4, RBBIM_CHILDSIZE = 0x20, RBBIM_SIZE = 0x40, RBBIM_IDEALSIZE = 0x200, RBBIM_BACKGROUND=0X80
	static id=10000, NP_T		;Text is made static so buffer can outlive call to this function.

	if hCtrl
		ControlGetPos, , ,wIdeal, NP_mH, , ahk_id %hCtrl%

	NP_T =
	loop, 10 { 
		if (o%A_index% = "")
			break
		j := InStr( o%A_index%, A_Space ),  prop := SubStr( o%A_index%, 1, j-1), NP_%prop% := SubStr( o%A_index%, j+1, 100) 
	}

	if NP_C !=
		NP_C .= " ", j := InStr(NP_C, A_Space), bg := Rebar_getColor( SubStr(NP_C, 1, j-1)), fg := Rebar_getColor( SubStr(NP_C, j+1) )

  ;handle styles	
	if NP_S !=
		if (hStyle := Rebar_getStyle( NP_S, true )) = ""
			return A_ThisFunc "> Some of the styles are invalid."

  ;set mask
	hMask := (NP_T != "" ? RBBIM_TEXT : 0)
			|(hStyle ? RBBIM_STYLE : 0) 
			|(NP_BG != "" ? RBBIM_BACKGROUND : 0) 
			|(NP_I ? RBBIM_IMAGE : 0)  
			|(NP_C != "" ? RBBIM_COLORS : 0) 
			|(hCtrl ? RBBIM_SIZE | RBBIM_CHILD | RBBIM_IDEALSIZE | RBBIM_ID : 0) ;RBBIM_SIZE only on update
			|(NP_mW or NP_mH ? RBBIM_CHILDSIZE : 0) 

  ;set calculated 
	hBmp := (NP_BG  != "") ? DllCall("LoadImage", "uint", 0, "str", NP_BG, "uint", 0, "uint", 0, "uint", 0, "uint", 0x10) : 0
	NP_L := (NP_L+0 != "") ? NP_L : wIdeal + 10		;if no len is specified use controls width + something for header
	id	 += hCtrl ? 1 : 0
 
	VarSetCapacity(BAND, 80, 0)
	 ,NumPut(80		,BAND)			;cbSize
	 ,NumPut(hMask	,BAND, 4)		;mask
	 ,NumPut(hStyle	,BAND, 8)		;style
	 ,NumPut(fg		,BAND, 12)      ;clrFore
	 ,NumPut(bg		,BAND, 16)      ;clrBack
	 ,NumPut(&NP_T	,BAND, 20)      ;lpText 
	 ,NumPut(NP_I-1	,BAND, 28)		;iImage
	 ,NumPut(hCtrl	,BAND, 32)      ;hwndChild 
	 ,NumPut(NP_mW	,BAND, 36)		;cyMinChild 
	 ,NumPut(NP_mH	,BAND, 40)		;cyMinChild 
	 ,NumPut(NP_L 	,BAND, 44)      ;cx 
	 ,NumPut(hBmp	,BAND, 48)		;hbmBack
	 ,NumPut(id		,BAND, 52)		;wID
	 ,NumPut(wIdeal	,BAND, 68)		;cxIdeal		;Ideal width of the band, in pixels. If the band is maximized to the ideal width (see RB_MAXIMIZEBAND), the rebar control will attempt to make the band this width.
	 ;NumPut(lparam	,BAND, 72)		;lParam			;Application-defined value.

	 return (NP_P+0 != "") ? NP_P-1 : -1			;return position on which to add band
}


;=========================================================== PRIVATE =======================================================
;Required function by Forms framework.
Rebar_add2Form(hParent, Txt, Opt) {
	static f := "Form_Parse"
	
	%f%(Opt, "x# y# w# h# style IL* g*", x,y,w,h,style,il,handler)
	pos := (x!="" ? " x" x : "") (y!="" ? " y" y : "") (w!="" ? " w" w : "") (h!="" ? " h" h : "")
	return Rebar_Add(hParent, style, il, pos, handler)
}

/*
  Function has 3 purposes :
 	o List evaluation: hex value out of list of style names
 	o Hex evaluation: list of style names out of hex value
 	o Negative list evaluation: hex value out of negative styles
 
  The problem is that style list can also contain numbers or be number (for instance: "novert 0x40 break" or just "0x40"). This is the purpose of pHex parameter that forces list evaluation or hex evaluation.
  Negative list evaulation is returned only if input variable is fed into the function. 
 
  The function is generic in sense that only statics need to be changed for any module to use it with its own styles.
 	o List of styles with prefix STYLE goes in first static row
 	o Ordered list of styles to be used for hex evaluation
    o DEFAULT style is hex combination of default styles for control. * in list of style names is replaced with default styles.
 
  pStyle    - Hex value of the style or named style
  pHex	    - Force pStyle as hex input.
  pNegStyle - Hex value of the negative styles
 */
Rebar_getStyle( pStyle, pHex = false, ByRef hNegStyle=""){
	static STYLE_HIDDEN=0x8, STYLE_BREAK=1, STYLE_FIXEDSIZE=0x2, STYLE_FIXEDBMP=0x20, STYLE_NOVERT=0x10, STYLE_VARIABLEHEIGHT=0x40, STYLE_CHILDEDGE=0x4, STYLE_USECHEVRON=0x200, STYLE_GRIPPERALWAYS = 0x80, STYLE_HIDETITLE = 0x400, STYLE_NOGRIPPER = 0x100
	static styles = "hidden,break,fixedbmp,novert,usechevron,fixedsize,gripperalways,hiddetittle,nogripper", STYLE_DEFAULT = 0x80	;GRIPPERALWAYS

  ;get hex value of named style
	if (pStyle+0 = "") or pHex 
	{
		StringReplace, pStyle, pStyle, *, DEFAULT, A

		hStyle := 0, hNegStyle := 0xFFFFFFFF
		loop, parse, pStyle, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		{
			ifEqual, A_LoopField,,continue
			if SubStr(A_LoopField, 1,1) = "-"
				s := SubStr(A_LoopField, 2), s := STYLE_%s%, hNegStyle &= ~s
			else hStyle |= A_LoopField+0 ? A_LoopField : STYLE_%A_LoopField%
		}
		return hStyle
	}

  ;return name of the style from hex
	else {
		loop, parse, styles, `,
			if (pStyle & STYLE_%A_LoopField%)
				style .= A_LoopField " "
		return SubStr(style, 1,-1)
	}
}

/*
 Converts AHK color (RGB without "0x") to Win color or vice-versa

 pColor	- Color to convert. Can be AHK color or Win color
 pAHK	- if true, input is AHK color, if false, input is Win color
 */
Rebar_getColor(pColor, pAHK = false) {

 ;convert to win
	if !pAHK {
		pColor := "0x" pColor
		return ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 
	}

 ;convert to rgb 
	oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format.  

	pColor := (pColor & 0xff00) + ((pColor & 0xff0000) >> 16) + ((pColor & 0xff) << 16) 
    StringTrimLeft, pColor, pColor, 2 
    loop, % 6-strlen(pColor) 
      pColor = 0%pColor% 

	SetFormat, integer, %oldFormat% 
	StringUpper, pColor, pColor
	return pColor
}


Rebar_onNotify(Wparam, Lparam, Msg, Hwnd) {
	static MODULEID := 30608, oldNotify="*"
	static RBN_LAYOUTCHANGED = -833, RBN_HEIGHTCHANGE = -831, RBN_CHEVRONPUSHED = -841, RBN_CHILDSIZE = -839

	if (_ := (NumGet(Lparam+4))) != MODULEID
	 ifLess _, 10000, return	;if ahk control, return asap (AHK increments control ID starting from 1. Custom controls use IDs > 10000. Its unlikely that u will use more then 10K ahk controls.
	 else {
		ifEqual, oldNotify, *, SetEnv, oldNotify, % Rebar("oldNotify")		
		if oldNotify !=
			return DllCall(oldNotify, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
	 }

	hw := NumGet(Lparam+0),  code := NumGet(Lparam+8, 0, "Int"),  handler := Rebar(hw "Handler")	
	ifEqual, handler, ,return

	if (code = RBN_CHEVRONPUSHED)
		%handler%(hw, "C")

	if (code = RBN_HEIGHTCHANGE)
		%handler%(hw, "H")

	if (code = RBN_LAYOUTCHANGED)
		%handler%(hw, "L")

;	if (code = RBN_CHILDSIZE)	;spammer msg
;		%handler%(hw, "S")

}

Rebar_malloc(pSize){
	static MEM_COMMIT=0x1000, PAGE_READWRITE=0x04
	return DllCall("VirtualAlloc", "uint", 0, "uint", pSize, "uint", MEM_COMMIT, "uint", PAGE_READWRITE)
}

Rebar_mfree(pAdr) {
	static MEM_RELEASE = 0x8000
	return DllCall("VirtualFree", "uint", pAdr, "uint", 0, "uint", MEM_RELEASE)
}

;Mini storage function
Rebar(var="", value="~`a") { 
	static
	_ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}

/* Group: Examples
	(start code)
		Gui, +LastFound +Resize 
		hGui := WinExist() 
		Gui, Show, w400 h140 hide			;set window size, mandatory

	  ;create edit
		Gui, Add, Edit, HWNDhEdit w100 h100

	  ;create combo
		Gui, Add, ComboBox, HWNDhCombo w80, item 1 |item 2|item 3

	  ;create rebar	
		hRebar := Rebar_Add(hGui)
		ReBar_Insert(hRebar, hEdit, "mw 100", "L 400", "T Log ")	;Insert edit band, set lenght of the band to 400
																	; minimum width of edit to 100, set text to "Log "
		ReBar_Insert(hRebar, hCombo, "L 300", "P 1")				;Insert combo band at the top, set length of the band to 300

		Gui, Show
	return 
	(end code)
 */

/* Group: About
	o Ver 2.02 by majkinetor. 
	o MSDN Reference: <http://msdn.microsoft.com/en-us/library/bb774375(VS.85).aspx>.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.
*/
