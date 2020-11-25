


;-------------------------------------------------------------------------------
NumberBox(Title := "", Prompt := "") {
;-------------------------------------------------------------------------------
    ; show a custom input box for numbers incl. decimals and/or negative numbers
    ; return the entered number
    ;
    ; Title is the title for the GUI
    ; Prompt is the text to display
    ;---------------------------------------------------------------------------

    static Result ; used as a GUI control variables

    ; create GUI
    Gui, NumberBox: New, +LastFound, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w100 vResult gEditHandler
    Gui, Add, Button, w80 Default, &OK

    ; main loop
    Gui, Show
    WinWaitClose
    Return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    NumberBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    Return

    NumberBoxGuiClose: ; {Alt+F4} pressed, [X] clicked
        Result := "WinClose"
        Gui, Destroy
    Return

    NumberBoxGuiEscape: ; {Esc} pressed
        Result := "EscapeKey"
        Gui, Destroy
    Return
}



;-------------------------------------------------------------------------------
EditHandler(hEdit) { ; check for number incl. decimal point
;-------------------------------------------------------------------------------
    static PrevNumber := [], Warning := "You can only enter a number!"
        ,  BadNeedle  := "[^\d\.-]|^.+-" ; allow negative numbers

    ControlGet, Pos, CurrentCol,,, ahk_id %hEdit%
    GuiControlGet, NewNumber,, %hEdit%
    StrReplace(NewNumber, ".",, DotCount)

    If NewNumber ~= BadNeedle Or DotCount > 1 { ; BAD
        ControlGetPos, x, y,,,, ahk_id %hEdit%
        ToolTip, %Warning%, x, y-20
        SetTimer, ToolTipOff, -2000
        GuiControl,, %hEdit%, % PrevNumber[hEdit]
        SendMessage, 0xB1, % Pos-2, % Pos-2,, ahk_id %hEdit%
    }

    Else ; GOOD
        PrevNumber[hEdit] := NewNumber

    Return

    ToolTipOff:
        ToolTip ; off
    Return
}
