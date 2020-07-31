#include ..\SCI.ahk
#singleinstance force

;---------------------
; Here we add a component embedded in a tab.
; If the variables "x,w,h" are empty the default values are used.

Gui, add, Tab2, HWNDhwndtab x0 y0 w600 h420 gtabHandler vtabLast,Scintilla|Empty

sci := new scintilla
sci.Add(hwndtab, x, 25, w, h, a_scriptdir "\scilexer.dll") ; we set the parent hwnd to be the tab in this case and those the main window

Gui, show, w600 h420
return

; This additional code is for hiding/showing the component depending on which tab is open
; In this example the Tab named "Scintilla" is the one that contains the control.
; If you switch the words "show" and "hide" the component will be shown when the tab called "Empty" is active.

tabHandler:                                 ; Tab Handler for the Scintilla Control
Gui, submit, Nohide
Control,% tabLast = "Scintilla" ? "Show" : "Hide",,, % "ahk_id " sci.hwnd
return

GuiClose:
    exitapp