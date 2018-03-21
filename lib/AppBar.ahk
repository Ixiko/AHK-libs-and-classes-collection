
/*
	Title:	Appbar

			An application desktop toolbar (also called an appbar) is a window that is similar to the Microsoft Windows taskbar. 
			It is anchored to an edge of the screen, and it typically contains buttons that give the user quick access to other applications and windows. 
			The system prevents other applications from using the desktop area occupied by an appbar. 
			Any number of appbars can exist on the desktop at any given time.
 */

/* 
	Function:	New
				Creates new Appbar.
	
	Parameters:
				Hwnd	- Reference to the handle of the existing window. If variable is empty, function will create Gui
						  and you will get its handle returned in this parameter. 
				o1..o9	- Named arguments. All named arguments are optional.

	Named Arguments:
				Edge	 - Screen edge to glue Appbar to. Possible values are "Top" (default), "Right", "Left", "Bottom". 
				AutoHide - Makes Appbar autohide (off by default). Value represents animation type. Can be "Slide", "Blend" or "Center".
						   Window will be shown only if mouse is in its hot area. When Appbar is activated, it will not auto hide
						   until its deactivated again. 						   
				Pos		 - Position. String similar to AHK format without X and Y but with P instead. For instance "w300 h30 p10". "p" 
						   means position and it represents X for Edge type Top/Bottom or Y for Edge type Left/Right. If "p" is omitted
						   Appbar will be put in center. If "p" is negative, window is positioned the opposite end.
				Style	 - Space separated list of Appbar styles. See below.
				Label	 - Used when function creates Gui, and for making an AHK Group. By default Hwnd is added to the group. You can add
						   more windows in the group that are part of the taskbar. Appbar with autohide style will not be hidden when 
						   window belonging to its group is activated. By default "Appbar".

	Styles:	
				OnTop	 -  Sets the Appbar always on top.
				Show	 -  Show the Appbar. If not present the Appbar will not be shown or visibility settings of passed window will not be changed.
						    By default "OnTop Show Reserve".
				Pin		-   Pin the Appbar to the Desktop (reserve the desktop space for the Appbar). 
							The system prevents other applications from using the screen area occupied by the appbar. Ignored with AutoHide.

  Returns:
				Gui number if function created Gui.
 */
Appbar_New(ByRef Hwnd, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9=""){
	static CALLBACKMSG := 12345, ABM_SETAUTOHIDEBAR=8, ABM_NEW=0

	oldDetect := A_DetectHiddenWIndows
	DetectHiddenWIndows, on

   ;- handle args ------------
	Edge:="Top", AutoHide := Show := 0, Style := "OnTop Show Pin", Label := "Appbar"
	loop, 9	{
		f := o%A_Index%
		ifEqual, f,,break
		j := InStr(f, "="), n := SubStr(f, 1, j-1), %n% := SubStr(f,j+1)
	}

	StringSplit, s, Style, %A_Space%
	loop, %s0%
		s := s%A_Index%, %s% := 1

	StringSplit, s, Pos, %A_Space%
	loop, %s0%
		d := SubStr(s%A_Index%, 1, 1),	%d% := SubStr(s%A_Index%, 2)
   ;--------------------------

	if (Hwnd = "") {
		k := 1
		while (k != 0) {					;find available gui number
			n := 100 - A_Index
			Gui %n%:+LastFoundExist
			k := WinExist()
		}
		Gui, %n%:+LastFound -Caption +ToolWindow +Label%Label%
		Hwnd := WinExist()
		WinSet, Style, 0x400000	;WS_DLGFRAME
	} else WinGetPos, x, y, w, h, ahk_id %Hwnd%	
	Hwnd+=0
	ifEqual, h, ,SetEnv, h, % Edge="Top"  || Edge="Bottom" ? 36 : A_ScreenHeight
	ifEqual, w, ,SetEnv, w, % Edge="Left" || Edge="Right"  ? 50 : A_ScreenWidth

	VarSetCapacity(ABD,36,0), NumPut(36, ABD), NumPut(Hwnd, ABD, 4), NumPut(CALLBACKMSG, ABD, 8) 
	if (AutoHide || !Pin)
		 r := DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_SETAUTOHIDEBAR, "UInt", &ABD)
	else r := DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_NEW, "UInt", &ABD)

	if !r {
		ifNotEqual,n,, Gui, %n%:Destroy
		return 0
	} 

	Appbar_setPos(Hwnd, Edge, w, h, p)
	if Show {
		WinShow, ahk_id %Hwnd%
		WinActivate, ahk_id %Hwnd%
	}
	
	GroupAdd, %Label%, ahk_id %Hwnd%
	if AutoHide
		Appbar_setAutoHideBar(Hwnd, Edge, AutoHide, Label)

	if OnTop
		WinSet, AlwaysOnTop, on, ahk_id %Hwnd%

;	OnMessage(12345, "AppBar_onMessage")
	DetectHiddenWIndows, %oldDetect%
	return n
}

