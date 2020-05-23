GetColumnList(fnTableName,fnDatabaseName = "xDatabaseNamex")
{
	; returns a comma-separated list of the columns for a given table in a database
	; MsgBox fnTableName: %fnTableName%`nfnDatabaseName: %fnDatabaseName%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ColumnList := ""


		; validate parameters
		If !fnTableName
			Throw, Exception("fnTableName was empty",-1,"AlwaysSilent")


		; initialise variables
		SQL := "
		( LTrim
			USE xDatabaseNamex
			SELECT name
			FROM sys.columns
			WHERE 1=1
				AND [object_id] = OBJECT_ID(N'xTableNamex')
				AND is_computed = 0
			ORDER BY column_id
		)"


		; do something
		StringReplace, SQL, SQL, xTableNamex, %fnTableName%, All ; insert the table name
		StringReplace, SQL, SQL, xDatabaseNamex, %fnDatabaseName%, All ; insert the database name
		ColumnList := ExecuteSQL("PROD" ";RowDelim=`,;ColDelim=`t",SQL,0) ; comma separated

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ColumnList
}


/* ; testing
params := xxx
ReturnValue := GetColumnList(params)
MsgBox, GetColumnList`n`nReturnValue: %ReturnValue%
*/