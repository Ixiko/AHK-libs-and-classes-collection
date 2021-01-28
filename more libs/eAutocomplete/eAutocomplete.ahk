Class eAutocomplete {
	_disabled := false
	_keypressThreshold := 225
	_autoSuggest := true
	_resource := ""
	resource {
		set {
			local
			try _disabled := this.disabled, this.disabled := true, this.WordList._current := value
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			} finally this.disabled := _disabled
		return this.resource
		}
		get {
		return this.WordList._current
		}
	}
	disabled {
		set {
			value := !!value
			if (value <> this.disabled) {
				OnMessage(0x8004, this._HostControlWrapper, !(this._disabled:=value))
				(value && this._stopPropagation())
				if (this.Menu.isVisible())
					this.Menu.dismiss()
			return this._disabled:=value
			}
		return this.disabled
		}
		get {
		return this._disabled
		}
	}
	keypressThreshold {
		set {
		return (not ((value:=Floor(value)) > 65)) ? this.keypressThreshold : this._keypressThreshold:=value
		}
		get {
		return this._keypressThreshold
		}
	}
	autoSuggest {
		set {
		return this._autoSuggest:=!!value
		}
		get {
		return this._autoSuggest
		}
	}
	WordList {
		set {
			throw Exception("This member is protected (read only).", -1)
		; return this.WordList
		}
		get {
		return this._WordList
		}
	}
	Menu {
		set {
			throw Exception("This member is protected (read only).", -1)
		; return this.Menu
		}
		get {
		return this._Menu
		}
	}
	Completor {
		set {
			throw Exception("This member is protected (read only).", -1)
		; return this.Completor
		}
		get {
		return this._Completor
		}
	}
	wrap(_hHost) {
		local
		_hHost := Format("{:i}", _hHost)
		try _lastFound := "", this._HostControlWrapper.wrap(_hHost, this.__focus__.bind(this))
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		; return
		}
		new this._HostControlWrapper.EventsMessenger(_hHost)
	}
	unwrap(_hHost) {
		local
		_hHost := Format("{:i}", _hwnd:=_hHost)
		try this._HostControlWrapper.EventsMessenger._dispose(_hHost)
		catch _exception {
			throw Exception(_exception.message, -1, _exception.extra)
		; return
		}
		this._HostControlWrapper.unwrap(_hHost, this.__focus__.bind(this))
	}
	unwrapAll() {
		this._HostControlWrapper.EventsMessenger._disposeAll()
		this.Menu.owner := ""
		this._HostControlWrapper.unwrapAll()
	}

	__focus__(_hEdit:=0x0, _param2:=false) {
		this._stopPropagation()
		if (_param2)
			this.Menu.hide()
		else if (this._HostControlWrapper.instances.hasKey(Format("{:i}", _hEdit)))
			this.Menu.owner := WinExist("ahk_id " . _hEdit)
		else this.Menu.owner := ""
	}
	__value__() {
		SetTimer % this, % - this._responseTime
	}
	_stopPropagation() {
		SetTimer % this, Off
	}
		_responseTime {
			get {
			return this.keypressThreshold + !this.Menu.isAvailable() * (this.keypressThreshold // 4)
			}
		}
	call(_suggest:=false) {
		local
		static COMPLETEWORD_QUERY := 1
		if ((_suggest || this.autoSuggest) && this._shouldTrigger(_caretPos)) {
			this.Menu._setSuggestionList(_list:="")
			; this.Menu.disabled := true
			_queryType := this.WordList._current.executeQuery(SubStr(this._HostControlWrapper.lastFoundValue, 1, _caretPos), _list)
			if (_queryType < COMPLETEWORD_QUERY)
				this.Menu._setSuggestionList(_list)
			else this.Menu._setSuggestionList()
			; this.Menu.disabled := false
		} else this.Menu._setSuggestionList()
	}
		_shouldTrigger(ByRef _caretPos:="") {
			local
			_HostControlWrapper := this._HostControlWrapper
			_atWordBufferPos := "", _caretPos := _HostControlWrapper.getCaretPos(_atWordBufferPos)
		return _atWordBufferPos
		}

	complete(_eventInfo_:=-1) {
		if (_eventInfo_ > -1)
			this._complete(this.Menu.itemsBox.selection.text, _eventInfo_)
	}
	completeAndGoToNewLine(_eventInfo_:=-1) {
		if (_eventInfo_ > -1)
			this._complete(this.Menu.itemsBox.selection.text, _eventInfo_, -1)
	}
	_complete(_selectedItemText, _variant:=0, _expandModeOverride:="") {
		this._completor(this.WordList._current.Query._history.1, _selectedItemText, _expandModeOverride, _variant)
	}
		__complete__(_fragment, _suggestion, ByRef _expandModeOverride, _variant) {
			local
			_source := this.WordList._current ; ~
			if (_source.deleteItem(_suggestion))
				_source.insertItem(_suggestion)
			_r := this[(_variant) ? "_onReplacement" : "_onComplete"].call(_suggestion, _expandModeOverride)
		return (this.Menu.isAvailable() ? _r : ""), this.Menu._setSuggestionList() ; this.call()
		}
		__complete(_suggestion, ByRef _expandModeOverride:="") {
		return _suggestion
		}
		__remplacement(_suggestion, ByRef _expandModeOverride:="") {
		return _suggestion
		}

	_infoTipInvocationHandler(_text) {
	return this._onSuggestionLookUp.call(_text)
	}
	__suggestionLookUp(_text) {
	return ""
	}
	lookUpSuggestion() {
		_thisHotkey := A_ThisHotkey
		this.Menu.InfoTip.show()
		KeyWait % this._Hotkey(this.Hotkey._ShouldFire, _thisHotkey).key
		this.Menu.InfoTip.hide()
	}
	invokeMenu() {
	this._stopPropagation(), this.call(true)
	}

	Class _HostControlWrapper {
		; static COMPATIBLE_CLASSES := "Edit"
		static COMPATIBLE_CLASSES := "Edit|RICHEDIT50W"
		instances := []
		lastFound := 0x0
		lastFoundValue := ""
		_notify := false
		notify {
			set {
				value:=!!value
				OnMessage(0x8003, this, value), OnMessage(0x8004, this, value)
			return this._notify:=value
			}
			get {
			return this._notify
			}
		}
		wrap(_hControlAsDigit, _cb:="") {
			local
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			WinGetClass, _class, % "ahk_id " . _hControlAsDigit
			DetectHiddenWindows % _detectHiddenWindows
			if not (_class ~= "^(" . this.COMPATIBLE_CLASSES . ")$") {
				throw Exception("The host control either does not exist or is not a representative of the class " . this.COMPATIBLE_CLASSES . ".", -1, _class)
			; return false
			}
			if (this.instances.hasKey(_hControlAsDigit)) {
				throw Exception("Could not wrap the control (the control is already interfaced).", -1, _hControlAsDigit)
			; return false
			}
			this.instances[_hControlAsDigit] := _class
			_hwnd := ""
			try {
				ControlGetFocus, _focusedControl, A
				ControlGet, _hwnd, Hwnd,, % _focusedControl, A
			} catch
				return true
			if (_hwnd = _hControlAsDigit)
				this.lastFound := _hControlAsDigit, (_cb && _cb.call(_hControlAsDigit))
		return true
		}
		unwrap(_hControlAsDigit, _cb:="") {
			this.instances[_hControlAsDigit] := ""
			this.instances.delete(_hControlAsDigit), (_cb && _cb.call())
		}
		unwrapAll() {
			local
			for _hControlAsDigit in this.instances.clone()
				this.unwrap(_hControlAsDigit)
		}
		_dispose() {
			this.notify := false
			this.__focus := this.__value := ""
		}
		__Delete() {
			; MsgBox % A_ThisFunc
		}
		__Call(_callee, _params*) {
			local
			if (IsFunc(this.base.__Class "._" _callee)) {
				_toggle := this.notify
				this.notify := false
				this["_" . _callee](_params*)
				sleep, 10 ; <<<<
				this.notify := _toggle
			}
		}
		_sendText(_text) {
			this._send("{Text}" . _text)
		}
		_send(_keys) {
			local
			sleep, 1 ; <<<<
			ControlFocus,, % "ahk_id " . this.lastFound
			_keyDelay := A_KeyDelay
			SetKeyDelay, 0
			SendInput, % _keys
			SetKeyDelay % _keyDelay
		}
		getCaretPos(ByRef _atWordBufferPos:="", ByRef _startPos:="", ByRef _endPos:="") {
			local
			_startPos := _endPos := "", this._getCaretPos(_startPos, _endPos)
			if (IsByref(_atWordBufferPos)) {
				_atWordBufferPos := this._isAtWordBufferPos(_startPos, _endPos)
			}
		return _endPos
		}
		_getCaretPos(ByRef _startPos:="", ByRef _endPos:="") {
			local
			static EM_GETSEL := 0xB0
			VarSetCapacity(_startPos, 4, 0), VarSetCapacity(_endPos, 4, 0)
			SendMessage, % EM_GETSEL, &_startPos, &_endPos,, % "ahk_id " . this.lastFound
		return _endPos := NumGet(_endPos), (IsByref(_startPos) && _startPos := NumGet(_startPos))
		}
		_isAtWordBufferPos(_startPos, _endPos) {
			return ((_startPos = _endPos) && (StrLen(RegExReplace(SubStr(this.lastFoundValue, _endPos, 2), "\s$")) <= 1))
		}
		_getTextFromEvent(ByRef _text, _eventParam1, _eventParam2) {
			local
			static OBJID_CLIENT := 0xFFFFFFFC
			_acc := this._Utils.Acc.ObjectFromEvent(_idChild_, _eventParam1, OBJID_CLIENT, _eventParam2)
			try _text := _acc.accValue(0)
			catch
				_text := ""
		}
		call(_param1, _param2, _msg, _hwnd) {
			local
			static EVENT_FOCUS := 0x8003
			static EVENT_VALUE := 0x8004
			Critical
			if (_msg = EVENT_VALUE) {
				if (this.instances.hasKey(_param1)) {
					_text := "", this._getTextFromEvent(_text, _param1, _param2)
					try this.lastFoundValue := _text
					this.__value.call()
				}
			} else if (_msg = EVENT_FOCUS) {
				this.__focus.call(this.lastFound:=this.instances.hasKey(_param1) * _param1, _param2)
			}
		}

		Class _Utils {
			Class Acc {
				Init() {
					static _h := ""
					IfNotEqual, _h,, return
					_h := DllCall("Kernel32.dll\LoadLibrary", "Str", "Oleacc.dll", "UPtr")
				}
				ObjectFromEvent(ByRef _idChild_, _hWnd, _idObject, _idChild) {
					local
					static VT_DISPATCH := 9
					static S_OK := 0x00
					this.Init(), _pAcc := ""
					_hResult := DllCall("Oleacc.dll\AccessibleObjectFromEvent"
					, "Ptr", _hWnd, "UInt", _idObject, "UInt", _idChild, "PtrP", _pAcc, "Ptr", VarSetCapacity(_varChild, 8 + 2 * A_PtrSize, 0) * 0 + &_varChild)
					if (_hResult = 0)
						return ComObj(VT_DISPATCH, _pAcc, 1), _idChild_ := NumGet(_varChild, 8, "UInt")
				}
			}
		}

		Class Complete extends eAutocomplete._HostControlWrapper._EventHandler {
	_correctCase := false
	_expandMode := 1
	__New(_control) {
		this.control := _control
	}
	__Call(_callee, _fragment, _by, _expandModeOverride:="", _params*) {
		local
		this.control.send("{BS " . StrLen(_fragment) . "}")
		((_onEvent:=this.onEvent) && (_by:=_onEvent.call(_fragment, _by, _expandModeOverride, _params*)))
		if not (this.correctCase) {
			_len := 0
			Loop, parse, % _fragment
			{
				if not (A_LoopField = SubStr(_by, a_index, 1))
					break
			_len++
			}
			(_len && _by := SubStr(_fragment, 1, _len) . SubStr(_by, _len + 1))
		}
		this.control.sendText(_by)
		((_expandModeOverride="") && _expandModeOverride:=this.expandMode)
		if (_expandModeOverride) {
			switch _expandModeOverride
			{
				case -1:
					this.control.send("{Enter}")
				case 1:
					this.control.send("{Space}")
			}
		}
	}
	expandMode {
		set {
			if ((value = 0) || (value = 1))
				return this._expandMode := value
			throw Exception("Invalid value.", -1, value)
		; return this.expandMode
		}
		get {
		return this._expandMode
		}
	}
	correctCase {
		set {
		return this._correctCase := !!value
		}
		get {
		return this._correctCase
		}
	}
}

		Class _EventHandler {
			_onEvent := ""
			onEvent {
				set {
					if (IsFunc(value)) {
						this._onEvent := StrLen(value) ? Func(value) : value
					} else if (IsObject(value)) {
						this._onEvent := value
					} else this._onEvent := ""
				return this._onEvent
				}
				get {
				return this._onEvent
				}
			}
		}

		Class EventsMessenger extends eAutocomplete._HostControlWrapper._EventsMessenger_ {
			static instances := []
			static winEventHooks := []
			__New(_hwnd) {
				local
				static EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
				static EVENT_OBJECT_VALUECHANGE := 0x800E
				static _cbValue := RegisterCallback("eAutocomplete._HostControlWrapper.EventsMessenger.__value")
				_idProcess := "", DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", _hwnd, "UIntP", _idProcess, "UInt")
				if not (_idProcess) {
					throw Exception("Could not retrieve the identifier of the process that created the window.")
				; return
				}
				this.idProcess := _idProcess
				this.instances[ _ID:=this.ID:=_hwnd+0 ] := this
				if not (this._isLastHandleForProcess(_ID, _idProcess))
					return this
				_winEventHooks := this.winEventHooks[_idProcess] := []
				Loop, parse, % EVENT_OBJECT_VALUECHANGE "," EVENT_OBJECT_TEXTSELECTIONCHANGED, CSV
				_winEventHooks.push(new this.WinEventHook(A_LoopField, _idProcess, _cbValue))
			return this
			}
			_isLastHandleForProcess(_identifier, _idProcess) {
				local
				for _ID, _instance in this.instances {
					if ((_ID <> _identifier) && (_instance.idProcess = _idProcess))
						return false
				}
				return true
			}
			__Delete() {
				local
				; MsgBox, 16,, % A_ThisFunc
				_ID := this.ID, _idProcess := this.idProcess
				if (this._isLastHandleForProcess(_ID, _idProcess))
					this.winEventHooks.delete(_idProcess)
			}

			_dispose(_hwnd) {
				local
				_instances := this.instances, _key := Format("{:i}", _hwnd)
				if (_instances.hasKey(_key)) {
					this.instances[_key] := ""
					this.instances.delete(_key)
				} else throw Exception("The instance does not exists.", -1, _hwnd)
			}
			_disposeAll() {
				local
				for _hControl in this.instances.clone()
					this._dispose(_hControl)
			}
			__value(_event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {
				static OBJID_CLIENT := 0xFFFFFFFC
				if (_idObject = OBJID_CLIENT) {
					DllCall("User32.dll\PostMessage", "Ptr", A_ScriptHwnd, "Uint", 0x8004, "Ptr", _hwnd, "Ptr", _idChild) ; WM_APP + 4
				}
			}
		}
		Class _EventsMessenger_ {
			_Init() {
				local _winEventHooks
				static EVENT_SYSTEM_MOVESIZESTART := 0x000A
				static EVENT_SYSTEM_SWITCHEND := 0x0015
				static EVENT_OBJECT_FOCUS := 0x8005
				static _cbFocus := RegisterCallback("eAutocomplete._HostControlWrapper._EventsMessenger_.__focus")
				static _ := eAutocomplete._HostControlWrapper._EventsMessenger_._Init()
				_winEventHooks := []
				Loop, parse, % EVENT_SYSTEM_MOVESIZESTART "," EVENT_SYSTEM_SWITCHEND "," EVENT_OBJECT_FOCUS, CSV
					_winEventHooks.push(new this.WinEventHook(A_LoopField, 0, _cbFocus))
				OnExit(eAutocomplete._HostControlWrapper._EventsMessenger_._Release.bind("", _winEventHooks))
			}
			_Release(_winEventHooks) {
				local
				for _k, _v in _winEventHooks.clone()
					_winEventHooks.delete(_k)
			}
				Class WinEventHook {
					__New(_event, _idProcess, _cb) {
						this.hWinEventHook := DllCall("User32.dll\SetWinEventHook"
												, "Uint", _event
												, "Uint", _event
												, "Ptr", 0
												, "Ptr", _cb
												, "Uint", _idProcess
												, "Uint", 0
												, "Uint", 0)
					}
					__Delete() {
						local
						; MsgBox % _r := DllCall("User32.dll\UnhookWinEvent", "Ptr", this.hWinEventHook)
						_r := DllCall("User32.dll\UnhookWinEvent", "Ptr", this.hWinEventHook)
					return _r
					}
				}
			__focus(_event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {
				local
				static EVENT_SYSTEM_MOVESIZESTART := 0x000A
				static _lastFoundControl := 0x0
				sleep, 1 ; <<<<
				; Critical
				ControlGetFocus, _focusedControl, A
				ControlGet, _hwnd, Hwnd,, % _focusedControl, A
				_boolean := (_event = EVENT_SYSTEM_MOVESIZESTART)
				if (_hwnd = _lastFoundControl) {
					if not (_boolean)
						return
				}
				_lastFoundControl := _hwnd
				DllCall("User32.dll\PostMessage", "Ptr", A_ScriptHwnd, "Uint", 0x8003, "Ptr", _hwnd, "Ptr", _boolean) ; WM_APP + 3
			}
		}

	}

	Class _WordList {
		static _table := {}
		static _current_ := ""
		_subsections := {}
		_hapaxLegomena := ComObjCreate("Scripting.Dictionary")
		_exportPath := ""
		__New(_sourceName, _caseSensitive:=false, _autoSort:=false, _bypass_:=false) {
			; static vbBinaryCompare := 0
			; static vbTextCompare := 1
			if not (StrLen(_sourceName) || _bypass_) {
				throw Exception("Invalid source name.", -1)
			; return
			}
			this.Word := new this.Word()
			this.Query := new this.Query(this.Word)
			; this._sortCS := (this._caseSensitive:=!!_caseSensitive) ? "C" : ""
			this._caseSensitive := !!_caseSensitive
			this._sortCS := ""
			ObjRawSet(this.Query.Sift, "_caseSensitive", _caseSensitive)
			this._hapaxLegomena.CompareMode := !_caseSensitive
			this._autosort := !!_autoSort
			this._name := _sourceName
		return this._table[_sourceName] := this
		}
		name {
			get {
			return this._name
			}
			set {
				throw Exception("The property is read only.", -1)
			; return this._name
			}
		}
		_learnWords := false
		learnWords {
			set {
			return this._learnWords := !!value
			}
			get {
			return this._learnWords
			}
		}
		_collectWords := true
		collectWords {
			set {
			return this._collectWords := !!value
			}
			get {
			return this._collectWords
			}
		}
		_collectAt := 4
		collectAt {
			set {
			local
				if ((value:=Floor(value)) > 0) {
					for _hapax in this._hapaxLegomena {
						this._hapaxLegomena.item[_hapax] := (this.isHapax(_hapax)) ? 0 : value
					}
				this._collectAt := value
				}
			return this._collectAt
			}
			get {
			return this._collectAt
			}
		}
		hasSource(_sourceName) {
			return this._table.hasKey(_sourceName)
		}
		getSource(_sourceName) {
			return this._table[_sourceName]
		}
		getSubsection(_word, ByRef _subsection:="") {
		_subsection := this._subsections[ SubStr(_word, 1, 1) ]
		}
		_build(_fileFullPath:="", ByRef _resource:="", _format:=false, _exportPath:="") {
			local
			if (_fileFullPath <> "") {
				if not (FileExist(_fileFullPath)) {
					throw Exception("The resource could not be found.",, _fileFullPath)
				; return
				}
				try _fileObject:=FileOpen(_fileFullPath, 4+8, "UTF-8")
				catch {
					throw Exception("Failed attempt to open the file.")
				; return
				}
				_resource := _fileObject.read(), _fileObject.close()
			}
			this._buildSubsections(_format, _resource)
			if (_exportPath <> "") {
				FileAppend,, % _exportPath, UTF-8
				if not (ErrorLevel)
					this._exportPath := _exportPath
			}
		}
		_buildSubsections(_format, ByRef _resource) {
			local
			_batchLines := A_BatchLines
			SetBatchLines, -1
			_resource .= "`n"
			_resource := RegExReplace(_resource, "(\t.+?)?(\r?\n)+", "`n")
			if (_format) {
				Sort, _resource, % this._sortCS . "D`nU"
				ErrorLevel := 0
			} else if (this._autosort) {
				Sort, _resource, % this._sortCS . "D`n"
				ErrorLevel := 0
			}
			_resource := "`n" . LTrim(_resource, "`n")
			_listLines := A_ListLines
			ListLines, 0
			while ((_letter:=SubStr(_resource, 2, 1)) <> "") {
				_position := RegExMatch(_resource, "SPsi)\n\Q" . _letter . "\E[^\n]+(?:.*\n\Q" . _letter . "\E.+?(?=\n))?", _length) + _length ; case insensitive
				if _letter is not space
					this._subsections[_letter] := SubStr(_resource, 1, _position)
				_resource := SubStr(_resource, _position)
			}
			ListLines % _listLines
			SetBatchLines % _batchLines
		}
		executeQuery(_needle, ByRef _list:="") {
			local
			if (this.Query.test(_needle, _queryMatchObject)) {
				if (_queryMatchObject.isComplete.len) {
					_value := _queryMatchObject.isPending.value
					if (this.collectWords && this.Word.test(_value))
						(this.isHapax(_value) && this.__hapax(_value))
				return 1
				} else if (_queryMatchObject.isPending.len) {
					_value := _queryMatchObject.isPending.value
					_subsection := "", this.getSubsection(_value, _subsection)
					_sift := this.Query.Sift, _sift.needle := _value, _sift.regex(_subsection, _list)
				return -1
				}
			}
		return 0
		}
		isHapax(_match) {
			for _each, _subsection in this._subsections {
				if InStr(_subsection, "`n" . _match . "`n", this._caseSensitive)
					return false
			}
			return true
		}
		__hapax(_match) {
			local
			_hapaxLegomena := this._hapaxLegomena
			if not (_hapaxLegomena.Exists(_match))
				_hapaxLegomena.Add(_match, 0)
			if (_hapaxLegomena.item[_match] + 1 = this.collectAt)
				this.insertItem(_match)
			++_hapaxLegomena.item[_match]
		}
		deleteItem(_value) {
			local
			_subsections := this._subsections, _letter := SubStr(_value, 1, 1)
			_stringCaseSense := A_StringCaseSense
			StringCaseSense % this._caseSensitive
			if (_subsections.hasKey(_letter)) {
				_subsections[_letter] := StrReplace(_subsections[_letter], "`n" . _value . "`n", "`n", _count, 1)
			return _count
			}
			StringCaseSense % _stringCaseSense
		return 0
		}
		insertItem(_value) {
			local
			_subsections := this._subsections, _letter := SubStr(_value, 1, 1)
			(_subsections.hasKey(_letter) || _subsections[_letter]:="`n")
			_subsection := "`n" . _value . _subsections[_letter]
			if (this._autosort) {
				Sort, _subsection, % this._sortCS . "D`nU"
				ErrorLevel := 0
			}
			_subsections[_letter] := _subsection
		}
		_dispose(_sourceName) {
			this._table[_sourceName] := ""
			this._table.delete(_sourceName)
		}
		_disposeAll() {
			local
			for _name in this._table.clone()
				this._dispose(_name)
		}
		__Delete() {
			; MsgBox % A_ThisFunc
			if (this.learnWords)
				this.update()
			this._hapaxLegomena := ""
		}
		update() {
			; MsgBox, 16,, % this._exportPath
			if (this._exportPath <> "") {
				this.export(this._exportPath)
			}
		}
		export(_fileFullPath) {
			local
			try _fileObject:=FileOpen(_fileFullPath, 4+1, "UTF-8")
			catch
				return
			_listLines := A_ListLines
			ListLines, 0
			for _letter, _subsection in this._subsections {
				_fileObject.write(_subsection)
			}
			ListLines % _listLines
			_fileObject.close()
		}

		Class Word {
		Class _Match {
			isPending := {value: "", pos: 0, len: 0}
			isComplete := {value: "", pos: 0, len: 0}
		}
		_minLength := (this.minLength:=2)
		minLength {
			set {
			return (not ((value:=Floor(value)) > 0)) ? this._minLength : this._minLength:=value
			}
			get {
			return this._minLength
			}
		}
		_edgeKeys := (this.edgeKeys:="\/|?!,;.:(){}[]'""<>@=")
		edgeKeys {
			set {
				local
				_lastEdgeKeys := "", _edgeKeys := ""
				_listLines := A_ListLines
				ListLines, 0
				Loop, parse, % RegExReplace(value, "\s")
				{
					if (InStr(_lastEdgeKeys, A_LoopField))
						continue
					_lastEdgeKeys .= A_LoopField
					if A_LoopField in \,.,*,?,+,[,],{,},|,(,),^,$
						_edgeKeys .= "\" . A_LoopField
					else _edgeKeys .= A_LoopField
				}
				ListLines % _listLines
			return this._edgeKeys:=_edgeKeys
			}
			get {
			return this._edgeKeys
			}
		}
		test(_string, ByRef _wrapper:="") {
			local
			_isPending := "?P<isPending>[^\s" . this.edgeKeys . "]{" . this.minLength . ",}", _isComplete := "?P<isComplete>[\s" . this.edgeKeys . "]?"
			_pos := RegExMatch(_string, "`aOi)(" . _isPending . ")(" . _isComplete . ")$", _match)
			for _subPatternName, _subPatternObject in _wrapper := new this._Match()
				for _property in _subPatternObject, _o := _wrapper[_subPatternName]
					_o[_property] := _match[_property](_subPatternName)
			return _pos
		}
		}

		Class Query {
		static _maxMem := 10
		_history := [ StrSplit(StrReplace(Format("{:" this._maxMem-1 "}", ""), A_Space, A_Space), A_Space)* ]
		__New(_Word) {
			this._Word := _Word
			this._Sift := new this._SiftEx()
		}
		Word {
			set {
				throw Exception("The property is read only.", -1)
			; return this._Word
			}
			get {
			return this._Word
			}
		}
		Sift {
			set {
				throw Exception("The property is read only.", -1)
			; return this._Sift
			}
			get {
			return this._Sift
			}
		}
		test(_string, ByRef _wrapper:="") {
			local
			_edgeKeys := this.Word.edgeKeys
			_isPending := "?P<isPending>[^\s" . _edgeKeys . "]{" . this.Word.minLength . ",}", _isComplete := "?P<isComplete>[\s" . _edgeKeys . "]?"
			_pos := RegExMatch(_string, "`aOi)(" . _isPending . ")(" . _isComplete . ")$", _match)
			for _subPatternName, _subPatternObject in _wrapper := new this.Word._Match()
				for _property in _subPatternObject, _o := _wrapper[_subPatternName]
					_o[_property] := _match[_property](_subPatternName)
			return _pos, this._history.insertAt(1, _wrapper.isPending.value), this._history.pop()
		}
		; _minLength := (this.minLength:=2)
		; minLength {
			; set {
			; return (not ((value:=Floor(value)) > 0)) ? this._minLength : this._minLength:=value
			; }
			; get {
			; return this._minLength
			; }
		; }
		Class _SiftEx extends eAutocomplete._WordList.Query._Sift {
			caseSensitive {
				set {
					throw Exception("The property is read only.", -1)
				; return this.caseSensitive
				}
			}
			delimiter {
				set {
					throw Exception("The property is read only.", -1)
				; return this.delimiter
				}
			}
		}
		Class _Sift {
			_delimiter := "`n"
			delimiter {
				set {
				return this._delimiter:=value
				}
				get {
				return this._delimiter
				}
			}
			_caseSensitive := false
			_lastNeedle := ""
			caseSensitive {
				set {
				return this._caseSensitive:=!!value
				}
				get {
				return this._caseSensitive
				}
			}
			_option := (this.option:="LEFT")
			option {
				set {
					value := Trim(value)
					if not (value ~= "i)^(IN|LEFT|RIGHT|EXACT|REGEX|OC|OW|UW|UC)$") {
						throw Exception("Invalid option.", -1, value)
					; return this._option
					}
				return this._option:=value, this.needle := this._lastNeedle
				}
				get {
				return this._option
				}
			}
			needle {
				set {
					local
					this._lastNeedle := value
					if (this.option = "IN")
						_needle := "\Q" . value . "\E"
					else if (this.option = "LEFT")
						_needle := "^\Q" . value . "\E"
					else if (this.option = "RIGHT")
						_needle := "\Q" . value . "\E$"
					else if (this.option = "EXACT")
						_needle := "^\Q" . value . "\E$"
					else if (this.option = "REGEX")
						_needle := value
					else if (this.option = "OC")
						_needle := RegExReplace(value, "(.)", "\Q$1\E.*")
					else if (this.option = "OW")
						_needle := RegExReplace(value, "(" . A_Space . ")", "\Q$1\E.*")
					else if (this.option = "UW") {
						_needle := ""
						Loop, Parse, % value, % A_Space
							_needle .= "(?=.*\Q" . A_LoopField . "\E)"
					} else if (this.option = "UC") {
						_needle := ""
						Loop, Parse, % value
							_needle .= "(?=.*\Q" . A_LoopField . "\E)"
					}
				return this._needle:=_needle
				}
				get {
				return (this.caseSensitive) ? this._needle : "i)" . this._needle
				}
			}
			regex(ByRef _haystack, ByRef _sifted:="") {
				local
				_delimiter := this.delimiter, _needle := this.needle, _sifted := ""
				_batchLines := A_BatchLines
				SetBatchLines, -1
				_listLines := A_ListLines
				ListLines, 0
				Loop, Parse, % _haystack, % _delimiter
				{
					if (RegExMatch(A_LoopField, _needle))
						_sifted .= A_LoopField . _delimiter
				}
				ListLines % _listLines
				SetBatchLines % _batchLines
				_sifted := SubStr(_sifted, 1, -1)
			}
		}
	}

		_current {
			set {
				if not (this.hasSource(value)) {
					throw Exception("The word list does not exist.", -1, value)
				; return this._current
				}
				this.__Delete()
			return this._current, eAutocomplete._WordList._current_:=value
			}
			get {
			return this.getSource(eAutocomplete._WordList._current_)
			}
		}
		buildFromVar(_sourceName, _list:="", _exportPath:="", _caseSensitive:=false) {
			local
			try _wordList := this.setFromVar(_sourceName, _list, _exportPath, _caseSensitive, false, true)
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			}
		return _wordList, _wordList.update()
		}
		buildFromFile(_sourceName, _fileFullPath, _exportPath:="", _caseSensitive:=false) {
			local
			((_exportPath = -1) && _exportPath:=_fileFullPath)
			try _wordList := this.setFromFile(_sourceName, _fileFullPath, _exportPath, _caseSensitive, false, true)
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			}
		return _wordList, _wordList.update()
		}
		setFromVar(_sourceName, _list:="", _exportPath:="", _caseSensitive:=false, _autoSort_:=false, _format_:=false) {
			local
			try {
				_wordList := new this(_sourceName, _caseSensitive, _autoSort_)
				_wordList._build("", _list, _format_, _exportPath)
			} catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			}
			return _wordList
		}
		setFromFile(_sourceName, _fileFullPath, _exportPath:="", _caseSensitive:=false, _autoSort_:=false, _format_:=false) {
			local
			try {
				((_exportPath = -1) && _exportPath:=_fileFullPath)
				_wordList := new this(_sourceName, _caseSensitive, _autoSort_)
				_wordList._build(_fileFullPath,, _format_, _exportPath)
			} catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			}
			return _wordList
		}

		_Init() {
			static _ := eAutocomplete._WordList._Init()
			new this("",,, true)
		}

	}

	Class _Window {
		move(_x, _y) {
			static SWP_NOSIZE := 0x0001
			static SWP_NOZORDER := 0x0004
			static SWP_NOACTIVATE := 0x0010
			static _uFlags := (SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE)
			DllCall("User32.dll\SetWindowPos", "Ptr", this.GUIID, "Ptr", 0, "Int", _x, "Int", _y, "Int", 0, "Int", 0, "UInt", _uFlags)
		}
		resize(_w, _h) {
			static SWP_NOMOVE := 0x0002
			static SWP_NOZORDER := 0x0004
			static SWP_NOACTIVATE := 0x0010
			static _uFlags := (SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE)
			DllCall("User32.dll\SetWindowPos", "Ptr", this.GUIID, "Ptr", 0, "Int", 0, "Int", 0, "Int", _w, "Int", _h, "UInt", _uFlags)
		}
		isVisible() {
		return DllCall("IsWindowVisible", "Ptr", this.GUIID)
		}
		_transparency := 255
		transparency {
			set {
				local
				_detectHiddenWindows := A_DetectHiddenWindows
				DetectHiddenWindows, On
				if value between 10 and 255
					WinSet, Transparent, % this._transparency:=value, % "ahk_id " . this.GUIID
				DetectHiddenWindows % _detectHiddenWindows
			return this.transparency
			}
			get {
			return this._transparency
			}
		}
		Class GUIControl {
		__New(_GUIID) {
			this._hHost := _GUIID
		}
		owner {
			get {
				static GA_ROOTOWNER := 3
			return DllCall("User32.dll\GetAncestor", "Ptr", this._hHost, "UInt", GA_ROOTOWNER, "Ptr")
			}
		}
		getPos(ByRef _x:="", ByRef _y:="") {
			WinGetPos, _x, _y,,, % "ahk_id " . this.HWND
		}
		font {
			get {
			return new this.FontWrapper(this.HWND)
			}
			set {
			return this.font
			}
		}
		Class FontWrapper {
			__New(_hControl) {
				static GA_ROOT := 2
				this.hControl := _hControl
				; this.GUIID := DllCall("User32.dll\GetAncestor", "Ptr", _hControl, "UInt", GA_ROOT, "Ptr")
				this.GUIID := DllCall("User32.dll\GetParent", "Ptr", _hControl, "Ptr")
				this.handle := this._getHandle()
			}
			_getHandle() {
				static WM_GETFONT := 0x31
				this.hDC := DllCall("User32.dll\GetDC", "Ptr", this.hControl, "Ptr")
				SendMessage, WM_GETFONT, 0, 0,, % "ahk_id " . this.hControl
			return DllCall("Gdi32.dll\SelectObject", "Ptr", this.hDC, "Ptr", ErrorLevel, "Ptr")
			}
			__Delete() {
				this._releaseHandle()
				; MsgBox, 16,, % A_ThisFunc
				; if not (this._releaseHandle())
					; MsgBox, 64,, Failed to release the font.
			}
			_releaseHandle() {
				if (this.handle) {
					DllCall("Gdi32.dll\SelectObject", "Ptr", this.hDC, "Ptr", this.handle, "Ptr")
				return DllCall("User32.dll\ReleaseDC", "Ptr", this.hControl, "Ptr", this.hDC)
				}
			}
			getTextExtentPoint(_text, ByRef _w:="", ByRef _h:="") {
				local
				_size := "", DllCall("Gdi32.dll\GetTextExtentPoint32", "UPtr", this.hDC, "Str", _text, "Int", StrLen(_text), "Int64P", _size)
				(IsByref(_w) && _w := _size &= 0xFFFFFFFF), (IsByref(_h) && _h := >> 32 & 0xFFFFFFFF)
			}
			color {
				set {
					try GUI % this.GUIID . ":Font", % "c" . value
					GuiControl, Font, % this.hControl
				return this.color
				}
				get { ; ~
				; return Format("{1:06X}", DllCall("Gdi32.dll\GetTextColor", "Ptr", this.hDC)) ; http://forum.script-coding.com/viewtopic.php?id=13256 [Сохранить скриншот в файл]
				return ""
				}
			}
			name {
				set {
					try GUI % this.GUIID . ":Font",, % value
					GuiControl, Font, % this.hControl
					this._releaseHandle(), this._getHandle()
				return this.name
				}
				get {
					local
					VarSetCapacity(_lpName, 40)
					DllCall("Gdi32.dll\GetTextFace", "Ptr", this.hDC, "UInt", 40, "Str", _lpName)
				return _lpName
				}
			}
			size {
				set {
					try GUI % this.GUIID . ":Font", % "s" . value
					GuiControl, Font, % this.hControl
					this._releaseHandle(), this._getHandle()
				return this._size:=value
				}
				get { ; ~
				return ""
				}
			}
		}
	}
		Class Text extends eAutocomplete._Window.GUIControl {
		__New(_GUIID, _x, _y) {
			local
			base.__New(_GUIID)
			GUI % this._hHost . ":Add", Text, % "hwnd_hText x" _x . " y" . _y,
			this.HWND := _hText
		}
		__Delete() {
		; MsgBox % A_ThisFunc
		}
	}
	}

	Class _BaseMenu extends eAutocomplete._Window {

		__New() {
			local
			static WS_EX_WINDOWEDGE := 0x00000100
			static WS_EX_TOOLWINDOW := 0x00000080
			static WS_EX_TOPMOST := 0x00000008
			static WS_EX_PALETTEWINDOW := (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)
			static WS_EX_NOACTIVATE := 0x08000000
			static WM_MOUSEACTIVATE := 0x0021
			; static WM_NCLBUTTONDOWN := 0x00A1
			_hLastFoundWindow := WinExist()
			_GUI := A_DefaultGUI
			GUI, New
			GUI +hwnd_GUIID
			GUI, +ToolWindow -Caption -SysMenu +AlwaysOnTop ; +Caption
			GUI, +E%WS_EX_PALETTEWINDOW% +E%WS_EX_NOACTIVATE%
			this.GUIID := _GUIID
			GUI, Margin, 0, 0
			GUI, %_GUI%:Default
			WinExist("ahk_id " . _hLastFoundWindow)
			this.canvas := new this.Text(this.GUIID, 0, 0)
			this.fn := ObjBindMethod(this, "WM_MOUSEACTIVATE")
			; OnMessage(WM_NCLBUTTONDOWN, this.fn, -1)
			OnMessage(WM_MOUSEACTIVATE, this.fn, -1)
		}
		_dispose() {
			static WM_MOUSEACTIVATE := 0x0021
			; static WM_NCLBUTTONDOWN := 0x00A1
			; OnMessage(WM_NCLBUTTONDOWN, this.fn, 0)
			OnMessage(WM_MOUSEACTIVATE, this.fn, this.fn:=0)
			this.canvas := ""
		}
		__Delete() {
			; MsgBox % A_ThisFunc
		}
		_bkColor := 0xF0F0F0
		bkColor {
			set {
				try GUI % this.GUIID . ":Color", % this._bkColor:=value, % value ; /GuiControl +BackgroundFF9977, MyListView
			return this.bkColor
			}
			get { ; ~
			return ""
			; return this._bkColor
				; local
				; static WM_CTLCOLORSTATIC := 0x138
				; _hCanvas := this.canvas.HWND
				; _hDC := DllCall("GetDC", "Ptr", _hCanvas, "Ptr")
				; SendMessage % WM_CTLCOLORSTATIC, % _hDC, % _hCanvas,, % "ahk_id " . this.GUIID
				; _color := DllCall("GetBkColor", "Ptr", _hDC)
				; DllCall("ReleaseDC", "Ptr", _hCanvas, "Ptr", _hDC)
				; _red:= (_color & 0xFF0000) >> 16, _green := (_color & 0x00FF00) >> 8, _blue:= (_color & 0xFF)
			; return Format("0x{:x}", (_blue << 16) + (_green << 8) + _red)
			}
		}
		show(_option) {
			GUI % this.GUIID . ":Show", % "NA " . _option
		}
		hide() {
			this.show("Hide")
		}
		WM_MOUSEACTIVATE(_wParam, _lParam, _uMsg, _hWnd) {
			static MA_NOACTIVATEANDEAT := 4
			Critical
			if (_wParam = this.GUIID)
				return MA_NOACTIVATEANDEAT
		}
		; #Include %A_LineFile%\..\_Menu.Text.ahk
	}

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

	Class BasicControlList extends eAutocomplete._Window.GUIControl {
	_MAXITEMS := 52
	_list := ""
	itemCount := 0
	_delimiter := "|"
	_maxVisibleItems := 5
	__New(_GUIID) {
		base.__New(_GUIID)
		this.delimiter := this.delimiter
		this.maxVisibleItems := this.maxVisibleItems
	}
	delimiter { ; to do: protected
		set {
			GUI % this._hHost . ":+Delimiter" . this._delimiter:=value:=RegExReplace(value, "^(Space|Tab|.)\K.*", "")
		return this._delimiter
		}
		get {
		return this._delimiter
		}
	}
	maxVisibleItems {
		set {
			if ((1 <= value) && (value <= this._MAXITEMS))
				return this._maxVisibleItems:=Floor(value)
			else return this._maxVisibleItems
		}
		get {
		return this._maxVisibleItems
		}
	}
	hasVScrollBar {
		get {
		return (this.itemCount > this.maxVisibleItems)
		}
		set {
		return this.hasVScrollBar
		}
	}
	getIdealWidth(_list) {
		local
		_widthBuffer := _w := 0
		_listLines := A_ListLines
		ListLines, 0
		_font := this.font
		for _index, _loopField in StrSplit(_list, this.delimiter,, -1)
		{
			_font.getTextExtentPoint(_loopField, _w)
			_w &= 0xFFFFFFFF, ((_w > _widthBuffer) && _widthBuffer:=_w)

		}
		ListLines % _listLines
	return _widthBuffer, (_widthBuffer && _widthBuffer += 8)
	}
	autoWH() {
		local
		this._Resizing.getDim(_w, _h, this._list)
		(this.hasVScrollBar) ? _h -= (this.itemCount - this.maxVisibleItems) * this.itemHeight
		this.resize(_w, _h)
	}
	__click() {
		local
		static EAT := 1
		_item := this.getItemFromPointer()
		if (_item > -1)
			return EAT, this.__itemClick(++_item)
		return not EAT
	}
	getItemFromPointer() {
	return -1
	}
	__itemClick(_item) {
	}
	_dispose() {
		this._Resizing := ""
	}
	itemHeight {
		set {
		return 0
		}
		get {
		return 0
		}
	}
	_resizingStrategy := "Menu"
	resizingStrategy {
		set {
			local
			for _strategy in this.DimStrategies {
				if ((_strategy = value) && (_strategy <> "__Class")) {
					_dimStrategy := this.DimStrategies[value], this._Resizing := new _dimStrategy(this._hHost, this)
				return this._resizingStrategy:=value
				}
			}
			throw Exception("The resizing strategy is not available.", -1, value)
		; return this._resizingStrategy
		}
		get {
		return this._resizingStrategy
		}
	}
	Class DimStrategies {
		Class DropDownList {
			__New(_hHost, _control) {
				this._parent := DllCall("User32.dll\GetParent", "Ptr", _hHost, "Ptr")
				this._itemsBox := _control
			}
			getDim(ByRef _w:="", ByRef _h:="", _list:="") {
				local
				static SM_CYHSCROLL := DllCall("GetSystemMetrics", "UInt", 3)
				_itemsBox := this._itemsBox
				_wIdeal := _itemsBox.getIdealWidth(_list)
				ControlGetPos,,, _w,,, % "ahk_id " . this._parent
				_h := (_itemsBox.itemCount + 1) * _itemsBox.itemHeight + (_wIdeal > _w) * SM_CYHSCROLL
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
			}
		}
		Class Menu {
			__New(_hHost, _control) {
				this._itemsBox := _control
			}
			getDim(ByRef _w:="", ByRef _h:="", _list:="") {
				static SM_CXVSCROLL := DllCall("GetSystemMetrics", "UInt", 2)
				local
				_itemsBox := this._itemsBox
				_w := _itemsBox.getIdealWidth(_list) + _itemsBox.hasVScrollBar * SM_CXVSCROLL
				_h := (_itemsBox.itemCount + 1) * _itemsBox.itemHeight
			}
			__Delete() {
				; ; MsgBox % A_ThisFunc
			}
		}
	}
}

	Class ListBox extends eAutocomplete._Menu.BasicControlList {
	__New(_GUIID, _x, _y) {
		local
		base.__New(_GUIID)
		GUI % this._hHost . ":Add", ListBox, % "-Sort -Multi -HScroll +VScroll hwnd_hListBox x" _x . " y" . _y,
		this.HWND := _hListBox
		this.selection := new this.SelectionWrapper(this.HWND)
		_font := this._font := new this.FontWrapper(this.HWND)
		_font.name := "Segoe UI", _font.size := 12, _font.color := "000000"
	}
	font {
		set {
		return this.font
		}
		get {
		return this._font
		}
	}
	_onItemClick := ""
	onItemClick {
		set {
			if (IsFunc(value)) {
				this._onItemClick := StrLen(value) ? Func(value) : value
			} else if (IsObject(value)) {
				this._onItemClick := value
			} else this._onItemClick := ""
		return this._onItemClick
		}
		get {
		return this._onItemClick
		}
	}
	_dispose() {
		sleep, 1
		base._dispose()
		this._font := ""
		this.onItemClick := ""
		this.selection._dispose()
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	resize(_w, _h) {
		GuiControl, Move, % this.HWND, % Format("w{} h{}", _w, _h)
	}
	getPos(ByRef _x:="", ByRef _y:="") {
		WinGetPos, _x, _y,,, % "ahk_id " . this.HWND
	}
	setlist(_list) {
		local
		_delimiter := this.delimiter
		_list := Trim(_list, _delimiter), _count := 0
		if (_list <> "") {
			_threshold := this._MAXITEMS
			StrReplace(_list, _delimiter,, _count)
			if (++_count > _threshold) {
				_count := _threshold, _list := SubStr(_list, 1, InStr(_list, _delimiter,,, ++_threshold) - 1)
			}
		}
		this.itemCount := _count
		GuiControl, -Redraw, % this.HWND
		GuiControl,, % this.HWND, % _delimiter . this._list:=_list
		GuiControl, +Redraw, % this.HWND
		; ((this.itemCount := _count) && this.selection.index:=1) ; <<<<
	}
	getItemFromPointer() {
		local
		static LB_ITEMFROMPOINT := 0x01A9
		; if not (DllCall("IsWindowVisible", "Ptr", this.HWND))
			; return -1
		VarSetCapacity(_POINT_, 8, 0)
		DllCall("GetCursorPos", "Ptr", &_POINT_)
		DllCall("ScreenToClient", "Ptr", this.HWND, "Ptr", &_POINT_)
		_x := NumGet(_POINT_, 0, "UShort"), _y := NumGet(_POINT_, 4, "UShort") << 16
		SendMessage % LB_ITEMFROMPOINT, 0, % (_x + _y),, % "ahk_id " . this.HWND
	return (ErrorLevel & 0xFFFF0000) ? -1 : (ErrorLevel & 0xFFFF)
	}
	_itemClickHandler() {
		local
		KeyWait, LButton, T0.65
		_e := ErrorLevel
		if (DllCall("IsWindowVisible", "Ptr", this.HWND))
			((_onItemClick:=this.onItemClick) && _onItemClick.call(this.selection.text, _e))
	}
	__itemClick(_itemIndex:="") {
		local
		(this.selection.index:=_itemIndex)
		_fn := this._itemClickHandler.bind(this)
		SetTimer % _fn, -1
	}
	itemHeight {
		get {
			static LB_GETITEMHEIGHT := 0x1A1
			SendMessage % LB_GETITEMHEIGHT, 0, 0,, % "ahk_id " . this.HWND
		return ErrorLevel
		}
		set {
		return this.itemHeight
		}
	}
	selectPrevious() {
	this.selection.previousItem()
	}
	selectNext() {
	this.selection.nextItem()
	}
	Class SelectionWrapper {
		__New(_parent) {
			local
			this._parent := _parent
			; _fn := this.__index.bind(this)
			; GuiControl, +g, % _parent, % _fn
		}
		_dispose() {
			; GuiControl, -g, % this._parent,
		}
		__index(_hControl, _GUIEvent, _eventInfo, _errorLevel:="") {
		; ...
		}
		itemCount {
			get {
				static LB_GETCOUNT := 0x18B
				SendMessage % LB_GETCOUNT, 0, 0,, % "ahk_id " . this._parent
			return ErrorLevel
			}
			set {
			return this.itemCount
			}
		}
		previousItem() {
			local
			_index := this.index - 1
			this.index := (_index < 1) ? this.itemCount : _index
		}
		nextItem() {
			local
			_index := this.index + 1
			this.index := (_index > this.itemCount) ? 1 : _index
		}
		isVisible() {
		return DllCall("IsWindowVisible", "Ptr", this._parent)
		}
		index {
			set {
				static LB_SETCURSEL := 0x0186
				if ((value+0 <> "") && value <> this.index)
					SendMessage % LB_SETCURSEL, % --value, 0,, % "ahk_id " . this._parent
			return this.index
			}
			get {
				local
				static LB_GETCURSEL := 0x188
				SendMessage, 0x188, 0, 0,, % "ahk_id " . this._parent
				_pos := ErrorLevel << 32 >> 32
			return ++_pos
			}
		}
		text {
			get {
				local
				ControlGet, _item, Choice,,, % "ahk_id " . this._parent
			return _item
			}
			set {
			return this.text
			}
		}
		offsetTop {
			get {
				static LB_GETTOPINDEX := 0x018E
				SendMessage % LB_GETTOPINDEX, 0, 0,, % "ahk_id " . this._parent
				_e := ErrorLevel
				return this.index - _e
			}
			set {
			return this.offsetTop
			}
		}
	}
}

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

}

	Class _FunctorEx extends eAutocomplete._FunctorEx._Proxy {
	call(_args*) {
		return base.call(_args*)
	}
	Class _Functor {
		static instances := {}
		__Call(_newEnum, _args*) {
			local
			if (IsObject(_newEnum)) {
				if (!_args.count())
					throw Exception("Invalid call.")
				__class := StrSplit(this.__Class, ".").pop()
				if not (_newEnum.hasKey(__class) || _newEnum.base.hasKey(__class))
					throw Exception("Invalid call.")
			return this.call(_args*)
			}
		}
	}
	Class _Proxy extends eAutocomplete._FunctorEx._Functor {
		test(_root, _maxParams, _k, _arg, _args*) {
			local _instances, __Class, _count, _inst, _arg_, _args_
			_instances := _root.instances, __class := StrSplit(this.__Class, ".").pop()
			if not (_instances.hasKey(__Class))
				_instances[__class] := {}
			_instances := _instances[__class], _count := _args.count()
			if not (_instances.hasKey(_k)) {
				if (_count = _maxParams - 2)
					_instances[_k] := {}
				else throw Exception("Invalid call.")
			} else if (_count <= _maxParams - 2) {
				if (!_count && (_arg = "")) {
					_instances[_k] := ""
					return "", _instances.delete(_k)
				} else if (_count = _maxParams - 3) {
					return _instances[_k, _arg]
				} else if not (_count = _maxParams - 2)
					throw Exception("Invalid call.")
			} else throw Exception("Invalid call.")
			_arg_ := _arg, _args_ := _args.clone()
			_instances := _instances[_k]
			_args_.insertAt(1, _arg_)
			Loop % _count {
				(IsObject(_instances[_arg_:=_args_.removeAt(1)]) || _instances[_arg_]:={})
				if (--_count)
					_instances := _instances[_arg_]
			}
			_instances[_arg_] := ""
		return _instances[_arg_] := new this(_k, _arg, _args*)
		}
		call(_k, _arg, _args*) {
			local base, _obj, _depth, _classPath, _className, _root
			_obj := this, _depth := 0
			while(_obj.base.__Class) {
				++_depth, _obj := _obj.base
			}
			_classPath := StrSplit(_obj.__Class, ".")
			_className := _classPath.removeAt(1)
			_root := %_className%[_classPath*]
			_obj := this
			while(_obj.base.base.base.base.__Class) {
				_obj := _obj.base
			}
			return this.test(_root, Func(_obj.__Class . ".__New").maxParams - 1, _k, _arg, _args*)
		}
	}
}

	__New() {
		local _classPath, _className
		static _init := -1
		switch _init
		{
			case -1:
				_classPath := StrSplit(this.base.__Class, "."), _className := _classPath.removeAt(1)
				if (_classPath.count() > 0)
					%_className%[_classPath*] := this
				else %_className% := this
			case 0:
				this._Init()
			Default:
				throw Exception(this.__Class . " is at its root designed as a super global automatically initialized singleton. Could not create the new instance.", -1)
		}
		if not (++_init)
			%A_ThisFunc%(this)
	}

	Class _EventObject extends eAutocomplete._FunctorEx {
		__New(_source, _eventName, _callback) {
			this.source := _source, this.eventName := _eventName
			this.setCallback(_callback)
		}
		setCallback(_callback) {
			if (_callback = "") {
				this.source[ this.eventName ] := ""
			} else if (IsFunc(_callback)) {
				_callback := StrLen(_callback) ? Func(_callback) : _callback
				this.source[ this.eventName ] := _callback
			} else if (IsObject(_callback)) {
				this.source[ this.eventName ] := _callback
			} else throw Exception("Invalid callback.", -1)
		}
		unregister() {
			this.setCallback("")
		}
		__Delete() {
			; MsgBox % A_ThisFunc
			this.unregister()
		}
	}
	Class _OnEvent extends eAutocomplete._EventObject {
		call(_fn) {
			local base, _classPath, _className, _cb, _r, _exception
			_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1), _cb := _classPath.pop()
			try _r := base.call((_classPath.count() > 0) ? %_className%[_classPath*] : %_className%, this._getCallbackName(_cb), _fn)
			catch _exception {
				throw Exception(_exception.message, -2)
			}
		return _r
		}
		_getCallbackName(_callee) {
		return "_" . _callee
		}
		__Delete() {
			; MsgBox % A_ThisFunc
			base.__Delete()
		}
	}

	Class OnComplete extends eAutocomplete._OnEvent {
	}
	Class OnReplacement extends eAutocomplete._OnEvent {
	}
	Class OnSuggestionLookUp extends eAutocomplete._OnEvent {
	}

	Class _Hotkey extends eAutocomplete._FunctorEx {
	__New(_hkIfFn, _keyName, _fn) {
		local
		if not (StrLen(Trim(_keyName))) {
			throw Exception("Invalid key name", -1)
		; return
		}
		this.ifFn := _hkIfFn, this.keyName := _keyName, this.fn := _fn
		RegExMatch(_keyName, "i)(\w+|.)(?:[ `t]Up)?$", _match)
		this.key := _match1
		Hotkey, If, % _hkIfFn
			_f := this.keyPressHandler.bind("", this.fn)
			Hotkey % _keyName, % _f, On T1 I0 B0
		Hotkey, If
	}
	keyPressHandler(_fn) {
		static _ongoing := false
		if (_ongoing)
			Exit
		_ongoing := true, %_fn%(), _ongoing := false
	}
	unregister() {
		local
		static _f := Func("WinActive")
		_hkIfFn := this.ifFn
		Hotkey, If, % _hkIfFn
			Hotkey % this.keyName, % _f, Off
		Hotkey, If
		this.fn := ""
	}
	__Delete() {
		; MsgBox % A_ThisFunc
		this.unregister()
	}
}
	Class _LongPressHotkey extends eAutocomplete._Hotkey {
		__New(_hkIfFn, _keyName, _fn) {
			local
			base.__New(_hkIfFn, _keyName, Func("WinActive"))
			_fn := new this._KeyPressHandler_(this.key, 0.65, _fn)
			base.__New(_hkIfFn, _keyName, _fn)
		}
		Class _KeyPressHandler_ {
			__New(_key, _timeout, _fn) {
				local
				if not (IsObject(_fn) || _fn:=Func(_fn)) {
					throw Exception("Invalid callback.", -1)
				; return
				}
				this.key := _key, this.timeout := _timeout
				this._fn := _fn
			}
			; __Delete() {
				; ; MsgBox % A_ThisFunc
			; }
			__Call(_callee, _args*) {
				local
				if (_callee = "") {
					(_fn:=this._fn, %_fn%(-1, _args*))
					this.keyWaitTimeout()
					_e := ErrorLevel
					this.keyWait()
					%_fn%(_e, _args*)
				}
			}
			keyWaitTimeout() {
				KeyWait % this.key, % "T" . this.timeout
			}
			keyWait() {
				KeyWait % this.key
			}
		}
	}

	Class _Hotkeys extends eAutocomplete._FunctorEx._Functor {
		Class _ShouldFire {
			hook := Func("StrLen")
			invokeKey := ""
			call(_hotkey) {
			return this.hook.call(_hotkey, (_hotkey = this.invokeKey))
			}
		}
		call(_base, _keyName, _expLevel_:=-1) {
			local _classPath, _count, _className, _target, _method, _exception, _r
			_classPath := StrSplit(this.__Class, ".")
			StrReplace(A_ThisFunc, ".", "", _count)
			_classPath.removeAt(_count)
			_className := _classPath.removeAt(1)
			_method := _classPath.pop()
			_target := %_className%
			; _target := %_className%[_classPath*]
			while (_classPath.count()) {
				_target := _target[_classPath.removeAt(1)]
			}
			try _r := _base.call(eAutocomplete._Hotkeys._ShouldFire, _keyName, _target[_method].bind(_target))
			catch _exception {
				throw Exception(_exception.message, _expLevel_, _exception.extra)
			}
		return _r
		}
		Class _ProxyN extends eAutocomplete._Hotkeys {
			call(_keyName, _expLevel_:=-3) {
			static _lastKeys := {}
			if (_keyName = "") {
				if (_lastKeys.hasKey(this.__Class))
					eAutocomplete._Hotkey(eAutocomplete._Hotkeys._ShouldFire, _lastKeys[ this.__Class ]).unregister()
			return ""
			}
			base.call(eAutocomplete._Hotkey, _keyName, _expLevel_)
			return "", _lastKeys[ this.__Class ] := _keyName
			}
		}
		Class _ProxyL extends eAutocomplete._Hotkeys {
			call(_keyName, _expLevel_:=-3) {
			static _lastKeys := {}
			if (_keyName = "") {
				if (_lastKeys.hasKey(this.__Class))
					eAutocomplete._LongPressHotkey(eAutocomplete._Hotkeys._ShouldFire, _lastKeys[ this.__Class ]).unregister()
			return ""
			}
			base.call(eAutocomplete._LongPressHotkey, _keyName, _expLevel_)
			return "", _lastKeys[ this.__Class ] := _keyName
			}
		}
		Class _ProxyI extends eAutocomplete._Hotkeys._ProxyN {
			call(_keyName) {
				local base
				base.call(_keyName, -4)
			return "", eAutocomplete._Hotkeys._ShouldFire.invokeKey := _keyName
			}
		}
	}
	__keyPress__(_hotkey, _invokeMenu) {
		if (GetKeyState("LButton", "P"))
			return false
		if (_invokeMenu)
			return (!this.Menu.isVisible() && this._shouldTrigger() && !this.Menu.disabled && this.Menu.itemsBox.itemCount)
		if (this.disabled || !this.Menu.isAvailable())
			return false
		else if (this.Menu.isVisible())
			return !this.Menu.disabled
	}
	Class Hotkey extends eAutocomplete._Hotkeys {
		Class LookUpSuggestion extends eAutocomplete._Hotkeys._ProxyN {
		}
		Class complete extends eAutocomplete._Hotkeys._ProxyL {
		}
		Class completeAndGoToNewLine extends eAutocomplete._Hotkeys._ProxyL {
		}
		Class invokeMenu extends eAutocomplete._Hotkeys._ProxyI {
		}
		Class Menu {
			Class hide extends eAutocomplete._Hotkeys._ProxyN {
			}
			Class ItemsBox {
				Class selectPrevious extends eAutocomplete._Hotkeys._ProxyN {
				}
				Class selectNext extends eAutocomplete._Hotkeys._ProxyN {
				}
				Class __selection extends eAutocomplete._Hotkeys._ProxyN {
				}
			}
		}
	}

	_Init() {
		local
		_HostControlWrapper := this._HostControlWrapper := new this._HostControlWrapper()
		_HostControlWrapper.__focus := this.__focus__.bind(this)
		_HostControlWrapper.__value := this.__value__.bind(this)
		this._completor := new _HostControlWrapper.Complete(_HostControlWrapper)
		this._completor.onEvent := this.__complete__.bind(this)
		_Menu := this._Menu := new this._Menu()
		_Menu.itemsBox.onItemClick := this._complete.bind(this)
		_Menu.InfoTip.onInvoke := this._infoTipInvocationHandler.bind(this)
		this.OnComplete(this.__complete.bind(this))
		this.OnReplacement(this.__remplacement.bind(this))
		this.OnSuggestionLookUp(this.__suggestionLookUp.bind(this))
		_HostControlWrapper.notify := true
		_Hotkey := this.Hotkey
		_Hotkey._ShouldFire.hook := this.__keyPress__.bind(this)
		_Hotkey.Menu.hide("+Esc")
		_Hotkey.Menu.itemsBox.selectPrevious("Up")
		_Hotkey.Menu.itemsBox.selectNext("Down")
		_Hotkey.complete("Tab")
		_Hotkey.completeAndGoToNewLine("Enter")
		_Hotkey.lookUpSuggestion("Right")
		_Hotkey.invokeMenu("^+Down")
		OnExit(this._Release.bind(this))
	}
	_Release() {
		this.disabled := true
		try {
			this.unwrapAll()
			this.OnComplete("")
			this.OnReplacement("")
			this.OnSuggestionLookUp("")
			this.Completor.onEvent := ""
			this._HostControlWrapper._dispose()
			this._Hotkey(this.Hotkey._ShouldFire, "")
			this._LongPressHotkey(this.Hotkey._ShouldFire, "")
			this.Menu._dispose()
			this.WordList._disposeAll()
			this.Hotkey._ShouldFire.hook := ""
			; this._HostControlWrapper := ""
			; this._Menu := ""
		}
		this.remove("", Chr(255))
	return 0
	}
	__Version {
		get {
			static __Version := ("2.0.0-beta", new eAutocomplete())
		return __Version
		}
		set {
		return this.__Version
		}
	}
}


