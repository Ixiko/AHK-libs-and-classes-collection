#Include ..\AHKLink.ahk
SetWorkingDir .. ; the index file is way over there in the parent directory
MsgBox % AHKLink_TSVRet("#Delimiter")    ; AutoHotkey_L     - http://www.autohotkey.net/~Lexikos/AutoHotkey_L/docs/commands/_EscapeChar.htm#Delimiter
MsgBox % AHKLink_TSVRet("#Delimiter", 1) ; sets ForceBasic - http://www.autohotkey.com/docs/commands/_EscapeChar.htm#Delimiter
MsgBox % AHKLink_TSVRet("Hotkeys", 0)