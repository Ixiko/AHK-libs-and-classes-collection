Class _Menu extends eAutocomplete._BaseMenu {
	__New() {
		local
		base.__New()
		this.itemsBox := new this.ListBox(this.GUIID, "m", "m")
		this.itemsBox.delimiter := "`n"
		this.positioningStrategy := "Menu"
		this.InfoTip := new this._InfoTip(this.itemsBox)
	}
	_dispose() {
		base._dispose()
		this._Positioning := ""
		this.InfoTip._dispose()
		this.itemsBox._dispose()
		this.onItemsBoxUpdate := ""
	}
	__Delete() {
		; MsgBox % A_ThisFunc
		base.__Delete()
	}
	isAvailable() {
	return (this.owner && this.hasSuggestions()) ; && !this.Menu.disabled
	}
	hasSuggestions() {
	return StrLen(this.itemsBox._list)
	}
	_setSuggestionList(_list:="") {
		this.itemsBox.setList(_list)
		(this.onItemsBoxUpdate.call(_list) ? this.suggest() : this.hide())
	}
	_onItemsBoxUpdate := Func("StrLen")
	onItemsBoxUpdate {
		set {
			if (IsFunc(value)) {
				this._onItemsBoxUpdate := StrLen(value) ? Func(value) : value
			} else if (IsObject(value)) {
				this._onItemsBoxUpdate := value
			} else this._onItemsBoxUpdate := ""
		return this._onItemsBoxUpdate
		}
		get {
		return this._onItemsBoxUpdate
		}
	}
	suggest() {
		this.autoWH(), this.autoXY(), this.show("AutoSize"), this.itemsBox.selection.index := 1
	}
	autoXY() {
		local
		this._Positioning.getPos(_x, _y)
		this.move(_x, _y)
	}
	autoWH() {
		this.itemsBox.autoWH()
		this.fitItemsBox()
	}
	fitItemsBox() {
		local
		ControlGetPos,,, _w, _h,, % "ahk_id " . this.itemsBox.HWND
		this.resize(_w, _h)
	}
	disabled {
		set {
			local
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinSet, % (value:=!!value) ? "Disable" : "Enable",, % "ahk_id " . this.GUIID
			DetectHiddenWindows % _detectHiddenWindows
		return this.disabled
		}
		get {
			local
			static WS_DISABLED := 0x8000000
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGet, _style, Style, % "ahk_id " . this.GUIID
			DetectHiddenWindows % _detectHiddenWindows
		return (_style & 0x8000000)
		}
	}
	WM_MOUSEACTIVATE(_wParam, _lParam, _uMsg, _hWnd) {
		static MA_ACTIVATE := 1 ; , MA_NOACTIVATE := 3, MA_NOACTIVATEANDEAT := 4
		Critical
		if (_wParam = this.GUIID) {
		return base.WM_MOUSEACTIVATE(_wParam, _lParam, _uMsg, _hWnd) - !this.__click()
		} else return MA_ACTIVATE
	}
	__click() {
		local
		MouseGetPos,,,, _hwnd, 2
		if (_hwnd+0 = this.itemsBox.HWND+0)
			return !!this.itemsBox.__click()
	}
	hide() {
		base.hide(), this.InfoTip.hide()
	}
	dismiss() {
		this._setSuggestionList()
	}
	_owner := 0x0
	owner { ; to do: interface
		set {
			local
			if (value <> this._owner) {
				GUI, % this.GUIID . ":+Owner" . this._owner:=value
				this.positioningStrategy := this.positioningStrategy
				this.hide()
			}
		return value
		}
		get {
		return this._owner
		}
	}
	_posStrategy := "Menu"
	positioningStrategy {
		set {
			local
			for _strategy in this.PosStrategies {
				if ((_strategy = value) && (_strategy <> "__Class")) {
					_posStrategy := this.PosStrategies[value], this._Positioning := new _posStrategy(this, this.itemsBox)
					this.itemsBox.resizingStrategy := value
				return this._posStrategy:=value
				}
			}
			throw Exception("The Positioning strategy is not available.", -1, value)
		; return this._posStrategy
		}
		get {
		return this._posStrategy
		}
	}
	Positioning {
		get {
		return this._Positioning
		}
		set {
		return this.Positioning
		}
	}
	Class PosStrategies {
		Class DropDownList {
			__New(_menu, _control) {
				this._menu := _menu, this._itemsBox := _control
			}
			getPos(ByRef _x:="", ByRef _y:="") {
				local
				WinGetPos, _x, _y,, _h, % "ahk_id " . this._menu.owner
				_y += _h
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
			}
		}
		Class Menu {
			__New(_menu, _control) {
				this._itemsBox := _control
				this._caretVicinity := new this._CaretVicinity(_menu, _control)
			}
			offsetX {
				set {
				return ((value+0) <> "") ? this._caretVicinity.offsetX:=Round(value) : this._caretVicinity.offsetX
				}
				get {
				return this._caretVicinity.offsetX
				}
			}
			offsetY {
				set {
				return ((value+0) <> "") ? this._caretVicinity.offsetY:=Round(value) : this._caretVicinity.offsetY
				}
				get {
				return this._caretVicinity.offsetX
				}
			}
			getPos(ByRef _x:="", ByRef _y:="") {
				this._caretVicinity.getPos(_x, _y)
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
				this._caretVicinity := ""
			}
			Class _CaretVicinity {
				offsetX := 5
				offsetY := 25
				__New(_menu, _control) {
					this._menu := _menu
					this._itemsBox := _control
				}
				getPos(ByRef _x:="", ByRef _y:="") {
					local
					if (A_CaretX <> (_x:=_y:="")) {
						VarSetCapacity(_POINT_, 8, 0)
						DllCall("User32.dll\GetCaretPos", "Ptr", &_POINT_)
						DllCall("User32.dll\MapWindowPoints", "Ptr", this._menu.owner, "Ptr", 0, "Ptr", &_POINT_, "UInt", 1)
						_x := NumGet(_POINT_, 0, "Int") + this.offsetX, _y := NumGet(_POINT_, 4, "Int") + this.offsetY
					}
				}
			}
		}
	}
	#Include %A_LineFile%\..\_Menu.BasicControlList.ahk
	#Include %A_LineFile%\..\_Menu.ListBox.ahk
	#Include %A_LineFile%\..\_InfoTip.ahk
}
