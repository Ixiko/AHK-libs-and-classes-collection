#Persistent
splashProgress("Go off in my time..", -10000)

return
splashProgress(text, timeout=0){ ; Pass text to display splash popup window. Timeout defaults to off.
	global

	if (timeout <> 0) {
		startTime := A_TickCount
		stext := text
		stimeout := timeout
		SetTimer, progressTimeout	, % timeout
		SetTimer, progressUpdate	, 100
	}
	Progress, show CTDDDDDD CW202020 fm20 WS700 c00 xCenter yCenter w350 h105 zy60 zh0 B0, , %text%,, %header%
}
progressUpdate:
	progress,,, % stext " " Abs(stimeout) - (A_TickCount-startTime)
	return
progressTimeout:
	Progress, Off
	ExitApp
	Return
