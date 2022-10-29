class TimeZone {

	static UNKWOWN  :=  0
	static STANDARD :=  1
	static DAYLIGHT :=  2
	static INVALID  := -1

	iD := 0
	bias := 0
	year := 0

	; ahklint-ignore-begin: W003
	setting
		:= { standard : { bias: 0
			, name: ""
			, date: { day: 0
				, dayOfWeek: 0
				, year: 0
				, month: 0
				, hour: 0
				, minute: 0 } }
		, Daylight : { bias: 0
			, name: ""
			, date: { Day: 0
				, dayOfWeek: 0
				, year: 0
				, month: 0
				, hour: 0
				, minute: 0 } } }
	; ahklint-ignore-end

	__new() {
		tzi := new TIME_ZONE_INFORMATION().implode(_tzi)
		this.iD := DllCall("GetTimeZoneInformation", "Ptr", &_tzi)
		if (this.iD != Calendar.TimeZone.INVALID) {
			tzi.explode(_tzi)
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

	forYear(aYear="") {
		this.year := (aYear != "" ? aYear : A_Year)
		tzi := new TIME_ZONE_INFORMATION().implode(_tzi)
		if (DllCall("GetTimeZoneInformationForYear", "UShort", aYear
				, "Ptr", 0, "Ptr", &_tzi, "UChar")) {
			tzi.explode(_tzi)
			this.bias := tzi.bias
			this.Setting.Standard.bias := tzi.StandardBias
			this.Setting.Standard.name := tzi.StandardName
			this.Setting.Standard.Date.day := tzi.StandardDate.wDay
			this.Setting.Standard.Date.dayOfWeek := tzi.StandardDate.wDayOfWeek
			this.Setting.Standard.Date.year := tzi.StandardDate.wYear
			this.Setting.Standard.Date.month := tzi.StandardDate.wMonth
			this.Setting.Standard.Date.hour := tzi.StandardDate.wHour
			this.Setting.Standard.Date.minute := tzi.StandardDate.wMinute
			this.Setting.Daylight.bias := tzi.DaylightBias
			this.Setting.Daylight.name := tzi.DaylightName
			this.Setting.Daylight.Date.day := tzi.DaylightDate.wDay
			this.Setting.Daylight.Date.dayOfWeek := tzi.DaylightDate.wDayOfWeek
			this.Setting.Daylight.Date.year := tzi.DaylightDate.wYear
			this.Setting.Daylight.Date.month := tzi.DaylightDate.wMonth
			this.Setting.Daylight.Date.hour := tzi.DaylightDate.wHour
			this.Setting.Daylight.Date.minute := tzi.DaylightDate.wMinute
		}
		return this
	}

	beginOfDaylighSavingTime() {
		return this.getTimestampFromSetting(this.Setting.Daylight.Date)
	}

	endOfDaylighSavingTime() {
		return this.getTimestampFromSetting(this.Setting.Standard.Date)
	}

	getTimestampFromSetting(aSettingDate) {
		ts := new Calendar(this.year)
				.setAsMonth(aSettingDate.month)
				.setAsDay(1)
				.setAsHour(aSettingDate.hour)
				.setAsMinutes(aSettingDate.minute)
		return ts.findWeekDay(aSettingDate.dayOfWeek + 1
				, (aSettingDate.day != 5 ? aSettingDate.day : -1))
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
