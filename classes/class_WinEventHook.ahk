; Usage example:
/*
#NoEnv
#SingleInstance force
#Warn

#Persistent
ControlGet, hEdit1, Hwnd,, Edit1, ahk_class Notepad
if not (hEdit1)
	ExitApp
WinEventHook.setForId(hEdit1, 0x800E, "f")
; WinEventHook.setForId(hEdit1, 0x800E, "f", 100) ; '100' means: "treat events separated by a period of less than 100ms as an influx of calls and buffer it as such"
return

!x::
	count := WinEventHook.unsetById(hEdit1)
	MsgBox % "ErrorLevel = " . ErrorLevel . "`nHook instance unset count = " . count
return


f(_params*) { ; _hWinEventHook, _event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime
	static OBJID_CLIENT := 0xFFFFFFFC ; https://docs.microsoft.com/fr-fr/windows/desktop/WinAuto/object-identifiers#OBJID_CLIENT
	local _idObject := _params.4
	if (_idObject = OBJID_CLIENT) ; actually, both the (edit child control) window's horizontal and the vertical scroll bars (OBJID_VSCROLL/OBJID_HSCROLL) could otherwise update the tooltip below
		ToolTip % Format("hWinEventHook = {}`nevent = {}`nhwnd = {}`nidObject = {}`nidChild = {}`ndwEventThread = {}`ndwmsEventTime = {}", _params*)
}
*/
; ========================================================

