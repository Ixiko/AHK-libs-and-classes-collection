; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) **************

; ****** HINT: Debug-lines should contain "; _DBG_" at the end of lines - using this, the debug lines could be automatically removed through scripts before releasing the sourcecode

#include %A_LineFile%\..
#include Recty.ahk
#include Pointy.ahk
#include MultiMony.ahk
#include Mony.ahk
#include Const_WinUser.ahk
#include _WindowHandlerEvent.ahk
#include ..\SerDes.ahk
#include ..\DbgOut.ahk

class Windy {
; ******************************************************************************************************************************************
/*
	Class: Windy
		Perform actions on windows using an unified class based interface

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/
	_version := "0.10.3"
	_debug := 0
	_hWnd := 0

	__useEventHook := 1
	_hWinEventHook1 := 0
	_hWinEventHook2 := 0
	_HookProcAdr := 0
		
	_bManualMovement := false

	_posStack := 0

	; ##################### Start of Properties (AHK >1.1.16.x) ############################################################
	activated[] {
	/* ---------------------------------------------------------------------------------------
	Property: activated [get/set]
	Set/Unset the current window as active window or get the current state

	Value:
	flag - *true* or *false* (activates/deactivates *activated*-Property)
	
	Remarks:		
	* To toogle, simply use
	>obj.activated := !obj.activated
	*/
		get {
			hwnd := this.hwnd
			val := WinActive("ahk_id " hwnd)
			ret := (val) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret " (" val ")", this.debug)
			return ret
		}
		set {
			hwnd := this.hwnd
			if (value == true)
				WinActivate, ahk_id hwnd
			else if (value == false) 
				WinActivate, ahk_class Shell_TrayWnd  ; see: https://autohotkey.com/board/topic/29314-windeactivate/
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> New Value:" this.activated, this.debug)
		
			return this.activated
		}
	}
	alwaysOnTop[] {
	/* ---------------------------------------------------------------------------------------
	Property: alwaysOnTop [get/set]
	Set/Unset alwaysontop flag of the current window or get the current state
			
	Value:
	flag - *true* or *false* (activates/deactivates *alwaysontop*-Property)
	
	Remarks:		
	* To toogle, simply use
	>obj.alwaysontop := !obj.alwaysontop
	*/
		get {
			ret := (this.styleEx & WS.EX.TOPMOST) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}
		set {
			hwnd := this.hwnd
			if (value == true)
				value := "on"
			else if (value == false) 
				value := "off"
			WinSet, AlwaysOnTop, %value%,  ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> New Value:" this.alwaysontop, this.debug)
			return this.alwaysOnTop
		}
	}
	caption[] {
	/* ---------------------------------------------------------------------------------------
	Property: caption [get/set]
	Set/Unset visibility of the window caption
			
	Value:
	flag - *true* or *false* (activates/deactivates *caption*-Property)
	
	Remarks:		
	* To toogle, simply use 
	> obj.caption := !obj.caption
	*/
		get {
			ret := (this.style & WS.CAPTION) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
		; Idea taken from majkinetors Forms Framework (https://github.com/maul-esel/FormsFramework), win.ahk
			style := "-" this.__hexStr(WS.CAPTION)
			if (value) {
				style := "+" this.__hexStr(WS.CAPTION)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.caption, this.debug)
			return value
		}
	}
	captionHeight[] {
	/* ---------------------------------------------------------------------------------------
	Property: captionHeight [get]
	Height of the caption bar 

	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			SysGet, val, 4
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " val, this.debug)
			return val
		}
	}
	centercoords[] {
	/* ---------------------------------------------------------------------------------------
	Property: centercoords [get/set]
	Coordinates of the center of the window as a <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	Value:
	coords - centercoordinates of the window
	*/

		get {
			pos := this.posSize
			x := Round((pos.w)/2 + pos.x)
			y := Round((pos.h)/2 + pos.y)
			centerPos := new Pointy(x,y,this._debug)
			dbgOut("=[" A_ThisFunc "(pos="pos.dump() " [" this.hwnd "])] -> " centerPos.dump(), this.debug)
			return centerPos
		}

		set {
			currCenter := this.centercoords
			currPos := this.posSize
		
			xoffset := value.x - currCenter.x
			yoffset := value.y - currCenter.y
		
			x := currPos.x + xoffset
			y := currPos.y + yoffset
		
			this.move(x,y,99999,99999)
			centerPos := this.centercoords
			dbgOut("=[" A_ThisFunc "(pos=" value.dump() " [" this.hwnd "])] -> " centerPos.dump(), this.debug)
			return centerPos
		}
	}
	classname[] {
	/* ---------------------------------------------------------------------------------------
	Property: classname [get]
	name of the window class. 

	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			val := this.hwnd
			WinGetClass, __classname, ahk_id %val%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "]) -> (" __classname ")]", this.debug)
			return __classname
		}
	}
	clickThrough[transparency := 128, alwaysOnTop := 0] {
	/* ---------------------------------------------------------------------------------------
	Property: clickThrough [get/set]
	Set/Unset clickThrough flag of the current window or get the current state

	When a Window is set to clickthrough, its recommended to set the *alwaysontop*-Property as well

	Parameters:
	transparency - transparency to be set on clickthrough. If clickthrough is disabled transparency will be switched off
			
	Value:
	flag - *true* or *false* (activates/deactivates *clickThrough*-Property)
	
	Remarks:		
	* To toogle, simply use
	>obj.clickThrough := !obj.clickThrough
	*/
		get {
			ret := (this.styleEx & WS.EX.CLICKTHROUGH) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}
		set {
			hwnd := this.hwnd
			if (value == true) {
				value := "+" WS.EX.CLICKTHROUGH
				tp := transparency
			} else if (value == false) {
				value := "-" WS.EX.CLICKTHROUGH
				tp := "OFF"
			}
			this.transparency(100) := tp
			WinSet, ExStyle, %value%, ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> New Value:" this.clickThrough, this.debug)
			return this.clickThrough
		}
	}
	debug[] {
	/* ------------------------------------------------------------------------------- 
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/
		get {
			return this._debug
		}
		set {
			mode := value<1?0:1
			this._debug := mode
			return this._debug
		}
	}
	exist[] {
	/* ---------------------------------------------------------------------------------------
	Property: exist [get]
	Checks whether the window still exists. 

	Value:
	flag - *true* or *false* (activates/deactivates *caption*-Property)

	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			val := this.hwnd
			_hWnd := WinExist("ahk_id " val)
			ret := true
			if (_hWnd = 0)
				ret := false
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}
	}
	hidden[] {
	/* ---------------------------------------------------------------------------------------
	Property: hidden [get/set]
	Hides/Unhide the current window or get the current state of hiding

	Value:
	flag - `true` or `false` (activates/deactivates *hidden*-Property)

	Remarks:		
	* To toogle current *hidden*-Property, simply use 
	> obj.hidden := !obj.hidden`
	*/
		get {
			prevState := A_DetectHiddenWindows
			ret := false
			DetectHiddenWindows, Off
			if this.exist {
				; As HiddenWindows are not detected, the window is not hidden in this case ...
				ret := false
			} 
			else {
				DetectHiddenWindows, On 
				if this.exist {
					; As HiddenWindows are detected, the window is hidden in this case ...
					ret := true
				} 
				else {
					; the window does not exist at all ...
					ret := -1
				}
			}
			
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set{
			mode := value
			val := this.hwnd
			ret := 0
			if (mode == true) {
				WinHide ahk_id %val%
				ret := 1
			}
			else if (mode == false) {
				WinShow ahk_id %val%
				ret := 0
			}
			
			isHidden := this.hidden
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], mode=" mode ")] -> New Value:" isHidden, this.debug)
			
			return isHidden
		}
	}
	hwnd[] {
	/* ---------------------------------------------------------------------------------------
	Property: hwnd [get]
	Get the window handle of the current window

	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			this._hwnd := this.__hexStr(this._hwnd)
			return this._hwnd
		}
	}
	hangs[] {
	/* ---------------------------------------------------------------------------------------
	Property: hangs [get]
	Determines whether the system considers that a specified application is not responding. 

	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			ret := DllCall("user32\IsHungAppWindow", "Ptr", this.hwnd)
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)		
			return ret
		}
	}
	hscrollable[] {
	/* ---------------------------------------------------------------------------------------
	Property: hscrollable [get/set]
	Is horizontal scrollbar available?

	Value:
	flag - *true* or *false (activates/deactivates *hscrollable*-Property)

	Remarks:		
	* To toogle current *hscrollable*-Property, simply use 
	> obj.hscrollable := !obj.hscrollable
	*/
		get {
			ret := (this.style & WS.HSCROLL) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			style := "-" this.__hexStr(WS.HSCROLL)
			if (value) {
				style := "+" this.__hexStr(WS.HSCROLL)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.hscrollable, this.debug)
			return value
		}
	}
	maximizebox[] {
	/* ---------------------------------------------------------------------------------------
	Property: maximizebox [get/set]
	Get or Set the *maximizebox*-Property (Is maximizebox available?)

	Value:
	flag - *true* or *false* (activates/deactivates *maximizebox*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.maximizebox := !obj.maximizebox
	*/
		get {
			ret := (this.style & WS.MAXIMIZEBOX) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			style := "-" this.__hexStr(WS.MAXIMIZEBOX)
			if (value) {
				style := "+" this.__hexStr(WS.MAXIMIZEBOX)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.maximizebox, this.debug)
			return value
		}
	}
	maximized[] {
	/* ---------------------------------------------------------------------------------------
	Property: maximized [get/set]
	Maximizes/Demaximizes the current window or get the current state of maximization
	
	Value:
	flag - *true* or *false* (activates/deactivates *maximized*-Property)
	
	Remarks:		
	* To toogle, simply use 
	> obj.maximized := !obj.maximized
*/
		get {
			val := this.hwnd
			WinGet, s, MinMax, ahk_id %val% 
			ret := 0
			if (s == 1)
				ret := 1	
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			mode := value
			newState := 1
			if (mode == 0) {
				newState := 0
			}
			
			prevState := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if (newState == 1 )
				WinMaximize % "ahk_id" this.hwnd
			else 
				WinRestore % "ahk_id" this.hwnd
			DetectHiddenWindows, %prevState%
			
			isMax := this.maximized
			dbgOut("=[[" A_ThisFunc "([" this.hwnd "], mode=" mode ")] -> New Value:" isMax, this.debug)
			
			return isMax
		}
	}
	minimizebox[] {
	/* ---------------------------------------------------------------------------------------
	Property: minimizebox [get/set]
	Get or Set the *minimizebox*-Property (Is minimizebox available?)

	Value:
	flag - *true* or *false* (activates/deactivates *minimizebox*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.minimizebox := !obj.minimizebox
	*/
		get {
			ret := (this.style & WS.MINIMIZEBOX) > 0 ? 1 : 0
			dbgOut("=[[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			style := "-" this.__hexStr(WS.MINIMIZEBOX)
			if (value) {
				style := "+" this.__hexStr(WS.MINIMIZEBOX)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.minimizebox, this.debug)
			return value
		}
	}
	minimized[] {
	/* ---------------------------------------------------------------------------------------
	Property: minimized [get/set]
	Minimizes/Deminimizes the current window or get the current state of minimization

	Value:
	flag - *true* or *false* (activates/deactivates *minimized*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.minimized := !obj.minimized
	*/
		get {
			val := this.hwnd
			WinGet, s, MinMax, ahk_id %val% 
			ret := 0
			if (s == -1)
				ret := 1
			dbgOut("=[[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			mode := value
			newState := 1
			if (mode == 0) {
				newState := 0
			}
		
			prevState := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if (newState == 1 )
				WinMinimize % "ahk_id" this.hwnd
			else 
				WinRestore % "ahk_id" this.hwnd
			DetectHiddenWindows, %prevState%
	
			isMin := this.minimized
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], mode=" mode ")] -> New Value:" isMin, this.debug)

			return isMin
			}
	}
	monitorID[] {
	/* ---------------------------------------------------------------------------------------
	Property: monitorID [get/set]
	Get or Set the ID of monitor on which the window is on. Setting the property moves the window to the corresponding monitor, trying to place the window at the same (scaled) position

	Value:
	ID - Monitor-ID (if *ID > max(ID)* then *ID = max(ID)* will be used)
		
	Remarks
	* Setting the property moves the window to the corresponding monitor, retaining the (relative) position and size of the window
	*/
		get {
			mon := 1
			c := this.centercoords
			md := new MultiMony(this._debug)
			mon := md.idFromCoord(c.x,c.y,mon)
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " mon, this.debug)
			return mon
		}

		set {
			md := new MultiMony(this._debug)

			oldID := this.monitorID
			realID := value
			if (realID > md.monitorsCount) {
				realID := md.monitorsCount
			}	
			if (realID < 1) {
				realID := 1
			}
			wasMaximized:= false
			if (this.maximized = true) {
				wasmaximized := true
				this.maximized := false
			}
			rt := this.scale(realID)
			this.move(rt.x,rt.y,rt.w, rt.h)
			if (wasmaximized = true) {
				this.maximized := true
			}
			
			monID := this.monitorID
			dbgOut("=[[" A_ThisFunc "([" this.hwnd "], ID=" value ")] -> New Value:" monID " (from: " oldID ")", this.debug)
	
			return monID
		}
	}
	next[] {
	/* ---------------------------------------------------------------------------------------
	Property: next [get]
	gets the <windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> object below the current object in the Z order. 

	Returns: 
	new <windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html>-object
	
	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			; http://autohotkey.com/board/topic/32171-how-to-get-the-id-of-the-next-or-previous-window-in-z-order/?p=205384
			hwndnext := this.hwnd
			Loop {
				hwndnext := DllCall("GetWindow", "uint", hwndnext, "uint", GW.HWNDNEXT)
				; GetWindow() returns a decimal value, so we have to convert it to hex
				SetFormat,integer,hex
				hwndnext += 0
				SetFormat,integer,d
				if (hwndnext = 0)
				  break
				if (this.__isWindow(hwndnext)) {
				  ; GetWindow() processes even hidden windows, so we move down the z oder until the next visible window is found
				  if (DllCall("IsWindowVisible","uint",hwndnext) = 1)
					  break
			  }
			}
			if (this._debug) ; _DBG_
				OutputDebug % "|[" A_ThisFunc "([" this.hwnd "]) -> (" hwndnext ")]" ; _DBG_		
			return hwndnext
		}
	}
	owner[] {
	/* ---------------------------------------------------------------------------------------
	Property: owner [get/set]
	Get or Set the handle of owner window of the window current.
	
	Value:
	hwndOwner - Handle to the owner window. If this parameter is 0, the desktop window becomes the new owner window.
	
	Returns:
	If the function succeeds, the return value is a handle to the owner window. Otherwise, its 0.

 	Remarks:
	See <http://msdn.microsoft.com/en-us/library/windows/desktop/ms633584%28v=vs.85%29.aspx> for more information.
	*/
		get {
			hwndOwner := DllCall("GetWindowLong", "uint", this.hwnd, "int", GWL.HWNDPARENT, "UInt")
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " hwndOwner, this.debug)
			return hwndOwner
		}

		set {
			hwndOwner := value
			ret := DllCall("SetWindowLong", "uint", this.hwnd, "int", GWL.HWNDPARENT, "uint", hwndOwner)
			if  ret == 0				
				hwndOwner := 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], hwndOwner= " hwndOwner ")] -> hwndOwner:" hwndOwner ")", this.debug)
			return hwndOwner	
		}
	}
	parent[bFixStyle=false]{
	/* ---------------------------------------------------------------------------------------
	Property: parent [get/set]
	Get or Set the parent of the window.
	
	Value:
	hwndPar	- Handle to the parent window. If this parameter is 0, the desktop window becomes the new parent window.
	bFixStyle - Set to TRUE to fix WS_CHILD & WS_POPUP styles. SetParent does not modify the WS_CHILD or WS_POPUP window styles of the window whose parent is being changed. 	If hwndPar is 0, you should also clear the WS_CHILD bit and set the WS_POPUP style after calling SetParent (and vice-versa).	

	Returns:
	If the function succeeds, the return value is a handle to the previous parent window. Otherwise, its 0.

 	Remarks:
	* If the current window identified by the hwnd parameter is visible, the system performs the appropriate redrawing and repainting.
	The function sends WM_CHANGEUISTATE to the parent after succesifull operation uncoditionally.
	* See <http://msdn.microsoft.com/en-us/library/ms633541(VS.85).aspx> for more information.
	*/
		get {
			hwndPar := DllCall("GetParent", "uint", hwndPar, "UInt")
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " hwndPar, this.debug)
			return hwndPar
		}


		set {
		; Idea taken from majkinetors Forms Framework (https://github.com/maul-esel/FormsFramework), win.ahk
			hwndPar := value
			hwnd := this.hwnd
			if (bFixStyle) {
				s1 := hwndPar ? "+" : "-", s2 := hwndPar ? "-" : "+"
				ws_child := WS.CHILD
				ws_popup := WS.POPUP
				WinSet, Style, %s1%%ws_child%, ahk_id %hwnd%
				WinSet, Style, %s2%%ws_popup%, ahk_id %hwnd%
			}
			ret := DllCall("SetParent", "uint", Hwnd, "uint", hwndPar, "Uint")
			if  ret == 0				
				hwndPar := 0
			else
				SendMessage, WM.CHANGEUISTATE, UIS.NITIALIZE,,,ahk_id %hwndPar%	
			
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], hwndPar= " hwndPar ", bfixStyle=" bFixStyle ")] -> hwnd:" hwndPar ")", this.debug)
			return hwndPar
		}
	}
	pos[] {
	/* ---------------------------------------------------------------------------------------
	Property: pos [get/set]
	Position of the window as <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	Value:
	pos - position of the window
	*/
		get {
			ps := this.posSize
			pt := new Pointy()
			pt.x := ps.x
			pt.y := ps.y
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> (" pt.dump() ")", this.debug)
			return pt
		}
		set {
			pt := value
			ps := this.posSize
			ps.x := pt.x
			ps.y := pt.y
			this.posSize := ps
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], pt=" pt.Dump()")] -> New Value:" pt.Dump(), this.debug)
			return pt
		}
	}
	posSize[] {
	/* ---------------------------------------------------------------------------------------
	Property: posSize [get/set]
	Get or Set the position and size of the window (To set the position use class <rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>.)	

	Value:
	ps - position and size of the window
	*/
		get {
			info := this.windowinfo
			currPos := new Recty(info.window.xul,info.window.yul,info.window.xlr-info.window.xul,info.window.ylr-info.window.yul,this._debug)
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> (" currPos.dump() ")", this.debug)
			return currPos
		}

		set {
			rect := value
			this.move(rect.x, rect.y, rect.w, rect.h)
			newPos := this.posSize
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], pos=" newPos.Dump()")] -> New Value:" newPos.Dump(), this.debug)
			return newPos
		}
	}
	previous[] {
	/* ---------------------------------------------------------------------------------------
	Property: previous [get]
	gets the <windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> object above the current object in the Z order. 

	Returns: 
	new <windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html>-object
	
	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
		; http://autohotkey.com/board/topic/32171-how-to-get-the-id-of-the-next-or-previous-window-in-z-order/?p=205384
			hwndprev := this.hwnd
			Loop {
				hwndprev := DllCall("GetWindow", "uint", hwndprev, "uint", GW.HWNDPREV)
				; GetWindow() returns a decimal value, so we have to convert it to hex
				SetFormat,integer,hex
				hwndprev += 0
				SetFormat,integer,d
				if (hwndprev =0)
				  break
				if (this.__isWindow(hwndprev)) {
				  ; GetWindow() processes even hidden windows, so we move down the z oder until the next visible window is found
				  if (DllCall("IsWindowVisible","uint",hwndprev) = 1)
					  break
			  }
			}
			if (this._debug) ; _DBG_
				OutputDebug % "|[" A_ThisFunc "([" this.hwnd "]) -> (" hwndprev ")]" ; _DBG_		
			return hwndprev
		}
	}
	processID[] {
	/*---------------------------------------------------------------------------------------
	Property: processID [get]
	Get the ID of the process the window belongs to
	
	Remarks:		
	* There is no setter available, since this cannot be modified
	*/
		get {
			ret := ""
			if this.exist {
				WinGet, PID, PID, % "ahk_id " this.hwnd
				ret := PID
			}
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)	
			return ret
		}
	}
	processname[] {
	/* ---------------------------------------------------------------------------------------
	Property: processname [get]
	Get the Name of the process the window belongs to

	Remarks:		
	* There is no setter available, since this cannot be modified
	*/
		get {
			ret := ""
			if this.exist {
				WinGet, PName, ProcessName, % "ahk_id " this.hwnd
				ret := PName
			}
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}
	}
	resizable[] {
	/* ---------------------------------------------------------------------------------------
	Property: resizable [get/set]
	Is window resizing possible?

	Value:
	flag - *true* or *false* (activates/deactivates *resizable*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.resizable := !obj.resizable
	* Same as property <sizebox at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#sizebox>

	*/
		get {
			return this.sizebox
		}
		set {
			this.sizebox := value
			return value
		}
	}
	rolledUp[] {
	/* ---------------------------------------------------------------------------------------
	Property: rolledUp [get/set]
	Is window rolled up to its title bar?  Rolls/De-Rolls the current window or get the current state of RollUp

	Value:
	flag - *true* or *false* (activates/deactivates *rolledUp*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.rolledUp := !obj.rolledUp
	*/
		get {
			ret := 0
			if !this.exist {
				; the window does not exist at all ...
				ret := -1
			}
			else {
				currPos := this.posSize
				if (currPos.h <= this.rolledUpHeight) {
					ret := 1
				}
			}
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			mode := value
			roll := 1
			if (mode == 1) 		
				roll := 1
			else if (mode = 0) 
				if (this.rolledUp = true)
					roll := 0 ; Only rolled window can be unrolled
				else
					roll := -1 ; As window is not rolled up, you cannot unroll it as requested ....
			else {
				if (this.rolledUp = true)
					roll := 0
				else
					roll := 1
			}
			
			; Determine the minmal height of a window
			MinWinHeight := this.rolledUpHeight
			; Get size of current window
			hwnd := this.hwnd
			currPos := this.posSize
		
			if (roll = 1) { ; Roll
	            this.move(currPos.x, currPos.y, currPos.w, MinWinHeight)
			}
			else if (roll = 0) { ; Unroll
				this.__posRestore()			
			}
			
			isRolled := this.rolledUp
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], mode=" mode ")] -> New Value:" isRolled, this.debug)

			return isRolled
		}
	}
	rolledUpHeight[] {
	/* ---------------------------------------------------------------------------------------
	Property: rolledUpHeight [get]
	Height of the caption bar of windows
		
	Remarks:
	* There is no setter available, since this is a constant window property
	*/
		get {
			SysGet, ret, 29
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

	}
	scale[ monIDDest := 1 ] {
	/* -------------------------------------------------------------------------------
	Property:  scale [get]
	Scales the current position and size of the window to another monitor considering current and destination monitor proportions
			
	Parameters:
	monIDDest - Destination Monitor number (*Required*, Default := 1)
			
	Returns:
	Rectangle containing the scaled coordinates og the window in given monitor (see <recty at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>.

	Remarks:
	* There is no setter available, since this is a constant system property

	*/
		get {
		    monIdCurr := this.monitorID
		    monCurr := new Mony(monIDCurr, this._debug)
			scaleX := monCurr.scaleX(monIDDest)
			scaleY := monCurr.scaleY(monIDDest)

			monDest := new Mony(monIDDest, this._debug)
			destMon := monDest.boundary
			currMon := monCurr.boundary
		
			currPos := this.posSize
			xdest := destMon.x+(currPos.x - currMon.x)
			ydest := destMon.y+(currPos.y - currMon.y)
			wdest := currPos.w * scaleX
			hdest := currPos.h * scaleY
			
			rt := new Recty(xdest, ydest, wdest, hdest, this._debug)
			dbgOut("=[" A_ThisFunc "([" this.id "],monDest:= " monIdDest "] (" currPos.dump() ") -> (" rt.dump() ")", this.debug)
			return rt
		}
	}
	size[] {
	/* ---------------------------------------------------------------------------------------
	Property: size [get/set]
	Dimensions (Width/Height) of the window as <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	Value:
	size - size of the window
	*/
		get {
			ps := this.posSize
			pt := new Pointy()
			pt.x := ps.w
			pt.y := ps.h
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> (" pt.dump() ")", this.debug)
			return pt
		}
		set {
			pt := Value
			ps := this.posSize
			ps.w := pt.x
			ps.h := pt.y
			this.posSize := ps
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value.Dump()")] -> New Value:" pt.Dump(), this.debug)
			return pt
		}
	}
	sizebox[] {
	/*---------------------------------------------------------------------------------------
	Property: sizebox [get/set]
	Is window resizing possible?

	Value:
	flag - *true* or *false* (activates/deactivates *sizebox*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.sizebox := !obj.sizebox
	* Same as property *resizable*
	*/
		get {
			ret := (this.style & WS.SIZEBOX) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			style := "-" this.__hexStr(WS.SIZEBOX)
			if (value) {
				style := "+" this.__hexStr(WS.SIZEBOX)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.sizebox, this.debug)
			return value
		}
	}
	style[] {
	/* ---------------------------------------------------------------------------------------
	Property: style [get/set]
	Current window style
	*/
		get {
			hWnd := this._hwnd
			WinGet, currStyle, Style, ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this._hwnd "])] -> (" this.__hexStr(currStyle) ")", this.debug)
			return currStyle
		}
		set {
			hwnd := this.hwnd
			WinSet, Style, %value%, ahk_id %hwnd%
			this.redraw()
			WinGet, currStyle, Style, ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], style=" this.__hexStr(value) ")] -> (" this.__hexStr(value) "/" this.__hexStr(currStyle) ")", this.debug)	
			return value
		}		
	}
	styleEx[] {
	/* ---------------------------------------------------------------------------------------
	Property: styleEx [get/set]
	Current window extended style
	*/

		get {
			hWnd := this._hwnd
			WinGet, currStyle, ExStyle, ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this._hwnd "])] -> (" this.__hexStr(currStyle) ")", this.debug)
			return currStyle
		}
		set {
			hwnd := this.hwnd
			WinSet, ExStyle, %value%, ahk_id %hwnd%
			this.redraw()
			WinGet, currStyle, ExStyle, ahk_id %hwnd%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], styleEx=" this.__hexStr(value) ")] -> (" this.__hexStr(value) "/" this.__hexStr(currStyle) ")", this.debug)
			return value
		}
	}
	title[] {
	/* ---------------------------------------------------------------------------------------
	Property: title [get/set]
	Current window title. 

	Remarks:		
	A change to a window's title might be merely temporary if the application that owns the window frequently changes the title.
	*/
		get {
			val := this.hwnd
			WinGetTitle, title, ahk_id %val%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "]) -> (" title ")]", this.debug)
			return title
		}

		set {
			title := value
			val := this.hwnd
			prevState := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinSetTitle, ahk_id %val%,, %title%
			DetectHiddenWindows, %prevState%
			newTitle := this.title
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], title=" title ")] -> " newTitle, this.debug)
			return newTitle
		}
	}
	transparency[increment := 1,delay := 10] {
	/* ---------------------------------------------------------------------------------------
	Property: transparency [get/set]
	Current window transparency. 

	Parameters:
	transparency - transparency to be set
	increment - transparency-incrementation while fading
	delay - delay between each increment (Unit: ms)

	Remarks:
	* if : transparency > current, increases current transparency [increment+]
	* if : transparency < current, decreases current transparency [increment-]
	* if : increment = 0, transparency isset immediately without any fading

	Author(s)
    Original - <joedf at http://ahkscript.org/boards/viewtopic.php?f=6&t=512>
	*/
		get {
			hwnd := this.hwnd
			WinGet, s, Transparent, ahk_id %hwnd% 
			ret := 255
			if (s != "")
				ret := s
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			hwnd := this.hwnd
			transFinal := value
			transOrig := value
			if (transFinal == "OFF")
				transFinal := 255
			transFinal:=(transFinal>255)?255:(transFinal<0)?0:transFinal

			transStart:= this.transparency
	    	transStart :=(transStart="")?255:transStart ;prevent trans unset bug
	    	if (this.caption = true) {
				WinSet,Transparent,%transStart%,ahk_id %hwnd%
			}
			else {
				winlong := DllCall("GetWindowLong", "Uint", hwnd, "Int", -20) ;// GWL_EXSTYLE := -20
   				DllCall("SetWindowLong", "UInt", hwnd, "Int", -20, "UInt", winlong|0x00080000) ;// WS_EX_LAYERED := 0x00080000
   				DllCall("SetLayeredWindowAttributes", "UInt", hwnd, "UInt", 0, "UInt", transStart, "UInt", 0x00000002) ;// LWA_ALPHA := 0x00000002 
			}

			if (increment != 0) {
				; do the fading animation
				increment:=(transStart<transFinal)?abs(increment):-1*abs(increment)
				transCurr := transStart
	    		while(k:=(increment<0)?(transCurr>transFinal):(transCurr<transFinal)&&this.exist) {
	        		transCurr:= this.transparency
	        		transCurr+=increment
	        		if (this.caption = true) {
	        			WinSet,Transparent,%transCurr%,ahk_id %hwnd%
        			}
        			else {
						DllCall("SetLayeredWindowAttributes", "UInt", hwnd, "UInt", 0, "UInt", transCurr, "UInt", 0x00000002) ;// LWA_ALPHA := 0x00000002 
        			}
	        		sleep %delay%
	    		}
    		}
    		; Set final transparency
    		if (this.caption = true) {
	    		WinSet,Transparent,%transFinal%,ahk_id %hwnd%
    	    }
        	else {
				DllCall("SetLayeredWindowAttributes", "UInt", hwnd, "UInt", 0, "UInt", transFinal, "UInt", 0x00000002) ;// LWA_ALPHA := 0x00000002 
        	}
	    		
			transEnd := this.transparency
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], transparency=" transOrig "(" transStart "), increment=" increment ", delay=" delay ")] -> New Value:" transEnd, this.debug)
			return transEnd
		}
	}
	vscrollable[] {
	/* ---------------------------------------------------------------------------------------
	Property: vscrollable [get/set]
	Is vertical scrollbar available?

	Value:
	flag - *true* or *false* (activates/deactivates *vscrollable*-Property)

	Remarks:		
	* To toogle, simply use 
	> obj.vscrollable := !obj.vscrollable
	*/
		get {
			ret := (this.style & WS.VSCROLL) > 0 ? 1 : 0
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> " ret, this.debug)
			return ret
		}

		set {
			style := "-" this.__hexStr(WS.VSCROLL)
			if (value) {
				style := "+" this.__hexStr(WS.VSCROLL)
			}
		 	prevState := A_DetectHiddenWindows
			DetectHiddenWindows, on
			this.style := style
			this.redraw()
			DetectHiddenWindows, %prevState%
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], value=" value ")] -> " this.vscrollable, this.debug)
			return value
		}
	}
	windowinfo {
	/* ---------------------------------------------------------------------------------------
	Property: windowinfo [get]
	Info about current window 

	Return values:    
	* On success  - Object containing structure's values (see Remarks)
    * On failure  - False, ErrorLevel = 1 -> Invalid HWN, ErrorLevel = 2 -> DllCall("GetWindowInfo") caused an error

    Remarks:          
    * The returned object contains all keys defined in WINDOWINFO except "Size".
    * The keys "Window" and "Client" contain objects with keynames defined in [5]
    * For more details see <http://msdn.microsoft.com/en-us/library/ms633516%28VS.85%29.aspx> and <http://msdn.microsoft.com/en-us/library/ms632610%28VS.85%29.aspx>

    Author(s)
    Original - <just me at http://www.autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/>
	*/
		get {
		   ; [1] = Offset, [2] = Length, [3] = Occurrences, [4] = Type, [5] = Key array
   			Static WINDOWINFO := { Size: [0, 4, 1, "UInt", ""]
			                        , Window: [4, 4, 4, "Int", ["xul", "yul", "xlr", "ylr"]]
			                        , Client: [20, 4, 4, "Int", ["xul", "yul", "xlr", "ylr"]]
			                        , Styles: [36, 4, 1, "UInt", ""]
			                        , ExStyles: [40, 4, 1, "UInt", ""]
			                        , Status: [44, 4, 1, "UInt", ""]
			                        , XBorders: [48, 4, 1, "UInt", ""]
			                        , YBorders: [52, 4, 1, "UInt", ""]
			                        , Type: [56, 2, 1, "UShort", ""]
			                        , Version: [58, 2, 1, "UShort", ""] }
   			Static WI_Size := 0
   			If (WI_Size = 0) {
      			For Key, Value In WINDOWINFO
         			WI_Size += (Value[2] * Value[3])
   			}
   			If !DllCall("User32.dll\IsWindow", "Ptr", this.hwnd) {
      			ErrorLevel := 1
      			dbgOut("=[" A_ThisFunc "([" this.hwnd "]) -> false (is not a window)]", this.debug)
      			Return False
   			}
   			struct_WI := ""
   			NumPut(VarSetCapacity(struct_WI, WI_Size, 0), struct_WI, 0, "UInt")
   			If !(DllCall("User32.dll\GetWindowInfo", "Ptr", this.hwnd, "Ptr", &struct_WI)) {
   		   		ErrorLevel := 2
   		   		dbgOut("=[" A_ThisFunc "([" this.hwnd "]) -> false]", this.debug)
      		 	Return False
  			}
   			obj_WI := {}
   			For Key, Value In WINDOWINFO {
	      		If (Key = "Size")
	         		Continue
			    Offset := Value[1]
	      		If (Value[3] > 1) { ; more than one occurrence
	         		If IsObject(Value[5]) { ; use keys defined in Value[5] to store the values in
	            		obj_ := {}
	            		Loop, % Value[3] {
	               			obj_.Insert(Value[5][A_Index], NumGet(struct_WI, Offset, Value[4]))
	               			Offset += Value[2]
	            		}
	            		obj_WI[Key] := obj_
	         		} Else { ; use simple array to store the values in
	            		arr_ := []
	            		Loop, % Value[3] {
	               			arr_[A_Index] := NumGet(struct_WI, Offset, Value[4])
	               			Offset += Value[2]
	            		}
	            		obj_WI[Key] := arr_
	         		}		
	      		} Else { ; just one item
	         		obj_WI[Key] := NumGet(struct_WI, Offset, Value[4])
	      		}
   			}
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] => (" SerDes(Obj_WI) ")", this.debug)
			Return obj_WI
		}	
	}
	; ##################### End of Properties (AHK >1.1.16.x) ##############################################################
	
	; ######################## Methods to be called directly ###########################################################     
	/* ---------------------------------------------------------------------------------------
	Method: border2percent
	translates a border string to monitor percents.

	When moving the actual window from current position to a certain position on the window border (given by a border string (as for example "l", "hc" or "r vc")), 
	the border string is transformed to factors which describe the destination size/position of actual window in relation to the monitor the window is own. Using this 
	factors the window can be moved via 'this.movePercental(factor.x, factor.y, factor.w, factor.h)' to the destination position as specified in border string.

	This method is needed as a helper method in order to allow an easy configuration of window alignment within AHK_EDE '

	 	 
	Parameters:
	border - string describing the border to move to - for further description see <moveBorder at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#moveBorder>)

	Returns:
	<rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html> containing the screen percents

	See Also: 
	<moveBorder at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#moveBorder>
	*/	
	border2percent(border="") {
		; check whether given border string is valid
		posValid := false
		StringLower, border, border
		border := RegExReplace(border, "S) +", A_Space)
		border := RegExReplace(border, "^ ", "")
		border := RegExReplace(border, " $", "")
		FoundPos := RegExMatch(border, "^(|t|b|l|r|vc|hc|l t|t l|l b|b l|l vc|vc l|r t|t r|r b|b r|r vc|vc r|hc t|t hc|hc b|b hc|hc vc|vc hc)$")
		if (FoundPos > 0) {
			posValid := true
		}

		if (posValid = true) {
			currPos := this.posSize
			mon := new Mony(this.monitorID, this._debug)
			monWorkArea := mon.workingArea
			monBound := mon.boundary

			x := currPos.x
			if (InStr(border,"l")) {
				x := 0 
			} else if (InStr(border,"r")) {
				x:= monBound.w - currPos.w
				
			} else if (InStr(border,"hc")) {
				x:= monBound.w/2 - currPos.w/2
			}
		
			y:= currPos.y
			if (InStr(border,"t")) {
				y := 0 
			} else if (InStr(border,"b")) {
				y:= monBound.h - currPos.h
			} else if (InStr(border,"vc")) {
				y:= monBound.h/2 - currPos.h/2
     		}

			destPos := new Recty(x, y, currPos.w, currPos.h)
			ret := mon.rectToPercent(destPos)
	
			dbgOut("=[" A_ThisFunc "([" this.hwnd "], border=""" border """)] pos (" this.posSize.Dump()") on Mon " this.monitorId " -> percent (" ret.Dump() ")", this.debug)

			return ret
	  }

	dbgOut("=[" A_ThisFunc "([" this.hwnd "], border=""" border """)] *** ERROR: Invalid border string <" border ">", this.debug)
		
	return
  }        
	/* ---------------------------------------------------------------------------------------
	Method: kill
	Kills the Window (Forces the window to close)
			
	Performs the AHK command <WinKill at (http://ahkscript.org/docs/commands/WinKill.htm>

	See Also: 
	<close at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#close>
	*/
	kill() {
		dbgOut("=[" A_ThisFunc "([" this.hwnd "])]", this.debug)
		prevState := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinKill % "ahk_id" this.hwnd
		DetectHiddenWindows, %prevState%
	}	
	/* ---------------------------------------------------------------------------------------
	Method: move
	Moves and/or resizes the window
			
	The given coordinates/sizes are absolute coordinates/sizes. If the value of any coordinate is equal *99999* the current value keeps unchanged. 

	Examples: 
	* Resize-only can be performed by 
	> obj.move(99999,99999,width,height)
	
	Parameters:
		x - x-Coordinate (absolute) the window has to be moved to - use *99999* to preserve actual value
		y - y-Coordinate (absolute) the window has to be moved to - use *99999* to preserve actual value
		w -  width (absolute) the window has to be resized to - use *99999* to preserve actual value *(Optional)*
		h - height (absolute) the window has to be resized to - use *99999* to preserve actual value *(Optional)*
	
	See Also: 
	<movePercental() at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#movePercental>, <moveBorder() at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#moveBorder>
	*/
	move(X,Y,W="99999",H="99999") {
		dbgOut(">[" A_ThisFunc "([" this.hwnd "])(X=" X " ,Y=" Y " ,W=" W " ,H=" H ")]")
		if (X = 99999 || Y = 99999 || W = 99999 || H = 9999)
			currPos := this.posSize
		
		if (X = 99999)
			X := currPos.X
		
		if (Y = 99999)
			Y := currPos.Y
		
		if (W = 99999)
			W := currPos.W
		
		if (H = 99999)
			H := currPos.H
		
		dbgOut("<[" A_ThisFunc "([" this.hwnd "])(X=" X " ,Y=" Y " ,W=" W " ,H=" H ")]", this.debug)
		WinMove % "ahk_id" this.hwnd, , X, Y, W, H
	}
	/* ---------------------------------------------------------------------------------------
	Method: movePercental
	move and resize window relative to the size of the current screen.
			
	Examples: 
	 * create a window with origin 0,0 and a *width=100% of screen width* and *height=100% of screen height*
	 > obj.movePercental(0,0,100,100)
	 * create a window at *x=25% of screen width*, *y =25% of screen height*, and with *width=50% of screen width*, *height=50% of screen height*. The resulting window is a screen centered window with the described width and height
	 > obj.movePercental(25,25,50,50)
	 
	Parameters:
	xFactor - x-position factor (percents of current screen width) the window has to be moved to (Range: 0.0 to 100.0) *(*Optional*, Default = 0)
	yFactor - y-position factor (percents of current screen height) the window has to be moved to (Range: 0.0 to 100.0) (*Optional*, Default = 0)
	wFactor - width-size factor (percents of current screen width) the window has to be resized to (Range: 0.0 to 100.0) (*Optional*, Default = 100)
	hFactor - height-size factor (percents of current screen height) the window has to be resized to (Range: 0.0 to 100.0) (*Optional*, Default = 100)
	
	See Also: 
	<move() at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#move>, <moveBorder() at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#moveBorder>
			
	Authors:
	- Original: <Lexikos at http://www.autohotkey.com/forum/topic21703.html>
			
	Caveats:
	- The range of the method parameters is *NOT* checked, so be carefull using any values *<0* or *>100*
	*/	
	movePercental(xFactor=0, yFactor=0, wFactor=100, hFactor=100) {
		dbgOut(">[" A_ThisFunc "([" this.hwnd "], xFactor=" xFactor ", yFactor=" yFactor ", wFactor=" wFactor ", hFactor=" hFactor ")]", this.debug)

		mon := new Mony(this.monitorID, this._debug)
		monWorkArea := mon.workingArea
		monBound := mon.boundary
		xrel := monWorkArea.w * xFactor/100
		yrel := monWorkArea.h * yFactor/100
		w := monBound.w * wFactor/100
		h := monBound.h * hFactor/100
		
		x := monBound.x + xrel
		y := monBound.y + yrel
		
		this.move(x,y,w,h)
		
		dbgOut("<[" A_ThisFunc "([" this.hwnd "], xFactor=" xFactor ", yFactor=" yFactor ", wFactor=" wFactor ", hFactor=" hFactor ")] -> padded to (" this.posSize.Dump() ") on Monitor (" this.monitorID ")", this.debug)
	}    
	/* ---------------------------------------------------------------------------------------
	Method: moveBorder
	move the window on the current screen to a border given by string while keeping the size.
			
	Example(s): 
	 * moves the window to the left border
	 > obj.moveBorder("l")
    * moves the window to the left border and centers it vertically
	 > obj.moveBorder("l vc")
	* moves the window to the top border and centers it horizontally
	 > obj.moveBorder("t hc")
    * moves the window to the top left corner
	 > obj.moveBorder("t l")

	 	 
	Parameters:
	border - string describing the border to move to (*t*: top, *b*: bottom, *l*: left, *r*: right, *vc*: vertically centered, *hc*: horizonally centered)
	
	See Also: 
	<move() at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#move>, <movePercental at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html#movePercental>
		*/	
	moveBorder(border="") {
		dbgOut(">[" A_ThisFunc "([" this.hwnd "], border=""" border """)] -> started from (" this.posSize.Dump() ") on Monitor (" this.monitorID ")", this.debug)
		factor := this.border2percent(border)
		if (factor) {
			this.movePercental(factor.x, factor.y, factor.w, factor.h)
		}
		dbgOut(">[" A_ThisFunc "([" this.hwnd "], border=""" border """)] -> moved to (" this.posSize.Dump() ") on Monitor (" this.monitorID ")", this.debug)
	}
	/* ---------------------------------------------------------------------------------------
	Method: posSize2percent
	Calculates screen percents from current size of actual window

	This method is needed as a helper method in order to allow an easy configuration of window alignment within AHK_EDE '

	Returns:
	<rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html> containing the screen percents 	 
	*/	
	posSize2percent() {
		currPos := this.posSize
		mon := new Mony(this.monitorID, this._debug)
		ret := mon.rectToPercent(currPos)
		dbgOut("=[" A_ThisFunc "([" this.hwnd "])] pos (" this.posSize.Dump()") on Mon " this.monitorId " -> percent (" ret.Dump() ")", this.debug)
		return ret
    }    
	/* ---------------------------------------------------------------------------------------
 	Method:	redraw
 	Redraws the window.

 	Parameters:
	Option  - Enable or disable redrawing (*Optional*, Default = "" (empty)). Use *"-"* to disable redrawing for the window, *"+"* to enable it and redraw it.
 
 	Returns:
	A nonzero value indicates success. Zero indicates failure.

	Hint:
		This function will update the window for sure, unlike <WinSet at http://ahkscript.org/docs/commands/WinSet.htm> or InvalidateRect.

	Authors:
	* Original: majkinetor
 	*/
    redraw(Option="" ) {
		return
		hwnd := this.hwnd
		if (Option != "") {
			old := A_DetectHiddenWindows
			DetectHiddenWindows, on
			bEnable := Option="+"
			SendMessage, WM.SETREDRAW, bEnable,,,ahk_id %hwnd%
			DetectHiddenWindows, %old%
			ifEqual, bEnable, 0, return		
		}
		ret := DllCall("RedrawWindow", "uint", hwnd, "uint", 0, "uint", 0, "uint" ,RDW.INVALIDATE | RDW.ERASE | RDW.FRAME | RDW.ERASENOW | RDW.UPDATENOW | RDW.ALLCHILDREN)
		dbgOut("=[" A_ThisFunc "([" this.hwnd "], Option=" Option ")] -> ret=" ret, this.debug)
		return ret
	}
	; ######################## Internal Methods - not to be called directly ############################################
	/* ---------------------------------------------------------------------------------------
	Method:   __isWindow
		Checks whether the given hWnd refers to a TRUE window (As opposed to the desktop or a menu, etc.) (*INTERNAL*)

	Parameters:
		hwnd  - Handle of window to check (*Obligatory*)

	Returns:
		true (window is a true window), false (window is not a true window)

	Author(s):
		Original - <ManaUser at http://www.autohotkey.com/board/topic/25393-appskeys-a-suite-of-simple-utility-hotkeys/>
	*/
	__isWindow(hWnd) {
		WinGet, s, Style, ahk_id %hWnd% 
		ret := s & WS.CAPTION ? (s & WS.POPUP ? 0 : 1) : 0  ;WS_CAPTION AND !WS_POPUP(for tooltips etc) 	
		dbgOut("=[" A_ThisFunc "([" hWnd "])] -> " ret, this.debug)
		return ret
	}	
	/* ---------------------------------------------------------------------------------------
    Method:   ____hexStr
	Converts number to hex representation (*INTERNAL*)
	*/
	__hexStr(i) {
		OldFormat := A_FormatInteger ; save the current format as a string
		SetFormat, Integer, Hex
		i += 0 ;forces number into current fomatinteger
		SetFormat, Integer, %OldFormat% ;if oldformat was either "hex" or "dec" it will restore it to it's previous setting
		return i
	}
	/* ---------------------------------------------------------------------------------------
	Method: __posPush
		Pushes current position of the window on position stack (*INTERNAL*)
	*/
	__posPush() {
			this._posStack.Insert(1, this.posSize)
		if (this._debug) { ; _DBG_ 
			dbgOut("=[" A_ThisFunc "([" this.hwnd "])] -> (" this._posStack[1].dump() ")", this.debug)
			this.__posStackDump() ; _DBG_ 
		}
	}
	/* ---------------------------------------------------------------------------------------
	Method: __posStackDump
		Dumps the current position stack via OutputDebug (*INTERNAL*)
	*/	
	__posStackDump() {
		For key,value in this._posStack	; loops through all elements in Stack
			dbgOut("=[" A_ThisFunc "()] -> (" key "): (" Value.dump() ")", this.debug)
		return
	}
	/* ---------------------------------------------------------------------------------------
	Method: __posRestore
		Restores position of the window  from Stack(*INTERNAL*)

	Parameters:
		index - Index of position to restore (*Optional*, Default = 2) (1 is the current position)
	*/
	__posRestore(index="2") {
		dbgOut(">[" A_ThisFunc "([" this.hwnd "], index=" index ")]", this.debug)
		restorePos := this._posStack[index]
		currPos := this.posSize
		
		this.__posStackDump()
		
		this.move(restorePos.x, restorePos.y, restorePos.w, restorePos.h)
		if (this._debug) { ; _DBG_
			dbgOut("<[" A_ThisFunc "([" this.hwnd "])] LastPos: " currPos.Dump() " - RestoredPos: " restorePos.Dump(), this.debug)
			this.__posStackDump() ; _DBG_ 
		}
	}
	/* ---------------------------------------------------------------------------------------
	Method: __SetWinEventHook
		Set the hook for certain win-events (*INTERNAL*)

	Parameters:
		see <http://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx>

	Returns:
		true or false, depending on result of dllcall
	*/ 
	__SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
		dbgOut("[" A_ThisFunc "([" this.hwnd "])(eventMin=" eventMin ", eventMax=" eventMax ", hmodWinEventProc=" hmodWinEventProc ", lpfnWinEventProc=" lpfnWinEventProc ", idProcess=" idProcess ", idThread=" idThread ", dwFlags=" dwFlags ")", this.debug)
		ret := DllCall("ole32\CoInitialize", Uint, 0)
		; This is a WinEventProc (siehe <http://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx>) - this determines parameters which can be handled by "HookProc"
		ret := DllCall("user32\SetWinEventHook"
			, Uint,eventMin   
			, Uint,eventMax   
			, Uint,hmodWinEventProc
			, Uint,lpfnWinEventProc
			, Uint,idProcess
			, Uint,idThread
			, Uint,dwFlags)   
		return ret
	}	
	/* ---------------------------------------------------------------------------------------
	Method:   __onLocationChange
		Callback on Object-Event *CONST_EVENT.OBJECT.LOCATIONCHANGE* or on *CONST_EVENT.SYSTEM.MOVESIZEEND* (*INTERNAL*)
		
		* Store windows size/pos on each change
	*/
	__onLocationChange() {
		if this.hwnd = 0
			return
		
	  dbgOut(">[" A_ThisFunc "([" this.hwnd "])")
		
		currPos := this.posSize
		lastPos := this._posStack[1]
		
		; current size/position is identical with previous Size/position
		if (currPos.equal(lastPos)) {
			dbgOut("<[" A_ThisFunc "([" this.hwnd "])] Position has NOT changed!)", this.debug)
			return
		}
		
		; size/position has been changed -> store it!
		this.__posPush()
				
		dbgOut("<[" A_ThisFunc "([" this.hwnd "])] LastPos: " lastPos.Dump() " - NewPos: " currPos.Dump(), this.debug)
		return
	}  
	/* ---------------------------------------------------------------------------------------
	Method: __Delete
	Destructor (*INTERNAL*)
	*/ 
	__Delete() {
		if (this.hwnd <= 0) {
			return
		}
		dbgOut("=[" A_ThisFunc "([" this.hwnd "])", this.debug)
			
		if (this.__useEventHook == 1) {
			if (this.__hWinEventHook1)
				DllCall( "user32\UnhookWinEvent", Uint,this._hWinEventHook1 )
			if (this.__hWinEventHook2)
				DllCall( "user32\UnhookWinEvent", Uint,this._hWinEventHook2 )
			if (this._HookProcAdr)
				DllCall( "kernel32\GlobalFree", UInt,&this._HookProcAdr ) ; free up allocated memory for RegisterCallback
		}
			
		; Reset all "dangerous" settings (all windows should be left in a user accessable state)
		if (this.alwaysontop == true) {
			this.alwaysOnTop(false)
		}
		if (this.__isHidden() == 1) {
			this.show()
		}
		
		if (this.__useEventHook == 1) {		
			ObjRelease(&this)
		}
	}
	/* ---------------------------------------------------------------------------------------
	Method: __New
		Constructor (*INTERNAL*)

	Parameters:
		hWnd - Window handle (*Obligatory*). If hWnd=0 a test window is created ...
		_debug - Flag to enable debugging (Optional - Default: 0)

	Returns:
		true or false, depending on current value
	*/   
	__New(_hWnd=-1, _debug=0, _test=0) {
		this._debug := _debug
		dbgOut(">[" A_ThisFunc "(hWnd=(" _hWnd "))] (version: " this._version ")", _debug)

		if % (A_AhkVersion < "1.1.08.00" || A_AhkVersion >= "2.0") {
			MsgBox 16, Error, %A_ThisFunc% :`n This class is only tested with AHK_L later than 1.1.08.00 (and before 2.0)`nAborting...
			dbgOut("<[" A_ThisFunc "(...) -> ()]: *ERROR* : This class is only tested with AHK_L later than 1.1.08.00 (and before 2.0). Aborting...", _debug)
			return
		}
		
		if  % (_hWnd = 0) {
			; Create a Testwindow ...
			Run, notepad.exe
			WinWait, ahk_class Notepad, , 2
			WinMove, ahk_class Notepad,, 10, 10, 300, 300
			_hWnd := WinExist("ahk_class Notepad")
		} else if % (_hWnd = -1) {
			; hWnd is missing
			MsgBox  16, Error, %A_ThisFunc% :`n Required parameter is missing`nAborting...
			dbgOut("<[" A_ThisFunc "(...) -> ()] *ERROR*: Required parameter is missing. Aborting...", _debug)
			this.hwnd := -1
			return
		}
		
		if (!this.__isWindow(_hWnd)) {
			dbgOut("<[" A_ThisFunc "(hWnd=(" _hWnd "))] is NOT a true window. Aborting...", _debug)
			this.hwnd := -1
			return
		}
		
		_hWnd := this.__hexstr(_hWnd)
		this._hWnd := _hWnd
    dbgOut("|[" A_ThisFunc "(hWnd=(" _hWnd "))] (WinTitle: " this.title ")", _debug)
				
		this._posStack := Object() ; creates initially empty stack
		
		; initially store the position to detect movement of window and allow window restoring
		this.__posPush()
		
		; Registering global callback and storing adress (&this) within A_EventInfo
		if (this.__useEventHook == 1) {
			ObjAddRef(&this)
			this._HookProcAdr := RegisterCallback("ClassWindy_EventHook", "", "", &this)
			; Setting Callback on Adress <_HookProcAdr> on appearance of any event out of certain range
			this._hWinEventHook1 := this.__SetWinEventHook( CONST_EVENT.SYSTEM.SOUND, CONST_EVENT.SYSTEM.DESKTOPSWITCH, 0, this._HookProcAdr, 0, 0, 0 )	
			this._hWinEventHook2 := this.__SetWinEventHook( CONST_EVENT.OBJECT.SHOW, CONST_EVENT.OBJECT.CONTENTSCROLLED, 0, this._HookProcAdr, 0, 0, 0 )	
		}
		
		dbgOut("<[" A_ThisFunc "(hWnd=(" _hWnd "))]", _debug)
		
		return this
	}
	
}

/* ===============================================================================
Function:   ClassWindy_EventHook
	Callback on System Events. Used as dispatcher to detect window manipulation and calling the appropriate member-function within class <WindowHandler>
	
See Also:
	* http://www.autohotkey.com/community/viewtopic.php?t=35659
	* http://www.autohotkey.com/community/viewtopic.php?f=1&t=88156
*/
ClassWindy_EventHook(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime ) {
	; ClassWindy_EventHook is used as WindowsEventHook - it's registered as callback within <__SetWinEventHook> of class <Windy>.
	; ClassWindy_EventHook is a WinEventProc (see http://msdn.microsoft.com/en-us/library/windows/desktop/dd373885(v=vs.85).aspx) and has those Parameter ...	

	; This function is called on the registered event(s) on every window - regardless whether it's an object instance or not
	; We have to check whether the current call refers to the current instance of the class Windy
	; HINT: A_EventInfo currently holds the address of the current WindowsHandler object instance (set during RegisterCallback ... see <__New>)
	
	; Don't handle any windows, that are not class instances ...
	if (hWnd != Object(A_EventInfo)._hWnd)
		return
	self := Object(A_EventInfo)

	dbgOut("=[" A_ThisFunc "([" Object(A_EventInfo)._hWnd "])(hWinEventHook=" hWinEventHook ", Event=" Event2Str(Event) ", hWnd=" hWnd ", idObject=" idObject ", idChild=" idChild ", dwEventThread=" dwEventThread ", dwmsEventTime=" dwmsEventTime ") -> A_EventInfo: " A_EventInfo, Object(A_EventInfo)._debug)
	
	; ########## START: Handling window movement ##################################################
	; We want to detect when the window movement has finished finally, as onLocationChanged() has only to be called at the END of the movement
	;
	; It has to be detected whether the location change was initiated by user dragging/rezizing ("manual movement") or any other window event ("non-manual movement").
	; * Manual movement triggers the following sequence: CONST_EVENT.SYSTEM.MOVESIZESTART - N times CONST_EVENT.OBJECT.LOCATIONCHANGE - CONST_EVENT.SYSTEM.MOVESIZEEND
	; * Non-manual movement by for example AHK WinMove only triggers: 1 time CONST_EVENT.OBJECT.LOCATIONCHANGE
	
	; +++ MANUAL MOVEMENT
	; The window is moved manually - as the movement isn't finished, don't call callback. Just store that we are in middle of manual movement
	if (Event == CONST_EVENT.SYSTEM.MOVESIZESTART) {
		Object(A_EventInfo)._bManualMovement := true
		return
	}
	; Manual movement has finished - trigger onLocationChange callback now
	if (Event == CONST_EVENT.SYSTEM.MOVESIZEEND) {
		Object(A_EventInfo)._bManualMovement := false
		Object(A_EventInfo).__onLocationChange()
		return
	}
	
	; +++ NON-MANUAL MOVEMENT
	; OutputDebug % "|[" A_ThisFunc "([" Object(A_EventInfo)._hWnd "])] -> Manual Movement " Object(A_EventInfo)._bManualMovement
	
	if (Event == CONST_EVENT.OBJECT.LOCATIONCHANGE) {
		if (Object(A_EventInfo)._bManualMovement == false) {
			; As its no manual movement, trigger onLocationChange callback now
			Object(A_EventInfo).__onLocationChange()
			return
		}
	}
	; ########## END: Handling window movement ####################################################
	return
}
