splashRadio(text, options){ ; Pass help text and |-separated options to populate the radio-button GUI
  global
  choice =  ; Clear previous choices
  IniRead()
  StringSplit, OutputArray, options, "|"
  Gui, splashRadio: -Caption -Border +AlwaysOnTop +OwnDialogs
  Gui, splashRadio: Color, %backC% ;
  Gui, splashRadio: Margin, 10, 10
  Gui, splashRadio: Font, s%size% bold c%secondaryC%, %font%
  Gui, splashRadio: Add, Text, , %text%
  Gui, splashRadio: Font, s%size% %style% c%fontC%, %font%
  loop, %OutputArray0%
  {
    option := OutputArray%A_Index%
    if A_Index = 1
      Gui, splashRadio: Add, Radio, vRadio%A_Index% Checked, %option% 
    Else if A_Index = 26
      Gui, splashRadio: Add, Radio, x200 y36 vRadio%A_Index%, %option%
    Else if A_Index = 54
      Gui, splashRadio: Add, Radio, x400 y36 vRadio%A_Index%, %option%
    Else if A_Index = 80
      Gui, splashRadio: Add, Radio, x600 y36 vRadio%A_Index%, %option%
    Else
      Gui, splashRadio: Add, Radio, vRadio%A_Index%, %option%
  }
  Gui, splashRadio: Add, Button, x-100 y-100 Default, OK ; Hide default button, as we're going to use enter to submit
  Gui, splashRadio: Show, x0 y0 h%A_ScreenHeight%, GUI splashRadio ; Create and display the GUI  
  ; Progress, show CT%fontC% CW221A0F fs24 WS700 c00 w300 h100 zy60 zh0 B0, %text%,,, %font%
  WinWaitClose, ahk_class AutoHotkeyGUI 
  Return 
  ; splashRadioGuiClose:
  
  splashRadioGuiEscape:
  choice = 
  Gui, splashRadio: Destroy
  Return 

  splashRadioButtonOK:
  Gui, splashRadio: Submit
  Gui, splashRadio: Destroy
  loop,  %OutputArray0% 
  {
    if Radio%A_Index% = 1 
    {
      choiceN = %A_Index%
      choice := % OutputArray%A_Index% ; Returns the text of selected radio button  
    }
  }
  StringReplace, choice, choice, & ; Remove "&" shortcut marker
  Return
}