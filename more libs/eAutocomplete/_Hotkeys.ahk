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
