; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=80069
; Author:	RazorHalo
; Date:   	18.08.2020
; for:     	AHK_L


; =======================================================================================================================
; Class: ControlMonitor
; 		Monitors controls for changes and triggers a Label or Function when modified.
;		Uses WM_COMMAND notifications instead of gLabels
;		Supported controls: EditBox, Radio, Checkbox, DropDownList, ComboBox, EditBox, ListBox, Push Button
;							Static Controls (Text and Picture) that have SS_NOTIFY Style set
;	 Tested on:		Win 10 (x64)
;		Author:		RazorHalo
;	Change log:		1.0 (August 18, 2020) - Initial release.
;
; =======================================================================================================================
Class ControlMonitor {
	; ===================================================================================================================
	; Constructor / Destructor
	; ===================================================================================================================
	__New() {
		; Bind the Check() method to WM_COMMAND notifications
		this.fn := ObjBindMethod(this, "Check")
		OnMessage(0x111, this.fn)
		this.Ctrl := {}
		this.State := 1
	}

	; ===================================================================================================================
	; Destroy			Frees the bound method and unregisters it from OnMessage
	; ===================================================================================================================
	Destroy() {
		OnMessage(0x111, this.fn, 0)
		this.fn := ""
	}

	; ===================================================================================================================
	; On				Turns on monitoring of controls
	; ===================================================================================================================
	On() {
		this.State := 1
	}

	; ===================================================================================================================
	; Off				Turns off monitoring of controls
	; ===================================================================================================================
	Off() {
		this.State := 0
	}

	; ===================================================================================================================
	; Add				Adds controls to the Monitor, saving its current value
	;    Parameters:	hControl - passed as either a single control hWnd or an array of control hWnds
	;					Group (Optional) - Specify a string to identify a group of controls, these can then be reset
	;					together.   Required when adding radio controls that are part of the same button group
	; Return values:	None
	; ===================================================================================================================
	Add(hControl, Group := "") {
		If (IsObject(hControl)) {
			For Each, hWnd in hControl {
				this.Ctrl[hWnd] := {}
				GuiControlGet, Value,, % hWnd
				this.Ctrl[hWnd].Value := Value

				If (Group) {
					this.Ctrl[hWnd].Group := Group
				}
			}
		} Else {
			this.Ctrl[hControl] := {}
			GuiControlGet, Value,, % hControl
			this.Ctrl[hControl] := Value

			If (Group) {
				this.Ctrl[hControl].Group := Group
			}
		}
	}

	; ===================================================================================================================
	; Remove			Removes controls from the Monitor
	;    Parameters:	hControl - passed as either a single control hWnd or an array of control hWnds
	;					Group (Optional) - Removes all controls from the specified group
	; Return values:	None
	; ===================================================================================================================
	Remove(hControl, Group := "") {
		If (IsObject(hControl))
			For Each, hWnd in hControl {
				If (Group && this.Ctrl[hWnd].Group != Group)
					Continue
				Else
					this.Ctrl.Delete(hWnd)
			}
		this.Ctrl.Delete(hControl)
	}

	; ===================================================================================================================
	; Reset				Resets the controls in the monitor, saving their current values to be the new 'unchanged' value
	;    Parameters:	hControl - passed as either a single control hWnd or an array of control hWnds
	;								** OMIT to reset all controls in the monitor
	;					Group (Optional) - Resets all controls in the specified group
	; Return values:	None
	; ===================================================================================================================
	Reset(hControl := "", Group := "") {
		If !(hControl) {
			For hWnd in this.Ctrl {
				If (Group && this.Ctrl[hWnd].Group != Group)
					Continue

				GuiControlGet, Value,, % hWnd
				this.Ctrl[hWnd].Value := Value
			}
		} Else If (IsObject(hControl)) {
			For Each, hWnd in hControl {
				GuiControlGet, Value,, % hWnd
				this.Ctrl[hWnd].Value := Value
			}
		} Else {
			GuiControlGet, Value,, % hControl
			this.Ctrl[hControl].Value := Value
		}
	}

	; ===================================================================================================================
	; Target			Sets the target label or function to execute when monitored control is modified
	;    Parameters:	Target - Name of a label or function
	; Return values:	On success  - False
	;					On failure  - True
	;		Remarks:	If the target is a function it will pass the controls hWnd as the first parameter
	; ===================================================================================================================
	Target(Target) {
		If IsLabel(Target) {
			this.Target := Target
			Return False
		} Else If IsFunc(Target) {
			this.Target := Func(Target)
			Return False
		}

		MsgBox, 16, Error, % Target " is not a valid label or function"
		Return True
	}

	; ===================================================================================================================
	; Check				Checks if the value of a control has changed
	;    Parameters:
	; Return values:	On success  - False
	;					On failure  - True
	;		Remarks:	Called by function bound to WM_COMMAND OnMessage
	; ===================================================================================================================
	Check(wParam, hCtrl, msg, hWnd) {
		Modified := 0

		NC := (wParam >> 16) ; Get notification code

		If (this.State && this.Ctrl.HasKey(hCtrl)
						&& (NC = 0x300		;EN_CHANGE
					    ||  NC = 0			;STN_CLICKED
					    ||  NC = 0x0			;BN_CLICKED
					    ||  NC = 1			;CBN_SELCHANGE, LBN_SELCHANGE
					    ||  NC = 5)) {		;CBN_EDITCHANGE

			; Make sure click is finished if any functions are using WM_LBUTTONUP
			While GetKeyState("LButton","P")
				Sleep 50

			; Compare the value
			GuiControlGet, Value,, % hCtrl

			If (this.Ctrl[hCtrl].Value != Value) {
				Modified := 1

			}

			; Execute target if control is modified
			If (Modified) {
				If (this.Ctrl[hCtrl].Group)
					this.Reset("", this.Ctrl[hCtrl].Group)
				Else
					this.Reset(hCtrl) ; Reset controls compare value to the new value

				If IsLabel(this.target)
					GoSub % this.Target
				Else If IsFunc(this.Target)
					this.Target.Call(hCtrl)
			}
		}
	}
}