


;-------------------------------------------------------------------------------
ListBox(Title := "", Prompt := "", List := "", Select := 0) {
;-------------------------------------------------------------------------------
    ; show a custom input box with a ListBox control
    ; return the text of the selected item
    ;
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; List is a pipe delimited list of choices
    ; Select (if present) is the index of the preselected item
    ;---------------------------------------------------------------------------

    static Result ; used as a GUI control variable

    ; create GUI
    Gui, ListBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, ListBox, w190 r10 vResult Choose%Select%, %List%
    Gui, Add, Button, w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel

    ; main loop
    Gui, Show
    WinWaitClose
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    ListBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    Return

    ListBoxButtonCancel: ; "Cancel" button
    ListBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    ListBoxGuiEscape:    ; {Esc} pressed
        Result := "ListBoxCancel"
        Gui, Destroy
    Return
}
