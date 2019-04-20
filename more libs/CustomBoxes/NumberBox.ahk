


;-------------------------------------------------------------------------------
NumberBox(Title := "", Prompt := "") {
;-------------------------------------------------------------------------------
    ; show a custom input box for numbers incl. negative decimal numbers
    ; return the entered number
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Prompt is the text to display

    static Result ; used as a GUI control variable

    ; create GUI
    Gui, NumberBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Text,, %Prompt%
    Gui, Add, Edit, w190 vResult gForceNumber
    Gui, Add, Button, w80 Default, &OK
    Gui, Add, Button, x+m wp, &Cancel
    Gui, Show

    ; main wait loop
    Gui, +LastFound
    WinWaitClose

return, Result


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    NumberBoxButtonOK: ; "OK" button, {Enter} pressed
        Gui, Submit ; get Result from GUI
        Gui, Destroy
    return

    NumberBoxButtonCancel: ; "Cancel" button
    NumberBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    NumberBoxGuiEscape:    ; {Esc} pressed
        Result := "NumberBoxCancel"
        Gui, Destroy
    return
}



;-------------------------------------------------------------------------------
ForceNumber(hEdit) { ; check for number incl. decimal point
;-------------------------------------------------------------------------------
    static PrevNumber := [], Warning := "You can only enter a number!"
        , BadNeedle := "[^\d\.-]|^.+-" ; allow negative numbers

    ControlGet, Pos, CurrentCol,,, ahk_id %hEdit%
    GuiControlGet, NewNumber,, %hEdit%
    StrReplace(NewNumber, ".",, DotCount)

    if NewNumber ~= BadNeedle Or DotCount > 1 { ; BAD
        ControlGetPos, x, y,,,, ahk_id %hEdit%
        ToolTip, %Warning%, x, y-20
        SetTimer, ForceNumber_ToolTipOff, -2000
        GuiControl,, %hEdit%, % PrevNumber[hEdit]
        SendMessage, 0xB1, % Pos-2, % Pos-2,, ahk_id %hEdit%
    }

    else ; GOOD
        PrevNumber[hEdit] := NewNumber

    return

    ForceNumber_ToolTipOff:
        ToolTip ; off
    return
}
