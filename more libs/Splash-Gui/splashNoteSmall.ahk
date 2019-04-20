splashNoteSmall(rows = 10, defaultTxt = ""){
	global  ; Set variable as global - rename 'vinput' below if you use 'input' as a variable elsewhere.
	input = ; Clear input variable
  	IniRead()
	Gui, splashNoteSmall: -Caption -Border +AlwaysOnTop +OwnDialogs
	Gui, splashNoteSmall: Color, 221a0f, 221a0f
	; Gui, splashNoteSmall: Margin, 150, 150 
    Gui, splashNoteSmall: Font, s14 cd3af86, Traveling _Typewriter
    Gui, splashNoteSmall: Add, Edit, r%rows% vinput WantReturn -E0x200 -VScroll, %defaultTxt%
          ; Edit box with variable rows. Press ctrl+enter for new line and enter to submit. 
	Gui, splashNoteSmall: Add, Button, x-100 y-100 Default, OK 
          ; OK button is hidden off the canvas, but is needed for submitting with enter.
	Gui, splashNoteSmall: +OwnDialogs
	Gui, splashNoteSmall: Show, x0
	Send {Right}
	WinWaitClose, ahk_class AutoHotkeyGUI 
          ; Wait until GUI has disappeared
    splashNoteSmallGuiEscape:  ; Pressing Esc, Enter, or Alt+F4 submits and returns 
	Gui, splashNoteSmall: Submit
    Gui, splashNoteSmall: Destroy
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
