; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
;    Name:				class_MouseDelta.ahk
;    Description: 	See mouse input the way games see it. (Use for mouse axis->key or joystick)
;    Author: 			evilC
;    Posted: 			05 Nov 2015, 16:22
;    Link: ﻿				https://autohotkey.com/boards/viewtopic.php?f=19&t=10159
;	MSDN:				https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwindowshookexa
; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

; Instantiate this class and pass it a func name or a Function Object
; The specified function will be called with the delta move for the X and Y axes
; Normally, there is no windows message "mouse stopped", so one is simulated.
; After 10ms of no mouse movement, the callback is called with 0 for X and Y
Class MouseDelta {
	State := 0
	__New(callback){
		;~ this.TimeoutFn := this.TimeoutFunc.Bind(this)
		this.MouseMovedFn := this.MouseMoved.Bind(this)

		this.Callback := callback
	}

	Start(){
		static DevSize := 8 + A_PtrSize, RIDEV_INPUTSINK := 0x00000100
		; Register mouse for WM_INPUT messages.
		VarSetCapacity(RAWINPUTDEVICE, DevSize)
		NumPut(1, RAWINPUTDEVICE, 0, "UShort")
		NumPut(2, RAWINPUTDEVICE, 2, "UShort")
		NumPut(RIDEV_INPUTSINK, RAWINPUTDEVICE, 4, "Uint")
		; WM_INPUT needs a hwnd to route to, so get the hwnd of the AHK Gui.
		; It doesn't matter if the GUI is showing, it still exists
		Gui +hwndhwnd
		NumPut(hwnd, RAWINPUTDEVICE, 8, "Uint")

		this.RAWINPUTDEVICE := RAWINPUTDEVICE
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		OnMessage(0x00FF, this.MouseMovedFn)
		this.State := 1
		return this	; allow chaining
	}

	Stop(){
		static RIDEV_REMOVE := 0x00000001
		static DevSize := 8 + A_PtrSize
		OnMessage(0x00FF, this.MouseMovedFn, 0)
		RAWINPUTDEVICE := this.RAWINPUTDEVICE
		NumPut(RIDEV_REMOVE, RAWINPUTDEVICE, 4, "Uint")
		DllCall("RegisterRawInputDevices", "Ptr", &RAWINPUTDEVICE, "UInt", 1, "UInt", DevSize )
		this.State := 0
		return this	; allow chaining
	}

	SetState(state){
		if (state && !this.State)
			this.Start()
		else if (!state && this.State)
			this.Stop()
		return this	; allow chaining
	}

	Delete(){
		this.Stop()
		;~ this.TimeoutFn := ""
		this.MouseMovedFn := ""
	}

	; Called when the mouse moved.
	; Messages tend to contain small (+/- 1) movements, and happen frequently (~20ms)
	MouseMoved(wParam, lParam){
		Critical
		; RawInput statics
		static DeviceSize := 2 * A_PtrSize, iSize := 0, sz := 0, pcbSize:=8+2*A_PtrSize, offsets := {x: (20+A_PtrSize*2), y: (24+A_PtrSize*2)}, uRawInput

		static axes := {x: 1, y: 2}

		; Get hDevice from RAWINPUTHEADER to identify which mouse this data came from
		VarSetCapacity(header, pcbSize, 0)
		If (!DllCall("GetRawInputData", "UPtr", lParam, "uint", 0x10000005, "UPtr", &header, "Uint*", pcbSize, "Uint", pcbSize) or ErrorLevel)
			Return 0
		ThisMouse := NumGet(header, 8, "UPtr")

		; Find size of rawinput data - only needs to be run the first time.
		if (!iSize){
			r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", 0, "UInt*", iSize, "UInt", 8 + (A_PtrSize * 2))
			VarSetCapacity(uRawInput, iSize)
		}
		sz := iSize	; param gets overwritten with # of bytes output, so preserve iSize
		; Get RawInput data
		r := DllCall("GetRawInputData", "UInt", lParam, "UInt", 0x10000003, "Ptr", &uRawInput, "UInt*", sz, "UInt", 8 + (A_PtrSize * 2))

		x := 0, y := 0	; Ensure we always report a number for an axis. Needed?
		x := NumGet(&uRawInput, offsets.x, "Int")
		y := NumGet(&uRawInput, offsets.y, "Int")

		this.Callback.(ThisMouse, x, y)

		;~ ; There is no message for "Stopped", so simulate one
		;~ fn := this.TimeoutFn
		;~ SetTimer, % fn, -50
	}

	;~ TimeoutFunc(){
		;~ this.Callback.("", 0, 0)
	;~ }

}

Class mouseVector {

	xVector := 0
	yVector := 0
	timeStamp := 0

	__new(xVector, yVector, timeStamp)
	{
		this.xVector := xVector
		this.yVector := yVector
		this.timeStamp := timeStamp
	}
}