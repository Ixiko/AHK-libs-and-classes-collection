#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode

#Include %A_ScriptDir%\..\..\lib\eAutocomplete.ahk

var =
(
A_AHKVersion
)

eAutocomplete.setSourceFromVar("myAutocompleteList", var) ; create a new autocomplete
; dictionary, called 'myAutocompleteList', from a variable
GUI, New
GUI, +Resize +hwndGUIID ;  +HwndGUIID stores the HWND (unique identifier) of the window in GUIID
myAutocomplete := eAutocomplete.create(GUIID, "w500 h300 +Resize")
; create the edit control and wrap it into an eAutocomplete object
myAutocomplete.disabled := true ; disable temporarily the instance so that we can programmatically
; set the content of its host edit control without triggering autocompletion
infoTip =
(Join`r`n
. type A_... - A_AHKVersion will be suggested
. press and hold the right arrow to retrieve from the internet and look up in a tooltip the current version of Autohotkey
. long press tab or enter to retrieve the version current of Autohotkey from the internet and replace the current partial string by it


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
myAutocomplete.onSuggestionLookup := Func("myAutocompleteOnSuggestionLookup")
myAutocomplete.onReplacement := Func("myAutocompleteOnReplacement")
OnExit, handleExit
return

handleExit:
	myAutocomplete.dispose() ; especially if your script implements a __Delete meta-method, you should
  ; call the 'dispose' method once you've done with the eAutocomplete instance
ExitApp

myAutocompleteOnReplacement(_suggestionText, _tabIndex) {
; this function is launched automatically whenever you are about to perform a replacement by long pressing either the
; Tab/Enter key (suggestion's first associated replacement string) or the Shift+Tab/Shift+Enter hotkey (suggestion's second
; associated replacement string). The event fires before the replacement string has been actually sent to the host control - the
; return value of the function being actually used as the actual replacement string.
	local
	static _whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if (_suggestionText = "A_AHKVersion") { ; if the selected suggestion appears to be 'A_AHKVersion'...
		; retrieve the current version of Autohotkey from the internet
		; cf.also: https://www.autohotkey.com/docs/commands/URLDownloadToFile.htm#WHR
		_whr.Open("GET", "https://www.autohotkey.com/download/1.1/version.txt", true)
		_whr.Send()
		_whr.WaitForResponse()
		_version := _whr.ResponseText
	return _version
	}
}

myAutocompleteOnSuggestionLookup(_suggestionText, _tabIndex) {
; this function is launched automatically whenever you attempt to query an info tip from the selected suggestion
; by pressing and holding either the Right key (querying the suggestion's first associated datum) or the Shift+Right hotkey
; (querying the suggestion's second associated datum). The return value of the callback will be used as the actual text
; displayed in the tooltip.
	return myAutocompleteOnReplacement(_suggestionText, _tabIndex)
		. " (version retrieved from the url https://www.autohotkey.com/download/1.1/version.txt)"
}