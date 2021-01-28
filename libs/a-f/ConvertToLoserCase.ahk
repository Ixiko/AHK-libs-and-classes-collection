ConvertToLoserCase(ByRef fnCopiedText)
{
	; converts object name from PascalCase to loser_case
	; MsgBox fnCopiedText: %fnCopiedText%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnCopiedText
			Throw, Exception("fnCopiedText was empty")


		; initialise variables
		NewString := fnCopiedText


		; any captial letter not preceded by an underscore gets one
		PCRE := "mS)(?<!_)([A-Z])(\w)"
		NewString := RegExReplace(NewString,PCRE,"_$L1$2")
		
		; any captial letter preceded by an underscore gets decapitalised
		PCRE := "mS)(_[A-Z])" 
		NewString := RegExReplace(NewString,PCRE,"$L1")
		
		; trim leading underscore
		StringLeft, FirstChar, NewString, 1
		NewString := SubStr(NewString,FirstChar = "_" ? 2 : 1) 
		
		; replace spaces with underscores
		StringReplace, NewString, NewString, %A_Space%, _, All
		
		; set the value of the ByRef parameter
		fnCopiedText := NewString

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
fnCopiedText := "hello there matey"
ReturnValue := ConvertToLoserCase(fnCopiedText)
MsgBox, ConvertToLoserCase`n`nReturnValue: %ReturnValue%`n`nfnCopiedText: %fnCopiedText%
*/