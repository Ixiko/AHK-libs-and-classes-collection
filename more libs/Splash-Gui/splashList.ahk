splashList(text, list, sorted=1, fontSize = 12){ ; Pass help text and |-separated list
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
  	boxWidth = 300
  IniRead()
  Gui, splashList: -Caption -Border +AlwaysOnTop +OwnDialogs
  Gui, splashList: Color, %background%, %background%
  Gui, splashList: Margin, 10, 10
  Gui, splashList: Font, s20 bold c%header_color%, %header%
  if text <> ; If text not empty 
  	Gui, splashList: Add, Text, , %text%
  Gui, splashList: Font, s%fontSize% %style% c%font_color%, %font%
  if sorted = 1
    Gui, splashList: Add, ListBox, sort ReadOnly Choose1 vchoice r%rows% gMyListBox w%boxWidth%, %list% 
  Else
    Gui, splashList: Add, ListBox, ReadOnly Choose1 vchoice r%rows% gMyListBox w%boxWidth%, %list% 
  Gui, splashList: Add, Button, x-100 y-100 Default, OK ; Hide default button, as we're going to use enter to submit
  Gui, splashList: Show, x0 y0 h%A_ScreenHeight%, GUI splashList ; Create and display the GUI  
  WinWaitClose, ahk_class AutoHotkeyGUI 
  Return 

  
  MyListBox:
  if A_GuiControlEvent <> DoubleClick
    return
  ; Otherwise, the user double-clicked a list item.
  Gui, splashList: Submit
  Gui, splashList: Destroy
  Return
  
  splashListGuiEscape:
  choice = 
  Gui, splashList: Destroy
  Return 

  splashListButtonOK:
  Gui, splashList: Submit
  Gui, splashList: Destroy
  Return
}