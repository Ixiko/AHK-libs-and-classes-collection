AddSqlDelimiters(fnCopiedText)
{
	; adds or removes SQL object name delimiters ([,]) to selected text
	; MsgBox fnCopiedText: %fnCopiedText%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := ""


		; validate parameters
		If !fnCopiedText
			Throw, Exception("fnCopiedText is empty")


		; initialise variables
		PCRE := "imSU)(\[)(.*)(\])"


		; add or remove SQL delimiters
		HasBrackets := RegExMatch(fnCopiedText,PCRE)
		If HasBrackets
		{
			ReturnValue := RegExReplace(fnCopiedText,PCRE,"$2")
		}
		Else
		{
			StringReplace, ReturnValue, fnCopiedText, ., `].`[, All
			ReturnValue := "[" fnCopiedText "]"
		}

	}
	Catch, ThrownValue
	{
		; ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := AddSqlDelimiters(params)
MsgBox, AddSqlDelimiters`n`nReturnValue: %ReturnValue%
*/