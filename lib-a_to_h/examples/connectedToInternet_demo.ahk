; #Include ConnectedToInternet.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; True if internet connection is available.
MsgBox % "ConnectedToInternet: " . ConnectedToInternet() 
