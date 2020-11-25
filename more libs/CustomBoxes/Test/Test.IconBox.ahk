#NoEnv
#SingleInstance, Force

    Gosub, Test1
    Gosub, Test2
    Gosub, Test3
    Gosub, Test4

ExitApp

#Include, ../IconBox.ahk



;-------------------------------------------------------------------------------
Test1: ; simple example (naked)
;-------------------------------------------------------------------------------
    Answer := IconBox()
    Msgbox,,, %Answer%, 2

Return



;-------------------------------------------------------------------------------
Test2: ; simple example
;-------------------------------------------------------------------------------
    Answer := IconBox("Hello world"
        , "Are you sure you want to say ""Hello"" to the world?`n"
        . "`nWarning! This operation is irreversible."
        , "&Yes|*Not &sure|&Not at all|&HELP!"
        , "E")

    Msgbox,,, %Answer%, 2

Return



;-------------------------------------------------------------------------------
Test3: ; custom icon from Shell32.dll
;-------------------------------------------------------------------------------
    Answer := IconBox("Where is it?"
        , "Do you want to find The Holy Grail?`n`ncustom icon from Shell32.dll"
        , "*&Yes, please|&Not today|Not &ever"
        , 23)

    Msgbox,,, %Answer%, 2

Return



;-------------------------------------------------------------------------------
Test4: ; example for a IconBox that is owned by our own GUI
;-------------------------------------------------------------------------------
    Gui, Add, Text,, This is my GUI and I'll cry if I want to.
    Gui, Add, Button, wp, Cry
    Gui, Show, x200 y200

    Answer := IconBox("Owned"
        , "I am owned by GUI 1"
        , "&OK|*&Whatever"
        , "", 1)

    Msgbox,,, %Answer%, 2

Return
