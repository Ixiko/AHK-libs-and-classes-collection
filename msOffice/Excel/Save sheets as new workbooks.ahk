; This script prompts the user to select a workbook file. Then each sheet in the selected workbook is copied into a
; new workbook. Each new workbook is then saved to the same dir as the original file.

; Select an Excel file to use.
FileSelectFile, SelectedFile, 3, %A_ScriptDir%, Select a file, Excel Workbooks (*.xls; *.xlsx)

; If the selected file does not exist, return.
if !FileExist(SelectedFile)
    return

; Split the file path (to be used later).
SplitPath, SelectedFile, SelectedFileName, SecectedFileDir, SelectedFileExtension, SelectedNameNoExt

; Create an instance of Excel.
xlApp := ComObjCreate("Excel.Application")
xlApp.Visible := true

; Open the source workbook.
wbkSource := xlApp.Workbooks.Open(SelectedFile)

; For each sheet in the workbook...
for sht, in wbkSource.Sheets
{
    ; Add a new workbook to Excel.
    wb := xlApp.Workbooks.Add()
    
    ; Copy the current sheet ('sht') into the new workbook.
    sht.Copy( wb.Sheets(1) )
    
    ; Save the new workbook. Use the 'FindFreeName' function (defined below) to find an unused file name. (ie: A file
    ; name that won't overwite an existing file.)
    wb.SaveAs( FindFreeName(SecectedFileDir, sht.Name, SelectedFileExtension) )
    
    ; Close the new workbook.
    wb.Close(0)
}

; Close the source workbook.
wbkSource.Close(0)

; Quit Excel.
xlApp.Quit
return


; Find an unused file name.
FindFreeName(FileDir, FileName, FileExt)
{
    FilePath := FileDir "\" FileName "." FileExt
    if FileExist(FilePath)  ; If the file exists, loop until an unused name is found.
    {
        Loop,
        {
            FilePath := FileDir "\" FileName "(" (A_Index + 1) ")." FileExt
            if !FileExist(FilePath)
                break
        }
    }
    return, FilePath
}

; References
;   - https://autohotkey.com/boards/viewtopic.php?f=5&t=28963&p=136076#p136076
