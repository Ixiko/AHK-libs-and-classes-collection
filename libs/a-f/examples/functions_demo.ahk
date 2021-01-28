; #Include Functions.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Call this once, if the library is not explicitly included.
Functions() 

MsgBox % StringReplace(var := "helloworld", "!", "?", True)