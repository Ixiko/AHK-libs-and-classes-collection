IsMouseOverStartButton() {
	CoordMode, Mouse, Screen
	MouseGetPos, , , win
	WinGetClass, class, ahk_id %win%
	return class = "button"
}

GetTaskbarDirection() {
	WinGetPos X, Y, Width, Height, ahk_class Shell_TrayWnd
	x := (x + x + width) / 2
	y := (y + y + height) / 2
	if(x < 0.1 * A_ScreenWidth)
		return 1
	if(x > 0.9 * A_ScreenWidth)
		return 2
	if(y < 0.1 * A_ScreenHeight)
		return 3
	if(y > 0.9 * A_ScreenHeight)
		return 4
	if(IsFullscreen("A", false, false))
		return -1
	return 0
}

IsMouseOverTaskList() {
	CoordMode, Mouse, Screen
	WinGetPos , X, Y, , , ahk_class Shell_TrayWnd
	if(WinVer >= WIN_7)
		ControlGetPos , TaskListX, TaskListY, TaskListWidth, TaskListHeight, MSTaskListWClass1, ahk_class Shell_TrayWnd
	else
		ControlGetPos , TaskListX, TaskListY, TaskListWidth, TaskListHeight, MSTaskSwWClass1, ahk_class Shell_TrayWnd
	;Transform to screen coordinates
	TaskListX += X
	TaskListY += Y
	MouseGetPos, x, y
	z := GetTaskBarDirection()
	if(z >= 1 && z <= 4)
		return IsMouseOverTaskbar() && IsInArea(x, y, TaskListX, TaskListY, TaskListWidth, TaskListHeight)
	return false
}

IsMouseOverTray() {
	CoordMode, Mouse, Screen
	MouseGetPos, x, y
	ControlGetPos , TrayX, TrayX, TrayWidth, TrayHeight, ToolbarWindow321, ahk_class Shell_TrayWnd
	z := GetTaskBarDirection()
	if(z >= 1 && z <= 4)
		return IsMouseOverTaskbar() && IsInArea(x, y, TrayX, TrayY, TrayWidth, TrayHeight)
	return false
}

IsMouseOverClock() {
	CoordMode, Mouse, Screen
	MouseGetPos, , , , ControlUnderMouse
	result := false
	if(ControlUnderMouse = "TrayClockWClass1")
		result := true
	outputdebug IsMouseOverClock()? %result%
	return result
}

IsMouseOverShowDesktop() {
	CoordMode, Mouse, Screen
	MouseGetPos, x, y
	ControlGetPos , ShowDesktopX, ShowDesktopY, ShowDesktopWidth, ShowDesktopHeight, TrayShowDesktopButtonWClass1, ahk_class Shell_TrayWnd
	z := GetTaskBarDirection()
	if(z >= 1 && z <= 4)
		return IsMouseOverTaskbar() && IsInArea(x,y,ShowDesktopX,ShowDesktopY,ShowDesktopWidth,ShowDesktopHeight)
	return false
}

IsMouseOverTaskbar() {
	CoordMode, Mouse, Screen
	MouseGetPos, , , WindowUnderMouseID 
	WinGetClass, winclass, ahk_id %WindowUnderMouseID%
	result := false
	if(winclass = "Shell_TrayWnd")
		result := true
	return result
}

IsMouseOverFreeTaskListSpace() {
	static result, IsRunning
	CoordMode, Mouse, Screen
	SetWinDelay 0
	SetKeyDelay 0
	SetMouseDelay 0
	if(!IsMouseOverTaskList())
	{
		IsRunning := false
		return false
	}
	if(WinVer < WIN_7)
	{
		x := HitTest()
		return x < 0
	}
	IsRunning := true
	Click Right
	result := 0
	x := 0
	while(x < 50)
	{
		if(WinExist("ahk_class #32768"))
		{
			result := true
			break
		}
		else if(WinActive("ahk_id DV2ControlHost"))
		{
			result := false
			break
		}
		x += 10
		sleep 10
	}
	while(WinExist("ahk_class #32768") || WinActive("ahk_class DV2ControlHost"))
		Send {Esc}
	IsRunning := false
	return result
}

;Middle click on taskbutton -> close task
TaskButtonClose() {
	if(IsMouseOverTaskList())
	{
		click right
		while(!IsContextMenuActive() && WinVer < WIN_7)
			sleep 10
		if(WinVer >= WIN_7) ;wait until the menu has slided out
		{
			prevx := 0
			prevy := 0
			x := 1
			y := 1
			while(true)
			{
				if(IsContextMenuActive())
				{
					Send {Esc}
					return true
				}
				if(WinActive("ahk_class DV2ControlHost"))
					break
				Sleep 10
			}
			while(prevx != x || prevy != y)
			{
				prevx := x
				prevy := y
				WinGetPos x, y, , , ahk_class DV2ControlHost
				Sleep 10
			}
		}
		Send {up}{enter}
		return false
	}
	return true
}