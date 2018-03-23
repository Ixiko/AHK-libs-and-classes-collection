getScriptHandle()
{
	hideMode := A_DetectHiddenWindows
	DetectHiddenWindows, on
	hWnd := WinExist("Ahk_PID " DllCall("GetCurrentProcessId"))
	DetectHiddenWindows, %hideMode%
	return hWnd
}