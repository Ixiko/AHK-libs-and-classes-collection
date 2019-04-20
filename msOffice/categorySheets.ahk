categorySheets(xl){
    global
    sheets = ; Clear sheets
    choice = ; Clear choice
    try
        xl.ActiveSheet.UsedRange.Rows.Count
    catch
    {
        MsgBox,16, %A_ScriptName%, Could not loop through active Excel document. `rMake sure you're not editing a cell and try again.
        ErrorLevel = 1
    }

    if ErrorLevel <> 1 ; Run only if ErrorLevel isn't = 1
    {
        Loop, % xl.ActiveWorkbook.Worksheets.Count {
            sheets .= xl.ActiveWorkbook.Worksheets(A_Index).Name "|" ; Get column headers
        }
    StringTrimRight, sheets, sheets, 1 ; Delete final |-character
    splashList("Select Word comment", sheets)
    }
Return 
}