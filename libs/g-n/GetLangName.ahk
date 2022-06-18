GetLangName(hWnd) {

	Static LOCALE_SENGLANGUAGE := 0x1001
	Locale := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr) & 0xFFFF
	Size := DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, UInt, 0, UInt, 0) * 2
	VarSetCapacity(lpLCData, Size, 0)
	DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, Str, lpLCData, UInt, Size)

Return lpLCData
}