/*	Function:	Remove
				Unregisters an appbar by removing it from the system's internal list. 
				The system no longer sends notification messages to the appbar or prevents other applications from using the screen area occupied 
				by the appbar.
 */
Appbar_Remove(Hwnd){
	static ABM_REMOVE=1
	VarSetCapacity(ABD,36,0), NumPut(36, ABD), NumPut(Hwnd, ABD, 4)
	DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_REMOVE, "UInt", &ABD)
}

/*	Function: SetTaskBar
			  Set the state of the Taskbar.

	Parameters:
			State - "autohide", "ontop", "all". You can also remove (-), add (+) or toggle (^) state. Omit to disable all states.
					You can also pass "disable". This is the only good way to remove TaskBar (simply hiding the window isn't enough).					
					
	Return:
			Previous state. 

	Examples:
		(start code)
			Shell_SetTaskBar()				;remove all states of TaskBar
			Shell_SetTaskBar("+autohide")	;add autohide state
			Shell_SetTaskBar("-autohide")	;remove autohide state
			Shell_SetTaskBar("ontop")		;set state to ontop
			Shell_SetTaskBar("^ontop")		;toggle ontop state
			
			oldState := Shell_SetTaskBar("disable")		;disable it.
			Shell_SetTaskBar( oldState )				; & restore it when you are done ...


			;Hotkey to enable/disable taskbar in reliable way.
			F12::
				if bIsEnabled := !bIsEnabled
					oldState := AppBar_SetTaskbar("^disable")
			else	AppBar_SetTaskbar(oldState) 
		return
		(end code)
*/
Appbar_SetTaskBar(State=""){
	static ABM_SETSTATE=10, ABM_GETSTATE=4, AUTOHIDE=1, ONTOP=2, ALL=3, 1="AutoHide", 2="OnTop", 3="All"

	if (State="disable") {
		oldState := Appbar_SetTaskBar()
		WinHide, ahk_class Shell_TrayWnd
		return oldState
	}
		
	VarSetCapacity(ABD,36,0), NumPut(36, ABD), NumPut(Hwnd, ABD, 4)
	curState := DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_GETSTATE, "UInt", &ABD)
	c := SubStr(State, 1, 1)
	if (bToggle :=  c = "^") || (bDisable := c = "-") || (c = "+")
		State := SubStr(State, 2), b := 1

	ifEqual, State, ,SetEnv, State, 0
	else State := %State%

	sd := curState & ~State, sa := curState | State
	if (b)
		State := bToggle ? (curState & State ? sd : sa) : bDisable ? sd : sa 
	NumPut(State, ABD, 32), DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_SETSTATE, "UInt", &ABD)

	WinShow, ahk_class Shell_TrayWnd
	return (%curState%)
}

;=========================================== PRIVATE ================================================
;Copy of Win_Animate
AppBar_animate(Hwnd, Type="", Time=100){
	static AW_ACTIVATE = 0x20000, AW_BLEND=0x80000, AW_CENTER=0x10, AW_HIDE=0x10000,AW_HNEG=0x2, AW_HPOS=0x1, AW_SLIDE=0x40000, AW_VNEG=0x8, AW_VPOS=0x4

	hFlags := 0
	loop, parse, Type, %A_Tab%%A_Space%, %A_Tab%%A_Space%
		ifEqual, A_LoopField,,continue
		else hFlags |= AW_%A_LoopField%

	ifEqual, hFlags, ,return "Err: Some of the types are invalid"
	DllCall("AnimateWindow", "uint", Hwnd, "uint", Time, "uint", hFlags)
}


;not used atm. Should be used to reposition bar when other bars are created so there is no overlapping.
;wparam msg, lparam, msg parameter
AppBar_onMessage(Wparam, Lparam, Msg, Hwnd){
	static ABN_POSCHANGED=1, ABN_FULLSCREENAPP=2
	
	ifEqual, Wparam, ABN_FULLSCREENAPP, return		;shell keeps spamming this msg for some reason all the time ?!
	
	if (Wparam = ABN_POSCHANGED)
		Appbar_setPos(Hwnd)
}

Appbar_setAutoHideBar(Hwnd, Edge, AnimType, Label){
	static timer := 500
	
	d1 := Edge="Top" ? "vpos" : Edge="Left" ? "hpos" : Edge ="Right" ? "hneg" : "vneg"
	d2 := Edge="Top" ? "vneg" : Edge="Left" ? "hneg" : Edge ="Right" ? "hpos" : "vpos"
	animOn := AnimType " " d1, animOff := AnimType " hide " d2
	
	oldDetect := A_DetectHiddenWIndows
	DetectHiddenWIndows, on
	WinGetPos, x, y, w, h, ahk_id %Hwnd%
	DetectHiddenWIndows, %oldDetect%

	Appbar_timer(Hwnd, Edge, animOn, animOff, Label)
	SetTimer, %A_ThisFunc%, %timer%
	return
	
 Appbar_setAutoHideBar:
	Appbar_timer()
 return
}

