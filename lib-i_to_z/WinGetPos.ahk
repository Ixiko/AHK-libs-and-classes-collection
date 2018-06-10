WinGetPos(hWnd, ByRef x := "", ByRef y := "", ByRef Width := "", ByRef Height := "", Mode := 0) {
	VarSetCapacity(RECT, 16, 0), i := {}
	h := DllCall("User32.dll\GetWindowRect", "Ptr", hWnd, "Ptr", &RECT)
	i.x := x := NumGet(RECT, 0, "Int"), i.y := y := NumGet(RECT, 4, "Int")
	if Mode {
		VarSetCapacity(RECT2, 16, 0)
		DllCall("User32.dll\GetClientRect", "Ptr", hWnd, "Ptr", &RECT2)
		i.h := i.Height := Height := NumGet(RECT2, 12, "Int")
		i.w := i.Width := Width := NumGet(RECT2,  8, "Int")
	} else {
		i.h := i.Height := Height := NumGet(RECT, 12, "Int") - y
		i.w := i.Width := Width := NumGet(RECT,  8, "Int") - x
	}
	return i, ErrorLevel := !h
}