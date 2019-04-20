splashNoteFull(rows = 10, defaultTxt = ""){
	global  ; Set variable as global - rename 'vinput' below if you use 'input' as a variable elsewhere.
	input = ; Clear input variable
  	IniRead()
	Gui, splashNote: -Caption -Border +AlwaysOnTop +OwnDialogs
	Gui, splashNote: Color, 221a0f, 221a0f
	Gui, splashNote: Margin, 150, 150 
    Gui, splashNote: Font, s24 cd3af86, Traveling _Typewriter
    Gui, splashNote: Add, Edit, r%rows% vinput -WantReturn w1250 -E0x200 -VScroll, %defaultTxt%
          ; Edit box with variable rows. Press ctrl+enter for new line and enter to submit. 
	Gui, splashNote: Add, Button, x-100 y-100 Default, OK 
          ; OK button is hidden off the canvas, but is needed for submitting with enter.
	Gui, splashNote: +OwnDialogs
	Gui, splashNote: Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth% 
	Send ^{End}
	WinWaitClose, ahk_class AutoHotkeyGUI 
          ; Wait until GUI has disappeared
    splashNoteGuiEscape:  ; Pressing Esc, Enter, or Alt+F4 submits and returns 
    Gui, splashNote: Destroy
    Return
	splashNoteGuiClose:
	splashNoteButtonOK:
	Gui, splashNote: Submit
	Gui, splashNote: Destroy
	; Progress, off
	Return
}

/* 
This function is useful for minimalistic text input.
Call it by passing the number of rows, you wish to use, along with the text.
It will return the edit box text in the 'input' variable. 
For example: 
      splashUI(2, "Evaluation")
      if input <> ; if input is not empty 
      MsgBox, %input%

# Todo: better implementation of cancel events  */
