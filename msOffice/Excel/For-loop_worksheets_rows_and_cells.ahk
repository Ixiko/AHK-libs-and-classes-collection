; This script opens a workbook and then loops through each sheet. Within each sheet, it finds the last non-blank cell in
; column A. It then loops through each row in the Range from A1 to the last row. Within each row, it loops through each
; cell in the row starting at column A and going until the last non-blank cell in the row.

; Constants
xlToLeft := -4159
xlUp := -4162

Path := A_Desktop "\test.xlsx"  ; The location of the workbook to use for this example.
MyApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
MyApp.Visible := true  ; Make Excel visible.
MyWorkbook := MyApp.Workbooks.Open(Path)  ; Open the workbook specified by 'Path'.

for MySheet, in MyWorkbook.Worksheets  ; For each worksheet in the workbook...
{
    SheetNumber := A_Index
    
    CellA1 := MySheet.Cells(1, 1)  ; Get a reference to Cell A1 on this (MySheet) sheet.
    
    ; Starting at the last cell in column A. ie: .Cells(MyApp.Rows.Count, 1)
    ; Look 'upwards' for a non-blank cell. ie: .End(xlUp)
    ; 'LastCellColumn' will contain a reference to the Range object representing the cell.
    LastCellColumn := MySheet.Cells(MyApp.Rows.Count, 1).End(xlUp)
    
    for MyCellColA, in MySheet.Range(CellA1, LastCellColumn)  ; For each cell in column A...
    {
        ; Get the last cell in the row. This is similar to how the last cell in column A was found.
        ; For each cell in the row...
        for c, in MySheet.Range(MyCellColA, MySheet.Cells(MyCellColA.Row, MyApp.Columns.Count - 1).End(xlToLeft))
        {
            MsgBox, % "MySheet.Name: "      MySheet.Name    "`n"
                    . "SheetNumber: "       SheetNumber         "`n"
                    . "MyCellColA.Row: "    MyCellColA.Row      "`n"
                    . "c.Address: "         c.Address           "`n"
                    . "c.Value: "           c.Value
        }
    }
}
return
