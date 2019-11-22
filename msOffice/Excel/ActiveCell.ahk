; This script demonstrates how to get a reference to the active cell in the active Excel application.

xlApp := ComObjActive("Excel.Application")  ; Excel must be running.
MyCell := xlApp.ActiveCell

; Display the results.
MsgBox, % "The cell at address " MyCell.Address " has a value of '" MyCell.Value 
        . "' and has the text '" MyCell.Text "'."

; Note: 'Cell.Value' and 'Cell.Text' may differ from each other depending on the cell contents.
; More info: 
;   http://stackoverflow.com/questions/17359835/what-is-the-difference-between-text-value-and-value2/17363466#17363466
;   https://fastexcel.wordpress.com/2011/11/30/text-vs-value-vs-value2-slow-text-and-how-to-avoid-it/
