; #Include IsFullScreen.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox Click Win+LeftMouseButton to see if application is in fullscreen mode.
Return

#LButton::
MsgBox % IsFullscreen()
Return