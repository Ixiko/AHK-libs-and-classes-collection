; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; SEVERAL FUNCTIONS FOR CALCULATIONS WITH DATES
; collected from Autohotkeyforum: https://autohotkey.com/boards/viewtopic.php?t=10600
; preserved in the original by Hoppfrosch
; warmed up and put into one soup by Ixiko on 04-01-2018 (yes american format - it sounds well "In January on his fourth day - were we fight against the ice cold. We are born as brothers!") (HAPPY END) ->
; 																										in germlingish : " On the fourth day of January - were we fight against the ice cold. We are died as brothers!"	(REAL END)
; DESCRIPTIONS and EXAMPLES - have been baked into the functions
; but the best joke is my english - " Come inside and find your way out! "
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Calculating date of christian easter and subsequent christian feasts
easter(year) {

; Calculating date of christian easter and subsequent christian feasts
;
; The following feasts are calculated:
; * Christian Easter
; * Ash Wednesday
; * Ascension Day
; * Whitsunday
; * Corpus Christi
;
; Author: hoppfrosch @ hoppfrosch@gmx.de
; Version: 1.0.1
; Date: 04.06.2009
; see: http://www.autohotkey.com/board/topic/41342-func-calculating-date-of-christian-easter/
;
; Restrictions: Works only between 1700.A.D and 9999 A.D due to restrictions of FormatTime
; ------------------------
/* EXAMPLE
year = 2011
easterdate := easter(year)
ashwednesdaydate := ashwednesday(year)
ascensiondaydate := ascensionday(year)
whitsundaydate := whitsunday(year)
corpuschristidate := corpuschristi(year)

MsgBox,
(
Year %year%
Christian Easter: %easterdate%
Ash Wednesday: %ashwednesdaydate%
Ascension Day: %ascensiondaydate%
Whitsunday: %whitsundaydate%
Corpus Christi: %corpuschristidate%
)

return
*/

  ; Saekularzahl: K(X) = X div 100
  k := Floor(year/100)
  ; saekulare Mondschaltung:  M(K) = 15 + (3K + 3) div 4 - (8K + 13) div 25
  m := 15 + floor((3 * k + 3)/4) - floor((8 * k + 13)/25)
  ; saekulare Sonnenschaltung: S(K) = 2 - (3K + 3) div 4
  s := 2 - floor((3 * k + 3)/4)
  ; Mondparameter: A(X) = X mod 19
  a := Mod(year,19)
  ; Keim fuer den ersten Vollmond im Fruehling:  D(A,M) = (19A + M) mod 30
  d := Mod((19 * a + m), 30)
  ; kalendarische Korrekturgroesse: R(D,A) = D div 29 + (D div 28 - D div 29) (A div 11)
  r := floor(d/29) + (floor(d/29)-floor(d/28))*floor(a/11)
  ; Ostergrenze: OG(D,R) = 21 + D - R
  og := 21 + d - r
  ; erster Sonntag im Maerz:  SZ(X,S) = 7 - (X + X div 4 + S) mod 7
  sz := 7 - Mod((year + Floor(year/4) + s),7)
  ; Osterentfernung in Tagen): OE(OG,SZ) = 7 - (OG - SZ) mod 7
  oe := 7 - Mod((og - sz),7)
  ; Datum des Ostersonntags als Märzdatum: OS = OG + OE
  os := og + oe
  ; Korrektur um 1 Tag noetig, da man vom 01.03 ausgeht
  os := os - 1

  result = %year%0301
  EnvAdd, result, %os%, days

  return result
}

ashwednesday(year) {
  result := easter(year)
  EnvAdd, result, -46, days
  return result
}

ascensionday(year) {
  result := easter(year)
  EnvAdd, result, 39, days
  return result
}

whitsunday(year) {
  result := easter(year)
  EnvAdd, result, 49, days
  return result
}

