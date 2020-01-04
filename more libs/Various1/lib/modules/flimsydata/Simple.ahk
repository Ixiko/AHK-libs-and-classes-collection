class Simple extends Flimsydata.Formatter {

	static CHARS_LOWERCASE := "abcdefghijklmnopqrstuvwxyz"
	static CHARS_UPPERCASE := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	static CHARS_MIXED := Flimsydata.Simple.CHARS_LOWERCASE
			. Flimsydata.Simple.CHARS_UPPERCASE

	getInt(from=1, to=10) {
		if (from > to) {
			throw Exception("'from'-value (" from ") mustn't be "
					. "greatern than 'to'-value (" to ")")
		}
		return Flimsydata.getRandomInt(this.randomizer, from, to)
	}

	getFloat(from=1.0, to=10.0, format="") {
		if (from > to) {
			throw Exception("'from'-value (" from ") mustn't be "
					. "greatern than 'to'-value (" to ")")
		}
		randomNumber := from + this.randomizer.generateRandomReal2()
				* (to - from)
		if (format == "") {
			format := A_FormatFloat
		}
		currentFloatFormat := A_FormatFloat
		SetFormat Float, %format%
		randomNumber += 0.0
		SetFormat Float, %currentFloatFormat%
		return randomNumber
	}

	getUpperCaseString(minLength, maxLength="") {
		return this.getString(minLength, maxLength, this.CHARS_UPPERCASE)
	}

	getLowerCaseString(minLength, maxLength="") {
		return this.getString(minLength, maxLength, this.CHARS_LOWERCASE)
	}

	getMixedString(minLength, maxLength="") {
		return this.getString(minLength, maxLength)
	}

	getString(minLength, maxLength, chars="") {
		if (chars == "") {
			chars := this.CHARS_MIXED
		}
		if (maxLength + 0) {
			length := this.getInt(minLength, maxLength)
		} else {
			length := minLength
		}
		randomString := ""
		loop %length% {
			randomString .= SubStr(chars, this.getInt(1, StrLen(chars)), 1)
		}
		return randomString
	}

	getTimeStamp(fromTimeStamp, toTimeStamp) {
		return this.getCalendar(fromTimeStamp, toTimeStamp).get()
	}

	getDate(fromDate, toDate) {
		return this.getCalendar(fromDate, toDate).asDate()
	}

	getTime(fromTime=000000, toTime=235959) {
		return this.getCalendar(16010101 fromTime, 16010101 toTime).asTime()
	}

	getCalendar(fromTimeStamp, toTimeStamp) {
		fromLongTimeStamp := new Calendar(fromTimeStamp).asLong()
		toLongTimeStamp := new Calendar(toTimeStamp).asLong()
		return new Calendar().setAsLong(this.GetInt(fromLongTimeStamp
				, toLongTimeStamp))
	}
}
