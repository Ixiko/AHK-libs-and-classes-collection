GetDurationFromMilliseconds(fnMilliseconds,fnIncludeMilliseconds = "0",fnPreserveNegative = "0")
{
	If !fnMilliseconds
		Return "00:00:00"
	
	NegativeSign := ""
	If (fnMilliseconds < 0)
	{
		fnMilliseconds := Abs(fnMilliseconds)
		NegativeSign := fnPreserveNegative ? "-" : ""
	}
	
	LeftoverMilliseconds := fnIncludeMilliseconds ? "." . Mod(fnMilliseconds,1000) : ""
	
	fnSeconds            := Floor(fnMilliseconds/1000)
	LeftOverSeconds      := SubStr("00" . Mod(fnSeconds,60),-1)
	
	fnMinutes            := Floor(fnSeconds/60)
	LeftOverMinutes      := SubStr("00" . Mod(fnMinutes,60),-1)
	
	fnHours              := Floor(fnMinutes/60)
	LeftOverHours        := SubStr("00" . Mod(fnHours,24),-1)
	
	fnDays               := Floor(fnHours/24)
	LeftOverDays         := fnDays ? fnDays . "d " : ""
	
	
	Duration = %NegativeSign%%LeftOverDays%%LeftOverHours%:%LeftOverMinutes%:%LeftOverSeconds%%LeftoverMilliseconds%
	Return Duration
		
}


/* ; testing
Duration := GetDurationFromMilliseconds(-984649)
MsgBox, Duration: %Duration%
*/