; #Include baseConvert.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox % baseConvert("123456","dec","hex")
InputBox, x, baseConvert, Type a decimal to convert to base45,,,,,,,, 10
MsgBox % baseConvert(x,"decimal","base45") 
