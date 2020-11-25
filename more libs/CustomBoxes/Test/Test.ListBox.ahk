#NoEnv
#SingleInstance, Force

    MsgBox, % ListBox("Test 1", "Choose a meal:", "Pizza|Spaghetti")
    MsgBox, % ListBox("Test 2", "Choose a vocal:", "A|E|I|O|U", 2)
    MsgBox, % ListBox("Test 3", "Choose a letter:", "a|b|c|d")
    MsgBox, % ListBox("Test 4", "Choose a letter:", "a|b|c|d", 3)

ExitApp

#Include, ..\ListBox.ahk
