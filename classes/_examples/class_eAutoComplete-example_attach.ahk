#NoEnv
#SingleInstance force
#Warn
; Windows 8.1 64 bit - Autohotkey v1.1.28.00 32-bit Unicode

#Include %A_ScriptDir%\eAutocomplete.ahk

WinWait, ahk_class Notepad
ControlGet, eHwnd, Hwnd,, Edit1, % "ahk_id " . WinExist()
A := eAutocomplete.attach(eHwnd)
Loop, 3
	Menu, startAt, Add, % a_index, startAt
Menu, Tray, Add, &Start at..., :startAt
Menu, startAt, Check, % A.startAt
Menu, Tray, Add, &AutoAppend, autoAppend
Menu, Tray, Add, &Regular expressions (*), matchModeRegEx
Menu, Tray, Check, &Regular expressions (*)
Menu, Tray, Add, Append &new occurrences, appendHapax
Menu, Tray, Add,
Menu, Tray, Add, &Word list..., setSource
Menu, Tray, Add, &Disable, disabled
Menu, Tray, Add, &Exit, exit
Menu, Tray, NoStandard
OnExit, handleExit
TrayTip, % A_ScriptName, Please first select a word list.
return


startAt:
	Menu, startAt, UnCheck, % A.startAt
	Menu, startAt, Check, % (A.startAt:=A_ThisMenuItemPos)
return

autoAppend:
matchModeRegEx:
appendHapax:
	A[ A_ThisLabel ] := !A[ A_ThisLabel ]
	Menu, Tray, ToggleCheck, % A_ThisMenuItem
return

disabled:
	Menu, Tray, Rename, % A_ThisMenuItem, % (A.disabled:=!A.disabled) ? "&Enable" : "&Disable"
return

setSource:
	FileSelectFile, path, 1,, Select a word list, Text Documents (*.txt)
	SplitPath, % path,,, extension
	ErrorLevel += (extension <> "txt")
	if (!ErrorLevel && eAutocomplete.addSourceFromFile("Default", path, "`n") && A.setSource("Default"))
		return
	MsgBox, 64,, Could not load word list.
return

exit:
handleExit:
A.dispose()
ExitApp
