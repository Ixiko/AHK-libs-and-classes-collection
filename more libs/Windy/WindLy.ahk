; ****** HINT: Documentation can be extracted to HTML using NaturalDocs (http://www.naturaldocs.org/) ************** 

; ****** HINT: Debug-lines should contain "; _DBG_" at the end of lines - using this, the debug lines could be automatically deleted through scripts before releasing the sourcecode
#include %A_LineFile%\..
#include Windy.ahk
#include Const_WinUser.ahk
#include ..\DbgOut.ahk


/* ******************************************************************************************************************************************
	Class: WindLy
	Class holding lists of <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects

	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original	

	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.
*/
class WindLy {
	_debug := 0
	_version := "0.0.9"
	_wl := {}

	; ##################### Properties (AHK >1.1.16.x) #################################################################
	list[] {
	/* ---------------------------------------------------------------------------------------
	Property: list [get]
	Get the currently stored list (may be determined anytime)
	*/
		get {
			return this._wl
		}
		
		set {
			this._wl := {}
			this._wl := value
			return this.list
	    }
	}
	; ######################## Methods to be called directly ########################################################### 
	/* -------------------------------------------------------------------------------
	Method:	byMonitorId
	Initializes the window list from a given monitor
	
	Parameters:
	id - Monitor-Id

	Returns:
	List of <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects on the given monitor
	*/
	byMonitorId(id=1) {
		this.__reset()
		_tmp := this.__all()
		for h_Wnd, win in _tmp {
			h_WndHex := this.__hexStr(h_Wnd)
			if (win.monitorID = id ) {
			   this._wl[h_WndHex] := win
			}
		}
		_tmp := {}
		return this._wl
	}
	/* -------------------------------------------------------------------------------
	Method:	byStyle
	Initializes the window list by given window style
	
	Parameters:
	myStyle - Windows-Style (<Class WS at http://hoppfrosch.github.io/AHK_Windy/files/Const_WinUser.ahk>)

	Returns:
	List of <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects matching the given style
	*/
	byStyle(myStyle) {
		this.__reset()
		_tmp := this.__all()

		for h_Wnd, win in _tmp {
			WinGet, l_tmp, Style, ahk_id %h_Wnd%
			h_WndHex := this.__hexStr(h_Wnd)
			if (l_tmp & myStyle) {
			   this.Insert(win)
			}
		}
		_tmp := {}
		return this._wl
	}
	/* -------------------------------------------------------------------------------
	Method:	delete
	deletes a single Windy-object from current instance

	Parameters:
	oWindy - <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Object to be deleted
	*/
	delete(oWindy) {
		x := this.__decStr(oWindy._hwnd)
		if (this._wl[this.__decStr(oWindy._hwnd)]) {
			this._wl.Delete(this.__decStr(oWindy._hwnd))
		}
		return this.list
	}
	/* -------------------------------------------------------------------------------
	Method:	difference
	Calculates the DIFFERENCE of the current instance and the given WindLy-Object

	The difference contains only elements from the current instance which are not part of the given WindLy-object

	Parameters:
	oWindLy - <WindLy at http://hoppfrosch.github.io/AHK_Windy/files/WindLy-ahk.html> Object to be used for calculating difference
	*/
	difference(oWindLy) {
		for currhwnd, data in oWindLy.list {
			this.delete(data)
		}
		return this.list
	}
	/* -------------------------------------------------------------------------------
	Method:	insert
	Inserts a single Windy-object into current instance

	Parameters:
	oWindy - <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Object to be inserted
	*/
	insert(oWindy) {
		if (!this._wl[oWindy._hwnd]) {
			h_WndHex := this.__hexStr(oWindy._hwnd)
			this._wl[h_WndHex] := oWindy
		}
	}
	/* -------------------------------------------------------------------------------
	Method:	intersection
	Calculates the INTERSECTION of the given WindLy-Object and the current instance

	The result only contains <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects which 
	have been in the current instance as well as in the given WindLy-Object
	
	Parameters:
	oWindy - <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Object to be inserted
	*/
	intersection(oWindLy) {
		result := new WindLy(this.debug)
		for _currhwnd, _data in oWindLy.list {
			if (this._wl[_data.hwnd]) {
				result.insert(_data)
			}
		}
		this.list := result.list
		return result.list
	}
	/* -------------------------------------------------------------------------------
	Method:	removeNonExisting
	Remove non-existing windows from the list
	
	The result only contains <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects which 
	do currently exist. Non existing windows are removed from the list.
	*/
	removeNonExisting() {
		dbgOut(">[" A_ThisFunc "([" this.hwnd "])]", this.debug)
		u := new WindLy(this.debug)
		u.list := this.list.Clone()
		for key, data in u.list {
			OutputDebug %  "  CURRENT:" key ": " data.hwnd ": " data.title " (" key ")" 
			if !data.exist {
				dbgOut("|[" A_ThisFunc "([" this.hwnd "])] - REMOVE SINCE NON EXISTANT:" key ": " data.hwnd, this.debug)
				u.delete(data)
			}
		}
		this.list := u.list.Clone()
		dbgOut("<[" A_ThisFunc "([" this.hwnd "])]", this.debug)
		return this.list
	}
	/* -------------------------------------------------------------------------------
	Method:	snapshot
	Initializes the window list from all currently openend windows
	
	Returns:
	List of <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects.
	*/
	snapshot() {
	  dbgOut(">[" A_ThisFunc "()]", this.debug)
		this.__reset()
		this._wl := this.__all()
		dbgOut("<[" A_ThisFunc "()]", this.debug)
		return this._wl
	}
	/* -------------------------------------------------------------------------------
	Method:	symmetricDifference
	Calculates the SYMMETRICDIFFERENCE of the given WindLy-Object and the current instance

	The result only contains <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects which 
	have not been in the current instance as well as not in the given WindLy-Object (Removes items which occur in both lists)
	
	Parameters:
	oWindy - <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Object to operate with
	*/
	symmetricDifference(oWindLy) {
		result := new WindLy(this.debug)
		u := new WindLy(this.debug)
		i := new WindLy(this.debug)

		; The symmetric difference is the union without the intersection:
		u.list := this.list.Clone()
		u.union(oWindly)
		for key, data in u.list {
			OutputDebug %  "  UNION:" key ": " data.hwnd ": " data.title " (" key ")" 
		}
		i.list := this.list.Clone()
		i.intersection(oWindly)
		for key, data in i.list {
			OutputDebug %  "  UNION:" key ": " data.hwnd ": " data.title " (" key ")" 
		}

		u.difference(i)

		this.list := u.list.Clone()
		return this.list
	}
	/* -------------------------------------------------------------------------------
	Method:	union
	Calculates the UNION of the given WindLy-Object and the current instance

	The Union contains all elements from the current instance as well as the given WindLy-object

	Parameters:
	oWindLy - <WindLy at http://hoppfrosch.github.io/AHK_Windy/files/WindLy-ahk.html> Object to be used for calculating union
	*/
	union(oWindLy) {
		for currhwnd, data in oWindLy.list {
			this.insert(data)
		}
		return this.list
	}

	; ######################## Internal Methods - not to be called directly ############################################
	; ===== Internal Methods =========================================================
	/*! -------------------------------------------------------------------------------
	method: __all
	Gets all currently openend windows and returns as a List of Objects (*INTERNAL*)

	Returns:
	List of <Windy at http://hoppfrosch.github.io/AHK_Windy/files/Windy-ahk.html> Objects
	*/
	__all() {
	  dbgOut(">[" A_ThisFunc "()]", this.debug)
		hwnds := this.__hwnds(true)
		ret := {}

		Loop % hwnds.MaxIndex() {
			h_Wnd := hwnds[A_Index]
			h_WndHex := this.__hexStr(h_Wnd)
			_w := new Windy(h_Wnd, this.debug)
			ret[h_WndHex] := _w
		}
		dbgOut("<[" A_ThisFunc "()]", this.debug)
		return ret
	}
	/*! ---------------------------------------------------------------------------------------
	Method:   __hwnds
	Determines handles of all current windows(*INTERNAL*)

	Parameters:
		windowsonly  - Flag to filter on "real windows" (Default: *true*)

	Returns:
		Array with determined window handles
	*/
	__hwnds(windowsOnly = true) {
		ret := Object()
		WinGet, _Wins, List

		Loop %_Wins%
		{
			h_Wnd:=_Wins%A_Index%
			h_WndHex := this.__hexStr(h_Wnd)
			bAdd := true
			if (windowsOnly = true) {
				bAdd := this.__isRealWindow(h_Wnd)
			}
			if (bAdd = true) {
				ret.Insert(h_WndHex)
			}
		}
		return ret
		
	
	}
	/*! ---------------------------------------------------------------------------------------
	Method:   __isRealWindow
	Checks whether the given hWnd refers to a TRUE window (As opposed to the desktop or a menu, etc.) (*INTERNAL*)

	Parameters:
		hwnd  - Handle of window to check (*Obligatory*)

	Returns:
		true (window is a true window), false (window is not a true window)

	Author(s):
		Original - <ManaUser at http://www.autohotkey.com/board/topic/25393-appskeys-a-suite-of-simple-utility-hotkeys/>
	*/
	__isRealWindow(h_Wnd) {
		WinGet, s, Style, ahk_id %h_Wnd% 
		ret := s & WS.CAPTION ? (s & WS.POPUP ? 0 : 1) : 0
		dbgOut("=[" A_ThisFunc "([hWnd=" h_wnd "])] -> " ret, this.debug)
		return ret
	}
	/*! -------------------------------------------------------------------------------
	method: __reset
	Initializes all the data (*INTERNAL*)
	*/
	__reset() {
	  dbgOut("=[" A_ThisFunc "()]", this.debug)
		this._wl := {}
	}
	/* ---------------------------------------------------------------------------------------
	Method: __New
		Constructor (*INTERNAL*)

	Parameters:
		_debug - Flag to enable debugging (Optional - Default: 0)
	*/   
	__New(_debug=0) {
		this._debug := _debug
		dbgOut(">[" A_ThisFunc "()] (version: " this._version ")", _debug)

		if % (A_AhkVersion < "1.1.20.02" || A_AhkVersion >= "2.0") {
			MsgBox 16, Error, %A_ThisFunc% :`n This class only needs AHK later than 1.1.20.01 (and before 2.0)`nAborting...
			if (this._debug) ; _DBG_
				OutputDebug % "<[" A_ThisFunc "(...) -> ()]: *ERROR* : This class needs AHK later than 1.1.20.01 (and before 2.0). Aborting..." ; _DBG_
			return
		}
		dbgOut("<[" A_ThisFunc "()]", _debug)		
		return this
	}
	/*! ---------------------------------------------------------------------------------------
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
	
	__decStr(i) {
		OldFormat := A_FormatInteger ; save the current format as a string
		SetFormat, Integer, D
		i += 0 ;forces number into current fomatinteger
		SetFormat, Integer, %OldFormat% ;if oldformat was either "hex" or "dec" it will restore it to it's previous setting
		return i
	}
}
