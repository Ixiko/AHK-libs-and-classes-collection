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