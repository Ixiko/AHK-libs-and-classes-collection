splashNoteFull(rows = 10, defaultTxt = ""){
	global  ; Set variable as global - rename 'vinput' below if you use 'input' as a variable elsewhere.
	input = ; Clear input variable
  	IniRead()
	Gui, splashNoteFull: -Caption -Border +AlwaysOnTop +OwnDialogs
	Gui, splashNoteFull: Color, 221a0f, 221a0f
	Gui, splashNoteFull: Margin, 150, 150 
    Gui, splashNoteFull: Font, s18 cd3af86, Traveling _Typewriter
    Gui, splashNoteFull: Add, Edit, r%rows% vinput w1050 -E0x200 -VScroll, %defaultTxt%
          ; Edit box with variable rows. Press ctrl+enter for new line and enter to submit. 
	Gui, splashNoteFull: Add, Button, x-100 y-100 Default, OK 
          ; OK button is hidden off the canvas, but is needed for submitting with enter.
	Gui, splashNoteFull: +OwnDialogs
	Gui, splashNoteFull: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% 
	Send {Right}
	WinWaitClose, ahk_class AutoHotkeyGUI 
          ; Wait until GUI has disappeared
    splashNoteFullGuiEscape:  ; Pressing Esc, Enter, or Alt+F4 submits and returns 
	Gui, splashNoteFull: Submit
    Gui, splashNoteFull: Destroy
    Return
}
