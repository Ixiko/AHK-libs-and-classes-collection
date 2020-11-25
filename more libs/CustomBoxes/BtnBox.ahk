


;-------------------------------------------------------------------------------
BtnBox(Title := "", Prompt := "", List := "", Seconds := "") {
;-------------------------------------------------------------------------------
    ; show a custom MsgBox with arbitrarily named buttons
    ; return the text of the button pressed
    ;
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ; List is a pipe delimited list of captions for the buttons
    ; Seconds is the time in seconds to wait before timing out
    ;---------------------------------------------------------------------------

    ; create GUI
    Gui, BtnBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Loop, Parse, List, |
        Gui, Add, Button, % (A_Index = 1 ? "" : "x+10") " gBtn", %A_LoopField%

    ; main loop
    Gui, Show
    WinWaitClose,,, %Seconds%
    If (ErrorLevel = 1) {
        Result := "TimeOut"
        Gui, Destroy
    }
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    Btn: ; all the buttons come here
        Result := A_GuiControl
        Gui, Destroy
    Return

    BtnBoxGuiClose: ; {Alt+F4} pressed, [X] clicked
        Result := "WinClose"
        Gui, Destroy
    Return

    BtnBoxGuiEscape: ; {Esc} pressed
        Result := "EscapeKey"
        Gui, Destroy
    Return
}
