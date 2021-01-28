#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\eAutocomplete.ahk

list =
(Join`n
A_AHKVersion%A_Tab%%A_AHKVersion%
A_AHKPath%A_Tab%%A_AHKPath%
A_Desktop%A_Tab%%A_Desktop%
)
/*
Autocompletion data are assumed to be described as a simple LF/CRLF-separated set of lines.
A given line may be commented out by prefixing it by one or more space (or tab) characters - while a given part of a line may be excluded
from the string which is intended to be displayed in the autocomplete menu, as an actual suggestion, by prefixing it by one or more tab characters.
*/
global tsv := Object(StrSplit(list, ["`n", "`t"])*)
wordlist := eAutocomplete.Wordlist.buildFromVar("myAutocompleteList", list)
; load a list of suggestions from a variable and prepare the given list for use as an autocompletion list.
GUI, New
GUI, +Resize +hwndGUIID ;  +HwndGUIID stores the HWND (unique identifier) of the window in GUIID
GUI, Add, Edit, w300 h300 +hwndhEdit, ; create the host edit control (+hwndhEdit stores the HWND (unique identifier) of the control in hEdit)
eAutocomplete.wrap(hEdit) ; wrap it into an eAutocomplete object
eAutocomplete.disabled := true ; disable temporarily the instance so that we can programmatically
; set the content of its host edit control without triggering autocompletion
infoTip =
(Join`r`n
. type A_... - A_AHKVersion will be suggested
. press and hold the right arrow to display the selected suggestion's infoTip through the onSuggestionLookUp callback
. long press tab or enter to replace the current partial string through the onReplacement callback


)
GUI, Show, AutoSize, eAutocomplete
ControlSetText,, % infoTip, % "ahk_id " . hEdit
; use PostMessage to move the caret at the very end of the input in the Edit control:
PostMessage, 0xB1, 0, -1,, % "ahk_id " . hEdit ; EM_SETSEL := 0xB1
; https://docs.microsoft.com/en-us/windows/win32/controls/em-setsel
PostMessage, 0xB1, -1,,, % "ahk_id " . hEdit
eAutocomplete.disabled := false
eAutocomplete.resource := wordlist.name ; set the instance's autocomplete list (can be changed at any time thereafter)
eAutocomplete.onReplacement("onReplacement")
eAutocomplete.onSuggestionLookUp("onSuggestionLookUp")
return

onReplacement(_suggestion, ByRef _expandModeOverride:="") {
/*
The function is launched automatically whenever you are about to replace a word by long pressing the Tab/Enter key (by default).
The event fires before the replacement string has been actually sent to the host control - the return value of the function being
actually used as the actual replacement string.
*/
return tsv[_suggestion]
}
onSuggestionLookUp(_selectionText) {
/*
The function is launched automatically whenever you attempt to query an info tip from the selected suggestion by pressing and holding
the ⯈ arrow key (by default). The return value of the callback will be used as the actual text displayed in the tooltip.
*/
return "info: " . tsv[_selectionText]
}

!x::ExitApp
