ConvertToPascalCase(ByRef fnCopiedText)
{
	; converts object name from loser_case to PascalCase
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


		; convert to title case
		StringLower, NewString, fnCopiedText, T
		
		; remove underscores and capitalize
		PCRE := "imS)([_])(\w)"
		NewString := RegExReplace(NewString,PCRE,"$U2")
		
		; capitalize
		PCRE := "imS)([ ,\(])(\[?)([\@\#])?(\w)"
		NewString := RegExReplace(NewString,PCRE,"$1$2$3$U4") 
		
		; id -> Id
		PCRE := "imS)(.*)(id)$"
		NewString := RegExReplace(NewString,PCRE,"$1Id") 
		
		; kb -> KB etc.
		PCRE := "imS)(.*)((k|m|g|t)b)$"
		NewString := RegExReplace(NewString,PCRE,"$1$U2") 
		
		; remove spaces
		StringReplace, NewString, NewString, %A_Space%,, All
		
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
params := "hello there matey"
ReturnValue := ConvertToPascalCase(params)
MsgBox, ConvertToPascalCase`n`nReturnValue: %ReturnValue%`n`nparams: %params%
*/