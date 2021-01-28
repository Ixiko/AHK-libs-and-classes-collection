HoursMinutesToDecimal(input, params) {
	Loop, Parse, input, `n
	{
		someTime := Trim(A_LoopField, "`r`n")
		if not someTime {
			str .= someTime "`n"
			continue
		}

		if (InStr(someTime, params.rangeSeparator)) {
			; INPUT: "10:00 -> 11:00" (=Time range, TimeSpent=1h)
			RegExMatch(someTime, "(\d+:\d+)" params.rangeSeparator "(\d+:\d+)", timeRange)

			startTime := ConvertTimeToDecimal(timeRange1)
			endTime := ConvertTimeToDecimal(timeRange2)
			dec := endTime - startTime

			totalDec += dec
			str .= someTime " = " Round(dec, 2) "`n"

			rangeWasPresent := true

		} else {
			; INPUT: "8:20" (=Time spent)
			dec := ConvertTimeToDecimal(someTime)
			totalDec += dec

			str .= someTime " = " dec "`n"
		}

		timeCount += 1
	}

	if (!totalDec) {
		Notify("Invalid input", "Expected something like one or more lines of:`n8:20`n8:20 " params.rangeSeparator " 10:40")
		return
	}

	roundedTotalDec := Round(totalDec, 2)
	if (not rangeWasPresent and timeCount = 1) {
		return roundedTotalDec
	}

	totalHours := Floor(totalDec)
	totalMinutes := Floor((totalDec - totalHours) * 60)

	str .= "`nTotal:`n" totalHours ":" totalMinutes " -> " Round(totalDec, 2)

	Notify("Total: " roundedTotalDec)
	return str
}


ConvertTimeToDecimal(someTime) {
	times := StrSplit(someTime, ":")
	return Round((times[1] + 0) + times[2] / 60, 2)
}


ToSortableDate() {
	return GetDateInFormat("yyyy-MM-dd HH:mm:ss")
}


ToSortableFileNameDate() {
	return GetDateInFormat("yyyy-MM-ddTHHmmss")
}


ToHumanReadableDate() {
	return GetDateInFormat("dd/MM/yyyy HH:mm:ss")
}


ToIsoDate() {
	return GetDateInFormat("yyyyMMddTHHmmssZ")
}

ToJekyllPostDate() {
	return GetDateInFormat("yyyy-MM-dd HH:mm:ss '{+}0200'")
}

ToJekyllFilePrefixDate() {
	return GetDateInFormat("yyyy-MM-dd-")
}

GetDateInFormat(format) {
	FormatTime, CurrentDateTime,, %format%
	return CurrentDateTime
}


; Builtin date variables:
; https://autohotkey.com/docs/Variables.htm#date

; Manipulation of dates with:
; https://autohotkey.com/docs/commands/EnvAdd.htm
; https://autohotkey.com/docs/commands/FormatTime.htm


/*
	Function: DateParse
		Converts almost any date format to a YYYYMMDDHH24MISS value.

	Parameters:
		str - a date/time stamp as a string

	Returns:
		A valid YYYYMMDDHH24MISS value which can be used by FormatTime, EnvAdd and other time commands.

	Example:
> time := DateParse("2:35 PM, 27 November, 2007")

	License:
		- Version 1.04 <http://www.autohotkey.net/~Titan/#dateparse>.
		- New BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
; DateParse(str) {
; 	static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
; 	str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
; 	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
; 		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
; 		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
; 		d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
; 	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
; 		RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?(?:\s*([ap]m))?", t)
; 			, RegExMatch(str, e2, d)
; 	f = %A_FormatFloat%
; 	SetFormat, Float, 02.0
; 	d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
; 		. ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0
; 			? d2 + 0.0 : A_MM). ((d1 += 0.0) ? d1 : A_DD) . t1
; 			+ (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "am" ? 0.0 : 12.0) . t2 + 0.0 . t3 + 0.0
; 	SetFormat, Float, %f%
; 	Return, d
; }
