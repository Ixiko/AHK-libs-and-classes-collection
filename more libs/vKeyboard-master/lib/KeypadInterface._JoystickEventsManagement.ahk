Class _JoystickEventsManagement {
	_onConnection(_keypadInst, _port, _joystick) {
		local _DPAd, _thumbstickL, _thumbstickR, _classPath, _className, _obj
		if (_joystick.hasPOV && _joystick.hasZRAxes) {
			_DPAd := _joystick.DPad
			_thumbstickL := _joystick.thumbsticks.L, _thumbstickR := _joystick.thumbsticks.R
			_classPath := StrSplit(this.__Class, "."), _className := _classPath.removeAt(1)
			_obj := (_classPath.count() > 0) ? %_className%[_classPath*] : %_className%
			_DPad.onEvent(ObjBindMethod(_obj, "_dPadEventMonitor", _keypadInst))
			_thumbstickL.onEvent(ObjBindMethod(_obj, "_thumbstickLEventMonitor", _keypadInst))
			_thumbstickR.onEvent(ObjBindMethod(_obj, "_thumbstickREventMonitor", _keypadInst))
				if (_keypadInst._hostWindow.isVisible()) {
					_joystick.poll(35, 120)
					; _joystick.poll(35, 120, 450)
				}
		}
	}
	_onDisconnection(_keypadInst, _port, _joystick) {
		_joystick.poll()
	}
	_dPadEventMonitor(_keypadInst, _joystick, _direction) {
		local
		static _t := true
		static _dPadSensitivity := 150
		for _k, _v in _keypadInst._hkEnterObject
			_v._precipitate()
		if (_t) {
			_t := false
			sleep % _dPadSensitivity
			_keypadInst._setFocusedKeyRelative(_direction)
			_t := true
		}
	}
	_thumbstickLEventMonitor(_keypadInst, _joystick, _δX, _δY) {
		local
		static _thumbstickLSensitivity := 40
		SetWinDelay, 1
		if (_δX) {
			; WinGetPos, _x,,,, A
			WinGetPos, _x,,,, % "ahk_id " . _keypadInst.hostWindow.HWND
			(_x += _thumbstickLSensitivity * ((_δX > 0) ? 1 : -1))
			WinMove, % "ahk_id " . _keypadInst.hostWindow.HWND,, % _x
		}
		if (_δY) {
			; WinGetPos,, _y,,, A
			WinGetPos,, _y,,, % "ahk_id " . _keypadInst.hostWindow.HWND
			(_y += _thumbstickLSensitivity * ((_δY > 0) ? 1 : -1))
			WinMove, % "ahk_id " . _keypadInst.hostWindow.HWND,,, % _y
		}
	} ; ++++++++
}