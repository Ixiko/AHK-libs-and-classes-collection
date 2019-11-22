; Usage:
;   Copy text to the clipboard.
;   Press F7 to search for the clipboard text in columns A and B.
;   If the text is found, the found cell's address is displayed.

; Constants
xlByColumns := 2
xlByRows := 1
xlPart := 2
xlValues := -4163
xlWhole := 1
return

F7::
    ; Remove spaces, tabs, carriage returns, and linefeeds from either end of the clipboard.
    SearchMe := Trim(Clipboard, A_Space A_Tab "`r`n")
    
    ; Here Excel_Get returns the active Excel application object.
    ; Excel_Get https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
    xlApp := Excel_Get()
    
    if !IsObject(xlApp)  ; If Excel_Get fails it returns an error message instead of an object.
    {
        MsgBox, 16, Excel_Get Error, % xlApp
        return
    }
    
    Rng := xlApp.Range("A:B")  ; The range that will be used.
    
    ; Range.Find Method (Excel) - https://msdn.microsoft.com/en-us/library/office/ff839746.aspx
    ; Note: LookIn, LookAt, SearchOrder, and MatchByte are saved each time you use the Find method. From the docs: "To
    ;   avoid problems, set these arguments explicitly each time you use this method."
    ;
    ; Find parameters used here:
    ;       What - 'SearchMe' contains the contents of the clipboard, which was trimmed of spaces, tabs, carriage 
    ;           returns, and linefeeds.
    ;       After - The last cell in Rng.
    ;       LookIn - xlValues (possible constants: xlFormulas, xlValues, or xlNotes)
    ;       LookAt - xlPart (possible constants: xlWhole or xlPart)
    ;       SearchOrder - xlByRows (possible constants: xlByRows or xlByColumns)
    ;       SearchDirection, MatchCase, MatchByte, SearchFormat - blank/default
    ;
    ;_______.Find(What, After, LookIn, LookAt, SearchOrder, SearchDirection, MatchCase, MatchByte, SearchFormat)
    c := Rng.Find(SearchMe, Rng.Cells(Rng.Cells.Count), xlValues, xlPart, xlByRows)
    if (c)
    {
        MsgBox, 64, Cell Address, % c.Address
    }
return

; Excel_Get is required https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
; <Paste the Excel_Get function definition here>
