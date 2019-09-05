; ADHD Bare bones template
; Simply creates an edit box and binds a hotkey to send the contents of the edit box on press of the hotkey

; ============================================================================================
; Setup SECTION

; Declare the library
ADHD := New ADHDLib

; Configure the About box
ADHD.config_about({name: "Template", version: 1.0, author: "nobody", link: "<a href=""http://google.com"">Somewhere</a>"})

; The default application to limit hotkeys to.
; Starts disabled by default, so no danger setting to whatever you want
ADHD.config_limit_app("Notepad")

; GUI size
;ADHD.config_size(375,150)

; Defines your hotkeys - here we define a hotkey "Fire" that calls the label "Fire"
ADHD.config_hotkey_add({uiname: "Fire", subroutine: "Fire"})

; End Setup section
; ============================================================================================

; Start ADHD
ADHD.init()
ADHD.create_gui()

; ============================================================================================
; GUI SECTION
; Add our custom GUI items...

; The "Main" tab is tab 1
Gui, Tab, 1

; Create normal label
Gui, Add, Text, x5 y40, String to Send
; Create Edit box that has state saved in INI
ADHD.gui_add("Edit", "StringToSend", "xp+120 yp W120", "", "")
; Create tooltip by adding _TT to the end of the Variable Name of a control
StringToSend_TT := "What to Send"

; End GUI creation section
; ============================================================================================

; Done! with startup! Tell ADHD to start running.
ADHD.finish_startup()
return

; ==========================================================================================
; HOTKEYS SECTION

; This is where you define labels that the various bindings trigger
; Make sure you call them the same names as you set in the settings at the top of the file (eg Fire, FireRate)
Fire:
	Send %StringToSend%
	return

; ===================================================================================================
; FOOTER SECTION

; KEEP THIS AT THE END!!
#Include %A_ScriptDir%\..\class_ADHDLib.ahk