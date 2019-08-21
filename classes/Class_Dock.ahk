/*
	Class Dock
		Attach a window to another
	Author
		Soft (visionary1 예지력)
	version
		0.1 (2017.04.20)
		0.2 (2017.05.06)
		0.2.1 (2017.05.07)
		0.2.1.1 bug fixed (2017.05.09)
		0.2.2 testing multiple docks... (2017.05.09)
	License
		WTFPL (http://wtfpl.net/)
	Dev env
		Windows 10 pro x64
		AutoHotKey H v1.1.25.01 32bit
	To Do...
		Multiple Dock, group windows...
	thanks to
		Helgef for overall coding advices
*/
class Dock
{
	static EVENT_OBJECT_LOCATIONCHANGE := 0x800B
	, EVENT_OBJECT_FOCUS := 0x8005, EVENT_OBJECT_DESTROY := 0x8001
	, EVENT_MIN := 0x00000001, EVENT_MAX := 0x7FFFFFFF ;for debug
	, EVENT_SYSTEM_FOREGROUND := 0x0003

	/*
		Instance := new Dock(Host hwnd, Client hwnd, [Callback], [CloseCallback])

			Host hwnd
				hwnd of a Host window

			Client hwnd
				hwnd of a window that follows Host window (window that'll be attached to a Host window)

			[Callback]
				a func object, or a bound func object
				if omitted, default EventsHandler will be used, which is hard-coded in 'Dock.EventsHandler'
				To construct your own events handler, I advise you to see Dock.EventsHandler first

			[CloseCallback]
				a func object, or a bound func object
				called when Host window is destroyed, see 'Dock Example.ahk' for practical usuage
	*/
	__New(Host, Client, Callback := "", CloseCallback := "")
	{
		this.hwnd := []
		this.hwnd.Host := Host
		this.hwnd.Client := Client
		WinSet, ExStyle, +0x80, % "ahk_id " this.hwnd.Client

		this.Bound := []

		this.Callback := IsObject(Callback) ? Callback : ObjBindMethod(Dock.EventsHandler, "Calls")
		this.CloseCallback := IsFunc(CloseCallback) || IsObject(CloseCallback) ? CloseCallback

		/*
			lpfnWinEventProc
		*/
		this.hookProcAdr := RegisterCallback("_DockHookProcAdr",,, &this)

		/*
			idProcess
		*/
		;WinGet, idProcess, PID, % "ahk_id " . this.hwnd.Host
		idProcess := 0

		/*
			idThread
		*/
		;idThread := DllCall("GetWindowThreadProcessId", "Ptr", this.hwnd.Host, "Int", 0)
		idThread := 0

		DllCall("CoInitialize", "Int", 0)

		this.Hook := DllCall("SetWinEventHook"
				, "UInt", Dock.EVENT_SYSTEM_FOREGROUND 		;eventMin
				, "UInt", Dock.EVENT_OBJECT_LOCATIONCHANGE 	;eventMax
				, "Ptr", 0				  	;hmodWinEventProc
				, "Ptr", this.hookProcAdr 			;lpfnWinEventProc
				, "UInt", idProcess			 	;idProcess
				, "UInt", idThread			  	;idThread
				, "UInt", 0)					;dwFlags
	}

	/*
		Instance.Unhook()
			unhooks Dock and frees memory
	*/
	Unhook()
	{
		DllCall("UnhookWinEvent", "Ptr", this.Hook)
		DllCall("CoUninitialize")
		DllCall("GlobalFree", "Ptr", this.hookProcAdr)
		this.Hook := ""
		this.hookProcAdr := ""
		this.Callback := ""
		WinSet, ExStyle, -0x80, % "ahk_id " this.hwnd.Client
	}

	__Delete()
	{
		this.Delete("Bound")

		If (this.Hook)
			this.Unhook()

		this.CloseCallback := ""
	}

	/*
		provisional
	*/
	Add(hwnd, pos := "")
	{
		static last_hwnd := 0

		this.Bound.Push( new this( !NumGet(&this.Bound, 4*A_PtrSize) ? this.hwnd.Client : last_hwnd, hwnd ) )

		If pos Contains Top,Bottom,R,Right,L,Left
			this.Bound[NumGet(&this.Bound, 4*A_PtrSize)].Position(pos)

		last_hwnd := hwnd
	}

	/*
		Instance.Position(pos)
			pos - sets position to dock client window
				Top - sets to Top side of the host window
				Bottom - sets to bottom side of the host window
				R or Right - right side
				L or Left -  left side
	*/
	Position(pos)
	{
		this.pos := pos
		Return this.EventsHandler.EVENT_OBJECT_LOCATIONCHANGE(this, "host")
	}

	/*
		Default EventsHandler
	*/
	class EventsHandler extends Dock.HelperFunc
	{
		Calls(self, hWinEventHook, event, hwnd)
		{
			Critical

			If (hwnd = self.hwnd.Host)
			{
				Return this.Host(self, event)
			}

			If (hwnd = self.hwnd.Client)
			{
				Return this.Client(self, event)
			}
		}

