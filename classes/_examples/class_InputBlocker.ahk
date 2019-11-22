#include <CallbackCreate>
;-----------------------------------------------------------------------
; InputBlocker
;   Blocks user input until a password is entered, or Stop() is called.
;-----------------------------------------------------------------------
class InputBlocker {
	static WH_KEYBOARD_LL := 13
	static WH_MOUSE_LL := 14
	static WM_KEYUP := 0x101
	
	; takes a string or an array of character keys
	__New(_password:="abc123") { ; default password
		this.password := IsObject(_password) ? _password : StrSplit(_password)
		if (this.password.Count() < 1)
			throw Exception("Invalid password.")
		this.callback := CallbackCreate(ObjBindMethod(this, "_hookProc"), , 3) ; num params = 3
		this.keyboardHook := ""
		this.mouseHook := ""
		this.pos := 1
		this.passwordEntered := false
	}
	
	__Delete() {
		CallbackFree(this.callback)
	}

	Start() {
		this.pos := 1
		this.passwordEntered := false
		this.Stop()
		this.keyboardHook := this._setWindowsHookEx(InputBlocker.WH_KEYBOARD_LL, this.callback)
		this.mouseHook := this._setWindowsHookEx(InputBlocker.WH_MOUSE_LL, this.callback)
		;~ this._releaseAllKeys()	; might not be needed
	}
	
	Stop() {
		if (this.keyboardHook)
			this._unhookWindowsHookEx(this.keyboardHook)
		if (this.mouseHook)
			this._unhookWindowsHookEx(this.mouseHook)
	}
	
	; checks if block was interrupted and clears the flag
	IsInterrupted() {
		Critical
		_retval := this.passwordEntered
		this.passwordEntered := false
		return _retval
	}
	
	_hookProc(nCode, wParam, lParam) {
		Critical 100
		if (nCode >= 0) {
			if (wParam = InputBlocker.WM_KEYUP) {
				if ((NumGet(lParam+0) << 32 >> 32) = GetKeyVK(this.password[this.pos])) {
					if (this.pos++ >= this.password.MaxIndex()) {
						this.passwordEntered := true
						this.pos := 1
						this.Stop()
					}
				}
				else {
					FileAppend, % "Blocked " (NumGet(lParam+0) << 32 >> 32), *
					this.pos := 1
				}
			}
			return 1 ; blocks the message
		}
		else return this._callNextHookEx(nCode, wParam, lParam)
	}
	
	_releaseAllKeys() {
		_intMode := A_FormatInteger
		_s := ""
		SetFormat, IntegerFast, H
		loop, 256 {
			if GetKeyState("VK" hexCode := SubStr(A_Index-1, 3))
				_s .=  "{vk" hexCode " up}"
		}
		if _s
			Send, %s%
		SetFormat, IntegerFast, %_intMode%
		return s
	}
	
	_setWindowsHookEx(idHook, addr) {
		static PTR := A_PtrSize ? "Ptr" : "UInt"
		return DllCall("SetWindowsHookEx", "Int", idHook, "UInt", addr, PTR, 0, "UInt", 0, PTR)
	}

	_unhookWindowsHookEx(hHook) {
		static PTR := A_PtrSize ? "Ptr" : "UInt"
		return DllCall("UnhookWindowsHookEx", PTR, hHook)
	}

	_callNextHookEx(nCode, wParam, lParam, kHook = 0) {
		static PTR := A_PtrSize ? "Ptr" : "UInt"
		return DllCall("CallNextHookEx", PTR, kHook, "Int", nCode, "UInt", wParam, "UInt", lParam)
	}
}
