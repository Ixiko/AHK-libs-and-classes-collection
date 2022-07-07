#NoTrayIcon
#SingleInstance force
#Persistent
DetectHiddenWindows, On
/* usage:
	JoystickDeviceManagement [mainScriptHwnd]
*/
if (WinExist("ahk_id " . A_Args.1  . " ahk_class AutoHotkey")) {
	PostMessage, 0x8000,, % A_ScriptHwnd ; WM_APP := 0x8000 (https://docs.microsoft.com/fr-fr/windows/win32/winmsg/wm-app)
	; send back to the launcher script's hidden main window the hwnd of this script
} else ExitApp
Class JoystickDeviceManagement {
	Class Events {
		WM_DEVICECHANGE(_wParam, _lParam, _msg, _hwnd) {
		; The WM_DEVICECHANGE message notifies an application of a change to the hardware configuration of a device or the computer (cf. https://docs.microsoft.com/en-us/windows/win32/devio/wm-devicechange)
		; cf. also: https://autohotkey.com/boards/viewtopic.php?f=5&t=9880
			static WM_DEVICECHANGE := 0x219
			static _ := OnMessage(WM_DEVICECHANGE, ObjBindMethod(JoystickDeviceManagement.Events, "WM_DEVICECHANGE"))
			; DBT_DEVICEARRIVAL
			; DBT_DEVICEREMOVECOMPLETE
			static DBT_DEVNODES_CHANGED := 0x0007 ; A device has been added to or removed from the system.
			static _t := 0
			local
			global JoystickDeviceManagement
			if (_wParam <> DBT_DEVNODES_CHANGED)
				return
			_boolean := ((A_TickCount - _t) > 100), _t := A_TickCount
			IfEqual, _boolean, 0, return ; buffer any influx of calls
			static _fn := ObjBindMethod(JoystickDeviceManagement.Events, "_WM_DEVICECHANGE")
			SetTimer % _fn, -400
		}
		_WM_DEVICECHANGE() {
			local
			global A_Args ; cf. https://www.autohotkey.com/boards/viewtopic.php?style=7&p=298429
			static _PORTS := 8 ; <<<
			if WinExist("ahk_id " . A_Args.1 . " ahk_class AutoHotkey") {
				_wParam := ""
				Loop % _PORTS {
					_wParam .= (GetKeyState(a_index . "JoyX") && GetKeyState(a_index . "JoyY"))
				}
				sleep, 1000 ; ++++++++++
				PostMessage, 0x8001, % _wParam, % A_ScriptHwnd
			} else ExitApp
			run % (A_IsCompiled) ? A_ScriptFullPath  . " /restart /force " . A_Args.1 :  A_AHKPath . " /restart /force " . A_ScriptFullPath . " " . A_Args.1
		}
	}
}