Appbar_timer(Hwnd="", Edge="", Anim1="", Anim2="", Label="") {
	static

	if (Hwnd != "") {
		critical 50
		if !SX
			VarSetCapacity(POINT, 8)
			,adrGetCursorPos := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "GetCursorPos")
			,SY := A_ScreenHeight - 5, SX := A_ScreenWidth - 5, 

		Hwnd += 0
		oldDetect := A_DetectHiddenWindows
		DetectHiddenWIndows, on
		WinGetPos, wx, wy, ww, wh, ahk_id %Hwnd%
		DetectHiddenWIndows, %oldDetect%
		bVert := Edge="Left" || Edge="Right"

		%Hwnd%animOn := Anim1, %Hwnd%animOff := Anim2					
		%Hwnd%bVisible := DllCall("IsWindowVisible", "uint", Hwnd)
		%Hwnd%e := Edge="Top" || Edge="Left"		
		%Hwnd%d1 :=  bVert ? ww : wh,	%Hwnd%d2 := bVert ? wh : ww					;d1 - dimension , width or height depending on edge, d2 - the other one.
		%Hwnd%v1 :=  bVert ? "x" : "y",	%Hwnd%v2 := bVert ? "y" : "x"				;v1- affected variable for autohide, x or y depending on edge, v2 - the other one.
		%Hwnd%pos1 := bVert ? wy : wx,	%Hwnd%pos2:= %Hwnd%pos1 + (bVert ? wh : ww)	;limits for variable %v1% (x or y depending on edge)
		%Hwnd%HWnd := Hwnd, %Hwnd%Label := Label
		BARLIST .= (BARLIST != "" ? " " : "") Hwnd
		return
	}
	DllCall(adrGetCursorPos, "uint", &POINT), x := NumGet(POINT, 0, "Int"), y := NumGet(POINT, 4, "Int")
	loop, parse, BARLIST, %A_Space%
	{
		j := A_LoopField, Lbl := %j%Label
		ifWinActive ahk_group %Lbl%
			continue
		p := %j%v1,  q := %j%v2,  dp := %j%d1,  dq := %j%d2, Sp := S%p%, Sq := S%q%,  pos1 := %j%pos1,  pos2 := %j%pos2, e := %j%e
		p :=%p%, q:=%q%
		if ((e && p<5) || (!e && p>Sp-5))  && (q>pos1 && q<pos2)
			Appbar_animate(%j%Hwnd, %j%animOn), %j%bVisible := true
		else if (%j%bVisible) && (e && p>dp) || (!e && p<Sp-dp) || (q<pos1) || (q > pos2)
			Appbar_animate(%j%Hwnd, %j%animOff), %j%bVisible := false
	}
}

Appbar_setPos(Hwnd, Edge="", Width="", Height="", Pos=""){
	static ABM_QUERYPOS=2, ABM_SETPOS=3, LEFT=0, TOP=1, RIGHT=2, BOTTOM=3

	H := A_ScreenHeight, W := A_ScreenWidth,  bVert := InStr("Left,Right", Edge)

	Height .= !Height ? H : ""
	Width  .= !Width  ? W : ""
	Pos	   .= !Pos	  ? bVert ? (H-Height)//2 : (W-Width)//2 : ""
	ifLess, Pos, 0, SetEnv, Pos, % bVert ? H + Pos : W + Pos
	
	VarSetCapacity(ABD,36,0), NumPut(36, ABD), NumPut(Hwnd, ABD, 4), NumPut(%Edge%, ABD, 12)
	if Edge = LEFT
		 r1 := 0, r2 := Pos, r3 := Width, r4 := r2 + Height
	else if Edge = RIGHT
		 r1 := W - Width, r2 := Pos, r3 := W, r4 := r2 + Height
	else if Edge = Top
		 r1 := Pos, r2 :=0, r3 := r1+Width, r4 := Height
	else r1 := Pos, r2 :=H-Height, r3 := r1+Width, r4 := H
	loop, 4                                          
		NumPut(r%A_Index%, ABD, 12+A_Index*4, "Int") 

	DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_QUERYPOS, "UInt", &ABD)
	loop, 4
		r%A_Index% := NumGet(ABD, 12 + 4*A_Index, "Int")
                                               
	if Edge = LEFT
		 r3 := r1+Width
	else if Edge = RIGHT
		 r1 := r3-Width
	else if Edge = TOP
		 r4 := r2+Height
	else r2 := r4-Height
	loop, 48
		NumPut(r%A_Index%, ABD, 12+A_Index*4, "Int") 

	DllCall("Shell32.dll\SHAppBarMessage", "UInt", ABM_SETPOS, "UInt", &ABD)
	DllCall("MoveWindow", "uint", Hwnd, "int", r1, "int", r2, "int", r3-r1, "int", r4-r2, "uint", 1)

}

/* Group: About
	o v0.91 by majkinetor 
	o Reference: <http://msdn.microsoft.com/en-us/library/cc144177(VS.85).aspx>
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
/*