#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input

CoordMode, ToolTip, Screen
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_LineFile%\..\..\Hotkey.ahk

; MsgBox % arrToString(Hotkey.getDefaultCriteria())

hk0 := new Hotkey("Joy4"), hk0.onEvent("myFunc")

Hotkey.setGroup("testGroup")
Hotkey.IfWinActive("ahk_class Notepad")
; Hotkey.IfWinNotExist("ahk_class Notepad")
	; MsgBox % arrToString(Hotkey.getDefaultCriteria())
	instance := new myClass()
	hk := new Hotkey("a"), hk.onEvent(ObjBindMethod(instance, "method"))
	hk := new Hotkey("a", false), hk.onEvent("myFunc", ObjBindMethod(instance, "method"))

Hotkey.InTheEventNot("check")
	hk2 := new Hotkey("Joy3"), hk2.onEvent(ObjBindMethod(instance, "method2"), "myOtherFunc")
Hotkey.setGroup()
return

^+e::Hotkey.enableAll(), ListHotkeys()
^+d::Hotkey.disableAll(), ListHotkeys()
^!e::
	enabledCount := Hotkey.enableAll("testGroup")
	ToolTip % enabledCount "," ErrorLevel, 0, 0, 10
	ListHotkeys()
return
^!d::
	disabledCount := Hotkey.disableAll("testGroup")
	ToolTip % disabledCount "," ErrorLevel, 0, 0, 10
	ListHotkeys()
return

!p::Pause
!d::MsgBox % hk.disable()
!e::MsgBox % hk.enable()
!t::MsgBox % hk.toggle()
!c::MsgBox % arrToString(hk.getCriteria())
!i::MsgBox % hk.getKeyName() "," hk.isEnabled()
!x::hk.delete(), hk := ""

arrToString(_arr, _delimiter:="|") {
	for _k, _v in _arr, _string := ""
		_string .= _v . _delimiter
return _string := RTrim(_string, _delimiter)
}

check(_buttonName) {
	ToolTip % _buttonName
return WinActive("ahk_exe firefox.exe")
}

ListHotkeys() {
ListHotkeys
}

Class myClass {
	method(_inst, _state:="") {
	static _i := 0
	ToolTip % A_ThisFunc "`r`n" ++_i "`r`n" _inst.getKeyName() "`r`n" _state, 100, 0, 1
	}
	method2(_inst, _state:="") {
	static _i := 0
	ToolTip % A_ThisFunc "`r`n" ++_i "`r`n" _inst.getKeyName() "`r`n" _state, 200, 0, 2
	}
}
myFunc(_inst, _state:="") {
static _i := 0
	; Critical 110
	; DllCall("Sleep", UInt, 100)
	sleep, 210
	ToolTip % A_ThisFunc "`r`n: " ++_i "`r`n" _inst.getKeyName() "`r`n" _state, 300, 0, 3
}
myOtherFunc(_inst, _state:="") {
static _i := 0
	ToolTip % A_ThisFunc "`r`n" ++_i "`r`n" _inst.getKeyName() "`r`n" _state, 400, 0, 4
}