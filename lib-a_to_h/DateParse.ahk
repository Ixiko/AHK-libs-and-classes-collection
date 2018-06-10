; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Converts almost any date format to a YYYYMMDDHH24MISS value.
; Modified ......: 2014.03.30
; Author ........: dougal/polyethene
; Licence .......: ???
; Source ........: http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-6#entry640277
; ===================================================================================


; ******* Start of Example **********************************************************
; Add dates for testing with correct return value and test value using pipe separator
/*
sDates =
( Comment
19600501|May1960
200711271435|2:35 PM, 27 November 2007
200402270455|4:55 am Feb 27, 2004
YYYYMMDD1126|11:26
20050219|19/2/05
YYYYMMDD1532|1532
20070626140912|2007-06-26T14:09:12Z
YYYYMMDD1435|2:35 PM
20071210|10/12/2007
20000105|05-Jan-00
20000105|Jan-05-00
20090817132333|Mon, 17 Aug 2009 13:23:33 GMT
20090315|3/15/2009
YYYYMMDD112224|11:22:24 AM
20090307134358|07 Mar 2009 13:43:58
20070627|Wed 6/27/2007
20120713131646|Fri, 13 Jul 2012 13:16:46 GMT
200706251852|2007-06-25 18:52
19600525|25May1960
20131231|Dec-31-13
20050219|19/2/05
20071210|10/12/2007
20090315|3/15/2009
20070627|Wed 6/27/2007
)
Loop, Parse, sDates, `n
{
	StringSplit, aTemp, A_LoopField, % "|"
	StringReplace, aTemp1, aTemp1, YYYYMMDD, %A_YYYY%%A_MM%%A_DD%
	sDate := DateParse(aTemp2)
	MsgBox, % aTemp2 "`n" sDate "`n`n" (aTemp1 = sDate ? "Correct" : "Error, should be:`n" aTemp1)
}
ExitApp

; ******* End of Example ***********************************************************
*/

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
		- Version 1.05 <http://www.autohotkey.net/~polyethene/#dateparse>
		- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/
/*
	With modifications from http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-5#entry561591
*/
/*
Modified return values:
	Partial date returns
		No month : nothing
		No year and no day : nothing
		Time and no day :nothing
		Month and year without time : substitute 1st for day
		Day and month : substitute current year
	No date and time still substitutes current date
Allow no separator aorund named months (eg 25May60)
Only alphabetic Month name follow on characters to prevent month taking first 2 digits of 4 digit year if there are no separators eg in 25May1960 year group only gets 60 and becomes 2060
Separators relaxed, can be any character except letter or digit
Search for named months first to prevent number month incorrectly matching in "Feb 12 11" as day =12 month=11 and skipping named month match
With named months day or year are optional
If numeric month is > 12 and day is <= 12 swap month and day (probably american date)
*/
DateParse(str, americanOrder=0) {
	static monthNames := "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-zA-Z]*"
		, dayAndMonth := "(\d{1,2})[^a-zA-Z0-9:.]+(\d{1,2})"
		, dayAndMonthName := "(?:(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Day>\d{1,2})[^a-zA-Z0-9]+|(?<Day>\d{1,2})[^a-zA-Z0-9:.]*(?<Month>" . monthNames . "))"
		, monthNameAndYear := "(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Year>(?:\d{4}|\d{2}))"
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i) ;ISO 8601 timestamps
		year := i1, month := i3, day := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t){
		RegExMatch(str, "i)(\d{1,2})"					;hours
				. "\s*:\s*(\d{1,2})"				;minutes
				. "(?:\s*:\s*(\d{1,2}))?"			;seconds
				. "(?:\s*([ap]m))?", t)				;am/pm
		StringReplace, str, str, %t%
		if RegExMatch(str, "Ji)" . dayAndMonthName . "[^a-zA-Z0-9]*(?<Year>(?:\d{4}|\d{2}))?", d) ; named month eg 22May14; May 14, 2014; 22May, 2014
			year := dYear, month := dMonth, day := dDay
		else if Regexmatch(str, "i)" . monthNameAndYear, d) ; named month and year without day eg May14; May 2014
				year := dYear, month := dMonth
		else {
			If Regexmatch(str, "i)(\d{4})[^a-zA-Z0-9:.]+" . dayAndMonth, d) ;2004/22/03
				year := d1, month := d3, day := d2
			Else If Regexmatch(str, "i)" . dayAndMonth . "(?:[^a-zA-Z0-9:.]+((?:\d{4}|\d{2})))?", d) ;22/03/2004 or 22/03/04
				year := d3, month := d2, day := d1
			If (RegExMatch(day, monthNames) or americanOrder and !RegExMatch(month, monthNames) or (month > 12 and day <= 12)) ;try to infer day/month order
				tmp := month, month := day, day := tmp
		}
	}
	f = %A_FormatFloat%
	SetFormat, Float, 02.0
	if (day or month or year) and not (day and month and year) ; partial date
		if not month or not (day or month) or (t1 and not day) ; partial date must have month and day with time or day or year without time
			return
		else if not day ; without time use 1st for day if not present
			day := 1
	d := (StrLen(year) == 2 ? "20" . year : (year ? year : A_YYYY))
		. ((month := month + 0 ? month : InStr(monthNames, SubStr(month, 1, 3)) // 4 ) > 0 ? month + 0.0 : A_MM)
		. ((day += 0.0) ? day : A_DD)
		. t1 + (t1 == 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "pm" ? 12.0 : 0.0)
		. t2 + 0.0 . t3 + 0.0
	SetFormat, Float, %f%
	return, d
}