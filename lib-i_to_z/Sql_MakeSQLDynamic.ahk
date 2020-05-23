MakeSQLDynamic(ByRef fnText, fnIncludeControlChars = 0)
{
	; converts regular SQL into dynamic SQL
	; MsgBox fnText: %fnText%`nfnIncludeControlChars: %fnIncludeControlChars%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		Tab            := % fnIncludeControlChars ? "+CHAR(9)"  : ""
		LineFeed       := % fnIncludeControlChars ? "+CHAR(10)" : ""
		CarriageReturn := % fnIncludeControlChars ? "+CHAR(13)" : ""


		; make adjustments to dynamic SQL
		fnText := RegExReplace(fnText,"imS)[ \t]+$","") ; trim whitespace from end of each line
		StringReplace, fnText, fnText, ', '', All ; single qoutes to double quotes
		

		; unify line endings
		StringReplace, fnText, fnText, `r`n, `n, All
		StringReplace, fnText, fnText, `n, `r`n, All
		
		
		; quote the text
		PCRE := "imS)^([ \t]*)([-][-])?(.*)$" ; 
		fnText := RegExReplace(fnText,PCRE,"$2$1+'$3 '" CarriageReturn LineFeed)
		
		
		; mid-line comment
		StringReplace, fnText, fnText, % " --", % " '" CarriageReturn LineFeed " --", All
		
		
		; control characters
		If fnIncludeControlChars
		{
			StringReplace, fnText, fnText, %A_Tab%, %Tab%, All ; replace tabs with control chars
			StringReplace, fnText, fnText, +''+,+, All ; tidy up empty strings
		}
		Else
		{
			PCRE := "imS)[ ]+" ; 
			fnText := RegExReplace(fnText,PCRE," ") ; remove double spaces
			
			PCRE := "imSx) ([']) (SELECT|GROUP BY|ORDER BY) ([ ]TOP[(]\d+[)])? ([ ]DISTINCT)? ([ ][']\s*) ([+]['])" ; 
			fnText := RegExReplace(fnText,PCRE,"$1$2$3$4$5 $6") ; then put one space back in for first term after keyword
			
			PCRE := "imS)^([ \t]*)([+]['])([ \t]+)"
			fnText := RegExReplace(fnText,PCRE,"$1$3$2") ; for indented lines, move leading whitespace outside the dynamic string
			
			PCRE := "imSx) (1[=]1[ ][']) (\R) (\s*) ([+][']AND[ ])" ; 
			fnText := RegExReplace(fnText,PCRE,"'$2$3    +'") ; remove '1=1 AND ' condition leader
			
			PCRE := "imSx) (1[=]0[ ][']) (\R) (\s*) ([+][']OR[ ])" ; 
			fnText := RegExReplace(fnText,PCRE,"'$2$3   +'") ; remove '1=0 OR ' condition leader
		}
		
		
		; strip leading +
		fnText := SubStr(fnText,2)

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
Text = 
(
SELECT *
, CASE 
	WHEN [name] = 'tempdb' THEN 'TempDB'
	                       ELSE [name]
  END 
FROM sys.databases AS d
WHERE 1=1
	AND d.database_id = DB_ID()
	--AND d.[name] = 'xxx'
)
; MsgBox %Text%
IncludeControlChars := 1
ReturnValue := MakeSQLDynamic(Text,IncludeControlChars)
MsgBox, MakeSQLDynamic`n`nReturnValue: %ReturnValue%`n`n%Text%
*/