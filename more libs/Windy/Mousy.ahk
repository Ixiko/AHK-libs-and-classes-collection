; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

#include %A_LineFile%\..
#include Pointy.ahk
#include Recty.ahk
#include Mony.ahk
#include MultiMony.ahk
#include Const_WinUser.ahk

/* ******************************************************************************************************************************************
	Class: Mousy
    Toolset to handle mousecursor within a MultiMonitorEnvironment

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/

class Mousy {
	_version := "1.1.4"
	_debug := 0 ; _DBG_	
	_showLocatorAfterMove := 1

	_bConfine := false
	_confineRect := new Recty()
	_movespeed := 50
	_movemode := 1 

	; ===== Properties ===============================================================
	confine[] {
	/* -------------------------------------------------------------------------------
	Property: confine [get/set]
	Should the mouse be confined/fenced into a rectangle?

	The rectangle is set via <confineRect at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#confineRect>

	Value:
	flag - *true* or *false*

	Examples: 
	> obj.confineRect := new Recty(100,100,500,500)
	> obj.confine := true  ; Confining to previously defined rect is enabled
	> obj.confine := false ; Confining to previously defined rect is disabled
	> obj.confine := true  ; Confining to previously defined rect is re-enabled
	*/
		get {
			return this._bConfine
		}
		set {
			OutputDebug % ">[" A_ThisFunc "()] -> New:" value " <-> Current:" this._bConfine ; _DBG_
			if (value== false) {
				this._bConfine := false
				ret := DllCall( "ClipCursor" )				
				OutputDebug % ">" ret ; _DBG_
			}
			else {
				rect := this.confineRect
				VarSetCapacity(R,16,0),NumPut(rect.xul,&R+0),NumPut(rect.yul,&R+4),NumPut(rect.xlr,&R+8),NumPut(rect.ylr,&R+12)
				this._bConfine := true
				DllCall("ClipCursor",UInt,&R)
			}
			return this._bConfine
		}
	}
	confineRect[] {
	/* -------------------------------------------------------------------------------
	Property: confineRect [get/set]
	Rectangle to be considered with confine (given as <rectangle at http://hoppfrosch.github.io/AHK_Windy/files/Recty-ahk.html>).

	Confining can be enabled/disabled via property <confine at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#confine>

	Value:
	rect - confining rectangle

	See Also:
	<confine at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#confine>
	*/
		get {
			return this._confineRect
		}
		set {
			this._confineRect.x := value.x
			this._confineRect.y := value.y
			this._confineRect.w := value.w
			this._confineRect.h := value.h
			return this._confineRect
		}
	}
	debug[] { ; _DBG_
   	/* -------------------------------------------------------------------------------
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/
		get {                                                                          ; _DBG_ 
			return this._debug                                                         ; _DBG_
		}                                                                              ; _DBG_
		set {                                                                          ; _DBG_
			mode := value<1?0:1                                                        ; _DBG_
			this._debug := mode                                                        ; _DBG_
			return this._debug                                                         ; _DBG_
		}                                                                              ; _DBG_
	}	
	monitorID[] {
	/* ---------------------------------------------------------------------------------------
	Property: monitorID [get/set]
	Get or Set the monitor the mouse is currently on
	*/
		get {
			md := new MultiMony(this._debug)
			return md.idFromMouse()
		}
		set {
			currMon := this.monitorID
			OutputDebug % "<[" A_ThisFunc "()] - >New:" value "<-> Current:" CurrMon ; _DBG_
			if (value != currMon) {
				md := new MultiMony(this._debug)
				; Determine relative Coordinates relative to current monitor
				curr := md.coordVirtualScreenToDisplay(this.x,this.y) 
				; Determine scaling factors from current monitor to destination monitor
				monCurr := new Mony(currMon, this._debug)
				scaleX := monCurr.scaleX(value)
				scaleY := monCurr.scaleY(value)
				mon := new Mony(value, this._debug)
				r := mon.boundary
				; Scale the relative coordinates and add them to the origin of destination monitor
				x := r.x + scaleX*curr.pt.x
				y := r.y + scaleY*curr.pt.y
				; Move the mouse onto new monitor
				this.__move(x, y)
			}
			return this.monitorID
		}
	}
	moveMode[] {
	/* ---------------------------------------------------------------------------------------
	Property: moveMode [get/set]
	Movement mode while moving the mouse via <pos at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#pos>, <x at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#x>, <y at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#y>

	This has to be a value out of 
	
	 * 0: mouse jumps immediatialy to the new position
	 * 1: mouse moves to new position following a linear track (default)
	 * 2: mouse moves to new position following a random track jittering along a line
	 * 3: mouse moves to new position following a random track following a bezier curce

	The speed of the movement can be set via <moveSpeed at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#moveSpeed>
	*/
		get {
			return this._movemode
		}
		set {
			if (value < 0)
				value := 0
			if (value > 3)
				value := 3
			this._movemode := value
			return value
		}
	}
	moveSpeed[] {
	/* ---------------------------------------------------------------------------------------
	Property: moveSpeed [get/set]
	Speed while moving the mouse via <pos at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#pos>, <x at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#x>, <y at http://hoppfrosch.github.io/AHK_Windy/files/Mousy-ahk.html#y>

	This has to be a value from range [0 (instant) ..100 (slow)]
	*/
		get {
			return this._movespeed
		}
		set {
			if (value < 0)
				value := 0
			if (value > 100)
				value := 100
			this._movespeed := value
			return value
		}
	}
	pos[] {
	/* ---------------------------------------------------------------------------------------
	Property: pos [get/set]
	Get or Set position of mouse as a <point at http://hoppfrosch.github.io/AHK_Windy/files/Pointy-ahk.html>

	See also: 
	<x  [get/set]>, <y  [get/set]>
	*/
		get {
			pt := new Pointy()
			return pt.fromMouse()
		}
		
		set {
			this.__move(value.x, value.y)
			return value
		}
	}
	showLocatorAfterMove[] {
	/* ---------------------------------------------------------------------------------------
	Property: showLocatorAfterMove [get/set]
	Get or Set the flag to show the Mouse-Locator after moving the mouse
	*/
		get {
			return this._showLocatorAfterMove
		}
		set {
			this._showLocatorAfterMove := value
			return value
		}
	}
	speed[] {
	/* ---------------------------------------------------------------------------------------
	Property: speed [get/set]
	Get or Set the speed of the mouse on (manual) mouse movement.

	This has to be a value from range [0..20]

	This value can also be set/get via System-Settings of Mouse within your windows-OS
	*/
		get {
			CurrMouseSpeed := 0
			DllCall("SystemParametersInfo", UInt, SPI.GETMOUSESPEED, UInt, 0, UIntP, CurrMouseSpeed, UInt, 0)
			return CurrMouseSpeed
		}
		set {
			if (value < 0)
				value := 0
			if (value > 20)
				value := 20
				
			DllCall("SystemParametersInfo", UInt, SPI.SETMOUSESPEED, UInt, 0, UInt, value, UInt, 0)
			return this.speed
		}
	}
	trail[] {
	/* ---------------------------------------------------------------------------------------
	Property: trail [get/set]
	Get or Set the drawing of a trail on (manual) mouse movement

	This has to be a value from range [0 (disabled)..7]

	This value can also be set/get via System-Settings of Mouse within your windows-OS
	*/
		get {
			nTrail := 0
			DllCall("SystemParametersInfo", UInt, SPI.GETMOUSETRAILS, UInt, 0, UIntP, nTrail, UInt, 0)
			return nTrail
		}
		set {
			if (value < 0)
				value := 0
			if (value > 7)
				value := 7
				
			DllCall("SystemParametersInfo", UInt, SPI.SETMOUSETRAILS, UInt, value, Str, 0, UInt, 0)
			return this.trail
		}
	}
	version[] {
    /* -------------------------------------------------------------------------------
	Property: version [get]
	Version of the class

	Remarks:
	* There is no setter available, since this is a constant system property
	*/
		get {
			return this._version
		}
	}
	x[] {
	/* ---------------------------------------------------------------------------------------
	Property: x [get/set]
	Get or Set x-coordinate of mouse

	See also: 
	<pos [get/set]>, <y [get/set]>
	*/
		get {
			return this.pos.x
		}
		
		set {
			this.__move(value, this.y)
			return value
		}
	}
	y[] {
	/* ---------------------------------------------------------------------------------------
	Property: y [get/set]
	Get or Set y-coordinate of mouse

	See also: 
	<pos [get/set]>, <x [get/set]>
	*/
		get {
			return this.pos.y
		}
		
		set {
			this.__move(this.x, value)
			return value
		}
	}

	; ===== Methods ==================================================================
	/* ---------------------------------------------------------------------------------------
	Method: dump
	Dumps coordinates to a string
	
	Returns:
	printable string containing coordinates
	*/
	dump() {
		return "(" this.x "," this.y ")"
	}

	/* ---------------------------------------------------------------------------------------
	Method: locate
	Easy find the mouse
	*/
	locate() {
	
		applicationname := A_ScriptName
		
		SetWinDelay,0 
		DetectHiddenWindows,On
		CoordMode,Mouse,Screen
		
		delay := 100
		size1 := 250
		size2 := 200
		size3 := 150
		size4 := 100
		size5 := 50
		col1 := "Red"
		col2 := "Blue"
		col3 := "Yellow"
		col4 := "Lime"
		col5 := "Green"
		boldness1 := 700
		boldness2 := 600
		boldness3 := 500
		boldness4 := 400
		boldness5 := 300
		
		Transform, OutputVar, Chr, 177
		
		Loop,5
		{ 
			MouseGetPos,x,y 
			size:=size%A_Index%
			width:=Round(size%A_Index%*1.4)
			height:=Round(size%A_Index%*1.4)
			colX:=col%A_Index%
			boldness:=boldness%A_Index%
			Gui,Mousy%A_Index%:New
			Gui,Mousy%A_Index%:+Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow 
			Gui,Mousy%A_Index%:Margin,0,0 
			Gui,Mousy%A_Index%:Color,123456
			
			Gui,Mousy%A_Index%:Font,c%colX% S%size% W%boldness%,Wingdings
			Gui,Mousy%A_Index%:Add,Text,,%OutputVar%
			
			Gui,Mousy%A_Index%:Show,X-%width% Y-%height% W%width% H%height% NoActivate,%applicationname%%A_Index%
			WinSet,TransColor,123456,%applicationname%%A_Index%
		}
		Loop,5
		{
			MouseGetPos,x,y 
			WinMove,%applicationname%%A_Index%,,% x-size%A_Index%/1.7,% y-size%A_Index%/1.4
			WinShow,%applicationname%%A_Index%
			Sleep,%delay%
			WinHide,%applicationname%%A_Index%
			;Sleep,%delay% 
		}
		
		Loop,5
		{ 
			Gui,Mousy%A_Index%:Destroy
		}
	}
	
	; ===== Internal Methods =========================================================
	/* ---------------------------------------------------------------------------------------
	Method:  __move
	Moves the mouse to given coordinates (*INTERNAL*)

	Parameters:
	x,y - Coordinates to move to
	*/  
	__move(x,y, mode = -1, speed = -1) {
		if (speed == -1) {
			speed := this._movespeed
		}
		if (mode == -1) {
			mode := this._movemode
		}
		T := A_MouseDelay
   		SetMouseDelay, -1
		CoordMode, Mouse, Screen
		if (mode == 0) {
			MouseMove % x, y, 0
		}
		else if (mode == 1) {
			MouseMove % x, y, speed
		}
		else if (mode == 2) {
			this.__moveRandomLinear(x, y, speed)
		}
		else if (mode == 3) {
			this.__moveRandomBezier(x, y, speed)
		}
		if (this.showLocatorAfterMove == 1)
			this.locate()
		SetMouseDelay, % T
	}

	/* ---------------------------------------------------------------------------------------
	Method:  __moveRandomBezier
	Moves the mouse to given coordinates on a random path, following a bezier curve  (*INTERNAL*)

	Parameters:
	x,y - Coordinates to move to

	Authors:
	* Original: <masterfocus at https://github.com/MasterFocus/AutoHotkey/tree/master/Functions/RandomBezier>
	*/
    __moveRandomBezier(x, y, Speed=-1) {
    	if (speed == -1) {
			speed := this._movespeed
		}

		time := 5000/100 * speed

		T := A_MouseDelay
   		SetMouseDelay, -1
   		MouseGetPos, CX, CY
   		RandomBezier(CX, CY, x, y, "T" time)
   		SetMouseDelay, % T
	}

	/* ---------------------------------------------------------------------------------------
	Method:  __moveRandomLinear
	Moves the mouse to given coordinates on a random path, jittering along a line (*INTERNAL*)

	Parameters:
	x,y - Coordinates to move to

	Authors:
	* Original: <slanter me at http://slanter-ahk.blogspot.de/2008/12/ahk-random-mouse-path-mousemove.html>
	*/
    __moveRandomLinear(x, y, Speed=-1) {
    	if (speed == -1) {
			speed := this._movespeed
		}
   		T := A_MouseDelay
   		SetMouseDelay, -1
   		MouseGetPos, CX, CY
   		Pts := Round(Sqrt((X - CX)**2 + (Y - CY)**2) / 30,0)
   		Loop %Pts% {
      		Random, NX, % CX - ((CX - X) / Pts) * (A_Index - 1), % CX - ((CX - X) / Pts) * A_Index
      		Random, NY, % CY - ((CY - Y) / Pts) * (A_Index - 1), % CY - ((CY - Y) / Pts) * A_Index
      		MouseMove, % NX, % NY, % speed
		}
   		MouseMove, % X, % Y, % Speed
   		SetMouseDelay, % T
	}
	
	/* -------------------------------------------------------------------------------
	Constructor: __New
	Constructor (*INTERNAL*)
		
	Parameters:
	debug - Flag to enable debugging (Optional; Default: 0)
	*/  
	__New( debug := false ) {
		this._debug := debug ; _DBG_
		if (this._debug) ; _DBG_
			OutputDebug % "|[" A_ThisFunc ")] (version: " this._version ")" ; _DBG_
	}
}


