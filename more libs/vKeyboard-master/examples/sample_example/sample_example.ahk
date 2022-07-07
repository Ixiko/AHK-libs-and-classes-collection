#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk

eAutocomplete.setSourceFromFile("fr", A_ScriptDir . "\autocompletion\fr") ; create a new autocomplete
; dictionary, called 'fr', from a file's content

vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
vk.autocomplete.source := "fr" ; set the visual keyboard's autocomplete list (can be changed at any time thereafter)
vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json")
; define a 'keymap' (keyboard layout mapping) from a file's content for future calls of the 'setLayout' method
; note: you can use the 'keymapMaker' example located in the 'examples' folder to create the WYSIWYG-way
; such keyboard layout mappings
vk.setLayout("français") ; set the visual keyboard's layout (can be changed at any time thereafter)
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css") ; define a style from a file's content
; for future calls of the 'setStyle' instance method
vk.setStyle("default") ; set the visual keyboard's style (can be changed at any time thereafter)
vk.autocomplete.bkColor := vk.backgroundColor
vk.autocomplete.fontColor := "FFFFFF"
vk.autocomplete.fontName := "Segoe UI"
vk.autocomplete.fontSize := 14
vk.autocomplete.listbox.bkColor := vk.backgroundColor
vk.autocomplete.listbox.fontColor := "666666"
vk.autocomplete.listbox.fontName := "Segoe UI"
vk.autocomplete.listbox.fontSize := 11
vk.setHotkeys({}, 1, "Joy5") ; set up all keyboard/joystick shortcuts to their respective default values
; for the given `vKeyboard` instance, subscribing to the first logical joystick port and using 'Joy5' as joystick 'modifier' key
vk.showHide() ; this shows the visual keyboard if it is hidden and vice versa
vk.fitContent(14, 2, true) ; resize the visual keyboard so that it fits its new content, given a
; font size value (here 16) and a 'padding' value (here 5)
vk.onSubmit(Func("vk_onSubmit")) ; set the 'onSubmit' callback to be the 'vk_onSubmit' function below
OnExit, handleExit ; specifies a callback function or subroutine to run automatically when the script exits
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

handleExit:
	vk.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the visual keyboard instance
ExitApp

!x::ExitApp ; ALT+X