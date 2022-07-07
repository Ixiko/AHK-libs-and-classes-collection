Class KeypadInterface extends Keypad {

	_joystick := ""
	_onConnectionFn := ObjBindMethod(this._JoystickEventsManagement, "_onConnection", this)
	_onDisconnectionFn := ObjBindMethod(this._JoystickEventsManagement, "_onDisconnection", this)

	setHotkeys(_obj, _joystickPort:=1, _joyModifier:="Joy5") {
		local
		global Hotkey
		this._unsetHotkeys(), this._setDirectionHotkeys(), this._setClickHotkey()
		_lastFoundGroup := Hotkey.setGroup(), Hotkey.setGroup(this._timestamp+4)
		try {
			_obj_ := this._Hotkeys.getSettings(_obj, _joystickPort)
			this._setHkPriority2(this._BasicOperations, _obj_, _joystickPort, _joyModifier)
			this._setHkPriority1(this._BasicOperations, _obj_, _joystickPort, _joyModifier)
			this._setHkPriority0(this._BasicOperations, _obj_, _joystickPort, _joyModifier)
		} catch _exception {
			this._unsetHotkeys_()
			throw Exception(_exception.message, -1, _exception.extra)
		} finally Hotkey.setGroup(_lastFoundGroup)
		if (_joystickPort) {
			this._joystick := new this._JoystickDevice(_joystickPort)
			this._joystick.Events.onConnection(this._onConnectionFn)
			this._joystick.Events.onDisconnection(this._onDisconnectionFn)
			this._joystick.Events.notify(true)
		}
	}
		_setHkPriority2(_basicOperationsWrapper, ByRef _obj_, _joystickPort, _joyModifier:="Joy5") {
			local
			global Hotkey
			_subWindow := _obj_.window
			_kbShowHide := _subWindow.keyboard.delete("showHide"), _joyShowHide := _subWindow.joystick.delete("showHide")
			this._autocomplete._setHotkeys(_basicOperationsWrapper, _obj_.autocomplete, _joystickPort, _joyModifier)
			Hotkey.IfWinActive()
				((_kbShowHide <> "") && new Hotkey(_kbShowHide).onEvent(this.showHide.bind(this)))
				((_joyShowHide <> "") && new Hotkey(_joyShowHide).onEvent(this.showHide.bind(this)))
		}
		_setHkPriority1(_basicOperationsWrapper, ByRef _obj_, _joystickPort, _joyModifier:="Joy5") {
			local
			global Hotkey
			_subKeypadKb := _obj_.keypad.keyboard, _subKeypadJoy := _obj_.keypad.joystick
			_kbPressKey := _subKeypadKb.delete("pressKey"), _joyPressKey := _subKeypadJoy.delete("pressKey")
			_kbAltReset := _subKeypadKb.delete("altReset"), _joyAltReset := _subKeypadJoy.delete("altReset")
			Hotkey.IfWinActive("ahk_id " . this._hostWindow.HWND)
			for _procName, _keyName in _subKeypadKb {
				new Hotkey(_keyName).onEvent(_basicOperationsWrapper[_procName . "Proc"].bind("", this))
			}
			for _k, _v in _subKeypadJoy, _obj := {}
				_obj[ Trim(_v) ] := _k
			for _keyName, _procName in _obj {
				_keyName := RegExReplace(_keyName:=Trim(_keyName), "i)^!(?=\d{1,2}Joy\d{1,2}$)", "", _count)
				_params := [ this._hostWindow.HWND ], _params.insertAt(2, (_count) ? _joystickPort . _joyModifier : "")
				Hotkey.InTheEvent(this._shouldFireAlt.bind(_params*))
					new Hotkey(_keyName).onEvent(_basicOperationsWrapper[_procName . "Proc"].bind("", this))
			}
			_subKeypadKb.pressKey := _kbPressKey, _subKeypadJoy.pressKey := _joyPressKey
			_subKeypadKb.altReset := _kbAltReset, _subKeypadJoy.altReset := _joyAltReset
		}
			_shouldFireAlt(_modifier, _thisHotkey) {
				return (WinActive("ahk_id " . _hHostWindow:=this) && ((_modifier = "") || GetKeyState(_modifier)))
			}
		_setHkPriority0(_basicOperationsWrapper, ByRef _obj_, _joystickPort, _joyModifier:="Joy5") {
			local
			_subKeypadKb := _obj_.keypad.keyboard, _subKeypadJoy := _obj_.keypad.joystick
			_kbPressKey := _subKeypadKb.delete("pressKey"), _joyPressKey := _subKeypadJoy.delete("pressKey")
			_kbAltReset := _subKeypadKb.delete("altReset"), _joyAltReset := _subKeypadJoy.delete("altReset")
			((_kbPressKey <> "") && this._setEnterHotkey(_kbPressKey)), ((_joyPressKey <> "") && this._setEnterHotkey(_joyPressKey))
			((_kbAltReset <> "") && this._setEscapeHotkey(_kbAltReset)), ((_joyAltReset <> "") && this._setEscapeHotkey(_joyAltReset))
		}
	_unsetHotkeys() {
		base._unsetHotkeys()
		this._unsetHotkeys_()
	}
		_unsetHotkeys_() {
			local
			global Hotkey
			this._autocomplete._unsetHotkeys()
			try Hotkey.deleteAll(this._timestamp+4)
		}

	showHide(_boolean:="") {
		local
		_r := base.showHide(_boolean)
		if (_r = -1)
			return
		if (this._joystick.info) {
			if (_r) {
				this._joystick.poll(35, 120)
			} else this._joystick.poll()
		}
	}
	_submit(_hideOnSubmit:=true, _resetOnSubmit:=false, _callback:=false) {
		base._submit(_hideOnSubmit, _resetOnSubmit, _callback)
		if (this._joystick.info) {
			if not (this.hostWindow.isVisible())
				this._joystick.poll()
		}
	}

	dispose() {
		this._unsetHotkeys()
		this._onConnectionFn := this._onDisconnectionFn := ""
		if (this._joystick.info)
			this._joystick.dispose() ; ++++++++++
		base.dispose()
	} ; +++++++
	__Delete() {
		; MsgBox % A_ThisFunc
	}

	Class _JoystickDevice extends Joystick.Device {
		poll(_dPad:="Off", _lThumbstick:="Off", _rThumbstick:="Off") {
			this.dPad.watch(_dPad)
			this.thumbsticks.L.watch(_lThumbstick)
			this.thumbsticks.R.watch(_rThumbstick)
		} ; ++++++++++
	}
	#Include %A_LineFile%\..\KeypadInterface._JoystickEventsManagement.ahk
	Class _Hotkeys {
		getSettings(_obj, _joystickPort) {
			local
			for _m, _v in _hkSettings:=new this.Settings() {
				if (!_joystickPort)
					_hkSettings[_m].delete("joystick")
				else for _kprime, _vprime in _v.joystick {
					_v.joystick[_kprime] := StrReplace(_vprime, "Joy", _joystickPort . "Joy")
				}
			}
			for _m, _v in _hkSettings {
			; autocomplete, keypad, window
				if (_obj.hasKey(_m)) {
					for _n, _w in _v {
					; keyboard, joystick
						if (_obj[_m].hasKey(_n)) {
							_subHk := _hkSettings[_m, _n], _subObj := _obj[_m, _n]
							for _kprime, _vprime in _w {
								if (_obj[_m, _n].hasKey(_kprime)) {
									_subHk[_kprime] := StrReplace(_subObj[_kprime], "Joy", _joystickPort . "Joy")
								}
							}
						}
					}
				}
			}
			return _hkSettings
		}
		#Include %A_LineFile%\..\KeypadInterface._Hotkeys.Settings.ahk
	}
}
#Include %A_LineFile%\..\Keypad.ahk
#Include %A_LineFile%\..\Joystick\Joystick.ahk