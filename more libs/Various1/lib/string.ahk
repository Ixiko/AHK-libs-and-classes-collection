; ahk: console
#Include %A_LineFile%\..\modules\string\
#Include HyphenationHelper.ahk
#Include PrintfHelper.ahk

"".base.repeat := Func("String.repeat")
"".base.pad := Func("String.pad")
"".base.padRight := Func("String.padRight")
"".base.padLeft := Func("String.padLeft")
"".base.padCenter := Func("String.padCenter")
"".base.padNumber := Func("String.padNumber")
"".base.trim := Func("String.trim")
"".base.trimLeft := Func("String.trimLeft")
"".base.trimRight := Func("String.trimRight")
"".base.trimAll := Func("String.trimAll")
"".base.count := Func("String.count")
"".base.replaceAt := Func("String.replaceAt")
"".base.insertAt := Func("String.insertAt")
"".base.cutAt := Func("String.cutAt")
"".base.upper := Func("String.upper")
"".base.lower := Func("String.lower")
"".base.asRegEx := Func("String.asRegEx")
"".base.subStr := Func("String.subStr")
"".base.swap := Func("String.swap")
"".base.reverse := Func("String.reverse")
"".base.asHex := Func("String.asHex")
"".base.asBinary := Func("String.asBinary")
"".base.asNumber := Func("String.asNumber")
"".base.len := Func("String.len")
"".base.put := Func("String.put")
"".base.get := Func("String.get")
"".base.toArray := Func("String.toArray")
"".base.formatNumber:= Func("String.formatNumber")
"".base.replace := Func("String.replace")
"".base.in := Func("String.in")
"".base.wrap := Func("String.wrap")
"".base.compare := Func("String.compare")
"".base.compareAsCaseSensitiveString
		:= Func("String.compareAsCaseSensitiveString")
"".base.compareAsString := Func("String.compareAsString")
"".base.compareAsNumber := Func("String.compareAsNumber")
"".base.equals := Func("String.equals")
"".base.equalsString := Func("String.equalsString")
"".base.equalsCaseSensitiveString
		:= Func("String.equalsCaseSensitiveString")
"".base.equalsNumber := Func("String.equalsNumber")
"".base.extract := Func("String.extract")
"".base.filter := Func("String.filter")
"".base.expand := Func("String.expand")
"".base.subst := Func("String.subst")
"".base.split := Func("String.split")
"".base.printf := Func("String.printf")
"".base.hyphenate	:= Func("String.hyphenate")

class String {

	; ahklint-ignore-begin: W002
	static TRIM_LEFT          := -1, TRIM_ALL             := 0, TRIM_RIGHT            := +1
	static PAD_LEFT           := 0,  PAD_CENTER           := 1, PAD_RIGHT             := 2,  PAD_NUMBER           := 3
	static ASHEX_LOWER        := 0,  ASHEX_UPPER          := 1, ASHEX_NOPREFIX        := 2,  ASHEX_2DIGITS        := 4
	static EXTRACT_NOBOUNDARY := 0,  EXTRACT_LEFTBOUNDARY := 1, EXTRACT_RIGHTBOUNDARY := 2,  EXTRACT_WITHBOUNDARY := 3
	static COMPARE_DETERMINE  := 0,  COMPARE_AS_STRING    := 1, COMPARE_AS_CASE_SENSITIVE_STRING := 2, COMPARE_AS_NUMBER := 3
	; ahklint-ignore-end

	__new() {
		throw Exception("Instantiation of class '"
				. String.__Class "' is not allowed", -1)
	}

	repeat(howManyTimes=1) {
		if (howManyTimes <= 0) {
			return ""
		}
		resultString := this
		loop % (howManyTimes - 1) {
			this .= resultString
		}
		return this
	}

