#NoEnv
#SingleInstance Force
#WinActivateForce
SetTitleMatchMode, 3
CoordMode, Mouse, Screen
DetectHiddenWindows, Off



class Monitor{
	__New(leftBound, topBound, rightBound, bottomBound, taskbarLeft, taskbarRight, taskbarTop, taskbarBottom, BorHor, BorVert, PadHor, PadVert, PortWin){
		
		this.workspace := 1
		this.Mode := 1
		
		this.LeftX := leftBound
		this.TopY := topBound
		this.RightX := rightBound
		this.BottomY := bottomBound
		
		this.Width := this.RightX - this.LeftX
		this.Height := this.BottomY - this.TopY
		
		this.Windows := Object()
		this.NumberWindows := 0
		
		this.WindowPaddingHorizontal := PadHor
		this.WindowPaddingVertical := PadVert
		
		this.BorderHorizontal := BorHor
		this.BorderVertical := BorVert
		
		this.WindowsInPort := PortWin
		
		this.usableSpace(taskbarLeft, taskbarRight, taskbarTop, taskbarBottom, BorHor, BorVert)
	}
		
	usableSpace(taskbarLeftSize, taskbarRightSize, taskbarTopSize, taskbarBottomSize, padHor, padVert){
		this.UsableWidth := this.Width - taskbarRightSize - taskbarLeftSize - (padHor * 2)
		this.UsableHeight := this.Height - taskbarTopSize - taskbarBottomSize - (padVert * 2)
	}
	
	details(){
		MsgBox, % "Monitor Details - Height: " this.Height " - Width: " this.Width " - LeftBound, RightBound, TopBound, BottomBound, in order: " this.LeftX "," this.RightX "," this.TopY "," this.BottomY
		temp := this.NumberWindows
		Loop, %temp%
		{
			String := String ", " this.Windows[A_Index]
		}
		MsgBox, % String
	}
	
	Swap(IDToMove, positionToMoveTo){
		temp := this.Windows[positionToMoveTo]
		temp2 := this.NumberWindows
		if(positionToMoveTo > temp2)
		{
			return 0
		}
		Loop, %temp2%
		{
			temp3 := this.Windows[A_Index]
			if(temp3 = IDToMove)
			{
				this.Windows[positionToMoveTo] := temp3
				this.Windows[A_Index] := temp
				return 1
			}
		}
	}
	
	SendWindowToMonitor(tempID, monitor)
	{
		temp := this.NumberWindows
		Loop, %temp%
		{
			temp2 := this.Windows[A_Index]
			if(tempID = temp2)
			{
					temp3 := monitor.NumberWindows
					monitor.Windows[temp3+1] := tempID
					monitor.NumberWindows += 1
					temp4 := this.NumberWindows - A_Index
					temp5 := A_Index
					Loop, %temp4%
					{
						this.Windows[temp5+(A_Index-1)] := this.Windows[temp5+(A_Index)]
					}
					this.NumberWindows -= 1
					this.Ship()
					monitor.Ship()
					return 1
			}
		}
	}
	
	Ship()
	{
		global
		local result, tempWin, tempNum, tempHorPad, tempVertPad, tempPW, tempN, PortWindowSizeVertical, PortWindowSizeHorizontal, PortWindowVerticalMovement, DeckWindowSizeVertical, DeckWindowSizeHorizontal, DeckWindowVerticalMovement
	
		tempNum := this.NumberWindows
		tempHorBor := this.BorderHorizontal
		tempVertBor := this.BorderVertical
		tempHorPad := this.WindowPaddingHorizontal
		tempVertPad := this.WindowPaddingVertical
		tempPW := this.WindowsInPort
		tempN := this.NumberWindows - tempPW
	
		PortWindowSizeVertical := (this.UsableHeight - (tempPW - 1)*tempVertPad)/tempPW
		PortWindowSizeHorizontal := 2*(this.UsableWidth - (tempHorPad))/3
		PortWindowVerticalMovement := PortWindowSizeVertical+tempVertPad
		DeckWindowSizeVertical := (this.UsableHeight - (tempN - 1)*tempVertPad)/tempN
		DeckWindowSizeHorizontal := (this.UsableWidth - (tempHorPad))/3
		DeckWindowVerticalMovement := DeckWindowSizeVertical+tempVertPad
		DeckWindowHorizontalMovement := PortWindowSizeHorizontal + tempHorPad
	
		Loop, %tempNum%
		{	
			tempWin := this.Windows[A_index]
			; Move Windows in the Ports
			if(A_Index<=tempPW)
			{
				WinMove, ahk_id %tempWin%,, this.LeftX + tempHorBor, this.TopY + ToolbarPaddingTop + tempVertBor + PortWindowVerticalMovement*(A_Index - 1), PortWindowSizeHorizontal, PortWindowSizeVertical
			} else {
				WinMove, ahk_id %tempWin%,, this.LeftX + tempHorBor + DeckWindowHorizontalMovement, this.TopY + tempVertBor + ToolbarPaddingTop + DeckWindowVerticalMovement*(A_Index-tempPW-1), DeckWindowSizeHorizontal, DeckWindowSizeVertical
			}
		}
	}
	
