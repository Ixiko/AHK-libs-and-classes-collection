/*
-----------------------Script Info-----------------------
Tested Window Version: 6.1.7601 (x32) (aka Window 7 (x32))
Tested Autohotkey Version: 1.1.25.01 Unicode 32-bit
Date : 2017/04/20
Last Modified : 2017/04/20
Version: v0.1 Beta test
Author: BOTLoi (aka MusicBot)

Get Http Response Header
Http Response 헤더 불러오기
---------------------------------------------------------
*/

/*
MsgBox % GetHeaderDate("https://www.naver.com")
return
*/

GetHeaderDate(url)
{
	WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WinHttp.Open("GET", url, false)
	WinHttp.Send
	res := WinHttp.GetResponseHeader("Date")

	return DateParse(res) "`n" res "`n" FormatTimeKor(res)
}

; Thanks to Lawlite: https://lawlite.tistory.com/276
FormatTimeKor(result)
{
	StringGetPos, pos, result, Date:,L1
	StringGetPos, pos2, result, GMT,L1
	pos3 := pos2-pos
	NewStr := SubStr(result, pos+7, pos3-7)

	StringRight, thetime, NewStr, 8
	ServerHour := Substr(thetime, 1, 2) + 9
	ServerMin := Substr(thetime, 4, 2)
	if ServerHour > 23
	{
	ServerHour := ServerHour - 24
	}
	if ServerHour < 10
	{
	ServerHour = 0%ServerHour%
	}
	StringLeft, theday, A_Now, 8
	tick3 := A_TickCount - tick1
	tick4 := tick3 + 500
	ForAdjust := round((tick4)/1000, 0)+0
	ServerSec := Substr(thetime, 7, 2)
	target = %theday%%serverhour%%servermin%%serversec%
	
	return target
}

/*
	Author : Dougal (https://autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-6#entry640277)

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