Class WinEventHook {

	/*
		Namespace: WinEventHook

		Environment: Windows 8.1 64 bit - Autohotkey v1.1.30.01 32-bit Unicode
		Credits:
			Fanatic Guru for WinHook - https://www.autohotkey.com/boards/viewtopic.php?t=59149&p=254920
		Related works:
			[LIB] EWinHook - SetWinEventHook implementation by cyruz - https://www.autohotkey.com/boards/viewtopic.php?p=176444
			Event Library by KuroiLight/klomb - https://www.autohotkey.com/boards/viewtopic.php?t=42657
	*/
	static _map := {}
	static _instances := {} ; _map and _instances are combined with a design conceived to allow cross-referencing while keeping track of instances
	static HANDLE_IDPROCESS := "" ; use internally to 'capture' events if a hWnd-filtering is set @._hookFunction. In any event, should not be 0 since the handle to the window that generates the event can be NULL - https://docs.microsoft.com/fr-fr/windows/desktop/api/winuser/nc-winuser-wineventproc#parameters
	static _callback := RegisterCallback("WinEventHook._hookFunction") ; we only need to call registercallback ones, we use a static variable - https://www.autohotkey.com/boards/viewtopic.php?t=59149&p=254920#profile249257

	Class _TimedCallback { ; nested class used internally to buffer an influx of calls as such, as influx

		static instances := {} ; keep track of instances
		_delegate := Func("Max") ; dummy variadic delegate
		_range := "Off"

		__New(_hWinEventHook) {
		return WinEventHook._TimedCallback.instances[ (this.ID:=_hWinEventHook) ] := this
		}
		__Call(_callee, _params*) { ; triggered by %this%(_hWinEventHook, _event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime)
			if (_callee = "") { ; for %fn%() or fn.() - https://www.autohotkey.com/docs/objects/Functor.htm#User-Defined
				this.params := _params
				SetTimer, % this, % -this._range
			}
		}
		__Delete() {
			SetTimer, % this, Off
			SetTimer, % this, Delete
			this._delegate := "" ;  release the user function object
		}
		call() { ; triggered by this.call(_hWinEventHook, _event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) yet  if the object is being used by SetTimer, only the call method is needed - https://www.autohotkey.com/docs/objects/Functor.htm#User-Defined
			_fn := this._delegate
		return %_fn%(this.params*)
		}
		delegate {
			set {
				if not (IsObject(value) || value:=Func(value)) {
					throw Exception("Invalid callback.")
				return
				}
			return this._delegate := value
			}
			get {
			return this._delegate
			}
		}
		range {
			set {
				static USER_RANGE_MAXIMUM := 1000
				if value not between -1 and %USER_RANGE_MAXIMUM%
				{
					throw Exception("The property could not be set to a value lower or greater than the ranged value.",, (value = "") ? """""" : value)
				return
				}
			return this._range := (value = -1) ? "Off" : value
			}
			get {
			return (this._range = "Off") ? -1 : this._range
			}
		}

	}

	__New(_idProcess, _event, _delegate, _hwnd, _offset:=-1, _range:=0) { ; designed to be used internally

		static _junkTimedCallback := (new WinEventHook._TimedCallback(0)) ; junk 'timed callback' used to check input parameters against the prerequisites
		static _junkFunc := Func("Func")
		local _hWinEventHook, _exception, _cbObject

		try { ; check input parameters against the prerequisites
			_junkTimedCallback.delegate := _delegate
			_junkTimedCallback.range := _range
		} catch _exception {
			throw Exception(_exception.message, _offset, _exception.extra)
		return
		} finally _junkTimedCallback.delegate := _junkFunc ; in any event, release the user function object

		if not (_hWinEventHook:=WinEventHook._map[_idProcess, _event]) { ; if the hook instance is not yet listed...
			_hWinEventHook := DllCall("SetWinEventHook"
									, "UInt", _event
									, "UInt", _event
									, "Ptr", 0x0
									, "Ptr", WinEventHook._callback
									, "UInt", _idProcess
									, "UInt", 0x0
									, "UInt", 0x0) ; https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwineventhook
			if not (_hWinEventHook) {
				throw Exception("Could not set the event hook function.", _offset)
			return
			}
			WinEventHook._map[_idProcess, _event] := _hWinEventHook
			WinEventHook._instances[_hWinEventHook] := {idProcess: _idProcess, event: _event} ; 'cross-referencing'
		}
		if (_range) { ; if influxes of calls need to be buffer as such, as influxes...
			_cbObject := new WinEventHook._TimedCallback(_hWinEventHook)
			_cbObject.delegate := _delegate
			_cbObject.range := _range
			WinEventHook._instances[_hWinEventHook].sieve[_hwnd] := _cbObject
		} else WinEventHook._instances[_hWinEventHook].sieve[_hwnd] := _delegate

	return _hWinEventHook
	}

	setForProcess(_idProcess, _event, _delegate, _p*) {
		if (_idProcess <> 0) {
			Process, Exist, % (_idProcess+0 <> "") ? _idProcess : 0 ; otherwise, if the PIDOrName parameter is blank, the script's own PID is retrieved - https://www.autohotkey.com/docs/commands/Process.htm#Exist
			if not (ErrorLevel) {
				throw Exception("The process could not be found.", -1, (_idProcess = "") ? """""" : _idProcess)
			return
			}
		} else return new WinEventHook(_idProcess, _event, _delegate, WinEventHook.HANDLE_IDPROCESS, -2, _p*)
	}
	setForId(_hwnd, _event, _delegate, _p*) {
		local _idProcess := ""
		DllCall("User32.dll\GetWindowThreadProcessId", "Ptr", _hwnd, "UIntP", _idProcess, "UInt")
		if not (_idProcess) {
			throw Exception("Could not retrieve the identifier of the process that created the window.", -1)
		return
		} else return new WinEventHook(_idProcess, _event, _delegate, Format("{1:u}", _hwnd), -2, _p*)
	}
	unset(_hWinEventHook) {
		local _unsetCount, _instance
		_unsetCount := (_instance:=WinEventHook._instances[_hWinEventHook]) ? WinEventHook._unset(_instance.idProcess, _instance.event) : 0
	return _unsetCount
	}

	unsetByProcess(_idProcess) {
		local _event, _hWinEventHook, _unsetCount
		for _event, _hWinEventHook in ObjClone(WinEventHook._map[_idProcess]), _unsetCount := 0
			ErrorLevel += !_unsetCount += WinEventHook._unset(_idProcess, _event)
		return _unsetCount
	}
	unsetById(_hwnd) {
		local _h, _hWinEventHook, _obj, _unsetCount, _sieve
		if not (_h:=Format("{1:u}", _hwnd)) { ; i.e. also if _hwnd = WinEventHook.HANDLE_IDPROCESS
			throw Exception("Invalid handle.", -1, (_hwnd = "") ? """""" : _hwnd)
		return
		}
		_hwnd := _h
		for _hWinEventHook, _obj in ObjClone(WinEventHook._instances), _unsetCount := 0 {
			if (ObjHasKey(_obj.sieve, _hwnd)) {
				_sieve := WinEventHook._instances[_hWinEventHook].sieve, ObjDelete(_sieve, _hwnd)
				if not (ObjCount(_sieve)) {
					ErrorLevel += !_unsetCount += WinEventHook._unset(_obj.idProcess, _obj.event)
				}
			}
		}
		return _unsetCount
	}
	unsetByEvent(_eventNum) {
		local _idProcess, _obj, _unsetCount, _event
		for _idProcess, _obj in ObjClone(WinEventHook._map), _unsetCount := 0 {
			for _event in _obj {
				if (_event = _eventNum) {
					ErrorLevel += !_unsetCount += WinEventHook._unset(_idProcess, _event)
				}
			}
		}
		return _unsetCount
	}

	unsetAll() {
		local _idProcess, _obj, _unsetCount, _event
		for _idProcess, _obj in ObjClone(WinEventHook._map), _unsetCount := 0
			for _event in _obj
				ErrorLevel += !_unsetCount += WinEventHook._unset(_idProcess, _event)
		return _unsetCount
	}
		_unset(_idProcess, _event) {
			local _hWinEventHook, _r
			_hWinEventHook := ObjDelete(WinEventHook._map[_idProcess], _event)
			(!ObjCount(WinEventHook._map[_idProcess]) && ObjDelete(WinEventHook._map, _idProcess))
			_r := DllCall("UnhookWinEvent", "Ptr", _hWinEventHook) ; https://docs.microsoft.com/fr-fr/windows/desktop/api/winuser/nf-winuser-unhookwinevent
			ObjDelete(WinEventHook._instances, _hWinEventHook)
			if (ObjHasKey(WinEventHook._TimedCallback.instances, _hWinEventHook)) ; if a '_TimedCallback' instance is associated with this hook instance...
				ObjDelete(WinEventHook._TimedCallback.instances, _hWinEventHook) ; release the function object (actually, the instance's own __Delete meta-function will be called)
		return _r
		}

		_dispose(_params*) {
		static _ := OnExit(ObjBindMethod(WinEventHook, "_dispose"))
		static _preventExit := 1
		return not _preventExit, WinEventHook.unsetAll()
		}

	_hookFunction(_event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime) {

		local _hWinEventHook, _enum, _handle, _delegate

		(_enum:=ObjNewEnum(WinEventHook._instances[ _hWinEventHook:=this ].sieve)).next(_handle, _delegate)
		if (_handle <> WinEventHook.HANDLE_IDPROCESS) { ; unsigned integers (i.e. hWnd, if any) necessarily appear before "" (HANDLE_IDPROCESS) in an enumeration
			Loop {
				if (_handle = _hwnd) {
					%_delegate%(_hWinEventHook, _event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime)
				return ;  'capture' the event: do not go all the way up on the process
				}
			} Until not (_enum[_handle, _delegate])
			if (_handle <> WinEventHook.HANDLE_IDPROCESS)
				return
		}
		%_delegate%(_hWinEventHook, _event, _hwnd, _idObject, _idChild, _dwEventThread, _dwmsEventTime)

	}

}