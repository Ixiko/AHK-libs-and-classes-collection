Class DropDownListControl extends GuiBase.ChoiceControlType {
	Type := "DropDownList"
	
	SetSelectionHeight(Px) {
		PostMessage, 0x153, -1, % Px,, % "ahk_id" this.hwnd
	}
	
	SetItemHeight(Px) {
		PostMessage, 0x153, 0, % Px,, % "ahk_id" this.hwnd	
	}
}