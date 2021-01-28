; #Include Hotstrings.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; hotstrings("(B|b)tw\s", "%$1%y the way") ; type 'btw' followed by space, tab or return
; hotstrings("i)omg", "oh my god{!}") ; type 'OMG' in any case, upper, lower or mixed
; hotstrings("\bcolou?r", "rgb(128, 255, 0);") ; '\b' prevents matching with anything before the word, e.g. 'multicololoured'

hotstrings("now#", "%A_Now%")
hotstrings("(B|b)tw", "%$1%y the way")
hotstrings("(\d+)\/(\d+)%", "percent") ; try 4/50%
Return

percent:
p := Round($1 / $2 * 100)
Send, %p%`%
Return