DateAdd(fnCount,fnTimeUnits,fnStartDate)
{
	; adds a duration to a timestamp in the specified units
	; MsgBox fnCount: %fnCount%`nfnTimeUnits: %fnTimeUnits%`nfnStartDate: %fnStartDate%


	; declare local, global, static variables


	Try
	{
		; set default return value
		EndDate := ""


		; validate parameters
		If fnCount is not integer
			Throw, Exception("fnCount is not integer")
		
		If fnTimeUnits not in YY,MM,DD,HH,MI,SS
			Throw, Exception("fnTimeUnits not in YY,MM,DD,HH,MI,SS")
		
		If fnStartDate is not date
			Throw, Exception("fnStartDate is not date")


		; initialise variables
		DatePadding := "00000101000000"
		StartDate := fnStartDate . SubStr(DatePadding,StrLen(fnStartDate)+1) ; normalise start date to 14 digits


		; for day or time, use native function
		If fnTimeUnits in DD,HH,MI,SS
		{
			EndDate  := StartDate
			TimeUnit := fnTimeUnits = "SS" ? "S"
					 :  fnTimeUnits = "MI" ? "M"
					 :  fnTimeUnits = "HH" ? "H"
					 :  fnTimeUnits = "DD" ? "D"
					 :                       ""

			EnvAdd, EndDate, %fnCount%, %TimeUnit%

			Return EndDate
		}


		; for year or month
		FormatTime, Year , %StartDate%, yyyy
		FormatTime, Month, %StartDate%, MM
		FormatTime, Day  , %StartDate%, dd
		FormatTime, Time , %StartDate%, HHmmss
		
		If fnTimeUnits in MM
		{
			Month := Mod(Month+fnCount,12)
			Month := "00" (Month < 1 ? Month+12 : Month) ; +12 ensures result > 0
			StringRight, Month, Month, 2
			
			Year += Round(fnCount/12)
			
			If Month in 04,06,09,11
				If Day > 30
					Day := 30
				
			If Month in 02
				If Day > 28
					Day := Mod(Year,4) = 0 ? 29 : 28
		}
		
		If fnTimeUnits in YY
		{
			Year += fnCount
			
			If Month in 02
				If Day > 28
					Day := Mod(Year,4) = 0 ? 29 : 28
		}
		
		EndDate := Year . Month . Day . Time

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return EndDate
}


/* ; testing
Count     := -23
TimeUnits := "MM"
StartDate := "20160912"
ReturnValue := DateAdd(Count,TimeUnits,StartDate)
MsgBox, DateAdd`n`nReturnValue: %ReturnValue%
*/