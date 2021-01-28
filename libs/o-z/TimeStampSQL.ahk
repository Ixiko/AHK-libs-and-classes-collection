TimeStampSQL(fnAhkTimeStamp := "",fnIncludeT := 0)
{
	; converts an AHK timestamp to an SQL timestamp
	; MsgBox fnAhkTimeStamp: %fnAhkTimeStamp%`nfnIncludeT: %fnIncludeT%


	; declare local, global, static variables


	Try
	{
		; set default return value
		SQLTimeStamp := ""


		; validate parameters
		If (fnAhkTimeStamp = "")
			Throw, Exception("fnAhkTimeStamp was empty")
		
		If fnAhkTimeStamp is not time
			Throw, Exception("fnAhkTimeStamp is not time")
		
		If (StrLen(fnAhkTimeStamp) > 14)
			Throw, Exception("fnAhkTimeStamp was longer that 14 characters")


		; initialise variables


		; format timestamp
		DefaultTimestamp := "20000101000000"
		fnAhkTimeStamp := fnAhkTimeStamp SubStr(DefaultTimestamp,StrLen(fnAhkTimeStamp)-13)
		
		FormatTime, ThisYear  , %fnAhkTimeStamp%, yyyy
		FormatTime, ThisMonth , %fnAhkTimeStamp%, MM
		FormatTime, ThisDay   , %fnAhkTimeStamp%, dd
		FormatTime, ThisHour  , %fnAhkTimeStamp%, HH
		FormatTime, ThisMinute, %fnAhkTimeStamp%, mm
		FormatTime, ThisSecond, %fnAhkTimeStamp%, ss
		
		SQLTimeStamp := ThisYear "-" ThisMonth "-" ThisDay (fnIncludeT ? "T" : " ") ThisHour ":" ThisMinute ":" ThisSecond


	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return SQLTimeStamp
}


/* ; testing
SomeTimeStamp := "201505161124"
ReturnValue := TimeStampSQL(SomeTimeStamp,0)
MsgBox, TimeStampSQL`n`nReturnValue: %ReturnValue%
*/