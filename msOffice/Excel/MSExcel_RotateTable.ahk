; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

F1::MSExcel_RotateTable()        ; Select range you want to rotate and press F1.
 
MSExcel_RotateTable() {	; Select range you want to rotate and call this function. By Learning one.
	try {
		;oExcel :=  Excel_Get()							; Recommended - by Jethrow/Sean http://www.autohotkey.com/board/topic/88337-ahk-failure-with-excel-get/#entry560328
		oExcel :=  ComObjActive("Excel.Application")	; Alternative - not always reliable...
		oRange :=  oExcel.Selection
	}
	catch
		return
	
	SafeArray := oRange.Value
	if (SafeArray.MaxIndex(1) = "")		; just one cell range - not safe array - nothing to do
		return
	
	;=== Get range dimensions, rotate range ===
	FirstRow := oRange.Row, FirstCoumn := oRange.Column
	TotalRows :=  oRange.Rows.Count, TotalColumns :=  oRange.Columns.Count	
	FirstCellAddress := oExcel.ActiveSheet.Cells(FirstRow, FirstCoumn).Address	; exa: $B$5
	StringReplace, FirstCellAddress, FirstCellAddress, $,, all					; exa: B5
	NewLastCellAddress := oExcel.ActiveSheet.Range(FirstCellAddress).Offset(TotalColumns-1,TotalRows-1).Address	; invert rows and columns
	StringReplace, NewLastCellAddress, NewLastCellAddress, $,, all
	oNewRange := oExcel.ActiveSheet.Range(FirstCellAddress ":" NewLastCellAddress)	; oNewRange is rotated oRange
	
	;=== Get values from SafeArray and build a new one ===
	NewSafeArray := ComObjArray(12, TotalColumns, TotalRows)	; invert rows and columns dimensions
	Loop % SafeArray.MaxIndex(1) ; loop through every row
	{
		RowNum := A_Index
		Loop % SafeArray.MaxIndex(2)  ; loop through every column
			NewSafeArray[A_Index-1, RowNum-1] := SafeArray[RowNum, A_Index]	; invert (note: zero based)
	}
	
	;=== Empty old range, populate and select new range ===
	oRange.Value := "", oNewRange.Value := NewSafeArray, oNewRange.Select
}