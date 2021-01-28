#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\eAutocomplete.ahk

global ahk_dir
RegRead, ahk_dir, HKEY_LOCAL_MACHINE, SOFTWARE\AutoHotkey, InstallDir
if (ErrorLevel) ; Not found, so look for it in some other common locations.
{
	if (A_AhkPath)
		SplitPath, A_AhkPath,, ahk_dir
	else IfExist ..\..\AutoHotkey.chm
		ahk_dir = ..\..
	else IfExist %A_ProgramFiles%\AutoHotkey\AutoHotkey.chm
		ahk_dir = %A_ProgramFiles%\AutoHotkey
	else {
		MsgBox Could not find the AutoHotkey folder.
	ExitApp
	}
} ; https://www.autohotkey.com/docs/scripts/index.htm#ContextSensitiveHelp

list =
(Join`r`n
Control	, Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlClick	[, Control-or-Pos, WinTitle, WinText, WhichButton, ClickCount, Options, ExcludeTitle, ExcludeText]
ControlFocus	[, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGet	, OutputVar, Cmd [, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetFocus	, OutputVar [, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetPos	[, X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlGetText	, OutputVar [, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlMove	, Control, X, Y, Width, Height [, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlSend	[, Control, Keys, WinTitle, WinText, ExcludeTitle, ExcludeText]
ControlSetText	[, Control, NewText, WinTitle, WinText, ExcludeTitle, ExcludeText]
)
global params := Object(StrSplit(list, ["`r`n", "`t"])*)
source := eAutocomplete.WordList.buildFromVar("myList", list)
; Load a list of suggestions from a file and prepare the given list for use as an autocompletion list.
query := source.Query
query.Word.minLength := 1
query.Sift.option := "OC" ; Needle is ORDERED CHARACTERS to be searched for even non-consecutively but in the given order in Haystack item
GUI, New, -DPISCALE
GUI, Font, s12, Segoe UI
GUI, Add, Edit, hwndhEdit w1000 h400
GUI, Show, AutoSize, eAutocomplete
eAutocomplete.wrap(hEdit)
eAutocomplete.resource := source.name
Menu := eAutocomplete.Menu
Menu.positioningStrategy := "DropDownList" ; the menu is intended to be displayed beneath the host control, in the manner of a combobox menu
Menu.InfoTip.font.setCharacteristics("Segoe UI", "s11")
Menu.itemsBox.maxVisibleItems := 5
eAutocomplete.onSuggestionLookUp("eA_onSuggestionLookUp")
eAutocomplete.onComplete("eA_onComplete")
eAutocomplete.onReplacement("eA_onReplacement")
return

eA_onComplete(_suggestion, ByRef _expandModeOverride:="") {
return _suggestion . params[_suggestion]
}
eA_onReplacement(_suggestion, ByRef _expandModeOverride:="") {
	static EXPAND_NO_SPACE := 0
	IfWinNotExist, AutoHotkey Help
	{
		Run %ahk_dir%\AutoHotkey.chm
		WinWait AutoHotkey Help
	}
	; The above has set the "last found" window which we use below:
	WinActivate
	WinWaitActive
	StringReplace, _suggestion, _suggestion, #, {#}
	; MsgBox % _suggestion
	SendInput, !n{home}+{end}%_suggestion%{enter}
	_expandModeOverride := EXPAND_NO_SPACE
} ; see also: https://www.autohotkey.com/docs/scripts/index.htm#ContextSensitiveHelp
eA_onSuggestionLookUp(_selectionText) {
return params[_selectionText]
}

!x::
ExitApp
