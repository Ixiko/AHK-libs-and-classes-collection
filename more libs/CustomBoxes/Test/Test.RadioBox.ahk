#NoEnv
#SingleInstance, Force

    MsgBox, % RadioBox("Test 1", "Choose a meal:", "Pizza|Spaghetti")
    MsgBox, % RadioBox("Test 2", "Choose a vocal:", "A|E|I|O|U", True)
    MsgBox, % RadioBox(,, "A|E|I|O|U", True)

ExitApp

#Include, ..\RadioBox.ahk
