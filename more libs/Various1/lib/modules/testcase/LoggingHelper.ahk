;{{{ LoggingHelper
/*
 *	Class: LoggingHelper
 *		Provide methods which support logging.
 */
class LoggingHelper {

	;{{{ __New
	/*
	 *	Constructor: __New
	 *		Instantiation of the LoggingHelper ist not allowed.
	 */
	__New() {
		throw Exception("Instantiation of class '" this.__Class
				. "' is not allowed")
	}
	;}}}

	;{{{ TweakValue
	/*
	 *	Method: TweakValue
	 *		Returns a printable output for objects and exceptions.
	 *		
	 *	Parameters:
	 *		pValue - Pass thru value.
	 *		
	 *	Returns:
	 *		The content of pValue.
	 */
	tweakValue(pValue) {
		_providedValue := pValue

		if (IsObject(pValue)) {
			if (pValue.__Class != "") {
				_providedValue := "@" Object(pValue)
						. (pValue.base.__Class != ""
						? "::" pValue.base.__Class : "")
						. (pValue.base.base.__Class != ""
						? "<-" pValue.base.base.__Class : "")
			} else if (pValue.HasKey("What") && pValue.HasKey("File")
					&& pValue.HasKey("Line") && pValue.HasKey("Message")) {
				_providedValue := "<Exception: '" pValue.Message "' in "
						. pValue.File ":" pValue.What ":" pValue.Line ">"
			} else if (pValue.__Class = "") {
				_providedValue := "@" Object(pValue)
			}
		}  else {
			if pValue is integer
			{
				_fi := A_FormatInteger
				SetFormat Integer, h
				_hex := pValue + 0
				SetFormat Integer, %_fi%
				_providedValue := pValue " (" _hex ")"
			} else if (RegExMatch(pValue, "`m)^\s*$", _providedValue)) {
				StringReplace _providedValue, _providedValue, %A_Space%, ·, All
				StringReplace _providedValue, _providedValue, %A_Tab%, ¬, All
				StringReplace _providedValue, _providedValue, `n, ¶, All
			} else {
				_p := 0
				try {
					if (_p := RegExMatch(pValue, "`nm)^(.+?)(\s*?)$"
							, #, _p + 1)) {
						_providedValue := ""
						loop {
							StringReplace #2, #2, %A_Space%, ·, All
							StringReplace #2, #2, %A_Tab%, ¬, All
							_providedValue .= #1 #2 "`n"
						} until ((_p := RegExMatch(pValue, "`nm)^(.*?)(\s*?)$"
								, #, _p + 1)) = 0)
					}
				} catch _ex {
					OutputDebug % "RegExMatch runtime error: " _ex.Message " - haystack = " pValue  ; ahklint-ignore: W002
					_providedValue := pValue
				}
				_providedValue := RegExReplace(_providedValue, "`n$", "")
				_providedValue := StrReplace(_providedValue, "`n", "¶")
			}
		}
		return _providedValue
	}
	;}}}

	;{{{ JustifyLeft
	/*
	 *	Method: JustifyLeft
	 *		Left-aligns a string to a specified size by using a given padding character.
	 *		
	 *	Parameters:
	 *		pstrText - The string to align.
	 *		piLength - Size desired length of the result string.
	 *		pcChar - The character to use for padding.
	 *		
	 *	Returns:
	 *		A left aligned string of the specified size, padded with the given character.
	 *		
	 *	See Also:
	 *		<LoggingHelper.JustifyRight>
	 */
	justifyLeft(pstrText="", piLength=1, pcChar=" ") {
		_pad := pcChar
		loop % (piLength - 1) {
			_pad .= pcChar
		}

		return SubStr(pstrText _pad, 1, piLength)
	}
	;}}}

	;{{{ JustifyRight
	/*
	 *	Method: JustifyRight
	 *		Right-aligns a string to a specified size by using a given padding character.
	 *		
	 *	Parameters:
	 *		pstrText - The string to align.
	 *		piLength - Size desired length of the result string.
	 *		pcChar - The character to use for padding.
	 *		
	 *	Returns:
	 *		A right aligned string of the specified size, padded with the given character.
	 *		
	 *	See Also:
	 *		<LoggingHelper.JustifyLeft>
	 */
	justifyRight(pstrText="", piLength=1, pcChar=" ") {
		_pad := pcChar
		loop % (piLength - 1) {
			_pad .= pcChar
		}

		return SubStr(_pad pstrText, (piLength - 1) * -1)
	}
	;}}}

	;{{{ Dump
	/*
	 *	Method: Dump
	 *		Dump the content of an object by traversing over its components.
	 *		
	 *	Parameters:
	 *		pObject - Provide the object to dump.
	 *		piNestedLevel - For internal use *do not set*
	 *		strId - For internal use *do not set*
	 *		
	 *	Returns:
	 *		An object dump as a string.
	 */
	dump(pObject, piNestedLevel=1, strId="") {
		static SPACER1 := "                    "
		static SPACER2 := "          "
		static strOutput := ""

		if (!IsObject(pObject)) {
			return pObject
		}
		if (piNestedLevel > 32) {
			return
		}

		gosub Indent

		if (strOutput = "") {
			strOutput .= "Dump>> " (IsObject(pObject.base)
					? LoggingHelper.JustifyLeft("@" Object(pObject.base), 10)
					: SPACER2)
					. "   " (pObject.__Class != ""
					? pObject.__Class " object"
					: "Object has no base class" ) "`n"
		}

		if (pObject.base) {
			if (IsObject(pObject.base) && pObject.base.__Class != "") {
				_name := pObject.base.__Class
				_suffix := " class"
			} else if (IsObject(pObject.base)) {
				_name := pObject.base
				_suffix := "{}"
			} else {
				_name := pObject.base
				_suffix := ""
			}
			piNestedLevel++
			gosub Indent
			strOutput .= SPACER1 SubStr(_indent, 1, StrLen(_indent) - 4) "|\`n"
			strOutput .= "Base   " (IsObject(pObject.base)
					? LoggingHelper.JustifyLeft("@" Object(pObject.base), 10)
					: SPACER2) "   " _indent _name _suffix "`n"
			strOutput .= LoggingHelper.Dump(pObject.base, piNestedLevel, _name)
			strOutput .= SPACER1 SubStr(_indent, 1, StrLen(_indent) - 4) "|/`n"
			piNestedLevel--
			gosub Indent
		}

		for _key, _value in pObject {
			if (IsObject(_value) && IsFunc(_value)) {
				strOutput .= "Func   " (IsObject(_value)
						? LoggingHelper.JustifyLeft("@" Object(_value), 10)
						: SPACER2)
						. "   " _indent _key "()`n"
			} else if (_value.MinIndex() != "" && _value.MaxIndex() != "") {
				strOutput .= "Array  " (IsObject(_value)
						? LoggingHelper.JustifyLeft("@" Object(_value), 10)
						: SPACER2)
						. "   " _indent _key
						. "[" _value.minIndex() ".." _value.maxIndex() "]`n"
				piNestedLevel++
				gosub Indent
				strOutput .= SPACER1
						. SubStr(_indent, 1, StrLen(_indent) - 4) "|\`n"
				strOutput .= LoggingHelper.Dump(_value
						, piNestedLevel, strId "." _key)
				strOutput .= SPACER1
						. SubStr(_indent, 1, StrLen(_indent) - 4) "|/`n"
				piNestedLevel--
				gosub Indent
			} else if (IsObject(_value)) {
				if (_value.__Class != "") {
					strOutput .= "Class  " (IsObject(_value)
							? LoggingHelper.JustifyLeft("@" Object(_value), 10)
							: SPACER2) "   " _indent _key "`n"
				} else {
					strOutput .= "Object " (IsObject(_value)
							? LoggingHelper.JustifyLeft("@" Object(_value), 10)
							: SPACER2) "   " _indent _key " = {}`n"
				}
				piNestedLevel++
				gosub Indent
				strOutput .= SPACER1
						. SubStr(_indent, 1, StrLen(_indent) - 4) "|\`n"
				strOutput .= LoggingHelper.Dump(_value
						, piNestedLevel, strId "." _key)
				strOutput .= SPACER1
						. SubStr(_indent, 1, StrLen(_indent) - 4) "|/`n"
				piNestedLevel--
				gosub Indent
			} else {
				strOutput .= "Prop   " (IsObject(pObject.base)
						? LoggingHelper.JustifyLeft("@"
						. Object(pObject.base), 10)
						: SPACER2) "   " _indent
						. _key " = " LoggingHelper.TweakValue(_value) "`n"
			}
		}

		if (piNestedLevel <= 1) {
			strOutput .= "End<<`n"
		}
		_output := strOutput, strOutput := ""
		return _output

		Indent:
			_indent := ""
			loop % (piNestedLevel - 1) {
				_indent .= "| "
			}
			_indent .= "* "
		return
	}
	;}}}

	;{{{ HexDump
	/*
	 *	Method: HexDump
	 *		Generat a hex dump for a given memory address from specified offset and length.
	 *		
	 *	Parameters:
	 *		piAddress - The address to start the dump.
	 *		piOffset - The offset to add to piAddress.
	 *		piSize - The number of bytes to dump.
	 *		
	 *	Returns:
	 *		A hex dump as a string.
	 */
	hexDump(piAddress, piOffset=0, piSize="") {
		_ofs := 0
		_str := ""
		strOutput := ""
		_addr := &piAddress
		_fi := A_FormatInteger
		SetFormat Integer, h
		loop %piSize% {
			if (Mod(_ofs, 16) = 0) {
				_addr := LoggingHelper.JustifyRight(RegExReplace(piAddress+_ofs
						, "i)^0x", ""), 12, 0)
				strOutput .= "  " _str "`n" _addr "  "
				_str := ""
			} else if (Mod(_ofs, 8) = 0) {
				strOutput .= " "
			}
			charCode := NumGet(piAddress + _ofs, 0, "UChar")
			_str .= (charCode >= 32 && charCode <= 126 ? Chr(charCode) : ".")
			strOutput .= LoggingHelper.JustifyRight(RegExReplace(charCode
					, "i)^0x", ""), 2, 0) " "
			_ofs++
		}
		if (Mod(_ofs, 16) != 0) {
			strOutput .= LoggingHelper.JustifyLeft(""
					, 3 * (16 - Mod(_ofs, 16)), " ")
					. (Mod(_ofs, 16) = Mod(_ofs, 8) ? " " : "")
		}
		strOutput .=  "  " _str
		SetFormat Integer, %_fi%

		return strOutput
	}
	;}}}

	hex(value) {
		_fi := A_FormatInteger
		SetFormat Integer, h
		value+=0
		SetFormat Integer, %_fi%

		return value
	}
}
