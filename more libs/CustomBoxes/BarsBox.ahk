


;-------------------------------------------------------------------------------
BarsBox(ArrName, X := "", Y := "", Width := 400, Height := 200) {
;-------------------------------------------------------------------------------
    ; display a bar graph in a Gui
    ; no return value
    ;---------------------------------------------------------------------------
    ; ArrName is the name of the array to show
    ; ArrName is also the title for the GUI
    ; X       is the initial x coord of the GUI
    ; Y       is the initial y coord of the GUI
    ; Width   is the initial width of the GUI
    ; Height  is the initial height of the GUI

    global

    Coords := (X = "" ? "" : " x" X) (Y = "" ? "" : " y" Y)
    my := %ArrName%

    ; create GUI
    Gui BarsBox: New, +LastFound, % ArrName " - " my.SampleSize
    Gui Margin, 0, 0
    BarWidth := Width // my.Bars
    Range := "Range0-" 2 * my.SampleSize // my.Bars

    Loop % my.Bars
        Gui Add, Progress
                , x+0 w%BarWidth% h%Height% vBar%A_Index% %Range% Vertical
                , % Bar%A_Index% := 0

    for each, Value in my.DATA {
        if Value is Float
            Bucket := Floor(map(Value, my.min, my.max, 0, my.Bars)) + 1
        else
            Bucket := Round(map(Value, my.min, my.max, 1, my.Bars))
        GuiControl,, Bar%Bucket%, % Bar%Bucket% += 1
    }

    ; check sum
    Sum := 0
    Loop % my.Bars
        Sum += Bar%A_Index%

    ; main loop
    Gui Show, %Coords%
    CoordMode ToolTip, Client
    ToolTip % "Samples " Sum "`nColumns " my.Bars "`n" Range, 1, 1
    WinWaitClose
    ToolTip ; off
    return


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    BarsBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    BarsBoxGuiEscape: ; {Esc} pressed
        Gui Destroy
    return
}



;-------------------------------------------------------------------------------



Norm(Value, A, B) { ; get the percentage
    return, (Value - A) / Abs(B - A)
}

Lerp(Value, A, B) { ; use a percentage to get the corresponding value
    return, Abs(B - A) * Value + A
}

Map(Value, A1, B1, A2, B2) { ; map a value from range1 to range2
    return, Lerp(Norm(Value, A1, B1), A2, B2)
}
