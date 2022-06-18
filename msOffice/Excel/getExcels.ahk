
/*

; https://www.autohotkey.com/boards/viewtopic.php?p=463899#p463899

LookForDate := "5/22/2022"
LookForName := "EDUJHEVJ"
FilePath :=  A_ScriptDir "\testfile123.xlsx"
array := getXcells(FilePath,  "sheet1")					    ; probably "blad1" in Dutch
for x,y in array
	if (y.1 = LookForName and y.2 = LookForDate)			; adjust to your need A = 1 D = 4 and F = 6
		msgbox % y.1 " " y.2 " " y.3 						; adjust to your need A = 1 D = 4 and F = 6
return
*/

getXcells(datasource, sheet := "sheet1") } { ;  requires https://www.microsoft.com/en-us/download/details.aspx?id=54920

	global colcnt, rowcnt
	arr := [], rowcnt := 0

	objConnection := ComObjCreate("ADODB.Connection"), 	objRecordSet := ComObjCreate("ADODB.Recordset")

	try objConnection.Open("Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" . dataSource . "; Extended Properties='Excel 12.0 xml;HDR=no;IMEX=1';")
	catch		{
		msgbox,48,, Error! Data could not be retrieved, 2
		return
		}

	try objRecordset.Open("Select * FROM [" Sheet "$]", objConnection, 3, 3, 1) 			; adOpenStatic = 3 , adLockOptimistic = 3 , adCmdText = 1
	catch		{
		msgbox,48,, Error! %Sheet% does not exist, 2
		return
		}

	pFields := objRecordset.Fields

	while !objRecordset.EOF		{
		row := [], ++rowcnt
		Loop, % colcnt := pFields.Count
			row[A_Index] := pFields.Item(A_Index-1).value
		arr.push(row)
		objRecordset.MoveNext
	}

	objRecordSet.Close()
	objConnection.Close()
	objRecordSet := ""
	objConnection := ""

return arr
}