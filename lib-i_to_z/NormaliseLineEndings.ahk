NormaliseLineEndings(ByRef fnText)
{
	; turn all line endings into CRLF
	; MsgBox fnText: %fnText%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnText
			Return ReturnValue


		; initialise variables
		CountOfAlreadyGood := 0
		CountOfReturns := 0
		CountOfNewLines := 0


		; normalise line-endings `r or `n to `r`n
		fnText := StrReplace(fnText,"`r`n","`n",CountOfAlreadyGood,-1)
		fnText := StrReplace(fnText,"`r","`n",CountOfReturns,-1)
		fnText := StrReplace(fnText,"`n","`r`n",CountOfNewLines,-1)
		
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
SomeText := "hello`rthere`nmatey`r`nhow`rare`r`nyou?`n"
StringReplace, OldText, SomeText, `r, _R, All
StringReplace, OldText, OldText , `n, N`r`n, All
MsgBox, NormaliseLineEndings`n`nReturnValue: %ReturnValue%`n`nOldText:`n%OldText%
ReturnValue := NormaliseLineEndings(SomeText)
StringReplace, NewText, SomeText, `r, _R, All
StringReplace, NewText, NewText , `n, N`r`n, All
MsgBox, NormaliseLineEndings`n`nReturnValue: %ReturnValue%`n`nNewText:`n%NewText%
*/