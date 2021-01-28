; Link:   	https://autohotkey.com/board/topic/94987-functions-rotatetable/?p=598567
; Author:	Learning one
; Date:
; for:     	AHK_L

/*


*/

RotateTable(oTable) {	; Rotates table object. By Learning one.
	Out := [], TotalColumns := oTable.1.MaxIndex()
	Loop, % TotalColumns
		Out.Insert([])
	For k,v in oTable
	{
		For k2,v2 in v
			Out[k2][k] := v2
	}
	return Out
}

/*
;Example:
oTable := [["Ana", "Tucker", "1988", "online"], ["Mia", "Meslin", "1991", "offline"]]
MsgBox % Table2String(oTable)

oRotatedTable := RotateTable(oTable)
MsgBox % Table2String(oRotatedTable)

;===Just a helper function ===
Table2String(oTable, RowsDelim = "`n", ColumnsDelim = "`t") {
	For k,v in oTable
	{
		For k2,v2 in v
			ThisRow .= ColumnsDelim v2
		ThisRow := SubStr(ThisRow, 1+StrLen(ColumnsDelim))
		Out .= RowsDelim ThisRow
		ThisRow := ""
	}
	return SubStr(Out, 1+StrLen(RowsDelim))
}
*/