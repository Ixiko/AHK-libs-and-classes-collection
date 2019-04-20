; #Include CMDret.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox % CMDret_RunReturn("cmd /c dir c:\")