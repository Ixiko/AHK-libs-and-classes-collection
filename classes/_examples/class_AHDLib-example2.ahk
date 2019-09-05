#SingleInstance, force
/*
vJoy Template for ADHD
An example script to show how to build a virtual joystick app with ADHD

Make sure you are using AutoHotkey from http://ahkscript.org, NOT Autohotkey.com!
Uses Shaul's vJoy - http://http://vjoystick.sourceforge.net - install this first
Then you need the AHK vJoy library:
https://github.com/evilC/AHK-vJoy-Library
*/

#include <VJoy_lib>
;#include VJoy_lib.ahk

; Create an instance of the library
ADHD := New ADHDLib

; Build Button String for DropDown boxes
ButtonString := ""
Loop 32 {
	ButtonString .= A_Index
	if (A_Index != 32){
		ButtonString .= "|"
	}
}

; ============================================================================================
; CONFIG SECTION - Configure ADHD

; Authors - Edit this section to configure ADHD according to your macro.
; You should not add extra things here (except add more records to hotkey_list etc)
; Also you should generally not delete things here - set them to a different value instead

; You may need to edit these depending on game
SendMode, Event
SetKeyDelay, 0, 50

; Stuff for the About box

ADHD.config_about({name: "vJoy Template", version: 0.1, author: "evilC", link: "<a href=""http://evilc.com/proj/adhd"">Homepage</a>"})
; The default application to limit hotkeys to.

; GUI size
ADHD.config_size(375,250)

; We need no actions, so disable warning
;ADHD.config_ignore_noaction_warning()

ADHD.config_hotkey_add({uiname: "Binding 1", subroutine: "Binding1"})
adhd_hk_k_1_TT := "Bind something to this and push it to press a virtual button"

; Hook into ADHD events
; First parameter is name of event to hook into, second parameter is a function name to launch on that event
ADHD.config_event("app_active", "app_active_hook")
ADHD.config_event("app_inactive", "app_inactive_hook")
ADHD.config_event("option_changed", "option_changed_hook")

ADHD.init()
ADHD.create_gui()

; The "Main" tab is tab 1
Gui, Tab, 1
; ============================================================================================
; GUI SECTION

; Add the GUI for vJoy selection
Gui, Add, Text, x15 y40, vJoy Stick ID
ADHD.gui_add("DropDownList", "selected_virtual_stick", "xp+70 yp-5 w50 h20 R9", "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16", "1")
Gui, Add, Text, xp+60 yp+5 w200 vadhd_virtual_stick_status, 

Gui, Add, GroupBox, x5 yp+25 W365 R1.5 section, Input Configuration
Gui, Add, Text, x15 ys+20, Joystick ID
ADHD.gui_add("DropDownList", "JoyID", "xp+80 yp-5 W50", "1|2|3|4|5|6|7|8", "1")
JoyID_TT := "The ID (Order in Windows Game Controllers?) of your Joystick"

Gui, Add, Text, xp+100 ys+20, Axis
ADHD.gui_add("DropDownList", "JoyAxis", "xp+40 yp-5 W50", "1|2|3|4|5|6", "1")
JoyAxis_TT := "The Axis on that stick that you wish to use"

ADHD.gui_add("CheckBox", "InvertAxis", "xp+60  yp+5", "Invert Axis", 0)
InvertAxis_TT := "Inverts the input axis.`nNot intended to be used with ""Use Half Axis"""

Gui, Add, GroupBox, x5 yp+35 W365 R1.5 section, Output Configuration
Gui, Add, Text, x15 ys+20, Binding 1 pushes virtual button
ADHD.gui_add("DropDownList", "OutputButton1", "xp+160 yp-5 W50", ButtonString, "1")

Gui, Add, GroupBox, x5 yp+45 R2 W365 section, Debugging
Gui, Add, Text, x15 ys+15, Current axis value
Gui, Add, Edit, xp+120 yp-2 W50 R1 vAxisValueIn ReadOnly,
AxisValueIn_TT := "Raw input value of the axis.`nIf you have Joystick ID and axis set correctly,`nmoving the axis should change the numbers here"

Gui, Add, Text, xp+60 ys+15, Adjusted axis value
Gui, Add, Edit, xp+100 yp-2 W50 R1 vAxisValueOut ReadOnly,
AxisValueOut_TT := "Input value adjusted according to options`nShould be 0 at center, 100 at full deflection"

