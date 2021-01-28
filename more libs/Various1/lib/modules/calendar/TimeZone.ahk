class TimeZone {

	static UNKWOWN  :=  0
	static STANDARD :=  1
	static DAYLIGHT :=  2
	static INVALID  := -1

	iD := 0
	bias := 0

	; ahklint-ignore-begin: W003
	setting
		:= { standard : { bias: 0
			, name: ""
			, date: { day: 0
				, dayOfWeek: 0
				, month: 0
				, hour: 0
				, minute: 0 } }
		, Daylight : { bias: 0
			, name: ""
			, date: { Day: 0
				, dayOfWeek: 0
				, month: 0
				, hour: 0
				, minute: 0 } } }
	; ahklint-ignore-end

	__new() {
		VarSetCapacity(_tzi, sizeOf(TIME_ZONE_INFORMATION))
		this.iD := DllCall("GetTimeZoneInformation", "UInt", &_tzi, "UInt")
		if (this.iD != Calendar.TimeZone.INVALID) {
			tzi := new TIME_ZONE_INFORMATION(_tzi)
			this.bias := tzi.bias
			this.Setting.Standard.bias := tzi.StandardBias
			this.Setting.Standard.name := tzi.StandardName
			this.Setting.Standard.Date.day       := tzi.StandardDate.wDay
			this.Setting.Standard.Date.dayOfWeek := tzi.StandardDate.wDayOfWeek
			this.Setting.Standard.Date.month     := tzi.StandardDate.wMonth
			this.Setting.Standard.Date.hour      := tzi.StandardDate.wHour
			this.Setting.Standard.Date.minute    := tzi.StandardDate.wMinute
			this.Setting.Daylight.bias := tzi.DaylightBias
			this.Setting.Daylight.name := tzi.DaylightName
			this.Setting.Daylight.Date.day       := tzi.DaylightDate.wDay
			this.Setting.Daylight.Date.dayOfWeek := tzi.DaylightDate.wDayOfWeek
			this.Setting.Daylight.Date.month     := tzi.DaylightDate.wMonth
			this.Setting.Daylight.Date.hour      := tzi.DaylightDate.wHour
			this.Setting.Daylight.Date.minute    := tzi.DaylightDate.wMinute
		}
		return this
	}

	getBias() {
		bias := ""
		if (this.iD = Calendar.TimeZone.UNKWOWN) {
			bias := this.bias
		} else if (this.iD = Calendar.TimeZone.STANDARD) {
			bias := this.bias + this.Setting.Standard.bias
		} else if (this.iD = Calendar.TimeZone.DAYLIGHT) {
			bias := this.bias + this.Setting.Daylight.bias
		}
		return bias
	}
}
