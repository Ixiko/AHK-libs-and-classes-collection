;================================================================================
; https://www.autohotkey.com/boards/viewtopic.php?f=6&p=264108#p264108
;--------------------------------------------------------------------------------
DropShadow(HGUI:="", Style:="", GetGuiClassStyle:="", SetGuiClassStyle:="") {
;--------------------------------------------------------------------------------

	if (GetGuiClassStyle) {
		ClassStyle:=GetGuiClassStyle()
		return ClassStyle
	}

	if (SetGuiClassStyle) {
		SetGuiClassStyle(HGUI, Style)
	}

}

GetGuiClassStyle() {
	Gui, GetGuiClassStyleGUI:Add, Text
	Module := DllCall("GetModuleHandle", "Ptr", 0, "UPtr")
	VarSetCapacity(WNDCLASS, A_PtrSize * 10, 0)
	ClassStyle := DllCall("GetClassInfo", "Ptr", Module, "Str", "AutoHotkeyGUI", "Ptr", &WNDCLASS, "UInt")
                 ? NumGet(WNDCLASS, "Int")
                 : ""
	Gui, GetGuiClassStyleGUI:Destroy
	Return ClassStyle
}

SetGuiClassStyle(HGUI, Style) {
	Return DllCall("SetClassLong" . (A_PtrSize = 8 ? "Ptr" : ""), "Ptr", HGUI, "Int", -26, "Ptr", Style, "UInt")
}
;================================================================================