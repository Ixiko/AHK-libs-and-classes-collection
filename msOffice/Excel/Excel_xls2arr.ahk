xls2arr(xlsFile, ByRef retArr) {
	ComObjError(0)

	Loop, % xlsFile
		xlsFile := A_LoopFileLongPath

	If !xl := ComObjGet(xlsFile) {
		xl := ComObjCreate("Excel.Application")
		xl.Workbooks.Open(xlsFile)
		needClose := True
	}

	retArr := []
	Loop, % xl.ActiveSheet.UsedRange.Rows.Count
	{
		row := A_Index
		Loop, % xl.ActiveSheet.UsedRange.Columns.Count
			retArr[row, A_Index] := xl.ActiveSheet.Cells(row, A_Index).text
	}

	needClose ? xl.Close : ""
	Return resultArr.MaxIndex()
}