; Pass text to display splash notification. 
; Position defaults to top. Timeout to 2000 ms. Font size to 12.Transparency to 200 (255 = none).

splashNotify(text, position="top", timeout=2000, fontSize= 12, transparency=200){ 
	global
	IniRead()
	if timeout <> 0
		SetTimer, notifyTimeout, %timeout%
	if position = top
		y := 0
	if position = middle
		y := A_ScreenHeight / 2 - 70
	if position = bottom 
		y := A_ScreenHeight - 70
	if position = typing
		y := A_ScreenHeight / 2.5
	if position <> typing
		Progress, B0 X0 Y%y% ZH0 fs%fontSize% CTFF9900 CW221A0F, %text%, , splashNotify.ahk, 
	Else
		Progress, B0 Y%y% ZH0 fs%fontSize% CTFF9900 CW221A0F, %text%, , splashNotify.ahk, 
	WinSet, Transparent, %transparency%, splashNotify.ahk
}

notifyTimeout:
	Progress, Off
	Return 
