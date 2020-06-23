splashConsole(text, default = ""){
	global 
          ; Set variable as global - rename 'vinput' below if you use 'input' as a variable elsewhere.
	Gui, splashConsole: -Caption -Border +AlwaysOnTop +OwnDialogs
	Gui, splashConsole: Color, 221A0F, 221A0F
	Gui, splashConsole: Margin, 50, 25
	Gui, splashConsole: Font, s10 bold cFF9900, Consolas
	Gui, splashConsole: Add, Text, +Wrap w100, %text%
	Gui, splashConsole: Add, Edit, vinput -WantReturn x120 y26 w345 -E0x200 -VScroll, %default%
	Gui, splashConsole: Add, Button, x-100 y-100 Default, OK 
          ; OK button is hidden off the canvas, but is needed for submitting with enter.
	Gui, splashConsole: +OwnDialogs
	Gui, splashConsole: Show, x0 y0 h100 w1366, AHK Console
	WinWaitClose, ahk_class AutoHotkeyGUI 
          ; Wait until GUI has disappeared
    splashConsoleGuiEscape:  ; Pressing Esc, Enter, or Alt+F4 submits and returns 
	splashConsoleGuiClose:
	splashConsoleButtonOK:
	Gui, splashConsole: Submit
	Gui, splashConsole: Destroy
	; Progress, off
	Return
}
