/*
Func: WinMovePos
    Moves window to area on the screen

Parameters:
    winHwnd	-	Hwnd of target window
    pos		-	Desired window position

Returns:
    Moves winHwnd to specified pos

Examples:
	WinMovePos(myWindowHwnd, "TopRight")
	=	Window myWindowHwnd will be in the topright corner the screen

Required libs:
    WinGetPos.ahk
*/
WinMovePos(winHwnd, pos) {
	WinGetPos( winHwnd, X0, Y0, W0, H0, 0)
	
	If (pos = "Center")	{
		X := (A_ScreenWidth / 2) - (W0 / 2)
		Y := (A_ScreenHeight / 2) - (H0 / 2)
	}
	
	If (pos = "Top") {
		X := X0
		Y := 0
	}
	
	If (pos = "Bottom")	{
		X := X0
		Y := (A_ScreenHeight) - H0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd)
			Y += 7
	}
	
	If (pos = "Left") {
		X := 0
		Y := Y0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd)
			X -= 7
	}
	
	If (pos = "TopLeft") {
		X := 0
		Y := 0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd)
			X -= 7
	}
	
	If (pos = "BottomLeft") {
		X := 0
		Y := (A_ScreenHeight) - H0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd) {
			Y += 7
			X -= 7
		}
	}
	
	If (pos = "Right") {
		X := (A_ScreenWidth - W0)
		Y := Y0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd)
			X += 7
	}
	
	If (pos = "TopRight") {
		X := (A_ScreenWidth) - W0
		Y := 0
		
		If InStr(A_OSVersion, "10.") and !WinBorderless(winHwnd)
			X += 7
	}
	
	If (pos = "BottomRight") {
		X := (A_ScreenWidth) - W0
		Y := (A_ScreenHeight) - H0
		
		If InStr(A_OSVersion, "10.")  and !WinBorderless(winHwnd) {
			Y += 7
			X += 7
		}
	}
	
	WinMove, % "ahk_id" winHwnd,, % X, % Y
}