corpuschristi(year) {
  result := easter(year)
  EnvAdd, result, 60, days
  return result
}
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DateParse(str, americanOrder=0) { ;have an order?

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

/*  EXAMPLE
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
/* DESCRIPTION
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
/* NOTIFICATION
	With modifications from http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-5#entry561591
*/
/* INFORMATION
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

DayofDate(Date) { ;day of week is meant

		/*
		DayofDate() by Avi Aryan
			Gives the day (Sunday, Mon..) of a requested date

		Based on Zeller's Algorithm
			http://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week#Zeller.E2.80.99s_algorithm

		Thanks to polyethene for DateParse()
		Licensed under Apache License v2.0
		-------------------------------------------------------------------------------------------------
		msgbox,% DayofDate("6 June 2013")
		msgbox,% DayofDate(A_Now)
		msgbox,% DayofDate("2013")  ;Day of 1st Jan 2013
		*/

		if Date is Not Integer
			Date := DateParse(Date)	;parse to format

		Year := SubStr(Date,1,4) , Month := (Month := Substr(Date, 5, 2)) ? Month : 01 , Day := (Day := Substr(Date,7,2)) ? Day : 01

		if (Month = 1 or Month = 2)
			Year-=1 , Month+=12		;a/c Zeller's
		last2ofy := Substr(Year, -1) , first2ofy := Substr(Year, 1, 2)

		dayindex := Mod( Day + Floor((Month+1)*2.6) + last2ofy + Floor(last2ofy/4) + Floor(first2ofy/4) - 2*first2ofy , 7 )

		static nameofdays := "Saturday,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday"
		day := Substr( nameofdays, startpos := Instr(nameofdays, ",", false, 1, dayindex)+1 , dayindex=6 ? 999999 : Instr(nameofdays, ",", false, 1, dayindex+1)-startpos )
		return day

}

IsLeapYear(Year) {	 ;very good function name

	;**** Function IsLeapYear(Year)
	;**** Checks if a year (format YYYY) is a leap year
	;**** Returns 1 if yes, else 0, -1 if wrong format
	;****  by jNizM - http://ahkscript.org/boards/viewtopic.php?p=10222#p10222


  return !Mod(Year, 100) && !Mod(Year, 400) || !Mod(Year, 4)
}

LDOM(TimeStr="") {	;Last Day of Month

	; ===================================================================================
	; AHK Version ...: AHK_L 1.1.15.03 x64 Unicode
	; Win Version ...: Windows 7 Professional x64 SP1
	; Description ...: Last Day of Month
	; Calculates number of days of a given month
	; Modified ......: ????
	; Author ........: Laszlo/Skan
	; Licence .......: ????
	; Source ........: http://www.autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/?p=51188
	; ===================================================================================

	; ******* Start of Example *********************************************************
	;MsgBox % LDOM(200601)
	;MsgBox % LDOM(200602)
	;MsgBox % LDOM(200612)
	;MsgBox % LDOM(200002)
	; ******* End of Example ***********************************************************


	If TimeStr=
     TimeStr = %A_Now%
  StringLeft Date,TimeStr,6 ; YearMonth
  Date1 = %Date%
  Date1+= 31,D              ; A day in next month
  StringLeft Date1,Date1,6  ; YearNextmonth
  Date1-= %Date%,D          ; Difference in days
  Return Date1

}