	pad(flags=0, length="", padWith="") {
		OutputDebug %A_ThisFunc% is deprecated. Use String.padLeft/.padRight/.padCenter/.padNumber instead ; ahklint-ignore: W002
		if (flags < String.PAD_LEFT || flags > String.PAD_NUMBER) {
			throw Exception("Invalid padding flags", -1)
		}
		if (length < 0) {
			throw Exception("Invalid pad size: " length)
		}
		$sign := ""
		if (flags = String.PAD_NUMBER) {
			padWith := (padWith = "" ? "0" : padWith)
			if (padWith = "0" && RegExMatch(this
					, "^(?<sign>[+-]?)(?<number>.*)$", $)) {
				this := $number
				if ($sign) {
					length-=1
				}
			}
		}
		if (padWith = "") {
			padWith := " "
		} else if (StrLen(padWith) > 1) {
			padWith := SubStr(padWith, 1, 1)
		}
		padLength := length - StrLen(this)
		if (padLength < 0 && flags = String.PAD_NUMBER) {
			return this
		}
		if (length >= StrLen(this) || flags = String.PAD_NUMBER) {
			if (flags = String.PAD_LEFT || flags = String.PAD_NUMBER) {
				this := padWith.repeat(padLength) this
			} else if (flags = String.PAD_RIGHT) {
				this := this padWith.repeat(padLength)
			} else {
				this := padWith.repeat(Ceil(padLength / 2))
						. this
						. padWith.repeat(Floor(padLength / 2))
			}
		} else {
			if (flags = String.PAD_LEFT) {
				this := SubStr(this, 0-StrLen(this)+2)
			} else if (flags = String.PAD_RIGHT) {
				this := SubStr(this, 1, length)
			} else {
				this := SubStr(this, 1 + Floor(StrLen(this) / 2)
						- Floor(length / 2), length)
			}
		}
		return $sign this
	}

	padRight(length, padWith=" ") {
		String.testPadLength(length)
		padChar := SubStr(padWith, 1, 1)
		return SubStr(this padChar.repeat(length), 1, length)
	}

	padLeft(length, padWith=" ") {
		String.testPadLength(length)
		padChar := SubStr(padWith, 1, 1)
		return SubStr(padChar.repeat(length) this, 0 - (length - 1))
	}

	padCenter(length, padWith=" ") {
		String.testPadLength(length)
		padLength := length - StrLen(this)
		if (padLength < 0) {
			return SubStr(this, 1 + Floor(StrLen(this) / 2)
					- Floor(length / 2), length)
		}
		padChar := SubStr(padWith, 1, 1)
		return padChar.repeat(Ceil(padLength / 2))
				. this padChar.repeat(Floor(padLength / 2))
	}

	padNumber(length, padWith="0") {
		String.testPadLength(length)
		if (StrLen(this) >= length) {
			return this
		}
		padChar := SubStr(padWith, 1, 1)
		if (padChar = "0" && RegExMatch(this
				, "^(?<sign>[+-]?)(?<number>.*)$", $)) {
			this := $number
			if ($sign) {
				length-=1
			}
		} else {
			$sign := ""
		}
		return $sign this.padLeft(length, padChar)
	}

	testPadLength(length) {
		if (length < 0) {
			throw Exception("Invalid pad size: " length)
		}
	}

	trim(pnTrimTo=0) {
		OutputDebug %A_ThisFunc% is deprecated. Use String.trimLeft/.trimRight/.trimAll instead ; ahklint-ignore: W002
		if (pnTrimTo <= 0) {
			this := RegExReplace(this, "^[\s]+", "")
		}
		if (pnTrimTo >= 0) {
			this := RegExReplace(this, "[\s]+$", "")
		}
		return this
	}

	trimLeft() {
		return RegExReplace(this, "^[\s]+", "")
	}

	trimRight() {
		return RegExReplace(this, "[\s]+$", "")
	}

	trimAll() {
		return this.trimLeft().trimRight()
	}

	count(regExToCount) {
		if (regExToCount = "") {
			return 0
		}
		count := 0
		lookAt := 0
		while (lookAt := RegExMatch(this, regExToCount,, lookAt + 1)) {
			count++
		}
		return count
	}

