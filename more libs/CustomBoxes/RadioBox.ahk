


;-------------------------------------------------------------------------------
RadioBox(Title := "", Prompt := "", List := "", WantNumeric := False) {
;-------------------------------------------------------------------------------
    ; show a custom input box with Radio buttons
    ; return the text/index of the selected choice
    ;
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; List is a pipe delimited list of choices
    ; WantNumeric determines if the result is numeric or textual
    ;
    ; Note: If the user clicks on the OK button without having made a choice,
    ; the function returns an empty string or 0.
    ;---------------------------------------------------------------------------

    static Index ; used as a GUI control variable

    ; create GUI
    Gui, RadioBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Loop, Parse, List, |
        Gui, Add, Radio, % A_Index = 1 ? "vIndex" : "", %A_LoopField%
    Gui, Add, Button, w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel

    ; main loop
    Gui, Show
    WinWaitClose
    Return, WantNumeric ? Index : Text


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    RadioBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Index from GUI
        GuiControlGet, Text,, Button%Index%, Text
        Gui, Destroy
    Return

    RadioBoxButtonCancel: ; "Cancel" button
    RadioBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    RadioBoxGuiEscape:    ; {Esc} pressed
        Index := 0
        Gui, Destroy
    Return
}
