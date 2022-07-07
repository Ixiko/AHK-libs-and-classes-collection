#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input

CoordMode, ToolTip, Screen
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk


vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
eAutocomplete.setSourceFromFile("fr", A_ScriptDir . "\autocompletion\fr") ; create a new autocomplete
; dictionary, called 'fr', from a file's content
eAutocomplete.setSourceFromFile("en", A_ScriptDir . "\autocompletion\en")
vk.autocomplete.source := "fr" ; set the visual keyboard's autocomplete list (can be changed at any time thereafter)
vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json")
vKeyboard.defineLayout("français_debug", A_ScriptDir . "\keymaps\debug\français_debug.json")
; define a 'keymap' (keyboard layout mapping) for future calls of the 'setLayout' method
; note: you can use the 'layoutMaker' example located in the 'examples' folder to create the WYSIWYG-way
; such keyboard layout mappings
vk.setLayout("français") ; set the visual keyboard's layout (can be changed at any time thereafter)
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css") ; define a style for future calls
vKeyboard.defineStyle("debug", A_ScriptDir . "\styles\debug.css") ; define a style for future calls
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
; in this example, we use an external JSON file to indicate the respective value
; of each keyboard/joystick shortcuts which are to be set by the script
FileRead, objDescription, % A_ScriptDir . "\settings.json" ; reads the JSON file
settings := JSON.Load(objDescription) ; parses the JSON string into an AHK object
; value using the JSON lib by coco, auto-included by the visual keyboard library
hotkeys := settings.hotkeys
vk.setHotkeys(hotkeys, 1, "Joy5") ; set up all keyboard/joystick shortcuts
; for the given `vKeyboard` instance, subscribing to the first logical joystick port and using 'Joy5' as joystick 'modifier' key
vk.showHide() ; this shows the visual keyboard if it is hidden and vice versa
vk.fitContent(16, 5, true) ; resize the visual keyboard so that it fits its new content, given a
; font size value (here 16) and a 'padding' value (here 5)
vk.onSubmit(Func("vk_onSubmit")) ; set the 'onSubmit' callback to be the 'vk_onSubmit' function below
vk.onShowHide(Func("vk_onShowHide")) ; set the 'onShowHide' callback to be the 'vk_onShowHide' function below
OnExit, handleExit ; specifies a callback function or subroutine to run automatically when the script exits
switch := 0 ; a simple variable use for the toggle hotkey below.
return

vk_onSubmit(this, _hLastFoundControl, _input) { ; executed each time the text entered so far is submitted
; if any, '_hLastFoundControl' contains the HWND of the control that had focus and whose focus has been stolen by the
; visual keyboard at the moment this latter was last shown.
; '_input' contains the visual keyboard's text entry field upon submission.
	ToolTip % _hLastFoundControl "," _input
	if (_hLastFoundControl)
		ControlSend,, % "{Text}" . _input, % "ahk_id " . _hLastFoundControl
	else SendInput % "{Text}" . _input
}
vk_onShowHide(this, _isVisible) {
	ToolTip % _isVisible
}

handleExit:
	vk.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the visual keyboard instance
ExitApp

#If WinActive("ahk_id " . vk.hostWindow.HWND)
	!y::vk.setLayer(1 + switch:=!switch)
	!l::vk.setLayout("français")
	^!l::vk.setLayout("français_debug")
	!s::
			vk.setStyle("default")
			vk.autocomplete.bkColor := vk.backgroundColor
			vk.redraw()
			vk.autocomplete.listbox.bkColor := vk.backgroundColor
			vk.autocomplete.fontColor := "FFFFFF"
			vk.autocomplete.listbox.fontColor := "666666"
	return
	^!s::
			vk.setStyle("debug")
			vk.autocomplete.bkColor := vk.backgroundColor
			vk.redraw()
			vk.autocomplete.listbox.bkColor := vk.backgroundColor
			vk.autocomplete.fontColor := "000000"
			vk.autocomplete.listbox.fontColor := "000000"
	return
	!m::vk.expand()
	^!m::vk.shrink()
	!a::vk.pressKey(1, 1, -1) ; x:1, y:1 | -1 > long press
	!b::vk.pressKey(1,, 1)
	!c::vk.pressKey(, 1, 1)
	!t::vk.transparency -= 10
	^!t::vk.transparency += 10
	!r::vk.resetOnSubmit := !vk.resetOnSubmit ; Set or get the boolean value which determine if the
	; entire text entry field of the visual keyboard should be cleared upon submission.
	!h::vk.hideOnSubmit := !vk.hideOnSubmit ; Set or get the boolean value which determine if the
	; visual keyboard should be hidden each time the text entered is submitted.
	!o::vk.alwaysOnTop := !vk.alwaysOnTop
	!i::MsgBox, 64,, % vk.X "," vk.Y . "`r`n"
					. vk.columns "," vk.rows . "`r`n"
					. vk.style . "`r`n"
					. vk.layout . "`r`n"
					. vk.layer . "`r`n"
					. vk.layers . "`r`n"
					. vk.altIndex . "`r`n"
					. vk.altMode . "`r`n"
					. vk.fontSize . "`r`n"
					. vk.hostWindow.HWND . "`r`n"
					. vk.backgroundColor . "`r`n"
					. vk.transparency . "`r`n"
					. vk.alwaysOnTop . "`r`n"
					. vk.hideOnSubmit . "`r`n"
					. vk.resetOnSubmit . "`r`n"
					. vk.autocomplete.bkColor . "`r`n"
					. vk.autocomplete.fontName . "`r`n"
					. vk.autocomplete.fontSize . "`r`n"
					. vk.autocomplete.fontColor . "`r`n"
	!f::vk.fontSize--
	^f::vk.fontSize++
	^!f::vk.fitContent(22, 4)
#If

!x::ExitApp
