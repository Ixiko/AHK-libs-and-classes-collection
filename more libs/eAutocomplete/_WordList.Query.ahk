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
