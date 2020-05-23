GetTimeDifference(fnStartTime,fnEndTime,fnTimeUnits := "Seconds")
{
	; returns difference between two times in the specified units
	; MsgBox fnStartTime %fnStartTime%`nfnEndTime %fnEndTime%`nfnTimeUnits %fnTimeUnits%


	; declare local, global, static variables


	Try
	{
		; set default return value
		TimeDifference := "X"


		; validate parameters
		If fnTimeUnits not in Seconds,S,Minutes,M,Hours,H,Days,D
			Throw, Exception("fnTimeUnits not in Seconds,S,Minutes,M,Hours,H,Days,D")
		
		If !fnStartTime
			fnStartTime := A_Now
		
		If fnStartTime is not time
			Throw, Exception("fnStartTime is not time")
		
		If !fnEndTime
			fnEndTime := A_Now
		
		If fnEndTime is not time
			Throw, Exception("fnEndTime is not time")


		; initialise variables


		; calculate time difference
		TimeDifference := fnEndTime
		EnvSub, TimeDifference, fnStartTime, %fnTimeUnits%

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
TimeUnits := "seconds"
TimeDiff := GetTimeDifference("19000101120000","19000101115959",TimeUnits)
MsgBox, TimeDiff: %TimeDiff% %TimeUnits%
*/