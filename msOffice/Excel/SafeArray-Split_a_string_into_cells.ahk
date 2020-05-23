; This script creates a SafeArray from the example string. Linefeeds ("`n") are used to split the string into rows, and
; commas (",") are used to split each row into cells. The safearray is then put into a new Excel workbook starting at
; cell C2.

ExampleStr :=
    (LTrim Join`r`n
       "a,b,c,d
        
        foo
        1
        2,3
        4,5,6,
        7,8"
    )

; Call 'SafeArrayFromStr' to split the string into rows and columns and create a SafeArray. 'MyObj' will contain
; the SafeArray and a count of the number of rows and colums.
; DelimRow = "`n"
; DelimCol = ","
; OmitRow = "`r"
MyObj := SafeArrayFromStr(ExampleStr, "`n", ",", "`r")

xlApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel
xlApp.Visible := true  ; Make Excel visible
Book := xlApp.Workbooks.Add  ; Create a new workbook

; Cell C2. The Cell at the start of the Range where the SafeArray will be inserted.
TopLeftCell := xlApp.Cells(2, 3)

; The Cell at end of Range where the SafeArray will be inserted.
BotRightCell := TopLeftCell.Offset(MyObj.Rows - 1, MyObj.Cols - 1)

; Set the value of the Range to the SafeArray. (The SafeArray is copied into the range.)
; An error will occur if the size of the Range (number of columns and rows) is smaller than the size of the SafeArray.
xlApp.Range(TopLeftCell, BotRightCell).Value := MyObj.SArr
return


; SafeArrayFromStr - https://autohotkey.com/boards/viewtopic.php?f=6&t=19872
; Revised: August 10, 2016
SafeArrayFromStr(Str, DelimRow, DelimCol:="", OmitRow:="", OmitCol:="")
{
    MaxRow := (Rows := StrSplit(Str, DelimRow, OmitRow)).MaxIndex()    ; Remember max row number
    MaxCol := 0
    for i, Row in Rows                                             ; Split each row into columns
        if ((Rows[i] := StrSplit(Row, DelimCol, OmitCol)).MaxIndex() > MaxCol)
            MaxCol := Rows[i].MaxIndex()                            ; Remember max column number
    SafeArray := ComObjArray(12, MaxRow, MaxCol)        ; Create a safearray of the correct size
    for Rn, Row in Rows                                           ; Copy Rows into the safearray
        for Cn, Cell in Row
            SafeArray[Rn - 1, Cn - 1] := Cell             ; Safearray indices start at 0 (not 1)
    return {SArr: SafeArray, Rows: MaxRow, Cols: MaxCol}
}

; References
;    https://autohotkey.com/board/topic/56987-com-object-reference-autohotkey-v11/page-7#entry394713