	AddFakeWindow()
	{
		this.NumberWindows += 1
	}
	
	RemoveFakeWindows()
	{
		tempNum := this.NumberWindows
		Loop, %tempNum%
		{
			tempID := this.Windows[A_Index]
			If %tempID%
			{
				; Do Nothing
			} else {
				this.Windows[A_Index] := this.Windows[A_Index+1]
				this.NumberWindows -= 1
			}
		}
	}
}

class Window{
	__New(aHwnd, aTitle){
		this.Hwnd := aHwnd
		WinGetClass, class, ahk_id %aHwnd%
		
		this.Title := 1
		this.OnTop := 0
		this.Initialized := 1
		
		this.titleAway(WindowTitlesOn)
	}
	
	titleAway(Bool){
		temp := this.Hwnd
		if(Bool = 0 && Title = 1)
		{
			WinSet, Style, -0xC00000, ahk_id %temp%
			WinSet, Style, -0x800000, ahk_id %temp%
			Title := 0
		} Else {
			WinSet, Style, +0xC00000, ahk_id %temp%
			WinSet, Style, +0x800000, ahk_id %temp%
			Title := 1
		}
		WinSet, Redraw,, ahk_id %temp%
	}
}

Configure(){
	global

	titlesOn := 1
	ignoreList := "Shell_SecondaryTrayWnd, Shell_TrayWnd, EdgeUiInputTopWndClass, WorkerW, Progman, Launchy, Valve001"
	
	ReadOptionsFromIni()
	
	SysGet, numMonitors, MonitorCount
	Loop, %numMonitors%
	{
		topTaskbar := ToolbarPaddingTop
		bottomTaskbar := ToolbarPaddingBot
		rightTaskbar := ToolbarPaddingRight
		leftTaskbar := ToolbarPaddingLeft
		
		SysGet, mon, Monitor, %A_Index%
		mon%A_Index% := new Monitor(monLeft, monTop, monRight, monBottom, leftTaskbar, rightTaskbar, topTaskbar, bottomTaskbar, BorderHor, BorderVert, PaddingHor, PaddingVert, InitialPortWindows)
		
	}
	return
}

ReadOptionsFromIni()
{
	Global
	IfNotExist, Config.ini
	{
		IniWrite, 10, Config.ini, Windows, BorderHor
		IniWrite, 10, Config.ini, Windows, BorderVert
		IniWrite, 10, Config.ini, Windows, PaddingHor
		IniWrite, 10, Config.ini, Windows, PaddingVert
	
		IniWrite, 1, Config.ini, Settings, InitialPortWindows
		IniWrite, 1, Config.ini, Settings, WindowTitlesOn
		
		IniWrite, 0, Config.ini, Settings, ToolbarPaddingTop
		IniWrite, 0, Config.ini, Settings, ToolbarPaddingBot
		IniWrite, 0, Config.ini, Settings, ToolbarPaddingLeft
		IniWrite, 0, Config.ini, Settings, ToolbarPaddingRight
	}
	IniRead, BorderHor, Config.ini, Windows, BorderHor
	IniRead, BorderVert, Config.ini, Windows, BorderVert
	IniRead, PaddingHor, Config.ini, Windows, PaddingHor
	IniRead, PaddingVert, Config.ini, Windows, PaddingVert
	
	IniRead, InitialPortWindows, Config.ini, Settings, InitialPortWindows
	IniRead, WindowTitlesOn, Config.ini, Settings, WindowTitlesOn
	
	IniRead, ToolbarPaddingTop, Config.ini, Settings, ToolbarPaddingTop
	IniRead, ToolbarPaddingBot, Config.ini, Settings, ToolbarPaddingBot
	IniRead, ToolbarPaddingLeft, Config.ini, Settings, ToolbarPaddingLeft
	IniRead, ToolbarPaddingRight, Config.ini, Settings, ToolbarPaddingRight
}