Span_Time(to,from="",units="d",params="") { ;Span between dates

	; ===================================================================================
	; AHK Version ...: AHK_L 0.1.48+ x64 Unicode
	; Win Version ...: Windows 7 Professional x64 SP1
	; Description ...: Time() - Count Days, hours, minutes, seconds between dates
	; Modified ......: ????
	; Author ........: HotKeyIt
	; Licence .......: ????
	; Source ........: https://autohotkey.com/board/topic/42668-time-count-days-hours-minutes-seconds-between-dates/
	; ===================================================================================
	/*
	#NoEnv
	SetBatchLines,-1
	MsgBox % "Count days from 12 May until 15 May`n"
			. Time("May-15","12.May","d")

	MsgBox % "Working hours from 01.05.2009 00:00:00   to   10.05.09 09:30:00`n"
			. "Count only working hours from 09 to 17 and consider weekends and 01.May bank holiday`n"
			. Time("20090504093000","20090501000000","h","W1.7 H9-17 B0105")

	MsgBox % "Days to work till end of 2009`n" . Time("01.01.2010","","d","W1.7")

	MsgBox % "Hours to work till end of 2009 from 09 - 17`n" . Time("01.01.2010","","h","W1.7 H9-17")

	ExitApp
	*/

	static _:="0000000000",s:=1,m:=60,h:=3600,d:=86400
				,Jan:="01",Feb:="02",Mar:="03",Apr:="04",May:="05",Jun:="06",Jul:="07",Aug:="08",Sep:="09",Okt:=10,Nov:=11,Dec:=12
	r:=0
	units:=units ? %units% : 8640
	If (InStr(to,"/") or InStr(to,"-") or InStr(to,".")){
		Loop,Parse,to,/-.,%A_Space%
			_%A_Index%:=RegExMatch(A_LoopField,"\d+") ? A_LoopField : %A_LoopField%
			,_%A_Index%:=(StrLen(_%A_Index%)=1 ? "0" : "") . _%A_Index%
		to:=SubStr(A_Now,1,8-StrLen(_1 . _2 . _3)) . _3 . (RegExMatch(SubStr(to,1,1),"\d") ? (_2 . _1) : (_1 . _2))
		_1:="",_2:="",_3:=""
	}
	If (from and InStr(from,"/") or InStr(from,"-") or InStr(from,".")){
		Loop,Parse,from,/-.,%A_Space%
			_%A_Index%:=RegExMatch(A_LoopField,"\d+") ? A_LoopField : %A_LoopField%
			,_%A_Index%:=(StrLen(_%A_Index%)=1 ? "0" : "") . _%A_Index%
		from:=SubStr(A_Now,1,8-StrLen(_1 . _2 . _3)) . _3 . (RegExMatch(SubStr(from,1,1),"\d") ? (_2 . _1) : (_1 . _2))
	}
   count:=StrLen(to)<9 ? "days" : StrLen(to)<11 ? "hours" : StrLen(to)<13 ? "minutes" : "seconds"
	to.=SubStr(_,1,14-StrLen(to)),(from ? from.=SubStr(_,1,14-StrLen(from)))
	Loop,Parse,params,%A_Space%
		If (unit:=SubStr(A_LoopField,1,1))
			 %unit%1:=InStr(A_LoopField,"-") ? SubStr(A_LoopField,2,InStr(A_LoopField,"-")-2) : ""
			,%unit%2:=SubStr(A_LoopField,InStr(A_LoopField,"-") ? (InStr(A_LoopField,"-")+1) : 2)
	count:=!params ? count : "seconds"
	add:=!params ? 1 : (S2="" ? (M2="" ? (H2="" ? ((D2="" and B2="" and W="") ? d : h) : m) : s) : s)
	While % (from<to){
		FormatTime,year,%from%,YYYY
		FormatTime,month,%from%,MM
		FormatTime,day,%from%,dd
		FormatTime,hour,%from%,H
		FormatTime,minute,%from%,m
		FormatTime,second,%from%,s
		FormatTime,WDay,%from%,WDay
		EnvAdd,from,%add%,%count%
		If (W1 or W2){
			If (W1=""){
				If (W2=WDay or InStr(W2,"." . WDay) or InStr(W2,WDay . ".")){
					Continue=1
				}
			} else If WDay not Between %W1% and %W2%
				Continue=1
			;else if (Wday=W2)
			;	Continue=1
			If (Continue){
				tempvar:=SubStr(from,1,8)
				EnvAdd,tempvar,1,days
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				Continue=
				continue
			}
		}
		If (D1 or D2 or B2){
			If (D1=""){
				If (D2=day or B2=(day . month) or InStr(B2,"." . day . month) or InStr(B2,day . month . ".") or InStr(D2,"." . day) or InStr(D2,day . ".")){
					Continue=1
				}
			} else If day not Between %D1% and %D2%
				Continue=1
			;else if (day=D2)
			;	Continue=1
			If (Continue){
				tempvar:=SubStr(from,1,8)
				EnvAdd,tempvar,1,days
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				Continue=
				continue
			}
		}
		If (H1 or H2){
			If (H1=""){
				If (H2=hour or InStr(H2,hour . ".") or InStr(H2,"." hour)){
					Continue=1
				}
			} else If hour not Between %H1% and %H2%
				continue=1
			;else if (hour=H2)
			;	continue=1
			If (continue){
				tempvar:=SubStr(from,1,10)
				EnvAdd,tempvar,1,hours
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				continue=
				continue
			}
		}
		If (M1 or M2){
			If (M1=""){
				If (M2=minute or InStr(M2,minute . ".") or InStr(M2,"." minute)){
					Continue=1
				}
			} else If minute not Between %M1% and %M2%
				continue=1
			;else if (minute=M2)
			;	continue=1
			If (continue){
				tempvar:=SubStr(from,1,12)
				EnvAdd,tempvar,1,minutes
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				continue=
				continue
			}
		}
		If (S1 or S2){
			If (S1=""){
				If (S2=second or InStr(S2,second . ".") or InStr(S2,"." second)){
					Continue
				}
			} else if (second!=S2)
				If second not Between %S1% and %S2%
					continue
		}
		r+=add
	}
	tempvar:=SubStr(count,1,1)
	tempvar:=%tempvar%
	Return (r*tempvar)/units

}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TZI_GetFromYear(Year) { ; GetTimeZoneInformationForYear -> msdn.microsoft.com/en-us/library/bb540851(v=vs.85).aspx (Win Vista+)

   ; ===================================================================================
	; AHK Version ...: v1.1.24.05 Unicode 32-bit
	; Win Version ...: Windows 7 Professional x64 SP1
	; Description ...: Get Timezone-information for given year based on current timezone settings
	; Modified ......: 2017.02.23
	; Author ........: just me
	; Licence .......: ???
	; Source ........: https://autohotkey.com/boards/viewtopic.php?p=133780#p133780
	; ===================================================================================

	; ----------------------------------------------------------------------------------------------------------------------------------
	; Requires Win Vista+
	; ----------------------------------------------------------------------------------------------------------------------------------

	/*
	#NoEnv
	Year := 2017
	TZI := TZI_GetFromYear(Year)
	Gui, Add, ListView, w1000 r9, Field|Value|Description
	LV_Add("", "Bias", TZI.Bias, "Minutes (UTC = Local Time + Bias).")
	LV_Add("", "StandardName", TZI.StandardName
			 , "A description for standard time.")
	LV_Add("", "StandardDate", TZI.StandardDate
			 , "A date and local time when the transition from daylight saving time to standard time occurs on this operating system.")
	LV_Add("", "StandardDate (UTC)", TZI.StandardDateUTC
			 , "Calculated UTC date and time.")
	LV_Add("", "StandardBias", TZI.StandardBias
			 , "This value is added to the value of the Bias member to form the bias used during standard time.")
	LV_Add("", "DaylightName", TZI.DaylightName
			 , "A description for daylight saving time.")
	LV_Add("", "DaylightDate", TZI.DaylightDate
			 , "A date and local time when the transition from standard time to daylight saving time occurs on this operating system.")
	LV_Add("", "DaylightDate (UTC)", TZI.DaylightDateUTC
			 , "Calculated UTC date and time.")
	LV_Add("", "DaylightBias", TZI.DaylightBias
			 , "This value is added to the value of the Bias member to form the bias used during daylight saving time.")
	Loop, 3
	   LV_ModifyCol(A_Index, "AutoHdr")
	Gui, Show, , TZI for %Year%
	Return
	GuiClose:
	GuiEscape:
	ExitApp
	*/

   If Year Is Not Integer
      Return 0
   If Year Is Not Date
      Return 0
   Year := SubStr(Year, 1, 4)
   VarSetCapacity(TZI, 172, 0)
   If !DllCall("GetTimeZoneInformationForYear", "UShort", Year, "Ptr", 0, "Ptr", &TZI, "Int")
      Return 0
   R := {}
   R.Bias := NumGet(TZI, "Int")
   R.StandardName := StrGet(&TZI + 4, 32, "UTF-16")
   ST := New TZI_SYSTEMTIME(&TZI + 68)
   ; If ST.Year is not zero the date is fix. Otherwise, the date is variable and must be calculated.
   ; ST.WDay contains the weekday and ST.Day the occurrence within ST.Month (5 = last) in this case.
   If (ST.Year = 0) {
      ST.Year := Year
      ST.Day := TZI_GetWDayInMonth(ST.Year, ST.Month, ST.WDay, ST.Day)
   }
   R.StandardDate := ST.TimeStamp
   R.StandardBias := NumGet(TZI, 84, "Int")
   R.DaylightName := StrGet(&TZI + 88, 32, "UTF-16")
   ST := New TZI_SYSTEMTIME(&TZI + 152)
   If (ST.Year = 0) {
      ST.Year := Year
      ST.Day := TZI_GetWDayInMonth(ST.Year, ST.Month, ST.WDay, ST.Day)
   }
   R.DaylightDate := ST.TimeStamp
   R.DaylightBias := NumGet(TZI, 168, "Int")
   ; Calculate the UTC values for StandardDate and DaylightDate
   UTCBias := R.Bias + R.DaylightBias ; StandardDate
   UTCDate := R.StandardDate
   UTCDate += UTCBias, M
   R.StandardDateUTC := UTCDate
   UTCBias := R.Bias + R.StandardBias ; DaylightDate
   UTCDate := R.DaylightDate
   UTCDate += UTCBias, M
   R.DaylightDateUTC := UTCDate
   Return R
}

