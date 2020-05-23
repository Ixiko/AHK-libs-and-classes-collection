; #Include StdoutToVar.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox % StdoutToVar_CreateProcess("ipconfig.exe /all")
MsgBox % StdoutToVar_CreateProcess("ping.exe www.autohotkey.com", True)