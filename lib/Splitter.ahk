/* Title:    Splitter
			 Splitter control.

			 (see splitter.png)

			 Splitter is control that is created between controls that need to have dynamic separation.
			 To use it, you first need to create the splitter (<Add>), then you have to activate it when all controls
			 that it separates are created (<Set>).
			 You can set splitter position with <SetPos> and obtain it with <GetPos>. 
			 You can also limit splitter movement with <Limit> function if you don't want controls it separates to be set completely invisible by the user.
			 
 Dependency:
			<Win> 1.24

 Effects:	
			- While user moves splitter, CoordMode of mouse is always returned to relative.
			- Upon movement, splitter will reset <Attach> for the parent, if present.			
 */

/*
 Function:	Add
 			Add new Splitter.
 
 Parameters:
 			Opt	    - Splitter Gui options. Splitter is subclassed Text control (Static), so it accepts any Text options.
					plus one the following: blackframe, blackrect, grayframe, grayrect, whiteframe, whiterect, sunken.
			Text    - Text to set.
			Handler - Notification function. See bellow.
			
 Handler:
 >			OnSplitter(Hwnd, Event, Pos)
		
			P - Triggered when user changes the position by dragging the splitter with mouse.
			D - User doubleclicked the splitter.
			R - User right clicked the splitter.

 Returns:
			Splitter handle.

 Remarks:
			This function adds a new splitter on the given position. User is responsible for correct position of the splitter.
			Splitter is inactive until you call <Set> function.
			When setting dimension of the splitter (width or height) use even numbers.
 */
Splitter_Add(Opt="", Text="", Handler="") {
	static SS_NOTIFY=0x100, SS_CENTER=0x200, SS_SUNKEN=0x1000, SS_BLACKRECT=4, SS_GRAYRECT=5, SS_WHITERECT=6, SS_BLACKFRAME=7, SS_GRAYFRAM=8, SS_WHITEFRAME=9

	hStyle := 0
	loop, parse, Opt, %A_Space%
		if A_LoopField in blackframe,blackrect,grayframe,grayrect,sunken,whiteframe,whiterect,sunken,center
			hStyle |= SS_%A_LoopField%
		else Opt .= A_LoopField " "

	Gui, Add, Text, HWNDhSep -hscroll -vscroll %SS_CENTERIMAGE% %SS_NOTIFY% center %Opt% %hStyle%, %Text%	
	hSep+=0
	if IsFunc(Handler)
		Splitter(hSep "Handler", Handler)
	return hSep
}

/*
 Function:	Add2Form
 			Add Splitter into the form. 

 Options:
			handler	- Splitter handler name.
			extra	- Extra parameters are transmited to <Add> Opt parameter.
 
 Remarks:
			Function is required by the Forms framework.
 */
Splitter_Add2Form(HParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "handler", handler, extra)
	DllCall("SetParent", "uint", hCtrl := Splitter_Add(extra, Txt, handler), "uint", HParent)
	return hCtrl
}

/*
 Function:	GetMax
 			Returns maximum position of the splitter.

 Remarks:
			Maximum position of the splitter will change if parent control is resized.
 */
Splitter_GetMax(HSep) {
	Win_Get( Win_Get(HSep, "P") , "Lwh", plw, plh)
	return (Splitter(HSep "bVert") ? plw : plh) - Splitter_getSize(HSep) - Splitter(HSep "L2")
}

Splitter_GetMin(HSep) {
	return Splitter(HSep "L1")
}

/*
 Function:	GetPos
 			Get position of the splitter.

 Parameters:
			Flag	- Set to "%" to return procentage instead position.

 Remarks:
			Position of the splitter is its x or y coordinate inside the parent window.
 */
Splitter_GetPos( HSep, Flag="" ) {
	pos := Win_GetRect(HSep, Splitter(HSep "bVert") ? "*x" : "*y")
	if (Flag = "%"){
		min := Splitter_GetMin(HSep), max := Splitter_GetMax(HSep)
		return 100*(pos-min)/(max-min)
	} else return pos
}

/*
 Function:	GetSize
 			Get size of the splitter.
 */
Splitter_GetSize(HSep) {
	Win_GetRect(HSep, "wh", w, h)
	return Splitter( HSep "bVert") ? w : h
}

