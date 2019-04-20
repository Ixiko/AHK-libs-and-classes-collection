LineBreakOnSqlKeyword(ByRef fnText)
{
	; insert a linebreak before each SQL keyword
	; MsgBox fnText: %fnText%


	; declare local, global, static variables
	Global BreakOnSqlKeywordList


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnText
			Throw, Exception("fnText was empty")


		; initialise variables
		ReturnString := fnText


		; add line-breaks
		PCRE := "imS)(\b)(" BreakOnSqlKeywordList ")(\b)"
		ReturnString := RegExReplace(fnText,PCRE,"$1`r`n$2$3")


		; remove leading line feed
		If (SubStr(ReturnString,1,1) = "`r")
			ReturnString := SubStr(ReturnString,2)

		If (SubStr(ReturnString,1,1) = "`n")
			ReturnString := SubStr(ReturnString,2)
		
		
		; pass string back out
		fnText := ReturnString

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
BreakOnSqlKeywordList = ALTER|AND|BACKUP|COMMIT|CREATE|CROSS|DBCC|DECLARE|DELETE|DROP|EXCEPT|EXEC|EXECUTE|FROM|FULL|GO|GROUP BY|HAVING|IF|INNER|INTERSECT|INTO|LEFT|MERGE|OPTION|ORDER BY|RAISERROR|RETURN|RETURNS|RIGHT|ROLLBACK|SELECT|SET|THROW|UNION|UPDATE|USE|USING|VALUES|WAITFOR|WHERE
SomeText := "ALTER AND BACKUP COMMIT CREATE CROSS DBCC DECLARE DELETE DROP EXCEPT EXEC EXECUTE FROM FULL GO GROUP BY HAVING IF INNER INTERSECT INTO LEFT MERGE OPTION ORDER BY RAISERROR RETURN RETURNS RIGHT ROLLBACK SELECT SET THROW UNION UPDATE USE USING VALUES WAITFOR WHERE"
ReturnValue := LineBreakOnSqlKeyword(SomeText)
MsgBox, LineBreakOnSqlKeyword`n`nReturnValue: %ReturnValue%`n`nSomeText: %SomeText%
*/