	replaceAt(from, length, replaceWith) {
		if (from < 1 || from > StrLen(this)) {
			throw Exception("Index out of range: " from, -1)
		}
		this := SubStr(this, 1, from - 1)
				. replaceWith
				. SubStr(this, from + length)
		return this
	}

	insertAt(at, insertText) {
		this := SubStr(this, 1, at - 1)
				. insertText
				. SubStr(this, at)
		return this
	}

	cutAt(at, cuttingLength) {
		cuttedString := ""
		if (at > 1) {
			cuttedString .= SubStr(this, 1, at - 1)
		}
		if (cuttingLength != "") {
			cuttedString .= SubStr(this, at + cuttingLength)
		}
		return cuttedString
	}

	upper() {
		StringUpper this, this
		return this
	}

	lower() {
		StringLower, this, this
		return this
	}

	asRegEx() {
		this := StrReplace(this, "\", "\\")
		this := StrReplace(this, ".", "\.")
		this := StrReplace(this, "*", "\*")
		this := StrReplace(this, "?", "\?")
		this := StrReplace(this, "+", "\+")
		this := StrReplace(this, "[" "\[")
		this := StrReplace(this, "{", "\{")
		this := StrReplace(this, "|", "\|")
		this := StrReplace(this, "(", "\(")
		this := StrReplace(this, ")", "\)")
		this := StrReplace(this, "^", "\^")
		this := StrReplace(this, "$", "\$")
		return this
	}

	subStr(from, length="") {
		if (length) {
			return SubStr(this, from, length)
		}
		return SubStr(this, from)
	}

	swap(ByRef anotherString) {
		tempString := anotherString
		anotherString := this
		return tempString
	}

	reverse() {
		reversedString := ""
		stringLength := StrLen(this)
		loop %stringLength% {
			reversedString .= SubStr(this, stringLength - A_Index + 1, 1)
		}
		return reversedString
	}

	asHex(flags=0, length=0) {
		if (!RegExMatch(this, "^[+-]?\d+$")) {
			throw Exception("Invalid data type, integer expcected"
					, -1, "<" this ">")
		}
		currentIntegerFormat := A_FormatInteger
		if (flags & String.ASHEX_UPPER) {
			SetFormat Integer, H
		} else {
			SetFormat Integer, h
		}
		this += 0
		SetFormat Integer, D
		RegExMatch(this, "i)([+-]?)(0x)([0-9a-f]+)", $)
		this := $1 ((flags & String.ASHEX_NOPREFIX) ? "" : $2)
		if ((flags & String.ASHEX_2DIGITS) && StrLen($3) == 1) {
			this .= "0"
		}
		this .= $3
		if (length > 0) {
			this := this.padNumber(length)
		}
		SetFormat Integer, %currentIntegerFormat%
		return this
	}

	asBinary(padLength=4, digitsToGroup="") {
		static BIT_PATTERN
				:= { 0: "0000" , 1: "0001" , 2: "0010" , 3: "0011"
				, 4: "0100" , 5: "0101" , 6: "0110" , 7: "0111"
				, 8: "1000" , 9: "1001" , A: "1010" , B: "1011"
				, C: "1100" , D: "1101" , E: "1110" , F: "1111" }

		if (!RegExMatch(this, "^[+-]?\d+$")) {
			throw Exception("Invalid data type, integer expcected"
					, -1, "<" this ">")
		}
		hexValue := this.asHex(String.ASHEX_NOPREFIX)
		binaryValue := ""
		loop % StrLen(hexValue) {
			binaryValue .= BIT_PATTERN[SubStr(hexValue, A_Index, 1)]
		}
		if (padLength != 4) {
			binaryValue := RegExReplace(binaryValue, "^0+", "")
			if (padLength != 0) {
				binaryValue := binaryValue.padNumber(padLength, "0")
			}
		}
		if (digitsToGroup) {
			at := digitsToGroup + 1
			while (at < StrLen(binaryValue)) {
				binaryValue := binaryValue.insertAt(at, " ")
				at += digitsToGroup + 1
			}
		}
		if (this < 0) {
			binaryValue := "-" binaryValue
		}
		return binaryValue
	}

	asNumber(inputDecimalChar=",", inputThousandsDelimiter=".") {
		formattedNumber := this
		withoutThousandsDelimiter := RegExReplace(formattedNumber
				, "\Q" inputThousandsDelimiter "\E", "")
		withoutDecimalChar := RegExReplace(withoutThousandsDelimiter
				, "\Q" inputDecimalChar "\E", ".",, 1)
		plainNumber := RegExReplace(withoutDecimalChar, "[^0-9+-.]", "")
		return plainNumber
	}

	len() {
		return StrLen(this)
	}

	put(ByRef var, targetEncoding="cp0") {
		VarSetCapacity(var, StrPut(this, targetEncoding)
				* ((targetEncoding="utf-16"
				||targetEncoding="cp1200"
				||targetEncoding="utf-8") ? 2 : 1))
		length := (StrPut(this, &var, targetEncoding)) - 1
		return length
	}

	; TODO: Document method
	; FIXME: Test method. Isn't working yet :-(
	/*
	get(size, sourceEncoding = "cp0") {
		_str := this
		st := StrGet(&_str, size, sourceEncoding)
		_len := VarSetCapacity(st, -1)
		this := st
		return this
	}
	*/

	toArray(delimiters=" ", charsToOmit="", keepEmptyElements=true) {
		stringToSplit := this
		this := StrSplit(stringToSplit, delimiters, charsToOmit)
		concat := 0
		i := 1
		while (i <= this.maxIndex()) {
			if (SubStr(this[i], 1, 1) = """") {
				this[i] := SubStr(this[i], 2)
				concat := i++
			} else if (concat > 0 && SubStr(this[i], 0) = """") {
				this[concat] .= " " SubStr(this[i], 1, StrLen(this[i])-1)
				concat := 1
				this.removeAt(i)
			} else if (concat > 1) {
				this[concat] .= " " this[i]
				this.removeAt(i)
			} else {
				if (!keepEmptyElements && this[i] = "") {
					this.removeAt(i)
				} else {
					i++
				}
			}
		}
		return this
	}

	formatNumber(inputDecimalChar="."
			, formatWithDecimalChar=",", formatWithThousandsDelimiter=".") {
		numbersMantissa := ""
		numbersFraction := ""
		if (!RegExMatch(this, "^(?P<Mantissa>[+-]?\d+)(\Q"
				. inputDecimalChar
				. "\E(?P<Fraction>\d+([eE]?[+-]?\d+)?))?$", numbers)) {
			throw Exception("InvalidNumberFormat", this)
		}
		_len := StrLen(numbersMantissa)
		loop % (_len - 1) // 3 {
			numbersMantissa := numbersMantissa.insertAt(_len + 1 - (A_Index * 3)
					, formatWithThousandsDelimiter)
		}
		return numbersFraction = ""
				? numbersMantissa
				: numbersMantissa formatWithDecimalChar numbersFraction
	}