TZI_GetWDayInMonth(Year, Month, WDay, Occurence) {
   YearMonth := Format("{:04}{:02}01", Year, Month) ; bugfix
   If YearMonth Is Not Date
      Return 0
   If WDay Not Between 1 And 7
      Return 0
   If Occurence Not Between 1 And 5 ; 5 = last occurence
      Return 0
   FormatTime, WD, %YearMonth%, WDay
   While (WD <> WDay) {
      YearMonth += 1, D
      FormatTime, WD, %YearMonth%, WDay
   }
   While (A_Index <= Occurence) && (SubStr(YearMonth, 5, 2) = Month) {
      Day := SubStr(YearMonth, 7, 2)
      YearMonth += 7, D
   }
   Return Day
}

Class TZI_SYSTEMTIME { ;belongs to the two functions above
   __New(Pointer) { ; a pointer to a SYSTEMTIME structure
      This.Year  := NumGet(Pointer + 0, "Short")
      This.Month := NumGet(Pointer + 2, "Short")
      This.WDay  := NumGet(Pointer + 4, "Short") + 1 ; DayOfWeek is 0 (Sunday) thru 6 (Saturday) in the SYSTEMTIME structure
      This.Day   := NumGet(Pointer + 6, "Short")
      This.Hour  := NumGet(Pointer + 8, "Short")
      This.Min   := NumGet(Pointer + 10, "Short")
      This.Sec   := NumGet(Pointer + 12, "Short")
      This.MSec  := NumGet(Pointer + 14, "Short")
   }
   TimeStamp[] { ; TimeStamp YYYYMMDDHH24MISS
      Get {
         Return Format("{:04}{:02}{:02}{:02}{:02}{:02}", This.Year, This.Month, This.Day, This.Hour, This.Min, This.Sec)
      }
      Set {
         Return ""
      }
   }
}
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

