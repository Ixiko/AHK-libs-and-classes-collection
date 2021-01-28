Class Text extends eAutocomplete._Window.GUIControl {
	__New(_GUIID, _x, _y) {
		local
		base.__New(_GUIID)
		GUI % this._hHost . ":Add", Text, % "hwnd_hText x" _x . " y" . _y,
		this.HWND := _hText
	}
	__Delete() {
	; MsgBox % A_ThisFunc
	}
}