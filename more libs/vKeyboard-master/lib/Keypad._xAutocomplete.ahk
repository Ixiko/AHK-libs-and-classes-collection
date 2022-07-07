Class _xAutocomplete extends eAutocomplete {
	static _propertiesExt :=
	(LTrim Join C
		{
			autoSuggest: true,
			onResize: "",
			bkColor: "000000",
			fontName: "Segoe UI",
			fontSize: 17,
			fontColor: "000000" ; ++++
		}
	)
	__New(_GUIID, _hHostControl, _isComboBox, _opt:="") {
		local
		base.__New(_GUIID, _hHostControl, true, _opt)
		base._Hotkey(this._hkIfFn)
		sleep, 15
		this._timestamp := A_TickCount
		base._setOptions(this, "_propertiesExt",, true)
		this.fontName := this._fontName
		this.fontSize := this._fontSize
		this.fontColor := this._fontColor
	}
	fontName {
		set {
		return value, this._setFont(StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop(), value)
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()] ; ~
		}
	}
	fontSize {
		set {
		return value, this._setFont(StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop(), value)
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()] ; ~
		}
	}
	fontColor {
		set {
		return value, this._setFont(StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop(), value)
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()] ; ~
		}
	}
		_setFont(_k, _v) {
			this["_" . _k] := _v
			try GUI % this._parent . ":Font", % Format("c{1} s{2}", this._fontColor, this._fontSize), % this._fontName
			GuiControl, Font, % this.hwnd
		return _v
		}
	bkColor {
		set {
			try GUI % this._parent . ":Color",, % this._bkColor:=value
		return value
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()] ; ~
		}
	}
	autoSuggest {
		set {
		return this._autoSuggest
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()]
		}
	}
	onResize {
		set {
		return this._onResize
		}
		get {
		return this["_" . StrSplit(SubStr(A_ThisFunc, 1, -4), ".").pop()]
		}
	}
	dispose() {
		ObjRawSet(this, "_onResize", "")
		this._unsetHotkeys()
		base.dispose()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	_unsetHotkeys() {
		try Hotkey.deleteAll(this._timestamp)
	}
	_setHotkeys(_basicOperationsWrapper, _obj, _joystickPort, _joyModifier) {
		local
		global Hotkey
		this._unsetHotkeys()
		_lastFoundGroup := := Hotkey.setGroup(), Hotkey.setGroup(this._timestamp)
		try {
			Hotkey.InTheEvent(this._hotkeyPressHandler.bind(this.HWND, ""))
			for _procName, _keyName in _obj.keyboard {
				(_hk := new Hotkey(_keyName)).onEvent(_basicOperationsWrapper[_procName].bind("", this))
			}
			for _k, _v in _obj.joystick, _obj_ := {}
					_obj_[ Trim(_v) ] := _k
			for _keyName, _procName in _obj_ {
				_keyName := RegExReplace(_keyName:=Trim(_keyName), "i)^!(?=\d{1,2}Joy\d{1,2}$)", "", _count)
				_params := [ this.HWND ], _params.insertAt(2, (_count) ? _joystickPort . _joyModifier : "")
				Hotkey.InTheEvent(this._hotkeyPressHandler.bind(_params*))
					new Hotkey(_keyName).onEvent(_basicOperationsWrapper[_procName].bind("", this))
			}
		} catch _exception {
			this._unsetHotkeys()
			throw Exception(_exception.message, -1, _exception.extra)
		} finally {
			Hotkey.InTheEvent(), Hotkey.setGroup(_lastFoundGroup)
		}
	} ; +++++++
		_hotkeyPressHandler(_joyModifier, _params*) {
			local
			if (_joyModifier <> "") {
				if not (GetKeyState(_joyModifier))
			return false
			}
			; _thisHotkey := _params.pop()
			_inst := base._instances[ _hHostControl:=this ]
			if (_inst._disabled || !_inst._ready || !WinActive("ahk_id " . _inst._parent))
				return false
			_listbox := _inst._listbox
			if not (_listbox._visible) {
				; if (_params.hasKey(_thisHotkey) && _listbox._itemCount)
				if (_listbox._itemCount)
					return true, _inst._listbox._showDropDown()
				return false
			}
			return true
		} ; +++++++
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	focus() {
		GuiControl, Focus, % this.hwnd
	}
	send(_keys) {
		this.focus()
		ControlSend,, % _keys, % this.AHKID
	}
	sendText(_text) {
		this.send("{Text}" . _text)
	}
	getText(ByRef _text:="") {
		GuiControlGet, _text,, % this.hwnd
	}
	setText(_text:="") {
		ControlSetText,, % _text, % this.AHKID
	} ; +++++++
	_clearContent() {
		this._Value._rawClear(this.hwnd)
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	Class _ListBox extends eAutocomplete._ListBox {
		__New(_GUIID, _hHostControl) {
			base.__New(_GUIID, _hHostControl)
			GUI, % this._owner . ":Add", Text, hwnd_hText x0 y0 w0 h0,
			this._compartment := _hText
		}
		_show(_boolean:=true) {
			base._show(_boolean)
			if (DllCall("IsWindowVisible", "Ptr", this._owner)) ; ~ onSuggestionsAvailable
				GUI % this._owner . ":Show", % "NA AutoSize" ; ~ onSuggestionsAvailable
		}
		_hideDropDown() {
		this._dismiss()
		}
		_dismiss() {
		this._setData(""), this._show(false)
		}
		; __Delete() {
			; base.__Delete()
			; MsgBox % A_ThisFunc
		; }
	}
	Class _ComboBoxList extends Keypad._xAutocomplete._ListBox {
		__New(_GUIID, _hHostControl) {
			local
			base.__New(_GUIID, _hHostControl)
			GUI % this._parent . ":+Parent" . this._owner
			_fn := this.__select.bind(this)
			GuiControl, +g, % this._HWND, % _fn
		}
		_getWidth(_list) {
			local
			global eAutocomplete
			_w := eAutocomplete._DropDownList._getWidth.call(this, _list)
		return _w, (_w && _w += 10)
		}
		_autoWH(_params*) {
			local
			_lastFoundWindow := WinExist()
			if not (WinExist("ahk_id " . this._host))
				return "", WinExist("ahk_id " . _lastFoundWindow)
			_w := this._lastWidth := this._getWidth(_params.1)
			try GuiControl, Move, % this._compartment, % "w" . _w
			GuiControl, Move, % this._HWND, % " w" . _w
			GUI % this._parent . ":Show", % "NA AutoSize"
			; WinSet, Redraw
			WinExist("ahk_id " . _lastFoundWindow)
		}
		_autoXY() {
			local
			_lastFoundWindow := WinExist()
			if not (WinExist("ahk_id " . this._host))
				return "", WinExist("ahk_id " . _lastFoundWindow)
			VarSetCapacity(_RECT_, 16, 0)
			DllCall("User32.dll\GetWindowRect", "Ptr", this._host, "Ptr", &_RECT_)
			DllCall("User32.dll\MapWindowPoints", "Ptr", 0, "Ptr", this._owner, "Ptr", &_RECT_, "UInt", 2)
			_y := NumGet(&_RECT_, 4, "Int"), _w := NumGet(&_RECT_, 8, "Int")
			try GuiControl, Move, % this._compartment, % "x" . _w
			GUI % this._parent . ":Show", % "NA x" . _w . " y" . _y
			; WinSet, Redraw
			WinExist("ahk_id " . _lastFoundWindow)
		}
		; __Delete() {
			; base.__Delete()
			; MsgBox % A_ThisFunc
		; }
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	Class _Value extends eAutocomplete._Value {
		registerProc(_idProcess) {
			local
			if not (base.processes.hasKey(_idProcess)) {
				base.processes[_idProcess] := []
				_callback := RegisterCallback(base.__Class . ".__valueChange")
				_hWinEventHook := DllCall("User32.dll\SetWinEventHook"
												, "Uint", 0x800E
												, "Uint", 0x800E
												, "Ptr", 0
												, "Ptr", _callback
												, "Uint", _idProcess
												, "Uint", 0
												, "Uint", 0)
				base.processes[_idProcess].push(_hWinEventHook)
			}
		}
		_rawClear(_hwnd) {
			local
			_state := base.bypassToggle
			base.bypassToggle := true
			GuiControl,, % _hwnd
			sleep, 300 ; check messages of the internal message queue
			base.bypassToggle := _state
		}
	}
}