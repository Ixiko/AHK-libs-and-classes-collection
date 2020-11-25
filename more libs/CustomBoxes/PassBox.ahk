


;-------------------------------------------------------------------------------
PassBox(Title := "", Prompt := "") {
;-------------------------------------------------------------------------------
    ; show a custom input box for a password
    ; return the entered password
    ;
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ;---------------------------------------------------------------------------

    static Result ; used as a GUI control variables

    ; create GUI
    Gui, PassBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w100 vResult Password
    Gui, Add, Button, w80 Default, &OK

    ; main loop
    Gui, Show
    WinWaitClose
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    PassBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    Return

    PassBoxGuiClose: ; {Alt+F4} pressed, [X] clicked
        Result := "WinClose"
        Gui, Destroy
    Return

    PassBoxGuiEscape: ; {Esc} pressed
        Result := "EscapeKey"
        Gui, Destroy
    Return
}
