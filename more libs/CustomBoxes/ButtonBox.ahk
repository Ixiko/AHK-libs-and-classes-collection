


;-------------------------------------------------------------------------------
ButtonBox(Title := "", Prompt := "", List := "", Seconds := "") {
;-------------------------------------------------------------------------------
    ; show a custom MsgBox with arbitrarily named buttons
    ; return the text of the button pressed
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; List is a pipe delimited list of captions for the buttons
    ; Seconds is the time in seconds to wait before timing out

    ; create GUI
    Gui, ButtonBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Loop, Parse, List, |
        Gui, Add, Button, % (A_Index = 1 ? "" : "x+10") " gBtn", %A_LoopField%
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    WinWaitClose,,, %Seconds%

    if (ErrorLevel = 1) {
        Result := "TimeOut"
        Gui, Destroy
    }

return Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    Btn: ; all the buttons come here
        Result := A_GuiControl
        Gui, Destroy
    return

    ButtonBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    ButtonBoxGuiEscape: ; {Esc} pressed
        Result := "ButtonBox_Cancel"
        Gui, Destroy
    return
}
