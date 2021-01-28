; #Include EmptyMem.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;This example will reduce mem usage from around 5,000k to 500k
Run, taskmgr.exe
MsgBox, Remember current memory usage then compare.
EmptyMem()
Sleep, 5000
Exitapp
