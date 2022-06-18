SetWindowBlur(toggle := true, hwnd) {                                                                                        		;--
	;https://autohotkey.com/boards/viewtopic.php?t=15689
	static padding := A_PtrSize = 8 ? 4 : 0
	static WCA_ACCENT_POLICY := 19, ACCENT_DISABLED := 0, ACCENT_ENABLE_BLURBEHIND := 3
	;if !(hTaskBar := DllCall("user32\FindWindow", "str", "Shell_TrayWnd", "ptr", 0, "ptr"))
	;throw Exception("Failed to get the handle", -1)
	size := VarSetCapacity(ACCENTPOLICY, 16, 0)
	NumPut(toggle ? ACCENT_ENABLE_BLURBEHIND : ACCENT_DISABLED, ACCENTPOLICY, 0, "int")
	VarSetCapacity(WINCOMPATTRDATA, 4 + padding + A_PtrSize + 4 + padding, 0)
	NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
	NumPut(&ACCENTPOLICY, WINCOMPATTRDATA, 4 + padding, "ptr")
	NumPut(size, WINCOMPATTRDATA, 4 + padding + A_PtrSize, "uint")
	DllCall("SetWindowCompositionAttribute", "ptr", hwnd "ptr", &WINCOMPATTRDATA)
return true
}
