ExecuteSQL(fnConnectionString,fnQueryStatement,fnIncludeHeaders,fnResultsAsText := 1)
{
	; ADOSQL v5.04L - By [VxE]
	; http://www.autohotkey.com/community/viewtopic.php?p=558323#p558323
	; Wraps the utility of ADODB to connect to a database, submit a query, and read the resulting recordset. Returns the result as a new object (or array of objects, if the query has multiple statements). To instead have this function return a string, include a delimiter option in the connection string.
	; IMPORTANT! Before you can use this library, you must have access to a database AND know the connection string to connect to your database. Varieties of databases will have different connection string formats, and different drivers (providers).	Use the mighty internet to discover the connection string format and driver for your type of database.
	; Example connection string for SQLServer (2005) listening on port 1234 and with a static IP: DRIVER={SQL SERVER};SERVER=192.168.0.12,1234\SQLEXPRESS;DATABASE=mydb;UID=admin;PWD=12345;APP=AHK
	; Uses an ADODB object to connect to a database, submit a query and read the resulting recordset. By default, this function returns an object. If the query generates exactly one result set, the object is a 2-dimensional array containing that result (the first row contains the column names). Otherwise, the returned object is an array of all the results. To instead have this function return a string, append either ";RowDelim=`n" or ";ColDelim=`t" to the connection string (substitute your preferences for "`n" and "`t").
	; If there is more than one table in the output string, they are separated by 3 consecutive row-delimiters. ErrorLevel is set to "Error" if ADODB is not available, or the COM error code if a COM error is encountered. Otherwise ErrorLevel is set to zero.
	; MsgBox fnConnectionString: %fnConnectionString%`n`nfnQueryStatement:`n%fnQueryStatement%`n`nfnIncludeHeaders: %fnIncludeHeaders%`n`nfnResultsAsText: %fnResultsAsText%


	; declare local, global, static variables
	Global ExecuteSQL_LastError, ExecuteSQL_LastQuery ; super-globals for debugging your SQL queries


	Try
	{
		; set default return value
		QueryResultsText := ""


		; validate parameters
		If !fnConnectionString
			Throw, Exception("No connection string was provided")

		If !fnQueryStatement
			Throw, Exception("No query statement was provided")


		; initialise variables
		ExecuteSQL_LastQuery := fnQueryStatement
		RowDelim             := "`n"
		ColDelim             := "`t"
		ConnectionString     := fnConnectionString
		COMObjectError       := ""
		CSVOutput            := 0


		; examine the connection string for output formatting options
		StringSplit, CxnToken, ConnectionString, `;
		Loop, %CxnToken0%
		{
			StringSplit, CxnParameter, % CxnToken%A_Index%, =
			If CxnParameter1 contains RowDelim,ColDelim
			{
				%CxnParameter1% := CxnParameter2 = "CSV" ? "," : CxnParameter2
				CSVOutput := CxnParameter2 = "CSV" ? "1" : CSVOutput
				StringReplace, ConnectionString, ConnectionString, % ";" CxnToken%A_Index%,, All
			}
		}
		; MsgBox RowDelim: x%RowDelim%x`nColDelim: x%ColDelim%x


		; disable notification of COM errors
		ComObjError(0)


		; create a connection object: http://www.w3schools.com/ado/ado_ref_connection.asp
		oConnection := ComObjCreate("ADODB.Connection")
		If !oConnection 	; if something goes wrong here, return blank and set the error message
		{
			ComObjError(1)
			ErrorLevel := "Error"
			ExecuteSQL_LastError := "Fatal Error: ADODB is not available."
			Return ""
		}
		oConnection.ConnectionTimeout := 3   ; Allow 3 seconds to connect to the server
		oConnection.CursorLocation    := 3   ; Use a client-side cursor server
		oConnection.CommandTimeout    := 900 ; A generous 15 minute timeout on the actual SQL statement
		oConnection.Open(ConnectionString) ; open the connection
		If (COMObjectError := A_LastError) ; capture the error
			Throw, Exception("Unable to open a connection to the database",,1)


		; execute the query statement and get the returned rows: http://www.w3schools.com/asp/ado_ref_recordset.asp
		oQueryResults := oConnection.Execute(ExecuteSQL_LastQuery) ; the returned recordset is always a read-only, forward-only recordset
		If (COMObjectError := A_LastError) ; capture the error
			Throw, Exception("Query completed with errors",,2)


		; examine the returned rows
		o3DA := [] ; create a 3-dimensional array
		While IsObject(oQueryResults)
		{
			If oQueryResults.State && !(oQueryResults.BOF && oQueryResults.EOF) ; State is zero if the recordset is closed ; for an empty set BOF and EOF are both true
			{
				o3DA.Insert(oTable := []) ; insert an empty table into the array
				oTable.Insert(oRow := []) ; insert an empty row into the table
				oFields := oQueryResults.Fields
				CountOfColumns := oFields.Count

				; put the column names in the first row
				If fnIncludeHeaders
				{
					Loop, % CountOfColumns
					{
						If fnResultsAsText
							QueryResultsText .= oFields.Item(A_Index-1).Name ColDelim
						Else
							oRow[A_Index] := oFields.Item(A_Index-1).Name
					}
					QueryResultsText .= CSVOutput ? "" : RowDelim
				}

				; construct result set
				TheseResultsText := ""
				If fnResultsAsText && !CSVOutput ; regular text results (not CSV)
					TheseResultsText .= oQueryResults.GetString(2,-1,ColDelim,RowDelim)
				Else ; build the results point by point
				{
					While !oQueryResults.EOF ; while the record pointer is not at the end of the recordset
					{
						oTable.Insert(oRow := []) ; insert a new row
						oRow.SetCapacity(CountOfColumns) ; set row width ; might improve performance on huge tables
						Loop, % CountOfColumns
						{
							ThisDataPoint := oFields.Item(A_Index-1).Value
							If fnResultsAsText && CSVOutput
							{
								If ThisDataPoint contains ,,," ; comma or double-quote
									ThisDataPoint := """" StrReplace(ThisDataPoint,"""","""""") """" ; turn double-quotes into double double-quotes and double-quote the whole string
								TheseResultsText .= (A_Index = 1 ? RowDelim : ",") ThisDataPoint
							}
							Else
								oRow[A_Index] := ThisDataPoint ; populate the row with values
						}
						oQueryResults.MoveNext() ; move the record pointer to the next row of the result set
					}
				}
				QueryResultsText .= TheseResultsText RowDelim RowDelim
			}
			oQueryResults := oQueryResults.NextRecordset() ; go to the next result set
		}
	}
	Catch, ThrownValue
	{
		; capture error values
		ErrorMessage := ThrownValue.Message, ErrorWhat := ThrownValue.What, ErrorExtra := ThrownValue.Extra, ErrorFile := ThrownValue.File, ErrorLine := ThrownValue.Line
		RethrowMessage := "Error at line " ErrorLine " of " ErrorWhat (ErrorMessage ? ": `n`n" ErrorMessage : "") ; (ErrorExtra ? "`n" ErrorExtra : "") (ErrorFile ? "`n`n" ErrorFile  : "")


		; set return value
		ReturnValue := !ReturnValue


		; take action on the error
		QueryResultsText := ""
		ErrorText := RethrowMessage ; ""
		oErrors := oConnection.Errors ; http://www.w3schools.com/asp/ado_ref_error.asp
		Loop, % oErrors.Count
		{
			oThisError := oErrors.Item(A_Index-1)
			ErrorDescription := oThisError.Description
			ErrorText .= (ErrorText ? "`n`n" : "")
				. Trim(SubStr(ErrorDescription,InStr(ErrorDescription,"]",0,InStr(ErrorDescription,"][",0,0)+2)+1)) ; text between the last two []
				. "`n`Number: "      oThisError.Number
				. "`n`NativeError: " oThisError.NativeError
				. "`n`Source: "      oThisError.Source
				. "`n`SQLState: "    oThisError.SQLState
		}

		If (ErrorExtra = 1)
			ErrorText .= "`n`n" ConnectionString

		If (ErrorExtra = 2)
			ErrorText .= "`n`n" ExecuteSQL_LastQuery

		ExecuteSQL_LastError := ErrorText

		; InfoTip(RethrowMessage,,,3,A_ThisFunc,1,10000)
		; MsgBox, 8500, %ApplicationName%, %RethrowMessage%`n`nOpen containing file?`n`n%ErrorFile%
		; IfMsgBox, Yes
			; Run, Edit %ErrorFile%


		; rethrow error to caller
		; Throw, RethrowMessage
	}
	Finally
	{
		; Close the connection. Local objects are cleaned up as the function returns.
		oConnection.Close()
		ComObjError(1)
		ErrorLevel := COMObjectError
	}

	; return
	Return fnResultsAsText     ? QueryResultsText
		 : o3DA.MaxIndex() = 1 ? o3DA[1]
		 :                       o3DA
		 ; : o3DA.MaxIndex()
}


