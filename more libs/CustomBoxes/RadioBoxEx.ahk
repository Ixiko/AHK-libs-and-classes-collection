


;-------------------------------------------------------------------------------
RadioBoxEx(Title := "", Prompt := "", List := "", MaxRows := 10) {
;-------------------------------------------------------------------------------
    ; show a custom input box with Radio buttons
    ; return the text/index of the selected choice
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; List is a pipe delimited list of choices
    ;
    ; Note: If the user clicks on the OK button without having made a choice,
    ; the function returns an empty string or 0.

    static Index ; used as a GUI control variable

    ; create GUI
    Gui, RadioBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Loop, Parse, List, |
    {
        options := A_Index = 1 ? "vIndex Section" : ""
        if (A_Index != 1) and Mod(A_Index, MaxRows) = 1
            options .= " ys"
        Gui, Add, Radio, %options%, %A_LoopField%
    }
    Gui, Add, Button, xm w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    WinWaitClose

return Index ; end of function


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    RadioBoxButtonOK:   ; "OK" button, {Enter} pressed
        Gui, Submit ; gets Index
        Gui, Destroy
    return

    RadioBoxButtonCancel: ; "Cancel" button
    RadioBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    RadioBoxGuiEscape:    ; {Esc} pressed
        Index := 0
        Gui, Destroy
    return
}
