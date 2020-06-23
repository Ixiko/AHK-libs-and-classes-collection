; #Include ConsoleApp.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox, % ConsoleApp_RunWait("cmd.exe /c dir c:\windows")
