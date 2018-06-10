#SingleInstance force
#NoEnv
#Persistent

#Include Class Hotkey.ahk

; the simplest hotkey we can have is a key that runs a function or label
; lets make a hotkey that binds ALT+A to an empty msgbox.
new Hotkey("!A", Func("MsgBox"))

; now lets make a hotkey that opens up a msgbox when I press ALT+A and notepad is open.
; but oh no! it's the same key as above!
; well, luckily we can have different types of hotkeys. this one will only run if notepad is active. otherwise, that first one will run.
NotepadHtk := new Hotkey("!A", Func("MsgBox").Bind("Notepad!"), "ahk_class Notepad")
; with the instance, we can modify the hotkey.
; to disable it, we could do NotepadHtk.Disable()

; lets create another hotkey which toggles the previous hotkey.
; we do this by binding this hotkey to the previous hotkeys' Toggle method.
; this hotkey is also only active when notepad is active.
new Hotkey("!S", NotepadHtk.Toggle.Bind(NotepadHtk), "ahk_class Notepad")

; lets also create a hotkey that only runs when notepad is *NOT* active:
; this hotkey will make a beep at 500hz
new Hotkey("!D", Func("SoundBeep").Bind(500), "ahk_class Notepad", "NotActive")

; lets make one last hotkey.
; this one will delete every hotkey except for the notepad one.
; this one is bound to a label instead of a function/method.
new Hotkey("!F", "DisableSomeKeys")
return


DisableSomeKeys:
; we use the base object method Hotkey.GetKey() to retrieve the hotkey instance.
Hotkey.GetKey("!A").Delete() ; deletes the first hotkey.
Hotkey.GetKey("!S", "ahk_class Notepad").Delete() ; deletes the third hotkey.

; of course, you can save the instance returned by GetKey() to a variable if you want.
HtkInstance := Hotkey.GetKey("!F")
HtkInstance.Delete()

; lets also make sure the notepad hotkey is enabled in case it was disabled when this label runs.
; we still have the instance from when we made this hotkey.
if !NotepadHtk.Enabled
	NotepadHtk.Enable()

MsgBox("Keys disabled!")
return


MsgBox(Msg := "") {
	MsgBox,, Hotkey example, % Msg
}

SoundBeep(hz) {
	SoundBeep % hz, 200
}