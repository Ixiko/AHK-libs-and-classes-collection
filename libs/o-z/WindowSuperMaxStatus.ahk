WindowSuperMaxStatus(fnX,fnY,fnW,fnH)
{
	; determines supermax (maxed across dual monitors) status of a window
	; MsgBox fnX: %fnX%`nfnY: %fnY%`nfnW: %fnW%`nfnH: %fnH%


	; declare local, global, static variables


	Try
	{
		; set default return value
		SuperMaxStatus := 0


		; validate parameters
		WinGetPos, TaskBarX, TaskBarY, TaskBarWidth, TaskBarHeight, ahk_class Shell_TrayWnd ; get taskbar positions and dimensions
		If (TaskBarHeight > TaskBarWidth || TaskBarY < A_ScreenHeight/2) ; taskbar on side or top
		{
			SuperMaxStatus := -2
			Throw, Exception("Taskbar on side or top")
		}
		SysGet, DualScreenW, 78 ; SM_CXVIRTUALSCREEN ; get total screen width (dual monitors)
		If (DualScreenW = A_ScreenWidth)
		{
			SuperMaxStatus := -3
			Throw, Exception("Not on dual monitors")
		}


		; initialise variables
		EdgeToleranceInPixels := 10


		; determine supermax status
		If (fnX <= 0+EdgeToleranceInPixels)
			If (fnY <= 0+EdgeToleranceInPixels)
				If (fnW >= DualScreenW-EdgeToleranceInPixels-EdgeToleranceInPixels)
					If (fnH >= A_ScreenHeight-TaskBarHeight-EdgeToleranceInPixels-EdgeToleranceInPixels)
						SuperMaxStatus := 1

	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return SuperMaxStatus
}


/* ; testing
WinGet, ThisWindowId, ID, ahk_class Notepad ; get active window ID
WinGetTitle, ThisWinTitle, ahk_id %ThisWindowId%
WinGetPos, npX, npY, npW, npH, ahk_id %ThisWindowId%
WinGetPos, TaskBarX, TaskBarY, TaskBarWidth, TaskBarHeight, ahk_class Shell_TrayWnd ; get taskbar positions and dimensions
SysGet, DualScreenW, 78 ; SM_CXVIRTUALSCREEN ; get total screen width (dual monitors)
abcH := A_ScreenHeight-TaskBarHeight
MsgBox, ThisWindowId: %ThisWindowId%`nThisWinTitle: %ThisWinTitle%`n%npX%,%npY%,%npW%,%npH%`nDualScreenW: %DualScreenW%`nA_ScreenHeight-TaskBarHeight: %abcH%
ReturnValue := WindowSuperMaxStatus(npX,npY,npW,npH)
MsgBox, WindowSuperMaxStatus`n`nSuperMaxStatus: %ReturnValue%
*/