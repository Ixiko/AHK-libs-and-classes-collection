; #Include grep.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

FileRead, haystack, %A_ScriptName%
regex := "%.*?%"
pos := grep(haystack, regex, outputVar, 1, 0, ", ")

MsgBox %pos%
MsgBox %outputVar%