	replace(searchFor, replaceWith="", replaceAllOccurences=true) {
		return StrReplace(this, searchFor, replaceWith,
				, (replaceAllOccurences ? -1 : 1))
	}

	in(listOfStrings*) {
		commaSeparatedList := ""
		while (A_Index <= listOfStrings.maxIndex()) {
			commaSeparatedList .= (commaSeparatedList = "" ? "" : ",")
					. listOfStrings[A_Index]
		}
		searchFor := this
		if searchFor in %commaSeparatedList%
		{
			return true
		}
		return false
	}

	wrap(length, indentWith="", initialIndent="", replaceFirstIndent=false
			, fillUp=false) {
		if (length < 3) {
			throw Exception("MinRequiredWidth3", length)
		}
		wrappedString := initialIndent
		endOfNextChunk := 1
		index := endOfNextChunk + length
		split := 0
		while (index <= StrLen(this)) {
			index := String.findPositionOfNextSpace(this, index, endOfNextChunk)
			if (index = endOfNextChunk) {
				chunk := SubStr(this, endOfNextChunk, length)
				endOfNextChunk += length
			} else {
				chunk := SubStr(this
						, endOfNextChunk, index - endOfNextChunk + 1)
				endOfNextChunk := index + 2
			}
			wrappedString .= String.composeWrappedString(String
					.returnIndent(split, replaceFirstIndent, indentWith)
					, chunk, fillUp, length) "`n"
			index := endOfNextChunk + length
			split++
		}
		if (endOfNextChunk <= StrLen(this)) {
			chunk := SubStr(this, endOfNextChunk)
			wrappedString .= String.composeWrappedString(String
					.returnIndent(split, replaceFirstIndent, indentWith)
					, chunk, fillUp, length)
		}
		return wrappedString
	}

