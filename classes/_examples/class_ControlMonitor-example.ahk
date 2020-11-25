; =======================================================================================================================
; Class_ControlMonitor Example - By RazorHalo
; =======================================================================================================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

MonitorRadioControls := 0

Gui Add, CheckBox, hWndhCheckBox vCheckBox x14 y6 w68 h23, CheckBox
Gui Add, ComboBox, hWndhComboBox vComboBox x160 y40 w121, ComboBox||Option 1|Option 2|Option 3
Gui Add, Edit, hWndhEditBox vEditBox x108 y8 w172 h21, EditBox
Gui Add, DropDownList, hWndhDropDownList vDropDownList x12 y39 w131, DropDownList||Option 1|Option 2|Option 3
Gui Add, ListBox, hWndhListBox vListBox x161 y76 w121 h108, ListBox||Red|Green|Blue|Black|White
Gui Add, Radio, hWndhRadioButton1 vRadioButton1 x31 y95 w91 h23, Radio Button 1
Gui Add, Radio, hWndhRadioButton2 vRadioButton2 x31 y122 w91 h24, Radio Button 2
Gui Add, Radio, hWndhRadioButton3 vRadioButton3 x31 y151 w91 h23, Radio Button 3
Gui Add, GroupBox, hWndhGroupBox vGroupBox x12 y72 w131 h113, NOT Monitored
Gui Add, Button, gMonitorRadioControls_TOGGLE x10 y194 w131 h23, Toggle Radio Monitor
Gui Font, s16 cRed
Gui Add, Text, hWndhTxtStatus x22 y253 w249 h24 +0x200 Center, None
Gui Font
Gui Font, s16 Underline
Gui Add, Text, x20 y223 w249 h24 +0x200 Center, Last Updated Control
Gui Font
Gui Add, Button, hWndhBtnMonitor_TOGGLE vBtnMonitor_TOGGLE gMonitor_TOGGLE x152 y194 w131 h23, Pause Monitor

Gui Show, w291 h289, Control Monitor

; Define some arrays of control hWnds
SomeControls := [hCheckBox, hComboBox, hEditBox, hDropDownList, hGroupBox]
RadioControls := [hRadioButton1, hRadioButton2, hRadioButton3]

; Create a new instance
Monitor := New ControlMonitor

Monitor.Add(SomeControls) 	; Add controls by passing an array of hWnds
Monitor.Add(hListBox)		; Add single control by passing a single hWnd

; Set the target to execute when a control changes
; In this case its the name of a function, but can also be a label to jump to
Monitor.Target("RefreshStatus")


Return

; Clean up and Exit
GuiEscape:
GuiClose:
	Monitor.Destroy() ; Needed to release the references to the WM_COMMAND message function
	Monitor := ""
	ExitApp

; Toggle monitoring of Radio Controls by adding and removing them from the monitor
MonitorRadioControls_TOGGLE:
	If (MonitorRadioControls := !MonitorRadioControls) {
		GuiControl ,, % hGroupBox, Monitoring
		Monitor.Add(RadioControls, "Radio") ; Radio controls need to be added as a group
	} Else {
		GuiControl ,, % hGroupBox, NOT Monitored
		Monitor.Remove(RadioControls)
	}
Return

; Pause and resume monitoring
Monitor_TOGGLE:
	If (Monitor.Status := ! Monitor.Status) {
		GuiControl ,, % hBtnMonitor_TOGGLE, Resume Monitor
		Monitor.Off()
	} Else {
		GuiControl ,, % hBtnMonitor_TOGGLE, Pause Monitor
		Monitor.On()
	}

Return

; Target function - just updates the gui as to what control was changed
RefreshStatus(hWnd) {
	Global hTxtStatus
	GuiControlGet, vLabel, Name, % hWnd
	GuiControl ,, % hTxtStatus, % vLabel
}

#Include %A_ScriptDir%\..\class_ControlMonitor.ahk