GetMonthNum(fnText)
{
	If (fnText = "Jan" || fnText = "January")
		Return "01"
	If (fnText = "Feb" || fnText = "February")
		Return "02"
	If (fnText = "Mar" || fnText = "March")
		Return "03"
	If (fnText = "Apr" || fnText = "April")
		Return "04"
	If (fnText = "May")
		Return "05"
	If (fnText = "Jun" || fnText = "June")
		Return "06"
	If (fnText = "Jul" || fnText = "July")
		Return "07"
	If (fnText = "Aug" || fnText = "August")
		Return "08"
	If (fnText = "Sep" || fnText = "September")
		Return "09"
	If (fnText = "Oct" || fnText = "October")
		Return "10"
	If (fnText = "Nov" || fnText = "November")
		Return "11"
	If (fnText = "Dec" || fnText = "December")
		Return "12"
	Else Return "mm"
}
