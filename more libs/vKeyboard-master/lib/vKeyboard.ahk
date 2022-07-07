Class vKeyboard extends KeypadInterface {
	dispose() {
		base.dispose()
		this.remove("", Chr(255)), this.base := "" ; https://autohotkey.com/board/topic/90734-method-to-delete-object/
	}
}
#Include %A_LineFile%\..\KeypadInterface.ahk
; #Requires AutoHotkey v1.1.32+