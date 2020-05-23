ReplaceUserVariables(ByRef fnText)
{
	; replaces user defined variables with their current value
	; MsgBox fnText: %fnText%


	; declare local, global, static variables
	Global


	Try
	{
		; set default return value
		TotalCountOfReplacements := 0


		; validate parameters
		If !fnText
			Return CountOfReplacements


		; initialise variables


		; replace user variables
		fnText := StrReplace(fnText,"xClipboardx"          ,ClipContents                            ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xDataBaseNamex"       ,DBName                                  ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xFileNamex"           ,FileName                                ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xFilePathx"           ,FilePath                                ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xLogToScreenStringx"  ,LogToScreenString                       ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xLogToSystemStringx"  ,LogToSystemString                       ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xProdServerNamex"     ,ProdServerName                          ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xTodaysDatex"         ,A_YYYY "-" A_MM "-" A_DD                ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xTodaysDateShortx"    ,A_YYYY A_MM A_DD                        ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xTodaysDatetimex"     ,A_YYYY "-" A_MM "-" A_DD "-00:00:00.000",CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xTodaysYearx"         ,A_YYYY                                  ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xUsernamex"           ,A_UserName                              ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements
		fnText := StrReplace(fnText,"xVarAssignmentStringx",VarAssignmentString                     ,CountOfReplacements,-1), TotalCountOfReplacements += CountOfReplacements

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return TotalCountOfReplacements
}


/* ; testing
SomeText := "xTodaysDatex for xUsernamex" 
CountOfReplacements := ReplaceUserVariables(SomeText)
MsgBox, ReplaceUserVariables`n`nReturnValue: %CountOfReplacements%`n`n%SomeText%
*/