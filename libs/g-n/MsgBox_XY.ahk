; Title:
; Link:   		https://www.autohotkey.com/boards/viewtopic.php?p=73307#p73307
; Author:
; Date:
; for:     	AHK_L

/*
; If you just want a function that puts/moves a msgbox dialogs at an X, Y when created using OnMessag

MsgBox_XY("Hello", 30,50)

*/


MsgBox_XY(Message, X, Y) {
	global MsgBox_X := X, MsgBox_Y := Y	; Make global for other function
	OnMessage(0x44, "Move_MsgBox")	; When a dialog appears run Move_MsgBox
	MsgBox, % Message
	OnMessage(0x44, "")				; When a dialog appears do nothing special
}

Move_MsgBox(P) {
	global MsgBox_X, MsgBox_Y 		; Have to be global to get value set in other function
	if (P = 1027) 					; Make sure it is a AHK dialog
	{
		Process, Exist	; Get the Process PID into ErrorLevel
		DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :	; Round about way of changing DetectHiddenWindows settting and saving the setting all in one line
		if WinExist("ahk_class #32770 ahk_pid " ErrorLevel)	; Make sure dialog still exist
			WinMove, MsgBox_X, MsgBox_Y	; Move the default window from above WinExist
		DetectHiddenWindows, %Setting_A_DetectHiddenWindows%	; Set the DetectHiddenWindows setting back to what it was before function changed it
	}
}