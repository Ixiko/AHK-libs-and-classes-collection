Class Joystick { ; example: https://gist.github.com/A-AhkUser/4627f2014352650115ad0cc4fa47ac51
; cf. https://autohotkey.com/docs/scripts/JoystickTest.htm
; cf. https://autohotkey.com/docs/scripts/JoystickMouse.htm

	connect(_port:=0) {

		Loop % !(_port) {
			Loop 16 {
				if (GetKeyState(a_index . "JoyX")) {
					this.name := GetKeyState((_prefix:=this._prefix:=(this.port:=a_index) . "Joy") . "Name")
				break, 2
				}
			}
			return false
		}

		(_buttons:=this.buttons:=[])[ GetKeyState(_prefix . "Buttons") ] := ""
		Loop % _buttons.length()
			_buttons[ a_index ] := _prefix . a_index

		this.thumbsticks := {}, this.thumbsticks.L := new Joystick.Thumbstick(this, "X", "Y")

		_info := this.info := GetKeyState(_prefix . "Info")
		if (this.hasPOV:=(InStr(_info, "P") && InStr(_info, "D")))
			this.POV := _prefix . "POV", this.dPad := new Joystick.DPad(this)
		if (this.hasZRAxis:=(InStr(_info, "Z") && InStr(_info, "R")))
			this.thumbsticks.R := new Joystick.Thumbstick(this, "Z", "R")

	return this.connected
	}

	_isConnected := false
	connected {
		set {
		static _callbacks := {(true): "__connection", (false): "__disconnected"}
			((_f:=this[ _callbacks[ this._isConnected:=value ] ]) && _f.call(this))
		return value
		}
		get {
		return ((_state:=(GetKeyState(this.X) <> "")) <> this._isConnected) ? this.connected:=_state : _state
		}
	}
	onConnection(_callback) {
	return Bound.Func._setCallback(this, "__connection", _callback)
	}
	onDisconnected(_callback) {
	return Bound.Func._setCallback(this, "__disconnected", _callback)
	}

		dispose() {
		for _axis, _thumbstick in this.thumbsticks
			_thumbstick.dispose(), _thumbstick := ""
		this.thumbsticks := ""
		if (this.hasPOV)
			this.dPad.dispose(), this.dPad := ""
		this.__connection := this.__disconnected := ""
		}

	Class Axes {

		eventMonitor := ""

		__New(_device, _params*) {
		this._device := _device, this._watcher := new Bound.Func.Iterator(this, "_spot", _params*)
		}

		setEventMonitor(_eventMonitor) {
		return Bound.Func._setCallback(this, "eventMonitor", _eventMonitor)
		}
		watch(_period:="Off") {
		if (this.eventMonitor)
			return true, this._watcher.setPeriod(_period)
		return false
		}
		dispose() {
		this.watch(), this._watcher.delete(), this.eventMonitor := ""
		}

	}
	Class DPad extends Joystick.Axes {

		__New(_device) {
		base.__New(_device, _device["POV"]:=_device._prefix . "POV")
		this._keyToHoldDown := [], this.invertAxis := false
		}
		_spot(_POV) {
		_listLines := A_ListLines
		ListLines, Off
		static _keyToHoldDown

			if not (this._device.connected) {
				this._watcher.setPeriod("Off")
			return
			}
			if ((_POV:=GetKeyState(_POV)) < 0)
		return
			else if _POV between 22500 and 31500
				_keyToHoldDown := this._keyToHoldDown.1
			else if _POV between 4500 and 13500
				_keyToHoldDown := this._keyToHoldDown.2
			else if _POV between 13501 and 22500
				_keyToHoldDown := this._keyToHoldDown.3
			else _keyToHoldDown := this._keyToHoldDown.4

			ListLines % _listLines ? "On" : "Off"

			this.eventMonitor.call(this._device, _keyToHoldDown)

		}
		invertAxis {
			set {
				this._keyToHoldDown := (this._invertAxis:=value) ? StrSplit("Right|Left|Up|Down", "|") : StrSplit("Left|Right|Down|Up", "|")
			return value
			}
			get {
			return this._invertAxis
			}
		}

	}
	Class Thumbstick extends Joystick.Axes {

		__New(_device, _axis1, _axis2, _threshold:=17, _multiplier:=0.30) {
			this.axes := [_axis1, _axis2]
			base.__New(_device, _device[_axis1]:=_device._prefix . _axis1, _device[_axis2]:=_device._prefix . _axis2)
			this.threshold := _threshold, this.multiplier := _multiplier
			this.invertAxis := false
		}
		_spot(_XOrZ, _YOrR) {
		_listLines := A_ListLines
		ListLines, Off
		static _δX, _δY

			if not (this._device.connected) {
				this._watcher.setPeriod("Off")
			return
			}
			_format := A_FormatFloat
			SetFormat, float, 03

			_XOrZ := GetKeyState(_XOrZ), _YOrR := GetKeyState(_YOrR)

			_u := this._thresholdUpper, _l := this._thresholdLower
			_boolean := false

			if (_XOrZ > _u) {
				_boolean := true, _δX := (_XOrZ - _u) * this.multiplier
			} else if (_XOrZ < _l) {
				_boolean := true, _δX := (_XOrZ - _l) * this.multiplier
			} else _δX := 0
			if (_YOrR > _u) {
				_boolean := true, _δY := (_YOrR - _u) * this.multiplier
			} else if (_YOrR < _l) {
				_boolean := true, _δY := (_YOrR - _l) * this.multiplier
			} else _δY := 0

			ListLines % _listLines ? "On" : "Off"

			if (_boolean) {
				this.eventMonitor.call(this._device, this._δXm * _δX, this._δYm * _δY)
			}
			SetFormat, float, % _format

		}
		invertAxis {
			set {
				this._δXm := this._δYm := (this._invertAxis:=value) ? -1 : 1
			return value
			}
			get {
			return this._invertAxis
			}
		}

		threshold {
			set {
			return this._threshold := value, this._thresholdLower := 50 - value, this._thresholdUpper := 50 + value
			}
			get {
			return this._threshold
			}
		}

	}

}