Excel_Get(WinTitle="ahk_class XLMAIN") {	; by Sean and Jethrow, minor modification by Learning one
	ControlGet, hwnd, hwnd, , Excel71, %WinTitle%
	if !hwnd
		return
	Window := Acc_ObjectFromWindow(hwnd, -16)
	Loop
		try
			Application := Window.Application
		catch
			ControlSend, Excel71, {esc}, %WinTitle%
	Until !!Application
	return Application
}	; http://www.autohotkey.com/forum/viewtopic.php?p=492448#492448