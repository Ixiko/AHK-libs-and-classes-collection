; Clipboard-related functions.

copyWithHotkey(hotkeyKeys) {
	if(hotkeyKeys = "")
		return
	
	clipboard := "" ; Clear the clipboard so we can wait for it to actually be set
	Send, % hotkeyKeys
	ClipWait, 0.5 ; Wait for the minimum time (0.5 seconds) for the clipboard to contain the new info.
}
copyFilePathWithHotkey(hotkeyKeys) {
	copyWithHotkey(hotkeyKeys)
	
	path := clipboard
	if(path) {
		path := cleanupPath(path)
		path := mapPath(path)
	}
	
	setClipboardAndToastValue(path, "file path")
}
copyFolderPathWithHotkey(hotkeyKeys) {
	copyWithHotkey(hotkeyKeys)
	
	path := clipboard
	if(path) {
		path := cleanupPath(path)
		path := mapPath(path)
		path := appendCharIfMissing(path, "\") ; Add the trailing backslash since it's a folder
	}
	
	setClipboardAndToastValue(path, "folder path")
}

;---------
; DESCRIPTION:    Add something to the clipboard history, restoring the original clipboard value.
; PARAMETERS:
;  textToSave (I,REQ) - Text to add to the clipboard history.
;---------
addToClipboardHistory(textToSave) {
	originalClipboard := clipboardAll
	
	clipboard := textToSave
	saveCurrentClipboard()
	
	clipboard := originalClipboard
	saveCurrentClipboard()
}

;---------
; DESCRIPTION:    Force the clipboard manager to store the current value, generally useful just
;                 before you change the clipboard to something else.
;---------
saveCurrentClipboard() {
	; If the ditto function is available that's preferable (no wait time), but fall back if needed.
	functionName := "dittoSaveCurrentClipboard" ; dittoSaveCurrentClipboard()
	if(isFunc(functionName))
		%functionName%()
	else
		Sleep, 1000
}

; Sends the selected text using the clipboard, fixing the clipboard as it finishes.
sendTextWithClipboard(text) {
	; DEBUG.popup("Text to send with clipboard", text)
	
	originalClipboard := clipboardAll ; Save off the entire clipboard.
	clipboard := ""                   ; Clear the clipboard
	
	clipboard := text
	ClipWait, 0.5                     ; Wait for clipboard to contain the data we put in it (minimum time).
	Send, ^v
	Sleep, 100
	
	clipboard := originalClipboard    ; Restore the original clipboard. Note we're using clipboard (not clipboardAll).
}

setClipboard(value) {
	clipboard := "" ; Clear the clipboard so we can wait for it to actually be set
	
	clipboard := value
	ClipWait, 2 ; Wait for 2 seconds for the clipboard to contain data.
}

setClipboardAndToastState(newClipboardValue, clipLabel := "value") {
	setClipboard(newClipboardValue)
	toastNewClipboardState(clipLabel)
}
setClipboardAndToastValue(newClipboardValue, clipLabel := "value") {
	setClipboard(newClipboardValue)
	toastNewClipboardValue(clipLabel)
}
setClipboardAndToastError(newClipboardValue, clipLabel, problemMessage, errorMessage := "") {
	if(clipLabel = "")
		clipLabel := "value"
	
	setClipboard(newClipboardValue)
	Toast.showError(problemMessage, errorMessage, "Clipboard set to " clipLabel ":`n" clipboard)
}

toastNewClipboardState(clipLabel := "value") {
	toastClipboard(clipLabel, false)
}
toastNewClipboardValue(clipLabel := "value") {
	toastClipboard(clipLabel, true)
}

toastClipboard(clipLabel, showClipboardValue) {
	if(clipLabel = "")
		clipLabel := "value"
	
	if(clipboard = "") {
		Toast.showError("Failed to get " clipLabel)
	} else {
		clipMessage := "Clipboard set to " clipLabel
		if(showClipboardValue)
			clipMessage .= ":`n" clipboard
		Toast.showMedium(clipMessage)
	}
}
