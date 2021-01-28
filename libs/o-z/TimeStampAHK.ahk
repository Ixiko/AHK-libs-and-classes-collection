TimeStampAHK(fnSqlTimeStamp := "")
{
	; convert an SQL timestamp to an AHK one
	; MsgBox fnSqlTimeStamp: %fnSqlTimeStamp%


	; declare local, global, static variables


	Try
	{
		; set default return value
		AHKTimeStamp := ""


		; validate parameters
		If (fnSqlTimeStamp = "")
			Throw, Exception("fnSqlTimeStamp was empty")


		; initialise variables


		; trim a dot and everything after
		StringGetPos, DotPosn, fnSqlTimeStamp, ., R
		DotPosn := InStr(fnSqlTimeStamp,.,0,0) ; search for first dot from right
		If DotPosn
			StringLeft, fnSqlTimeStamp, fnSqlTimeStamp, % DotPosn-1
		
		
		; remove non-digit timestamp characters
		AhkTimeStamp := fnSqlTimeStamp
		StringReplace, AhkTimeStamp, AhkTimeStamp, -,,A ; remove dashes
		StringReplace, AhkTimeStamp, AhkTimeStamp, :,,A ; remove colons
		StringReplace, AhkTimeStamp, AhkTimeStamp, %A_Space%,,A ; remove spaces
		
		
		; check for non-timestamp characters
		RegExReplace(AhkTimeStamp,"S)\D","x",CountOfReplacements) ; replacement all non-digit characters with an 'x' and count the number of replacements
		If CountOfReplacements > 0
			Throw, Exception("Non-digit characters found")
			
		If (StrLen(AhkTimeStamp) > 14)
			Throw, Exception("AhkTimeStamp longer than 14 characters")
		
		DefaultTimestamp := "20000101000000"
		If (StrLen(AhkTimeStamp) < 14)
		{
			StringRight, TrailingTimeValues, DefaultTimestamp, 14-StrLen(AhkTimeStamp)
			AhkTimeStamp := AhkTimeStamp . TrailingTimeValues
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
	Return AHKTimeStamp
}


/* ; testing
SomeTimeStamp := "2015-05-16 11:24:13.123"
ReturnValue := TimeStampAHK(SomeTimeStamp)
MsgBox, TimeStampSQL`n`nReturnValue: %ReturnValue%
*/