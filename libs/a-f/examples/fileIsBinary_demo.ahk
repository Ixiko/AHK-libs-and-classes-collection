; #Include fileIsBinary.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox % "A_ScriptFullPath: " . fileIsBinary(A_ScriptFullPath) . "`nA_AhkPath: " . fileIsBinary(A_AhkPath)