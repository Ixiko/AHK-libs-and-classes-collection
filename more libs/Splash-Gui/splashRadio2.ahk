splashRadio2(text, options){ ; Pass help text and |-separated options to populate the radio-button GUI
  global
  choice = ; Clear previous choices
  StringSplit, OutputArray, options, "|"
  Gui, 97: -Caption -Border +AlwaysOnTop +OwnDialogs
  Gui, 97: Color, 221A0F
  Gui, 97: Margin, 10, 10
  Gui, 97: Font, s13 bold cFF9900, Courier New
  Gui, 97: Add, Text, Center , %A_ScriptName%
  Gui, 97: Font, s2 cFF9900, Consolas
  Gui, 97: Add, Text, 
  Gui, 97: Font, s12 normal cFF9900, Consolas
  loop, %OutputArray0%
  {
    option := OutputArray%A_Index%
    if A_Index = 1
      Gui, 97: Add, Radio, vRadio%A_Index% Checked, %option% 
    Else
      Gui, 97: Add, Radio, vRadio%A_Index%, %option%
  }
  Gui, 97: Font, s4 cFF9900, Consolas
  Gui, 97: Add, Text, 
  Gui, 97: Font, s12 cFF9900, Consolas
  Gui, 97: Add, Text,, %text% 
  Gui, 97: Add, Button, x-100 y-100 Default, OK ; Hide default button, as we're going to use enter to submit
  Gui, 97: Show, x0 y0 H768, 
  WinWaitClose, ahk_class AutoHotkeyGUI 
  97GuiEscape:
  97ButtonGuiCancel:
  Gui, 97: Destroy
  Return

  97ButtonOK:
  Gui, 97: Submit
  Gui, 97: Destroy
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