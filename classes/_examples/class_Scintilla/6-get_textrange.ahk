#include ..\SCI.ahk
#singleinstance force

;---------------------
; This script will add a component, put some text on it and then retrieve a specified range of text and put it in a variable

Gui +LastFound
sci := new scintilla(WinExist())

sci.SetWrapMode(true), sci.SetText(unused, "this is some cool text") ; Adds some text to the scintilla control and sets the option of word-wrap
Gui, show, w600 h400

sci.GetTextRange([8,13], myvar) ; Gets the specified range of text from the control and puts it into a variable. Range starts at 0.
msgbox % myvar
return

GuiClose:
    ExitApp