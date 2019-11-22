; This script demonstrates how to get a reference to a cell in the active Excel application.

xlApp := ComObjActive("Excel.Application")  ; Excel must be running.

MyCell := xlApp.Cells(2, 3)  ; Get the cell at row 2, column 3.
; MyCell := xlApp.Range("C2")  ; Get the cell "C2". (This does the same thing as the previous line.)

; Display the results.
MsgBox, % "The cell at address " MyCell.Address " has a value of '" MyCell.Value 
        . "' and has the text '" MyCell.Text "'."

MyRange := xlApp.Range("D3:F5")  ; Get/save a reference to the specified Range.
SubRng1 := MyRange.Cells(2)  ; Get a cell (range) from within 'MyRange'.
SubRng2 := MyRange.Cells(2, 1)  ; Get a cell (range) from within 'MyRange'.

; Display the results.
MsgBox, % "The cell at address " SubRng1.Address " has a value of '" SubRng1.Value
        . "' and has the text '" SubRng1.Text "'."
MsgBox, % "The cell at address " SubRng2.Address " has a value of '" SubRng2.Value
        . "' and has the text '" SubRng2.Text "'."

; References
;   Range.Cells Property (Excel) - https://msdn.microsoft.com/en-us/library/office/ff196273.aspx
