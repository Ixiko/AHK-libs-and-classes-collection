; This script adds some example data to Excel and then sets some PageSetup properties.

; Constants
msoTrue := -1  ; true = -1 in VBA

xlApp := ComObjCreate("Excel.Application")  ; Create an instance of Excel.
xlApp.Visible := true             ; Make Excel visible.
WrkBk := xlApp.Workbooks.Add      ; Add a new blank workbook.
s1 := xlApp.Worksheets("Sheet1")  ; Save a reference to Sheet1 since we will be using that sheet several times later.

; Simple way to copy a small amount of data into Excel. Use a SafeArray for increased speed.
for CurCell in s1.Range("A1:AF8")  ; For each cell in the range A1:AF8...
    CurCell.Value := A_Index - 1   ; Add some dummy data.

; ***Version Added:  Excel 2010***
; Set the PrintCommunication property to False to speed up the execution of code that sets PageSetup properties. Set the
; PrintCommunication property to True after setting properties to commit all cached PageSetup commands.
xlApp.Application.PrintCommunication := false

; If the Zoom property is True, the FitToPagesWide property is ignored.
s1.PageSetup.Zoom := 0

; FitToPagesWide - Returns or sets the number of pages wide the worksheet will be scaled to when it's printed.
s1.PageSetup.FitToPagesWide := 1

; If this property is False, Microsoft Excel scales the worksheet according to the FitToPagesWide property.
s1.PageSetup.FitToPagesTall := false

xlApp.PrintCommunication := msoTrue
