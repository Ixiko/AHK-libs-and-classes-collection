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
	#Include %A_LineFile%\..\_WordList.Word.ahk
	#Include %A_LineFile%\..\_WordList.Query.ahk
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