/* ; testing
SqlText =
( LTrim
	SELECT 'Hello, mate, how are you?' AS Greeting,'not so bad. yourself?' AS Response
	UNION ALL
	SELECT 'Bibble, bobble','"umpty",dumpty';

	SELECT STUFF(name,4,1,'"') AS name, * FROM master.sys.tables;

	--SELECT * FROM master.sys.procedures;

	SELECT STUFF(name,4,1,',') AS name, * FROM master.sys.databases;
)

; SqlText =
; ( LTrim
	; CREATE TABLE tempdb.dbo.SomeTable (Id int, Blurb varchar(500))
	; GO

	; INSERT INTO tempdb.dbo.SomeTable VALUES (99, 'Blurb');
	; GO

	; SELECT * FROM tempdb.dbo.SomeTable;
	; GO

	; DROP TABLE tempdb.dbo.SomeTable;
	; GO
; )

; SqlText := "SELECT 1/0"

ServerName := GetServerName("LOCL")
ConnectionString := GetConnectionString(ServerName)
ResultsText := ExecuteSQL(ConnectionString,SqlText,1,1)
ErrorText := ExecuteSQL_LastError
GuiText := ErrorText ? ErrorText : ResultsText "`n`n" "Query executed successfully."

Gui, new,, ResultsWindow
; Gui, +Wrap
Gui, Add, Text, +Wrap, %GuiText%
Gui, Show
WinWait, ResultsWindow
WinWaitClose, ResultsWindow
ExitApp
*/