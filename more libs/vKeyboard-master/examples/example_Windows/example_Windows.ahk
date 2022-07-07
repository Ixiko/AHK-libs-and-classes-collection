#NoEnv
; #SingleInstance force
#SingleInstance ignore
SetWorkingDir % A_ScriptDir
SendMode, Input

#Warn
DetectHiddenWindows, Off
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

sleep, 100
if not (GetKeyState("JoyX"))
	ExitApp
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) { ; cf. https://www.autohotkey.com/docs/commands/Run.htm#RunAs
    try {
        if (A_IsCompiled)
            run *RunAs "%A_ScriptFullPath%" /restart
        else run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}
#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk
vKeyboard.base._JoystickEventsManagement := JoystickEventsManagement
vKeyboard.base._JoystickDevice := JoystickDevice

vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
eAutocomplete.setSourceFromFile("fr", A_ScriptDir . "\autocompletion\liste_de_mots_francais_frgut.txt") ; create a new autocomplete
; dictionary, called 'fr', from a file's content
vk.autocomplete.source := "fr" ; set the visual keyboard's autocomplete list (can be changed at any time thereafter)
vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json")
; define a 'keymap' (keyboard layout mapping) for future calls of the 'setLayout' method
vk.setLayout("français") ; set the visual keyboard's layout (can be changed at any time thereafter)
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css") ; define a style for future calls
; of the 'setStyle' instance method
vk.setStyle("default") ; set the visual keyboard's style (can be changed at any time thereafter)
vk.autocomplete.bkColor := vk.backgroundColor
vk.autocomplete.fontColor := "FFFFFF"
vk.autocomplete.fontName := "Segoe UI"
vk.autocomplete.fontSize := 14
vk.autocomplete.listbox.bkColor := vk.backgroundColor
vk.autocomplete.listbox.fontColor := "666666"
vk.autocomplete.listbox.fontName := "Segoe UI"
vk.autocomplete.listbox.fontSize := 11
vk.setHotkeys({"window":{"joystick":{"showHide": "Joy11"}}}, 1, "Joy5") ; set up all keyboard/joystick shortcuts
; for the given `vKeyboard` instance, subscribing to the first logical joystick port, using 'Joy5' as joystick 'modifier' key
; and using a custom hotkey for the command 'window.joystick.showHide'
vk.showHide()
vk.fitContent(16, 5, true) ; resize the visual keyboard so that it fits its new content, given a
; font size value (here 16) and a 'padding' value (here 5)
vk.onSubmit(Func("vk_onSubmit")) ; set the 'onSubmit' callback to be the 'vk_onSubmit' function below
OnExit, handleExit ; specifies a callback function or subroutine to run automatically when the script exits
return

handleExit:
	vk.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the visual keyboard instance
ExitApp

^Esc::ExitApp

vk_onSubmit(this, _hLastFoundControl, _input) { ; executed each time the text entered so far is submitted
; if any, '_hLastFoundControl' contains the HWND of the control that had focus and whose focus has been stolen by the
; visual keyboard at the moment this latter was last shown.
; '_input' contains the visual keyboard's text entry field upon submission.
	if (_hLastFoundControl)
		ControlSend,, % "{Text}" . _input, % "ahk_id " . _hLastFoundControl
	else SendInput % "{Text}" . _input
}


IAmInFoxitReaderReadingMode() {
	local
	_w := "", _h := ""
	WinGetPos,,, _w, _h, % "ahk_id " . WinActive("ahk_class classFoxitReader ahk_exe FoxitReader.exe")
return ((_w = A_ScreenWidth) && (_h = A_ScreenHeight))
}

#If  !vk.hostWindow.isVisible() && WinActive("ahk_exe FoxitReader.exe")
	Joy8::send, s ; (FoxitReader) add a sticky note (note: for it to work, you need to enable single-key accelerators.
	; Go to File> Preferences> General,  and check Use single-key accelerators to access tools option in the Basic Tools group.
#If  !vk.hostWindow.isVisible() && IAmInFoxitReaderReadingMode()
	; respectively zoom in and zoom out in FoxitReader (fullscreen)
	Joy9::send, {Ctrl Down}{NumpadSub}{Ctrl Up}
	Joy10::send, {Ctrl Down}{NumpadAdd}{Ctrl Up}
#If !vk.hostWindow.isVisible()
	; release Alt if need be (after you pressed Joy9 or e.g. to quit AltTab mode), otherwise: it closes the current tab (firefox) / it closes the active window (anywhere else)
	Joy1::
		if GetKeyState("Alt")
			send, {Alt Up}
		else {
			send % (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 200) ? ((WinActive("ahk_exe firefox.exe")) ? "{Ctrl Down}w{Ctrl Up}" : "{Alt Down}{F4}{Alt Up}") : "{Esc}"
		}
	return
	; paste
	Joy2::send, {Ctrl Down}v{Ctrl Up}
	; basic LButton event handler
	Joy3::
		Send {LButton down}
		SetTimer, WaitForButtonUp3, 10
	return
		WaitForButtonUp3:
			if GetKeyState("Joy3")
				return
			Send {LButton up}
			SetTimer, WaitForButtonUp3, Off
		return
	; copy
	Joy4::send, {Ctrl Down}c{Ctrl Up}
	; Shift+Tab
	Joy5::send, {Shift Down}{Tab}{Shift Up}
	; Tab
	Joy6::send, {Tab}
	; Enter AltTab mode (Joy1: quit AltTab mode)
	Joy7::send, {Alt Down}{Tab}
	; RButton
	Joy8::send, {RButton}
	; press: Alt // long press: explorer.exe > focus Address Bar / otherwise, anywhere else> focus the Tray Menu
	Joy9::SetTimer, WaitForButtonUp9, 300
		WaitForButtonUp9:
			SetTimer, WaitForButtonUp9, Off
			send % GetKeyState("Joy9") ? WinActive("ahk_exe explorer.exe ahk_class CabinetWClass") ? "{Alt Down}a{Alt Up}" : "{LWin Down}b{LWin Up}" : "{Alt Down}{Alt Up}"
		return
	; press: Enter // long press: focus Address Bar (firefox)
	Joy10::SetTimer, WaitForButtonUp10, 300
		WaitForButtonUp10:
			SetTimer, WaitForButtonUp10, Off
			if (GetKeyState("Joy10") && WinActive("ahk_exe firefox.exe"))
				send, {F6}
			else send, {Enter}
		return
	; basic LWin event handler
	Joy12::
		Send {LWin down}
		SetTimer, WaitForButtonUp12, 10
	return
		WaitForButtonUp12:
			if GetKeyState("Joy12")
				return
			Send {LWin up}
			SetTimer, WaitForButtonUp12, Off
		return
#If

Class JoystickDevice extends KeypadInterface._JoystickDevice {
	poll(_dPad:="Off", _lThumbstick:="Off", _rThumbstick:="Off") {
		local
		global vk ; ~
		sleep, 100 ; ~
		if not (vk.hostWindow.isVisible()) {
			base.poll(140, 17, 400)
		} else {
			base.poll(_dPad, _lThumbstick, _rThumbstick)
		}
	} ; ~ ++++
}
Class JoystickEventsManagement extends KeypadInterface._JoystickEventsManagement {
	_dPadEventMonitor(_keypadInst, _joystick, _direction) {
		if not (_keypadInst.hostWindow.isVisible()) {
			send % "{" . _direction . "}"
		return
		}
		base._dPadEventMonitor(_keypadInst, _joystick, _direction)
	}
	_thumbstickLEventMonitor(_keypadInst, _joystick, _δX, _δY) {
		if not (_keypadInst.hostWindow.isVisible()) {
			SetMouseDelay, -1
			MouseMove, _δX, _δY, 0, R
		return
		}
		base._thumbstickLEventMonitor(_keypadInst, _joystick, _δX, _δY)
	}
	_thumbstickREventMonitor(_keypadInst, _joystick, _δZ, _δR) {
		local
		_keyToHoldDown := ""
		if (_δZ = 10)
			_keyToHoldDown := "{Space}"
		else if (_δZ = -10)
			_keyToHoldDown := "{BackSpace}"
		else if (_δR = 10)
			_keyToHoldDown := "{NumpadPgDn}"
		else if (_δR = -10)
			_keyToHoldDown := "{NumpadPgUp}"
		if (_keyToHoldDown)
			send % _keyToHoldDown
	} ; ++++
}