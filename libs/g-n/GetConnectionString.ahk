GetConnectionString(fnServerName)
{
	; get the connection string for the corresponding server name
	; MsgBox fnServerName: %fnServerName%
	
	
	; declare local, global, static variables
	
	
	Try
	{
		; set default return value
		ConnectionString := ""

		
		; validate parameters
		If !fnServerName
			Throw, Exception("No server name provided")
		
		
		; initialise variables
		ConnectionStringGeneric =
		( LTrim Join; Comments
			DRIVER={SQL SERVER}
			SERVER=xServerNamex
			DATABASE=master
			; UID=admin
			; PWD=12345
			APP=AHK
		)

		
		; construct the connection string for this server name
		StringReplace, ConnectionString, ConnectionStringGeneric, xServerNamex, %fnServerName%
	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,1)
	}
	Finally
	{
	}

	; return
	Return ConnectionString
}


/* ; testing
SomeServerName := "abc\def"
ReturnValue := GetConnectionString(SomeServerName)
MsgBox, GetConnectionString`n`nReturnValue: %ReturnValue%
*/
