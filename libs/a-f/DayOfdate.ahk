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

DayofDate(Date) {
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

