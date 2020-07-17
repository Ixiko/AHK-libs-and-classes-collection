class DateTools {
	; written by Roy Miller, 2015 Jul 10
	; these are a collection of date related tools lumped together into a class
	; to use these you can simply call them as datetools.<method name>
	SyntaxExamples() {

		Today := New date					; sets the date to today
		strMessage .= "`n'" . Today.Format("yyyy.MM.dd-HH:mm:ss") . "' = ThisDate"   ; return the formatted datetime

		strMessage .= "`n'" . Today.Till . "' = Till 1 "
		Today.Till := "19711121042100"
		strMessage .= "`n'" . Today.Till . "' = Till 2"


		strMessage .= "`n'" . Today.Add({Decades:1, Years:-1, Months:1, Days:-1, Hours:1, Minutes:-1, Seconds:10}) . "' = Add {Decades:1, Years:-1, Months:1, Days:-1, Hours:1, Minutes:-1, Seconds:10}"
		strMessage .= "`n'" . Today.Add({Decades:-1, Years:1, Months:-1, Days:1, Hours:-1, Minutes:1, Seconds:-10}) . "' = subtract {Decades:-1, Years:1, Months:-1, Days:1, Hours:-1, Minutes:1, Seconds:-10}"

		strMessage .= "`n"

		StaticDate := New date
		strMessage .= "`n'" . StaticDate.Format . "' = Static "


		StaticDate.Add({Decades:10, Years:-1, Months:1, days:-1, Hours:1, Minutes:-1, Seconds:10})  ; do some date math, note the blend of adding, subtracting, and multiple date parts
		StaticDate.Add({Weekdays: -10})

		StaticDate.Day := 21

		StaticDate.Year := 1971	; set the year

		StaticDate.Month := 11

		StaticDate.Meridian := {am:"pm", pm:"am"}[StaticDate.Meridian]

		StaticDate.Add({Score:-4, Years:-7})

		strMessage .= "`n'" . StaticDate.Format . "' = Static after multiple math "
		 TimeSpan := StaticDate.TimeSpan(Today)	; calculate the difference between Today, which was set earlier, and our StaticDate which we have been modifying
		 strMessage .= "`n`nTimeSpan between '" . Today.Format . "' and '" . StaticDate.Format . "'"
		 strMessage .= "`n" . StaticDate.TimeSpan(Today).HumanReadable

		StaticDate.Till
		strMessage .= "`n"
		strMessage .= "`n'" . StaticDate.Till . "' = Till"

		 strMessage .= "`n'" . StaticDate.Format . "' = Format 2"
		 strMessage .= "`n'" . (StaticDate.Format := "yyyyMMdd-HH") . "' = Format 3 should save"
		 strMessage .= "`n'" . StaticDate.Format . "' = Format 4"

		 strMessage .= "`n`n'" . Today.Parse().DayOfWeek.NameLong . "' = Day of week"

		 StaticDate := New date("2015Dec31") 	; sets the date to a static value.
		 strMessage .= "`n`n'" . (StaticDate.Epoch := 1437082574) . "' = Set Epoch, should be '20150716-213614'"


		 StaticDate.Format("yyyy.MM.dd MMM")
		 strMessage .= "`n'" . (StaticDate.Month := 1) . "' = Set Month 1"
		 strMessage .= "`n'" . (StaticDate.Month := "Feb") . "' = Set Month Feb"
		 strMessage .= "`n'" . (StaticDate.Month := "March") . "' = Set Month March"

		 StaticDate.Format("yyyy.MM.dd ddd")
		 strMessage .= "`n'" . (StaticDate.DayOfWeek := 1) . "' = Set Day of week 1"
		 strMessage .= "`n'" . (StaticDate.DayOfWeek := "Tue") . "' = Set Day of week Tue"
		 strMessage .= "`n'" . (StaticDate.DayOfWeek := "Wednesday") . "' = Set Day of week Wednesday"
		 strMessage .= "`n'" . (StaticDate.Add({Mondays: "Previous"})) . "' = Set Day of previous Monday"
		 strMessage .= "`n'" . (StaticDate.Add({Thursdays: "Next"})) . "' = Set Day of Following Thrusday"

		 StaticDate := New date("20150716213614") 		; sets the date to a static value 2015 Apr 01. in this case the format is yyyyJD3, here JD3 is a three digit number of days into the desired year
		 StaticDate.Hour := 21
		 StaticDate.Minute := 36
		 StaticDate.Second := 14

		 strMessage .= "`n'" . StaticDate.Format . "' = New date, should be '20150401-HHmmss'"

		 StaticDate.Add({Decades:1, Years:-1, Months:1, days:-1, Hours:1, Minutes:-1, Seconds:10})  ; do some date math, note the blend of adding, subtracting, and multiple date parts
		 strMessage .= "`n'" . StaticDate.Format("yyyy.MM.dd-HH:mm:ss") . "' = Date Math" 	; change the object's date format and return the formatted DateTime
		 strMessage .= "`n'" . StaticDate.Add({Weekdays: -10}) . "' = Date Math, added -10 weekdays  "

		 strMessage .= "`n'" . (StaticDate.Day := 21) . "' = Changed Day = 21" ; change the object's date format and return the formatted DateTime

		 StaticDate.Year := 1971	; set the year
		 strMessage .= "`n'" . StaticDate.Format . "' = Changed Year = 1971" ; change the object's date format and return the formatted DateTime

		 strMessage .= "`n'" . (StaticDate.Month := 11) . "' = Changed Month = 11" ; change the object's date format and return the formatted DateTime

		 StaticDate.Meridian := {am:"pm", pm:"am"}[StaticDate.Meridian]   	; toggle the AM/PM
		 strMessage .= "`n'" . StaticDate.Format . "' = Changed Meridian = '" . StaticDate.Meridian . "'" ; change the object's date format and return the formatted DateTime

		 strMessage .= "`n'" . StaticDate.Add({Score:-4, Years:-7}) . "' = Date Math, four score and seven years ago"

		 TimeSpan := StaticDate.TimeSpan(Today)	; calculate the difference between Today, which was set earlier, and our StaticDate which we have been modifying
		 strMessage .= "`n`nTimeSpan between '" . Today.Format . "' and '" . StaticDate.Format . "'`n" . DateTools.ReportOptions(TimeSpan)

		 strMessage .= "`n`n'" . TimeSpan.HumanReadable . "' =Human1"
		 strMessage .= "`n'" . StaticDate.TimeSpan(Today).HumanReadable . "' =Human2"

		 RandomDate := New Date("19711121042100")
		 ; note that we set StaticDate.Till to Today in the TimeSpan functions above
		 strMessage .= "`n`n'" . RandomDate.Format("yyyy MMM dd") . "' '" . {1:"is", 0:"is not"}[StaticDate.IsAfter(RandomDate)] . "' after date: '" . StaticDate.Format("yyyy-MM/dd") . "'"
		 strMessage .= "`n'" . RandomDate.Format("yyyy MMM dd") . "' '" . {1:"is", 0:"is not"}[StaticDate.IsBefore(RandomDate)] . "' before date: '" . StaticDate.Format("yyyy,MM-dd") . "'"
		 strMessage .= "`n'" . RandomDate.Format("yyyy MMM dd") . "' '" . {1:"is", 0:"is not"}[StaticDate.IsEqual(RandomDate)] . "' equal to date: '" . StaticDate.Format("yyyy-MM_dd") . "'"
		 strMessage .= "`n'" . RandomDate.Format("yyyy MMM dd") . "' '" . {1:"is", 0:"is not"}[StaticDate.IsBetween := RandomDate] . "' between dates: '" . StaticDate.Format("yyyy!MM-dd") . "' and '" . Today.Format . "'"

		StaticDate.Add(-1) := TimeSpan
		 strMessage .= "`n'" . StaticDate.Format("yyyy.MM.dd-HH:mm:ss") . "' = return to '"	. Today.Format("yyyy.MM.dd-HH:mm:ss") . "'"

		MsgBox, % strMessage
		} ; end SyntaxExamples

	NextDay( DateTime, IncrementDirection=1, Type="Weekdays") {
		; returns datetime if datetime is a already the desired day type
		NextDay := Object()
		NextDay.Weekdays 	:= {-1:{Saturday:-1, Sunday:-2}, 1:{Saturday:2, Sunday:1}}
		NextDay.Weekends 	:= {-1:{Monday:-1, Tuesday:-2, Wednesday:-3, Thursday:-4, Friday:-5}, 1:{Monday:5, Tuesday:4, Wednesday:3, Thursday:2, Friday:1}}
		NextDay.Mondays 	:= {-1:{Monday:0, Tuesday:-1, Wednesday:-2, Thursday:-3, Friday:-4, Saturday:-5, Sunday:-6}, 1:{Monday:0, Tuesday:6, Wednesday:5, Thursday:4, Friday:3, Saturday:2, Sunday:1}}
		NextDay.Tuesdays 	:= {-1:{Monday:-6, Tuesday:0, Wednesday:-1, Thursday:-2, Friday:-3, Saturday:-4, Sunday:-5}, 1:{Monday:1, Tuesday:0, Wednesday:6, Thursday:5, Friday:4, Saturday:3, Sunday:2}}
		NextDay.Wednesdays 	:= {-1:{Monday:-5, Tuesday:-6, Wednesday:0, Thursday:-1, Friday:-2, Saturday:-3, Sunday:-4}, 1:{Monday:2, Tuesday:1, Wednesday:0, Thursday:6, Friday:5, Saturday:4, Sunday:3}}
		NextDay.Thursdays 	:= {-1:{Monday:-4, Tuesday:-5, Wednesday:-6, Thursday:0, Friday:-1, Saturday:-2, Sunday:-3}, 1:{Monday:3, Tuesday:2, Wednesday:1, Thursday:0, Friday:6, Saturday:5, Sunday:4}}
		NextDay.Fridays 	:= {-1:{Monday:-3, Tuesday:-4, Wednesday:-5, Thursday:-6, Friday:0, Saturday:-1, Sunday:-2}, 1:{Monday:4, Tuesday:3, Wednesday:2, Thursday:1, Friday:0, Saturday:6, Sunday:5}}
		NextDay.Saturdays 	:= {-1:{Monday:-2, Tuesday:-3, Wednesday:-4, Thursday:-5, Friday:-6, Saturday:0, Sunday:-1}, 1:{Monday:5, Tuesday:4, Wednesday:3, Thursday:2, Friday:1, Saturday:0, Sunday:6}}
		NextDay.Sundays 	:= {-1:{Monday:-1, Tuesday:-2, Wednesday:-3, Thursday:-4, Friday:-5, Saturday:-6, Sunday:0}, 1:{Monday:6, Tuesday:5, Wednesday:4, Thursday:3, Friday:2, Saturday:1, Sunday:0}}

		DateTime += NextDay[Type][IncrementDirection][DateTools.DayOfWeek(DateTime, "NameLong")], days
		return, % datetime
		} ; end NextDay

	Formatted(DateTime, DesiredFormat="yyyyMMddHHmmss"){
		FormatTime, Output, %DateTime%, %DesiredFormat%
		Return, % Output
		} ; end Formatted

	Epoch(DateTime) {
		; DateTime needs to already in yyyyMMddHHmmss format, to prevent a recursive loop with .parse
		; returns the epoch time
		DateTime -= 1970, seconds
		Return, % DateTime
		} ; end function DateToolsEpoch

	EpochToDate(Epoch="") {
		; converts a epoch time to datetime format
		DateTime = 19700101000000
		DateTime += Epoch, seconds
		Return, % DateTime
		} ; end function EpochToDate

	DateDIFF( B, E, U="S" ) {
		E -= %B%,%U%
		Return E
		} ; end DateDiff

	DateADD( DateTime, Value, Units="S" ) {
		DateTime += %Value%,%Units%
		Return DateTime
		} ; end DateAdd

	IsLeapYear( DateTime ) {
		return, % {365:false, 366:true}[DateTools.LDOY(DateTime)]
		} ; end IsLeapYear

	LDOY( DateTime ) {	; Last Day of Year
		; receives a standard DateTime in yyyyMMddHHmmss
		; returns the total number of days in the year
		Year := SubStr(DateTime,1,4) . "1231"
		FormatTime, Output, %Year%, Yday
		Return, % Output
		} ; end LDOY

	LDOM( DateTime ) { ; Last Day of Month
		DaysInMonths := {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31, 366:29, 365:28 }
		Month := SubStr(DateTime, 5, 2)
		return , % Month = 2 ? DaysInMonths[DateTools.LDOY(DateTime)] : DaysInMonths[Month]
		} ; end LDOM

	DayOfWeek(DateTime, Type="") {
		; to prevent circular references, DateTime must already be in yyyyMMddHHmmss format
		; Type can be either NameLong, NameShort, Number, or blank,
		FormatTime, day_of_Week, %DateTime%, dddd

		Output := Object()
		Output.NameLong := day_of_week
		Output.NameShort := SubStr(day_of_week, 1, 3)
		Output.Number := {Monday:1, Tuesday:2, Wednesday:3, Thursday:4, Friday:5, Saturday:6, Sunday:7}[day_of_week]

		return, % ( Type = "" ? Output : Output[Type] )
		} ; end function funDayOfWeek

	Add(Param, DateTime, Multiplier="SameDirection" ) {
		; adds the desired number of years, months, days, hours, minutes, seconds, weeks, fortnights, quarters, decades, score, centuries, weekdays, weekends, NextWeekend, NextWeekday
		;
		; notes, does not authotkey does not handle dates before year 1600
		; example
		; LastYear.Add({Years:-1, Months:-1, Days:-1, Hours:-1, Minutes:-1, Seconds:-10})
		; strMessage .= "`n'" . LastYear.Format . "' = ThisDate"
		if (IsObject(Param)) {
			} else {
			Param := {Seconds:Param}
			} ; end if

		MultiplierOptions := {"SameDirection":1, "Reverse":-1}
		Multiplier := MultiplierOptions.HasKey(Multiplier) ? MultiplierOptions[Multiplier] : Multiplier
		Months := Days := Seconds := 0

		; deal with date elements that translate directly into Seconds
		for UnitOfMeasure, Units in {Seconds:1, Minutes:60, Hours:3600} {
			Seconds 	+= Param.HasKey(UnitOfMeasure) ? Param[UnitOfMeasure] * Units	: 0
			} ; next UnitOfMeasure
		DateTime += Seconds * Multiplier, Seconds

		; deal with date elements that translate directly into Days
		for UnitOfMeasure, Units in {Days:1, Weeks:7, Fortnights:14} {
			Days 	+= Param.HasKey(UnitOfMeasure) ? Param[UnitOfMeasure] * Units	: 0
			} ; next UnitOfMeasure
		DateTime += Days * Multiplier, Days

		; deal with date elements that can translate directly into months
		; calculate months last because the odd nature of how the function deals with the days at the end of the month
		for UnitOfMeasure, Units in {Months:1, Quarters:3, Years:12, Biennium:24, Triennium:36, Olympiad:48, Lustrum:60, Decades:120, Indiction:180, Score:240, Jubilee:600, Centuries:1200} {
			Months 	+= Param.HasKey(UnitOfMeasure) ? Param[UnitOfMeasure] * Units	: 0
			} ; next UnitOfMeasure
		DateTime := DateTools.AddMonths(Months * Multiplier, DateTime)

		; move DateTime to the next day type
		for Index, Type in ["NextWeekday", "NextWeekend"] {
			if ( Param.HasKey(Type) ) {
				IncrementDirection := (Param[Type] < 0 ? -1 : 1)
				DateTime := DateTools.NextDay( DateTime, (Param[Type] < 0 ? -1 : 1), {NextWeekday:"Weekdays", NextWeekend:"Weekends"}[Type] )
				} ; end if
			} ; next type

		; counting weekdays or weekends needs to be done after calculating months to ensure we do not land on an undesirable day of week
		for Index, DayOfWeek in ["Weekdays", "Weekends", "Mondays", "Tuesdays", "Wednesdays", "Thursdays", "Fridays", "Saturdays", "Sundays"] {
			if ( Param.HasKey(DayOfWeek) ) {
				IncrementDirection := Param.Weekends < 0 ? -1 : 1
				IncrementCount := Param[DayOfWeek]
				; deal with -0 and +0
				if ( Param[DayOfWeek] = "Previous" ) {
					IncrementCount := 0
					IncrementDirection := -1
					} ; end if
				if ( Param[DayOfWeek] = "Next" or Param[DayOfWeek] = 0 ) {
					IncrementCount := 0
					IncrementDirection := 1
					} ; end if

				; move date to the next day of this type, if already on the next day of this type then we'll stay here
				DateTime := DateTools.NextDay( DateTime, IncrementDirection, DayOfWeek )

				; move date the desired number of days to accommodate the entire move
				; note that we already moved to the first of this day type above with NextDay
				if ( IncrementCount-- ) {
					DaysInSeries := {Weekdays:5, Weekends:2, Mondays:1, Tuesdays:1, Wednesdays:1, Thursdays:1, Fridays:1, Saturdays:1, Sundays:1}[DayOfWeek]
					DateTime += (floor(abs(IncrementCount) / DaysInSeries) * IncrementDirection * 7) + mod(IncrementCount, DaysInSeries) * Multiplier, days
					} ; end if

				; one last check to ensure we've landed on the correct day type, I agree this is probably overkill.
				; DateTime := DateTools.NextDay( DateTime, IncrementDirection, DayOfWeek )
				} ; end if Param.HasKey(DayOfWeek)
			} ; next weekday
		return, % DateTime
		} ; end Add

	AddMonths(months, DateTime) {
		; accepts date in yyyyMMddHHmmss format
		; adds the desired number of months to the date
		; returns new date in yyyyMMddHHmmss format
		;
		; Rules: if the desired day of the new month is after the total number of days in the month then this will select the last day of the month.
		;
		; example
		; strDate := date.AddMonths(3, 0, a_now)
		;
		if ( ! months ) {
			return DateTime
			} ; end if

		DaysInMonths := {0:31, 1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31, 13:31, 366:29, 365:28}
		, IncrementDirection := months < 0 ? -1 : 1
		, Year 			:= DateTools.Formatted(DateTime, "yyyy") + ( floor(abs(Months) / 12) * IncrementDirection )
		, Month 		:= DateTools.Formatted(DateTime, "MM") + mod(Months,12)
		, DesiredDay 	:= DateTools.Formatted(DateTime, "dd")

		; normalize the Month and carry a year
		if ( Month < 1 ) {
			Month := Month + 12
			, Year --
			} ; end if
		if ( Month > 12 ) {
			Month := Month - 12
			, Year ++
			} ; end if

		; calculate the number of days in February
		if ( Month = 2 ) {
			DaysInMonths[2] := DaysInMonths[DateTools.LDOY(Year)]
			} ; end if

		; use the correct day
		Day := DesiredDay < DaysInMonths[Month] ? DesiredDay : DaysInMonths[Month]

		return, % substr("0000" . Year, -3) . substr("00" . Month, -1) . substr("00" . Day, -1) . DateTools.Formatted(DateTime, "HHmmss")
		} ; End function AddMonths

	TimeSpan(Till, When) {
		; receives two DateTime values
		;	Till : defaults to this.till, or a_now if not passed
		;	When : defaults to this.DateTime or a_now if not passed
		; calculates the difference between the DateTime values
		; returns a Hashtable of all the different demonstrates

		Output := Object()
		, RangeBegin := Output.Till 	:= Till
		, RangeEnd	 := Output.When 	:= When

		; swap dates to make Till
		if ( Output.Till > Output.When ) {
			RangeBegin := Output.When
			, RangeEnd := Output.Till
			, IncrementDirection := -1
			} else {
			IncrementDirection := 1
			} ; end if

		Output.TillEpoch 		:= DateTools.Epoch(Output.Till)
		Output.WhenEpoch 		:= DateTools.Epoch(Output.When)

		Output.TotalSeconds 	:= Output.TillEpoch - Output.WhenEpoch
		, Output.TotalMinutes 	:= Output.TotalSeconds  / 60
		, Output.TotalHours 	:= Output.TotalMinutes / 60
		, Output.TotalDays 		:= Output.TotalHours  / 24
		, Output.TotalWeeks 	:= Output.TotalDays  / 7

		; calculate the actual number of days, months, and years.
		; note this complexity is required to overcome the varying month and year lengths
		, Output.Years := Output.Months := Output.Days := 0

		; check to see if the beginning date is after Feb29, if so then no need to include the leap day,
		DaysToSeconds := {28:2419200, 29:2505600, 30:2592000, 31:2678400, 365:31536000, 366:31622400}
		SecondsInYear := DaysToSeconds[RangeBegin > SubStr(RangeBegin,1,4) . "0229235959" ? 365 : DateTools.LDOY(RangeBegin)]
		If ( DateTools.DateDiff(RangeBegin,RangeEnd) >= SecondsInYear ) {
			RangeBegin := DateTools.DateAdd(RangeBegin,SecondsInYear)
			, Output.Years += IncrementDirection
			} ; end if

		Loop {
			SecondsInYear := DaysToSeconds[DateTools.LDOY(RangeBegin)]
			If ( DateTools.DateDiff(RangeBegin,RangeEnd) >= SecondsInYear ) {
				RangeBegin := DateTools.DateAdd(RangeBegin,SecondsInYear)
				, Output.Years += IncrementDirection
				} else {
				Break
				} ; end if
			} ; end loop years
		Loop {
			SecondsInMonth := DaysToSeconds[DateTools.LDOM(RangeBegin)]
			If ( DateTools.DateDiff(RangeBegin,RangeEnd) >= SecondsInMonth ) {
				RangeBegin := DateTools.DateAdd(RangeBegin,SecondsInMonth)
				, Output.Months += IncrementDirection
				} else {
				Break
				} ; end if.
			} ; end loop months

		; deal with the remaining days
		Output.Days := floor(DateTools.DateDiff(RangeBegin,RangeEnd) / 86400)
		RangeBegin += Output.Days, Days
		Output.Days *= IncrementDirection

		; deal with the remaining time units
		Remainder := DateTools.DateADD("16010101", DateTools.DateDIFF(RangeBegin,RangeEnd))
		HMS := 	DateTools.Formatted(Remainder, "HH:mm:ss")
		Output.Hours := SubStr(HMS, 1,2) * IncrementDirection
		Output.Minutes := SubStr(HMS, 4,2) * IncrementDirection
		Output.Seconds := SubStr(HMS, 7,2) * IncrementDirection

		; build human readable format, only include non-zero date parts
		Output.HumanReadable := ""
		for Index, Type in ["years", "months", "days", "hours", "minutes", "seconds"] {
			Output.HumanReadable .= Output[Type] ? Output[Type] . " " . Type . " " : ""
			} ; next type

		Return, % Output
		} ; end TimeSpan

	JulianDates(DateTime=""){
		; these dates follow the rules listed on https://en.wikipedia.org/wiki/Julian_day
		; receive DateTime in yyyyMMddHHmmss format, if not passed then uses This[]
		; returns either a hash, or if Type is specified then returns the 5 or 7 digit value
		Output := Object()

		if ( DateTime ) {
			Year 		:= substr(DateTime, 1, 4)
			, Month 	:= substr(DateTime, 5, 2)
			, Day 		:= substr(DateTime, 7, 2)
			} else {
			Year 		:= This.Year
			, Month 	:= This.Month
			, Day 		:= This.Day
			, DateTime:= This.DateTime
			} ; end if
		Day := Day * 1
		if (Month < 3) {
			Month += 12
			, Year--
			} ; end if
		A := (14 - Month) // 12
		, Year := Year + 4800 - A
		, Month := Month + (12 * A) - 3

		, Output.DateTime		:= DateTime
		, Output.Date 			:= Day + ((153* Month +2)//5) + (365 * Year) + (Year //4) - (Year //100) + (Year //400) - 32045
		, Output.Reduced 		:= Output.Date - 2400000
		, Output.Modified 		:= Output.Date - 2400000.5
		, Output.Truncated		:= floor(Output.Date - 2440000.5)
		, Output.Dublin	 		:= Output.Date - 2415020
		, Output.Lilan			:= floor(Output.Date - 2299159.5)
		, Output.RataDie		:= floor(Output.Date - 1721424.5)
		, Output.Unix			:= (Output.Date - 2440587.5) * 86400  ; note this time is calculated to the beginning of the day and does not include all the seconds accumulated during the day, If you need the exact number of seconds, then use DateTools.Epoch instead
		, Output.Epoch			:= This.Epoch(DateTime)
		, Output.MarsSol		:= (Output.Date - 2405522)/1.02749

		FormatTime, JulianDay, DateTime, YDay0
		Output.Day			:= JulianDay

		return, % Output
		} ; end function JulianDates

	JulianDateToDateTime(JulianDate, Year){
		; receives a 5 or 7 digit julian date {Date|Reduced}
		; receives a 3 digit julian day and assumes it to be in the current year
		; returns DateTime in the format yyyyMMddHHmmss
		; note funny things start to happen if we get close to time in memorial
		if ( StrLen(JulianDate) <= 3 ) {
			Output := Year ? Year : A_YYYY
			Output += JulianDate - 1, days
			return, % Output

			} else {
			; string lengths = 5 or 7
			JulianDate := StrLen(JulianDate) = 7 ? JulianDate - 2400000 : JulianDate

			A := JulianDate + 2468569
			, C := JulianDate//36524+68
			, F := (A-(((146097*C)+3)//4))
			, g := (4000*(F+1)//1461001)
			, L := F-(1461*g//4)+31
			, J := (80*L)//2447
			, Day := L-(2447)*J//80
			, B := J//11
			, Month := J+2-(12*B)
			, Year := (100*(C-49))+g+B

			return, % Year . SubStr( "00" . Month , -1 ) . SubStr( "00" . Day , -1 ) . "000000"
			} ; end if Julian date length <= 3
		} ; end function JulianDateToDateTime

	Parse(DateTime, Favor="American") {
		; receives a date string and returns a hash of date parts
		; parts that are not included in the provided string will be derived from A_Now
		; the regex currently assumes american dates formats
		; Favor can be {American|British} and essentially describes the American mm/dd or European dd/mm format (listed here in alphabetical order), note American is the default
		Regex := "OJix)"
			. "(?(DEFINE)"
			. "(?<Year4>         [0-9]{4})"
			. "(?<Year2>         [0-9]{2})"
			. "(?<MonthNames>    Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sept?(?:ember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
			. "(?<MonthDigits2>  0[0-9]|1[012])"
			. "(?<MonthDigits1>  1[012]|[0-9])"
			. "(?<DayNames>      (?:Mon|Tues?|Wed(?:nes)?|Thu(?:rs)?|Fri|Sat(?:ur)?|Sun)(?:day)?)"
			. "(?<JulianDay>     [012][0-9][0-9]|3[0-5][0-9]|36[0-6])"
			. "(?<DayDigits2>    [012][0-9]|3[012])"
			. "(?<DayDigits1>    [012][0-9]|3[012]|[0-9])"
			. "(?<Hour2>         [01][0-9]|2[0123])"
			. "(?<Hour1>         1[0-9]|2[0123]|[0-9])"
			. "(?<Minute2>       [012345][0-9])"
			. "(?<Second2>       [012345][0-9])"
			. "(?<Meridian>      [ap]m)"
			. "(?<Zone>          (?:gmt|z))"
			. "(?<TimeCharacter> t)"
			. "(?<DateSeperator> [-/])"
			. "(?<TimeSeperator> :)"
			. ")"
			. ""
			. "\A"
			. "(?<EntireString>"
				; yyyyMMdd-HHmmss, yyyyMMddHHmmss
				; yyyyMMdd-HHmm, yyyyMMddHHmm
				; yyyyMMdd-HH, yyyyMMddHH
				; yyyyMMdd, yyyyMMMdd
				; yyyyMM, yyyyMMM
				; yyyy
				. "(?<f0>     (?<Year4>(?&Year4)) (?: (?:(?<Month>(?&MonthDigits2))|(?<MonthName>(?&MonthNames))) (?:(?<Day>(?&DayDigits2)) (?:-? (?<Hour>(?&Hour2)) (?:(?<Minute>(?&Minute2)) (?:(?<Second>(?&Second2)))?)?)?)?)? )"

				; MMM-dd-yyyy
				; MMM-dd-yy
				; MMMyyyy
				. "|(?<f1>    (?<MonthName>(?&MonthNames)) (?:(?<Year4>(?&Year4)) | (?&DateSeperator)(?<Day>(?&DayDigits2))(?&DateSeperator) (?:(?<Year2>(?&Year2))|(?<Year4>(?&Year4))) )"

				; H:MM am, d MMM yyyy
				. "|(?<f2>    (?<Hour>(?&Hour1))(?&TimeSeperator)(?<Minute>(?&Minute2))\s(?<Meridian>(?&Meridian)),\s(?<Day>(?&DayDigits1))\s(?<MonthName>(?&MonthNames))\s(?<Year4>(?&Year4)))"

				; H:MM am MMM d, yyyy
				. "|(?<f3>    (?<Hour>(?&Hour1))(?&TimeSeperator)(?<Minute>(?&Minute2))\s(?<Meridian>(?&Meridian))\s(?<MonthName>(?&MonthNames))\s(?<Day>(?&DayDigits1)),\s(?<Year4>(?&Year4)))"

				; H:mm:ss am
				; H:mm ss am
				; H:mm am
				; H:mm
				; HH:mm
				. "|(?<f14>   (?<Hour>(?&Hour1)|(?&Hour2))(?&TimeSeperator)(?<Minute>(?&Minute2)) (?:(?:(?&TimeSeperator)|\s)(?<Second>(?&Second2)))? (?:\s(?<Meridian>(?&Meridian)))? )"

				; ddd, dd MMM yyyy H:mm:ss gmt
				; dd MMM yyyy HH:mm:ss
				; d MMM yyyy
				; dd MMM yyyy
				; dd-MMM-yy
				; dd-MMM-yyyy
				. "|(?<f12>   (?:(?<DayName>(?&DayNames)),\s)? (?<Day>(?&DayDigits1)|(?&DayDigits2))(?:(?&DateSeperator)|\s)(?<MonthName>(?&MonthNames))(?:(?&DateSeperator)|\s) (?:(?<Year4>(?&Year4))|(?<Year2>(?&Year2))) (?:\s(?<Hour>(?&Hour1)|(?&Hour2))(?&TimeSeperator)(?<Minute>(?&Minute2))(?&TimeSeperator)(?<Seconds>(?&Second2)) (?:\s(?<Zone>(?&Zone)))?)? )"

				if ( Favor="European" ) {
					; ddd dd-MM-yyyy
					; dd-MM-yyyy
					; dd-MM-yy
					Regex .= "|(?<f16>   (?<DayName>(?&DayNames))\s)? (?<Day>(?&DayDigits2))(?&DateSeperator)(?<Month>(?&MonthDigits2))(?&DateSeperator) (?:(?<Year4>(?&Year4))|(?<Year2>(?&Year2))) )"

					} else {
					; ddd MM-dd-yyyy
					; MM-dd-yyyy
					; MM-dd-yy
					Regex .= "|(?<f16>   (?<DayName>(?&DayNames))\s)? (?<Month>(?&MonthDigits2))(?&DateSeperator)(?<Day>(?&DayDigits2))(?&DateSeperator) (?:(?<Year4>(?&Year4))|(?<Year2>(?&Year2))) )"
					} ; end if

				Regex .= ""
				; yyyy-MM-ddTHH:mm:ss gmt
				. "|(?<f7>    (?<Year4>(?&Year4))(?&DateSeperator)(?<Month>(?&MonthDigits2))(?&DateSeperator)(?<Day>(?&DayDigits2)) (?:(?&TimeCharacter)|\s) (?<Hour>(?&Hour2))(?&TimeSeperator)(?<Minute>(?&Minute2))(?&TimeSeperator) (?:(?<Seconds>(?&Second2))\s(?<Zone>(?&Zone)))? )"

				; yyyyJD0   = 2015001 = "2015 Jan 01";  2015365 = "2015 Dec 31"
				; JDO		= zero padded three digit number
				. "|(?<f26>   (?<Year4>(?&Year4))? (?<JulianDay>(?&JulianDay)))"
				. ")"
			. "\Z"
		DateTime := IsObject(DateTime) ? DateTime.DateTime : DateTime

		; parse DateTime into parts
		RegExMatch(DateTime, Regex, Matches)

		if ( Matches.EntireString = "" and DateTime <> "" ) {
			strMessage .= "`n`n---warning date not matched---`n"
			debug := true
			} ; end if

		if ( debug ) {
			strMessage .= "`n`nMatches"
			for Index, Name in ["Year4", "Year2", "Month", "MonthName", "Day", "DayName", "Hour", "Minute", "Second", "JulianDay"] {
				strMessage .= "`n" . Name . " = '" . Matches[Name] . "'"
				} ; next name
			} ; end debug

		; clean up the date portions
		DatePart := Object()

		; set the year, favor the 4 digit year version over a 2 digit year.
		If ( Matches.Year2 and Matches.Year4 = "" ) {
			; 2 digit year falls into a range between 1950 - 2049
			DatePart.Year := Matches.Year2 <= 50 ? 1900 : 2000
			DatePart.Year += Matches.Year2 * 1
			} else {
			DatePart.Year 		:= Matches.Year4 = "" 		? A_YYYY 			: Matches.Year4
			} ; end if

		; if date came form a Julian day, then we can infer the month and day
		if ( Matches.JulianDay ) {
			Temp := DateTools.JulianDateToDateTime(Matches.JulianDay, DatePart.Year)
			DatePart.Month := substr(temp, 5,2)
			DatePart.Day := substr(temp, 7,2)
			} ; end if

		; cleanse the month
		if ( ! DatePart.Month ) {
			DatePart.Month 		:= Matches.MonthName = "" 	? A_MM				: {Jan:1, Feb:2, Mar:3, Apr:4, May:5, Jun:6, Jul:7, Aug:8, Sep:9, Oct:10, Nov:11, Dec:12}[ SubStr(Matches.MonthName, 1, 3) ]
			DatePart.Month 		:= Matches.Month = "" 		? DatePart.Month 	: Matches.Month
			} ; end if
		DatePart.MonthName	 	:= ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][DatePart.Month]

		; cleanse the day
		if ( ! DatePart.Day ) {
			DatePart.Day 		:= Matches.Day = "" 		? A_DD 				: Matches.Day
			} ; end if

		; cleanse the time
		DatePart.Hour 			:= Matches.Hour = "" 		? A_Hour 			: Matches.Hour
		DatePart.Minute 		:= Matches.Minute = "" 		? A_Min 			: Matches.Minute
		DatePart.Second 		:= Matches.Second = "" 		? A_Sec 			: Matches.Second

		; correct for Meridian and 24 hour mismatches
		; if meridian is present then we'll assume it's correct and update the hour to 24 hour format
		if ( Matches.Meridian ) {
			if ( DatePart.Hour < 12 and regexMatch( Matches.Meridian, "^pm$" ) ) {
				DatePart.Hour += 12
				} ; end if
			if ( DatePart.Hour >= 12 and regexMatch( Matches.Meridian, "^am$" ) ) {
				DatePart.Hour -= 12
				} ; end if

			} else {
			DatePart.Meridian := DatePart.Hour >= 12 ? "pm" : "am"
			} ; end if

		; pad two digit values with leading zeros
		for Index, Name in ["Month", "Day", "Hour", "Minute", "Second"] {
			DatePart[Name] := SubStr( "00" . DatePart[Name] , -1 )
			} ; next name

		; create DateTime
		DatePart.DateTime 		:= DatePart.Year . DatePart.Month . DatePart.Day . DatePart.Hour . DatePart.Minute . DatePart.Second

		; create miscellaneous date values
		DatePart.DayOfWeek 		:= DateTools.DayOfWeek(DatePart.DateTime)
		DatePart.Epoch			:= DateTools.Epoch(DatePart.DateTime)
		DatePart.IsLeapYear		:= DateTools.IsLeapYear(DatePart.DateTime)

;		DatePart.Julian			:= This.JulianDates := DatePart.DateTime
;
		if ( debug ) {
			strMessage .= "`n`nDatePart " . DateTools.ReportOptions(DatePart)
			MsgBox, % strMessage
			} ; end if
		return, % DatePart
		} ; end parse

	IsBetween(DateTime, Till="", When="", Resolution="yyyyMMdd") {
		; tests the DateTime to see if it's on or after Till, and on or before When
		; if Till or When are null then gathered from This.Till and This.DateTime
		; notes: this should be read as: on or after the youngest time and before the oldest time
		Resolution := Resolution ? Resolution : "yyyyMMdd"
		, When 		:= DateTools.Formatted(When, Resolution)
		, Till 		:= DateTools.Formatted(Till, Resolution)

		; Swap the older datetime into "till"
		if ( When > Till ) {
			Temp := When
			When := Till
			Till := Temp
			} ; end if

		return, % DateTools.IsAfter(DateTime, When, Resolution) and DateTools.IsBefore(DateTime, Till, Resolution)
		} ; end IsBetween

	IsAfter(DateTime, When="", Resolution="yyyyMMdd") {
		Resolution := Resolution ? Resolution : "yyyyMMdd"
		, When 		:= DateTools.Formatted(When, Resolution)
		, DateTime 	:= DateTools.Formatted(DateTime, Resolution)
		return, % When <= DateTime
		} ; end IsAfter

	IsBefore(DateTime, When="", Resolution="yyyyMMdd") {
		Resolution := Resolution ? Resolution : "yyyyMMdd"
		, When 		:= DateTools.Formatted(When, Resolution)
		, DateTime 	:= DateTools.Formatted(DateTime, Resolution)
		return, % ! DateTools.IsAfter(DateTime, When, Resolution)
		} ; end IsBefore

	IsEqual(DateTime, When="", Resolution="yyyyMMdd") {
		Resolution := Resolution ? Resolution : "yyyyMMdd"
		, When 		:= DateTools.Formatted(When, Resolution)
		, DateTime 	:= DateTools.Formatted(DateTools.Parse(DateTime).DateTime, Resolution)
		return, % DateTime = When
		} ; end IsOn

	ReportOptions(Object, Tree=" ") {
		Output := ""

		for Key, Value in Object {
			if ( IsObject(Value) ) {
				Output .= DateTools.ReportOptions(Value, Tree . "." . Key)
				} else {
				Output .= "`n" . Tree . "." . Key . " = '" . Value . "'"
				} ; end if
			} ; next
		return, % Output
		} ; end ReportOptions

	} ; end DateTools


class Date {

	; written by Roy Miller, 2015 Jul 12
	; builds a date object, complete with methods for manipulating dates and times, via a programmer-friendly interface
	; Dates are automatically parsed from a variety of formats, however the safest format is yyyyMMddHHmmss. This is the autohotkey standard format.
	; When parsing dates, any missing date information will derived from the information provided or will be gathered from A_Now
	; Note, this set of functions may not behave properly for dates before the 1600's
	;
	; MyDate := new Date(value|hash)	: creates a new date object
	; 		value 		                            	: optional, string or date object, defaults to A_Now; The provided value will be parsed and This.DateTime will be set to the yyyyMMddHHmmss format
	;			    		                            	: The provided string can be in any of a variety of formats and will be parsed. Any missing date parts (year,month,day,hour,minute,second) will be collected from A_Now
	; 	    hash	    	                            	: optional, hash containing the desired options
	;	    DateTime	                            	: Date/time in one of the many formats, this will be parsed and will populate This.DateTime
	; 		Till	                                    	: Date/time, optional, only used for calculating differences between dates
	;		Region 	                            	: String, optional, defaults to "American". This describes the region that will be used in the parsing engine for determining the dd/mm or mm/dd formats
	;
	; .Add(Multiplier) := hash             	: Applies date math to This.DateTime. returns This.Format after date math is done
	;
	; .Add(<hash>, Multiplier)             	: Applies date math to This.DateTime. returns This.Format after date math is done
	; 		hash			                            	: Positive values will move the date forward and negative values will move the date backwards.
	;						                            	: hash can contain keys from the following list {years, months, days, hours, minutes, seconds, weeks, fortnights, quarters, decades, score, centuries, weekdays
	;                                                   	  , weekends, NextWeekend, NextWeekday, Mondays, Tuesdays, Wednesdays, Thursdays, Fridays, Saturdays, Sundays}
	;						                            	: the system will process increments in the following order: Days, Months, NextWeekday, NextWeekend, Weekdays, Weekends, Mondays,
	;														  Tuesdays, Wednesdays, Thursdays, Fridays, Saturdays, Sundays
	;		Seconds	                            	: {hours, minutes, seconds} increments are first converted to Seconds then added to the DateTime in one operation.
	;		Days		                            	: {days, weeks, fortnights} increments are first converted to Days then added to the DateTime in one operation.
	; 		Months		                            	: {Months, Quarters, Years, Biennium, Triennium, Olympiad, Lustrum, Decades, Indiction, Score, Jubilee, Centuries} increments are first converted to
	;                                                         months then added to the DateTime in one operation.
	; 		Months		                            	: moves the date the given number of months. If the last day of the month is less than the desired day, then the routine will return the last day of the month.
	;                                                      	  The routine will calculate this correctly for leap years.
	;
	;	NextWeekday                             	: moves to the first Week day, in a given direction, does nothing if the current day is a weekday. a positive value will move forward, a negative value will move backward
	;
	;	NextWeekend                             	: moves to the first Weekend day, in a given direction, does nothing if the current day is a weekend. a positive value will move forward, a negative value will move backward
	;			    		                            	: the following types will move This.DateTime forward or backwards to the next day of a the matching type
	;				    	                            	: if the value is "next" or 0, then we move forward to the next type and stop; if the value is "Previous" then we move backwards to the next type and stop.
	;					                                	: these allow calculations like fourth Thursday, or first Saturday after the second Tuesday.
	;					                                	: these day centric operations are handled after the Day and Month calculations are processed
	;	Weekdays                                	: moves the date the given number of weekdays, and will ignore weekend days
	; 	Weekends                                	: moves the date the given number of weekend days, and will ignore weekdays
	;					                            		 Mondays, Tuesdays, Wednesdays, Thursdays, Fridays, Saturdays, Sundays
	;	Multiplier	                                	: default "SameDirection"; the number of times this will be applied, positive numbers continue in the same direction, negative numbers will reverse direction.
	;                                                    	Also accepts "SameDirection" or "Reverse" as syntactic sugar for 1 or -1  respectively.
	; .TimeSpan(DateTime) := Till    		: Sets This.Till and This.DateTime, and Calculates the difference between This.Till and This.DateTime.
	; .TimeSpan(Till, DateTime)		    	: Calculates the difference between Till and DateTime. Does not set This.Till or This.DateTime
	;					                                	: Returns a hash containing all various TimeSpan Elements, which can be pushed back into a This.Add(<hash>) as the hash to move the same amount of time.
	;		Till		                                	: optional, string or date object, defaults to This.Till
	; 	DateTime	                                	: optional, string or date object, defaults to This.DateTime
	; .DateTime	                                	: returns the This.DateTime in yyyyMMddHHmmss format. See also This.Format
	; 	.Till 			                                	: returns the This.Till date value. If not set then defaults to A_Now
	; .Till := DateTime                        	: sets the This.Till date value. Returns This.Till
	; DateTime                                 		: string in yyyyMMddHHmmss format
	; .JulianDate := DateTime            	: returns the astronomical julian dates extrapolated from This.DateTime see also https://en.wikipedia.org/wiki/Julian_day for more details
	;.JulianDates(DateTime)                	: returns the astronomical julian dates extrapolated from This.DateTime see also https://en.wikipedia.org/wiki/Julian_day for more details
	;					                            		: these are experimental and not fully tested
	;		Type		                            		: optional string, if provided then the requested julian date type will be returned, otherwise a hash of all available julian dates will be returned
	;	---------------------------------------------------------------------
	;					                            		: The following date parts will:
	;					                            		: Getting a property will retrieve the actual date part requested, this will be a zero padded value, i.e. If Month = 3 then This.Month will return "03"
	;					                            		: Setting a property will cause This.DateTime to be recalculated, and will return This.Format. See examples.
	; 	.Year		:= value                            	: Acceptable values need to be in the format yyyy or yy. If 2 digit years are provided then it's assumed to be in the range 1950-2049. Get will return a 4 digit year.
	;	.Month		:= value                            	: Acceptable values can be 1-12, where 1 is January or at least the first three characters of the month name; The change remains in the current Year.
	;				                                    			: Note: this uses the This.Add({Months:X}) method to deal with last day of month issues i.e. if Jan 31 is the current day, moving to Feb will force a leap year check for the year and will set the day to either 29 or 28 accordingly.
	; 	.Day		:= value	:
	;	.DayOfWeek 	:= value                    	: Acceptable values can be 1-7, where 1 is monday or at least the first three characters of the day name; The change remains in the current week.
	;	.DayOfYear 	:= value                        	: Acceptable values can be zero padded three digit number 001-366, and the date will be moved to this day of the year
	;	.Hour		:= value                            	: Acceptable values can be 0-23, expressed in 24 hour format
	;	.Minute		:= value	:
	;	.Second		:= value	:
	; 	.Meridian 	:= value                        	: "am" or "pm" value for This.DateTime, Setting will also adjust the This.Hour to the corresponding value
	; 		value                	: string, "am" or "pm"
	;
	; 	.MonthName                                    	: gets the full Month name for This.DateTime
	;
	; 	.IsLeapYear                                       	: gets a boolean value telling if This.DateTime is a leap year
	;
	; 	.IsAfter(Resolution) := DateTime	    	: returns boolean, true if This.DateTime IsAfter DateTime, False if This.DateTime is not After DateTime
	;
	; 	.IsAfter(DateTime, Resolution) 		    	: returns boolean, true if This.DateTime IsAfter DateTime, False if This.DateTime is not After DateTime
	;		DateTime	                                    	: required, string or DateTime object. This value will be parsed into the Resolution format automatically before comparison
	; 		Resolution                            	    	: optional, format string, default "yyyyMMdd"; Each of the dates will reformatted as this for comparison. Note using formats with text names will cause spurious results.
	;
	; 	.IsBefore(Resolution) := DateTime    	: returns boolean, true if This.DateTime IsBefore DateTime, False if This.DateTime is not Before DateTime
	;
	; 	.IsBefore(DateTime, Resolution) 	    	: returns boolean, true if This.DateTime IsBefore DateTime, False if This.DateTime is not Before DateTime
	;		DateTime                                     	: required, string or DateTime object. This value will be parsed into the Resolution format automatically before comparison
	; 		Resolution                            	    	: optional, format string, default "yyyyMMdd"; Each of the dates will reformatted as this for comparison. Note using formats with text names will cause spurious results.
	;
	; 	.IsEqual(Resolution) := DateTime	    	: returns boolean, true if This.DateTime IsEqual DateTime, False if This.DateTime is not equal DateTime
	;
	; 	.IsEqual(DateTime, Resolution) 	    	: returns boolean, true if This.DateTime IsEqual DateTime, False if This.DateTime is not equal DateTime
	;		DateTime	                                    	: required, string or DateTime object. This value will be parsed into the Resolution format automatically before comparison
	; 		Resolution                            	    	: optional, format string, default "yyyyMMdd"; Each of the dates will reformatted as this for comparison. Note using formats with text names will cause spurious results.
	;
	; 	.IsBetween(Resolution) := DateTime	: returns Boolean, true if This.DateTime is Before This.Till and On/After This.DateTime
	;
	; 	.IsBetween(DateTime, Resolution)    	: returns Boolean, true if This.DateTime is Before This.Till and On/After This.DateTime
	;		DateTime	                                    	: required, string or DateTime object. This value will be parsed into the Resolution format automatically before comparison
	; 		Resolution                                		: optional, format string, default "yyyyMMdd"; Each of the dates will reformatted as this for comparison. Note using formats with text names will cause spurious results.
	;
	;	.Parse(Region) := DateTime             	: parses the Datetime, returns the DatePart Hash of the given DateTime
	;
	; 	.Parse(DateTime, Region)                 	: parses the Datetime, returns the DatePart hash of the given DateTime
	; 		DateTime	                                    	: optional, string datetime, defaults to This.DateTime
	; 		Region	                                    		: optional, string region name, defaults to This.Region
	;
	; 	.Region	                                    			: returns the currently set region, if not set then defaults to "American"
	;
	; 	.Region := Value                              	: sets the region, returns the currently set region
	;
	; 	.DesiredFormat := value 		        		: gets or sets the desired format, use .Format instead
	;
	;	.Format(value)                                		: returns This.DateTime in the specified format, does not save the format to This.DesiredFormat
	;
	;	.Format := value                                	: sets This.Format. Syntactic sugar for This.DesiredFormat. Returns This.Format
	;		value                                    			: case sensitive string, default yyyyMMdd-HHmmss; Format that will be used to display This.DateTime.
	;			d	                                        		: Day of the month without leading zero (1 - 31)
	;			dd	                                    		: Day of the month with leading zero (01 – 31)
	;			ddd	                                    		: Abbreviated name for the day of the week (e.g. Mon) in the current user's language
	;			dddd                                    		: Full name for the day of the week (e.g. Monday) in the current user's language
	;			M	        	                                	: Month without leading zero (1 – 12)
	;			MM		                                    	: Month with leading zero (01 – 12)
	;			MMM		                                	: Abbreviated month name (e.g. Jan) in the current user's language
	;			MMMM	                                	: 	Full month name (e.g. January) in the current user's language
	;			y		                                        	: Year without century, without leading zero (0 – 99)
	;			yy		                                        	: Year without century, with leading zero (00 - 99)
	;			yyyy	                                        	: 	Year with century. For example: 2005
	;			gg	                                        	: Period/era string for the current user's locale (blank if none)
	;			h		                                        	: Hours without leading zero; 12-hour format (1 - 12)
	;			hh	                                        	: Hours with leading zero; 12-hour format (01 – 12)
	;			H		                                        	: Hours without leading zero; 24-hour format (0 - 23)
	;			HH	                                        	: Hours with leading zero; 24-hour format (00– 23)
	;			m		                                        	: Minutes without leading zero (0 – 59)
	;			mm	                                        	: Minutes with leading zero (00 – 59)
	;			s		                                        	: Seconds without leading zero (0 – 59)
	;			ss		                                        	: Seconds with leading zero (00 – 59)
	;			t		                                        	: Single character time marker, such as A or P (depends on locale)
	;			tt		                                        	: Multi-character time marker, such as AM or PM (depends on locale)
	;
	; Examples
	; DateTools.SyntaxExamples()

	__New(Param="") {
		; if param is a string, then it's assigned to the DateTime
		; if param is a hash, it can contain {DateTime, Till, Format} values
		; any passed dates will be passed through the date parser in an attempt to make a proper datetime in yyyyMMddHHmmss format
		if (IsObject(Param)) {
			} else {
			Param := {DateTime:Param}
			} ; end if

		Region := This.RegionName := Param.HasKey("Region") ? Param.Region : "American"

		; 'DateTime' is the date stored in a system acceptable format of 'yyyyMMddHHmmss' aka 'yyyymmddhh24miss'
		if ( Param.HasKey("DateTime") ) {
			ParsedDate := DateTools.Parse(Param.DateTime, Region)
			} else {
			ParsedDate := DateTools.Parse(a_Now, Region)
			} ; end if
		if ( Param.HasKey("Till")  ) {
			This.Until := DateTools.Parse(Param.Till, Region).DateTime
			} else {
			This.Until := a_Now
			} ; end if

		This.DesiredFormat 	:= Param.HasKey("Format") 		? Param.Format 					: "yyyyMMdd-HHmmss"
		, This.DatePart := ParsedDate
		, This.DateTime := ParsedDate.DateTime
		} ; end __New

	__Get(aName) {
		if ( RegexMatch(aName, "i)^(?:Year|Month|Day|Hour|Minute|Second|Meridian|IsLeapYear)$") ) {
			return, % SubStr("0000" . This.DatePart[aName], {Year:-3, Month:-1, Day:-1, Hour:-1, Minute:-1, Second:-1, Meridian:-1, IsLeapYear:0}[aName])
			} ; end if
		if ( RegexMatch(aName, "i)^(?:MonthName|Epoch)$") ) {
			return, % This.DatePart[aName]
			} ; end if
;		return, % This.Format
		} ; end __Get

	__Set(aName, aValue) {
		if ( RegexMatch(aName, "i)^(?:Year|Month|Day|Hour|Minute|Second)$") ) {
			IncrementCount := aName <> "Month" ? aValue : {1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10, 11:11, 12:12, Jan:1, Feb:2, Mar:3, Apr:4, May:5, Jun:6, Jul:7, Aug:8, Sep:9, Oct:10, Nov:11, Dec:12}[substr(aValue,1,3)]
			IncrementCount := aName <> "Year"  ? aValue : (0 <= Year and Year < 100 ? (aValue <= 50 ? 1900 : 2000) + aValue : aValue)
			; desired DatePart minus current DatePart equals the number of DateParts to add
			return, % This.Add := {aName . "s":IncrementCount - This.DatePart[aName]}
			} ; end if
		if ( RegexMatch(aName, "i)^(?:Meridian)$") ) {
			; only change the meridian if it is truly different
			if ( This.DatePart.Meridian <> aValue ) {
				return, % This.Add := {Hours:{am:-12, pm:12}[aValue]}
				} ; end if
			return, % This.Format
			} ; end if
		if ( RegexMatch(aName, "i)^(?:Epoch)$") ) {
			return, % This.Recalculate := DateTools.EpochToDate(aValue)
			} ; end if
		if ( RegexMatch(aName, "i)^(?:DayOfWeek)$") ) {
			; desired DayOfWeek minus current DayOfWeek equals the number of Days to add
			; get current day of week
			return, % This.Add := {Days: {1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, Mon:1, Tue:2, Wed:3, Thu:4, Fri:5, Sat:6, Sun:7}[substr(aValue,1,3)] - This.DatePart.DayOfWeek.Number }
			} ; end if
		if ( RegexMatch(aName, "i)^(?:DayOfYear|NewDateTime)$") ) {
			return, % This.Recalculate := aValue
			} ; end if
		} ; end __Get

	Recalculate[DateTime=""] {
		get { ; ( DateTime )
			; pulls the dateparts together and recalculates the This.DateTime
			This.DateTime := (This.DatePart := This.Parse := DateTime ? DateTime : This.Year . This.Month . This.Day . This.Hour . This.Minute . This.Second).DateTime
			Return, % This.Format
			} ; end get
		set { ; := DateTime
			return, % This.Recalculate(Value)
			} ; end set
		} ; end recalculate

	IsBetween[OptionA="", OptionB="yyyyMMdd"] {
		; tests the DateTime or value to see if it's on or after This.Till, and before This.DateTime
		; notes: this should be read as: on or after the youngest time and before the oldest time
		Get { ; ( DateTime, Resolution )
			return, % Datetools.IsBetween(This.Parse(OptionA).DateTime, This.Till, This.DateTime, OptionB)
			} ; end get
		Set { ; ( Resolution ) := DateTime
			return, % This.IsBetween(Value, OptionA)
			} ; end set
		} ; end IsBetween

	IsAfter[OptionA="", OptionB="yyyyMMdd"] {
		Get { ; ( DateTime, Resolution )
			return, % Datetools.IsAfter(This.Parse(OptionA).DateTime, This.DateTime, OptionB)
			} ; end get
		Set { ; ( Resolution ) := DateTime
			return, % This.IsAfter(Value, OptionA)
			} ; end set
		} ; end IsAfter

	IsBefore[OptionA="", OptionB="yyyyMMdd"] {
		Get { ; ( DateTime, Resolution )
			return, % Datetools.IsBefore(This.Parse(OptionA).DateTime, This.DateTime, OptionB)
			} ; end get
		Set { ; ( Resolution ) := DateTime
			return, % This.IsBefore(Value, OptionA)
			} ; end set
		} ; end IsBefore

	IsEqual[OptionA="", OptionB="yyyyMMdd"] {
		Get { ; ( DateTime, Resolution )
			return, % Datetools.IsEqual(This.Parse(OptionA).DateTime, This.DateTime, OptionB)
			} ; end get
		Set { ; ( Resolution ) := DateTime
			return, % This.IsEqual(Value, OptionA)
			} ; end set
		} ; end IsBefore

	ResolveDateTime(DateTime, ThisProperty="DateTime", ParseProperty="DateTime", Default="") {
		; receives a datetime as a string or date object
		; returns
		;	if the provided datetime is an object or datetime string, parse and return the provided datetime
		; 	if the provided datetime is null, return This[Property]
		;	If This[Property] is null, then return Default
		; 	if default is null, then return A_Now
		;
		; examples
		; DateTime 	:= This.ResolveDateTime(DateTime, "DateTime")
		; Till 		:= This.ResolveDateTime(DateTime, "Till")
		Default := Default ? Default : A_Now
		if ( DateTime ) {
			if ( IsObject(DateTime) ) {
				Return, % DateTime.HasKey(ParseProperty) ? DateTime[ParseProperty] : Default
				} else {
				Return, % This.Parse[ParseProperty]
				} ; end if
			} else {
			Return, % This[ThisProperty] ? This[ThisProperty] : Default
			} ; end if
		} ; end ResolveDateTime

	Add[OptionA="", OptionB=""] {
		; receives a date string and returns a hash of date parts
		; parts that are not included in the provided string will be derived from A_Now
		; the regex currently assumes American dates formats
		get { ; ( Hash, Multiplier )
			This.DateTime := DateTools.Add(OptionA, This.DateTime, (OptionB ? OptionB : "SameDirection") )
			This.DatePart := This.Parse
			Return, % This.Format
			} ; end get
		set { ; ( Multiplier ) := Hash
			return, % This.Add(Value, (OptionA ? OptionA : "SameDirection"))
			} ; end set
		} ; end Add

	JulianDates[DateTime=""] {
		get { ; ( DateTime )
			Return, % DateTools.JulianDates(DateTime ? DateTime : This.DateTime)
			} ; end get
		Set { ;  := DateTime
			Return, % This.JulianDates(Value)
			} ; end set
		} ; end JulianDates

	TimeSpan[OptionA="", OptionB=""] {
		get { ; (Till, DateTime)
			return, % DateTools.TimeSpan(This.ResolveDateTime(OptionA, "DateTime"), This.ResolveDateTime(OptionB, "DateTime"))
			} ; end get
		set { ; (DateTime) := Till
			This.Till := This.ResolveDateTime(Value, "DateTime")
			This.DateTime := This.ResolveDateTime(OptionA, "DateTime")
			Return, % This.TimeSpan
			} ; end set
		} ; end TimeSpan

	Format[DesiredFormat=""] {
		get { ; ( DesiredFormat )
			Return, % DateTools.Formatted(This.DateTime, (DesiredFormat ? DesiredFormat : This.DesiredFormat) )
			} ; end get
		set { ; := DesiredFormat
			This.DesiredFormat := Value
			Return, % This.Format
			} ; end set
		} ; end Format

	Region[NotUsed=""] {
		get {
			return, % This.RegionName
			} ; end get
		set { ; := RegionName
			This.RegionName := Value
			return, % This.RegionName
			} ; end set
		} ; end till

	Till[NotUsed=""] {
		get {
			return, % This.Until
			} ; end get
		set { ; := DateTime
			This.Until := Value
			return, % This.Until
			} ; end set
		} ; end till

	Parse[OptionA="", OptionB=""] {
		; receives a date string and returns a hash of date parts
		; parts that are not included in the provided string will be derived from A_Now
		; the regex currently assumes American dates formats
		get { ; (DateTime, Region)
			Region := OptionB ? OptionB : This.Region
			return, % DateTools.Parse((OptionA ? OptionA : This.DateTime), Region)
			} ; end get
		set { ; (Region) := DateTime
			Region := OptionA ? OptionA : This.Region
			return, % This.Parse(Value, Region)
			} ; end set
		} ; end Parse
	} ; end class date
