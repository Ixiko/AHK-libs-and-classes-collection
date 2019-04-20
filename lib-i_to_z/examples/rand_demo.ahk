; #Include Rand.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Random integer between 50 and 100 (typical use)
MsgBox % "Rand: " . Rand(50, 100) 