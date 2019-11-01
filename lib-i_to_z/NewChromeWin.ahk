; Open a new chrome window and get process ID
;		wait until the window is ready to move
; 	For some reason the Chrome --window-size and --window-position arguments don't work
; https://autohotkey.com/boards/viewtopic.php?p=78778#p78778

NewChromeWin(x, y, w, h) {

	chromeProcesses := ChromeProcessCount()
		
	run, % "chrome.exe" ( winExist("ahk_class Chrome_WidgetWin_1") ? " --new-window " : " " ) url,,, WinPID
	sleep 150
	While(ChromeProcessCount() = chromeProcesses) {
	}
	chromeProcesses := ChromeProcessCount()
	WinPID := LastChromeProcessId()
	WinWait, % "ahk_pid " WinPID
	WinMove, % "ahk_pid " WinPID,, x, y, w, h

	return WinPID
}

; Determine how many Chrome processes are running
ChromeProcessCount() {
  return ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name = 'chrome.exe'").Count()
}

LastChromeProcessId() {
  WinGet, winId, IDLast, ahk_exe chrome.exe
  WinGet, processId, PID, ahk_id %winId%
  return processId
}