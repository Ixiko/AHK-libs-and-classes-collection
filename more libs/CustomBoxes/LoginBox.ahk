


;-------------------------------------------------------------------------------
LoginBox(Title := "") {
;-------------------------------------------------------------------------------
    ; show a custom input box for credentials
    ; return an object with Username and Password
    ;
    ; Title is the title for the GUI
    ;---------------------------------------------------------------------------

    static Name, Pass ; used as a GUI control variables

    ; create GUI
    Gui, LoginBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text, ym+4 w55, Username:
    Gui, Add, Edit, x+10 yp-4 w100 vName
    Gui, Add, Text, xm y+10 w55, Password:
    Gui, Add, Edit, x+10 yp-4 w100 vPass Password
    Gui, Add, Button, w80 Default, &OK

    ; main loop
    Gui, Show
    WinWaitClose
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    LoginBoxButtonOK:  ; "OK" button, {Enter} pressed
        Gui, Submit
        Result := {Username: Name, Password: Pass}
        Gui, Destroy
    Return

    LoginBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
        Result := "WinClose"
        Gui, Destroy
    Return

    LoginBoxGuiEscape: ; {Esc} pressed
        Result := "EscapeKey"
        Gui, Destroy
    Return
}
