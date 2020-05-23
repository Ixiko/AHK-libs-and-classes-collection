/*
	Makes the Gui window NoActivate but Clickable
	
	Usage: 
		Gui_NoActivate(GuiHwnd, EnableEdit := False, Disable_RButton := False)

	Parameters:
		GuiHwnd    - The Gui's hwnd
		EnableEdit - True or False (default). Whether activates the GUI when an Edit Control is focused.
		Disable_RButton - True or False (default)
*/
Gui_NoActivate(p*) {
	Gui_NoActivate.Apply(p*)
}

Class Gui_NoActivate {
	static WS_EX_NOACTIVATE := 0x08000000

	Apply(GuiHwnd, EnableEdit := False, Disable_RButton := False) {
		Gui, %GuiHwnd%: +LastFound ; WinTitle is not working for WinSet
		WinSet, ExStyle, % "+" this.WS_EX_NOACTIVATE

		OnMessage( 0xA1, ObjBindMethod(this, "WM_NCLBUTTONDOWN") )
		OnMessage( 0xA0, ObjBindMethod(this, "WM_NCMOUSEMOVE")   )
		If EnableEdit {
			OnMessage( 0x06, ObjBindMethod(this, "WM_ACTIVATE") )
			OnMessage( 0x201, ObjBindMethod(this, "WM_LBUTTONDOWN") )
		}
		If Disable_RButton
			OnMessage( 0x204, ObjBindMethod(this, "Disable_RButton") ) ; WM_RBUTTONDOWN

		this.GuiHwnd := GuiHwnd
	}

	; Remove WS_EX_NOACTIVATE style, when Gui is dragging
	WM_NCLBUTTONDOWN(wParam, lParam, msg, hwnd) {
		this.pre_hForegroundWnd := msg ? DllCall("GetForegroundWindow") : ""
		WinSet, ExStyle, % "-" this.WS_EX_NOACTIVATE, ahk_id %hwnd%
		DllCall("SetForegroundWindow", "Uint", hwnd)
	}

	; Re-add WS_EX_NOACTIVATE style, when Gui is dragging finished
	WM_NCMOUSEMOVE() {
		If !this.pre_hForegroundWnd || GetKeyState("LButton", "P")
			Return
		WinSet, ExStyle, % "+" this.WS_EX_NOACTIVATE, % "ahk_id " this.GuiHwnd
		DllCall("SetForegroundWindow", "Uint", this.pre_hForegroundWnd)
		this.pre_hForegroundWnd := ""
	}

	; Detect if clicked on an edit control
	WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
		SendMessage, 0x00BA, 0, 0,, ahk_id %hwnd% ; EM_GETLINECOUNT = 0x00BA
		If (errorLevel > 0) {
			this.WM_NCLBUTTONDOWN(0, 0, 0, this.GuiHwnd) ; Activate the Gui window
			this.WinWaitNotActive := True
		}
	}

	WM_ACTIVATE(wParam) {
		If this.WinWaitNotActive && (wParam = 0) { ; Gui is deactivated
			this.WinWaitNotActive := ""
			WinSet, ExStyle, % "+" this.WS_EX_NOACTIVATE, % "ahk_id " this.GuiHwnd
		}
	}

	Disable_RButton() {
		Return 0
	}
}