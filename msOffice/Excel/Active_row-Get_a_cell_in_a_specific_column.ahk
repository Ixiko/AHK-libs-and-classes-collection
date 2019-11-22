; This script will display the value of the cell in column 'D' of the active row.

; Excel hotkeys
#IfWinActive, ahk_class XLMAIN

^1::  ; Ctrl+1 hotkey.
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    MyValue := xlApp.ActiveCell.EntireRow.Cells(4).Value  ; Column 'D' is the 4th column in the row.
    MsgBox, 64, Column D Cell Value, % "The value of the cell in column D of the active row is:`n" MyValue
return

; Turn off context-sensitive hotkeys.
#If


Esc::ExitApp  ; Press 'Escape' to exit this script.

; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
; <Paste the Excel_Get function definition here>
