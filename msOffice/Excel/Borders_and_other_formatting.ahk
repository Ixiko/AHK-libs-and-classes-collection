; This script copies example data from an object into a SafeArray. The SafeArray is then assigned to a Range in Excel.
; Some formatting is then added such as bold text, column widths and borders.

; Constants
msoTrue := -1
xlContinuous := 1
xlDown := -4121
xlEdgeBottom := 9
xlEdgeLeft := 7
xlEdgeRight := 10
xlEdgeTop := 8
xlInsideHorizontal := 12
xlInsideVertical := 11
xlMedium := -4138
xlRight := -4152
xlThin := 2

; The example object. 
ExObj := [ [2, "Abc", "asdf1234"]
         , [3, "Xyz", "zxcv2345"] 
         , [5, "Lmn", "qwer3456"]
         , [7, "Opq", "dfgh4567"] ]

xlApp := ComObjCreate("Excel.Application")  ; Create an Excel Application object.
xlApp.Visible := true                       ; Make Excel visible.
WrkBk := xlApp.Workbooks.Add                ; Create a new Workbook object.

; Create a SafeArray containing the proper amount of rows and columns. 4 extra rows are added for the column headings,
; a blank row, user and date.
SafeArray := ComObjArray(12, ExObj.MaxIndex() + 4, 3)

; Put data into the SafeArray. These items will eventually be in cells A1, B1 and A2.
SafeArray[0, 0] := "User:", SafeArray[0, 1] := A_UserName
SafeArray[1, 0] := "Date:"

; Headings. Cells A3, B3 and C3.
SafeArray[3, 0] := "Quantity"
SafeArray[3, 1] := "Item"
SafeArray[3, 2] := "Code"

; Insert the items from ExObj into the SafeArray.
for RowNumber, Row in ExObj
    for FieldNumber, FieldValue in Row
        SafeArray[RowNumber + 3, A_Index - 1] := FieldValue

TopLeftCell := xlApp.Worksheets(1).Cells(1, 1)  ; The top left cell where the data will be inserted.

; Bot. right cell where the data will be inserted.
BotRightCell := xlApp.Worksheets(1).Cells(ExObj.MaxIndex() + 4, ExObj.1.MaxIndex())

TotalRange := xlApp.Range(TopLeftCell, BotRightCell)
TotalRange.Value := SafeArray  ; Copy the SafeArray into the range.

xlApp.Worksheets(1).Range("B2").NumberFormat := "@"  ; NumberFormat @=Text
xlApp.Worksheets(1).Range("B2").Value := A_MMMM " " A_DD ", " A_YYYY

; Cells A1:A2. Bold and align to the right. 
ThisRange := xlApp.Worksheets(1).Range("A1:A2")
ThisRange.Font.Bold := msoTrue
ThisRange.HorizontalAlignment := xlRight

; Cells A4:C4. Bold and add borders.
ThisRange := xlApp.Worksheets(1).Range("A4:C4")
ThisRange.Font.Bold := msoTrue
ThisRange.Borders(xlInsideVertical).LineStyle := xlContinuous
ThisRange.Borders(xlInsideVertical).Weight := xlMedium
for i, Const in [xlEdgeLeft, xlEdgeTop, xlEdgeBottom, xlEdgeRight] {
    ThisRange.Borders(Const).LineStyle := xlContinuous
    ThisRange.Borders(Const).Weight := xlMedium
}

; Set column widths.
for i, Col in [1, 3] {
    TopLeftCell := xlApp.Worksheets(1).Cells(4, Col)
    BotRightCell := TopLeftCell.End(xlDown)
    xlApp.Worksheets(1).Range(TopLeftCell, BotRightCell).Columns.AutoFit
}
xlApp.Worksheets(1).Columns("B:B").ColumnWidth := 40  ; Fixed width column.

; More borders.
TopLeftCell := xlApp.Worksheets(1).Cells(5, 1)
BotRightCell := xlApp.Worksheets(1).Cells(ExObj.MaxIndex() + 4, ExObj.1.MaxIndex())
ThisRange := xlApp.Range(TopLeftCell, BotRightCell)
ThisRange.Borders(xlInsideVertical).LineStyle := xlContinuous
ThisRange.Borders(xlInsideVertical).Weight := xlMedium
ThisRange.Borders(xlInsideHorizontal).LineStyle := xlContinuous
ThisRange.Borders(xlInsideHorizontal).Weight := xlThin
for i, Const in [xlEdgeLeft, xlEdgeTop, xlEdgeBottom, xlEdgeRight] {
    ThisRange.Borders(Const).LineStyle := xlContinuous
    ThisRange.Borders(Const).Weight := xlMedium
}

TotalRange.Select
WrkBk.Saved := msoTrue
WrkBk.PrintPreview(msoTrue)
