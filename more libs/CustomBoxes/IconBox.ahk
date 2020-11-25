


;-------------------------------------------------------------------------------
IconBox(Title := "", Prompt := "", List := "", Icon := "", Owner := 0) {
;-------------------------------------------------------------------------------
    ; show a custom MsgBox with arbitrarily named buttons and an icon
    ; return the text of the button pressed
    ;
    ; Title  is the title for the GUI
    ; Prompt is the text to display
    ; List   is a pipe delimited list of buttons
    ;        (a button starting with * is the default button)
    ; Icon   I = info, Q = question, E = error, or a number from Shell32.dll
    ; Owner  the GUI number or the GUI handle of the owner
    ;---------------------------------------------------------------------------

    _DefaultGui := A_DefaultGui ; remember
    Icon := Icon = "I" ? 222 : Icon = "Q" ? 24 : Icon = "E" ? 110 : Icon

    ; create GUI
    Gui, IconBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    If Icon
        Gui, Add, Picture, Icon%Icon%, Shell32.dll
    Gui, Add, Text, % Icon ? "x+10" : "", %Prompt%
    Loop, Parse, List, |
        Gui, Add, Button
            , % (A_Index = 1 ? "x+10" : "y+6") " w100 gBtn"
            . (SubStr(A_LoopField, 1, 1) = "*" ? " Default" : "")
            , % LTrim(A_LoopField, "*")
    If Owner {
        Gui, %Owner%: +Disabled
        Gui, +Owner%Owner%
    }

    ; main loop
    Gui, Show
    WinWaitClose
    If Owner
        Gui, %Owner%: -Disabled
    Gui, %_DefaultGui%: Default ; restore
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    Btn: ; all the buttons come here
        Result := A_GuiControl
        Gui, Destroy
    Return

    IconBoxGuiClose: ; {Alt+F4} pressed, [X] clicked
        Result := "WinClose"
        Gui, Destroy
    Return

    IconBoxGuiEscape: ; {Esc} pressed
        Result := "EscapeKey"
        Gui, Destroy
    Return
}
