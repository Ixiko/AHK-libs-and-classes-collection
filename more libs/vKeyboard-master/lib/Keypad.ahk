#Include %A_LineFile%\..\AutoHotkey-JSON-master\JSON.ahk
#Include %A_LineFile%\..\eAutocomplete-1.2.30\eAutocomplete.ahk
#Include %A_LineFile%\..\_Keypad.ahk
Class Keypad extends _Keypad {
	_hLastFoundControl := 0x0
	, _hideOnSubmit := true
	, _resetOnSubmit := true
	, _alwaysOnTop := true
	, _transparency := 255
	_Init() {
		static _ := Keypad._Init()
		vKeyboard._defineLayout("", "[[[null]]]",, "StrLen", true)
	}
	__New(_excpLevel:=-1) {
		local
		try {
			base.__New(0x0)
			this._autocomplete := this._xAutocomplete.create(this._hostWindow.HWND, "xs ys-150 h140 +Resize") ; ~
		} catch _exception {
			throw Exception(_exception.message, _excpLevel, _exception.extra)
		}
		this.alwaysOnTop := this._alwaysOnTop
		this.transparency := this._transparency

		this._hostWindow.onResize := ObjBindMethod(this, "_hostWindowGUISize") ; +++++++
		this._onResize := ObjBindMethod(this, "_onSize")
		ObjRawSet(this._autocomplete, "_onResize", ObjBindMethod(this, "_autocompleteOnResize"))

		this.setLayout("")

	} ; ++++
	autocomplete {
		set {
		return this._autocomplete
		}
		get {
		return this._autocomplete
		}
	}

	setLayout(_layout, _layer:=1, _center:=false) {
		local
		if ((_r:=base.setLayout(_layout, _layer)) > 0) {
			(_center && (this.hostWindow.show(((this.hostWindow.isVisible()) ? "Hide ": "") . "NA XCenter YCenter"))) ; ++++
		} else {
			throw Exception("Could not set the specified layout", -1, _layout)
		; return
		}
	return _r
	} ; ++++
	setStyle(_style) { ; https://developer.mozilla.org/fr/docs/Web/CSS/Type_color
		local
		if (this._style <> _style) {
			try base.setStyle(_style)
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			; return
			}
			_bkColor := this.backgroundColor
			GUI % this._hostWindow.HWND ":Color", % _bkColor
		}
	return _style
	} ; ++++

	alwaysOnTop {
		set {
			local
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinSet, AlwaysOnTop, % value:=!!value, % "ahk_id " . this._hostWindow.HWND ; 1.1.30.00+
			DetectHiddenWindows % _detectHiddenWindows
		return this._alwaysOnTop:=value
		}
		get {
			local
			WinGet, _exStyle, ExStyle, % "ahk_id " . this._hostWindow.HWND
		return !!this._alwaysOnTop:=(_exStyle & 0x8) ; WS_EX_TOPMOST := 0x8
		}
	}
	transparency {
		set {
			local
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinSet, Transparent, % this._transparency:=this._autocomplete.ListBox.transparency:=value, % "ahk_id " . this._hostWindow.HWND
			DetectHiddenWindows % _detectHiddenWindows
			return this._transparency
		}
		get {
		return this._transparency
		}
	}

	hideOnSubmit {
		set {
		return this._hideOnSubmit:=!!value
		}
		get {
		return this._hideOnSubmit
		}
	}
	resetOnSubmit {
		set {
		return this._resetOnSubmit:=!!value
		}
		get {
		return this._resetOnSubmit
		}
	}
	__submit := ""
	onSubmit(_args*) {
		return this._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
	}
	__showHide := ""
	onshowHide(_args*) {
		return this._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
	}
	showHide(_boolean:="") {
		local
		if (_boolean <> (_isVisible:=this._hostWindow.isVisible())) {
			if not (_isVisible) {
				this._hLastFoundControl := this._updateLastFoundControl(), this._hostWindow.show()
			} else {
				this._hostWindow.hide()
			}
			_r := !_isVisible, (this.__showHide && this.__showHide.call(this, _r))
		return _r
		}
		return -1
	}
		_updateLastFoundControl() {
			local
			_focusedControl := ""
			try ControlGetFocus, _focusedControl, A
			if (_focusedControl) {
				ControlGet, _ID, Hwnd,, % _focusedControl, A
			return _ID
			}
		}
	_submit(_hideOnSubmit:=true, _resetOnSubmit:=false, _callback:=false) {
		local
		this.altReset()
		this._autocomplete.getText(_text)
		if (_resetOnSubmit || this._resetOnSubmit) {
			this._autocomplete._clearContent()
		}
		if (_hideOnSubmit || this.hideOnSubmit)
			this._hostWindow.hide()
		if (_callback || this.__submit) {
			this.__submit.call(this, this._hLastFoundControl, _text)
		}
	}
	Class _Callbacks {
		chain := []
		__New(_args*) {
			local
			if not (ObjCount(_args))
				return this
			for _i, _fn in _args {
				if not (IsObject(_fn) || _args[_i]:=Func(_fn)) {
					throw Exception("Invalid callback.", -1)
				; return
				}
			}
			for _i, _fn in _args
				this.chain.push(_fn)
		}
		call(_args*) {
			local
			for _, _fn in this.chain
				%_fn%(_args*)
		}
		_on(_inst, _callee, _args*) {
			local _functor, _exception, _classPath, _className, _obj
			_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
			_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
			try _functor:=new _obj(_args*)
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			; return
			}
			_inst["__" . LTrim(_callee, "on")] := _functor
		}
	}

	fitContent(_size:="", _multiplier:=6, _center:=true) {
		base.fitContent(_size, _multiplier)
		if (_center && this.hostWindow.isVisible())
			this.hostWindow.show("NA XCenter YCenter")
	} ; ++++

	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	_hostWindowGUISize(_hostWindow, _wParam, _lParam, _msg, _hwnd) {
		local
		_controlDelay := A_ControlDelay
		SetControlDelay, 2
		_width := _lParam & 0xFFFF, _heigth := _lParam >> 16
		_autocomplete := this._autocomplete, _listBox := _autocomplete.ListBox
		if (_wParam = 0) {
			_w := _width - _listBox._lastWidth
			GuiControl, Move, % _autocomplete.HWND, % "w" . _w
			GuiControl, Move, % _autocomplete._hEditLowerCornerHandle, % "x" . _w - 22 + 10
			GuiControl, Move, % _hostWindow.HWND, % "w" . _w
			GuiControl, Move, % _listBox._compartment, % "h" . _heigth
			GuiControl, Move, % _listBox.HWND, % "h" . _heigth
			try GUI % _listBox._parent . ":Show", % "NA AutoSize h" . _heigth
		}
		SetControlDelay % _controlDelay
	}
	_onSize(_w, _h) {
		local
		_autocomplete := this._autocomplete, _listBox := _autocomplete.ListBox
		_controlDelay := A_ControlDelay
		SetControlDelay, 2
		if (_listBox._visible)
			_listBox._dismiss()
		GuiControl, Move, % _autocomplete.HWND, % "w" . _w
		GuiControl, Move, % _autocomplete._hEditLowerCornerHandle, % "x" . _w - 22
		GuiControl, Move, % _listBox._compartment, x0 h0
		if (this._hostWindow.isVisible())
			this._hostWindow.show("NA AutoSize")
		SetControlDelay % _controlDelay
	; return 0
	}
	_autocompleteOnResize(_autocomplete, _parent, _w, _h, _mousex, _mousey) {
		local
		_controlDelay := A_ControlDelay
		SetControlDelay, 2
		_listBox := _autocomplete.ListBox
		if (_listBox._visible)
			_listBox._dismiss()
		GuiControl, Move, % this.HWND, % "y" . _h + 10 . " w" . _w
		_clientHeight := this._docRef.documentElement.clientHeight
		_h += this._docRef.documentElement.clientHeight
		GuiControl, Move, % _listBox._compartment, % "x" . _w . " h" . _h
		GuiControl, Move, % _listBox.HWND, % "h" . _h
		if (this._hostWindow.isVisible()) ; ++++
			this._hostWindow.show("NA AutoSize")
		SetControlDelay % _controlDelay
	return 0
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	dispose() {
		this.onshowHide(), this.onSubmit()
		this._autocomplete.dispose()
		base.dispose()
		this._hostWindow.destroy()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}

	defineLayout(_name, _pathOrContent, _defaultObjectWrapper:="", _defaultCallback:="", _validate_:=true) {
		if not (StrLen(_name)) {
			throw Exception("Invalid layout name.", -1)
		; return
		}
		this._defineLayout(_name, _pathOrContent, _defaultObjectWrapper, _defaultCallback, _validate_)
	}
	_defineLayout(_name, _pathOrContent, _defaultObjectWrapper:="", _defaultCallback:="", _validate_:=true) {
		local _inst, _exception, _classPath, _className, _obj, _fileObject, _objDescription
		if (SubStr(_pathOrContent, 1, 1) <> "[") {
			try _fileObject:=FileOpen(_pathOrContent, 4+8+0, "UTF-8")
			catch {
				throw Exception("Failed attempt to open the file.", -1)
			; return
			}
			_objDescription := _fileObject.read(), _fileObject.close()
		} else _objDescription := _pathOrContent
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
		((_defaultObjectWrapper = "") && _defaultObjectWrapper:=_obj._BasicOperations)
		((_defaultCallback = "") && _defaultCallback:="call")
		try _inst := new _obj.Keymap(_name, _objDescription, _defaultObjectWrapper,  _defaultCallback, _validate_) ; +++++++
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		; return
		}
		_obj._keymaps[_name] := _inst._map
	} ; ++++++++++

	#Include %A_LineFile%\..\Keypad._HostWindowWrapper.ahk
	#Include %A_LineFile%\..\Keypad._xAutocomplete.ahk
	#Include %A_LineFile%\..\Keypad._BasicOperations.ahk

}
#Include %A_LineFile%\..\Hotkey\Hotkey.ahk
