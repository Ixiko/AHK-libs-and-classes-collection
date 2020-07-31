#include ..\SCI.ahk
#singleinstance force

;---------------------
; This script will add a component, put some text on it and then retrieve it and put it in a variable

Gui +LastFound
sci := new scintilla(WinExist())

sci.SetWrapMode(true), sci.SetText(unused, "This is some cool text") ; Adds some text to the scintilla control and sets the option of word-wrap
Gui, show, w600 h400

sci.GetText(sci.getLength()+1, myvar) ; Gets the text of the control and puts it into a variable
msgbox % myvar
return

GuiClose:
    ExitApp