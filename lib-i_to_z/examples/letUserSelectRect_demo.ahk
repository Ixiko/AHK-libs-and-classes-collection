; #Include LetUserSelectRect.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse ; Required: change coord mode to screen vs relative.
 
LetUserSelectRect(x1, y1, x2, y2)
MsgBox %x1%,%y1%  %x2%,%y2%

ExitApp