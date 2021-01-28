; #Include Exec.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

test=var
double=triple
one=double
var=one
Script := "MsgBox 4,Title,%test% is %var%``, %%var%%``, %%%var%%%,5`nIfMsgBox Yes,MsgBox,You pressed yes`nIfMsgBox No,MsgBox,You pressed no"
Exec(Script)
ExitApp 
