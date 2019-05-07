ExecuteSQL(fnConnectionString,fnQueryStatement,fnIncludeHeaders,fnResultsAsText := 1)
{
	; ADOSQL v5.04L - By [VxE]
	; http://www.autohotkey.com/community/viewtopic.php?p=558323#p558323
	; Wraps the utility of ADODB to connect to a database, submit a query, and read the resulting recordset. Returns the result as a new object (or array of objects, if the query has multiple statements). To instead have this function return a string, include a delimiter option in the connection string.
	; IMPORTANT! Before you can use this library, you must have access to a database AND know the connection string to connect to your database. Varieties of databases will have different connection string formats, and different drivers (providers).	Use the mighty internet to discover the connection string format and driver for your type of database.
	; Example connection string for SQLServer (2005) listening on port 1234 and with a static IP: DRIVER={SQL SERVER};SERVER=192.168.0.12,1234\SQLEXPRESS;DATABASE=mydb;UID=admin;PWD=12345;APP=AHK
	; Uses an ADODB object to connect to a database, submit a query and read the resulting recordset. By default, this function returns an object. If the query generates exactly one result set, the object is a 2-dimensional array containing that result (the first row contains the column names). Otherwise, the returned object is an array of all the results. To instead have this function return a string, append either ";RowDelim=`n" or ";ColDelim=`t" to the connection string (substitute your preferences for "`n" and "`t").
	; If there is more than one table in the output string, they are separated by 3 consecutive row-delimiters. ErrorLevel is set to "Error" if ADODB is not available, or the COM error code if a COM error is encountered. Otherwise ErrorLevel is set to zero.

	connection_string_generic =
	( ltrim join;
		DRIVER={SQL SERVER}
		SERVER=xServerx
		DATABASE=master
		APP=AHK
	)

	StringReplace, connection_string_PROD, connection_string_generic, xServerx, xxx, All ;insert the current database name
	StringReplace, connection_string_STAG, connection_string_generic, xServerx, xxx, All ;insert the current database name
	StringReplace, connection_string_DEVA, connection_string_generic, xServerx, xxx, All ;insert the current database name
	StringReplace, connection_string_LOCL, connection_string_generic, xServerx, xxx, All ;insert the current database name

	StringReplace, fnConnectionString, fnConnectionString, PROD, %connection_string_PROD%, All ;replace the placeholder text with the correct connection string
	StringReplace, fnConnectionString, fnConnectionString, STAG, %connection_string_STAG%, All ;replace the placeholder text with the correct connection string
	StringReplace, fnConnectionString, fnConnectionString, DEVA, %connection_string_DEVA%, All ;replace the placeholder text with the correct connection string
	StringReplace, fnConnectionString, fnConnectionString, LOCL, %connection_string_LOCL%, All ;replace the placeholder text with the correct connection string
	
	If fnResultsAsText
		fnConnectionString .= ";RowDelim=`n;ColDelim=`t"
	; MsgBox %fnConnectionString%

	;super-globals for debugging your SQL queries
	global ExecuteSQL_LastError
	global ExecuteSQL_LastQuery 

	coer   := "" ;COM object error
	txtout := 0
	rd     := "`n" ;row delimiter
	cd     := "CSV" ;column delimiter
	str    := fnConnectionString ; 'str' is shorter

	; Examine the connection string for output formatting options.
	If ( 9 < oTbl := 9 + InStr( ";" str, ";RowDelim=" ) )
	{
		rd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
	}
	If ( 9 < oTbl := 9 + InStr( ";" str, ";ColDelim=" ) )
	{
		cd := SubStr( str, oTbl, 0 - oTbl + oRow := InStr( str ";", ";", 0, oTbl ) )
		str := SubStr( str, 1, oTbl - 11 ) SubStr( str, oRow )
		txtout := 1
	}

	;disable notification of COM errors
	ComObjError(0) 


	;create a connection object: http://www.w3schools.com/ado/ado_ref_connection.asp
	If !(oCon := ComObjCreate("ADODB.Connection")) 	;if something goes wrong here, return blank and set the error message
	{
		ComObjError(1)
		ErrorLevel := "Error"
		ExecuteSQL_LastError := "Fatal Error: ADODB is not available."
		return ""
	}


	oCon.ConnectionTimeout := 3 ; Allow 3 seconds to connect to the server.
	oCon.CursorLocation := 3 ; Use a client-side cursor server.
	oCon.CommandTimeout := 900 ; A generous 15 minute timeout on the actual SQL statement.
	oCon.Open( str ) ; open the connection.

	; Execute the query statement and get the recordset. > http://www.w3schools.com/ado/ado_ref_recordset.asp
	If !( coer := A_LastError )
		oRec := oCon.execute( ExecuteSQL_LastQuery := fnQueryStatement )

	If !( coer := A_LastError ) ; The query executed OK, so examine the recordsets.
	{
		o3DA := [] ; This is a 3-dimensional array.
		While IsObject( oRec )
			If !oRec.State ; Recordset.State is zero if the recordset is closed, so we skip it.
				oRec := oRec.NextRecordset()
			Else ; A row-returning operation returns an open recordset
			{
				oFld := oRec.Fields
				o3DA.Insert( oTbl := [] )
				oTbl.Insert( oRow := [] )

				Loop % cols := oFld.Count ; Put the column names in the first row.
					oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Name

				While !oRec.EOF ; While the record pointer is not at the end of the recordset...
				{
					oTbl.Insert( oRow := [] )
					oRow.SetCapacity( cols ) ; Might improve performance on huge tables??
					Loop % cols
						oRow[ A_Index ] := oFld.Item( A_Index - 1 ).Value	
					oRec.MoveNext() ; move the record pointer to the next row of values
				}

				oRec := oRec.NextRecordset() ; Get the next recordset.
			}

		If (txtout) ; If the user wants plaintext output, copy the results into a string
		{
			fnQueryStatement := "x"
			Loop % o3DA.MaxIndex()
			{
				fnQueryStatement .= rd rd
				oTbl := o3DA[ A_Index ]
				Loop % oTbl.MaxIndex()
				{
					If !(fnIncludeHeaders) 
						If (A_Index = 1) 
							continue 
					
					oRow := oTbl[ A_Index ]
					Loop % oRow.MaxIndex()
						If ( cd = "CSV" )
						{
							str := oRow[ A_Index ]
							StringReplace, str, str, ", "", A
							If !ErrorLevel || InStr( str, "," ) || InStr( str, rd )
								str := """" str """"
							fnQueryStatement .= ( A_Index = 1 ? rd : "," ) str
						}
						Else
							fnQueryStatement .= ( A_Index = 1 ? rd : cd ) oRow[ A_Index ]
				}
			}
			fnQueryStatement := SubStr( fnQueryStatement, 2 + 3 * StrLen( rd ) )
		}
	}
	Else ; Oh NOES!! Put a description of each error in 'ExecuteSQL_LastError'.
	{
		oErr := oCon.Errors ; > http://www.w3schools.com/ado/ado_ref_error.asp
		fnQueryStatement := "x"
		Loop % oErr.Count
		{
			oFld := oErr.Item( A_Index - 1 )
			str := oFld.Description
			fnQueryStatement .= "`n`n" SubStr( str, 1 + InStr( str, "]", 0, 2 + InStr( str, "][", 0, 0 ) ) )
				. "`n   Number: " oFld.Number
				. ", NativeError: " oFld.NativeError
				. ", Source: " oFld.Source
				. ", SQLState: " oFld.SQLState
		}
		ExecuteSQL_LastError := SubStr( fnQueryStatement, 4 )
		fnQueryStatement := ""
		txtout := 1
	}

	; Close the connection and return the result. Local objects are cleaned up as the function returns.
	oCon.Close()
	ComObjError( 1 )
	ErrorLevel := coer
	Return txtout ? fnQueryStatement : o3DA.MaxIndex() = 1 ? o3DA[1] : o3DA
} 


/* ; testing
ResultsText := ExecuteSQL("LOCL","SELECT * FROM master.sys.tables; SELECT * FROM master.sys.procedures",1)
ErrorText := ErrorLevel
GuiText := ResultsText
If ErrorText
	GuiText := ErrorText

Gui, new,, ResultsWindow
Gui, Add, Text,, %GuiText%
Gui, Show
WinWait, ResultsWindow
WinWaitClose, ResultsWindow
ExitApp
*/ 