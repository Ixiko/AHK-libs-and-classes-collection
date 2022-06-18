; function by maul.esel, inspired by above
MeasureTextHeight(Str, Width, FontOpts = "", FontName = "") {

	Static DT_FLAGS := 0x0530 ; DT_SINGLELINE = 0x20, DT_NOCLIP = 0x0100, DT_CALCRECT = 0x0400, DT_WORDBREAK = 0x10
	Static WM_GETFONT := 0x31

	Gui, New
	If (FontOpts <> "") || (FontName <> "")
		Gui, Font, %FontOpts%, %FontName%
	Gui, Add, Text, hwndHWND

	SendMessage, WM_GETFONT, 0, 0, , ahk_id %HWND%
	HFONT := ErrorLevel
	, HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
	, DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", HFONT)

	, VarSetCapacity(RECT, 16, 0)
	, NumPut(Width, RECT, 8, "Int")

	, DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Str, "Int", -1, "Ptr", &RECT, "UInt", DT_FLAGS)
	, DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)

	Gui, Destroy

	Return NumGet(RECT, 12, "Int")
}