; #Include DateParse.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

time := "2:35 PM, 27 November, 2007"
MsgBox % """" . time . """`n`n    converted to`n`n""" . DateParse(time) . """"

; It will also work with any of the following formats:
; 4:55 am Feb 27, 2004
; 11:26 PM
; 1532
; 19/2/05
; 2007-06-26T14:09:12Z