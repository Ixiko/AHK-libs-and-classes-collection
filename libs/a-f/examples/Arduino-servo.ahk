;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows XP +??
; Author:         ahklerner / kruzan
;
; Script Function:
;	Arduino GUI Example
;
; set some defaults
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; serial settings
ARDUINO_Port     = COM2 ; change accordingly
ARDUINO_Baud     = 115200
ARDUINO_Parity   = N
ARDUINO_Data     = 8
ARDUINO_Stop     = 1
; setup arduino serial communication
arduino_setup(start_polling_serial:=false)
; *****************GUI CODE***************
Gui, Add, Slider, vServoSlider1 gServoSlider1 range0-180 AltSubmit, 90
Gui, Add, Text,, Current Servo Position (as reported by Arduino):
Gui, Add, Text, vPosition,**NO DATA RECEIVED YET**

; show the gui (it will be auto sized and positioned)
Gui, Show
; *****************************************
Gosub, ServoSlider1
return
; ******button action code ******

ServoSlider1:
	Gui, Submit, NoHide
	UpdateSliderToolTip(ServoSlider1)
	GuiControl,,Position, % arduino_send(ServoSlider1)
return

UpdateSliderToolTip(val){
	SetFormat, Integer, DEC
	val += 0
	ToolTip % val
	SetTimer, tooltip_close, -500
}

tooltip_close:
	ToolTip
return

;*************************************************************************************
; *****Do not edit below this line unless you want to change the core functionality of the script*****
;*************************************************************************************
; called when the gui is closed
;also called when program exits
GuiClose:
OnExit:
	; make sure to cleanly shut down serial port on exit
	arduino_close()
; this is important!! or else theprogram does not end when closed
ExitApp
#include %A_ScriptDir%\Arduino.ahk