splashList_AltSubmit(text, list){ ; Pass help text and |-separated list
  global
  choice =  ; Clear previous choices
  rows = ; Clear previous number of rows
  Loop, Parse, list, | ; Calculate ListBox height 
    rows = %A_Index%  
  if text <> ; If text not empty 
  {
	boxWidth := StrLen(text) * 15 ; and width 
	if boxWidth < 300
		boxWidth = 300
  }
  Else 
  	boxWidth = 200
  IniRead()
  Gui, splashList_AltSubmit: -Caption -Border +AlwaysOnTop +OwnDialogs
  Gui, splashList_AltSubmit: Color, %background%, %background%
  Gui, splashList_AltSubmit: Margin, 10, 10
  Gui, splashList_AltSubmit: Font, s20 bold c%header_color%, %header%
  if text <> ; If text not empty 
  	Gui, splashList_AltSubmit: Add, Text, , %text%
  Gui, splashList_AltSubmit: Font, s%size% %style% c%font_color%, %font%
  Gui, splashList_AltSubmit: Add, ListBox, ReadOnly Choose1 AltSubmit vchoice r%rows% gMyAltSubmitListBox w%boxWidth%, %list% 
  Gui, splashList_AltSubmit: Add, Button, x-100 y-100 Default, OK ; Hide default button, as we're going to use enter to submit
  Gui, splashList_AltSubmit: Show, x0 y0 h%A_ScreenHeight%, GUI splashList_AltSubmit ; Create and display the GUI  
  WinWaitClose, ahk_class AutoHotkeyGUI 
  Return 

  
  MyAltSubmitListBox:
  if A_GuiControlEvent <> DoubleClick
    return
  ; Otherwise, the user double-clicked a list item.
  Gui, splashList_AltSubmit: Submit
  Gui, splashList_AltSubmit: Destroy
  Return
  
  splashList_AltSubmitGuiEscape:
  choice = 
  Gui, splashList_AltSubmit: Destroy
  Return 

  splashList_AltSubmitButtonOK:
  Gui, splashList_AltSubmit: Submit
  Gui, splashList_AltSubmit: Destroy
  Return
}