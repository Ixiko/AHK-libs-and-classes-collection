SuperMaxWindow(fnWindowId,fnSuperMax)
{
	; maximizes a window across dual monitors
	; MsgBox fnWindowId: %fnWindowId%`nfnSuperMax: %fnSuperMax%


	; declare local, global, static variables
	Global TaskBarX, TaskBarY, TaskBarWidth, TaskBarHeight, DualScreenW
	; Local ReturnValue, NewX, NewY, NewW, NewH, WinX, WinY, WinW, WinH, ThisWinIsSuperMaxed


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If fnSuperMax not in 0,1
		{
			ReturnValue := -1
			Throw, Exception("fnSuperMax not in 0,1")
		}
		IfWinNotExist, ahk_id %fnWindowId%
		{
			ReturnValue := -2
			Throw, Exception("Window doesn't exist")
		}
		WinGetPos, TaskBarX, TaskBarY, TaskBarWidth, TaskBarHeight, ahk_class Shell_TrayWnd ; get taskbar positions and dimensions
		If (TaskBarHeight > TaskBarWidth || TaskBarY < A_ScreenHeight/2) ; taskbar on side or top
		{
			ReturnValue := -3
			Throw, Exception("Taskbar on side or top")
		}
		SysGet, DualScreenW, 78 ; SM_CXVIRTUALSCREEN ; get total screen width (dual monitors)
		If (DualScreenW = A_ScreenWidth)
		{
			ReturnValue := -4
			Throw, Exception("Not on dual monitors",-1,"AlwaysSilent")
		}


		; initialise variables
		NewX := 0
		NewY := 0
		NewW := A_ScreenWidth
		NewH := A_ScreenHeight


		; get position of window
		WinRestore, ahk_id %fnWindowId%
		WinGetPos, WinX, WinY, WinW, WinH, ahk_id %fnWindowId%
		
		
		; determine supermax status
		ThisWinIsSuperMaxed := WindowSuperMaxStatus(WinX,WinY,WinW,WinH)
		
		
		; if win is not supermaxed and attempting to supermax
		If (!ThisWinIsSuperMaxed && fnSuperMax)
		{
			WindowPrevPosn%fnWindowId% := WinX "," WinY "," WinW "," WinH ; store current location in list
			SetSuperMaxPosn(NewX,NewY,NewW,NewH) ; supermax it
		}
		
		
		; if win is supermaxed and attempting to supermax
		If (ThisWinIsSuperMaxed && fnSuperMax)
			SetSuperMaxPosn(NewX,NewY,NewW,NewH) ; supermax it anyway
		
		
		; if win is supermaxed and restoring
		If (ThisWinIsSuperMaxed && !fnSuperMax)
		{
			SetDefaultPosn(NewX,NewY,NewW,NewH) ; set default posn in case of missing list entry
			GetLastPosn(fnWindowId,NewX,NewY,NewW,NewH) ; get its last location from list
			WindowPrevPosn%fnWindowId% := "" ; delete from list
		}
		
		
		; if win is not supermaxed and restoring
		If (!ThisWinIsSuperMaxed && !fnSuperMax)
		{
			WindowPrevPosn%fnWindowId% := "" ; delete entry from list in case it already exists
			Throw, Exception("Trying to restore a window that is not supermaxed")
		}
			
		
		; move window
		WinMove, ahk_id %fnWindowId%,, %NewX%, %NewY%, %NewW%, %NewH%

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}

SetSuperMaxPosn(ByRef X,ByRef Y,ByRef W,ByRef H)
{
	Global
	X := -8
	Y := 0
	W := DualScreenW+16
	H := A_ScreenHeight-TaskBarHeight+8
}

SetDefaultPosn(ByRef X,ByRef Y,ByRef W,ByRef H)
{
	Global
	X := 50
	Y := 50
	W := A_ScreenWidth-100
	H := A_ScreenHeight-TaskBarHeight-100
}

GetLastPosn(fnWindowId,ByRef X,ByRef Y,ByRef W,ByRef H)
{
	Global
	Local CoordList, Coord
	CoordList := WindowPrevPosn%fnWindowId%
	StringSplit, Coord, CoordList, `,
	LastPosnWasSuperMaxed := WindowSuperMaxStatus(Coord1,Coord2,Coord3,Coord4)
	If LastPosnWasSuperMaxed
		Return
	X := Coord1 ? Coord1 : X
	Y := Coord2 ? Coord2 : Y
	W := Coord3 ? Coord3 : W
	H := Coord4 ? Coord4 : H
}


/* ; testing
; WinGet, ThisWindowId, ID, ahk_class Notepad ; get active window ID
; WinGetTitle, ThisWinTitle, ahk_id %ThisWindowId%
; MsgBox, ThisWindowId: %ThisWindowId%`nThisWinTitle: %ThisWinTitle%
ThisWindowId := WinExist("WinMerge ahk_class WinMergeWindowClassW ahk_exe WinMergeU.exe")

ThisSuperMax := 1
ReturnValue := SuperMaxWindow(ThisWindowId,ThisSuperMax)
MsgBox, SuperMaxWindow`n`nReturnValue: %ReturnValue%

ThisSuperMax := 1
ReturnValue := SuperMaxWindow(ThisWindowId,ThisSuperMax)
MsgBox, SuperMaxWindow`n`nReturnValue: %ReturnValue%

ThisSuperMax := 0
ReturnValue := SuperMaxWindow(ThisWindowId,ThisSuperMax)
MsgBox, SuperMaxWindow`n`nReturnValue: %ReturnValue%

ThisSuperMax := 0
ReturnValue := SuperMaxWindow(ThisWindowId,ThisSuperMax)
MsgBox, SuperMaxWindow`n`nReturnValue: %ReturnValue%
; */