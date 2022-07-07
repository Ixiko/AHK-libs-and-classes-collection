Class _HostWindowWrapper extends _KeypadEvents._HostWindowWrapper {
	__New(ByRef _hWndActiveX:="") {
		local
		this._HWND := this._makeGUI()
		_hWndActiveX := this._addActiveX(0, 150)
		OnMessage(0x05, ObjBindMethod(this, "_GUISizeFn")) ; WM_SIZE := 0x05
	}
	HWND {
		set {
		return this._HWND
		}
		get {
		return this._HWND
		}
	}
	_makeGUI() {
		local
		_hDefaultGUI := A_DefaultGUI, _lastFoundWindow := WinExist()
		GUI, New, +hWnd_GUIID -MaximizeBox -Resize +LastFound, % Chr(8203) ; https://unicode-table.com/en/200B/ ++++
		GUI, Margin, 0, 0
		WinExist("ahk_id " . _lastFoundWindow)
		GUI, %_hDefaultGUI%:Default
	return _GUIID
	}
	_addActiveX(_x, _y) {
		local
		; static _wb
		GUI % this._HWND ":Add", ActiveX, % "Section x" _x " y" _y
		; GUI % this._HWND ":Add", ActiveX, % "v_wb Section x" _x " y" _y
		, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge" charset="utf-8">
		; , Shell.Explorer
		; _wb.navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible' content='IE=edge'>")
		; _wb.navigate("file://...")
		; while (_wb.readystate <> 4 || _wb.busy)
			; sleep 10
		_detectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On
		_hWndActiveX := ""
		while not (_hWndActiveX) {
			try ControlGet, _hWndActiveX, Hwnd,, Internet Explorer_Server1, % "ahk_id " . this._HWND
		sleep, 100
		}
		DetectHiddenWindows % _detectHiddenWindows
	return _hWndActiveX
	}
	_GUISizeFn(_wParam, _lParam, _msg, _hwnd) {
		local
		if (_hwnd <> this._HWND)
			return
		(this._onResize && this._onResize.call(this, _wParam, _lParam, _msg, _hwnd))
	}
	_onResize := ""
	onResize {
		set {
		return this._onResize := value
		}
		get {
		return this._onResize
		}
	}
	destroy() {
		OnMessage(0x05, this._GUISizeFn, this._GUISizeFn:=0) ; WM_SIZE := 0x05 (https://www.autohotkey.com/boards/viewtopic.php?p=192247#profile192277)
		this._onResize := ""
		GUI % this._HWND . ":Destroy"
	}
	show(_options:="", _title:="") {
		if (_title <> "") {
			GUI, % this._HWND . ":Show", % _options, % _title
		} else GUI, % this._HWND . ":Show", % _options
	} ; +++++++
	hide() {
	this.show("Hide")
	}
	isVisible() {
	return DllCall("IsWindowVisible", "Ptr", this._HWND)
	}
}