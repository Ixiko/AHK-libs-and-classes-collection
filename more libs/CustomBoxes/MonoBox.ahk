


;-------------------------------------------------------------------------------
MonoBox(Title := "", Prompt := "", Font := "Consolas", Size := 11) {
;-------------------------------------------------------------------------------
    ; show a custom message box with monospaced font
    ; no return value
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; Font is the name of the font to use
    ; Size is the font size to use
    ;
    ; Note: The user may choose a non-monospaced font for displaying the text,
    ; but the function was written with monospaced fonts in mind.

    ; create GUI
    Saved := A_DefaultGui
    Gui, MonoBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Font, s%Size%, %Font%
    Gui, Add, Text,, %Prompt%
    Gui, Font ; default
    Gui, Add, Button, w80 Default, &OK
    Gui, Show
    Gui, %Saved%: Default

    ; main wait loop
    Gui, +LastFound
    WinWaitClose

return ; end of function


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    MonoBoxButtonOK:  ; "OK" button, {Enter} pressed
    MonoBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    MonoBoxGuiEscape: ; {Esc} pressed
        Gui, Destroy
    Return
}
