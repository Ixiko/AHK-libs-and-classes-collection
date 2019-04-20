; #Include TaskButton.ahk
#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On

; Get list of information about all buttons in the system taskbar in following format:
; idx: 1 | idn: 3 | pid: 5912 | hWnd: 328792 | Class: CabinetWClass | Process: explorer.exe`n   | Tooltip: samp`n
MsgBox % TaskButton()
Return

