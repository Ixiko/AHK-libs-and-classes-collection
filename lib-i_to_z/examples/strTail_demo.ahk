; #Include strTail.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Text =
(
Text of Line 1
Text of Line 2
Text of Line 3
Text of Line 4
Text of Line 5
)

MsgBox % "'" . strTail(Text, 2) . "'"
MsgBox % "'" . strTail_last(Text) . "'" 
