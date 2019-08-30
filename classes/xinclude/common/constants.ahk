class constants extends xlib.bases.setgetErrorCleanup {
	
	pPostMessage[] {
		get {
			static p := ''
			if !p
				p := xlib.ui.getFnPtrFromLib('User32.dll', 'PostMessage', true)
			return p
		}
	}
	
	static msgNumber := 0x5537
	
	msgHWND[] {
		get {
			return this.msgWin.hwnd
		}
	}

	msgWin[] {
		get {
			static g := guicreate()
			return g
		}
	}
	
	; internal methods
	cleanup(){
		try
			this.msgWin.destroy
		objrawset this, 'msgWin', ''
	}
}