	findPositionOfNextSpace(text, startAt, downTo) {
		at := startAt
		loop {
			char := SubStr(text, at--, 1)
		} until (at <= downTo || char == A_Space || char == A_Tab)
		return at
	}

	returnIndent(split, replaceFirstIndent, indentWith) {
		return (split == 0 && replaceFirstIndent ? "" : indentWith)
	}

	composeWrappedString(indent, wrappedString, fillUp, length) {
		indentedString := indent . wrappedString
		return (fillUp ? indentedString.padRight(length, " ") : indentedString)
	}

	compare(compareWith, flag=0) {
		OutputDebug % A_ThisFunc ": compare <" this "> with <" compareWith "> " flag ; ahklint-ignore: W002
		if (flag = String.COMPARE_AS_STRING) {
			return this.compareAsString(compareWith)
		} else if (flag = String.COMPARE_AS_CASE_SENSITIVE_STRING) {
			return this.compareAsCaseSensitiveString(compareWith)
		} else {
			if (RegExMatch(this, "^[+-]?\d+(\.\d+)*([eE][+-]?\d)*$")) {
				return this.compareAsNumber(compareWith)
			}
			return this.compareAsCaseSensitiveString(compareWith)
		}
	}

	compareAsString(compareWith) {
		compareThisString := this "$"
		compareWithString := compareWith "$"
		return (compareThisString = compareWithString ? 0
				: compareThisString > compareWithString ? +1
				: -1)
	}

	compareAsCaseSensitiveString(compareWith) {
		scs := A_StringCaseSense
		StringCaseSense on
		compareThisString := this "$"
		compareWithString := compareWith "$"
		result := (compareThisString == compareWithString ? 0
				: compareThisString > compareWithString ? +1
				: -1)
		StringCaseSense %scs%
		return result
	}

	compareAsNumber(compareWith) {
		return (this = compareWith ? 0
				: this > compareWith ? +1
				: -1)
	}

	equals(compareWith, caseSensitive=true) {
		return this.compare(compareWith, caseSensitive) == 0
	}

	equalsString(compareWith) {
		return this.compareAsString(compareWith) == 0
	}

	equalsCaseSensitiveString(compareWith) {
		return this.compareAsCaseSensitiveString(compareWith) == 0
	}

	equalsNumber(compareWith) {
		return this.compareAsNumber(compareWith) == 0
	}

	extract(fromString, toString, includeBoundaries=0) {
		if (fromString) {
			p1 := InStr(this, fromString)
			if (!(includeBoundaries & String.EXTRACT_LEFTBOUNDARY)) {
				p1 += 1
			}
		} else {
			p1 := 1
		}
		p2 := InStr(this, toString,, p1)
		if (includeBoundaries & String.EXTRACT_RIGHTBOUNDARY) {
			p2 += 1
		}
		return this.subStr(p1, p2-p1)
	}

