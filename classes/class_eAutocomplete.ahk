;#Include %A_LineFile%/../acc.ahk
Class eAutocomplete {
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PRIVATE NESTED CLASSES ~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Class _Proxy extends eAutocomplete._Functor {

		static instances := {}

		call(_k, _params*) {
			if not (eAutocomplete._Proxy.instances.hasKey(_k)) {
				eAutocomplete._Proxy.instances[_k] := {}
			} else if not (_params.length()) {
				return "", eAutocomplete._Proxy.instances.delete(_k)
			}
			_subClass := eAutocomplete[ SubStr(this.__class, InStr(this.__class, ".",, 0) + 1) ]
			return _inst := new _subClass(_k, _params*), eAutocomplete._Proxy.instances[_k].push(_inst)
		}

	}
	Class _Functor { ; https://autohotkey.com/boards/viewtopic.php?f=7&t=38151
		__Call(_newEnum, _k, _params*) {
			if (_k <> "")
				return this.call(_k, _params*)
		}
	}
		; ====================================================================================
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
			__New(_hkIfFuncObject, _keyName, _func) {
				this.ifFuncObj := _hkIfFuncObject, this.keyName := _keyName
				Hotkey, If, % _hkIfFuncObject
					Hotkey % _keyName, % _func, On T1 I0 B0
				Hotkey, If
			}
			unregister() {
				static _f := Func("WinActive")
				_hkIfFuncObject := this.ifFuncObj
				Hotkey, If, % _hkIfFuncObject
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
			if (_f:=this.callableObject)
				SetTimer, % _f, % _period
			}
			unregister() {
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
		; ====================================================================================

	Class _Resource {

		static table := []

		path := ""
		subsections := {}
		hapaxLegomena := {}

		_set(_sourceName, _fileFullPath:="", _resource:="") {
			if not (StrLen(_sourceName))
				throw Exception("Invalid source name.")
			if (_fileFullPath <> "") {
				if not (FileExist(_fileFullPath))
					throw Exception("The resource could not be found.")
				try _fileObject:=FileOpen(_fileFullPath, 4+8+0, "UTF-8")
				catch
					throw Exception("Failed attempt to open the file.")
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
			while (_letter:=SubStr(_resource, 2, 1)) {
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
			_subsections := this.subsections, _letter := SubStr(_value, 1, 1)
			(_subsections.hasKey(_letter) || _subsections[_letter]:="`n")
			_subsection := _subsections[_letter] . _value . "`n"
			Sort, _subsection, D`n U
			ErrorLevel := 0
			_subsections[_letter] := "`n" . LTrim(_subsection, "`n")
		}
		update() {
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
		leftPart := {value: "", pos: 0, len: 0}
		isRegEx := {value: "", pos: 0, len: 0}
		rightPart := {value: "", pos: 0, len: 0}
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
		_lastX := 0
		_lastY := 0
		_lastWidth := 0
		_itemHeight := 0
		_list := ""
		_itemCount := 0
		_visible := false

		_onSelection := ""

		__New(_GUIID, _hHostControl) {

			static _virtualScreenWidth := DllCall("User32.dll\GetSystemMetrics", "UInt", 78)
			this._overallWidthAlloc := _virtualScreenWidth

			eAutocomplete._setOptions(this,, true)

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
			if (eAutocomplete._Listbox._properties.hasKey(_k))
			{
				if ((_updateFont:=((_k = "fontName") || (_k = "fontSize"))) || (_k = "fontColor")) { ; *
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
					_COUNTUPPERTHRESHOLD := eAutocomplete._ListBox._COUNTUPPERTHRESHOLD
					if _v between 1 and %_COUNTUPPERTHRESHOLD%
						return this._maxSuggestions:=Floor(_v), this._autoWH(this._list)
					else return this._maxSuggestions
				}
				else if (_k = "transparency") {
					if _v between 0 and 255
					{
						this._transparency := _v
						(this._visible && this._show())
					}
				return this._transparency
				}
				else if (_k = "bkColor") { ; *
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
			if (eAutocomplete._Listbox._properties.hasKey(_k))
				return this["_" . _k]
		}
		_hasHScrollBar {
			get {
			return !(this._itemCount <= this._maxSuggestions)
			}
		}

		setOptions(_opt) {
		eAutocomplete._setOptions(this, _opt)
		}

		_setData(_list) {
			_list := Trim(_list, "`n"), _count := 0
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
		_getHeight() {
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
					ControlGet, _item, Choice,,, % "ahk_id " . this._parent
				return this._text:=_item
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
		; =============================================================================================================
		_getCurrentItemData(_dataMaxIndex:=3) { ; //LB_GETITEMDATA/LB_SETITEMDATA
			(_tsv:=[])[_dataMaxIndex] := ""
			for _index, _element in StrSplit(this._selection.text, A_Tab, A_Tab . A_Space, _dataMaxIndex)
				_tsv[_index] := _element
		return _tsv
		}
		; =============================================================================================================

		_show(_boolean:=true) {
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

		__select(_hwnd:="", _event:="") {
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

		_dispose() {
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
			_w := this._lastWidth := this._getWidth(_params.1), _h := this._getHeight()
			GuiControl, Move, % this._HWND, % "w" . _w . " h" . _h
			GUI % this._parent . ":Show", % "NA AutoSize"
		}
		_autoXY() {
			if (A_CaretX <> "") {
				VarSetCapacity(_POINT_, 8, 0)
				DllCall("User32.dll\GetCaretPos", "Ptr", &_POINT_)
				DllCall("User32.dll\MapWindowPoints", "Ptr", this._host, "Ptr", 0, "Ptr", &_POINT_, "UInt", 1)
				_x1 := NumGet(_POINT_, 0, "Int") + 5, _y := NumGet(_POINT_, 4, "Int") + 30
				_x2 := _x1 + this._lastWidth
				_x := (_x2 > this._overallWidthAlloc) ? this._overallWidthAlloc - this._lastWidth : _x1
				GUI % this._parent . ":Show", % "NA x" . (this._lastX:=_x) . " y" . (this._lastY:=_y)
			}
		}

	}
	Class _ComboBoxList extends eAutocomplete._ListBox {

		__New(_GUIID, _hHostControl) {
			base.__New(_GUIID, _hHostControl)
			GUI % this._parent . ":+Parent" . this._owner
			_fn := this.__select.bind(this)
			GuiControl, +g, % this._HWND, % _fn
		}
		_getWidth() {
			ControlGetPos,,, _w,,, % "ahk_id " . this._host
		return _w
		}
		_autoWH(_params*) {
			if not (WinExist("ahk_id " . this._host))
				return
			GuiControl, MoveDraw, % this._HWND, % "h" . (_h:=this._getHeight()) . " w" . (_w:=this._getWidth())
			GUI % this._parent . ":Show", % "NA AutoSize"
		}
		_autoXY() {
			if not (WinExist("ahk_id " . this._host))
				return
			VarSetCapacity(_RECT_, 16, 0) ; https://autohotkey.com/boards/viewtopic.php?f=6&t=38472 - convert coordinates between Client/Screen/Window modes
			DllCall("User32.dll\GetWindowRect", "Ptr", this._host, "Ptr", &_RECT_)
			_x := NumGet(&_RECT_, 0, "Int"), _y := NumGet(&_RECT_, 4, "Int"), _h := NumGet(&_RECT_, 12, "Int") - _y
			this._lastX := _x, this._lastY := _y + _h
			DllCall("User32.dll\MapWindowPoints", "Ptr", 0, "Ptr", this._owner, "Ptr", &_RECT_, "UInt", 2)
			_x := NumGet(&_RECT_, 0, "Int"), _y := NumGet(&_RECT_, 4, "Int"), _h := NumGet(&_RECT_, 12, "Int") - _y
			GUI % this._parent . ":Show", % "NA x" . _x . " y" . _y + _h
		}

	}
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PRIVATE BASE OBJECT PROPERTIES ~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	static _instances := {}
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		static _properties :=
		(LTrim Join C
			{
				AHKID: "",
				autoSuggest: true,
				collectAt: 4,
				collectWords: true,
				disabled: false,
				endKeys: "?!,;.:(){}[\]'""<>\\@=/|", ; +todo subsquenceKeys
				expandWithSpace: true,
				HWND: "",
				learnWords: false,
				listbox: "",
				matchModeRegEx: true,
				minWordLength: 4,
				onCompletion: "",
				onReplacement: "",
				onResize: "",
				onSuggestionLookUp: "",
				regExSymbol: "*",
				source: "",
				suggestAt: 2 ; +onSuggestionsAvailable: "",
			}
		)
	__Set(_k, _v) {
		if (eAutocomplete._properties.hasKey(_k))
		{
			if ((_k = "AHKID") || (_k = "HWND") || (_k = "listbox"))
				return this["_" . _k]
			else if ((_k = "autoSuggest") || (_k = "collectWords") || (_k = "expandWithSpace") || (_k = "learnWords") || (_k = "matchModeRegEx"))
				return this["_" . _k] := !!_v
			else if (_k = "source") {
				if ((_v <> this._source.name) && eAutocomplete._Resource.table.hasKey(_v)) {
					_state := this._disabled
					this.disabled := true
					(this._learnWords && this._source.update())
				return this._source:=eAutocomplete._Resource.table[_v], this._disabled := _state
				}
			return this._source.name
			}
			else if (_k = "disabled") {
				((!!_v <> this._disabled) && (this._disabled:=!!_v) && this._listbox._dismiss())
			return this._disabled
			}
			else if ((_k = "onCompletion") || (_k = "onResize")) ; || (_k = "onSuggestionsAvailable")
				return _v, eAutocomplete._EventObject(this, "_" . _k, _v)
			else if ((_k = "onReplacement") || (_k = "onSuggestionLookUp")) {
				((_v <> "") || _v:=this["__" . _k].bind(this))
			return _v, eAutocomplete._EventObject(this, "_" . _k, _v)
			}
			else if ((_k = "collectAt") || (_k = "minWordLength") || (_k = "suggestAt"))
				return (not ((_v:=Floor(_v)) > 0)) ? this["_" . _k] : this["_" . _k]:=_v
			else if (_k = "endKeys") {
				static _lastEndKeys := eAutocomplete._properties.endKeys
				if InStr(_v, this._regExSymbol)
					return this["_endKeys"]
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
			else if (_k = "regExSymbol") {
				_v := Trim(_v, _lastEndKeys . A_Space . "`t`r`n")
			return (not (StrLen(_v) = 1)) ? this._regExSymbol : this._regExSymbol:=_v
			}
		}
	}
	setOptions(_opt) {
	eAutocomplete._setOptions(this, _opt)
	}
	__Get(_k, _params*) {
		if (eAutocomplete._properties.hasKey(_k))
			return this["_" . _k]
	}
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PUBLIC METHODS ~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	dispose() {
		if not (eAutocomplete._instances.hasKey(this._HWND))
			return
		this.disabled := true, eAutocomplete._instances.delete(this._HWND)
		for _, _instance in eAutocomplete._instances, _noMoreFromProcess := true {
			if (_instance._idProcess = this._idProcess) {
				_noMoreFromProcess := false
			break
			}
		}
		(_noMoreFromProcess && eAutocomplete._Value.unregisterProc(this._idProcess))
		; ========================================
		eAutocomplete._Hotkey(this._hkIfFuncObject)
		eAutocomplete._EventObject(this)
		eAutocomplete._Iterator(this._HWND)
		; ========================================
		(this._learnWords && this._source.update())
		if (this.hasKey("_hEditLowerCornerHandle"))
			GuiControl, -g, % this._hEditLowerCornerHandle
		this._listbox._dispose()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PUBLIC BASE OBJECT METHODS ~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	create(_GUIID, _editOptions:="", _opt:="") {
		_hLastFoundWindow := WinExist()
		try {
			Gui % _GUIID . ":+LastFoundExist"
			IfWinNotExist
				throw Exception("Invalid GUI window.",, _GUIID)
		} finally WinExist("ahk_id " . _hLastFoundWindow)
		GUI, % _GUIID . ":Add", Edit, % _editOptions . " hwnd_hEdit",
		_plusResize := ((_editOptions <> "") && (_editOptions ~= "i)(^|\s)\K\+?[^-]?Resize(?=\s|$)"))
		_isComboBox := (!_plusResize && !(DllCall("GetWindowLong", "UInt", _hEdit, "Int", -16) & 0x4))
		_inst := new eAutocomplete(_GUIID, _hEdit, _isComboBox, _opt)
		if (_plusResize) {
			GuiControlGet, _pos, Pos, % _hEdit
			GUI, % _GUIID . ":Add", Text, % "0x12 w11 h11 " . Format("x{1} y{2}", _posx + _posw - 7, _posy + _posh - 7) . " hwnd_hEditLowerCornerHandle",
			_inst._hEditLowerCornerHandle := _hEditLowerCornerHandle, _fn := _inst.__resize.bind(_inst)
			GuiControl +g, % _hEditLowerCornerHandle, % _fn
		}
	return _inst
	}
	attach(_hHostControl, _opt:="") {
		_detectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGetClass, _class, % "ahk_id " . _hHostControl
		DetectHiddenWindows % _detectHiddenWindows
		if not ((_class = "Edit") || (_class = "RICHEDIT50W"))
			throw Exception("The host control either does not exist or is not a representative of the class Edit/RICHEDIT50W.")
		_GUIID := DllCall("User32.dll\GetAncestor", "Ptr", _hHostControl, "UInt", 2, "Ptr")
		ControlGet, _style, Style,,, % "ahk_id " . _hHostControl
		_isComboBox := not (_style & 0x4) ; ES_MULTILINE
		_inst := new eAutocomplete(_GUIID, _hHostControl, _isComboBox, _opt)
		if (WinActive("ahk_id " . _GUIID))
			eAutocomplete._Value.__sourceChanged(0x8005, _hHostControl)
	return _inst
	}
	setSourceFromVar(_sourceName, _list:="") {
	eAutocomplete._Resource._set(_sourceName, "", _list)
	}
	setSourceFromFile(_sourceName, _fileFullPath) {
	eAutocomplete._Resource._set(_sourceName, _fileFullPath)
	}
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_hEditLowerCornerHandle := ""
	_minSize := {w: 51, h: 21}
	_maxSize := {w: A_ScreenWidth, h: A_ScreenHeight}
	_content := ""
	_pendingWord := ""
	_ready := true
	_completionData := ""
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PRIVATE METHODS ~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	__New(_GUIID, _hHostControl, _isComboBox, _opt:="") {

		eAutocomplete._setOptions(this,, true)

		_idProcess := "", DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", _GUIID, "UIntP", _idProcess, "UInt")
		if not (_idProcess)
			throw Exception("Could not retrieve the identifier of the process that created the host window.")
		this._idProcess := _idProcess, this._parent := _GUIID, this._AHKID := "ahk_id " . (this._HWND:=_hHostControl)

		_listBox := (this._isComboBox:=_isComboBox) ? eAutocomplete._ComboBoxList : eAutocomplete._DropDownList
		_listbox := this._listbox := new _listBox(_GUIID, _hHostControl)

		this._source := eAutocomplete._Resource.table["Default"]
		this.onSuggestionLookUp := "", this.onReplacement := ""
		if (IsObject(_opt)) {
			_clone := _opt.clone()
			if (_listBoxOptions:=_clone.remove("listbox"))
				_listBox.setOptions(_listBoxOptions)
			this.setOptions(_clone)
		}

		; ========================================
		eAutocomplete._Iterator(this._HWND, ObjBindMethod(this, "__valueChanged", _hHostControl))
		; ========================================
		eAutocomplete._Value.registerProc(this._idProcess)
		eAutocomplete._EventObject(this._listbox, "_onSelection", ObjBindMethod(this, "_listboxSelectionEventMonitor"))
		; ========================================
		_hkIfFuncObject := this._hkIfFuncObject := this._hotkeyPressHandler.bind("", _hHostControl)
		eAutocomplete._Hotkey(_hkIfFuncObject, "Escape", ObjBindMethod(this._listbox, "_dismiss"))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Up", ObjBindMethod(_listbox, "_selectUp"))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Down", ObjBindMethod(_listbox, "_selectDown"))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Left", Func("WinActive"))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Right", ObjBindMethod(this, "_completionDataLookUp", 1))
		eAutocomplete._Hotkey(_hkIfFuncObject, "+Right", ObjBindMethod(this, "_completionDataLookUp", 2))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Tab", ObjBindMethod(this, "_complete", false, 1))
		eAutocomplete._Hotkey(_hkIfFuncObject, "+Tab", ObjBindMethod(this, "_complete", false, 2))
		eAutocomplete._Hotkey(_hkIfFuncObject, "Enter", ObjBindMethod(this, "_complete", true, 1))
		eAutocomplete._Hotkey(_hkIfFuncObject, "+Enter", ObjBindMethod(this, "_complete", true, 2))
		; ========================================

	return eAutocomplete._instances[_hHostControl] := this
	}

	; ==================================================================

	__valueChanged() {
		this._ready := false
		_count := this._hasSuggestions
		if (_count > 0) {
			(this._autoSuggest && this._suggest()) ; +(this._onSuggestionsAvailable && this._onSuggestionsAvailable.call(this))
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
	_capturePendingWord() {
		_wrapper := new eAutocomplete._pendingWordMatchObjectWrapper
		_content := this._content, _caretPos := this._getSelection() ; <<<<
		_caretIsWellPositioned := (StrLen(RegExReplace(SubStr(_content, _caretPos, 2), "\s$")) <= 1) ; <<<<-
		if not (_caretIsWellPositioned)
			return _wrapper
		_leftPart := "?P<leftPart>[^\s" . this._endKeys . this._regExSymbol . "]{" . this._suggestAt - 1 . ",}" ; todo: prebuild the needleRegEx
		_isRegex := "?P<isRegEx>\Q" . this._regExSymbol . "\E?"
		_rightPart := "?P<rightPart>[^\s" . this._endKeys . this._regExSymbol . "]+"
		_match := "?P<match>(" . _leftPart . ")(" . _isRegex . ")(" . _rightPart . ")"
		_isComplete := "?P<isComplete>[\s" . this._endKeys . "]?"
		RegExMatch(SubStr(_content, 1, _caretPos), "`aOi)(" . _match . ")(" . _isComplete . ")$", _pendingWord)
		for _subPatternName, _subPatternObject in _wrapper
			for _property in _subPatternObject, _o := _wrapper[_subPatternName]
				_o[_property] := _pendingWord[_property](_subPatternName)
		return _wrapper
	}
	__hapax(_match, _len) {
		if (!this._collectWords || (_len < this._minWordLength))
			return
		_hapaxLegomena := this._source.hapaxLegomena
		(_hapaxLegomena.hasKey(_match) || _hapaxLegomena[_match]:=0)
		if not (++_hapaxLegomena[_match] = this.collectAt)
			return
		this._source.appendValue(_match)
	}
	_hasSuggestions {
		get {
			_pendingWord := this._pendingWord := this._capturePendingWord()
			if not (this._pendingWord.match.len)
				return 0
			else if (_pendingWord.isComplete.len)
				return -1
			_list := ""
			if ((_subsection:=this._source.subsections[ SubStr(_pendingWord.match.value, 1, 1) ]) <> "") {
				if (_pendingWord.isRegEx.len && this._matchModeRegEx) {
					_substring := _pendingWord.leftPart.value
					RegExMatch(_subsection, "`nsi)\n\Q" . _substring . "\E[^\n]+(?:.*\n\Q" . _substring . "\E.+?(?=\n))?", _match)
					_len := _pendingWord.leftPart.len + 1, _rightPart := _pendingWord.rightPart.value
					_listLines := A_ListLines
					ListLines, Off
					Loop, parse, % _match, `n
					{
						if (InStr(SubStr(A_LoopField, _len), _rightPart))
							_list .= A_LoopField . "`n"
					}
					ListLines % _listLines ? "On" : "Off"
				} else {
					_substring := _pendingWord.match.value
					RegExMatch(_subsection, "`nsi)\n\Q" . _substring . "\E[^\n]+(?:.*\n\Q" . _substring . "\E.+?(?=\n))?", _list)
				}
			}
			this._listbox._setData(_list)
		return this._listbox._itemCount
		}
	}
	_suggest() {
		; if (!this._isComboBox || !this._listbox._visible)
			this._listbox._showDropDown()
		this._listbox._selectDown()
	}

	_listboxSelectionEventMonitor(_selection, _clickEvent, _selectionHasChanged) {
	(_selectionHasChanged && this._completionData:=""), (_clickEvent && this._complete(false))
	}
	_completionDataLookUp(_tabIndex) {
		static _keys := {}
		if not (_keys.hasKey(A_ThisHotkey)) {
			RegExMatch(A_ThisHotkey, "i)(\w+|.)(?:[ `t]Up)?$", _match), _keys[ A_ThisHotkey ] := _match
		}
		_listbox := this._listbox
		(!this._completionData && this._completionData:=_listbox._getCurrentItemData())
		_coordModeToolTip := A_CoordModeToolTip
		CoordMode, ToolTip, Screen
			_x := _listbox._lastX + 10
			_y := _listbox._lastY + (_listbox._selection.offsetTop - 0.5) * _listbox._itemHeight
			ToolTip % this._onSuggestionLookUp.call(this._completionData.1, _tabIndex), % _x, % _y
			KeyWait % _keys[ A_ThisHotkey ]
			ToolTip
		CoordMode, ToolTip, % _coordModeToolTip
	}
	__onSuggestionLookUp(_value, _tabIndex) {
		_infoTipText := this._completionData[ _tabIndex + 1 ]
	return StrReplace(StrReplace(_infoTipText, "``n", "`n"), "``r", "`r")
	}

	_complete(_goToNewLine, _tabIndex:="") {
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
		(!this._completionData && this._completionData:=this._listbox._getCurrentItemData())
		_pendingWord := this._pendingWord
		if (_pendingWord.isRegEx.len) {
			StringTrimLeft, _missingPart, % this._completionData.1, % _pendingWord.leftPart.len
			eAutocomplete._Value._rawSend("{BS " . 1 + _pendingWord.rightPart.len . "}", this._HWND)
		} else {
			StringTrimLeft, _missingPart, % this._completionData.1, % StrLen(_pendingWord.match.value)
		}
		eAutocomplete._Value._rawPaste(_missingPart, this._HWND) ; <<<<
	}
	_replace(_tabIndex) {
		(!this._completionData && this._completionData:=this._listbox._getCurrentItemData())
		eAutocomplete._Value._rawSend("{BS " . StrLen(this._pendingWord.match.value) . "}", this._HWND)
		_value := this._completionData[ _tabIndex + 1 ] := this._onReplacement.call(this._completionData.1, _tabIndex)
		eAutocomplete._Value._rawPaste(_value, this._HWND)
	}
	__onReplacement(_value, _tabIndex) {
	return this._completionData[ _tabIndex + 1 ]
	}

	; -----------------------------------------------------------------------------------------------
	_getSelection(ByRef _startSel:="", ByRef _endSel:="") { ; <<<<
		static EM_GETSEL := 0xB0
		VarSetCapacity(_startPos, 4, 0), VarSetCapacity(_endPos, 4, 0)
		SendMessage, % EM_GETSEL, &_startPos, &_endPos,, % this._AHKID
		_startSel := NumGet(_startPos), _endSel := NumGet(_endPos)
	return _endSel
	}
	; -----------------------------------------------------------------------------------------------

	__resize(_hEditLowerCornerHandle) {

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
			if (this._onResize && this._onResize.call(A_GUI, this, _w, _h, _x, _y))
				Exit
			GuiControl, Move, % _hEdit, % "w" . _w . " h" . _h
			GuiControlGet, _pos, Pos, % _hEdit
			GuiControl, MoveDraw, % _hEditLowerCornerHandle, % "x" . (_posx + _posw - 7) . " y" . _posy + _posh - 7
		sleep, 15
		}
		CoordMode, Mouse, % _coordModeMouse
		ListLines % _listLines ? "On" : "Off"

	}

	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~ PRIVATE BASE OBJECT METHODS ~~~~~~~~~~~~
	; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	_setOptions(_obj, _opt:="", _initialize:=false) {
		_clone := _obj._properties.clone()
		if (_initialize) {
			for _key, _defaultValue in _clone {
				ObjRawSet(_obj, "_" . _key, _defaultValue)
			}
		return
		}
		if (IsObject(_opt))
			for _key, _value in _opt
				(_clone.hasKey(_key) && _obj[_key]:=_value)
	}
	_hotkeyPressHandler(_hwnd, _thisHotkey) {
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
			for _, _hWinEventHook in eAutocomplete._Value.processes[_idProcess]
				DllCall("User32.dll\UnhookWinEvent", "Ptr", _hWinEventHook)
			eAutocomplete._Value.processes.delete(_idProcess)
		}
		_rawSend(_keys, _hwnd) {
		_state := eAutocomplete._Value.bypassToggle
		eAutocomplete._Value.bypassToggle := true
		_keyDelay := A_KeyDelay
		SetKeyDelay, 0
		ControlSend,, % _keys, % "ahk_id " . _hwnd
		sleep, 300 ;  check messages of the internal message queue
		SetKeyDelay % _keyDelay
		eAutocomplete._Value.bypassToggle := _state
		}
		_rawPaste(_text, _hwnd) {
		_state := eAutocomplete._Value.bypassToggle
		eAutocomplete._Value.bypassToggle := true
		Control, EditPaste, % StrReplace(StrReplace(_text, "``n", "`n"), "``r", "`r"),, % "ahk_id " . _hwnd
		sleep, 300 ;  check messages of the internal message queue
		eAutocomplete._Value.bypassToggle := _state
		}
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		__sourceChanged(_event, _hwnd) {
			if ((_event = 0x8005) || (_event = 0x0015)) { ; *
				ControlGetFocus, _focusedControl, A
				ControlGet, _hwnd, Hwnd,, % _focusedControl, A
				if (_hwnd = eAutocomplete._Value.lastFoundControl)
					return
			}
			; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			; f(_hwnd)
			for _each, _instance in eAutocomplete._instances {
				if (_instance._listbox._visible) {
					_instance._listbox._hideDropDown()
				break
				}
			}
			eAutocomplete._Value.lastFoundControl:=(eAutocomplete._instances.hasKey(_hwnd)) ? _hwnd : 0x0
			; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		}
		__valueChange(_event, _hwnd, _idObject, _idChild) {
			static OBJID_CLIENT := 0xFFFFFFFC
			if (_idObject <> OBJID_CLIENT) ; for instance > OBJID_VSCROLL = 0xFFFFFFFB
				return
			if not (eAutocomplete._Value.bypassToggle) {
			; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			; f(_hwnd)
				if (eAutocomplete._instances.hasKey(_hwnd)) {
					_inst := eAutocomplete._instances[_hwnd]
					Critical
					; ACC ================================================
					_acc := Acc_ObjectFromEvent(_idChild_, _hwnd, _idObject, _idChild)
					try _inst._content := _acc.accValue(0)
					; ACC ================================================
					; ControlGetText, _text,, % _inst._AHKID
					; _inst._content := _text
					if (!_inst._disabled) {
						eAutocomplete._Iterator.instances[_inst._HWND].1.setPeriod(-(3 + !_inst._ready) * 75)
					}
				}
			; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			}
		}

	}

}
