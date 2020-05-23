guiOffScreenCheck(hwnd) {
	DetectHiddenWindows, On
	WinGetPos, winX, winY, winW, winH, % "ahk_id " hwnd

	If (winY < 0)
		Y := 0
		
	If (winY + winH > A_ScreenHeight)
		Y := A_ScreenHeight - winH
		
	If (winX + winW > A_ScreenWidth)
		X := A_ScreenWidth - winW
	
	If (winX < 0)
		X := 0
	
	If (winH <= 39)
		WinMove, % "ahk_id " hwnd, , , , 500, 750
	
	WinMove, % "ahk_id " hwnd, , % winX, % winY
}