selectRows(xl){
    global
    Gui, +border -caption +AlwaysOnTop +OwnDialogs
    splashUI("p", "Select which rows to merge")
    Loop, % xl.ActiveSheet.UsedRange.Rows.Count ; Loop through used columns 
        {
            if A_Index > 1
            {   
                nCheckbox++
                rText := xl.Range("A" . A_Index).Value  
                Gui, Add, Checkbox, checked vselectRow%A_Index%, Row &%A_Index%: %rText% ; Note that the output variables will be numbered from 2, since the first row is reserved for the colum headers
            }
        }
    Gui, Font, s8 underline
    Gui, Add, Text, x10 gAll, &All rows 
    Gui, Add, Text, x+10 gLast, &Last row
    Gui, Font
    Gui, Add, Text, x40 gRowOK, OK 
    Gui, Add, Text, x+10 gRowCancel, Cancel 
    Gui, Show, w250
    WinWaitClose, ahk_class AutoHotkeyGUI 

    All:
        OnOff := !OnOff
        Loop, %nCheckbox%
            GuiControl,,Button%A_Index%,%OnOff%
        Return
    Last:
        Loop, % xl.ActiveSheet.UsedRange.Rows.Count - 1 ; Loop through used rows minus header
            GuiControl,,Button%A_Index%,0
        GuiControl,,Button%nCheckbox%,1
        Return
    RowCancel:
        Gui, Destroy
        ExitApp
        oWord.quit
        xl.quit
    RowOK:
        Gui, Submit
        Gui, Destroy
        Return
}