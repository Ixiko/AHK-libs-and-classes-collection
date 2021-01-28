Class _InfoTip extends eAutocomplete._Window {
	_lastFoundX := -1
	_lastFoundY := -1
	_tip := ""
	__New(_controlList, _TT_WHICH:=19) {
		local
		ToolTip, % Chr(8203), % this._lastFoundX, this._lastFoundY, % this.TT_WHICH := _TT_WHICH
		DetectHiddenWindows, On
		WinGet, _hToolTip, ID, % "ahk_pid " .  DllCall("GetCurrentProcessId") . " ahk_class tooltips_class32"
		DetectHiddenWindows, Off
		this.GUIID := _hToolTip
		this.controlList := _controlList
		this.font := new this.Font(_hToolTip)
		this.hide()
		this.positioningStrategy := "Standard"
		this.font.setCharacteristics("Segoe UI", "s14 italic")
		; WinSet, ExStyle, +E0x08000000, % "ahk_id " . this.GUIID
	}
	Class Font extends eAutocomplete._Window.Text {
		__New(_hTooltip) {
			local
			static WS_CHILD = 0x40000000
			this.hTooltip := _hTooltip
			GUI, New
			GUI +hwnd_GUIID +%WS_CHILD%
			base.__New(_GUIID, 0, 0)
		}
		setCharacteristics(_fontName:="Segoe UI", _options:="") {
			local
			static WM_SETFONT := 0x30
			static WM_GETFONT := 0x31
			_hHost := this._hHost, _hCanvas := this.HWND
			try GUI % _hHost ":Font", % _options, % _fontName
			GuiControl % _hHost ":Font", % _hCanvas
			SendMessage % WM_GETFONT, 0, 0,, % "ahk_id " . _hCanvas
			DllCall("SendMessage", "Ptr", this.hTooltip, "Uint", WM_SETFONT, "Ptr", ErrorLevel, "Ptr", 0)
		}
		__Delete() {
			; MsgBox % A_ThisFunc
			GUI % this._hHost . ":Destroy"
		}
	}
	_dispose() {
		this._Positioning := ""
		this.onInvoke := ""
		this.font := ""
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	_updateTip() {
		local
		_coordModeToolTip := A_CoordModeToolTip
		CoordMode, ToolTip, Screen
		_tip := this._tip := this._getText()
		if (StrLen(_tip))
			ToolTip, % _tip, % this._lastFoundX, this._lastFoundY, % this.TT_WHICH
		CoordMode, ToolTip, % _coordModeToolTip
	}
	show() {
		local
		static SW_SHOWNOACTIVATE := 4
		if (_r:=!this.isVisible()) {
			this.autoXY()
			this._updateTip()
			(StrLen(this._tip) && DllCall("ShowWindow", "Ptr", this.GUIID, "Int", SW_SHOWNOACTIVATE))
		}
	return _r
	}
	hide() {
		local
		if (_r:=this.isVisible())
			WinHide % "ahk_id " . this.GUIID
	return _r
	}
	autoXY() {
		local
		this._Positioning.getPos(_x, _y)
		this.move(_x, _y)
	}
	move(_x, _y) {
		this._lastFoundX := _x, this._lastFoundY := _y
		base.move(_x, _y)
	}
	_getText() {
		local
		_text := this.controlList.selection.text, ((_onInvoke:=this.onInvoke) && (_text:=_onInvoke.call(_text)))
	return _text
	}
	_onInvoke := ""
	onInvoke {
		set {
			if (IsFunc(value)) {
				this._onInvoke := StrLen(value) ? Func(value) : value
			} else if (IsObject(value)) {
				this._onInvoke := value
			} else this._onInvoke := ""
		return this._onInvoke
		}
		get {
		return this._onInvoke
		}
	}
	_posStrategy := "Standard"
	positioningStrategy {
		set {
			local
			for _strategy in this.PosStrategies {
				if ((_strategy = value) && (_strategy <> "__Class")) {
					_posStrategy := this.PosStrategies[value], this._Positioning := new _posStrategy(this.controlList)
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
		Class Standard {
			_offsetX := 40
			offsetX {
				set {
				return ((value+0) <> "") ? this._offsetX:=Round(value) : this._offsetX
				}
				get {
				return this._offsetX
				}
			}
			__New(_controlList) {
				this._controlList := _controlList
			}
			getPos(ByRef _x:="", ByRef _y:="") {
				local
				_controlList := this._controlList
				_controlList.getPos(_x, _y)
				_x += this._offsetX
				_y += _controlList.selection.offsetTop * _controlList.itemHeight - (_controlList.itemHeight // 2)
			}
			__Delete() {
				; MsgBox % A_ThisFunc
			}
		}
	}
}
