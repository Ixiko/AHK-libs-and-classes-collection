; Source:
;    https://superuser.com/questions/1049609/search-in-autohotkey-for-a-window-title-that-contains-a-string-but-does-not-con
;    
; Accessed:
;    2019_10_23
;    
; Requires:
;    Microsoft Word
;    
; Note:
;    Does not toggle


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; --- Global Variables --- ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__PROCESS_NAME := "WINWORD.EXE"
__PROCESS_DISPLAY_NAME := "Microsoft Word"
__SUBWINDOW_NAME := "Word Options"
__SUBWINDOW_SHORT_DESC := "Options"
__SUBWINDOW_TIMEOUT := 4  ; seconds


;;;;;;;;;;;;;;;;;;;;;
; --- Functions --- ;
;;;;;;;;;;;;;;;;;;;;;

IsNamedProcess(name) {
	global
	StringUpper, name, name
	return name = __PROCESS_NAME
}

GetActiveWindowProcessName() {
	WinGet, name, ProcessName, A
	return name
}

ActivateWindow(proc_name) {
	WinGet, windows, List
	
	Loop, %windows%
	{
		id := windows%A_Index%
		WinGet, proc_name, ProcessName, ahk_id %id%
		
		if (IsNamedProcess(proc_name)) {
			WinActivate, ahk_id %id%
			break
		}
	}
	
	name := GetActiveWindowProcessName()
	return IsNamedProcess(name)
}

OpenSubwindow() {
	SendInput !ft
}

WaitForWindow(name, timeout) {
	WinWait, %name%,, %timeout%
	return ErrorLevel = 0
}

GetFailureMessage(short_desc, timeout) {
	msg := "Your " short_desc " could not be set."
    msg .= "`r`nThe timeout occurs at " timeout " seconds."
}

SendKeyStrokes() {
	SendInput {DOWN 2}     ; Proofing
	                       ; When correcting spelling and grammar in Word
	SendInput !p           ;    Check spelling as you type
	SendInput !m!m{SPACE}  ;    Mark grammar errors as you type
	SendInput !n           ;    Frequently confused words
	SendInput !h!h{SPACE}  ;    Check grammar with spelling
	SendInput {Enter}      ; Confirm and close Word Options
}


;;;;;;;;;;;;;;;;;;;;;;
; --- Main Entry --- ;
;;;;;;;;;;;;;;;;;;;;;;

Main() {
	global
	
	if (!ActivateWindow(__PROCESS_NAME)) {
		msg := "An window for " __PROCESS_DISPLAY_NAME " could not be found in the running windows."
		MsgBox %msg%
		return
	}
	
	OpenSubwindow()
	
	if (WaitForWindow(__SUBWINDOW_NAME, __SUBWINDOW_TIMEOUT)) {
		SendKeyStrokes()
	} else {
		MsgBox, % GetFailureMessage(__SUBWINDOW_SHORT_DESC, __SUBWINDOW_TIMEOUT)
	}
}

Main()

