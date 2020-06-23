class Flimsydata {

	requires() {
		return [Random, Calendar]
	}

	#Include %A_LineFile%\..\modules\flimsydata\
	#Include Simple.ahk
	#Include Givenname.ahk
	#Include Postalcode.ahk
	#Include Lorem.ahk
	#Include Pattern.ahk

	class Provider {
		static data := ""
	}

	class Formatter {

		randomizer := ""

		__new(seed=12345) {
			this.randomizer := new Random(seed)
			return this
		}
	}

	getRandomInt(randomizer, from, to) {
		return from + Mod(randomizer.generateRandomInt32(), to + 1 - from)
	}

	getRandomListElement(randomizer, list) {
		randomIndex := Flimsydata.getRandomInt(randomizer
				, list.minIndex()
				, list.maxIndex())
		return list[randomIndex]
	}

	getRandomPattern(randomizer, pattern) {
		randomPattern := new Flimsydata.Pattern()
		return randomPattern.getPatternForRandomizer(randomizer, pattern)
	}

	getCountry(inputLocale) {
		if (RegExMatch(inputLocale
				, "iJ)^([a-z]{2}_(?P<Country>[a-z]{2})|(?P<Country>[a-z]{2}))$"
				, locale)) {
			return localeCountry.upper()
		}
		throw Exception("Invalid locale: " inputLocale)
	}

	getLanguage(inputLocale) {
		if (RegExMatch(inputLocale
				, "iJ)^((?P<Language>[a-z]{2})_[a-z]{2}"
				. "|(?P<Language>[a-z]{2}))$"
				, locale)) {
			return localeLanguage.lower()
		}
		throw Exception("Invalid locale: " inputLocale)
	}
}

#Include %A_LineFile%\..\modules\flimsydata\dataprovider
#Include PGivenname.ahk
#Include PPostalcode.ahk
#Include PLorem.ahk
#Include PMetasyntax.ahk
#Include PFoldername.ahk
#Include PFilename.ahk
#Include PFileext.ahk
