class Object {

	class Ini {
		stFileName := ""
		section := {}

		__new(pstFileName) {
			this.stFileName := pstFileName
			return this
		}

		write(pstSection, pstKey, pValue) {
			_curValue := this.section[pstSection, pstKey]
			this.section[pstSection, pstKey] := pValue
			return _curValue
		}

		read(pstSection, pstKey) {
			return this.section[pstSection, pstKey]
		}

		save() {
			_file := FileOpen(this.stFileName, "w")
			_file.writeLine("# " A_Now)

			for _section, _entry in this.section {
				_file.writeLine("[" _section "]")
				for _key, _value in _entry {
					_file.writeLine((_key != "" ? _key "=" _value : " "))
				}
			}

			_file.close()

			return this
		}

		load() {
			_file := FileOpen(this.stFileName, "r")

			this.section := {}

			_section := ""
			while (!_file.atEOF()) {
				_line := _file.readLine()
				if (RegExMatch(_line, "^#.*$")) {
					continue
				}
				if (RegExMatch(_line, "^\[(.*)\]", $)) {
					this.section[$1] := {}
					_section := $1
					continue
				}
				if (RegExMatch(_line, "^(.+?)=(.*?)\s*$", $)) {
					this.section[_section, $1] := $2
					continue
				}
			}

			_file.close()

			return this
		}
	}

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' is not allowed")
	}

	serialize(po, pstIniFileName) {
		_ini := new Object.Ini(pstIniFileName)

		if (po.__Class != "") {
			_ini.write("__Class", "__Class", po.__Class)
		}

		object_Serialize(po, _ini)

		_ini.save()
	}

	deserialize(pstIniFileName) {
		_ini := new Object.Ini(pstIniFileName)
		_ini.load()

		IniRead _type, %pstIniFileName%, __Class, __Class, *SIMPLE_OBJECT*

		if (_type == "*SIMPLE_OBJECT*") {
			_obj := Object()
			_obj := object_Deserialize(_obj, _ini.section)
		} else {
			_obj := new %_type%()
			_obj := object_Deserialize(_obj, _ini.section)
		}

		return _obj
	}

	instanceOf(po, pstrClassName) {
		loop {
			if (po.__Class = pstrClassName || po.base.__Class = pstrClassName) {
				return true
			}
			if (IsObject(po.base)) {
				po := po.base
			} else {
				break
			}
		}
		return false
	}

	compare(poFirst, poSecond) {
		o1 := poFirst.clone()
		o2 := poSecond.clone()
		_keys := []
		for _key, _value in o1 {
			_keys.push(_key)
		}
		for _i, _key in _keys {
			if (o1[_key] != o2[_key]) {
				return false
			}
			o1.remove(_key)
			o2.remove(_key)
		}
		for _key, _value in o2 {
			return false
		}
		return true
	}
}

object_Serialize(poObject, poIni, pstId="") {
	if (!IsObject(poObject)) {
		throw Exception("The given variable does not contain an object"
				, -1, poObject)
	}
	if (poObject.base) {
		object_Serialize(poObject.base, poIni, pstId)
	}
	if (poObject.getCapacity() = 0) {
		poIni.write(pstId, "", "")
		return poObject
	}
	for _key, _value in poObject {
		if (_value.minIndex() != "" && _value.maxIndex() != "") {
			object_Serialize(_value, poIni, (pstId != "" ? pstId "." : "") _key)
		} else if (IsObject(_value)) {
			object_Serialize(_value, poIni, (pstId != "" ? pstId "." : "") _key)
		} else {
			if (_key != "__class") {
				_value := StrReplace(_value, "`n", "``n")
				poIni.write(pstId, _key, _value)
			}
		}
	}

	return poObject
}

object_Deserialize(poObject, poData, pstId="") {

	for _key, _value in poData {
		; OutputDebug ### %_key% = %_value% / %pstId%
		if (IsObject(_value)) {
			objs := StrSplit(_key, ".")
			o := poObject
			loop % objs.maxIndex() {
				if (!IsObject(o[objs[A_Index]])) {
					o[objs[A_Index]] := {}
				}
				o := o[objs[A_Index]]
			}
			object_Deserialize(poObject, _value
					, (pstId != "" ? pstId "." : "") _key)
		} else if (_key != "__class") {
			_value := StrReplace(_value, "`n", "``n")
			if (pstId) {
				objs := StrSplit(pstId, ".")
				o := poObject
				loop % objs.maxIndex() {
					o := o[objs[A_Index]]
				}
				o[_key] := _value
			} else {
				poObject[_key] := _value
			}
		}
	}
	return poObject
}
