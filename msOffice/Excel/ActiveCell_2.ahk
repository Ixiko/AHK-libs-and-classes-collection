; This script selects the cell to the right of the active cell. Excel must be running and not in Edit mode.

xlApp := ComObjActive("Excel.Application")
xlApp.ActiveCell.Offset(0, 1).Select

; References
;   https://autohotkey.com/boards/viewtopic.php?p=143720#p143720
