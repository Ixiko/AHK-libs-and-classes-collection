#include ..\SCI.ahk
#singleinstance force

;---------------------
; This script adds a component with default values.
; If no path was specified when creating the object it expects scilexer.dll to be on the script's location.
; The default values are calculated to fit optimally on a 600x400 GUI/Control

Gui +LastFound
sci := new scintilla(WinExist())

Gui, show, w600 h400
return

GuiClose:
    exitapp