; #Include Edit.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Start Notepad and get handle of the editor.
Run, notepad.exe,, , pid
WinWait ahk_pid %pid%
ControlGet, hEdit, Hwnd,, Edit1, ahk_pid %pid%

; Set default text to opened editor.
GoSub, F1

; Exit script after attached Notepad is closed.
WinWaitClose, ahk_pid %pid%
ExitApp

; Hotkeys for testing on that editor.
F1::Edit_SetText( hEdit, "Hotkeys `r`n  F1 - Set editor to default text`r`n  F2 - Show length of text`r`n  F3 - search text ""Show"", ahk_pid %pid%" )
F2::MsgBox % "Text length: " . Edit_GetTextLength( hEdit )
F3::MsgBox % "Position of ""Show"": " . Edit_FindText( hEdit,  "Show")
