#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input

CoordMode, ToolTip, Screen
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_LineFile%\..\..\Joystick.ahk

global J := new Joystick.Device(1)
; global J2 := new Joystick.Device(2)
global instance := new MyClass()
J.Events.onConnection("Joystick_onConnection", ObjBindMethod(instance, "connection"))
; J2.Events.onConnection("Joystick_onConnection")
J.Events.onDisconnection(Func("Joystick_onDisconnection"))
; J2.Events.onDisconnection(Func("Joystick_onDisconnection"))
return

!x::ExitApp

!s::J.Events.notify(true) ; , J2.Events.notify(true)
!u::J.Events.notify(false) ; , J2.Events.notify(true)

#If IsObject(J)
	!j::MsgBox % J.name
				. "`r`n" J.buttons.count()
				. "`r`n" J.info
				. "`r`n" J.axes
	!i::(J.dPad && J.dPad.invertAxis:=!J.dPad.invertAxis)
	^!i::(J.thumbsticks.L && J.thumbsticks.L.invertAxis:=!J.thumbsticks.L.invertAxis)
#If


Class MyClass {
	connection(_port, _joystick) {
		MsgBox % A_ThisFunc " > " _port ": " _joystick.info
	}
	eventMonitor(_joystick, _direction) {
		ToolTip % A_ThisFunc " > " _joystick.port ": " _direction, 0, 100, 1
	}
	__Delete() {
		MsgBox % A_ThisFunc
	}
}

Joystick_onConnection(_port, _joystick) {
	ToolTip % A_ThisFunc " > " _port ": " _joystick.info " | " _joystick.info
	if (_joystick.hasPOV)
		_joystick.DPad.onEvent(ObjBindMethod(instance, "eventMonitor"), "J_DPadEventMonitor"), _joystick.DPad.watch(120)
	for _side, _thumbstick in _joystick.thumbsticks {
		_thumbstick.onEvent("J_thumbstick" . _side . "EventMonitor"), _thumbstick.watch(70)
	}
}
Joystick_onDisconnection(_port, _joystick) {
	MsgBox % A_ThisFunc " > "_port ": " _joystick.info
	_joystick.thumbsticks.L.watch()
	_joystick.thumbsticks.R.watch()
	_joystick.DPad.watch()
}

J_dPadEventMonitor(_joystick, _direction) {
	ToolTip % A_ThisFunc " > " _joystick.port ": " _direction, 0, 200, 2
}
J_thumbstickLEventMonitor(_joystick, _δX, _δY) {
	static _o := {Left: [ "X", -1 ], Up: [ "Y", -1 ], Right: [ "X", 1 ], Down: [ "Y", 1 ]}
	static _i := 0
	SetWinDelay, -1
	if (_δX) {
		WinGetPos, _x, _y,,, A
		_v := (_w:=_o[_δX > 0 ? "Right" : "Left"]).1, _%_v% += 40*_w.2
		WinMove, A,, % _x, _y
	}
	if (_δY) {
		WinGetPos, _x, _y,,, A
		_v:=(_w:=_o[_δY > 0 ? "Down" : "Up"]).1, _%_v% += 40*_w.2
		WinMove, A,, % _x, _y
	}
}
J_thumbstickREventMonitor(_joystick, _δX, _δY) {
ToolTip % _joystick.port ": " _δX . "," . _δY, 0, 300, 3
}