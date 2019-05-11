GetServerName(fnServerNameLabel)
{
	; get the server name for the corresponding label
	; MsgBox fnServerNameLabel: %fnServerNameLabel%
	
	
	; declare local, global, static variables
	
	
	Try
	{
		; set default return value
		ServerName := ""

		
		; validate parameters
		If !fnServerNameLabel
			Throw, Exception("No server name label provided")
		
		
		; initialise variables

		
		; construct the connection string for this label
		FileRead, ServerNames, %A_MyDocuments%\AutoHotkey\Lib\ExecuteSQL_Servers.txt

		Loop, Parse, ServerNames, `n, `r
		{
			ThisLine := A_LoopField ";" ; add a comment character here to avoid a 0 returned by InStr
			
			ThisLine := Trim(SubStr(ThisLine,1,InStr(ThisLine,";")-1)) ; remove comments
			
			If !ThisLine ; skip blank lines
				Continue
			
			StringSplit, LinePart, ThisLine, `,, %A_Space%%A_Tab%
			
			If (LinePart1 != fnServerNameLabel)
				Continue
			
			ServerName := LinePart2
			Break
		}
		
		If !ServerName
			Throw, Exception("No server name found for label " fnServerNameLabel)
	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,1)
	}
	Finally
	{
	}

	; return
	Return ServerName
}


/* ; testing
SomeLabel := "LOCL"
ReturnValue := GetServerName(SomeLabel)
MsgBox, GetServerName`n`nReturnValue: %ReturnValue%
*/
