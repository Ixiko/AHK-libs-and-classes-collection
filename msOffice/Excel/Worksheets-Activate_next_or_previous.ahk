; F8 hotkey to activate the next sheet.
F8::
    ; Get a reference to the active workbook. One (and only one) instance of Excel must be running.
    Wbk := ComObjActive("Excel.Application").ActiveWorkbook
    
    ; Get the sheet number of the active sheet.
    Idx := Wbk.ActiveSheet.Index
    
    ; If the 'Idx' counter is equal to the total number of sheets, reset the counter.
    if (Idx = Wbk.Worksheets.Count)
        Idx := 0
    Wbk.Worksheets(++Idx).Activate  ; Add 1 to 'Idx' and activate the specified sheet.
return

; F7 hotkey to activate the previous sheet. Similar logic to the F8 hotkey above, only condensed.
F7::(Wbk := ComObjActive("Excel.Application").ActiveWorkbook).Worksheets((Idx := Wbk.ActiveSheet.Index) = 1 
    ? Wbk.Worksheets.Count : Idx - 1).Activate


; These won't "wrap around" like the versions above. ie: when you get to the final sheet, Next.Activate won't loop back
; to the first sheet.
F10::ComObjActive("Excel.Application").ActiveSheet.Next.Activate
F9::ComObjActive("Excel.Application").ActiveSheet.Previous.Activate

; References
; https://autohotkey.com/boards/viewtopic.php?f=5&t=21394
