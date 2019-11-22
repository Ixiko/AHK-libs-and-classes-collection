; Usage:
;   Win+7 hotkey  - Assigns the active cell to the same address on Sheet2.
;   Ctrl+7 hotkey - Assigns a range of cells from the active worksheet to Sheet2.
;   Win+8 hotkey  - Assigns the active cell to the next worksheet.
;   Ctrl+8 hotkey - Assigns a range of cells to the next worksheet.
;   Win+9 hotkey  - Copies the active cell to the same address on Sheet2.
;   Ctrl+9 hotkey - Copies a range of cells to the same range on Sheet2.

; Excel hotkeys
#IfWinActive, ahk_class XLMAIN

; This hoteky copies the active cell to the same address on Sheet2.
#7::  ; Win+7 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    Address := xlApp.ActiveCell.Address  ; Get the address of the active cell.
    
    ; Copy the acative cell to the same address on sheet2.
    xlApp.Worksheets("Sheet2").Range(Address).Value := xlApp.ActiveCell.Value
return


; This hoteky copies cells from the active worksheet to Sheet2. The range of cells copied starts at the active cell and
; includes 15 cells to the right of the active cell. For example, if cell B3 is the active cell, the range B3:Q3 is
; copied.
^7::  ; Ctrl+7 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    ActCell := xlApp.ActiveCell  ; Save the active cell in case it changes.
    
    ; Get the range of 16 cells to be copied. Start at the active cell and end at an offset of 15 columns to the right.
    SourceRange := xlApp.Range( ActCell, ActCell.Offset(0, 15) )
    
    ; Assign the source range to the destination range.
    xlApp.Worksheets("Sheet2").Range( ActCell.Address, ActCell.Offset(0, 15).Address ).Value := SourceRange.Value
return


; This hotkey copies the active cell from the active worksheet to the next worksheet. If the current worksheet is the
; last worksheet, it wraps around to the first sheet.
#8::  ; Win+8 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    SheetNumber := xlApp.ActiveSheet.Index  ; What sheet number are we on? (not the name, we want the number)
    MaxSheetNumber := xlApp.ActiveWorkbook.Worksheets.Count  ; How many sheets are there total?
    if (SheetNumber = MaxSheetNumber)
        SheetNumber := 1  ; If we are on the last sheet, wrap around to the first sheet.
    else
        SheetNumber++  ; Add 1 to the current sheet number to get the next sheet number.
    
    xlApp.Worksheets(SheetNumber).Range( xlApp.ActiveCell.Address ).Value := xlApp.ActiveCell.Value
return


; This hotkey copies a range of cells, starting at the active cell, from the active worksheet to the next worksheet.
^8::  ; Ctrl+8 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    ActCell := xlApp.ActiveCell  ; Save the active cell in case it changes.
    SheetNumber := xlApp.ActiveSheet.Index  ; What sheet number are we on? (not the name, we want the number)
    MaxSheetNumber := xlApp.ActiveWorkbook.Worksheets.Count  ; How many sheets are there total?
    if (SheetNumber = MaxSheetNumber)
        SheetNumber := 1  ; If we are on the last sheet, wrap around to the first sheet.
    else
        SheetNumber++  ; Add 1 to the current sheet number to get the next sheet number.
    
    xlApp.Worksheets(SheetNumber).Range( ActCell.Address, ActCell.Offset(0, 15).Address ).Value
    := xlApp.Range( ActCell, ActCell.Offset(0, 15) ).Value
return


; This hoteky copies the active cell to the same address on Sheet2.
#9::  ; Win+9 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    xlApp.ActiveCell.Copy( xlApp.Worksheets("Sheet2").Range( xlApp.ActiveCell.Address ) )
return


; This hoteky copies cells from the active worksheet to Sheet2. The range of cells copied starts at the active cell and
; includes 15 cells to the right of the active cell. For example, if cell B3 is the active cell, the range B3:Q3 is
; copied.
^9::  ; Ctrl+9 hotkey
    xlApp := Excel_Get()  ; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    ActCell := xlApp.ActiveCell
    xlApp.Range( ActCell, ActCell.Offset(0, 15) ).Copy( xlApp.Worksheets("Sheet2").Range( ActCell.Address ) )
return

; Turn off context-sensitive hotkeys.
#If

; References
; https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Range.ahk
; https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Worksheets-Activate_next_or_previous.ahk
; https://autohotkey.com/boards/viewtopic.php?f=5&t=32839


; Excel_Get - https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
; <Paste the Excel_Get function definition here>
