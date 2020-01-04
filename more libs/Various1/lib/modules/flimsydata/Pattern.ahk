class Pattern extends Flimsydata.Formatter {

	static DIGITS := Flimsydata.Pattern.defineDigits()
	static LC_VOWELS := Flimsydata.Pattern.defineVowelsLower()
	static UC_VOWELS := Flimsydata.Pattern.defineVowelsUpper()
	static LC_CONSONANTS := Flimsydata.Pattern.defineConsonatsLower()
	static UC_CONSONANTS := Flimsydata.Pattern.defineConsonatsUpper()
	static LC_LETTERS := Flimsydata.Pattern.defineLettersLower()
	static UC_LETTERS := Flimsydata.Pattern.defineLettersUpper()
	static PUNCT := Flimsydata.Pattern.definePunct()
	static SPACES := Flimsydata.Pattern.defineSpaces()
	static SPECIAL := Flimsydata.Pattern.defineSpecialChars()
	static LETTERS := Flimsydata.Pattern.defineLetters()
	static SP_LETTERS := " " Flimsydata.Pattern.defineLetters()
	static ALPHA := Flimsydata.Pattern.defineAlphabetic()
	static ALPHANUM := Flimsydata.Pattern.defineAlphaNumeric()

	pattern := ""
	patternGroup := []
	patternGroupIndex := 1

	defineDigits() {
		return "0123456789"
	}

	defineVowelsLower() {
		return "aeiou"
	}

	defineVowelsUpper() {
		StringUpper vowelsUpper, % Flimsydata.Pattern.defineVowelsLower()
		return vowelsUpper
	}

	defineConsonatsLower() {
		return "bcdfghjklmnpqrstvwxyz"
	}

	defineConsonatsUpper() {
		StringUpper consonantsUpper, % Flimsydata.Pattern.defineConsonatsLower()
		return consonantsUpper
	}

	defineLettersLower() {
		return Flimsydata.Pattern.defineVowelsLower()
				. Flimsydata.Pattern.defineConsonatsLower()
	}

	defineLettersUpper() {
		return Flimsydata.Pattern.defineVowelsUpper()
				. Flimsydata.Pattern.defineConsonatsUpper()
	}

	definePunct() {
		return ",.-;:`´'!?"""
	}

	defineSpaces() {
		return " `t`n`r"
	}

	defineSpecialChars() {
		return "§$%&/()=\}][{@_#+*~<|>"
	}

	defineLetters() {
		return Flimsydata.Pattern.defineLettersLower()
				. Flimsydata.Pattern.defineLettersUpper()
	}

	defineAlphabetic() {
		return Flimsydata.Pattern.defineLetters()
				. Flimsydata.Pattern.definePunct()
				. Flimsydata.Pattern.defineSpecialChars()
	}

	defineAlphaNumeric() {
		return Flimsydata.Pattern.defineAlphabetic()
				. Flimsydata.Pattern.defineDigits()
	}

	getPattern(pattern) {
		this.pattern := this.pickPattern(pattern)
		this.findSubSetsOfElements()
		this.patternGroupIndex := 1
		handleEscapeChar := false
		randomPatternString := ""
		loop % StrLen(this.pattern) {
			patternChar := SubStr(this.pattern, A_Index, 1)
			if (handleEscapeChar) {
				randomPatternString .= patternChar
				handleEscapeChar := false
				continue
			} else if (patternChar == "%") {
				randomPatternString .= this.getRandomGroup()
				continue
			} else if (patternChar == "\") {
				handleEscapeChar := true
				continue
			} else {
				setForPatternChar := this.getSubSetForPatternChar(patternChar)
			}
			randomIndex := Flimsydata.getRandomInt(this.randomizer, 1
					, StrLen(setForPatternChar))
			randomPatternString .= SubStr(setForPatternChar, randomIndex, 1)
		}
		return randomPatternString
	}

	getPatternForRandomizer(randomizer, pattern) {
		this.randomizer := randomizer
		return this.getPattern(pattern)
	}

	pickPattern(pattern) {
		if (pattern.maxIndex() == "") {
			return pattern
		}
		randomPatternIndex := Flimsydata.getRandomInt(this.randomizer
				, pattern.minIndex()
				, pattern.maxIndex())
		return pattern[randomPatternIndex]
	}

	findSubSetsOfElements() {
		subSetsOfElements := []
		p := 1
		while (p := RegExMatch(this.pattern, "`%\[(.+?)\]", $, p)) {
			subSetsOfElements.push(StrSplit($1, ",", " `t``"))
			this.pattern := (this.pattern).cutAt(p+1, StrLen($)-1)
			p++
		}
		this.patternGroup := subSetsOfElements
	}

	getRandomGroup() {
		setForPatternChar := this.patternGroup[this.patternGroupIndex++]
		randomPatternGroupIndex := Flimsydata.getRandomInt(this.randomizer
				, setForPatternChar.minIndex()
				, setForPatternChar.maxIndex())
		return setForPatternChar[randomPatternGroupIndex]
	}

	getSubSetForPatternChar(patternChar) {
		subSetForPatternChar
				:= (patternChar == "v" ? Flimsydata.Pattern.LC_VOWELS
				: patternChar == "V" ? Flimsydata.Pattern.UC_VOWELS
				: patternChar == "c" ? Flimsydata.Pattern.LC_CONSONANTS
				: patternChar == "C" ? Flimsydata.Pattern.UC_CONSONANTS
				: patternChar == "l" ? Flimsydata.Pattern.LC_LETTERS
				: patternChar == "L" ? Flimsydata.Pattern.UC_LETTERS
				: patternChar == "x" ? Flimsydata.Pattern.LETTERS
				: patternChar == "X" ? Flimsydata.Pattern.SP_LETTERS
				: patternChar == "#" ? Flimsydata.Pattern.DIGITS
				: patternChar == "." ? Flimsydata.Pattern.PUNCT
				: patternChar == "$" ? Flimsydata.Pattern.SPECIAL
				: patternChar == "a" ? Flimsydata.Pattern.ALPHA
				: patternChar == "A" ? Flimsydata.Pattern.ALPHANUM
				: patternChar == "*" ? Flimsydata.Pattern.ALPHANUM
				. Flimsydata.Pattern.SPACES
				: "")
		if (!subSetForPatternChar) {
			throw Exception("Invalid pattern char at "
					. A_Index ": '" patternChar "' within '"
					. this.pattern "'")
		}
		return subSetForPatternChar
	}
}