	filter(filterExpression, filterIsRegularExpression=false
			, ignoreCase=false, invertMatch=false, ByRef match="") {
		if (!filterIsRegularExpression) {
			filterExpression := RegExReplace(filterExpression
					, "([^*?]+)", "\Q$1\E")
			filterExpression := StrReplace(filterExpression, "*", ".*")
			filterExpression := StrReplace(filterExpression, "?", ".?")
			filterExpression := "^" filterExpression "$"
		}
		if (!ignoreCase && RegExMatch(filterExpression
				, "^([msxADJUXOPSC]|`n|`r|`a|(?P<i>i))*?\)", has_)) {
			if (has_i) {
				ignoreCase := true
			}
		}
		filterExpression := RegExReplace(filterExpression
				, "^([imsxADJUXOPSC]|`n|`r|`a)+\)", "")
		if (ignoreCase) {
			filterExpression := "iO)" filterExpression
		} else {
			filterExpression := "O)" filterExpression
		}
		p := RegExMatch(this, filterExpression, match)
		if (invertMatch) {
			p := !p
		}
		return p
	}

	expand(expandBy, howOften, delimiter="`n") {
		if (howOften <= 0) {
			return ""
		}
		if (this != "") {
			tokens := StrSplit(this, delimiter)
			numberOfTokens := tokens.maxIndex()
			if (tokens[numberOfTokens] = "") {
				tokens.removeAt(numberOfTokens)
				numberOfTokens := tokens.maxIndex()
			}
		} else {
			numberOfTokens := 0
		}
		loop % (howOften - numberOfTokens) {
			this .= expandBy
		}
		return this
	}

	subst(pstSubst*) {
		OutputDebug %A_ThisFunc% is deprecated. Use String.Printf instead ; ahklint-ignore: W002,W009
		loop % pstSubst.maxIndex() {
			p := RegExMatch(this, "%(?<type>[si])(?<size>[+-]?\d+)*", $)
			ps := StrLen($)
			if ($size = "") {
				_subst := pstSubst[A_Index]
			} else if ($type = "s") {
				if ($size > 0) {
					_subst := (pstSubst[A_Index]).padRight($size, " ")
				} else if ($size < 0) {
					_subst := (pstSubst[A_Index]).padLeft(Abs($size), " ")
				} else {
					_subst := pstSubst[A_Index]
				}
			} else if ($type = "i") {
				_subst := (pstSubst[A_Index])
						.padLeft($size, (SubStr($size, 1, 1)="0" ? "0" : " "))
			}
			this := (p > 1 ? SubStr(this, 1, p-1) : "")
					. _subst SubStr(this, p+ps)
		}
		return this
	}

	split(delimitingRegEx) {
		parts := { surround: []
				, delimiter: []
				, all: [] }
		if (delimitingRegEx == "") {
			parts.surround := [this]
			parts.all := [this]
			return parts
		}
		startAt := 1
		positionWithinThis := 1
		while (delimiterFoundAt := (RegExMatch(this, delimitingRegEx
				, delimiter, startAt))) {
			surroundPartLength := delimiterFoundAt - positionWithinThis
			if (surroundPartLength > 0) {
				surroundPart := SubStr(this
						, positionWithinThis, surroundPartLength)
				parts.surround.push(surroundPart)
				parts.all.push(surroundPart)
			}
			parts.delimiter.push(delimiter)
			parts.all.push(delimiter)
			startAt := delimiterFoundAt + StrLen(delimiter)
			positionWithinThis := startAt
		}
		if (positionWithinThis <= StrLen(this)) {
			remainingSurroundPart := SubStr(this, positionWithinThis)
			parts.surround.push(remainingSurroundPart)
			parts.all.push(remainingSurroundPart)
		}
		return parts
	}

	unSplit(parts) {
		concatedString := ""
		if (parts.delimiter[1] == parts.all[1]) {
			loop % parts.delimiter.maxIndex() {
				concatedString .= parts.delimiter[A_Index]
				concatedString .= parts.surround[A_Index]
			}
		} else {
			loop % parts.surround.maxIndex() {
				concatedString .= parts.surround[A_Index]
				concatedString .= parts.delimiter[A_Index]
			}
		}
		return concatedString
	}

	printf(placeHolderValues*) {
		return PrintfHelper.printf(this, placeHolderValues)
	}

	hyphenate(hyphenateAt=-1, hyphenChar="") {
		return HyphenationHelper.hyphenate(this, hyphenateAt, hyphenChar)
	}
}
; vim: ts=4:sts=4:sw=4:tw=0:noet
