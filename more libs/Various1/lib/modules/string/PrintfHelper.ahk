class PrintfHelper {

	static INT_TYPES := "di"
	static FLOAT_TYPES := "fe"
	static NUMBER_TYPES := PrintfHelper.INT_TYPES PrintfHelper.FLOAT_TYPES
	static CHAR_TYPES := "cs"
	static TYPES := PrintfHelper.NUMBER_TYPES PrintfHelper.CHAR_TYPES

	static placeHolderValues := []
	static placeHolderIndex := 0
	static placeHolder := {}

	printf(patternText, placeHolderValues*) {
		PrintfHelper.values := Arrays.flatten(placeHolderValues)
		p := 1
		PrintfHelper.placeHolderIndex := 0
		loop {
			if (p := PrintfHelper.patternHasPlaceHolders(patternText, p)) {
				PrintfHelper.handleZero()
				replacingValue
						:= PrintfHelper.values[++PrintfHelper.placeHolderIndex]
				replacingValue := PrintfHelper.handleGenericSize(replacingValue)
				replacingValue := PrintfHelper.handlePrecision(replacingValue)
				replacingValue := PrintfHelper.handleSigns(replacingValue)
				replacingValue := PrintfHelper.handleChars(replacingValue)
				replacingValue := PrintfHelper.handleStrings(replacingValue)
				replacingValue := PrintfHelper.doPadding(replacingValue)
				patternText := patternText.replaceAt(p
						, StrLen(PrintfHelper.placeHolder.all), replacingValue)
				p += StrLen(replacingValue)
			}
		} until (p <= 0)
		return StrReplace(patternText, "%%", "%")
	}

	patternHasPlaceHolders(patternText, position) {
		PrintfHelper.placeHolder := {}
		if (newPosition := RegExMatch(patternText
				, "(?<!%)%(?<flag>[ +-]?)"
				. "(?<zero>0?)"
				. "(?<size>\d*|\*)"
				. "(\.(?<precision>\d*|\*))?"
				. "(?<type>[" PrintfHelper.TYPES "])"
				, $, position)) {
			PrintfHelper.placeHolder.all := $
			PrintfHelper.placeHolder.flag := $flag
			PrintfHelper.placeHolder.zero := $zero
			PrintfHelper.placeHolder.size := $size
			PrintfHelper.placeHolder.precision := $precision
			PrintfHelper.placeHolder.type := $type
			return newPosition
		}
		return 0
	}

	handleGenericSize(replacingValue) {
		if (PrintfHelper.placeHolder.size = "*") {
			PrintfHelper.placeHolder.size := replacingValue
			return PrintfHelper.values[++PrintfHelper.placeHolderIndex]
		}
		return replacingValue
	}

	handlePrecision(replacingValue) {
		if (PrintfHelper.placeHolder.precision = "*") {
			PrintfHelper.placeHolder.precision := replacingValue
			return PrintfHelper.values[++PrintfHelper.placeHolderIndex]
		}
		return replacingValue
	}

	handleZero() {
		PrintfHelper.placeHolder.zero := (PrintfHelper.placeHolder.zero = ""
				? " "
				: "0")
	}

	handleSigns(replacingValue) {
		if (InStr(PrintfHelper.NUMBER_TYPES, PrintfHelper.placeHolder.type)) {
			if (PrintfHelper.placeHolder.flag = "+" && replacingValue >= 0) {
				return "+" replacingValue
			} else if (PrintfHelper.placeHolder.flag = " ") {
				return Abs(replacingValue)
			}
		}
		return replacingValue
	}

	handleChars(replacingValue) {
		if (PrintfHelper.placeHolder.type = "c") {
			if (replacingValue >= 0 && replacingValue <= 255) {
				return Chr(replacingValue)
			} else {
				return SubStr(replacingValue, 1, 1)
			}
		}
		return replacingValue
	}

	handleStrings(replacingValue) {
		if (PrintfHelper.placeHolder.type = "s") {
			if (PrintfHelper.placeHolder.precision
					&& StrLen(replacingValue)
					> PrintfHelper.placeHolder.precision) {
				replacingValue := SubStr(replacingValue
						, 1, PrintfHelper.placeHolder.precision)
			}
		}
		return replacingValue
	}

	doPadding(replacingValue) {
		; if (PrintfHelper.placeHolder.size) {
			if (InStr(PrintfHelper.INT_TYPES
					, PrintfHelper.placeHolder.type)) {
				replacingValue := PrintfHelper.padIntegerTypes(replacingValue)
			} else if (InStr(PrintfHelper.CHAR_TYPES
					, PrintfHelper.placeHolder.type)) {
				replacingValue := PrintfHelper.padCharTypes(replacingValue)
			} else if (InStr(PrintfHelper.FLOAT_TYPES
					, PrintfHelper.placeHolder.type)) {
				replacingValue := PrintfHelper.padFloatTypes(replacingValue)
			}
		; }
		return replacingValue
	}

	padIntegerTypes(replacingValue) {
		if (PrintfHelper.placeHolder.precision != "") {
			if (PrintfHelper.placeHolder.precision == 0
					&& replacingValue == 0) {
				replacingValue := ""
			} else if (PrintfHelper.placeHolder.precision > 0) {
				replacingValue := replacingValue
						.padNumber(PrintfHelper.placeHolder.precision)
			}
		}
		replacingValue := RegExReplace(replacingValue , "\.\d+$", "")
		size := (PrintfHelper.placeHolder.size == ""
				? StrLen(replacingValue)
				: PrintfHelper.placeHolder.size)
		if (PrintfHelper.placeHolder.flag = "-") {
			replacingValue := replacingValue.padRight(size)
		} else {
			replacingValue := replacingValue
					.padNumber(size
					, PrintfHelper.placeHolder.zero)
		}
		return replacingValue
	}

	padCharTypes(replacingValue) {
		if (StrLen(replacingValue) < PrintfHelper.placeHolder.size) {
			replacingValue := (PrintfHelper.placeHolder.flag == "-"
					? replacingValue.padRight(PrintfHelper.placeHolder.size)
					: replacingValue.padLeft(PrintfHelper.placeHolder.size))
		}
		return replacingValue
	}

	padFloatTypes(replacingValue) {
		RegExMatch(replacingValue
				, "(?<integer>[+-]?\d*)(\.(?<fraction>\d*))?", $)
		frac := (PrintfHelper.placeHolder.precision > 0
				? "." ($fraction ? $fraction : "0")
				.padRight(PrintfHelper.placeHolder.precision, "0")
				: "")
		if (PrintfHelper.placeHolder.size == "") {
			replacingValue := $integer frac
		} else {
			replacingValue := $integer
					.padNumber(PrintfHelper.placeHolder.size - StrLen(frac)
					, PrintfHelper.placeHolder.zero) frac
		}
		return replacingValue
	}
}
