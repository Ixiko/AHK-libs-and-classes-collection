; Title:   	[Class] midday.ahk
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=92696
; Author:	Chunjee
; Date:
; for:     	AHK_L

/*


*/

class midday
{
; --- Static Methods ---

	to24(param_time) {
		; prepare
		re := "^(([01][012])|(\d)):([012345]\d)\s?(a|p)m$"

		; check
		if (this._regexpTest(param_time, re)) {
			parts := this._regexpExec(param_time, re)

			switch (format(parts[5], "{:L}")) {
				case "p":
					if (parts[1] < 12) {
						hour := parts[1] + 12
					} else {
						hour := parts[1]
					}
				case "a":
					hour := parts[1]
					if (hour == 12) {
						hour := "00"
					}
			}
			if (strLen(hour) == 1) {
				hour := "0" hour
			}
			return hour ":" parts[4]
		}
		throw exception("Invalid time input: " param_time)
	}

	to12(param_time) {
		; prepare
		re := "^(([01]?\d)|(2[0123]))\D?([012345]\d)$"

		; create
		if (this._regexpTest(param_time, re)) {
			parts := this._regexpExec(param_time, re)
			hour := parts[1]
			min := parts[4]
			if (hour >= 12) {
				if (hour > 12) {
					hour := hour - 12
				}
				ampm := "PM"
			} else {
				ampm := "AM"
			}
			if (hour == "00") {
				hour := "12"
			}
			return hour ":" min " " ampm
		}

		throw exception("Invalid time input: " param_time)
	}

	_regexpTest(param_value, param_re) {
		try {
			; do something
			this._regExpExec(param_value, param_re)
		} catch error {
			return false
		}
		return true
	}

	_regexpExec(param_value, param_re) {
		RegExMatch(param_value, "i)" param_re, outputVar)
		if (outputVar == "") {
			throw exception("Regexp Error")
		} else {
			outputArray := []
			loop, 5 {
				outputArray.push(outputVar%A_Index%)
			}
			return outputArray
		}
	}
}
