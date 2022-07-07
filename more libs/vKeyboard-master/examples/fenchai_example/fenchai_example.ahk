#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
CoordMode, ToolTip, Screen
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

/*
	Sample example demonstrating how a custom event handling can be designed to navigate the
	web via an instance of vKeyboard and by means of user-defined prefixes, on the model of the Universal_Searcher by
	fenchai (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=42788&p=194488).
	For the first three characters entered (case-insensitive):
		*L X - search X @ https://www.linguee.com/english-french
		*Y X - search X @ https://www.youtube.com
*/

placeholder := "${}"
prefixes := {}
	prefixes.l := {}
		prefixes.l.url := "https://www.linguee.fr/francais-anglais/search?source=auto&query=" . placeholder
		prefixes.l.color := "#2b4d96"
	prefixes.y := {}
		prefixes.y.url := "https://www.youtube.com/results?search_query=" . placeholder
		prefixes.y.color := "#991029"
; ...
	prefixes.current := "", prefixes.none := {color: "#000000"}

#Include %A_ScriptDir%\..\..\lib\vKeyboard.ahk

eAutocomplete.setSourceFromFile("fr", A_ScriptDir . "\autocompletion\fr") ; create a new autocomplete
; dictionary, called 'fr', from a file's content
vk := new vKeyboard() ; create a new instance of the visual keyboard object and stores it in 'vk'

; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
vk.autocomplete.base.__valueChanged := Func("vk_autocompleteValueChangedHook").bind(vk.autocomplete)
; hook the eAutocomplete.__valueChanged internal method
vk.base._submit := Func("_submit").bind(vk) ; _submit (internal method) fix
; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

vKeyboard.defineLayout("français", A_ScriptDir . "\keymaps\français.json")
; define a 'keymap' (keyboard layout mapping) from a file's content for future calls of the 'setLayout' method
; note: you can use the 'keymapMaker' example located in the 'examples' folder to create the WYSIWYG-way
; such keyboard layout mappings
vk.setLayout("français") ; set the visual keyboard's layout (can be changed at any time thereafter)
vKeyboard.defineStyle("default", A_ScriptDir . "\styles\default.css") ; define a style from a file's content
; for future calls of the 'setStyle' instance method
vk.setStyle("default") ; set the visual keyboard's style (can be changed at any time thereafter)
vk.autocomplete.setOptions({expandWithSpace: false, suggestAt: 2, source: "fr"})
; set several options of a the autocomplete component
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
vk.fitContent(16, 5, true) ; resize the visual keyboard so that it fits its new content, given a
; font size value (here 16) and a 'padding' value (here 5)
vk.onSubmit(Func("vk_onSubmit")) ; set the 'onSubmit' callback to be the 'vk_onSubmit' function below
OnExit, handleExit
return

vk_onSubmit(this, _hLastFoundControl, _input) { ; executed each time the text entered so far is submitted
	; '_input' contains the visual keyboard's text entry field upon submission.
	local
	global prefixes, placeholder
	if (prefixes.current) {
		this.AXObject.document.body.style.background := prefixes.none.color
		run % StrReplace(prefixes.current.url, placeholder, Trim(SubStr(_input, 2)))
	}
}

getPrefix(_input) {
	local
	global prefixes
	static _letter := ""
	if (RegExMatch(_input, "^\S\s", _prefixMatch)) {
	; upon a prefix pattern match...
		if (!prefixes.current && prefixes.hasKey(_prefixMatch:=RTrim(_prefixMatch))) {
		; if currently, there is no set prefix and the letter matched appears to be a prefix...
			_letter := _prefixMatch, prefixes.current := prefixes[_letter]
		return 1
		}
	}
	if (prefixes.current && (_prefixMatch <> _letter . A_Space)) {
	; if the prefix has been removed or altered...
		prefixes.current := ""
	return -1
	}
}

!x::
handleExit:
	vk.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the visual keyboard instance
ExitApp

; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
vk_autocompleteValueChangedHook(this) {
	local
	global eAutocomplete, vk, prefixes
	if (_r:=getPrefix(this._content)) {
		vk.AXObject.document.body.style.background := prefixes[(_r=1) ? "current" : "none"].color
		; sets the background colour accordingly
	}
	eAutocomplete.__valueChanged.bind(this).call()
	; give control back to eAutocomplete
}
_submit(this, _hideOnSubmit:=true, _resetOnSubmit:=false, _callback:=false) {
	; _submit (internal method) fix
	local
	this.altReset()
	this._autocomplete.getText(_text)
	if (_callback || this.__submit) {
		this.__submit.call(this, this._hLastFoundControl, _text)
	}
	if (_resetOnSubmit || this._resetOnSubmit) {
		this._autocomplete._clearContent()
		; must be called after the __submit callbacks in this example; otherwise, prefixes.current
		; will always be blank @ vk_onSubmit
	}
	if (_hideOnSubmit || this.hideOnSubmit)
		this._hostWindow.hide()
}
; <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>