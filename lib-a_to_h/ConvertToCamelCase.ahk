ConvertToCamelCase(ByRef fnCopiedText)
{
	; converts text to camelCase
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


		; convert to Pascal case
		ConvertToPascalCase(fnCopiedText)

		; decapitalise the first character
		PCRE := "iS)^(\w)(.*)"
		NewString := RegExReplace(fnCopiedText,PCRE,"$L1$2")
		
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
#Include ahkfn_ConvertToPascalCase.ahk
params := "hello there matey"
ReturnValue := ConvertToCamelCase(params)
MsgBox, ConvertToCamelCase`n`nReturnValue: %ReturnValue%`n`nparams: %params%
*/