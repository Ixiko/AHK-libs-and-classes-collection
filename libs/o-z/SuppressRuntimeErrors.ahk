SuppressRuntimeErrors("Error at line {#}.  Please contact support.")
MsgBox % %empty%  ; Normally "This dynamic variable is blank."
return

SuppressRuntimeErrors(NewErrorFormat)
{
	; Call self-contained helper/message-monitor function:
	return SuppressRuntimeErrors_(NewErrorFormat, 0, 0, 0)
}

SuppressRuntimeErrors_(wParam, lParam, msg, hwnd)
{
	; Constants:
	static WM_COMMNOTIFY := 0x0044, AHK_DIALOG := 1027
	; Persistent variables:
	static sScriptPID := 0, sMessage
	
	Critical 1000
	
	if hwnd     ; Called internally to handle a WM_COMMNOTIFY message.
	{
		DetectHiddenWindows On
		
		if (hwnd = A_ScriptHwnd  ; Script's main window is the recipient.
			&& wParam = AHK_DIALOG  ; We're showing a dialog of some sort.
			&& WinExist("ahk_class #32770 ahk_pid " sScriptPID))
		{
			ControlGetText msg, Static1
			; The following relies on the fact that all built-in error
			; dialogs use this format to point out the current line:
			static RegEx := (A_AhkVersion>="2" ? "" : "O") "m`a)^--->`t0*\K\d+(?=:)"
			if RegExMatch(msg, RegEx, line)
			{
				; If we change the text, the dialog will still be sized
				; based on the previous text.  So instead, close this
				; dialog and show a new one.
				DllCall("DestroyWindow", "ptr", WinExist())
				msg := StrReplace(sMessage, "{#}", line.0)
				MsgBox 48,, %msg%
				
				ExitApp
				; If not exiting, just indicate this message has been handled:
				; return 0
			}
		}
	}
	else        ; Called by script.
	{
		sMessage := wParam
		
		; If we're already registered, just return.
		if sScriptPID
			return
		
		; Retrieve script's process ID.
		sScriptPID := DllCall("GetCurrentProcessId", "uint")
		
		; Register message handler.  Since hotkeys and other things can
		; launch new threads while we're displaying our error dialog,
		; pass 10 for MaxThreads so that we can catch any error dialogs
		; that these other threads might display:
		OnMessage(WM_COMMNOTIFY, Func(A_ThisFunc), 10)
	}
}