/*
 Function:	Set
 			Initiates separation of controls.
 
 Parameters:
 			HSep - Splitter handle.
			Def	 - Splitter definition or words "off" or "on". The syntax of splitter definition is given bellow.
			Pos	 - Position of the splitter to apply upon initialization (optional).
			Limit - Decimal, sets start and end limits for splitter movement. The minimum and maximum splitter value will
					be adjusted by this value. For instance, .100 means that maximum value will be less by 100.

 Splitter Defintion:
 >		c11 c12 c13 ... Type c21 c22 c23 ...
		
		c1n - Controls left or top of the splitter.
		Type - Splitter type: " | " vertical or " - " horizontal.
		c2n	- Controls right or bottom of the splitter.
 */
Splitter_Set( HSep, Def, Pos="", Limit=0.0 ) {
	static

	if Def=off
		return Win_subclass(HSep, old)
	else if Def=on
		return Win_subclass(HSep, wndProc)

	if bVert := (InStr(Def, "|") != 0)
		Splitter(HSep "bVert", bVert)

	old := Win_subclass(HSep, wnadProc = "" ? "Splitter_wndProc" : wndProc, "", wndProc)

	StringSplit, L, Limit, .
	Splitter(HSep "Def", Def),  Splitter(HSep "L1", L1),  Splitter(HSep "L2", L2)
	return 	Splitter_SetPos(HSep, Pos)
}
/*
 Function:	SetPos
			Set splitter position.
 
 Parameters:
   			HSep - Splitter handle.
			Pos	 - Position to set. Position is the client x/y coordinate of the splitter control. 
				   If followed by the sign %, position is set using procentage of splitter range. 
				   If Pos is empty, function returns without any action. 

 Remarks:
			Due to the rounding, if you set position using procentage, actuall position may be slightly different.
			You can find out what is exact position set if you use <GetPos> with Flag set to "%".
 */
Splitter_SetPos(HSep, Pos, bInternal=false) {
	ifEqual, Pos,, return
	min := Splitter_GetMin(HSep), max := Splitter_GetMax(HSep)

	if SubStr(Pos, 0) = "%"
		Pos := min + SubStr(Pos, 1, -1)*(max-min)//100

	bVert := Splitter(HSep "bVert"),  Def := Splitter(HSep "Def")

	ifLess, Pos, %min%, SetEnv, Pos, %min%
	StringSplit, s, Def, %A_Space%

	Delta := Pos - Splitter_GetPos(HSep)
	v := bVert ? Delta : "",  h := bVert ? "" : Delta
	loop, %s0%
	{
		s := s%A_Index%
		if !otherSide
		{
			Win_MoveDelta(s, "", "", v, h)
			if s in |,-
				otherSide := true, Win_MoveDelta(HSep, v, h)
		} else 	Win_MoveDelta(s, v, h, -v, -h)
	}		
					
	Win_Redraw( Win_Get(HSep, "A") )						;redrawing imediate parent was not that good.
	IsFunc(f := "Attach") ? %f%( Win_Get(HSep, "P") ) : ""	;reset attach for parent of HSep

	if (handler := Splitter(HSep "Handler")) && bInternal
		%handler%(HSep, "P", Splitter_GetPos(HSep))
}

;=============================================== PRIVATE ===============================================

