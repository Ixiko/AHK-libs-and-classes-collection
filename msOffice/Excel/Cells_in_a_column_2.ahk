; This script gets a range of cells in column A and B. (Like selecting cell A2 and then pressing Ctrl+Shift+Down and
; then Shift+Right.) Then each time the Ctrl+F12 hotkey is pressed it sends the next value.

; Usage:
; Press Ctrl+F12 to send the next value.

; Constants
xlDown := -4121

WorkbookPath := A_ScriptDir "\MyWorkbook.xlsx"       ; <-- Change this to the path of your workbook
xlApp := ComObjCreate("Excel.Application")                            ; Create an instance of Excel
xlApp.Visible := true                                                          ; Make Excel visible
MyWorkbook := xlApp.Workbooks.Open(WorkbookPath)                                ; Open the workbook
CellA2 := xlApp.Cells(2, 1)                                          ; Store a reference to cell A2
LastCell := CellA2.End(xlDown).Offset(0, 1)  ; Store the last cell. .End is like pressing Ctrl+Down
MyRange := xlApp.Range(CellA2, LastCell)               ; Store a reference to the Range A2:LastCell
CellNumber := 1                                   ; This variable will store the cell number to use
CellCount := MyRange.Cells.Count                            ; Store the count of cells in the range
return

^F12::                                                                            ; Ctrl+F12 hotkey
    SendRaw % MyRange.Cells(CellNumber).Text      ; Send the current cell specified by 'CellNumber'
    CellNumber++                                                     ; Increase 'CellNumber' by one
    if (CellNumber > CellCount) {    ; If 'CellNumber' is greater than the total amount of cells...
        MsgBox, 64, Info, Finished. No more cells.                                           ; Done
        CellNumber := 1
    }
return

; References
; As requested here: https://autohotkey.com/boards/viewtopic.php?p=160113#p160113
; https://autohotkey.com/boards/viewtopic.php?p=112648#p112648
; https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Cells_in_a_column.ahk
