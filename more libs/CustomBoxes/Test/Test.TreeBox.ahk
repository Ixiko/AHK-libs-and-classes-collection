#NoEnv
#SingleInstance, Force

    TestObject := {abc: 123, def: 456, ghi: {alpha: 345, beta: 789}}
    TreeBox("TestObject")

ExitApp

#Include, ..\TreeBox.ahk
