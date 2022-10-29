#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

MsgBox % TimeUntilTime(EndTime := "16:21:00")
Exit


TimeUntilTime(b) {
FormatTime, a, T12, Time
_a := StrSplit(a, ":"), _b := StrSplit(b, ":")
If (_a[2] > _b[2])
	_b[1] := _b[1]-1, _b[2] := _b[2]+60,_b[2] := _b[2] - _a[2], _b[1] := _b[1] - _a[1]
Return _b[1] " hours and " _b[2] " minutes"
}