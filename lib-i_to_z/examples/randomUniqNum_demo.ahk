; #Include RandomUniqNum.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Generate a comma separated list of 5 integers between 1 and 100.
MsgBox % RandomUniqNum(1, 100, 5)
Return