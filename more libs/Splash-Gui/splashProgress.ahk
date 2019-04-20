splashProgress(text, timeout=0){ ; Pass text to display splash popup window. Timeout defaults to off.
	global
	IniRead()
	if timeout <> 0
		SetTimer, progressTimeout, %timeout%
	Progress, show CT%header_color% CW%background% fm20 WS700 c00 x0 w300 h125 zy60 zh0 B0, , %text%,, %header% 
}
progressTimeout:
	Progress, Off
	Return 
