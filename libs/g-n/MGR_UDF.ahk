; Minimize the active window
Win_Minimize(){
	WinGetClass, Class, A
	If (Class="Progman")
		Return
	WinMinimize, A
}

; Maximize or Restore the active window
Win_Maximize(){
	WinGetClass, Class, A
	If (Class="Progman")
		Return
	WinGet, WinMinMax, MinMax, A
	If (WinMinMax==1)
		WinRestore, A
	Else
		WinMaximize, A
}

; Close the whole active window, not only the tab
Win_Close(){
	WinClose, A
}

; Toggle the active window between AlwaysOnTop states
Win_AlwaysOnTop(){
	WinGetClass, Class, A
	If (Class="Progman")
		Return
	WinSet, AlwaysOnTop, Toggle, A
}

; Get the process name of the active window
; and put it in the clipboard
Win_GetProcess(){
	TLimit := 3 , t1 := A_TickCount
	While (Seconds<TLimit){
		Sleep, 10
		t2 := A_TickCount , Seconds	:= ((t2-t1)//1000)
		WinGet, Process, ProcessName, A
		ToolTip, % "Process name (" TLimit-Seconds "s) : " Process
	}
	Clipboard := Process
	ToolTip
}

; Get the class of the active window
; and put it in the clipboard
Win_GetClass(){
	TLimit := 3 , t1 := A_TickCount
	While (Seconds<TLimit){
		Sleep, 10
		t2 := A_TickCount , Seconds	:= ((t2-t1)//1000)
		WinGetClass, Class, A
		ToolTip, % "Window's class (" TLimit-Seconds "s) : " Class
	}
	Clipboard := Class
	ToolTip
}

; Activate the next window
Win_Next(){
	IDs := Win_GetIDs() , Pos := 1
	WinActivate, % "ahk_id " IDs[IDs.MaxIndex()]
}

; Activate the last window
Win_Last(){
	IDs := Win_GetIDs() , Pos := 1
	WinGetTitle, t1, % "ahk_id " IDs[1]
	WinGetTitle, t2, % "ahk_id " IDs[2]
	WinActivate, % "ahk_id " ((t1=t2) ? IDs[3] : IDs[2])
}

; Get IDs of all visible windows
Win_GetIDs(){
	DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	BlackList := "Program manager|ProgMan|WorkerW|Startup|Démarrer"
	IDs := []
	WinGet, ID, List
	Loop, % ID
	{
		ID := ID%A_Index%
		WinGetTitle, Title, ahk_id %ID%
		WinGetClass, Class, ahk_id %ID%
		If ( Title && not (Title~="i)(" BlackList ")")
			&& not (Class~="i)tooltips_class32") )
				IDs.Insert(ID)
	}
	DetectHiddenWindows, % DetectHiddenWindows
	Return, IDs
}

; Get the monitor number where the mouse is
Win_MonitorNbr(){
    SysGet, MonitorCount, 80
    WinGetPos, X, Y,,, A
    Loop %MonitorCount%
    {
        SysGet, Mon, Monitor, %A_Index%
        If (X>=(MonLeft-20) && X<=(MonRight+10)
        	&& Y>=(MonTop-10) && Y<=(MonBottom+10))
            Return A_Index
    }
}

; Move the active window to the next monitor
Win_Move2NextMonitor(Maximize=0)
{
    CoordMode, Mouse, Screen
    SetWinDelay, -1
    SysGet, MonitorCount, MonitorCount
    WID := WinExist("A")
    If !WinActive("ahk_id " WID)
        WinActivate, % "ahk_id " WID
    MonitorNbr    := Win_MonitorNbr()
    NewMonitorNbr := (MonitorNbr=MonitorCount) ? 1 : MonitorNbr+1
    SysGet, MWA_,  MonitorWorkArea, % MonitorNbr
	SysGet, NMWA_, MonitorWorkArea, % NewMonitorNbr
	SysGet, NM_, Monitor, % NewMonitorNbr
	WinGetPos, WX, WY, WW, WH, % "ahk_id " WID
	WinGet, WinMinMax, MinMax, % "ahk_id " WID
    WXO := (WX-MWA_Left)          , WYO := (WY-MWA_Top)
    WNW := (NMWA_Right-NMWA_Left) , WNH := (NMWA_Bottom-NMWA_Top)
    MWA_W := (MWA_Right-MWA_Left) , MWA_H := (MWA_Bottom-MWA_Top)
    WinMove, % "ahk_id " WID,, % NMWA_Left+WXO , % NMWA_Top+WYO
    If (WinMinMax==1)
        WinMove, % "ahk_id " WID,,,, % WNW, % WNH
    Else If (!WinMinMax && WW>=MWA_W && WH>=MWA_H)
        WinMove, % "ahk_id " WID,,,, % NM_Right-NM_Left, % NM_Bottom-NM_Top
}

; Move the active window to the left part of the screen
Win_MoveLeft(){
    WinGet, WinID, ID, A
    Monitor := Win_MonitorNbr()
    SysGet, MWA_, MonitorWorkArea, % Monitor
    WinGet, WinMinMax, MinMax, % "ahk_id " WinID
    If (WinMinMax==1)
        WinRestore, % "ahk_id " WinID
    X := MWA_Left , Y := MWA_Top
    W := (MWA_Right-MWA_Left)/2 , H := MWA_Bottom
    WinMove, % "ahk_id " WinID,, % X, % Y, % W, % H
}

; Move the active window to the right part of the screen
Win_MoveRight(){
    WinGet, WinID, ID, A
    Monitor := Win_MonitorNbr()
    SysGet, MWA_, MonitorWorkArea, % Monitor
    WinGet, WinMinMax, MinMax, % "ahk_id " WinID
    If (WinMinMax==1)
        WinRestore, % "ahk_id " WinID
    X := MWA_Left+((MWA_Right-MWA_Left)/2) , Y := MWA_Top
    W := (MWA_Right-MWA_Left)/2 , H := MWA_Bottom
    WinMove, % "ahk_id " WinID,, % X, % Y, % W, % H
}

; Paste the clipboard in plain text format
Cpbd_PastePlainText(){
	WinActivate, A
	Clipboard := Clipboard
	Send, ^v
}

; Get the user's selection and converts it to plain text format
GetSelection(PlainText=1){
	LastClipboard := ClipboardAll , Clipboard := ""
	SendInput, ^c
	ClipWait, 2, 1
	If ErrorLevel
		Return
	If not PlainText
		Return, ClipboardAll
	Selection := Clipboard , Clipboard := LastClipboard
	Return, Selection
}

; Save the user's selection in a txt file
SaveSelection(){
	If !(Selection := GetSelection())
		Return
	InputBox, FileName, Save Clipboard:, File name ?,, 250, 115
	If (!FileName || ErrorLevel )
		Return
	If !FileExist(A_ScriptDir "\SavedTexts")
		FileCreateDir, % A_ScriptDir "\SavedTexts"
	Path := A_ScriptDir "\SavedTexts\" FileName
	FileDelete, % Path
	FileAppend, % Selection, % Path
	Return, Path
}

; Simulate a click at X and Y coordinates
MClick(x=0, y=0){
	If !(x~="^\d$" || y~="^\d$")
		x := 0 , y := 0
	MouseGetPos, MouseX, MouseY
	MouseClick, Left , % x, % y, 1, 0
	MouseMove, % MouseX, % MouseY, 0
}