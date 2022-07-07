#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk

vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'
vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json",, "customCb")
; define a 'keymap' (keyboard layout mapping) from a file's content for future calls of the 'setLayout' method
; in this example, we specify a custom default callback: 'customCb' - which will be executed in place of the built-in default callback
; each time a key on the visual keyboard is pressed/clicked, assuming that a f-function has not been set for this key
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
vk.fitContent(18, 7, true) ; resize the visual keyboard so that it fits its new content, given a
; font size value (here 18) and a 'padding' value (here 7)
OnExit, handleExit ; specifies a callback function or subroutine to run automatically when the script exits
return


handleExit:
	vk.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the visual keyboard instance
ExitApp

!x::ExitApp ; ALT+X

customCb(this, _keyDescriptor, _count) { ; the custom default callback
; _keyDescriptor 	Contains a reference to the descriptor of the key whose click/press triggered the f-function.
; _count 	A non-zero integer which represents the number of clicks or presses that triggered the callback.
; 		Up to 3 consecutive presses/clicks are detected as such - while -1 stands for a long click/press.
	local
	_clickOrPressSubString := (A_ThisHotkey = "LButton") ? "clicked on" : "pressed"
	ToolTip, % "You " . _clickOrPressSubString . " the '" . _keyDescriptor.caption . "' [" . this.X "," .  this.Y "] key "
		. ((_count = -1) ? "a long time" : _count . "time(s)") . "!", 0, 0, 1
; return 0
}