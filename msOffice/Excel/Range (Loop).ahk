; This script gets/saves a reference to a Range object ('MyRange'). Then it loops through each item in the Range. Each
; item in the range is a Cell. Each cell is actually a Range object. ie: A range can contain several cells, or only one.

xlApp := ComObjActive("Excel.Application")  ; Excel must be running.

MyRange := xlApp.Range("A1:C4")  ; Get a Range.

for CurrentCell, in MyRange  ; For each item (cell/range) in 'MyRange'...
{
    MsgBox, 65, Cell Info, % "The 'CurrentCell' variable now contains a reference to the Range object at "
                           . CurrentCell.Address ". This cell's value is " CurrentCell.Value ".`n`nContinue?"
    IfMsgBox, Cancel
        break
}
return

; References
;   MS Office COM Basics (5.2 Enumerating Collections) - https://autohotkey.com/boards/viewtopic.php?f=7&t=8978
;   https://autohotkey.com/docs/commands/For.htm
;   Range Object (Excel) - https://msdn.microsoft.com/en-us/library/office/ff838238.aspx
