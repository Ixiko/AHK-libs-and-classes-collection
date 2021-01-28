
/* 
	I have put all functions here so as to make my examples clear. You may want to reuse these functions later
	add_days and month_days work together. created by MartinThuku
	
	month_days returns the number of days of the current month if no parameter m is passed.
	month_days parameter m is the month in MM format ie. 02 or 12. If you pass a month, it will give you the number of days of that month.
	
	add_days accepts the date you want to increment and the days you want to add. The days can be negative if you want to deduct days :) the days can be 0 - 10000000 :) Might take some processing time for large days addition
	If both the date and the days are blank, it will return the current date. 
	If date is blank and days has a value it will add days to the current date - today
	If the days is blank and date has value, it will add no days to the passed date. 
	The date must be in the format dd/MM/yyyy and it will return dd/MM/yyyy
	it is dependent on DateParse and month_days See DateParse info below
*/
	
	
add_days(date="",days=""){
	if date=
	{
		timestamp := A_Now
		FormatTime,date,%timestamp%,dd/MM/yyyy
	}
	if days=
		days=0
	Day := SubStr(date, 1, 2)
	Month := SubStr(date, 4, 2)
	Year := SubStr(date, 7, 4)
	SetFormat,float,20.0
	DaysCount := Sqrt((days * days))
	DaysCount = %DaysCount%
	loop, % daysCount
	{
		month_days := month_days(Month)
		if days < 0
			Day -= 1
		else
			Day += 1
		Day += (days<0?-1:1)
		if Day > %month_days%
		{
			Month ++
			if Month > 12
			{
				Year ++
				Month := Month - 12
			}
			Day := Day - month_days
		}
		
		if Day < 1
		{
			Month--
			if Month < 1
			{
				Year --
				Month := 12 + Month
			}
			month_days := month_days(Month)
			Day := month_days + Day
		}
	}
	
	;we create the new date
	new_date := Day "/" Month "/" Year ;can be 1/1/2015
	new_date := DateParse(new_date) ;converts 1/1/2015 to 20150101
	FormatTime,new_date,%new_date%,dd/MM/yyyy ;converts 20150101 to 01/01/2015
	return new_date
}

month_days(m = ""){
	if m =
		m := A_MM
	Year := A_Year
	30s=04,06,09,11
	31s=01,03,05,07,08,10,12
	if 30s contains %m%
		return 30
	if 31s contains %m%
		return 31
	else
		return (!Mod(Year, 100) && !Mod(Year, 400) && !Mod(Year, 4)?29:28)
}


/*
	Title: Date Parser
	
	Function: DateParse
	
	Converts almost any date format to a YYYYMMDDHH24MISS value.
	
	Parameters:
		str - a date/time stamp as a string
	
	Returns:
		A valid YYYYMMDDHH24MISS value which can be used by FormatTime,
		EnvAdd and other time commands.
	
	About: Example
		- time := DateParse("2:35 PM, 27 November, 2007")
	
	About: License
		- Version 1.01 by Titan <http://www.autohotkey.net/~Titan/#dateparse>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/

DateParse(str) {
	static e1 = "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?\s*([ap]m)"
		, e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
	str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
		d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
		RegExMatch(str, e1, t), RegExMatch(str, e2, d)
	f = %A_FormatInteger%
	SetFormat, Float, 02.0
	d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
		. ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0 ? d2 + 0.0 : A_MM)
		. ((d1 += 0.0) ? d1 : A_DD) . t1 + (t4 = "pm" ? 12.0 : 0.0) . t2 + 0.0 . t3 + 0.0
	SetFormat, Float, %f%
	Return, d
}
	