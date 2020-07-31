#include ..\SCI.ahk
#singleinstance force

;---------------------
; Add multiple components.

Gui +LastFound
hwnd:=WinExist()

sci1 := new scintilla(hwnd, 0, 0, 590, 190) ; you can put the parameters here
sci2 := new scintilla

sci2.add(hwnd, 0, 200, 590, 190) ; or you can use the add function like this

Gui, show, w600 h400
return

GuiClose:
    exitapp