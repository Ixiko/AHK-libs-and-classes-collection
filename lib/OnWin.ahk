/**
 * Function: OnWin
 *     Specifies a function to call when the specified window event for the
 *     specified window occurs.
 * Version:
 *     v1.1.00.02
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest stable version of AutoHotkey
 * Syntax:
 *     OnWin( Event, WinTitle, Callback [, ItemId := "" ] )
 * Parameter(s):
 *     Event           [in] - Window event to monitor. Valid values are: Exist,
 *                            Close, Show, Hide, Active, NotActive, Minimize,
 *                            Maximize.
 *     WinTitle        [in] - see http://ahkscript.org/docs/misc/WinTitle.htm
 *     Callback        [in] - "Function object" - see http://ahkscript.org/docs/objects/Functor.htm
 *     ItemId     [in, opt] - User-defined ID to associate with this particular
 *                            window event monitor.
 * Remarks:
 *     - Script must be #Include-ed(manually or automatically) and must not be
 *       copy-pasted into the main script.
 *     - OnWin() uses A_TitleMatchMode
 * Links:
 *     GitHub      - http://goo.gl/JfzFTh
 *     Forum Topic - http://goo.gl/sMufTt
 */
OnWin(args*)
{
	return __OnWinEvent(args*)
}
/**
 * Function: OnWin_Ex
 *     Sames as OnWin() above, however, a child process is spawned to perform the
 *     monitoring.
 * Syntax:
 *     OnWin_Ex( Event, WinTitle, Callback [, ItemId := "", ProcessName := "default" ] )
 * Parameter(s):
 *     Event             [in] - Same as that of OnWin()'s
 *     WinTitle          [in] - Same as that of OnWin()'s
 *     Callback          [in] - Same as that of OnWin()'s
 *     ItemId       [in, opt] - Same as that of OnWin()'s
 *     ProcessName  [in, opt] - User-defined ID to associate with this particular
 *                              child process. Subsequent call(s) to OnWin_Ex()
 *                              will push the window event monitor info into the
 *                              queue of this particular process unless a different
 *                              name/ID is specified.
 */
OnWin_Ex(args*)
{
	return __OnWinEvent(args*)
}
/**
 * Function: OnWin_Stop
 *     Disables monitoring for the particular window event monitor info item
 *     specified by the 'ItemId' parameter.
 * Syntax:
 *     OnWin_Stop( ItemId [, ProcessName ] )
 * Parameter(s):
 *     ItemId            [in] - a previously defined ItemId - see OnWin/OnWin_Ex
 *                              If explicitly blank(""), all window event monitor
 *                              are disabled.
 *     ProcessName  [in, opt] - a previously defined ProcessName - see OnWin_Ex
 */
OnWin_Stop(id, name*)
{
	return __OnWinEvent(id, name*)
}

; PRIVATE
__OnWinEvent(args*)
{
	static InProcess   := new __OnWinEvent.Watcher
	static SubProcesss := new __OnWinEvent.Server

	static level := A_AhkVersion<"2" ? -2 : -1
	command := Exception("", level).What ; prevent user from calling A_ThisFunc directly, overkill??
	if (command == "OnWin")
		return %InProcess%(args*)

	else if (command == "OnWin_Ex")
		return %SubProcesss%(args*)

	else if (command == "OnWin_Stop")
	{
		if ObjHasKey(args, 2)
			SubProcesss.Clients[args[2]].Stop(args[1])
		else
			InProcess.Stop(args[1])
	}
}

class __OnWinEvent ; namespace
{
	class Callable ; base object for custom "Function" objects
	{
		__Call(method, args*)
		{
			if IsObject(method)
				return this.Call(method, args*)
			else if (method == "")
				return this.Call(args*)
		}
	}
	
	class Watcher extends __OnWinEvent.Callable
	{
		Queue := []
		IsRunning := false
		Call(args*)
		{
			ObjPush(this.Queue, info := new __OnWinEvent.Info(args*))
			
			if !this.IsRunning
				this.Start()
		}

		Watch()
		{
			Loop, % ObjLength(this.Queue)
			{
				if this.Queue[1].Assert()
					ObjRemoveAt(this.Queue, 1)
				else
					ObjPush(this.Queue, ObjRemoveAt(this.Queue, 1))
			}

			if !this.IsRunning := ObjLength(this.Queue) ; update 'IsRunning' property
				this.Stop()
		}

		Start()
		{
			this.SetTimer(25)
			this.IsRunning := true
		}

		Stop(args*)
		{
			this.SetTimer("Off")

			if HasId := ObjLength(args)
			{
				id := args[1]
				if (id == "") && (len := ObjLength(this.Queue))
					ObjRemoveAt(this.Queue, 1, len)

				Loop, % ObjLength(this.Queue)
					if (this.Queue[A_Index].Id = id) ? ObjRemoveAt(this.Queue, A_Index) : 0
						break
			}

			this.SetTimer(HasId ? "On" : "Delete")
		}

		SetTimer(arg3)
		{
			static number := "number"
			if arg3 is %number%
			{
				if !timer := this.Timer
					timer := this.Timer := ObjBindMethod(this, "Watch")
				SetTimer, %timer%, %arg3%
			}
			
			else if (arg3 = "On" || arg3 = "Off")
			{
				timer := this.Timer
				SetTimer, %timer%, %arg3%
			}
			
			else if (arg3 = "Delete")
			{
				if timer := ObjDelete(this, "Timer")
					SetTimer, %timer%, Delete
			}
		}
	}

	class WatcherEx extends __OnWinEvent.Watcher
	{
		Host := "" ; value assigned by host
		Name := "" ; value assigned by host
		__Delete()
		{
			ExitApp
		}

