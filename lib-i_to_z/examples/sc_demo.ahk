; #Include sc.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Capture current window with cursor to file screen.jpg with quality setting to 70%.
Pause::
sc_CaptureScreen(1, true, "screen.jpg", "70")
Return