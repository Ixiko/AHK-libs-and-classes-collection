; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) **************

; ****** HINT: Debug-lines should contain "; _DBG_" at the end of lines - using this, the debug lines could be automatically removed through scripts before releasing the sourcecode

class Pointy {
; ******************************************************************************************************************************************
/*
	Class: Pointy
	Handling points (given through 2-D coordinates [x, y])

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original
	
	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/
	
	_version := "0.2.0"
	_debug := 0 ; _DBG_	
	x := 0
	y := 0
	
	; ##################### Start of Properties (AHK >1.1.16.x) ############################################################
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
	; ##################### End of Properties (AHK >1.1.16.x) ##############################################################

	/* --------------------------------------------------------------------------------------
	Method: Dump()
	Dumps coordinates to a string

	Returns:
	printable string containing coordinates
	*/
	Dump() {
		return "(" this.x "," this.y ")"
	}
	/* --------------------------------------------------------------------------------------
	Method: equal(comp)
	Compares currrent point to given point

	Parameters:
	comp - [Point](Pointy.html) to compare with

	Returns:
	true or false
	*/
	equal(comp) {
	
		return (this.x == comp.x) AND (this.y == comp.y)
	}
	/* --------------------------------------------------------------------------------------
	Method: fromHWnd(hwnd)
	Fills values with upper left corner coordinates from given Window (given by Handle)

	Parameters:
	hWnd - Window handle, whose upper left corner has to be determined
	*/
	fromHWnd(hwnd) {
		WinGetPos, x, y, w, h, ahk_id %hwnd%
		this.x := x
		this.y := y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "([" hwnd "])] -> x,y: (" x "," y ")" ; _DBG_
		
		return this
	}
	/* --------------------------------------------------------------------------------------
	Method: fromMouse(hwnd)
	Fills values from current mouseposition
	*/
	fromMouse() {
		CoordMode, Mouse, Screen
		MouseGetPos, x, y
		this.x := x
		this.y := y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "([" hwnd "])] -> x,y: (" x "," y ")" ; _DBG_
		
		return this
	}
	/* --------------------------------------------------------------------------------------
	Method: fromPoint(new)
	Fills values from given <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	Parameters:
	new - Point
	*/	
	fromPoint(new) {
		this.x := new.x 
		this.y := new.y
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "] -> x,y: " this.Dump() ; _DBG_
		
		return this
	}
	/* ---------------------------------------------------------------------------------------
	Constructor: __New
	Constructor via given X,X Coordinates
	
	Parameters:
	x,y - X,Y coordinates of the point
	debug - Flag to enable debugging (Optional - Default: 0)
	*/
	__New(x=0, y=0, debug=false) {
		this._debug := debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc "(x=" x ", y=" y ", _debug=" debug ")] (version: " this._version ")" ; _DBG_
		this.x := x
		this.y := y
	}
}

/*!
	End of class
*/
