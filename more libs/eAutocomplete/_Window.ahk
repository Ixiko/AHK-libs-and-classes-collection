Class _Window {
	move(_x, _y) {
		static SWP_NOSIZE := 0x0001
		static SWP_NOZORDER := 0x0004
		static SWP_NOACTIVATE := 0x0010
		static _uFlags := (SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE)
		DllCall("User32.dll\SetWindowPos", "Ptr", this.GUIID, "Ptr", 0, "Int", _x, "Int", _y, "Int", 0, "Int", 0, "UInt", _uFlags)
	}
	resize(_w, _h) {
		static SWP_NOMOVE := 0x0002
		static SWP_NOZORDER := 0x0004
		static SWP_NOACTIVATE := 0x0010
		static _uFlags := (SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE)
		DllCall("User32.dll\SetWindowPos", "Ptr", this.GUIID, "Ptr", 0, "Int", 0, "Int", 0, "Int", _w, "Int", _h, "UInt", _uFlags)
	}
	isVisible() {
	return DllCall("IsWindowVisible", "Ptr", this.GUIID)
	}
	_transparency := 255
	transparency {
		set {
			local
			_detectHiddenWindows := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if value between 10 and 255
				WinSet, Transparent, % this._transparency:=value, % "ahk_id " . this.GUIID
			DetectHiddenWindows % _detectHiddenWindows
		return this.transparency
		}
		get {
		return this._transparency
		}
	}
	#Include %A_LineFile%\..\_Window.GuiControl.ahk
	#Include %A_LineFile%\..\_Window.Text.ahk
}