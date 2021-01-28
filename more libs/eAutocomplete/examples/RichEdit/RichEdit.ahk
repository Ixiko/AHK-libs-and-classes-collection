#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\eAutocomplete.ahk

list =
(Join`n
voiture	car
jour	day
)
/*
Autocompletion data are assumed to be described as a simple LF/CRLF-separated set of lines.
A given line may be commented out by prefixing it by one or more space (or tab) characters - while a given part of a line may be excluded
from the string which is intended to be displayed in the autocomplete menu, as an actual suggestion, by prefixing it by one or more tab characters.
*/
global tsv := Object(StrSplit(list, ["`n", "`t"])*)
wordlist := eAutocomplete.Wordlist.buildFromVar("myAutocompleteList", list)
; load a list of suggestions from a variable and prepare the given list for use as an autocompletion list.
classNNIndex := 1
WinWait, ahk_class WordPadClass
ControlGet, hControl, hwnd,, % "RICHEDIT50W" . classNNIndex, % "ahk_id " . WinExist()
eAutocomplete.wrap(hControl) ; wrap it into an eAutocomplete object
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
