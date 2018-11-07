/*
	THIS EXAMPLE IS INCOMPLETE!!!
*/
#SingleInstance force
#include ..\..\_CCF_Error_Handler_.ahk
#include ..\..\CCFramework.ahk
#include ..\..\Unknown\Unknown.ahk
#include ..\RichEditOLE.ahk

DllCall("LoadLibrary", "Str", "Msftedit.dll", "Uint")

Gui +LastFound
hCtrl := DllCall("CreateWindowEx"
                  , "Uint", 0
                  , "str" , "RICHEDIT50W"
                  , "str" , ""
                  , "Uint", 0x40000000|0x10000000
                  , "int" , 5
                  , "int" , 5
                  , "int" , 200
                  , "int" , 200
                  , "Uint", WinExist()
                  , "Uint", 0
                  , "Uint", 0
                  , "Uint", 0)

edit := RichEditOLE.FromHWND(hCtrl)
doc := ComObjEnwrap(edit.QueryInterface("{8CC497C0-A1DF-11ce-8098-00AA0047BE5D}"))

Gui Show, w210 h210, test

sleep 3000
doc.Freeze()

sleep 3000
doc.Unfreeze()

return

GuiClose:
ExitApp
return