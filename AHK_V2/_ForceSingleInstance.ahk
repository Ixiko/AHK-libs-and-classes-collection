;posted by: emmanuel d
;
; This function has been converted to a library.
;
; This script saved me countless headaches.  Thanks emmanuel d!

;#SingleInstance off									; We handle instances ourselves
;ForceSingleInstance()								; force single instance ourselve

;Gui, show ,w100 h100,thegui						; show a gui to see if it activates when we open a second instance
;Return

ForceSingleInstance() {
	Process, Exist,%A_ScriptName%					; this allways gets the pid from the 1 instance in the ErrorLevel
	FirstInstancePID:=ErrorLevel					; store the pid of the instance
	if (FirstInstancePID=DllCall("GetCurrentProcessId"))	; if the first instance is this script
		return										; Return
	else {
		winshow,ahk_pid %FirstInstancePID% ahk_class AutoHotkeyGUI			; show the window if hidden
		winactivate,ahk_pid %FirstInstancePID% ahk_class AutoHotkeyGUI		; Activate the first instance 
		exitapp										; we have a return for the first instance so exit the app
	}
}
;GuiEscape:
;guiclose:
;	Gui, hide
;return

