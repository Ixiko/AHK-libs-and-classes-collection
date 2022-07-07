Class Joystick {

	; note: requires JoystickDeviceManagement.ahk
	; cf. https://www.autohotkey.com/docs/KeyList.htm#Joystick
	; cf. https://www.autohotkey.com/docs/misc/RemapJoystick.htm
	; cf. https://autohotkey.com/docs/scripts/JoystickTest.htm
	; cf. https://autohotkey.com/docs/scripts/JoystickMouse.htm

	Class DeviceManagement {
		static _instances := []
		static _PORTS := 8
		_notify := false
		__New(_joystick) {
			this._lastFoundState := (GetKeyState(_joystick.port . "JoyX") && GetKeyState(_joystick.port . "JoyY"))
			this._device := _joystick
			this._instances.push(this)
			this._monitorWatchdogMessages := true
		}
		_dispose(_exitReason_:="", _exitCode_:="") {
			static _ := OnExit(ObjBindMethod(Joystick.DeviceManagement, "_dispose"))
			local
			global Joystick
			OnMessage(0x8000, this.__Class . "._WM_APP", 0)
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if (WinExist("ahk_id " . this._WM_APP()))
				WinClose
			DetectHiddenWindows % _detectHiddenWindows
			for _timestamp, _instance in this._instances {
				_instance._monitorWatchdogMessages := false
				(IsObject(_instance._device) && _instance._device.dispose())
			}
		return 0
		}
		_monitorWatchdogMessages_ := false
		_monitorWatchdogMessages {
			set {
				OnMessage(0x8001, ObjBindMethod(this, "_WM_APPPLUS"), value:=!!value)
				this._monitorWatchdogMessages_ := value
			}
			get {
			return this._monitorWatchdogMessages_
			}
		}
			_WM_APP(_params*) {
			static _lastFoundId := 0x0
				if not (_params.count())
					return _lastFoundId
				_lastFoundId := _params.1 ; _lParam
			}
			_WM_APPPLUS(_params*) {
				local
				; Critical ; ++++++++++
				_device := this._device, _port := _device.port
				_lastFoundState := this._lastFoundState
				_wParam := Format("{:0" . this._PORTS . "}", _params.1)
				if (_params.count()) {
					this._lastFoundState := StrSplit(_wParam)[_port]
				}
				if (_toggle:=this._notify) {
					if (this._lastFoundState <> _lastFoundState) {
						if not (_lastFoundState) {
							if (__connection:=this.__connection) {
								(!_device.hasKey("info") && _device:=_device._wrap())
								_fn := this.test.bind(this, __connection, _port, _device)
								SetTimer % _fn, -1
							}
						} else {
							if (__disconnection:=this.__disconnection) {
								_fn := this.test.bind(this, __disconnection, _port, _device)
								SetTimer % _fn, -1
							}
						}
					}
				}
				; Critical, Off
			}
			test(_fn, _port, _device) {
				_fn.call(_port, _device)
			}
		notify(_boolean) {
			this._notify := !!_boolean
		}
		__disconnection := ""
		onDisconnection(_args*) {
			local
			global Joystick
			return Joystick._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
		}
		__connection := ""
		onConnection(_args*) {
			local
			global Joystick
			return Joystick._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
		}

		_runWatchdog() {
			local
			global Joystick
			static _ := Joystick.DeviceManagement._runWatchdog()
			OnMessage(0x8000, "Joystick.DeviceManagement._WM_APP", 1)
			SplitPath, % A_LineFile,, _directory
			try run % _directory . "\JoystickDeviceManagement.ahk" A_Space A_ScriptHwnd ; <<< for non-complied scripts
			catch _exception {
				throw Exception("Failed to lunch the JoystickDeviceManagement service. The script will exit.", -1, _exception.extra)
			; ExitApp
			}
			sleep, 300
		}

	} ; ++++++++++

	Class Device {
		__New(_port) {
			local
			global Joystick
			this.port := _port
		return this, this._Events := new Joystick.DeviceManagement(this)
		} ; ++++++++++
			_wrap() {
				this.name := GetKeyState((_prefix:=this._prefix:=(this.port) . "Joy") . "Name")
				_buttons := this.buttons:=[], _count := GetKeyState(_prefix . "Buttons")
				Loop % _count
					_buttons[ a_index ] := _prefix . a_index
				_info := this.info := GetKeyState(_prefix . "Info")
				if (this.hasPOV:=InStr(_info, "P")) ; <<< and InStr(_info, "D")
					this.POV := _prefix . "POV", this.DPad := new Joystick.Device.DPad(this, this.POV)
				this.axes := GetKeyState(_prefix . "Axes"), this.thumbsticks := {}
				this.X := this._prefix . "X", this.Y := this._prefix . "Y"
				this.thumbsticks.L := new Joystick.Device.Thumbstick(this, this.X, this.Y)
				if (this.hasZRAxes:=(InStr(_info, "Z") && InStr(_info, "R"))) {
					this.Z := this._prefix . "Z", this.R := this._prefix . "R"
					this.thumbsticks.R := new Joystick.Device.Thumbstick(this, this.Z, this.R)
				}
				return this
			} ; ++++++++++
		Events {
			set {
			return this._Events
			}
			get {
			return this._Events
			}
		} ; ++++++++++
			dispose() {
				local
				_Events := this._Events, _Events.notify(false)
				if not (_Events._device)
					return
				(this.hasPOV && (this.DPad.dispose()))
				for _direction, _thumbstick in this.thumbsticks
					_thumbstick.dispose()
				_Events._device := ""
				_Events.onConnection(), _Events.onDisconnection()
			} ; ++++++++++
			__Delete() {
				; MsgBox % A_ThisFunc
			}

		Class _Directional {
			__New(_device) {
				this.invertAxis := false
			}
			__event := ""
			onEvent(_args*) {
				local
				global Joystick
				return Joystick._Callbacks._on(this, StrSplit(A_ThisFunc, ".").pop(), _args*)
			}
			watch(_period:="Off") {
				local
				if (this.__event && this._fn) {
					_fn := this._fn
					SetTimer % _fn, % _period
				}
			}
			dispose() {
				local
				this.onEvent()
				if (_fn:=this._fn) {
					SetTimer % _fn, Off
					SetTimer % _fn, Delete
					this._fn := ""
				}
			}
		}
		Class DPad extends Joystick.Device._Directional {
			__New(_device, _POV) {
				base.__New(_device)
				this._fn := this._spot.bind(this, _device, _POV)
				sleep, 10
			}
			_spot(_joystick, _POV) { ; cf also: https://www.autohotkey.com/docs/misc/RemapJoystick.htm#joystick-pov-hat
			static _keyToHoldDown, _listLines
			_listLines := A_ListLines
			ListLines, Off
				if ((_POV:=GetKeyState(_POV)) < 0)
			return
				else if _POV between 22500 and 31500
					_keyToHoldDown := this._keyToHoldDown.1
				else if _POV between 4500 and 13500
					_keyToHoldDown := this._keyToHoldDown.2
				else if _POV between 13501 and 22500
					_keyToHoldDown := this._keyToHoldDown.3
				else _keyToHoldDown := this._keyToHoldDown.4
				this.__event.call(_joystick, _keyToHoldDown)
			ListLines % _listLines ? "On" : "Off"
			}
			invertAxis {
				set {
				return value, this._keyToHoldDown := (this._invertAxis:=value) ? StrSplit("Right|Left|Up|Down", "|") : StrSplit("Left|Right|Down|Up", "|")
				}
				get {
				return this._invertAxis
				}
			}
			__Delete() {
				; MsgBox % A_ThisFunc
			}
		}
		Class Thumbstick extends Joystick.Device._Directional {

			__New(_device, _directional1, _directional2, _threshold:=17, _multiplier:=0.30) {
				base.__New(_device)
				this._fn := this._spot.bind(this, _device, _directional1, _directional2)
				sleep, 10
				this.threshold := _threshold, this.multiplier := _multiplier
			}
			_spot(_joystick, _XOrZ, _YOrR) { ; cf also: https://www.autohotkey.com/docs/scripts/JoystickMouse.htm
			static _δX, _δY, _listLines, _format, _u, _l, _boolean
			_listLines := A_ListLines
			ListLines, Off
				_format := A_FormatFloat
				SetFormat, float, 03
				_XOrZ := GetKeyState(_XOrZ), _YOrR := GetKeyState(_YOrR)
				if (_XOrZ . _YOrR = "")
					return
				_u := this._thresholdUpper, _l := this._thresholdLower
				_boolean := false
				if (_XOrZ > _u) {
					_boolean := true, _δX := (_XOrZ - _u) * this._multiplier
				} else if (_XOrZ < _l) {
					_boolean := true, _δX := (_XOrZ - _l) * this._multiplier
				} else _δX := 0
				if (_YOrR > _u) {
					_boolean := true, _δY := (_YOrR - _u) * this._multiplier
				} else if (_YOrR < _l) {
					_boolean := true, _δY := (_YOrR - _l) * this._multiplier
				} else _δY := 0
				_δX := this._δXm * _δX, _δY := this._δYm * _δY
				SetFormat, float, % _format
				if (_boolean) {
					this.__event.call(_joystick, _δX, _δY)
				}
				ListLines % _listLines ? "On" : "Off" ; ++++
			}
			invertAxis {
				set {
				return value, this._δXm := this._δYm := (this._invertAxis:=value) ? -1 : 1
				}
				get {
				return this._invertAxis
				}
			}
			threshold { ; cf. https://www.autohotkey.com/docs/scripts/JoystickMouse.htm
				set {
				return this._threshold := value, this._thresholdLower := 50 - value, this._thresholdUpper := 50 + value
				}
				get {
				return this._threshold
				}
			}
			multiplier {
				set {
				return this._multiplier := value
				}
				get {
				return this._multiplier
				}
			}
			__Delete() {
				; MsgBox % A_ThisFunc
			}
		}
	}
	Class _Callbacks {
		chain := []
		__New(_args*) {
			local
			if not (ObjCount(_args))
				return this
			for _i, _fn in _args {
				if not (IsObject(_fn) || _args[_i]:=Func(_fn)) {
					throw Exception("Invalid callback.", -1)
				; return
				}
			}
			for _i, _fn in _args
				this.chain.push(_fn)
		}
		call(_args*) {
			local
			for _, _fn in this.chain
				%_fn%(_args*)
		}
		_on(_inst, _callee, _args*) {
			local _functor, _exception, _classPath, _className, _obj
			_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
			_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
			try _functor:=new _obj(_args*)
			catch _exception {
				throw Exception(_exception.message, -1, _exception.extra)
			; return
			}
			_inst["__" . LTrim(_callee, "on")] := _functor
		}
	}
}