CreateWindows(){
	global
	local tempid, tempTitle, tempclass
	DetectHiddenWindows, Off
	windowArray := Object()
	tempTitle := 
	
	Loop, %windows%
	{
		VarSetCapacity(windows%A_Index%,0)
	}
	
	WinGet, windows, List
	Loop, %windows%
	{
		tempid := windows%A_Index%
		WinGetTitle, tempTitle, ahk_id %tempid%
		WinGetClass, tempclass, ahk_id%tempid%
		if(tempTitle != ""){
			ifNotInString, ignoreList, %tempclass%
			{
				windowArray[A_Index] := new Window(tempid, titlesOn)
			}
		}
	}
	return
}

DetectMonitorMouse(){
	global
	local mouseTempX, mouseTempY, currentMonitor
	
	MouseGetPos, mouseTempX, mouseTempY
	Loop, %numMonitors%{
		currentMonitor := mon%A_Index%
		if(currentMonitor.LeftX <= mouseTempX && mouseTempX < currentMonitor.RightX && currentMonitor.TopY <= mouseTempY && mouseTempY < currentMonitor.BottomY){
			return %A_Index%
		}
	}
	return 0
}

DetectMonitorWindow(WindowID){
	global 
	local winX, winY, currentMonitor
	
	WinGetPos, winX, winY,,,ahk_id %WindowID%
	Loop, %numMonitors% {
		currentMonitor := mon%A_Index%
		if(currentMonitor.LeftX <= winX && winX < currentMonitor.RightX && currentMonitor.TopY <= winY && winY < currentMonitor.BottomY){
			return %A_Index%
		}
	}
	return 0
}

SendWindowToMonitorArray(WindowID){
		global
		local windowLocation, temp, tempmon
		
		windowLocation := DetectMonitorWindow(WindowID)
		tempmon := mon%windowLocation%
		temp := tempmon.NumberWindows+1
		tempmon.Windows[temp] := WindowID
		tempmon.NumberWindows := temp
	
		return
}

SendAllWindowsToMonitorArray(){
	global
	local temp
	Loop, %windows%
	{
		temp := windowArray[A_Index].Hwnd
		SendWindowToMonitorArray(temp)
	}
}

SearchAndDestroyWindow(WindowID)
{
	global
	local temp, temp2, temp3, tempID, monitor
	Loop, %numMonitors%
	{
		monitor := mon%A_Index%
		temp := monitor.NumberWindows
		Loop, %temp%
		{
			tempID := monitor.Windows[A_Index]
			if(WindowID = tempID)
			{
				temp2 := temp - A_Index
				temp3 := A_Index
				Loop, %temp2%
				{
					monitor.Windows[temp3+(A_Index-1)] := monitor.Windows[temp3+A_Index]
				}
				monitor.Windows[temp] := ""
				monitor.NumberWindows := temp - 1
				return monitor
			}
		}
	}
}



ShellMessage(wParam, lParam){
	Global
	local temp, tempmon
	if(wParam = 1){
		;Window Created
		temp := DetectMonitorWindow(lParam)
		tempmon := mon%temp%
		tempWindow := new Window(lParam, titlesOn)
		SendWindowToMonitorArray(lParam)
		tempmon.Ship()
	} else if(wParam = 4 || wParam = 3 || wParam = 6){
		;Window active
		temp := DetectMonitorWindow(lParam)
		tempmon := mon%temp%
		tempmon.Ship()
	} else if(wParam = 2){
		temp := DetectMonitorWindow(lParam)
		tempmon := SearchAndDestroyWindow(lParam)
		tempmon.Ship()
	}
	return
}

























