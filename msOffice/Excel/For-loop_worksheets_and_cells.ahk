; This script opens a workbook and then loops through each sheet. Within each sheet, it finds the last non-blank cell in
; column A. It then loops through each cell in the Range from A1 to the last cell.

; Constants
xlUp := -4162

Path := A_Desktop "\Test.xlsx"  ; The location of the workbook to use for this example.
MyApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
MyApp.Visible := true  ; Make Excel visible.
MyWorkbook := MyApp.Workbooks.Open(Path)  ; Open the workbook specified by 'Path'.

for MyWorksheet, in MyWorkbook.Worksheets  ; For each worksheet in the workbook...
{
    SheetNumber := A_Index
    
    CellA1 := MyWorksheet.Cells(1, 1)  ; Get a reference to Cell A1 on this sheet (MyWorksheet).
    
    ; Starting at the last cell in column A. ie: .Cells(MyApp.Rows.Count, 1)
    ; Look 'upwards' for a non-blank cell. ie: .End(xlUp)
    ; 'LastCell' will contain a reference to the Range object representing the cell.
    LastCell := MyWorksheet.Cells(MyApp.Rows.Count, 1).End(xlUp)
    
    ; This is another way to get the last row. UsedRange has some weird quirks though.
    ;~ LastRow := MyWorksheet.UsedRange.Rows.Count
    
    ; This is another way to make the for-loop. A bit clumsier IMO than using Range references as shown below.
    ;~ for MyCell, in MyWorksheet.Range("A1:A" LastRow)
    
    for MyCell, in MyWorksheet.Range(CellA1, LastCell)  ; For each cell in the Range...
    {
        MsgBox, % "Sheet: "         MyWorksheet.Name    "`n"
                . "SheetNumber: "   SheetNumber         "`n"
                ;~ . "LastRow: "       LastRow             "`n"
                . "MyCell.Row: "    MyCell.Row          "`n"
                . "MyCell.Value: "  MyCell.Value
    }
}
return
