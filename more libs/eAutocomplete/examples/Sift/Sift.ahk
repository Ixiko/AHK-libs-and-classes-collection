#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\eAutocomplete.ahk


wordlist := eAutocomplete.Wordlist.buildFromFile("myAutocompleteList", A_ScriptDir . "\Autocompletion\Autocompletion_en")
; Load a list of suggestions from a file and prepare the given list for use as an autocompletion list.
query := wordlist.Query
query.Word.minLength := 1
query.Word.edgeKeys := RegExReplace(query.Word.edgeKeys, "[\.\*\?\+\{\}\\\[\]\(\)\^\$\|]", "")
/*
Known limitation: for now, the script is unable to make a distinction between 'edge chars' and symbols commonly used in the regex syntax: if
; you want to use a regex symbol as such, it must not be listed in edgeKeys.
*/
query.Sift.option := "REGEX" ; Needle is an REGEX expression to check against Haystack item
GUI, New
GUI, +Resize +hwndGUIID ;  +HwndGUIID stores the HWND (unique identifier) of the window in GUIID
GUI, Add, Edit, w300 h300 +hwndhEdit, ; create the host edit control (+hwndhEdit stores the HWND (unique identifier) of the control in hEdit)
eAutocomplete.wrap(hEdit) ; wrap it into an eAutocomplete object
eAutocomplete.resource := wordlist.name ; set the instance's autocomplete list (can be changed at any time thereafter)
GUI, Show, AutoSize, eAutocomplete
return

!x::ExitApp
