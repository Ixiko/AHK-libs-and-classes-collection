#include %A_LineFile%\..
#include ..\DbgOut.ahk

; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

class Recty {
; ******************************************************************************************************************************************
/*
	Class: Recty
		Handling rectangles (given through [x, y (upper-left corner), w, h] or [x, y (upper-left corner), x, y (lower-right corner)])
		
	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original	

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.

*/
	_version := "0.3.1"
	_debug := 0 ; _DBG_	
	x := 0
	y := 0
	w := 0
	h := 0

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
	/* ---------------------------------------------------------------------------------------
	Property: x [get/set]
	Get or Set x-coordinate of the upper left corner of the rectangle

	Value:
	x -  x-coordinate of the upper left corner of the rectangle

	See Also:
	<xul>
	*/
	/* ---------------------------------------------------------------------------------------
	Property: y [get/set]
	Get or Set y-coordinate of the upper left corner of the rectangle

	Value:
	y -  y-coordinate of the upper left corner of the rectangle

	See Also:
	<yul>
	*/	
	/* ---------------------------------------------------------------------------------------
	Property: w [get/set]
	Get or Set the width of the rectangle

	Value:
	w -  width of the rectangle
	*/
	/* ---------------------------------------------------------------------------------------
	Property: h [get/set]
	Get or Set the height of the rectangle

	Value:
	h -  height of the rectangle
	*/
	xul[] {
	/* ------------------------------------------------------------------------------- 
	Property: xul [get/set]
	Get or Set x-coordinate of the upper left corner of the rectangle			
		
	Value:
	xul -  x-coordinate of the upper left corner of the rectangle

	See Also:
	<y>
	*/
		get {
			return this.x
		}
		set {
			this.x := value
			return this.x
		}
	}
	yul[] {
	/* ------------------------------------------------------------------------------- 
	Property: yul [get/set]
	Get or Set y-coordinate of the upper left corner of the rectangle			
		
	Value:
	y -  y-coordinate of the upper left corner of the rectangle

	See Also:
	<y>
	*/
		get {
			return this.y
		}
		set {
			this.y := value
			return this.y
		}
	}
	xlr[] {
	/* ------------------------------------------------------------------------------- 
	Property: xlr [get/set]
	Get or Set x-coordinate of the lower right corner of the rectangle		
			
	Value:
	xlr -  x-coordinate of the lower right corner of the rectangle
	*/
		get {
			return this.x+this.w
		}
		set {
			this.w := value - this.x
			return value
		}
	}
	ylr[] {
	/* ------------------------------------------------------------------------------- 
	Property: ylr [get/set]
	Get or Set y-coordinate of the lower right corner of the rectangle		
			
	Value:
	ylr -  y-coordinate of the lower right corner of the rectangle
	*/
		get {
			return this.y+this.h
		}
		set {
			this.h := value - this.y
			return value
		}
	}
	; ##################### End of Properties (AHK >1.1.16.x) ##############################################################

	/* ---------------------------------------------------------------------------------------
	Method: Dump
		Dumps coordinates to a string

	Returns:
		printable string containing coordinates
	*/
	Dump() {
		return "(" this.x "," this.y "," this.w "," this.h ")"
	}
	/* ---------------------------------------------------------------------------------------
	Method: equal
		Compares currrent rectangle to given rectangle

	Parameters:
		comp - <Rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty.html> to compare with

	Returns:
		true or false

	See Also: 
		<equalPos>, <equalSize>
	*/
	equal(comp) {
		return this.equalPos(comp) AND this.equalSize(comp)
	}
	/* ---------------------------------------------------------------------------------------
	Method: equalPos
		Compares currrent rectangle position to given rectangle position
		
	Parameters:
		comp - <Rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty.html> to compare with

	Returns:
		true or false

	See Also: 
		<equal>, <equalSize>
	*/
	equalPos(comp) {
		return (this.x == comp.x) AND (this.y == comp.y)
	}
	/* ---------------------------------------------------------------------------------------
	Method: equalSize
		Compares currrent rectangle size to given rectangle size
		
	Parameters:
		comp - <Rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty.html> to compare with
		
	Returns:
		true or false

	See Also: 
		<equal>, <equalPos>	
	*/
	equalSize(comp) {
		ret := (this.w == comp.w)  AND (this.h == comp.h)
		return ret
	}
	/* ---------------------------------------------------------------------------------------
	Method: fromHWnd(hwnd)
		Fills values from given Window (given by Handle)

	Parameters:
		hWnd - Window handle, whose geometry has to be determined

	See Also: 
		<fromWinPos>
	*/
	fromHWnd(hwnd) {
		WinGetPos, x, y, w, h, ahk_id %hwnd%
		this.x := x
		this.y := y
		this.w := w
		this.h := h
		dbgOut("=[" A_ThisFunc "([" hwnd "])] -> x,y,w,h: (" x "," y "," w "," h ")", this.debug)
	}
	/* ---------------------------------------------------------------------------------------
	Method: fromRectangle(new)
	Fills values from given <Rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty.html>

	Parameters:
	new - <Rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty.html>
	*/
	fromRectangle(new) {
		this.x := new.x 
		this.y := new.y
		this.w := new.w
		this.h := new.h
		dbgOut("=[" A_ThisFunc "] -> x,y,w,h: " this.Dump(), this.debug)
	}
	/* ---------------------------------------------------------------------------------------
	Method: __New
	Constructor (*INTERNAL*)

	Parameters:
	x,y,w,h - X,Y (upper left corner coordinates) and Width, Height of the rectangle
	debug - Flag to enable debugging (*Optional* - Default: false)
	*/  
	__New(x=0, y=0, w=0, h=0, debug=false) {   
		this._debug := debug ; _DBG_
		dbgOut("=[" A_ThisFunc "(x=" x ", y=" y ", w=" w ", h=" h ", _debug=" debug ")] (version: " this._version ")", this._debug)
		this.x := x
		this.y := y
		this.w := w
		this.h := h
	}
}

/*!
	End of class
*/
