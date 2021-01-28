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
