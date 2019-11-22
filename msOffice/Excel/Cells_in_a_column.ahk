; This script will look for the last non-blank cell in column A. Then it loops through each cell in column A starting at
; cell A1 all the way to the last non-blank cell.

WorkbookPath := A_ScriptDir "\MyWorkbook.xlsx"       ; <-- Change this to the path of your workbook
xlApp := ComObjCreate("Excel.Application")                            ; Create an Excel application
xlApp.Visible := true      ; Optional. Just remember to close Excel at the end if it is not visible
MyWorkbook := xlApp.Workbooks.Open(WorkbookPath)                                ; Open the workbook
CellA1 := xlApp.Cells(1, 1)                                          ; Store a reference to cell A1

; Find the last cell in Column 'A' that is not blank.
; Start at the last cell in Column 'A' and look upwards for a non-blank cell
LastCell := xlApp.Cells(xlApp.Rows.Count, 1).End(-4162)                              ; xlUp = -4162

MyRange := xlApp.Range(CellA1, LastCell)               ; Store a reference to the Range A1:LastCell
for MyCell, in MyRange                                              ; For each cell in the range...
{
    MsgBox, % "The value of cell " MyCell.Address " is " MyCell.Text
}
MyWorkbook.Close()                                                             ; Close the workbook
xlApp.Quit()                                                                          ; Close Excel

; References
; https://autohotkey.com/boards/viewtopic.php?p=112648#p112648
