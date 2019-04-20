titleColumn(xl) {
	global
    titles = ; Clear titles 
    choice = ; Clear choice
    try
        xl.ActiveSheet.UsedRange.Rows.Count
    catch
    {
        MsgBox,16, %A_ScriptName%, Could not loop through active Excel document found. `rMake sure you're not editing a cell and try again.
        ErrorLevel = 1
    }
    if ErrorLevel <> 1 ; Run only if ErrorLevel isn't = 1
    {
	   Loop, % xl.ActiveSheet.UsedRange.Rows.Count { ; Loop through used columns 
            if A_Index > 1 ; Skip header-row
                titles .= xl.Range("A" . A_Index).Value "|" ; Get column headers
        }
        StringTrimRight, titles, titles, 1 ; Delete final |-character
        splashList_AltSubmit("Choose Word comment", titles)
    }
	Return
}

