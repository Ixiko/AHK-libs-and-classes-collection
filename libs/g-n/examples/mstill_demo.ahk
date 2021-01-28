; #Include msTill.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

; Typical usage is something like msTill("1357"). The following is just
; for demonstration.

; Calculate a time when for when to call the subroutine.
; Use current time from now and add 5 seconds to it.
Seconds = 5
targetTime := A_Now
EnvAdd, targetTime, %Seconds%, Seconds

; Extract the needed hour, minutes and seconds. Drop the date part.
FormatTime, targetTime, %targetTime%, HHmmss

; Single run  with "-", because running at intervals of the time till 
; your destination is Silly
SetTimer Dest, % "-" msTill(targetTime) 

; Just show a countdown.
While (Seconds > 0)
{
    TrayTip, msTill, %Seconds% seconds till time
    Sleep, 1000
    Seconds--
}
Return

Dest:
TrayTip
MsgBox %A_Now%
ExitApp
Return