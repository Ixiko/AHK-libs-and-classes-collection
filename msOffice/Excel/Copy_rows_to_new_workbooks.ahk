; This script copies rows from one workbook into new workbooks. This was originally made for an "Ask for Help" question
; posted at: https://autohotkey.com/boards/viewtopic.php?f=5&t=34083
; To run this script you will need to set up an example workbook. You can look at the link above for details, but
; basically the workbook looks like this:
;   <---Row 1 (header row)--->
;   <---Row 2 (some data)--->
;   <---Row 3 (blank row)--->
;   <---Row 4 (some data)--->
;   <---Row 5 (some data)--->
;   <---Row 6 (blank row)--->
;   <---Row 7 (some data)--->
;   <---Row 8 (some data)--->
;   ...
; The task is to copy the header and each "chunk" of rows into a new workbook. So, for the example above:
;   Row 1 and 2  are copied into a new workbook.
;   Row 1, 4 and 5 are copied into a new workbook.
;   Row 1, 7 and 8... are copied into a new workbook.
; The new workbooks are named based on a cell in column B. So, for the example above, the names come from the cells in
; column B in rows 2, 4 and 7.

; Select the workbook to use.
FileSelectFile, wbkPath, 1, %A_ScriptDir%, Open, Workbooks (*.xlsx; *.xls)
if (ErrorLevel)  ; User pressed cancel.
    return

; Store the workbook directory.
SplitPath, % wbkPath,, saveDir

; Create an instance of Excel
xlApp := ComObjCreate("Excel.Application")

; Make Excel visible. This line can be removed once you verify that the script runs without any errors.
xlApp.Visible := true

; Open the source workbook.
wbkSrc := xlApp.Workbooks.Open(wbkPath)

; Change the number format in column 'C' (the 3rd column).
wbkSrc.Worksheets(1).Columns(3).NumberFormat := "0.00"

; Get the header row from sheet1.
HeaderRow := wbkSrc.Worksheets(1).Rows(1)

; Get cell A2 on sheet1.
myCell := wbkSrc.Worksheets(1).Range("A2")

; Loop until 'myCell' is blank.
while myCell.Formula != "" {
    
    ; Get a continuous range of cells based on which cells in column A are not blank.
    rng := FindContinuousRange(myCell)

    ; Get the name to use for the new workbook.
    wbkNewName := myCell.Offset(0, 1).Text

    ; Add a new blank workbook.
    wbkNew := xlApp.Workbooks.Add()

    ; Copy the header into the new workbook.
    HeaderRow.Copy( wbkNew.Worksheets(1).Range("A1") )

    ; Copy 'rng' into the new workbook.
    rng.Copy( wbkNew.Worksheets(1).Range("A2") )
    
    ; Autosize all columns on sheet1 in the new workbook.
    wbkNew.Worksheets(1).Columns.AutoFit

    ; SaveAs
    wbkNew.SaveAs(saveDir "\" wbkNewName ".xlsx")

    ; Close the new workbook.
    ;~ MsgBox  ; Pause to see the workbook.
    wbkNew.Close()
    
    ; Get the cell to use for the next loop. (down 2 rows in column A)
    rng := rng.Columns(1)
    myCell := rng.Cells(rng.Cells.Count).Offset(2, 0)
}

; Close the source workbook. 0 = do not save changes.
wbkSrc.Close(0)

; Quit Excel.
xlApp.Quit()
return

FindContinuousRange(rCell) {
    ; Reference http://sitestory.dk/excel_vba/find-next-empty-cell.htm
    static xlDown := -4121
    
    ; If the cell just below is blank.
    if (rCell.Offset(1, 0).Formula = "")
        return rCell.EntireRow
    ; Finds the last cell with content.
    ; .End(xlDown) is like pressing CTRL + down.
    else
        return rCell.Application.Range(rCell, rCell.End(xlDown)).EntireRow
}


; References
;   https://autohotkey.com/boards/viewtopic.php?f=5&t=34083
