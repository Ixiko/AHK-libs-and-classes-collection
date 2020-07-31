#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\eAutocomplete.ahk

var =
(
A_AHKVersion%A_Tab%%A_AHKVersion%
)
/*
Autocompletion data are assumed to be described in a linefeed-separated (CRLF, preferably) list
of a TSV-formatted lines.
A line can describe up to three items, in a tabular structure:
- the first tab-separated item represents the string value which is intended to be
displayed in the drop-down list, as an actual suggestion.
- the other two items represent potential replacement strings - aside from being able to
be displayed as info tips.
*/
eAutocomplete.setSourceFromVar("myAutocompleteList", var) ; create a new autocomplete
; dictionary, called 'myAutocompleteList', from a variable
GUI, New
GUI, +Resize +hwndGUIID ;  +HwndGUIID stores the HWND (unique identifier) of the window in GUIID
myAutocomplete := eAutocomplete.create(GUIID, "w300 h300 +Resize")
; create the edit control and wrap it into an eAutocomplete object
myAutocomplete.disabled := true ; disable temporarily the instance so that we can programmatically
; set the content of its host edit control without triggering autocompletion
infoTip =
(Join`r`n
. type A_... - A_AHKVersion will be suggested
. press and hold the right arrow to look up the selected suggestion's first associated data
. long press tab or enter to replace the current partial string by the selected suggestion's first own replacement string


)
GUI, Show, AutoSize, eAutocomplete
ControlSetText,, % infoTip, % myAutocomplete.AHKID ; https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_id
; use PostMessage to move the caret at the very end of the input in the Edit control:
PostMessage, 0xB1, 0, -1,, % myAutocomplete.AHKID ; EM_SETSEL := 0xB1
; https://docs.microsoft.com/en-us/windows/win32/controls/em-setsel
PostMessage, 0xB1, -1,,, % myAutocomplete.AHKID
myAutocomplete.disabled := false
myAutocomplete.source := "myAutocompleteList"
; set the instance's autocomplete list (can be changed at any time thereafter)
OnExit, handleExit
return

handleExit:
	myAutocomplete.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the eAutocomplete instance
ExitApp
