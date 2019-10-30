;
;
; AutoHotkey:	 v1.1.26.01 Unicode 32-bit (Installed)
; Language:		 English
; Author:        A_AhkUser wrote the lib and the example script from which this is derived,brutus_skywalker just wrote the active wordlist parsing
; OS:  			 WIN_7 64-bit Service Pack 1 v6.1.7601 (WIN32_NT)  , 6050.68MB RAM
; Date:          Wednesday, May 23, 2018 0:37
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
;#NoTrayIcon


;#Include %A_ScriptDir%\..\class_eAutocomplete.ahk


While !GetTextFromControl()		;wait until supported edit control is active.
	Sleep 10


Gosub, winChanged		;initialise eAutocomplete & wordlist from active window
SetTimer, winChanged, 500		;check for window change,to update wordlist on window change.
SetTimer, updateWordList, 2000	;attempt to update wordlist every 2sec since last wordlist update,holding until user releases all keys before proceeding with update.

Loop, 3
	Menu, startAt, Add, % a_index, startAt
Menu, Tray, Add, &Start at..., :startAt
Menu, startAt, Check, % A.startAt
Menu, Tray, Add, &AutoAppend, autoAppend
Menu, Tray, Add, &Regular expressions (*), matchModeRegEx
Menu, Tray, Check, &Regular expressions (*)
Menu, Tray, Add, Append &new occurrences, appendHapax
Menu, Tray, Add,
Menu, Tray, Add, &Disable, disabled
Menu, Tray, Add, &Exit, exit
Menu, Tray, NoStandard
OnExit, handleExit
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


exit:
handleExit:
A.dispose()
ExitApp


winChanged:
If (WinChanged() AND GetTextFromControl()){		;GetTextFromControl() only returns value if a supported edit control is detected
;reattach to supported edit control on active window
	WinGet, controlList, ControlList, A
	WinGet, ProcName , ProcessName, A

	;currently scintilla edit controls appear incompatible.
	if InStr(controlList, "Edit3"){
		ControlGet, eHwnd, Hwnd,, Edit3, % "ahk_id " . WinExist()
		A.dispose()
		A := eAutocomplete.attach(WinExist(), eHwnd)
	}else if InStr(controlList, "Edit1"){
		ControlGet, eHwnd, Hwnd,, Edit1, % "ahk_id " . WinExist()
		A.dispose()
		A := eAutocomplete.attach(WinExist(), eHwnd)
	}else if InStr(controlList, "TConTEXTSynEdit1"){
		ControlGet, eHwnd, Hwnd,, TConTEXTSynEdit1, % "ahk_id " . WinExist()
		A.dispose()
		A := eAutocomplete.attach(WinExist(), eHwnd)
	}else if InStr(controlList, "RICHEDIT50W1"){
		ControlGet, eHwnd, Hwnd,, RICHEDIT50W1, % "ahk_id " . WinExist()
		A.dispose()
		A := eAutocomplete.attach(WinExist(), eHwnd)
	}

Gosub, updateWordList
}
Return


updateWordList:
	SetBatchLines, -1	;go as fast as possible to reduce update delay

	thisEditorText := GetTextFromControl()

	;don't rebuild word list if text content of window hasn't changed
	IfEqual, thisEditorText, %lastEditorText%
		{
		SetBatchLines, 10ms	;default speed
		Return
		}

	SetTimer, updateWordList, off
	While GetAllKeysPressed(){		;wait until user is done typing before updating the word list further
		Sleep, 1000
		}
	SetTimer, updateWordList, on


	;Get Wordlist
	this_WordList := AlphaSortList(GetActiveWinWordList())		;get & sort worldlist from active window text
	If (!this_WordList){	;if current window has no wordlist,retain old one.
		SetBatchLines, 10ms	;default speed
		Return
		}


	;rebuild wordlist
	A.addSource("dynamicWordList", this_WordList, "`n")
	A.setSource("dynamicWordList") ; defines the word list to use
	; ToolTip, %WordList%
	SoundBeep					;DEBUG: SIGNIFY UPDATE

	lastEditorText := thisEditorText
	SetBatchLines, 10ms	;default speed
	Return



GetActiveWinWordList(){
	Static lastText
	Static lastWordList
	text := GetTextFromControl()
	If !text	;if no text can be retrieved from a control get all text in window
		WinGetText, text, A
	;rebuild WordList only if text in editor has changed
	IfEqual, text, %lastText%
		Return lastWordList
	lastText := text
	StringReplace, text, text, `,, `n, ALL
	StringReplace, text, text, `r`n, `n, ALL
	StringReplace, text, text, %A_Space%, `n, ALL
	StringReplace, text, text, %A_Tab%, `n, ALL
	;remove white spaces
	wordListText := RegExReplace(text , "(^|\R)\K\s+")
	;rebuild wordlist using only strings longer than 3 characters
	Wordlist:=""
	Loop, Parse, wordListText, `n
		If StrLen(A_LoopField) >= 3		;strings of over 3 characters
			IfNotInString, Wordlist, %A_Space%%A_LoopField%%A_Space%	;avoid repeated strings
				Wordlist.= " " A_LoopField " " "`n"	;add spaces on either side so that words in other word can easily be added to list
	StringReplace, Wordlist, Wordlist, %A_Space%, , ALL ;spaces are no longer needed as list is done building
	lastWordList := WordList
	Return WordList
}

GetTextFromControl(){
	WinGet, controlList, ControlList, A
	WinGet, ProcName , ProcessName, A

	if InStr(controlList, "Edit3")
		ControlGetText, text ,Edit3, A
	else if InStr(controlList, "Edit1")
		ControlGetText, text ,Edit1, A
	else if InStr(controlList, "TConTEXTSynEdit1")
		ControlGetText, text ,TConTEXTSynEdit1, A
	else if InStr(controlList, "RICHEDIT50W1")
		ControlGetText, text ,RICHEDIT50W1, A

	return (text ? text : "")
}

AlphaSortList(list){
StringSplit, line, list, `n,`r
Loop, parse, list, `n, `r
	data1 .= (data1?"`n":"") A_LoopField "|" A_Index
data1 := RegExReplace(data1, "[ `,“”\(\)\/`:]")
sort, data1
loop, parse, data1, `n,`r
	l := RegExReplace(A_LoopField, ".*\|")	, out .= (out?"`n":"") line%l%
Return out
}

; returns an variable containing names of all keys pressed down currently.
; Pass "L" (default) to check only the logical state of the keys, and "P" to check the physical state
GetAllKeysPressed(mode = "L") {
SetBatchLines, -1
		keys = ``|1|2|3|4|5|6|7|8|9|0|-|=|[|]\|;|'|,|.|/|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|Esc|Tab|CapsLock|LShift|RShift|LCtrl|RCtrl|LWin|RWin|LAlt|RAlt|Space|AppsKey|Up|Down|Left|Right|Enter|BackSpace|Delete|Home|End|PGUP|PGDN|PrintScreen|ScrollLock|Pause|Insert|NumLock|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20
	; '|' isn't a key itself (with '\' being the "actual" key), so okay to use is as a delimiter
	Loop Parse, keys, |
	{
		key = %A_LoopField%
		isDown :=  GetKeyState(key, mode)
		if isDown
			pressed .= key
	}
SetBatchLines, 10ms
	return pressed
}

WinChanged(){
	static lastHwnd
	If ( WinExist("A") != lastHwnd ){
		lastHwnd := WinExist("A")
		Return True
	}
}