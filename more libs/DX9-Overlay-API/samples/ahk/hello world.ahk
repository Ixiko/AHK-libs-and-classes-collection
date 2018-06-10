/*
DX9-Overlay-API AutoHotkey "Hello World" script

By default, injects to the GFXTest application by evolution536 and learn_more from here: http://www.unknowncheats.me/forum/general-programming-and-reversing/105528-gfxtest-lightweight-graphics-testing-application.html

Usage:
1) Install Autohotkey (http://ahkscript.org) - BE SURE TO INSTALL ANSI 32-bit version!!
2) Change PROC_NAME to desired process name
3) Run script and DX application (in any order)

Hitting ALT+X will exit the script, hitting ALT+T will toggle the text on/off
*/

#SingleInstance, force
#NoEnv

PROC_NAME := "GFXTest.exe"

overlay_ids := {}
text_visible := 1

#include ..\..\include\ahk\overlay.ahk
OnExit, GuiClose

SetParam("process", PROC_NAME)

WatchProcess(PROC_NAME)

return

; Quit script hotkey: ALT+X
~!x::
GuiClose:
	soundbeep
	DestroyOverlays()
	ExitApp
	return

; Toggle text overlay hotkey - ALT+T
~!t::
	text_visible := 1 - text_visible
	TextSetShown(overlay_ids.text,text_visible)
	return

; Watch process and add overlays when it starts running.
WatchProcess(name){
	global overlay_ids
	static proc_running := 0

	Loop {
		ifwinexist, ahk_exe %name%
		{
			if (!proc_running){
				proc_running := 1
				overlay_ids := CreateOverlays()
			}
		} else {
			if (proc_running){
				proc_running := 0
				overlay_ids := {}
			}
		}
		Sleep 100
	}
}

; Add overlays to application
CreateOverlays(){
	ret := {}
	ret.text := TextCreate("Arial", 25, false, false, 100, 100, 0xFFFFFFFF, "Hello {ffff00}World", true, true)
	ret.box := BoxCreate(200, 200, 200, 200, 0xFFFFFFFF, true)
	return ret
}

; Remove overlays from application
DestroyOverlays(){
	DestroyAllVisual()
}
