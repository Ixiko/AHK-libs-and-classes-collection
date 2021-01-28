GetMostRecentTime(fnFirstTime,fnSecondTime)
{
	; returns the later of two datetime stamps
	MostRecentTime := fnFirstTime
	If (fnSecondTime > MostRecentTime)
		MostRecentTime := fnSecondTime
	Return MostRecentTime
}


/* ; testing
SomeFirstTime  := "" ; "20190101000000" ; 
SomeSecondTime := A_Now ; SomeFirstTime ; 
ReturnValue := GetMostRecentTime(SomeFirstTime,SomeSecondTime)
MsgBox, GetMostRecentTime`n`nReturnValue: %ReturnValue%
*/