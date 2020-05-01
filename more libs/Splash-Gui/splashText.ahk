splashText(text, rows = 1, helptext = "", defaultTxt = "", timeout = ""){
	global  ; Set variable as global - rename 'vinput' below if you use 'input' as a variable elsewhere.
	input = ; Clear input variable
  	IniRead()
  	guiX := A_ScreenWidth - 600 
	Gui, splashText: -Caption -Border +AlwaysOnTop +OwnDialogs
	Gui, splashText: Color, %background%, %background%
	Gui, splashText: Margin, 50, 25 
	if rows = 1
	    Gui, splashText: Font, s%size% %style% c%font_color%, %font%
	Else 
	    Gui, splashText: Font, s%size% %style% c%font_color%, %typingFont%
    Gui, splashText: Add, Edit, r%rows% vinput -WantReturn w400 -E0x200 -VScroll, %defaultTxt%
          ; Edit box with variable rows. Press ctrl+enter for new line and enter to submit. 
	Gui, splashText: Font, s10 c%font_color%, %header%
    if helptext <> ; If helptext not empty 
    	Gui, splashText: Add, Text,, %helptext%
	Gui, splashText: Add, Button, x-100 y-100 Default, OK 
          ; OK button is hidden off the canvas, but is needed for submitting with enter.
	Gui, splashText: +OwnDialogs
	Gui, splashText: Show, x%guiX% W500 ; x0 y0 h100 w%A_ScreenWidth% 
 	splashProgress(text) ; Show splash text 
; Progress, show CT%header_color% CW%background% fm20 WS700 c00 x0 w300 h125 zy60 zh0 B0, , %text%,, %header% 
	WinWaitClose, ahk_class AutoHotkeyGUI 
          ; Wait until GUI has disappeared
    splashTextGuiEscape:  ; Pressing Esc, Enter, or Alt+F4 submits and returns 
    Gui, splashText: Destroy
    Return
	splashTextGuiClose:
	splashTextButtonOK:
	Gui, splashText: Submit
	Gui, splashText: Destroy
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
