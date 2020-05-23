;==================================================================
; WINDOW CREATED LISTENER v1.0.0
; Author: Daniel Shuy
; 
; A script that displays a pop-up whenever a Window is created
;==================================================================

#NoEnv

#Include %A_ScriptDir%\ShellHook-1.0.1.ahk

Gui +LastFound	; Win commands called specifying window will use last found window instead
	
	hWnd := WinExist()	; get reference to this script
	
	; register Shell Hook to detect Window opening event
	new WindowCreatedListener(hWnd)
return

class WindowCreatedListener extends ShellHook {
	__New(hWnd) {
		base.__New(hWnd)
	}
	
	;@Override
	ShellProc(hookCode, id) {
		if (hookCode = ShellHook.HSHELL_WINDOWCREATED) {
			MsgBox Window Created!
		}
	}
}
