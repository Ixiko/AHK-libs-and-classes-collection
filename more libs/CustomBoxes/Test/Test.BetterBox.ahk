#NoEnv
#SingleInstance, Force

    MsgBox, % BetterBox("Test 1", "Position is", "0 = start", 0)
    MsgBox, % BetterBox("Test 2", "Position is", "-1 = end", -1)
    MsgBox, % BetterBox("Test 3", "Position is", "1 = after first char", 1)

ExitApp

#Include, ..\BetterBox.ahk
