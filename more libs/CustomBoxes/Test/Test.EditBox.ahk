#NoEnv
#SingleInstance, Force

    FileRead, Test, %A_ScriptFullPath%
    EditBox("Test", 50, 50, 640, 400)
    EditBox("Test")

ExitApp

#Include, ..\EditBox.ahk
