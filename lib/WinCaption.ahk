WinCaption(Hwnd) {
	WinGetPos( Hwnd, X0, Y0, W0, H0, 0)
	WinGetPos( Hwnd, X1, Y1, W1, H1, 1)
	
	wDiff := W0 - W1
	
	If (wDiff = 0)
		return 1 ; Has caption
	else
		return 0 ; No caption
}