Splitter_wndProc(Hwnd, UMsg, WParam, LParam) {	
	static
	static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202, WM_LBUTTONDBLCLK=515, WM_RBUTTONUP=517, SIZENS := 32645, SIZEWE := 32644

	If (UMsg = WM_SETCURSOR)
		return 1 
	
	if (UMsg = WM_MOUSEMOVE) {
		if !%Hwnd%_cursor
			%Hwnd%_bVert := Splitter(Hwnd "bVert"), %Hwnd%_cursor := DllCall("LoadCursor", "Uint", 0, "Int", %Hwnd%_bVert ? SIZEWE : SIZENS, "Uint")

		critical 	;safe, always in new thread.
			DllCall("SetCursor", "uint", %Hwnd%_cursor)
		if moving 
			Splitter_updateFocus(Hwnd)
	}

	if (UMsg = WM_LBUTTONDOWN) {
		DllCall("SetCapture", "uint", Hwnd),  parent := DllCall("GetParent", "uint", Hwnd, "Uint")
		VarSetCapacity(RECT, 16), DllCall("GetWindowRect", "uint", parent, "uint", &RECT)

		sz := Win_GetRect(Hwnd, %Hwnd%_bVert ? "w" : "h") // 2
		ch := Win_Get(parent, "Nh" )			;get caption size of parent window

	  ;prevent user from going offscreen with separator
		NumPut( NumGet(RECT, 0) + sz-1	,RECT, 0)
		NumPut( NumGet(RECT, 4) + sz+ch ,RECT, 4)
		NumPut( NumGet(RECT, 8) - sz+4 	,RECT, 8)
		NumPut( NumGet(RECT, 12)- sz+4	,RECT, 12)
				
		DllCall("ClipCursor", "uint", &RECT), DllCall("SetCursor", "uint", %Hwnd%_cursor)
		moving := true
	}
	if (UMsg = WM_LBUTTONUP){
		moving := false
	
		DllCall("ClipCursor", "uint", 0),  DllCall("ReleaseCapture")
		Splitter_SetPos(Hwnd, Splitter_updateFocus(), true)
	}

	if UMsg in %WM_LBUTTONDBLCLK%,%WM_RBUTTONUP%
	{
		handler := Splitter(Hwnd "Handler")
		ifEqual, handler,,return

		ifEqual, UMsg, %WM_LBUTTONDBLCLK%, SetEnv, Event, D
		else ifEqual, UMsg, %WM_RBUTTONUP%, SetEnv, Event, R
			
		%handler%(Hwnd, Event, Splitter_GetPos(Hwnd))
	}

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",hwnd,"uint",uMsg,"uint",wParam,"uint",lParam)
}

;Updates focus rectangle while mouse is moving. 
;If called without arguments it returns latest focus rectangle position.
Splitter_updateFocus( HSep="" ) {
	static

	if !HSep
		return pos - offset, dc := 0
	
	MouseGetPos, mx, my
	if !dc 
	{
		ifEqual, adrDrawFocusRect,, SetEnv, adrDrawFocusRect, % DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "DrawFocusRect")
		CoordMode, mouse, relative

	  ;initialize dc, RECT, idx, delta(distance between mouse and splitter position), sz, pos & max when user starts moving.
		dc := Win_Get( HSep, "0D")		; take root DC, for some reason it doesn't work good on parent's DC

		Win_GetRect(HSep, "!xywh", sx, sy, sw, sh)
		VarSetCapacity(RECT, 16), NumPut(sx, RECT), NumPut(sy, RECT, 4), NumPut(sx+sw, RECT, 8), NumPut(sy+sh, RECT, 12) , sz := sh
		
		if bVert := Splitter( HSep "bVert" )
			 idx := 0,   delta := mx-sx,   sz := sw
		else idx := 4,   delta := my-sy,   sz := sh

      ;if in Panel, there will be offset to mouse movement according to its position.
		parent := Win_Get(HSep, "P")
		WinGetClass, cls, ahk_id %parent%
		offset :=  cls != "Panel" ? 0 : Win_GetRect( parent, bVert ? "!x" : "!y")

		pos := Splitter_GetPos(HSep),  
		max := offset + Splitter_getMax(HSep),	 min := offset + Splitter_getMin(HSep)
		return DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
	}
	pos := bVert ? mx-delta : my-delta
	ifLess, pos, %min%, SetEnv, pos, %min%
	else ifGreater, pos, %max%, SetEnv, pos, %max%

	DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
	NumPut(pos, RECT, idx),   NumPut(pos+sz, RECT, idx+8),  DllCall(adrDrawFocusRect, "uint", dc, "uint", &RECT)
}

;storage
Splitter(Var="", Value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") {
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
}

#include *i Win.ahk

/* Group: Examples
 (start code)
		w := 500, h := 600, sep := 5
		w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3

		Gui, Margin, 0, 0
		Gui, Add, Edit, HWNDc11 w%w1% h%h1%
		Gui, Add, Edit, HWNDc12 w%w1% h%h1%
		hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
		Gui, Add, Monthcal, HWNDc21 w%w2% h%h2% x+0
		Gui, Add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
		Gui, Add, ListBox,  HWNDc23 w%w2% h%h2% , 1|2|3

		sdef = %c11% %c12% | %c21% %c22% %c23%			;vertical splitter.
		Splitter_Set( hSepV, sdef )

		Gui, show, w%w% h%h%	
	return
 (end code)
 */

/* Group: About
	o Ver 1.6 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
 */