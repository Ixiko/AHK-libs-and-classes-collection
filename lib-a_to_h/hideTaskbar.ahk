hideTaskbar(toggle){
	WinExist("ahk_class Shell_TrayWnd")
	ControlGetPos,,,, hTB, ahk_class Shell_TrayWnd  ; Get Taskbar Height
	; t := !t  ; Toggle Var (0 or 1)
	
	VarSetCapacity(area, 16)
	WinGetActiveStats, AT, AW, AH, AX, AY  ; Get Active Window Stats
	
	If (toggle = "1") {  ; Hide
		Top := A_ScreenHeight
		WinHide, ahk_class Shell_TrayWnd  ; Hide Taskbar
		WinHide, Start ahk_class Button  ; Hide Start Button
		WinMove, %AT%,,,0,, %A_ScreenHeight%  ; Increase Active Window's Height
	} Else {  ; Show
		Top := A_ScreenHeight - hTB  ; Screen Height - Taskbar Height
		WinShow, ahk_class Shell_TrayWnd  ; Show Taskbar
		WinShow, Start ahk_class Button  ; Show Start Button
		WinMove, %AT%,,,0,, (A_ScreenHeight-hTB)  ; Decrease Active Window's Height
	}
	
	DllCall("ntoskrnl.exe\RtlFillMemoryUlong", UInt,&area + 0, UInt,4, UInt,0)
	DllCall("ntoskrnl.exe\RtlFillMemoryUlong", UInt,&area + 4, UInt,4, UInt,0)
	DllCall("ntoskrnl.exe\RtlFillMemoryUlong", UInt,&area + 8, UInt,4, UInt,A_ScreenWidth)
	DllCall("ntoskrnl.exe\RtlFillMemoryUlong", UInt,&area + 12,UInt,4, UInt,Top)
	DllCall("SystemParametersInfo", UInt,0x2F, UInt,0, UInt,&area, UInt,0)
	return		
}
	