/*
RandomBezier.ahk
Copyright (C) 2012,2013 Antonio França
This script is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
This script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License
along with this script. If not, see <http://www.gnu.org/licenses/>.
*/
;========================================================================
;
; Function: RandomBezier
; Moves the mouse through a random Bézier path
; URL (+info): --------------------
;
; Last Update: 30/May/2013 03:00h BRT
;
; Author:
; * Created by MasterFocus (https://github.com/MasterFocus, http://masterfocus.ahk4.net, http://autohotkey.com/community/viewtopic.php?f=2&t=88198)
RandomBezier( X0, Y0, Xf, Yf, O="") {
	Time := RegExMatch(O,"i)T(\d+)",M)&&(M1>0)? M1: 10
	RO := InStr(O,"RO",0) , RD := InStr(O,"RD",0)
	N:=!RegExMatch(O,"i)P(\d+)(-(\d+))?",M)||(M1<2)? 2: (M1>19)? 19: M1
	If ((M:=(M3!="")? ((M3<2)? 2: ((M3>19)? 19: M3)): ((M1=="")? 5: ""))!="")
	Random, N, %N%, %M%
	OfT:=RegExMatch(O,"i)OT(-?\d+)",M)? M1: 100, OfB:=RegExMatch(O,"i)OB(-?\d+)",M)? M1: 100
	OfL:=RegExMatch(O,"i)OL(-?\d+)",M)? M1: 100, OfR:=RegExMatch(O,"i)OR(-?\d+)",M)? M1: 100
	MouseGetPos, XM, YM
	If ( RO )
		X0 += XM, Y0 += YM
	If ( RD )
		Xf += XM, Yf += YM
	If ( X0 < Xf )
		sX := X0-OfL, bX := Xf+OfR
	Else
		sX := Xf-OfL, bX := X0+OfR
	If ( Y0 < Yf )
		sY := Y0-OfT, bY := Yf+OfB
	Else
		sY := Yf-OfT, bY := Y0+OfB
	Loop, % (--N)-1 {
		Random, X%A_Index%, %sX%, %bX%
		Random, Y%A_Index%, %sY%, %bY%
	}
	X%N% := Xf, Y%N% := Yf, E := ( I := A_TickCount ) + Time
	While ( A_TickCount < E ) {
		U := 1 - (T := (A_TickCount-I)/Time)
		Loop, % N + 1 + (X := Y := 0) {
			Loop, % Idx := A_Index - (F1 := F2 := F3 := 1)
				F2 *= A_Index, F1 *= A_Index
			Loop, % D := N-Idx
				F3 *= A_Index, F1 *= A_Index+Idx
			M:=(F1/(F2*F3))*((T+0.000001)**Idx)*((U-0.000001)**D), X+=M*X%Idx%, Y+=M*Y%Idx%
		}
		MouseMove, %X%, %Y%, 0
		Sleep, 1
	}
	MouseMove, X%N%, Y%N%, 0
	Return N+1
}