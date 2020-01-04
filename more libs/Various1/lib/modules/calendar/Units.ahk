class Units {
	static SECONDS := "s"
	static SECOND  := "s"
	static MINUTES := "m"
	static MINUTE  := "m"
	static HOURS   := "h"
	static HOUR    := "h"
	static DAYS    := "D"
	static DAY     := "D"

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' is not allowed", -1)
	}

	isValid(unitCharToCheck) {
		if (StrLen(unitCharToCheck) == 1) {
			for unitName, unitChar in Calendar.Units {
				if (unitCharToCheck = unitChar) {
					return true
				}
			}
		}
		return false
	}
}
