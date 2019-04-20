#include %A_ScriptDir%\..\MouseDelta.ahk
#SingleInstance force

; ============= START USER-CONFIGURABLE SECTION =============
ShiftKey := "F12"	; The key used to shift DPI. Can be any key name from the AHK Key list: https://autohotkey.com/docs/KeyList.htm
ShiftMode := 1		; 0 for shift-while-held, 1 for toggle
ScaleFactor := 4	; The amount to multiply movement by when not in Sniper Mode
; ============= END USER-CONFIGURABLE SECTION =============

; Adjust ScaleFactor. If the user wants 2x sensitivity, we only need to send 1x input...
; ... because the user already moved the mouse once, so we only need to send that input 1x more...
; ... to achieve 2x sensitivity
ScaleFactor -= 1
SniperMode := 0
md := new MouseDelta("MouseEvent").Start()

hotkey, % ShiftKey, ShiftPressed
if (!ShiftMode){
	hotkey, % ShiftKey " up", ShiftReleased
}
return
 
ShiftPressed:
	if (ShiftMode){
		SniperMode := !SniperMode
	} else {
		SniperMode := 1
	}
	md.SetState(!SniperMode)
	return

ShiftReleased:
	if (!ShiftMode){
		SniperMode := 0
	}
	md.SetState(!SniperMode)
	return

; Gets called when mouse moves or stops
; x and y are DELTA moves (Amount moved since last message), NOT coordinates.
MouseEvent(MouseID, x := 0, y := 0){
	global ScaleFactor
 
	if (MouseID){
		x *= ScaleFactor, y *= ScaleFactor
		DllCall("mouse_event",uint,1,int, x ,int, y,uint,0,int,0)
	}
}