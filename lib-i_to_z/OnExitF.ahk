OnExitF(fn:="", prms*) {
	; Prepend w/ '_' to make sure it gets freed first.
	; Variables containing object references are freed alphabetically.
	static _dummy
	static handler := { __Delete: Func("OnExitF") }
	static oef := {}

	; called by __Delete
	if (IsObject(fn) && fn.base == handler) {
		if !(exit_sub := oef.Remove("fn"))
			return
		return %exit_sub%(oef.prms*)
	}

	if (fn == "") { ; disable, return script to normal behavior
		oef.Remove("prms")
		return oef.Remove("fn").Name
	}

	if !IsFunc(fn)
		return false
	oef.fn := IsObject(fn) ? fn : Func(fn)
	oef.prms := prms
	if !_dummy
		_dummy := new handler
	return true
}