UnformatTime(str,format) { ;Accepts a formatted Date/Time string and returns a VALID DateTime Stamp - FORMATTED TO VALID!

	; ===================================================================================
	; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
	; Win Version ...: Windows 7 Professional x64 SP1
	; Description ...: Accepts a formatted Date/Time string and returns a VALID DateTime Stamp.
	; Convert Seconds to Day(s), Hour(s), Minute(s), Second(s)
	; e.g. MsgBox %	UnformatTime("Thu Mar 31, 2011 9:34 pm (GMT 0)","MMM dd, yyyy h:mm tt")  => 20110331213400
	; Modified ......: ????
	; Author ........: sinkface
	; Licence .......: ????
	; Source ........: http://www.autohotkey.com/board/topic/65302-unformattime-inverter-for-formattime-command/#entry413030
	; ===================================================================================

	; Example Calls
	;MsgBox %	UnformatTime("Thu Mar 31, 2011 9:34 pm (GMT 0)","MMM dd, yyyy h:mm tt")


	static	pf :=	"t,y,M,d,h,H,m,s"
	, MMM :=	{Jan:"01",Feb:"02",Mar:"03",Apr:"04",May:"05",Jun:"06",Jul:"07",Aug:"08",Sep:"09",Oct:10,Nov:11,Dec:12}
	, MMMM :=	{January:"01",February:"02",March:"03",April:"04",May:"05",June:"06",July:"07",August:"08",September:"09",October:10,November:11,December:12}
	StringCaseSense, On
	RegExMatch(str,RegExReplace(format,"\w+","\w+"),timeStr)
	n := 0
	Loop, parse, pf, `,
	{
		Pos :=	1, t :=	format
		if	!RegExMatch(format,A_LoopField "+",r)
			if	InStr("h,t",A_LoopField)
				continue
			else	_1 :=	""
		else
		{
			While	Pos :=	RegExMatch(format,"\w+",m,Pos+StrLen(m))
				StringReplace, t, t, %m%, %	(m==r) ? "(\w+)" : "\w+"
			RegExMatch(timeStr,t,_)
			if	(A_LoopField="t" && _1~="i)p")
				n := 12
		}
		res .=	(A_LoopField="t") ? ""
		 : !_1 ? ((r~="y") ? "0000" : "00")
		 : (r~="y") ? ((r="y" && StrLen(_1)=1) ? 200 _1 : (StrLen(r)<4) ? ((_1>SubStr(A_YYYY,-1)) ? 19 _1 : 20 _1) : _1)
		 : (r~="M") ? ((r="MMM") ? MMM[_1] : (r="MMMM") ? MMMM[_1] : (Abs(_1)<10) ? "0" SubStr(_1,0) : _1)
		 : (r~="h") ? ((n && _1=12) ? "00" : n ? Abs(_1)+n : (Abs(_1)<10) ? "0" SubStr(_1,0) : _1)
		 : (StrLen(r)=1 && Abs(_1)<10) ? "0" SubStr(_1,0) : _1
	}
	return	res
}

YearOfPreviousMonth( date ) { ;very good name

	; ===================================================================================
	; AHK Version ...: AHK_L 1.1.14+ x64 Unicode
	; Win Version ...: Windows 7 Professional x64 SP1
	; Description ...: Year of previous Month
	; Figure out that last month was last year not the current year
	; Modified ......: ????
	; Author ........: Skan
	; Licence .......: ????
	; Source ........: http://www.autohotkey.com/board/topic/7984-ahk-functions-incache-cache-list-of-recent-items/?p=359874
	; ===================================================================================
	;somedate=20100226
	;MsgBox, % YearOfPreviousMonth( somedate )

	date += 0,D
	date := SubStr(date,1,6 )
	date += -1,D

	Return substr( date,1,4 )
}
; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AGE(B,E) {  ; SKAN, http://www.autohotkey.com/forum/topic21456.html
  X := E
  X -= B,s ; seconds difference
  If X < 0 ; change startDate with endDate
    {
      X := B
      B := E
      E := X
    }
  Y:=0, M:=0, D:=0,  Feb29 := SubStr(B,1,4) . "0229235959"
    dYear := B > Feb29 ? 365 * 86400 : LDOY(B) * 86400
    If DateDiff(B,E) >= dYear
       B:=DateAdd(B,dYear)  ,   Y:=Y+1
    Loop   {
              sYear := LDOY(B) * 86400
              If DateDiff(B,E) >= sYear
                 B:=DateAdd(B,sYear)  ,   Y:=Y+1
              Else Break
  } Loop   {
              sMonth := LDOM(B) * 86400
              If DateDiff(B,E) >= sMonth
                 B:=DateAdd(B,sMonth) ,   M:=M+1
              Else Break
  } Loop   {
              If DateDiff(B,E) >= 86400
                 B:=DateAdd(B,86400)  ,   D:=D+1
              Else Break
           }
  W := D > 6 ? Floor(D/7) : ""
  D := W ? D - W * 7 : D
  Y := Abs(Y) > 1 ? Y " Jahre"  : Abs(Y) < 1 ? "" : Y " Jahr"
  M := Abs(M) > 1 ? M " Monate" : Abs(M) < 1 ? "" : M " Monat"
  W := Abs(W) > 1 ? W " Wochen" : Abs(W) < 1 ? "" : W " Woche"
  D := Abs(D) > 1 ? D " Tage"   : Abs(D) < 1 ? "" : D " Tag"
  String = (%Y%`, %M%`, %W%`, %D%)
  String := RegExReplace(String, "(?<=\(), |, (?=,)|, (?=\))")
  String := RegExReplace(String, "^\(\K, ") ; "(?<=\(), " ; nicht in oberer Zeile
  Return String
  }

DateDIFF(B, E, U="S") { ; EnvSub
  E-=%B%,%U%
  Return E
  }

DateADD(Dt, V, U="S") { ; EnvAdd
  Dt+=%V%,%U%
  Return Dt
  }

LDOY( Dt ) { ; Last Day of Year
  Year:=SubStr(Dt,1,4), Days:=Year+1
  Days-=%Year%,D
  Return Days
  }

LDOM( Dt ) { ; Last Day of Month
  M1:=SubStr(Dt,1,6), M2:=M1
  M2+=31,D
  M2:=SubStr(M2,1,6)
  M2-=%M1%,D
  Return M2
  }

