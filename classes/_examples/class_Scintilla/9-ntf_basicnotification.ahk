#include ..\SCI.ahk
#singleinstance force

/*
    ---------------------
    In this example we will catch the scintilla notifications.
    For that we just have to set the variable sciObj.notify with the name of a custom function which will be called
    whenever a scintilla message is sent.

    There are some variables in the main object that are set by different messages. Please read the code for information on this.
*/

Gui +LastFound
sci := new scintilla(WinExist())

; Set some options
sci.SetWrapMode(true), sci.Notify := "Notify" ; The notify option tells the wrapper which function to call when WM_NOTIFY is sent

Gui, Show, w600 h400
return

GuiClose:
ExitApp

Notify(wParam, lParam, msg, hwnd, obj){

if (obj.scnCode = SCN_CHARADDED)
tooltip % chr(obj.ch) ; obj is in this case the scintilla object above. The obj.sc variable contains the latest character added to the control
return
}