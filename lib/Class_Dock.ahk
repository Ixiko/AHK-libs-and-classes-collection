/*
	Class Dock
		Attachs a window to another

	version
		0.1 (2017.04.20)

	License
		WTFPL (http://wtfpl.net/)

	Dev env
		Windows 10 pro x64
		AutoHotKey H v1.1.25.01
		lastly edited by Soft(Visionary1)


	Instance := new Dock(parent, child, Callback)

	parent
		- hwnd of the window that child will follow

	child
		- hwnd of the window that follows the parent window

	Callback
		- a function object, or a boundfunc object

	To Detach, circular references have to be freed
	otherwise, __Delete() won't be called. See 'Dock Example.ahk' for example
*/

Class Dock
{
	static EVENT_OBJECT_LOCATIONCHANGE := 0x800B
	, EVENT_OBJECT_FOCUS := 0x8005, EVENT_OBJECT_DESTROY := 0x8001

	__New(Main, Attach, Callback)
	{
		this.hwnd := []
		this.hwnd.Main := Main
		this.hwnd.Attach := Attach
		this.Callback := Callback

		; lpfnWinEventProc
		this.hookProcAdr := RegisterCallback("_DockHookProcAdr",,, &this)

		; idProcess
		WinGet, idProcess, PID, % "ahk_id " . this.hwnd.Main

		; idThread
		idThread := DllCall("GetWindowThreadProcessId", "Ptr", this.hwnd.Main, "Int", 0)

		DllCall("CoInitialize", "Int", 0)

		this.Hook := DllCall("SetWinEventHook"
				, "UInt", Dock.EVENT_OBJECT_DESTROY 		;eventMin
				, "UInt", Dock.EVENT_OBJECT_LOCATIONCHANGE 	;eventMax
				, "Ptr", 0 					;hmodWinEventProc
				, "Ptr", this.hookProcAdr 			;lpfnWinEventProc
				, "UInt", idProcess		 		;idProcess
				, "UInt", idThread				;idThread
				, "UInt", 0) 					;dwFlags
	}

	__Delete()
	{
		DllCall("UnhookWinEvent", "Ptr", this.Hook)
		DllCall("CoUninitialize")
		DllCall("GlobalFree", "Ptr", this.hookProcAdr)
		this.Hook := ""
		this.hookProcAdr := ""
		this.Callback := ""
		this.Delete("hwnd")
	}
}

Class Dock_Events
{
	Calls(self, hWinEventHook, event, hwnd)
	{
		If !(hwnd = self.hwnd.Main)
			Return

		If (event = Dock.EVENT_OBJECT_FOCUS)
		{
			this.EVENT_OBJECT_FOCUS(self.hwnd.Attach)
		}

		If (event = Dock.EVENT_OBJECT_LOCATIONCHANGE)
		{
			this.EVENT_OBJECT_LOCATIONCHANGE(self)
		}

		If (event = Dock.EVENT_OBJECT_DESTROY)
		{
			ExitApp
		}
	}

	EVENT_OBJECT_FOCUS(hwnd)
	{
		WinSet, AlwaysOnTop, On, % "ahk_id " . hwnd
		WinSet, AlwaysOnTop, Off, % "ahk_id " . hwnd
	}

	EVENT_OBJECT_LOCATIONCHANGE(self)
	{
		WinGetPos, hX, hY, hW, hH, % "ahk_id " . self.hwnd.Main
		WinGetPos, cX, cY, cW, cH, % "ahk_id " . self.hwnd.Attach
		X := hX + hW
		Y := hY

		DllCall("MoveWindow", "Ptr", self.hwnd.Attach, "Int", X, "Int", Y, "Int", cW, "Int", cH, "Int", 1)
	}
}

_DockHookProcAdr(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
	this := Object(A_EventInfo)
	Return this.Callback.Call(this, hWinEventHook, event, hwnd)
}