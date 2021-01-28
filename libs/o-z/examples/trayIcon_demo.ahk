; #Include TrayIcon.ahk
#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On

; Get list of information about all icons in the system tray in following format:
; idx: 0 | idn: 10 | Pid: 4508 | uID: 1028 | MessageID: 1028 | hWnd: 4719526 | Class: AutoHotkey | Process: AutoHotkey.exe`n   | Tooltip: LibraryExplorer.ahk`n
MsgBox % TrayIcon()
Return

