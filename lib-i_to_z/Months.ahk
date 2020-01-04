/*
Months(date,months):
This function accepts a date in the YYYYMMDD(...) format, goes forward or backward a
given number of months, and then returns the new date in the original format.
For example: 
date := Months(date,24)
date := Months(date,-24)
*/


Months(date,months) {
	FormatTime, year, %date%, yyyy ; Get the four-digit year
	FormatTime, month, %date%, MM ; Get the two-digit month

	; Cycle through the months an appropriate number of times
	Loop % abs(months) {
		i = 1
		if months < 0 
			i = -1	
		month += i ; Will add or subtract accordingly.
		
		; Whenever we hit a month of 0 or 13...
		if (month < 1 || month > 12) {
			month := abs(12 - month) ; Convert it, and...
			year += i ; ...add or subtract a year.
		}
	}
		
	if strLen(month) < 2 
		month := "0" . month ; Keep month in MM format
	
	; Return input date with modified year/month.
	return year . month . SubStr(date, 7)
}