; End GUI creation section
; ============================================================================================

; Useful arrays to convert axis number to axis name
axis_list_ahk := Array("X","Y","Z","R","U","V")
axis_list_vjoy := Array("X","Y","Z","RX","RY","RZ","SL0","SL1")

ADHD.finish_startup()

; Loop runs endlessly...
Loop, {
	if (vjoy_is_ready){
		; Get the value of the axis the user has selected as input
		axis := conform_axis()
		
		; Assemble the string which sets which virtual axis will be manipulated
		vjaxis := axis_list_vjoy[2]
		
		; input is in range 0->100, but vjoy operates in 0->32767, so convert to correct output format
		axis := axis * 327.67
		
		; Set the vjoy axis
		VJoy_SetAxis(axis, vjoy_id, HID_USAGE_%vjaxis%)
	}
	
	; Sleep a bit to chew up less CPU time
	Sleep, 10
	
}
return

Binding1:
	VJoy_SetBtn(1, vjoy_id, OutputButton1)
	Return

Binding1Up:
	VJoy_SetBtn(0, vjoy_id, OutputButton1)
	Return

; Conform the input value from an axis to a range between 0 and 100
; Handles invert, half axis usage (eg xbox left trigger) etc
conform_axis(){
	global axis_list_ahk
	global JoyID
	global JoyAxis
	global InvertAxis
	
	; Assemble string to describe which axis the user selected (eg 2JoyX)
	tmp := JoyID "Joy" axis_list_ahk[JoyAxis]
	
	; Detect the state of the input axis
	GetKeyState, axis, % tmp
	
	; Update the contents of the "Current" debugging text box
	GuiControl,,AxisValueIn, % round(axis,1)
	
	; Invert the axis if the user selected the option
	if (InvertAxis){
		axis := 100 - axis
	}

	; Update the contents of the "Adjusted" text box
	GuiControl,,AxisValueOut, % round(axis,1)
	
	return axis
}

app_active_hook(){

}

app_inactive_hook(){

}

option_changed_hook(){
	global ADHD

	; Release Buttons
	if (vjoy_is_ready){
		Loop % VJoy_GetVJDButtonNumber(vjoy_id) {
			VJoy_SetBtn(0, vjoy_id, A_Index)
		}
	}

	connect_to_vjoy()
}

; Connect to vJoy stick.
connect_to_vjoy(){
	;global ADHD, this.vjoy_id ; What ID we are connected to now
	global vjoy_id, vjoy_is_ready
	global selected_virtual_stick	; What ID is selected in the UI
	;global adhd_vjoy_ready ;store this global, so loops outside can see whether vjoy is ready or not.
	; Connect to virtual stick
	if (vjoy_id != selected_virtual_stick){

		if (VJoy_Ready(vjoy_id)){
			VJoy_RelinquishVJD(vjoy_id)
			VJoy_Close()
		}
		vjoy_id := selected_virtual_stick
		vjoy_status := DllCall("vJoyInterface\GetVJDStatus", "UInt", vjoy_id)
		if (vjoy_status == 2){
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Busy - Other app controlling this device?
		}  else if (vjoy_status >= 3){
			; 3-4 not available
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Not Available - Add more virtual sticks using the vJoy config app
		} else if (vjoy_status == 0){
			; already owned by this app - should not come here as we want to release non used sticks
			GuiControl, +Cred, adhd_virtual_stick_status
			GuiControl, , adhd_virtual_stick_status, Already Owned by this app (Should not see this!)
		}
		if (vjoy_status <= 1){
			VJoy_Init(vjoy_id)
			if (VJoy_Ready(vjoy_id)){
				; Seem to need this to allow reconnecting to sticks (ie you selected id 1 then 2 then 1 again. Else control of stick does not resume
				VJoy_AcquireVJD(vjoy_id)
				VJoy_ResetVJD(vjoy_id)
				vjoy_is_ready := 1
				GuiControl, +Cgreen, adhd_virtual_stick_status
				GuiControl, , adhd_virtual_stick_status, Connected
			} else {
				GuiControl, +Cred, adhd_virtual_stick_status
				GuiControl, , adhd_virtual_stick_status, Problem Connecting
				vjoy_is_ready := 0
			}
		} else {
			vjoy_is_ready := 0
		}
	}
}

; KEEP THIS AT THE END!!
#Include %A_ScriptDir%\class_ADHDLib.ahk