class CalendarHelper {

	static MAX_DAY_OF_MONTH := [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	__new() {
		throw Exception("Instatiation of class '"
				. this.__Class "' is not allowed", -1)
	}

	validTime(dateTime="") {
		if (dateTime = "") {
			validDateTime := A_Now
		} else if (!RegExMatch(dateTime, "^\d+$")) {
			throw Exception("The given time contains invalid characters"
					, -1, "<" dateTime ">")
		} else if (StrLen(dateTime) < 4) {
			throw Exception("Invalid time. "
					. "Provide at least a year between 1601 and 9999"
					, -1, "<" dateTime ":" dateTime.Len() ">")
		} else {
			dateTimeWithYear := CalendarHelper.testForValidYear(dateTime)
			CalendarHelper.MAX_DAY_OF_MONTH[2]
					:= CalendarHelper.returnMaxDaysForFebruary(dateTimeWithYear)
			dateTimeWithMonth
					:= CalendarHelper.testForValidMonth(dateTimeWithYear)
			dateTimeWithDay := CalendarHelper.testForValidDay(dateTimeWithMonth)
			dateTimeWithHours
					:= CalendarHelper.testForValidHour(dateTimeWithDay)
			dateTimeWithMinutes
					:= CalendarHelper.testForValidMinutes(dateTimeWithHours)
			dateTimeWithSeconds
					:= CalendarHelper.testForValidSeconds(dateTimeWithMinutes)
			validDateTime := dateTimeWithSeconds
		}
		return validDateTime
	}

	returnMaxDaysForFebruary(dateTime) {
		yearToTest := SubStr(dateTime, 1, 4)
		if ((Mod(yearToTest, 4) == 0 && Mod(yearToTest, 100) != 0)
				|| Mod(yearToTest, 400) == 0) {
			return 29
		}
		return 28
	}

	testForValidYear(dateTime) {
		yearToTest := SubStr(dateTime, 1, 4)
		if (yearToTest < 1601) {
			throw Exception("Provide a year between 1601 and 9999"
					, -1, "<" yearToTest ">")
		}
		return dateTime
	}

	testForValidMonth(dateTime) {
		monthToTest := SubStr(dateTime, 5, 2)
		if (monthToTest = "") {
			dateTime .= "01"
		}
		else if (monthToTest < 01 || monthToTest > 12) {
			throw Exception("Month must be between 01 and 12"
					, -1, "<" monthToTest ">")
		}
		return dateTime
	}

	testForValidDay(dateTime) {
		dayToTest := SubStr(dateTime, 7, 2)
		if (dayToTest = "") {
			dateTime .= "01"
		}
		else {
			month := SubStr(dateTime, 5, 2)
			year := SubStr(dateTime, 1, 4)
			CalendarHelper.MAX_DAY_OF_MONTH[2]
					:= CalendarHelper.returnMaxDaysForFebruary(year)
			if (dayToTest < 01
					|| dayToTest > CalendarHelper.MAX_DAY_OF_MONTH[month]) {
				throw Exception("Day of month must be between 01 and "
						. CalendarHelper.MAX_DAY_OF_MONTH[month]
						, -1, "<" dayToTest ">")
			}
		}
		return dateTime
	}

	testForValidHour(dateTime) {
		hourToTest := SubStr(dateTime, 9, 2)
		if (hourToTest = "") {
			dateTime .= "00"
		}
		else if (hourToTest < 00 || hourToTest > 23) {
			throw Exception("Hour must be between 00 and 23"
					, -1, "<" hourToTest ">")
		}
		return dateTime
	}

	testForValidMinutes(dateTime) {
		minutesToTest := SubStr(dateTime, 11, 2)
		if (minutesToTest = "") {
			dateTime .= "00"
		}
		else if (minutesToTest < 00 || minutesToTest > 59) {
			throw Exception("Minutes must be between 00 and 59"
					, -1, "<" minutesToTest ">")
		}
		return dateTime
	}

	testForValidSeconds(dateTime) {
		secondsToTest := SubStr(dateTime, 13, 2)
		if (secondsToTest = "") {
			dateTime .= "00"
		}
		else if (secondsToTest < 00 || secondsToTest > 59) {
			throw Exception("Seconds must be between 00 and 59"
					, -1, "<" secondsToTest ">")
		}
		return dateTime
	}

	daysInMonth(dateTime="", month="") {
		try {
			CalendarHelper.validTime(dateTime)
		} catch _ex {
			throw _ex
		}
		return CalendarHelper.MAX_DAY_OF_MONTH[month]
	}

	testForValidInteger(value, additionalInfo="") {
		if (!RegExMatch(value, "^[-+]?\d+$")) {
			throw Exception(additionalInfo (additionalInfo != "" ? " - " : "")
					. "integer expected", -1, "<" value ">")
		}
		return true
	}

	testForValidNumber(value, additionalInfo="") {
		if (!RegExMatch(value, "^[+-]?(\d+|\d*?\.\d*)$")) {
			throw Exception(additionalInfo (additionalInfo != "" ? " - " : "")
					. "number expected", -1, "<" value ">")
		}
		return true
	}

	testForValidWeekDay(weekDay) {
		if (weekDay < Calendar.SUNDAY || weekDay > Calendar.SATURDAY) {
			throw Exception("Week day must be between " Calendar.SUNDAY
					. " and " Calendar.SATURDAY, -1, "<" weekDay ">")
		}
		return true
	}

	adjustMonthAndHandleUnderFlowOrOverFlow(calendar, monthsToAdjust) {
		if (calendar.asMonth() + monthsToAdjust < 1) {
			calendar.setAsMonth(12 + calendar.asMonth() + monthsToAdjust)
			calendar.setAsYear(calendar.asYear() - 1)
		} else if (calendar.asMonth() + monthsToAdjust > 12) {
			calendar.setAsMonth(calendar.asMonth() + monthsToAdjust - 12)
			calendar.setAsYear(calendar.asYear() + 1)
		} else {
			calendar.setAsMonth(calendar.asMonth() + monthsToAdjust)
		}
		maxDaysInAdjustedMonth
				:= CalendarHelper.daysInMonth(new Calendar(calendar.asYear()
				. calendar.asMonth()).get(), calendar.asMonth())
		if (calendar.asDay() > maxDaysInAdjustedMonth) {
			calendar.setAsDay(maxDaysInAdjustedMonth)
		}
	}

	findNextOrFirstOccurenceOfWeekDay(direction) {
		return direction >= Calendar.FIND_NEXT_OR_FIRST_OCCURENCE_OF_WEEKDAY
	}

	findNextOccurenceOfWeekDay(calendar, weekDay, occurence) {
		if (occurence == Calendar.FIND_NEXT) {
			if (weekDay = calendar.dayOfWeek()) {
				occurence := 2
			} else {
				occurence := 1
			}
		} else {
			calendar.setAsDay(1)
		}
		if (weekDay <= calendar.dayOfWeek()) {
			if (weekDay = calendar.dayOfWeek()) {
				occurence -= 1
			}
			distance := weekDay + 7 - calendar.dayOfWeek()
		} else {
			distance := weekDay - calendar.dayOfWeek()
		}
		distance *= occurence
		calendar.adjust(0, 0, distance)
		return calendar
	}

	findRecentOccurenceOfWeekDay(calendar, weekDay, occurence) {
		if (occurence == Calendar.FIND_RECENT) {
			occurence := 1
		} else {
			calendar.setAsDay(calendar.daysInMonth())
		}
		if (weekDay = calendar.dayOfWeek()) {
			if (occurence > 0) {
				distance := 7
			} else {
				distance := 0
			}
		} else {
			distance := calendar.dayOfWeek() - weekDay
		}
		distance += 7 * (Abs(occurence) - 1)
		distance *= -1
		calendar.adjust(0, 0, distance)
		return calendar
	}
}
