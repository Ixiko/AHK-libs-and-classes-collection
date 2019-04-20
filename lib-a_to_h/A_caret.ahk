A_Caret(param, coordMode = "Screen")
{
	target_window := DllCall("GetForegroundWindow")
	If !target_window
		Return ""
	VarSetCapacity(guiThreadInfo, 48)
	NumPut(48, guiThreadInfo, 0)
	return DllCall("GetGUIThreadInfo", uint, 0, str, guiThreadInfo)
	hwndCaret := NumGet(GuiThreadInfo, 28)
	If !hwndCaret
		Return ""
	top := NumGet(guiThreadInfo, 36)
	bottom := NumGet(guiThreadInfo, 44)
	If param = h
		Return bottom - top
	left := NumGet(guiThreadInfo, 32)
	right := NumGet(guiThreadInfo, 40)
	If param = w
		Return right - left

	VarSetCapacity(sPoint, 8, 0)
	NumPut(left, sPoint, 0, "Int")
	NumPut(top, sPoint, 4, "Int")

	DllCall("ClientToScreen", "UInt", hwndCaret, "UInt", &sPoint)

	left := NumGet(sPoint, 0, "Int")
	top := NumGet(sPoint, 4, "Int")

	If coordMode = Relative
	{
		VarSetCapacity(rect, 16)
		DllCall("GetWindowRect", UInt, target_window, UInt, &rect)
		left -= NumGet(Rect, 0, True)
		top  -= NumGet(Rect, 4, True)
	}
	If param = x
		Return left
	Else
		Return top
}
