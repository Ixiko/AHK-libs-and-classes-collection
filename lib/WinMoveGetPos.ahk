/*
Func: WinMoveGetPos
    Returns x and y coordinates to move window to area on the screen

Parameters:
    winHwnd	-	Hwnd of target window
    pos		-	Desired window position
    outputX	-	Output for X
    outputY	-	Output for Y

Returns:
	X&Y coordinates to move winHwnd to selected pos

Examples:
	+ Add example

Required libs:
    WinGetPos.ahk
*/
WinMoveGetPos(winHwnd, pos, ByRef outputX:="", ByRef outputY:="") {
	DetectHiddenWindows, On
	WinGetPos( winHwnd, X0, Y0, W0, H0, 0)

	If (pos = "Center")
	{
		nX := (A_ScreenWidth / 2) - (W0 / 2)
		nY := (A_ScreenHeight / 2) - (H0 / 2)
	}
	
	If (pos = "Top")
	{
		nX := (A_ScreenWidth / 2) - (W0 / 2)
		nY := 0
	}
	
	If (pos = "Bottom")
	{
		nX := (A_ScreenWidth / 2) - (W0 / 2)
		nY := (A_ScreenHeight) - H0
	}
	
	If (pos = "Left")
	{
		nX := 0
		nY := (A_ScreenHeight / 2) - (H0 / 2)
	}
	
	If (pos = "TopLeft") or (pos = "Top-Left")
	{
		nX := 0
		nY := 0
	}
	
	If (pos = "BottomLeft") or (pos = "Bottom-Left")
	{
		nX := 0
		nY := (A_ScreenHeight) - H0
	}
	
	If (pos = "Right")
	{
		nX := (A_ScreenWidth - W0)
		nY := (A_ScreenHeight / 2) - (H0 / 2)
	}
	
	If (pos = "TopRight") or (pos = "Top-Right")
	{
		nX := (A_ScreenWidth) - W0
		nY := 0
	}
	
	If (pos = "BottomRight") or (pos = "Bottom-Right")
	{
		nX := (A_ScreenWidth) - W0
		nY := (A_ScreenHeight) - H0
	}
	
	outputX := nX
	outputY := nY
}