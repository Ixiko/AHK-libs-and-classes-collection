; These are the two files that will be used.
Book1Path := A_ScriptDir "\Workbook1.xlsx"
Book2Path := A_ScriptDir "\Workbook2.xlsx"  ; This workbook receives data when the Ctrl+1 hotkey is pressed. 

; Create an instance of Excel.
xlApp := ComObjCreate("Excel.Application")
xlApp.Visible := true

; Open the two workbooks.
Book1 := xlApp.Workbooks.Open(Book1Path)
Book2 := xlApp.Workbooks.Open(Book2Path)

; Constants
xlUp := -4162

return  ; End of Auto-execute section.


; Excel hotkeys
#IfWinActive, ahk_class XLMAIN

; Hotkey to copy the active cell to the next blank row in Book2. ActiveCell can be in either Book1 or Book2. (ie:
; 'ActiveCell' is a property of the Application object. Workbook and Worksheet objects do not have an 'ActiveCell'
; property.
^1::  ; Ctrl+1 hotkey.
    
    ; Find the next blank row in column A, sheet 1, of Book2. Start at the last cell in Column 'A' and look upwards for
    ; a non-blank cell. Then offset 1 down. (This essentially does the same thing as selecting the last cell in a column
    ; and then pressing the keys 'Ctrl+Up' followed by 'Down'.)
    Cell := Book2.Sheets(1).Cells(xlApp.Rows.Count, 1).End(xlUp).Offset(1, 0)
    
    Cell.Value := xlApp.ActiveCell.Value
return

; Copy data from cell 'B3', sheet 1, 'Book2' --> to --> cell 'A1', sheet 1, 'Book1'
^2::  ; Ctrl+2 hotkey
    Book1.Sheets(1).Range("A1").Value := Book2.Sheets(1).Range("B3").Value
return

; Cut-and-paste cell 'C2', sheet 1, 'Book2' --> to --> cell 'A2', sheet 1, 'Book1'
^3::  ; Ctrl+3 hotkey
    Book2.Sheets(1).Range("C2").Cut( Book1.Sheets(1).Range("A2") )
return

; Turn off context-sensitive hotkeys.
#If


Esc::ExitApp  ; Press 'Escape' to exit this script.