		Host(self, event)
		{
			If (event = Dock.EVENT_SYSTEM_FOREGROUND)
			{
				Return this.EVENT_SYSTEM_FOREGROUND(self.hwnd.Client)
			}

			If (event = Dock.EVENT_OBJECT_LOCATIONCHANGE)
			{
				Return this.EVENT_OBJECT_LOCATIONCHANGE(self, "host")
			}

			If (event = Dock.EVENT_OBJECT_DESTROY)
			{
				self.Unhook()

				If (IsFunc(self.CloseCallback) || IsObject(self.CloseCallback))
					Return self.CloseCallback()
			}
		}

		Client(self, event)
		{
			If (event = Dock.EVENT_SYSTEM_FOREGROUND)
			{
				Return this.EVENT_SYSTEM_FOREGROUND(self.hwnd.Host)
			}

			If (event = Dock.EVENT_OBJECT_LOCATIONCHANGE)
			{
				Return this.EVENT_OBJECT_LOCATIONCHANGE(self, "client")
			}
		}

		/*
			Called when host window got focus
			without this, client window can't be showed (can't set to top)
		*/
		EVENT_SYSTEM_FOREGROUND(hwnd)
		{
			Return this.WinSetTop(hwnd)
		}

		/*
			Called when host window is moved
		*/
		EVENT_OBJECT_LOCATIONCHANGE(self, via)
		{
			Host := this.WinGetPos(self.hwnd.Host)
			Client := this.WinGetPos(self.hwnd.Client)

			If InStr(self.pos, "Top")
			{
				If (via = "host")
				{
					Return this.MoveWindow(self.hwnd.Client 	;hwnd
								, Host.x		;x
								, Host.y - Client.h 	;y
								, Client.w	  	;width
								, Client.h) 		;height
				}

				If (via = "client")
				{
					Return this.MoveWindow(self.hwnd.Host	   	;hwnd
								, Client.x	  	;x
								, Client.y + Client.h   ;y
								, Host.w		;width
								, Host.h)	   	;height
				}
			}

			If InStr(self.pos, "Bottom")
			{
				If (via = "host")
				{		   
					Return this.MoveWindow(self.hwnd.Client	 	;hwnd
								, Host.x		;x
								, Host.y + Host.h   	;y
								, Client.w	  	;width
								, Client.h)	 	;height
				}

				If (via = "client")
				{
					Return this.MoveWindow(self.hwnd.Host	   	;hwnd
								, Client.x	  	;x
								, Client.y - Host.h 	;y
								, Host.w		;width
								, Host.h)	   	;height
				}
			}

			If InStr(self.pos, "R")
			{
				If (via = "host")
				{
					Return this.MoveWindow(self.hwnd.Client	 	;hwnd
								, Host.x + Host.w   	;x
								, Host.y		;y
								, Client.w	  	;width
								, Client.h)	 	;height	
				}

				If (via = "client")
				{
					Return this.MoveWindow(self.hwnd.Host	   	;hwnd
								, Client.x - Host.w 	;x
								, Client.y	  	;y
								, Host.w		;width
								, Host.h)	   	;height
				}
			}

			If InStr(self.pos, "L")
			{
				If (via = "host")
				{
					Return this.MoveWindow(self.hwnd.Client	 	;hwnd
								, Host.x - Client.w 	;x
								, Host.y		;y
								, Client.w	  	;width
								, Client.h)	 	;height	
				}

				If (via = "client")
				{
					Return this.MoveWindow(self.hwnd.Host	   	;hwnd
								, Client.x + Client.w   ;x
								, Client.y	  	;y
								, Host.w		;width
								, Host.h)	   	;height	
				}
			}
		}
	}

	class HelperFunc
	{
		WinGetPos(hwnd)
		{
			WinGetPos, hX, hY, hW, hH, % "ahk_id " . hwnd
			Return {x: hX, y: hY, w: hW, h: hH}
		}

		WinSetTop(hwnd)
		{
			WinSet, AlwaysOnTop, On, % "ahk_id " . hwnd
			WinSet, AlwaysOnTop, Off, % "ahk_id " . hwnd
		}

		MoveWindow(hwnd, x, y, w, h)
		{
			Return DllCall("MoveWindow", "Ptr", hwnd, "Int", x, "Int", y, "Int", w, "Int", h, "Int", 1)
		}

		Run(Target)
		{
			Try Run, % Target,,, OutputVarPID
			Catch, 
				Throw, "Couldn't run " Target

			WinWait, % "ahk_pid " OutputVarPID

			Return WinExist("ahk_pid " OutputVarPID)
		}
	}
}

_DockHookProcAdr(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
	this := Object(A_EventInfo)
	this.Callback.Call(this, hWinEventHook, event, hwnd)
}