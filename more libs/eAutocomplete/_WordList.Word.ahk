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
