Class _BaseMenu extends eAutocomplete._Window {
	__New() {
		local
		static WS_EX_WINDOWEDGE := 0x00000100
		static WS_EX_TOOLWINDOW := 0x00000080
		static WS_EX_TOPMOST := 0x00000008
		static WS_EX_PALETTEWINDOW := (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)
		static WS_EX_NOACTIVATE := 0x08000000
		static WM_MOUSEACTIVATE := 0x0021
		; static WM_NCLBUTTONDOWN := 0x00A1
		_hLastFoundWindow := WinExist()
		_GUI := A_DefaultGUI
		GUI, New
		GUI +hwnd_GUIID
		GUI, +ToolWindow -Caption -SysMenu +AlwaysOnTop ; +Caption
		GUI, +E%WS_EX_PALETTEWINDOW% +E%WS_EX_NOACTIVATE%
		this.GUIID := _GUIID
		GUI, Margin, 0, 0
		GUI, %_GUI%:Default
		WinExist("ahk_id " . _hLastFoundWindow)
		this.canvas := new this.Text(this.GUIID, 0, 0)
		this.fn := ObjBindMethod(this, "WM_MOUSEACTIVATE")
		; OnMessage(WM_NCLBUTTONDOWN, this.fn, -1)
		OnMessage(WM_MOUSEACTIVATE, this.fn, -1)
	}
	_dispose() {
		static WM_MOUSEACTIVATE := 0x0021
		; static WM_NCLBUTTONDOWN := 0x00A1
		; OnMessage(WM_NCLBUTTONDOWN, this.fn, 0)
		OnMessage(WM_MOUSEACTIVATE, this.fn, this.fn:=0)
		this.canvas := ""
	}
	__Delete() {
		; MsgBox % A_ThisFunc
	}
	_bkColor := 0xF0F0F0
	bkColor {
		set {
			try GUI % this.GUIID . ":Color", % this._bkColor:=value, % value ; /GuiControl +BackgroundFF9977, MyListView
		return this.bkColor
		}
		get { ; ~
		return ""
		; return this._bkColor
			; local
			; static WM_CTLCOLORSTATIC := 0x138
			; _hCanvas := this.canvas.HWND
			; _hDC := DllCall("GetDC", "Ptr", _hCanvas, "Ptr")
			; SendMessage % WM_CTLCOLORSTATIC, % _hDC, % _hCanvas,, % "ahk_id " . this.GUIID
			; _color := DllCall("GetBkColor", "Ptr", _hDC)
			; DllCall("ReleaseDC", "Ptr", _hCanvas, "Ptr", _hDC)
			; _red:= (_color & 0xFF0000) >> 16, _green := (_color & 0x00FF00) >> 8, _blue:= (_color & 0xFF)
		; return Format("0x{:x}", (_blue << 16) + (_green << 8) + _red)
		}
	}
	show(_option) {
		GUI % this.GUIID . ":Show", % "NA " . _option
	}
	hide() {
		this.show("Hide")
	}
	WM_MOUSEACTIVATE(_wParam, _lParam, _uMsg, _hWnd) {
		static MA_NOACTIVATEANDEAT := 4
		Critical
		if (_wParam = this.GUIID)
			return MA_NOACTIVATEANDEAT
	}
	; #Include %A_LineFile%\..\_Menu.Text.ahk
}
