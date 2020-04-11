;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THE KEYBOARD LOCKER                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This script will disable the keyboard when the user       ;
; presses Ctrl+Alt+Shift+K. To re-enabled the user must     ;
; type "unlock".                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Originally written by Lexikos:                            ;
;  http://www.autohotkey.com/forum/post-147849.html#147849  ;
; Modifications by Trevor Bekolay for the How-To Geek       ;
;  http://www.howtogeek.com/                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Include %A_ScriptDir%\..\Lib\TransparentWindow.ahk

; This can only execute if the keyboard is NOT blocked,
; so it can't be used to unblock the keyboard.
^!+k::
	KeyWait, Ctrl ; don't block Ctrl key-up
	KeyWait, Alt  ; or Alt key-up
	KeyWait, Shift  ; or Shift key-up
	KeyWait, k    ; or k-up
	BlockKeyboard()
return
*/

BlockKeyboard(block=-1) { ; -1, true or false.

	static hHook = 0, cb = 0
	global notray

	if !cb ; register callback once only.
		cb := RegisterCallback("BlockKeyboard_HookProc")

	if (block = -1) ; toggle
		block := (hHook=0)

	if ((hHook!=0) = (block!=0)) ; already (un)blocked, no action necessary.
		return

	if (block) {
		hHook := DllCall("SetWindowsHookEx"
			, "int", 13  ; WH_KEYBOARD_LL
			, "uint", cb ; lpfn (callback)
			, "uint", 0  ; hMod (NULL)
			, "uint", 0) ; dwThreadId (all threads)

		; Display message to user
		TransparentWindow("Keyboard Disabled", 450)
	}
	else
	{
		DllCall("UnhookWindowsHookEx", "uint", hHook)
		hHook = 0
		TransparentWindow("Keyboard Enabled", 450)
	}
}

BlockKeyboard_HookProc(nCode, wParam, lParam) {
	static count = 0

	; Unlock keyboard if "unlock" typed in
	if (NumGet(lParam+8) & 0x80) { ; key up
		if (count = 0 && NumGet(lParam+4) = 0x16) {        ; 'u'
			count = 1
		} else if (count = 1 && NumGet(lParam+4) = 0x31) { ; 'n'
			count = 2
		} else if (count = 2 && NumGet(lParam+4) = 0x26) { ; 'l'
			count = 3
		} else if (count = 3 && NumGet(lParam+4) = 0x18) { ; 'o'
			count = 4
		} else if (count = 4 && NumGet(lParam+4) = 0x2E) { ; 'c'
			count = 5
		} else if (count = 5 && NumGet(lParam+4) = 0x25) { ; 'k'
			count = 0
			BlockKeyboard(false)
		} else {
			count = 0
		}
	}

	return 1
}
