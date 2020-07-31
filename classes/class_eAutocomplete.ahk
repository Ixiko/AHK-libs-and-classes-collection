#Include %A_LineFile%/../acc.ahk
Class eAutocomplete {
	Class _Proxy extends eAutocomplete._Functor {
		static instances := {}
		call(_k, _params*) {
			local
			global eAutocomplete
			if not (eAutocomplete._Proxy.instances.hasKey(_k)) {
				eAutocomplete._Proxy.instances[_k] := {}
			} else if not (_params.length()) {
				return "", eAutocomplete._Proxy.instances.delete(_k)
			}
			_subClass := eAutocomplete[ SubStr(this.__class, InStr(this.__class, ".",, 0) + 1) ]
			_inst := new _subClass(_k, _params*)
		return _inst, eAutocomplete._Proxy.instances[_k].push(_inst)
		}
	}
	Class _Functor { ; https://autohotkey.com/boards/viewtopic.php?f=7&t=38151
		__Call(_newEnum, _k, _params*) {
			if (_k <> "")
				return this.call(_k, _params*)
		}
	}
		Class _EventObject extends eAutocomplete._Proxy {
			__New(_source, _eventName, _callback) {
				this.source := _source, this.eventName := _eventName
				if (_callback = "") {
					this.unregister()
				} if (IsFunc(_callback)) {
					((_callback.minParams = "") && _callback:=Func(_callback))
					_source[_eventName] := _callback
				} else if (IsObject(_callback)) {
					_source[_eventName] := _callback
				}
			}
			unregister() {
				this.source[ this.eventName ] := ""
			}
			__Delete() {
				this.unregister()
			}
		}
		Class _Hotkey extends eAutocomplete._Proxy {
			__New(_hkIfFn, _keyName, _fn) {
				this.ifFn := _hkIfFn, this.keyName := _keyName
				Hotkey, If, % _hkIfFn
					Hotkey % _keyName, % _fn, On T1 I0 B0
				Hotkey, If
			}
			unregister() {
				local
				static _f := Func("WinActive")
				_hkIfFn := this.ifFn
				Hotkey, If, % _hkIfFn
					Hotkey % this.keyName, % _f, Off
				Hotkey, If
			}
			__Delete() {
				this.unregister()
			}
		}
		Class _Iterator extends eAutocomplete._Proxy {
			__New(_ID, _fn) {
				this.callableObject := _fn
			}
			setPeriod(_period) {
				local
				if (_fn:=this.callableObject)
					SetTimer, % _fn, % _period
			}
			unregister() {
				local
				if not (_f:=this.callableObject)
					return
				SetTimer, % _f, Off
				SetTimer, % _f, Delete
				this.callableObject := ""
			}
			__Delete() {
			this.unregister()
			}
		}

	Class _Resource {
		static table := []
		path := ""
		subsections := {}
		hapaxLegomena := {}
		_set(_sourceName, _fileFullPath:="", _resource:="") {
			local
			global eAutocomplete
			if not (StrLen(_sourceName)) {
				throw Exception("Invalid source name.")
			return
			}
			if (_fileFullPath <> "") {
				if not (FileExist(_fileFullPath)) {
					throw Exception("The resource could not be found.")
				return
				}
				try _fileObject:=FileOpen(_fileFullPath, 4+8+0, "UTF-8")
				catch {
					throw Exception("Failed attempt to open the file.")
				return
				}
				_resource := _fileObject.read(), _fileObject.close()
			}
			_source := new eAutocomplete._Resource(_sourceName)
			_source.path := _fileFullPath
			_resource .= "`n"
			_batchLines := A_BatchLines
			SetBatchLines, -1
			Sort, _resource, D`n U
			ErrorLevel := 0
			_resource := "`n" . LTrim(_resource, "`n")
			_listLines := A_ListLines
			ListLines, Off
			while ((_letter:=SubStr(_resource, 2, 1)) <> "") {
				_position := RegExMatch(_resource, "Psi)\n\Q" . _letter . "\E[^\n]+(?:.*\n\Q" . _letter . "\E.+?(?=\n))?", _length) + _length
				if _letter is not space
					_source.subsections[_letter] := SubStr(_resource, 1, _position)
				_resource := SubStr(_resource, _position)
			}
			ListLines % _listLines ? "On" : "Off"
			SetBatchLines % _batchLines
		}
		__New(_sourceName) {
			static _ := new eAutocomplete._Resource("Default")
			this.name := _sourceName
		return eAutocomplete._Resource.table[_sourceName] := this
		}
		appendValue(_value) {
			local
			_subsections := this.subsections, _letter := SubStr(_value, 1, 1)
			(_subsections.hasKey(_letter) || _subsections[_letter]:="`n")
			_subsection := _subsections[_letter] . _value . "`n"
			Sort, _subsection, D`n U
			ErrorLevel := 0
			_subsections[_letter] := "`n" . LTrim(_subsection, "`n")
		}
		update() {
			local
			if (this.path <> "") {
				try _fileObject:=FileOpen(this.path, 4+1, "UTF-8")
				catch
					return
				for _letter, _subsection in this.subsections {
					_fileObject.write(_subsection)
				}
				_fileObject.close()
			}
		}
	}
	Class _pendingWordMatchObjectWrapper {
		match := {value: "", pos: 0, len: 0}
		isComplete := {value: "", pos: 0, len: 0}
	}
	Class _ListBox {
		static _properties :=
		(LTrim Join C
			{
				AHKID: "",
				bkColor: "FFFFFF",
				fontColor: "000000",
				fontName: "Segoe UI",
				fontSize: "13",
				HWND: "",
				maxSuggestions: 7,
				tabStops: 512,
				transparency: 235
			}
		)
		static _COUNTUPPERTHRESHOLD := 52
		_lastWidth := 0
		_itemHeight := 0
		_list := ""
		_itemCount := 0
		_visible := false
		_onSelection := ""
		__New(_GUIID, _hHostControl) {
			local
			global eAutocomplete
			this._overallWidthAlloc := DllCall("User32.dll\GetSystemMetrics", "UInt", 78)
			eAutocomplete._setOptions(this, "_properties",, true)
			_GUI := A_DefaultGUI
			GUI, New, % "+Owner" . (this._owner:=_GUIID) . " +hwnd_parent +ToolWindow -Caption +Delimiter`n"
			this._host := _hHostControl, this._parent := _parent
			GUI, Margin, 0, 0
			GUI, Add, ListBox, % "x0 y0 -HScroll +VScroll hwnd_hListBox t" . eAutocomplete._ListBox._properties.tabStops,
			this._AHKID := "ahk_id " . (this._HWND:=_hListBox)
			GUI, %_GUI%:Default
			this.fontName := eAutocomplete._ListBox._properties.fontName
			this._selection := new eAutocomplete._ListBox._SelectionWrapper(this._HWND)
		}
		__Set(_k, _v) {
			local
			global eAutocomplete
			if (eAutocomplete._Listbox._properties.hasKey(_k))
			{
				if ((_updateFont:=((_k = "fontName") || (_k = "fontSize"))) || (_k = "fontColor")) {
					this["_" . _k] := _v
					try GUI % this._parent . ":Font", % Format("c{1} s{2}", this._fontColor, this._fontSize), % this._fontName
					GuiControl, Font, % this._HWND
					if (_updateFont) {
						if (this._hFont) {
							DllCall("SelectObject", "UPtr", this._hDC, "UPtr", this._hFont, "UPtr")
							DllCall("ReleaseDC", "UPtr", this._HWND, "UPtr", this._hDC)
						}
						this._hDC := DllCall("GetDC", "UPtr", this._HWND, "UPtr")
						SendMessage, 0x31, 0, 0,, % this._AHKID
						this._hFont := DllCall("SelectObject", "UPtr", this._hDC, "UPtr", ErrorLevel, "UPtr")
						SendMessage, 0x1A1, 0, 0,, % this._AHKID
						this._itemHeight := ErrorLevel
						this._autoWH(this._list)
					}
				return this["_" . _k]
				}
				else if (_k = "maxSuggestions") {
					if ((1 <= _v) && (_v <= eAutocomplete._ListBox._COUNTUPPERTHRESHOLD))
						return this._maxSuggestions:=Floor(_v), this._autoWH(this._list)
					else return this._maxSuggestions
				}
				else if (_k = "transparency") {
					if _v between 10 and 255 ; +++
					{
						this._transparency := _v
						(this._visible && this._show())
					}
				return this._transparency
				}
				else if (_k = "bkColor") {
					try GUI % this._parent . ":Color",, % this._bkColor:=_v
				return this._bkColor
				}
				else if (_k = "tabStops") {
					if not (mod(_v, 8))
						GuiControl, % "+t" . this["_" . _k]:=_v, % this._HWND
				return this["_" . _k]
				}
				else if ((_k = "AHKID") || (_k = "HWND"))
					return this["_" . _k]
			}
		}
		__Get(_k, _params*) {
			local
			global eAutocomplete
			if (eAutocomplete._Listbox._properties.hasKey(_k))
				return this["_" . _k]
		}
		setOptions(_opt) {
			local
			global eAutocomplete
			eAutocomplete._setOptions(this, "_properties", _opt)
		}
		_setData(_list) {
			local
			global eAutocomplete
			_count := 0
			_list := Trim(_list, "`n")
			if (_list <> "") {
				StrReplace(_list, "`n",, _count)
				_upperThreshold := eAutocomplete._ListBox._COUNTUPPERTHRESHOLD
				if (++_count > _upperThreshold) {
					_count := _upperThreshold, _list := SubStr(_list, 1, InStr(_list, "`n",,, ++_upperThreshold) - 1)
				}
			}
			this._itemCount := _count
			GuiControl,, % this._HWND, % "`n" . this._list:=_list
			this._autoWH(_list)
			this._selection := new eAutocomplete._ListBox._SelectionWrapper(this._HWND)
		}
		_hasHScrollBar {
			get {
			return !(this._itemCount <= this._maxSuggestions)
			}
		}
		_getHeight() {
			local
			_rows := (this._hasHScrollBar) ? this._maxSuggestions : this._itemCount
		return (_rows + 1) * this._itemHeight
		}

		Class _SelectionWrapper {
			_index := 0
			_text := ""
			__New(_parent) {
			this._parent := _parent
			}
			index {
				set {
					GuiControl, Choose, % this._parent, % this._index:=value
				return value
				}
				get {
				return this._index
				}
			}
			text {
				get {
					local
					ControlGet, _item, Choice,,, % "ahk_id " . this._parent
				return this._text:=Trim(_item, "`r`n") ; ~ ++++
				}
				set {
				return this.text
				}
			}
			offsetTop {
				get {
					SendMessage, 0x018E, 0, 0,, % "ahk_id " . this._parent
					return this._offsetTop := this._index - ErrorLevel
				}
				set {
				return this.offsetTop
				}
			}
		}
		_getCurrentItemData(_dataMaxIndex:=3) {
			local
			_tsv:=[]
			_tsv.setCapacity(_dataMaxIndex)
			for _index, _element in StrSplit(this._selection.text, A_Tab, A_Tab . A_Space, _dataMaxIndex)
				_tsv[_index] := _element
		return _tsv
		}
		__select(_hwnd:="", _event:="") {
			local
			_selection := this._selection, _index := _selection._index
			if (_event = "CustomDown") {
				((++_index > this._itemCount) && _index:=1)
				_selection.index := _index, ((_fn:=this._onSelection) && _fn.call(_selection, false, true))
			} else if (_event = "CustomUp") {
				((--_index < 1) && _index:=this._itemCount)
				_selection.index := _index, ((_fn:=this._onSelection) && _fn.call(_selection, false, true))
			} else if (_event = "Normal") {
				SendMessage, 0x188, 0, 0,, % "ahk_id " . _hwnd
				_pos := (ErrorLevel << 32 >> 32) + 1
				_selectionHasChanged := (_index <> _pos)
				_selection.index := _pos, ((_fn:=this._onSelection) && _fn.call(_selection, true, _selectionHasChanged))
			}
		}
		_selectUp() {
			this.__select(, "CustomUp")
		}
		_selectDown() {
			this.__select(, "CustomDown")
		}
		_show(_boolean:=true) {
			local
			_hLastFoundWindow := WinExist()
			try GUI % this._parent ":+LastFound"
			WinSet, Transparent, % (this._visible:=_boolean) ? this._transparency : 0
			WinSet, Redraw
			WinExist("ahk_id " . _hLastFoundWindow)
		}
		_showDropDown() {
			this._autoXY(), this._show()
		}
		_hideDropDown() {
			this._show(false)
		}
		_dismiss() {
			this._setData(""), this._hideDropDown()
		}
		_dispose() {
			local
			global eAutocomplete
			try GUI % this._parent . ":-Parent"
			GuiControl -g, % this._HWND
			eAutocomplete._EventObject(this)
		}
		__Delete() {
			; MsgBox % A_ThisFunc
			try GUI % this._parent . ":Destroy"
			DllCall("SelectObject", "UPtr", this._hDC, "UPtr", this._hFont, "UPtr")
			DllCall("ReleaseDC", "UPtr", this._HWND, "UPtr", this._hDC)
		}
	}
	Class _DropDownList extends eAutocomplete._ListBox {
		__New(_GUIID, _hHostControl) {
			base.__New(_GUIID, _hHostControl)
			GUI % this._parent . ":+E0x20"
		}
		_getWidth(_list) {
			static SM_CXVSCROLL := DllCall("GetSystemMetrics", "UInt", 2)
			local
			_size := "", _w := 0
			_listLines := A_ListLines
			ListLines, Off
			Loop, Parse, % _list, `n
			{
				_substr := SubStr(A_LoopField, 1, ((_l:=InStr(A_LoopField, A_Tab) - 1) > 0) ? _l : _l:=StrLen(A_LoopField))
				DllCall("GetTextExtentPoint32", "UPtr", this._hDC, "Str", _substr, "Int", _l, "Int64P", _size)
				_size &= 0xFFFFFFFF
				((_size > _w) && _w:=_size)
			}
			ListLines % _listLines ? "On" : "Off"
		return _w, (_w && _w += 10 + this._hasHScrollBar * SM_CXVSCROLL)
		}
		_autoWH(_params*) {
			local
			_w := this._lastWidth := this._getWidth(_params.1), _h := this._getHeight()
			GuiControl, Move, % this._HWND, % "w" . _w . " h" . _h
			GUI % this._parent . ":Show", % "NA AutoSize"
		}
		_autoXY() {
			local
			if (A_CaretX <> "") {
				VarSetCapacity(_POINT_, 8, 0)
				DllCall("User32.dll\GetCaretPos", "Ptr", &_POINT_)
				DllCall("User32.dll\MapWindowPoints", "Ptr", this._host, "Ptr", 0, "Ptr", &_POINT_, "UInt", 1)
				_x1 := NumGet(_POINT_, 0, "Int") + 5, _y := NumGet(_POINT_, 4, "Int") + 30
				_x2 := _x1 + this._lastWidth
				_x := (_x2 > this._overallWidthAlloc) ? this._overallWidthAlloc - this._lastWidth : _x1
				GUI % this._parent . ":Show", % "NA x" . _x . " y" . _y
			}
		}

	}
	Class _ComboBoxList extends eAutocomplete._ListBox {
		__New(_GUIID, _hHostControl) {
			local
			base.__New(_GUIID, _hHostControl)
			GUI % this._parent . ":+Parent" . this._owner
			_fn := this.__select.bind(this)
			GuiControl, +g, % this._HWND, % _fn
		}
		_getWidth() {
			local
			ControlGetPos,,, _w,,, % "ahk_id " . this._host
		return _w
		}
		_autoWH(_params*) {
			local
			_lastFoundWindow := WinExist()
			if not (WinExist("ahk_id " . this._host))
				return "", WinExist("ahk_id " . _lastFoundWindow)
			GuiControl, MoveDraw, % this._HWND, % "h" . (_h:=this._getHeight()) . " w" . (_w:=this._getWidth())
			GUI % this._parent . ":Show", % "NA AutoSize"
			WinExist("ahk_id " . _lastFoundWindow)
		}
		_autoXY() {
			local
			_lastFoundWindow := WinExist()
			if not (WinExist("ahk_id " . this._host))
				return "", WinExist("ahk_id " . _lastFoundWindow)
			VarSetCapacity(_RECT_, 16, 0) ; https://autohotkey.com/boards/viewtopic.php?f=6&t=38472 - convert coordinates between Client/Screen/Window modes
			DllCall("User32.dll\GetWindowRect", "Ptr", this._host, "Ptr", &_RECT_)
			DllCall("User32.dll\MapWindowPoints", "Ptr", 0, "Ptr", this._owner, "Ptr", &_RECT_, "UInt", 2)
			_x := NumGet(&_RECT_, 0, "Int"), _h := NumGet(&_RECT_, 12, "Int")
			GUI % this._parent . ":Show", % "NA x" . _x . " y" . _h
			WinExist("ahk_id " . _lastFoundWindow)
		}
	}


	static _instances := {}
	static _properties :=
	(LTrim Join C
		{
			AHKID: "",
			autoSuggest: true,
			collectAt: 4,
			collectWords: true,
			disabled: false,
			endKeys: "?!,;.:(){}[\]'""<>\\@=/|",
			expandWithSpace: true,
			HWND: "",
			learnWords: false,
			listbox: "",
			minWordLength: 4,
			onSearch: "", ; +++
			onCompletion: "",
			onReplacement: "",
			onResize: "",
			onSuggestionLookUp: "",
			source: "",
			suggestAt: 2
		}
	)
	__Set(_k, _v) {
		local
		global eAutocomplete
		if (eAutocomplete._properties.hasKey(_k))
		{
			if ((_k = "AHKID") || (_k = "HWND") || (_k = "listbox"))
				return this["_" . _k]
			else if ((_k = "autoSuggest") || (_k = "collectWords") || (_k = "expandWithSpace") || (_k = "learnWords"))
				return this["_" . _k] := !!_v
			else if (_k = "source") {
				if ((_v <> this._source.name) && eAutocomplete._Resource.table.hasKey(_v)) {
					_isDisabled := this._disabled
					this.disabled := true
					(this._learnWords && this._source.update())
				return this._source:=eAutocomplete._Resource.table[_v], this._disabled := _isDisabled
				}
			return this._source.name
			}
			else if (_k = "disabled") {
				((!!_v <> this._disabled) && (this._disabled:=!!_v) && this._listbox._dismiss())
			return this._disabled
			}
			else if ((_k = "onCompletion") || (_k = "onResize"))
				return _v, eAutocomplete._EventObject(this, "_" . _k, _v)
			else if ((_k = "onReplacement") || (_k = "onSuggestionLookUp") || (_k = "onSearch")) { ; +++
				((_v <> "") || _v:=this["__" . _k].bind(this))
			return _v, eAutocomplete._EventObject(this, "_" . _k, _v)
			}
			else if ((_k = "collectAt") || (_k = "minWordLength") || (_k = "suggestAt"))
				return (not ((_v:=Floor(_v)) > 0)) ? this["_" . _k] : this["_" . _k]:=_v
			else if (_k = "endKeys") {
				_lastEndKeys := "", _endKeys := ""
				Loop, parse, % RegExReplace(_v, "\s")
				{
					if (InStr(_lastEndKeys, A_LoopField))
						continue
					_lastEndKeys .= A_LoopField
					if A_LoopField in ^,-,],\
						_endKeys .= "\" . A_LoopField
					else _endKeys .= A_LoopField
				}
				return this["_endKeys"] := _endKeys
			}
		}
	}
	__Get(_k, _params*) {
		local
		global eAutocomplete
		if (eAutocomplete._properties.hasKey(_k))
			return this["_" . _k]
	}
	setOptions(_opt) {
		local
		global eAutocomplete
		eAutocomplete._setOptions(this, "_properties", _opt)
	}
	dispose() {
		local
		global eAutocomplete
		if not (eAutocomplete._instances.hasKey(this._HWND))
			return
		this.disabled := true, eAutocomplete._instances.delete(this._HWND)
		for _each, _instance in eAutocomplete._instances, _noMoreFromProcess := true {
			if (_instance._idProcess = this._idProcess) {
				_noMoreFromProcess := false
			break
			}
		}
		(_noMoreFromProcess && eAutocomplete._Value.unregisterProc(this._idProcess))
		eAutocomplete._Hotkey(this._hkIfFn)
		eAutocomplete._EventObject(this)
		eAutocomplete._Iterator(this._HWND)
		(this._learnWords && this._source.update())
		if (this.hasKey("_hEditLowerCornerHandle"))
			GuiControl, -g, % this._hEditLowerCornerHandle
		this._listbox._dispose()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}

	create(_GUIID, _editOptions:="", _opt:="") {
		local _hLastFoundWindow, _hEdit, _plusResize, _isComboBox, _classPath, _className, _obj, _inst
			, _pos, _posx, _posy, _posw, _posh, _hEditLowerCornerHandle, _fn
		_hLastFoundWindow := WinExist()
		try {
			Gui % _GUIID . ":+LastFoundExist"
			IfWinNotExist
			{
				throw Exception("Invalid GUI window.", -1, _GUIID)
			return
			} ; +++
		} finally WinExist("ahk_id " . _hLastFoundWindow)
		GUI, % _GUIID . ":Add", Edit, % _editOptions . " hwnd_hEdit",
		_plusResize := ((_editOptions <> "") && (_editOptions ~= "i)(^|\s)\K\+?[^-]?Resize(?=\s|$)"))
		_isComboBox := (!_plusResize && !(DllCall("GetWindowLong", "UInt", _hEdit, "Int", -16) & 0x4))
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1) ; +++
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className% ; +++
		_inst := new _obj(_GUIID, _hEdit, _isComboBox, _opt) ; +++
		if (_plusResize) {
			GuiControlGet, _pos, Pos, % _hEdit
			GUI, % _GUIID . ":Add", Text, % "0x12 w11 h11 " . Format("x{1} y{2}", _posx + _posw - 7, _posy + _posh - 7) . " hwnd_hEditLowerCornerHandle",
			_inst._hEditLowerCornerHandle := _hEditLowerCornerHandle, _fn := _inst.__resize.bind(_inst)
			GuiControl +g, % _hEditLowerCornerHandle, % _fn
		}
	return _inst
	}
	attach(_hHostControl, _opt:="") {
		local _detectHiddenWindows, _class, _GUIID, _style, _isComboBox, _classPath, _className, _obj, _inst, _hLastFoundWindow
		_detectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGetClass, _class, % "ahk_id " . _hHostControl
		DetectHiddenWindows % _detectHiddenWindows
		if not ((_class = "Edit") || (_class = "RICHEDIT50W")) {
			throw Exception("The host control either does not exist or is not a representative of the class Edit/RICHEDIT50W.", -1, _class)
		return
		}
		_GUIID := DllCall("User32.dll\GetAncestor", "Ptr", _hHostControl, "UInt", 2, "Ptr")
		ControlGet, _style, Style,,, % "ahk_id " . _hHostControl
		_isComboBox := not (_style & 0x4) ; ES_MULTILINE
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1) ; +++
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className% ; +++
		_inst := new _obj(_GUIID, _hHostControl, _isComboBox, _opt) ; +++
		_hLastFoundWindow := WinExist()
		if (WinActive("ahk_id " . _GUIID))
			eAutocomplete._Value.__sourceChanged(0x8005, _hHostControl, 0, 0, 0, 0) ; ++++
		WinExist("ahk_id " . _hLastFoundWindow)
	return _inst
	}
	setSourceFromVar(_sourceName, _list:="") {
		local
		global eAutocomplete
		try eAutocomplete._Resource._set(_sourceName, "", _list)
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		} ; +++
	}
	setSourceFromFile(_sourceName, _fileFullPath) {
		local
		global eAutocomplete
		try eAutocomplete._Resource._set(_sourceName, _fileFullPath)
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		} ; +++
	}
	; <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	_hEditLowerCornerHandle := ""
	_minSize := {"w": 51, "h": 21}
	_maxSize := {"w": A_ScreenWidth, "h": A_ScreenHeight}
	_content := ""
	_pendingWord := ""
	_ready := true
	_completionData := ""
	__New(_GUIID, _hHostControl, _isComboBox, _opt:="") {
		local _idProcess, _classPath, _className, _obj, _listBox, _clone, _listBoxOptions, _hkIfFn
		eAutocomplete._setOptions(this, "_properties",, true)
		_idProcess := "", DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", _GUIID, "UIntP", _idProcess, "UInt")
		if not (_idProcess) {
			throw Exception("Could not retrieve the identifier of the process that created the host window.", -2) ; +++
		return
		}
		this._idProcess := _idProcess, this._parent := _GUIID, this._AHKID := "ahk_id " . (this._HWND:=_hHostControl)
		_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1) ; +++
		_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className% ; +++
		_listBox := (this._isComboBox:=_isComboBox) ? _obj._ComboBoxList : _obj._DropDownList ; +++
		_listbox := this._listbox := new _listBox(_GUIID, _hHostControl)

		this._source := eAutocomplete._Resource.table["Default"]
		this.onSuggestionLookUp := "", this.onReplacement := "", this.onSearch := "" ; +++
		if (IsObject(_opt)) {
			_clone := ObjClone(_opt) ; +++
			if (_listBoxOptions:=_clone.remove("listbox"))
				_listBox.setOptions(_listBoxOptions)
			this.setOptions(_clone)
		}

		eAutocomplete._Iterator(this._HWND, ObjBindMethod(this, "__valueChanged")) ; +++
		_obj._Value.registerProc(this._idProcess) ; +++

		eAutocomplete._EventObject(this._listbox, "_onSelection", ObjBindMethod(this, "_listboxSelectionEventMonitor"))

		_hkIfFn := this._hkIfFn := this._hotkeyPressHandler.bind("", _hHostControl)
		eAutocomplete._Hotkey(_hkIfFn, "Escape", ObjBindMethod(this._listbox, "_dismiss"))
		eAutocomplete._Hotkey(_hkIfFn, "Up", ObjBindMethod(_listbox, "_selectUp"))
		eAutocomplete._Hotkey(_hkIfFn, "Down", ObjBindMethod(_listbox, "_selectDown"))
		eAutocomplete._Hotkey(_hkIfFn, "Left", Func("WinActive"))
		eAutocomplete._Hotkey(_hkIfFn, "Right", ObjBindMethod(this, "_completionDataLookUp", 1))
		eAutocomplete._Hotkey(_hkIfFn, "+Right", ObjBindMethod(this, "_completionDataLookUp", 2))
		eAutocomplete._Hotkey(_hkIfFn, "Tab", ObjBindMethod(this, "_complete", false, 1))
		eAutocomplete._Hotkey(_hkIfFn, "+Tab", ObjBindMethod(this, "_complete", false, 2))
		eAutocomplete._Hotkey(_hkIfFn, "Enter", ObjBindMethod(this, "_complete", true, 1))
		eAutocomplete._Hotkey(_hkIfFn, "+Enter", ObjBindMethod(this, "_complete", true, 2))

	return eAutocomplete._instances[_hHostControl] := this
	}
	__valueChanged() {
		local
		this._ready := false
		_count := this._hasSuggestions
		if (_count > 0) {
			(this._autoSuggest && this._suggest())
		} else if (_count = -1) {
			_match := this._pendingWord.match.value
			if (_match <> this._listbox._getCurrentItemData().1)
				this.__hapax(_match, this._pendingWord.match.len)
			this._listbox._hideDropDown()
		} else { ; 0
			this._listbox._hideDropDown()
		}
		this._ready := true
	}
	__hapax(_match, _len) {
		local
		if (!this._collectWords || (_len < this._minWordLength))
			return
		_hapaxLegomena := this._source.hapaxLegomena
		(_hapaxLegomena.hasKey(_match) || _hapaxLegomena[_match]:=0)
		if not (++_hapaxLegomena[_match] = this.collectAt)
			return
		this._source.appendValue(_match)
	}
	_capturePendingWord() {
		local
		global eAutocomplete
		_wrapper := new eAutocomplete._pendingWordMatchObjectWrapper
		_content := this._content, _caretPos := this._getSelection()
		_caretIsWellPositioned := (StrLen(RegExReplace(SubStr(_content, _caretPos, 2), "\s$")) <= 1)
		if not (_caretIsWellPositioned)
			return _wrapper
		_match := "?P<match>[^\s" . this._endKeys . "]{" . this._suggestAt . ",}"
		_isComplete := "?P<isComplete>[\s" . this._endKeys . "]?"
		RegExMatch(SubStr(_content, 1, _caretPos), "`aOi)(" . _match . ")(" . _isComplete . ")$", _pendingWord)
		for _subPatternName, _subPatternObject in _wrapper
			for _property in _subPatternObject, _o := _wrapper[_subPatternName]
				_o[_property] := _pendingWord[_property](_subPatternName)
		return _wrapper
	}
	_hasSuggestions {
		get {
			local
			_pendingWord := this._pendingWord := this._capturePendingWord()
			if not (this._pendingWord.match.len)
				return 0
			else if (_pendingWord.isComplete.len)
				return -1
			_list := ""
			_substring := _pendingWord.match.value
			this._onSearch.call(this, this._source.subsections[ SubStr(_substring, 1, 1) ], _substring, _list)
			this._listbox._setData(_list)
		return this._listbox._itemCount
		}
	} ; +++
	__onSearch(_inst, _subsection, _substring, ByRef _list:="") {
		local
		if (_subsection <> "") {
			if not (RegExMatch(_subsection, "`nsi)\n\Q" . _substring . "\E[^\n]+(?:.*\n\Q" . _substring . "\E.+?(?=\n))?", _list)) {
				this._score(_subsection, _substring, _list)
			} else _list := RTrim(_list, "`r") ; +++
		}
	} ; +++
		_score(_subsection, _word, ByRef _sortedMatches:="") { ; adapted from Score by Uberi
			local
			_listLines := A_ListLines
			ListLines, Off
			Loop, Parse, % _subsection, "`r`n"
			{
				_score := 100
				_len := StrLen(_word)
				; determine prefixing
				_pos := 1
				while % (_pos <= _len && SubStr(_word,_pos,1) = SubStr(A_LoopField,_pos,1))
					_pos ++
				_score *= _pos ** 8
				; determine number of superfluous characters
				; \Q...\E
				_remaining := "", RegExMatch(A_LoopField, "imS)^" . SubStr(RegExReplace(_word, "S).", "$0.*"), 1, -2), _remaining) ; +++
				_score *= (1 + StrLen(_remaining) - _len) ** -1.5
				_score *= StrLen(_word) ** 0.4

				(_score && _sortedMatches .= _score . "`t" . A_LoopField . "`r`n")
			}
			ListLines % _listLines ? "On" : "Off"
			_sortedMatches := SubStr(_sortedMatches, 1, -2)
			Sort, _sortedMatches, N R ; rank results numerically descending by score
			_sortedMatches := RegExReplace(_sortedMatches,"`nmS)^[^`t]+`t") ; remove scores

		} ; https://github.com/Uberi/Autocomplete/blob/master/Autocomplete.ahk

	_suggest() {
		this._listbox._showDropDown(), this._listbox._selectDown()
	}
	_listboxSelectionEventMonitor(_selection, _clickEvent, _selectionHasChanged) {
		(_selectionHasChanged && this._completionData:=""), (_clickEvent && this._complete(false))
	}
	_completionDataLookUp(_tabIndex) {
		local
		static _keys := {}
		if not (_keys.hasKey(A_ThisHotkey)) {
			RegExMatch(A_ThisHotkey, "i)(\w+|.)(?:[ `t]Up)?$", _match), _keys[ A_ThisHotkey ] := _match
		}
		_listbox := this._listbox
		(!this._completionData && this._completionData:=_listbox._getCurrentItemData())
		_coordModeToolTip := A_CoordModeToolTip
		CoordMode, ToolTip, Screen
			WinGetPos, _x, _y,,, % _listBox.AHKID
			_x += 10
			_y := _y + (_listbox._selection.offsetTop - 0.5) * _listbox._itemHeight
			ToolTip % this._onSuggestionLookUp.call(this._completionData.1, _tabIndex), % _x, % _y
			KeyWait % _keys[ A_ThisHotkey ]
			ToolTip
		CoordMode, ToolTip, % _coordModeToolTip
	}
	__onSuggestionLookUp(_value, _tabIndex) {
		local
		_infoTipText := this._completionData[ _tabIndex + 1 ]
	return StrReplace(StrReplace(_infoTipText, "``n", "`n"), "``r", "`r")
	}
	_complete(_goToNewLine, _tabIndex:=1) {
		local
		global eAutocomplete
		static _keys := {}
		if (_isReplacement:=A_ThisHotkey <> "") {
			if not (_keys.hasKey(A_ThisHotkey)) {
				RegExMatch(A_ThisHotkey, "i)(\w+|.)(?:[ `t]Up)?$", _match), _keys[ A_ThisHotkey ] := _match
			}
			KeyWait % _keys[ A_ThisHotkey ], T0.6
			(not (_isReplacement:=ErrorLevel)) ? this._expand() : this._replace(_tabIndex)
			KeyWait % _keys[ A_ThisHotkey ]
		} else this._expand()
		this._listbox._dismiss()
		if (_goToNewLine) {
			eAutocomplete._Value._rawSend("{Enter}", this._HWND)
		} else (this._expandWithSpace && eAutocomplete._Value._rawSend("{Space}", this._HWND))
		((_fn:=this._onCompletion) && _fn.call(this, this._completionData[ 1 + _isReplacement * _tabIndex ], _isReplacement))
	}
	_expand() {
		local
		global eAutocomplete
		(!this._completionData && this._completionData:=this._listbox._getCurrentItemData())
		eAutocomplete._Value._rawSend("{BS " . StrLen(this._pendingWord.match.value) . "}", this._HWND)
		eAutocomplete._Value._rawPaste(this._completionData.1, this._HWND)
	} ; +++
	_replace(_tabIndex) {
		local
		global eAutocomplete
		(!this._completionData && this._completionData:=this._listbox._getCurrentItemData())
		eAutocomplete._Value._rawSend("{BS " . StrLen(this._pendingWord.match.value) . "}", this._HWND)
		_value := this._completionData[ _tabIndex + 1 ] := this._onReplacement.call(this._completionData.1, _tabIndex)
		eAutocomplete._Value._rawPaste(_value, this._HWND)
	}
	__onReplacement(_value, _tabIndex) {
		return this._completionData[ _tabIndex + 1 ]
	}
	; --------------------------------------------------------------------------------------------------------------------------------
	_getSelection(ByRef _startSel:="", ByRef _endSel:="") {
		local
		static EM_GETSEL := 0xB0
		VarSetCapacity(_startPos, 4, 0), VarSetCapacity(_endPos, 4, 0)
		SendMessage, % EM_GETSEL, &_startPos, &_endPos,, % this._AHKID
		_startSel := NumGet(_startPos), _endSel := NumGet(_endPos)
	return _endSel
	}
	; --------------------------------------------------------------------------------------------------------------------------------
	__resize(_hEditLowerCornerHandle) {
		local
		_listLines := A_ListLines
		ListLines, Off
		_coordModeMouse := A_CoordModeMouse
		CoordMode, Mouse, Client
		GuiControlGet, _start, Pos, % _hEdit:=this._HWND
		_minSz := this._minSize, _maxSz := this._maxSize
		while (GetKeyState("LButton", "P")) {
			MouseGetPos, _x, _y
			_w := _x - _startX, _h := _y - _startY
			if (_w <= _minSz.w)
				_w := _minSz.w
			else if (_w >= _maxSz.w)
				_w := _maxSz.w
			if (_h <= _minSz.h)
				_h := _minSz.h
			else if (_h >= _maxSz.h)
				_h := _maxSz.h
			if (this._onResize && this._onResize.call(this, A_GUI, _w, _h, _x, _y)) {
				CoordMode, Mouse, % _coordModeMouse
				ListLines % _listLines ? "On" : "Off"
			Exit
			} ;  +++
			GuiControl, Move, % _hEdit, % "w" . _w . " h" . _h
			GuiControlGet, _pos, Pos, % _hEdit
			GuiControl, MoveDraw, % _hEditLowerCornerHandle, % "x" . (_posx + _posw - 7) . " y" . _posy + _posh - 7
		sleep, 15
		}
		CoordMode, Mouse, % _coordModeMouse
		ListLines % _listLines ? "On" : "Off"
	}

	_setOptions(_obj, _prop, _opt:="", _initialize:=false) {
		local
		_properties := _obj[_prop]
		if (_initialize) {
			for _key, _defaultValue in _properties {
				ObjRawSet(_obj, "_" . _key, _defaultValue)
			}
		return
		}
		if (IsObject(_opt))
			for _key, _value in _opt
				(_properties.hasKey(_key) && _obj[_key]:=_value)
	} ; +++

	_hotkeyPressHandler(_hwnd, _thisHotkey) {
		local
		global eAutocomplete
		if (_hwnd <> eAutocomplete._Value.lastFoundControl)
			return false
		_inst := eAutocomplete._instances[_hwnd]
		if (_inst._disabled || !_inst._ready || !WinActive("ahk_id " . _inst._parent))
			return false
		_listbox := _inst._listbox
		if not (_listbox._visible) {
			if ((_thisHotkey = "Down") && _listbox._itemCount)
				return true, _inst._listbox._showDropDown()
			return false
		}
		return true
	}

	Class _Value {
		static processes := {}
		static lastFoundControl := 0x0
		static bypassToggle := false
		registerProc(_idProcess) {
			local
			global eAutocomplete
			if not (eAutocomplete._Value.processes.hasKey(_idProcess)) {
				eAutocomplete._Value.processes[_idProcess] := []
				_callback := RegisterCallback("eAutocomplete._Value.__valueChange")
				_hWinEventHook
				:= DllCall("User32.dll\SetWinEventHook","Uint",0x800E,"Uint",0x800E,"Ptr",0,"Ptr",_callback,"Uint",_idProcess,"Uint",0,"Uint",0)
				eAutocomplete._Value.processes[_idProcess].push(_hWinEventHook)
				_callback := RegisterCallback("eAutocomplete._Value.__sourceChanged")
				Loop, parse, % "0x000A,0x0015,0x8005", CSV
				{
				_hWinEventHook
				:= DllCall("User32.dll\SetWinEventHook","Uint",A_LoopField,"Uint",A_LoopField,"Ptr",0,"Ptr",_callback,"Uint",_idProcess,"Uint",0,"Uint",0)
				eAutocomplete._Value.processes[_idProcess].push(_hWinEventHook)
				}
			}
		}
		unregisterProc(_idProcess) {
			local
			global eAutocomplete
			for _each, _hWinEventHook in eAutocomplete._Value.processes[_idProcess]
				DllCall("User32.dll\UnhookWinEvent", "Ptr", _hWinEventHook)
			eAutocomplete._Value.processes.delete(_idProcess)
		}

		_rawSend(_keys, _hwnd) {
			local
			global eAutocomplete
			_state := eAutocomplete._Value.bypassToggle
			eAutocomplete._Value.bypassToggle := true
			_keyDelay := A_KeyDelay
			SetKeyDelay, 0
			ControlFocus,, % "ahk_id " . _hwnd ; ++++++
			SendInput, % _keys ; ++++++
			; ControlSend,, % _keys, % "ahk_id " . _hwnd
			sleep, 300 ; check messages of the internal message queue
			SetKeyDelay % _keyDelay
			eAutocomplete._Value.bypassToggle := _state
		}
		_rawPaste(_text, _hwnd) {
			local
			global eAutocomplete
			_state := eAutocomplete._Value.bypassToggle
			eAutocomplete._Value.bypassToggle := true
			Control, EditPaste, % StrReplace(StrReplace(_text, "``n", "`n"), "``r", "`r"),, % "ahk_id " . _hwnd
			sleep, 300 ; check messages of the internal message queue
			eAutocomplete._Value.bypassToggle := _state
		}
		; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
		__sourceChanged(_event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {
			local
			global eAutocomplete
			if ((_event = 0x8005) || (_event = 0x0015)) {
				ControlGetFocus, _focusedControl, A
				ControlGet, _hwnd, Hwnd,, % _focusedControl, A
				if (_hwnd = eAutocomplete._Value.lastFoundControl)
					return
			}
			; f(_hwnd)
			for _each, _instance in eAutocomplete._instances {
				if (_instance._listbox._visible) {
					_instance._listbox._hideDropDown()
				break
				}
			}
			eAutocomplete._Value.lastFoundControl := (eAutocomplete._instances.hasKey(_hwnd)) ? _hwnd : 0x0
		}
		__valueChange(_event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {
			local
			global eAutocomplete
			static OBJID_CLIENT := 0xFFFFFFFC
			if (_idObject <> OBJID_CLIENT)
				return
			if not (eAutocomplete._Value.bypassToggle) {
			; f(_hwnd)
				if (eAutocomplete._instances.hasKey(_hwnd)) {
					_inst := eAutocomplete._instances[_hwnd]
					Critical
					_acc := Acc_ObjectFromEvent(_idChild_, _hwnd, _idObject, _idChild)
					try _inst._content := _acc.accValue(0)
					if (!_inst._disabled) {
						eAutocomplete._Iterator.instances[_inst._HWND].1.setPeriod(-(3 + !_inst._ready) * 75)
					}
				}
			}
		}
	}
}
