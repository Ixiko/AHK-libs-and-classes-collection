#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\eAutocomplete.ahk

eAutocomplete.setSourceFromFile("mySource", A_ScriptDir . "\Autocompletion\Autocompletion_en")
; Creates a new autocomplete dictionary from a file's content, storing it directly in the base object.

GUI, New
GUI, +hwndGUIID ; +hwndGUIID stores the window handle (HWND) of the GUI in 'GUIID'
GUI, Font, s14, Segoe UI
myAutocomplete := eAutocomplete.create(GUIID, "w500 h400")
GUI, Show, AutoSize, eAutocomplete
; myAutocomplete.source := "mySource"
; myAutocomplete.suggestAt := 2
; myAutocomplete.onSearch := Func("myAutocompleteOnSearch")
myAutocomplete.setOptions({source: "mySource", suggestAt: 2, onSearch: Func("myAutocompleteOnSearch")})
; myAutocomplete.listbox.transparency := 230
; myAutocomplete.listbox.fontColor := "blue"
; myAutocomplete.listbox.fontName := "Arial"
; myAutocomplete.listbox.maxSuggestions := 9
myAutocomplete.listbox.setOptions({transparency: 230, fontColor: "blue", fontName: "Arial", maxSuggestions: 9})
OnExit, handleExit
return

handleExit:
	myAutocomplete.dispose() ; you should call the `dispose` method, when you've done with
	; the instance, especially if your script implements a __Delete meta-function.
ExitApp

myAutocompleteOnSearch(this, _subsection, _substring, ByRef _suggestionList:="") {
; This function is triggered before a search is performed, after suggestAt is met. That way, you can override the built-in scoring algorithm that check
; the pending word against the current autocomplete source list, implement your own in order to return custom subsets of suggestions.
/*
_subsection 	The subsection of the autocomplete source where all words start with the first letter of the pending word.
_substring 	Contains the pending word.
_suggestionList [BYREF] 	Your callback is supposed to give a value to this ByRef parameter, that of a linefeed-separated (CRLF) subset of
					suggestions, precisely the subset which is intended to be displayed as autocomplete suggestions.
*/
	_suggestionList := Sift_Regex(_subsection, _substring, "OC")
}

; Sift_Regex by FanaticGuru (cf. https://www.autohotkey.com/boards/viewtopic.php?t=7302)
Sift_Regex(ByRef Haystack, ByRef Needle, Options := "IN", Delimit := "`n")
{
	Sifted := {}
	if (Options = "IN")
		Needle_Temp := "\Q" Needle "\E"
	else if (Options = "LEFT")
		Needle_Temp := "^\Q" Needle "\E"
	else if (Options = "RIGHT")
		Needle_Temp := "\Q" Needle "\E$"
	else if (Options = "EXACT")
		Needle_Temp := "^\Q" Needle "\E$"
	else if (Options = "REGEX")
		Needle_Temp := Needle
	else if (Options = "OC")
		Needle_Temp := RegExReplace(Needle,"(.)","\Q$1\E.*")
	else if (Options = "OW")
		Needle_Temp := RegExReplace(Needle,"( )","\Q$1\E.*")
	else if (Options = "UW")
		Loop, Parse, Needle, " "
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"
	else if (Options = "UC")
		Loop, Parse, Needle
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"

	if Options is lower
		Needle_Temp := "i)" Needle_Temp

	if IsObject(Haystack)
	{
		for key, Hay in Haystack
			if RegExMatch(Hay, Needle_Temp)
				Sifted.Insert(Hay)
	}
	else
	{
		Loop, Parse, Haystack, %Delimit%
			if RegExMatch(A_LoopField, Needle_Temp)
				Sifted .= A_LoopField Delimit
		Sifted := SubStr(Sifted,1,-1)
	}
	return Sifted
}
