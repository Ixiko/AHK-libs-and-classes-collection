DateDiff(fnTimeUnits,fnStartDate,fnEndDate)
{
	; returns the difference between two timestamps in the specified units
	; MsgBox fnTimeUnits: %fnTimeUnits%`nfnStartDate: %fnStartDate%`nfnEndDate: %fnEndDate%


	; declare local, global, static variables


	Try
	{
		; set default return value
		TimeDifference := 0


		; validate parameters
		If fnTimeUnits not in YY,MM,DD,HH,MI,SS
			Throw, Exception("fnTimeUnits were not valid")
		
		If fnStartDate is not date
			Throw, Exception("fnStartDate was not a date")
		
		If fnEndDate is not date
			Throw, Exception("fnEndDate was not a date")


		; initialise variables
		DatePadding := "00000101000000"
		StartDate := fnStartDate . SubStr(DatePadding,StrLen(fnStartDate)+1) ; normalise start date to 14 digits
		EndDate   := fnEndDate   . SubStr(DatePadding,StrLen(fnEndDate  )+1) ; normalise end   date to 14 digits


		; for day or time, use native function
		If fnTimeUnits in DD,HH,MI,SS
		{
			TimeDifference := EndDate
			TimeUnit := fnTimeUnits = "SS" ? "S"
					 :  fnTimeUnits = "MI" ? "M"
					 :  fnTimeUnits = "HH" ? "H"
					 :  fnTimeUnits = "DD" ? "D"
					 :                       ""

			EnvSub, TimeDifference, %StartDate%, %TimeUnit%
		}

		
		; for year or month
		FormatTime, StartYear , %StartDate%, yyyy
		FormatTime, StartMonth, %StartDate%, MM
		FormatTime, StartDay  , %StartDate%, dd
		FormatTime, StartTime , %StartDate%, HHmmss
		
		FormatTime, EndYear , %EndDate%, yyyy
		FormatTime, EndMonth, %EndDate%, MM
		FormatTime, EndDay  , %EndDate%, dd
		FormatTime, EndTime , %EndDate%, HHmmss
		
		If fnTimeUnits in MM
		{
			StartInMonths := (StartYear*12)+StartMonth
			EndInMonths   := (EndYear  *12)+EndMonth
			
			TimeDifference := EndInMonths-StartInMonths
			
			If (StartDate < EndDate)
				If (EndDay < StartDay)
					TimeDifference--
			
			If (StartDate > EndDate)
				If (EndDay > StartDay)
					TimeDifference++
		}
		
		If fnTimeUnits in YY
		{
			TimeDifference := EndYear-StartYear
			
			If (StartDate < EndDate)
				If (EndMonth <= StartMonth)
					If (EndDay < StartDay)
						TimeDifference--
			
			If (StartDate > EndDate)
				If (EndMonth >= StartMonth)
					If (EndDay > StartDay)
						TimeDifference++
		}

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return TimeDifference
}


/* ; testing
SomeTimeUnits := "MM"
SomeStartDate := "19020227"
SomeEndDate   := "19000228"
ReturnValue := DateDiff(SomeTimeUnits,SomeStartDate,SomeEndDate)
MsgBox, DateDiff`n`nReturnValue: %ReturnValue%
*/