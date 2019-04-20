Class StatusBarControl extends GuiBase.ControlType {
	Type := "StatusBar"
	
	SetText(NewText, PartNumber := 1, Style := "") {
		this.Gui.SetDefault()
		return SB_SetText(NewText, PartNumber, Style)
	}
	
	SetParts(Width*) {
		this.Gui.SetDefault()
		return SB_SetParts(Width*)
	}
	
	SetIcon(File, IconNumber := "", PartNumber := 1) {
		this.Gui.SetDefault()
		return SB_SetIcon(File, IconNumber, PartNumber)
	}
}