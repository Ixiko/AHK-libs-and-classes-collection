#include ..\SCI.ahk
#singleinstance force

;---------------------
; This script adds a component with default values and the "Border" style. 
; More styles can be found here: http://msdn.microsoft.com/en-us/library/czada357.aspx
; You can copy/paste them or just leave the WS_ part out and put only the style name. e.g. "border"

Gui +LastFound
sci:= new scintilla
sci.Add(WinExist(), x, y, w, h, DllPath, "WS_BORDER") ; emtpy variables will make the wrapper use the default values

Gui, show, w600 h400
return

GuiClose:
    exitapp