; #Include ProcessInfo.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Process, Exist
MsgBox % ProcessInfo_GetModuleFileNameEx(ErrorLevel)