CountOfFiles(fnFilePattern,fnMode := "F")
{
	; returns a count of all files that match the file pattern provided
	; MsgBox fnFilePattern: %fnFilePattern%`nfnMode: %fnMode%


	; declare local, global, static variables


	Try
	{
		; set default return value
		CountOfFiles := 0


		; validate parameters
		If (StrLen(fnFilePattern) = 0)
			Throw, Exception("fnFilePattern was empty")
		
		If fnMode not contains D,F,R
			Throw, Exception("fnMode doesn't contain D,F,R")

		; initialise variables		
		If !RegExMatch(fnFilePattern,"iS)^([A-Z]:|\\)\\(\w+\\)*([\w\*]+\.[\w\*]+)$")
			fnFilePattern .= "\*.*"
			
		If (fnMode = "R")
			fnMode := "FR"


		; count files
		Loop, Files, %fnFilePattern%, %fnMode%
			CountOfFiles++


	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return CountOfFiles
}


/* ; testing
RootPath := "C:\Test"
FileCount := CountOfFiles(RootPath,"R")
MsgBox, %RootPath% has %FileCount% files.
*/