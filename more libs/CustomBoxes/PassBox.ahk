


;-------------------------------------------------------------------------------
PassBox(Title := "", Prompt := "") {
;-------------------------------------------------------------------------------
    ; show a custom input box for a password
    ; return the entered password
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display

    static Result ; used as a GUI control variable

    ; create GUI
    Gui, PassBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w100 vResult Password
    Gui, Add, Button, w80 Default, &OK
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    WinWaitClose

return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    PassBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    return

    PassBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    PassBoxGuiEscape: ; {Esc} pressed
        Result := "PassBox_Cancel"
        Gui, Destroy
    return
}
