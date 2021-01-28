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
