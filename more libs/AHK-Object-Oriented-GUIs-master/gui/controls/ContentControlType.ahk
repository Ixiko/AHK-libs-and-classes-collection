Class ContentControlType extends GuiBase.ControlType {
	SetText(Text) {
		this.Text := Text
	}
	
	GetText() {
		return this.Text
	} 
	
	Text {
		get {
			ControlGetText, text,, % "ahk_id" this.hwnd
			return text
		}
		
		set {
			GuiControl,, % this.hwnd, % value
		}
	}
}