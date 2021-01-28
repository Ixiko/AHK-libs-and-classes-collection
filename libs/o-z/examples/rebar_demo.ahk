; #Include Rebar.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

    Gui, +LastFound +Resize
    hGui := WinExist()
    Gui, Show, w400 h140 hide           ;set window size, mandatory

  ;create edit
    Gui, Add, Edit, HWNDhEdit w100 h100

  ;create combo
    Gui, Add, ComboBox, HWNDhCombo w80, item 1 |item 2|item 3

  ;create rebar
    hRebar := Rebar_Add(hGui)
    ReBar_Insert(hRebar, hEdit, "mw 100", "L 400", "T Log ")    ;Insert edit band, set lenght of the band to 400
                                                                ; minimum width of edit to 100, set text to "Log "
    ReBar_Insert(hRebar, hCombo, "L 300", "P 1")                ;Insert combo band at the top, set length of the band to 300

    Gui, Show
Return

GuiClose:
ExitApp