		Stop(args*)
		{
			base.Stop(args*)
			
			if !ObjLength(args) ; usually called from the timer routine when the queue is empty
			{
				; there are no longer any window events to monitor. Remove object
				; reference from the host script's clients list, __Delete should be
				; triggered automatically.
				this.Host.Ptr.Clients.Delete(this.Name)
				this.Host := ""
			}
		}
	}

	class Server extends __OnWinEvent.Callable
	{
		Clients := {}
		Call(event, WinTitle, CbProc, id:="", name:="default")
		{
			if !IsObject(this.Clients[name])
			{
				client := new __OnWinEvent.Client

				static q := Chr(34), quot := Func("Format").Bind("{1}{2}{1}", q)
				code := Format("
				( LTrim Join`r`n Comments
				ComObjActive({1}).Proxy := new __OnWinEvent.WatcherEx
				return
				#NoTrayIcon
				#Persistent
				#Include {2}
				)"
				, quot.Call(client.Guid["Str"]), A_LineFile)

				try
				{
					WshExec := ComObjCreate("WScript.Shell").Exec(quot.Call(A_AhkPath) . " /ErrorStdOut *")
					WshExec.StdIn.Write(code)
					WshExec.StdIn.Close()
					while (WshExec.Status == 0) && !client.Proxy
						Sleep, 10
				}
				finally
					client.Revoke()

				client.Proxy.Host := new this.Ref(this) ; weak reference, allows 2-way communication
				client.Proxy.Name := name
				this.Clients[name] := client.Proxy
				client := ""
			}

			remote := this.Clients[name]
			return %remote%(event, WinTitle, CbProc, id, A_TitleMatchMode)
		}

		class Ref
		{
			__New(self)
			{
				this.__Ptr := &self
			}

			Ptr[] ; allows client script(s) to retrieve a reference to the host object
			{
				get {
					if (pThis := this.__Ptr) && (NumGet(pThis + 0) == NumGet(&this))
						return Object(pThis)
				}
			}
		}

		__Delete() ; triggers on main script's exit
		{
			; stop remote client script(s) if any
			for i, client in this.Clients
				client.SetTimer("Delete") ; force stop and remove any extra object references(timer's BoundFunc)
			this.Clients := "" ; should trigger client script(s) __Delete
		}
	}

	class Client
	{
		__New()
		{
			HR := DllCall("oleaut32\RegisterActiveObject", "Ptr", &this, "Ptr", this.Guid["Ptr"], "UInt", 0, "UInt*", hReg, "UInt")
			if (HR < 0)
				throw Exception("RegisterActiveObject() error", -1, Format("HRESULT: 0x{:x}", HR))
			this.__Handle := hReg
		}

		__Delete()
		{
			this.Revoke()
		}

		Revoke()
		{
			if hReg := this.__Handle
				DllCall("oleaut32\RevokeActiveObject", "UInt", hReg, "Ptr", 0)
			this.__Handle := 0
		}

		Guid[arg]
		{
			get {
				if !pGuid := ObjGetAddress(this, "_Guid")
				{
					ObjSetCapacity(this, "_Guid", 94)
					pGuid := ObjGetAddress(this, "_Guid")
					if ( DllCall("ole32\CoCreateGuid", "Ptr", pGuid) != 0 )
						throw Exception("Failed to create GUID", -1, Format("<at {1:p}>", pGuid))
					DllCall("ole32\StringFromGUID2", "Ptr", pGuid, "Ptr", pGuid + 16, "Int", 39)
				}
				return (arg="Ptr") ? pGuid : (arg="Str") ? StrGet(pGuid + 16, "UTF-16") : ""
			}
		}
	}

	class Info
	{
		__New(event, WinTitle, CbProc, id:="", tmm:=0) ; tmm used internally for client scripts
		{
			this.Event := event
			this.WinTitle := WinTitle
			this.Callback := CbProc
			this.TitleMatchMode := tmm ? tmm : A_TitleMatchMode
			if (id != "")
				this.Id := id
		}

		Assert()
		{
			event := this.Event
			WinTitle := this.WinTitle
			prev_TMM := A_TitleMatchMode
			this_TMM := this.TitleMatchMode
				SetTitleMatchMode, %this_TMM%

			prev_DWH := A_DetectHiddenWindows
			DetectHiddenWindows, On

			if (event = "Exist")
				r := WinExist(WinTitle)

			else if (event = "Close")
				r := !WinExist(WinTitle)
			
			else if (event = "Active")
				r := WinActive(WinTitle)

			else if (event = "NotActive")
				r := !WinActive(WinTitle)
			
			else if (event = "Show") || (event = "Hide" && hWnd := WinExist(WinTitle))
			{
				DetectHiddenWindows, Off
				r := (event="Show") ? WinExist(WinTitle) : !WinExist(WinTitle)
			}
			
			else if (event = "Minimize" || event = "Maximize")
			{
				static WINDOWPLACEMENT
				if !VarSetCapacity(WINDOWPLACEMENT)
					VarSetCapacity(WINDOWPLACEMENT, 44, 0), NumPut(44, WINDOWPLACEMENT, 0, "UInt") ; sizeof(WINDOWPLACEMENT)
				
				hWnd := WinExist(WinTitle)
				showCmd := event="Minimize" ? 2 : 3
				DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
				r := NumGet(WINDOWPLACEMENT, 8, "UInt") == showCmd
			}

			
			SetTitleMatchMode, %prev_TMM%
			DetectHiddenWindows %prev_DHW%
			
			if r
				this.Callback.Call(this)
			return r
		}
	}
}