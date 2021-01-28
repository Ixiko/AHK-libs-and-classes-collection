; #Include uuid.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Clipboard := uuid()
MsgBox %Clipboard%