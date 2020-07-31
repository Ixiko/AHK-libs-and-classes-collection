#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\eAutocomplete.ahk

list =
(Join`r`n
voiture	car	автомобиль
jour	day	день
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
eAutocomplete.setSourceFromVar("mySource", list) ; Creates a new autocomplete dictionary
; from an input string, storing it directly in the base object.

GUI, New
GUI, +hwndGUIID ; +hwndGUIID stores the window handle (HWND) of the GUI in 'GUIID'
GUI, Font, s14, Segoe UI
myAutocomplete := eAutocomplete.create(GUIID, "w500 h400")
myAutocomplete.disabled := true ; disable temporarily the instance so that we can programmatically
; set the content of its host edit control without triggering autocompletion
infoTip =
(Join`r`n
. type 'voiture' or 'jour'
. press and hold the Right/Shift+Right hotkeys to look up the selected suggestion's first/second associated data, respectively
. long press Tab/Shift+Tab to replace the current partial string by the selected suggestion's first/second own replacement strings, respectively


)
GUI, Show, AutoSize, eAutocomplete sample example
ControlSetText,, % infoTip, % myAutocomplete.AHKID ; https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_id
; use PostMessage to move the caret at the very end of the input in the Edit control:
PostMessage, 0xB1, 0, -1,, % myAutocomplete.AHKID ; EM_SETSEL := 0xB1
; https://docs.microsoft.com/en-us/windows/win32/controls/em-setsel
PostMessage, 0xB1, -1,,, % myAutocomplete.AHKID
myAutocomplete.disabled := false
myAutocomplete.source := "mySource"
myAutocomplete.suggestAt := 1
; myAutocomplete.setOptions({source: "mySource", suggestAt: 1})
OnExit, handleExit
return

handleExit:
	myAutocomplete.dispose() ; you should call the `dispose` method, when you've done with
	; the instance, especially if your script implements a __Delete meta-function.
ExitApp
