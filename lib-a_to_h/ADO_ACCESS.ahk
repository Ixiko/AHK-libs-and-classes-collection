/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; ADO_Write - For use with INSERT or UPDATE statements
;
; Inputs:
;	SQL - An SQL statement eg. 
;			INSERT INTO [table] (columns) VALUES (values);
;	sDbFile - Path to the database file
;
; Returns:
;	On Failure - ADO specific Error Text
;                         Also sets ErrorLevel to the error text
;	On Success - 0
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADO_Write(SQL, sDbFile) {
	pcn := ComObjCreate("ADODB.Connection")
	pcn.ConnectionString := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" . sDbFile . ";"
	pcn.Open()
	If (pcn.State != 1)
	{
		ErrorLevel := "The connection to the database failed"
		Return ErrorLevel
	}
	pcn.Execute(SQL)
	pcn.Close()
	If (ErrorLevel := ADO_GetError(pcn))
	{
		Return ErrorLevel
	}
	Else
	{
		Return 0
	}	
}

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; ADO_Read - For use with SELECT statements
;
; Inputs:
;	SQL - An SQL statement eg. 
;			SELECT ALL * FROM [table];
;	sDbFile - Path to the database file
;	sNames - Set to 1 to return column names from the table
;
; Returns:
;	On Failure - ADO specific Error Text
;                         Also sets ErrorLevel to the error text
;	On Success - Returns data in the following format.
					column1|column2|column3|etc.`n
					column1|column2|column3|etc.`n
				 
				 If sNames is set to 1 an extra data line is 
				 added at the top containing the column names 
				 delimited with | and ending with a ^ 
				 
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADO_Read(SQL, sDbFile, sNames=0) {
	pcn := ComObjCreate("ADODB.Connection")
	pcn.ConnectionString := "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" . sDbFile . ";"
	pcn.Open()
	If (pcn.State != 1)
	{
		ErrorLevel := "The connection to the database failed"
		Return ErrorLevel
	}
	prs := pcn.Execute(SQL)
	If ADO_GetError(pcn)
	{
		ErrorLevel := ADO_GetError(pcn)
		Return ErrorLevel
	}
	If (prs.BOF) and (prs.EOF)
	{
		ErrorLevel := "The returned RecordSet contains no records"
		Return ErrorLevel
	}
	While !prs.EOF
	{
		prsFields := prs.Fields
		Names =
		Loop, % prsFields.Count ;%
		{
			prsField := prsFields.Item(A_Index-1)
			Data .= prsField.Value . "|"
			Names .= prsField.Name . "|"
		}
		StringTrimRight, Data, Data, 1
		Data .= "`n"
		prs.MoveNext()
	}
	pcn.Close()
	StringTrimRight, Names, Names, 1
    StringTrimRight, Data, Data, 1
	If (sNames)
	{
		Return (Names . "^" . Data)
	}
	Else
	{
		Return Data
	}
}

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; ADO_GetError - Returns the last error from the supplied ADO connection Objetc
;
; Inputs:
;	Conn - A current ADO Connection object
;	Text - Set to 0 to return the error number rather than the error text
;			(As far as I can tell this is the same as A_LastError)
;
; Returns:
;	ADO Error Text or Number. If no error detected, returns 0
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADO_GetError(Conn, Text=1) {
	ErrorObj := Conn.Errors.Item(0)
	If !ErrorObj
	{
		Return 0
	}
	If Text
	{
		Return % ErrorObj.Description
	}
	Else
	{
		Return % ErrorObj.Number
	}
}