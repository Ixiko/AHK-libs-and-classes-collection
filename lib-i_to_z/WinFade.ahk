#NoEnv  					; Recommended for performance and compatibility with future AutoHotkey releases.
DetectHiddenWindows, On     ; Determines whether invisible windows are "seen" by the script.

/**
*  WinFadeTo( WinTitle, [, Duration] )
*   WinTitle
*      A window title identifying the name of the target window.
*   Duration (default 1 second)
*      A number (in seconds) defining how long the animation will take to complete.
*      NOTE: The duration cannot be set to lower than 1 second.
*   Hide (disabled by default)
*      Set the visible state of the target window after fade out.
*      NOTE: Enabled by default if "DetectHiddenWindows" is set to on, otherwise disabled.
*/
WinFadeToggle(WinTitle, Duration := 1, Hide := false) {
	; Declarations
	LoopCount := 64 * Duration                      ; Calculated number of iterations for loop
	WinGet, WinOpacity, Transparent, %WinTitle%     ; Get transparency level of target window

	; Return error if target window does not exist or is not active
	If !WinExist(WinTitle) && !WinActive(WinTitle) {
		ErrorMessage := "Target window is not active or does not exist."
	}

	; Check "DetectHiddenWindows" state
	If( A_DetectHiddenWindows = "On" ) {
		Hide := true
	}

	; Check target window for transparency level
	If ( WinOpacity = "" ) {
		WinSet, Transparent, 255, %WinTitle% ; Set transparency of target window
	}

	; Set the direction of the fade (in/out)
	If(WinOpacity = 255 || WinOpacity = "") {
		start := -255
		} else {
			start := 0
			WinShow, %WinTitle%
			WinActivate, %WinTitle%     ; Activate target window on fade in
		}

		; Iterate through each change in opacity level
		timer_start := A_TickCount ; Log time of fade start
		Loop, % LoopCount {
			opacity := Abs(255/LoopCount * A_Index + start) ; opacity value for the current iteration
			WinSet, Transparent, %opacity%, %WinTitle%      ; Set opacity level for target window
			Sleep, % duration                               ; Pause between each iteration
		}
		timer_stop := A_TickCount ; Log time of fade completion

		; Hide target window after fade-out completes
		If(start != 0 && Hide = true) {
			WinHide, %WinTitle%
		}

		Return ErrorMessage
	}

	#Include, Print.ahk
