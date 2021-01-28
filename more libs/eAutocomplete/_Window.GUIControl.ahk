Class GUIControl {
	__New(_GUIID) {
		this._hHost := _GUIID
	}
	owner {
		get {
			static GA_ROOTOWNER := 3
		return DllCall("User32.dll\GetAncestor", "Ptr", this._hHost, "UInt", GA_ROOTOWNER, "Ptr")
		}
	}
	getPos(ByRef _x:="", ByRef _y:="") {
		WinGetPos, _x, _y,,, % "ahk_id " . this.HWND
	}
	font {
		get {
		return new this.FontWrapper(this.HWND)
		}
		set {
		return this.font
		}
	}
	Class FontWrapper {
		__New(_hControl) {
			static GA_ROOT := 2
			this.hControl := _hControl
			; this.GUIID := DllCall("User32.dll\GetAncestor", "Ptr", _hControl, "UInt", GA_ROOT, "Ptr")
			this.GUIID := DllCall("User32.dll\GetParent", "Ptr", _hControl, "Ptr")
			this.handle := this._getHandle()
		}
		_getHandle() {
			static WM_GETFONT := 0x31
			this.hDC := DllCall("User32.dll\GetDC", "Ptr", this.hControl, "Ptr")
			SendMessage, WM_GETFONT, 0, 0,, % "ahk_id " . this.hControl
		return DllCall("Gdi32.dll\SelectObject", "Ptr", this.hDC, "Ptr", ErrorLevel, "Ptr")
		}
		__Delete() {
			this._releaseHandle()
			; MsgBox, 16,, % A_ThisFunc
			; if not (this._releaseHandle())
				; MsgBox, 64,, Failed to release the font.
		}
		_releaseHandle() {
			if (this.handle) {
				DllCall("Gdi32.dll\SelectObject", "Ptr", this.hDC, "Ptr", this.handle, "Ptr")
			return DllCall("User32.dll\ReleaseDC", "Ptr", this.hControl, "Ptr", this.hDC)
			}
		}
		getTextExtentPoint(_text, ByRef _w:="", ByRef _h:="") {
			local
			_size := "", DllCall("Gdi32.dll\GetTextExtentPoint32", "UPtr", this.hDC, "Str", _text, "Int", StrLen(_text), "Int64P", _size)
			(IsByref(_w) && _w := _size &= 0xFFFFFFFF), (IsByref(_h) && _h := >> 32 & 0xFFFFFFFF)
		}
		color {
			set {
				try GUI % this.GUIID . ":Font", % "c" . value
				GuiControl, Font, % this.hControl
			return this.color
			}
			get { ; ~
			; return Format("{1:06X}", DllCall("Gdi32.dll\GetTextColor", "Ptr", this.hDC)) ; http://forum.script-coding.com/viewtopic.php?id=13256 [Сохранить скриншот в файл]
			return ""
			}
		}
		name {
			set {
				try GUI % this.GUIID . ":Font",, % value
				GuiControl, Font, % this.hControl
				this._releaseHandle(), this._getHandle()
			return this.name
			}
			get {
				local
				VarSetCapacity(_lpName, 40)
				DllCall("Gdi32.dll\GetTextFace", "Ptr", this.hDC, "UInt", 40, "Str", _lpName)
			return _lpName
			}
		}
		size {
			set {
				try GUI % this.GUIID . ":Font", % "s" . value
				GuiControl, Font, % this.hControl
				this._releaseHandle(), this._getHandle()
			return this._size:=value
			}
			get { ; ~
			return ""
			}
		}
	}
}