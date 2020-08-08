GetChildHWND(ParentHWND, ChildClassNN)
{
	WinGetPos, ParentX, ParentY,,, ahk_id %ParentHWND%
	if ParentX =
		return  ; Parent window not found (possibly due to DetectHiddenWindows).
	ControlGetPos, ChildX, ChildY,,, %ChildClassNN%, ahk_id %ParentHWND%
	if ChildX =
		return  ; Child window not found, so return a blank value.
	; Convert child coordinates -- which are relative to its parent's upper left
	; corner -- to absolute/screen coordinates for use with WindowFromPoint().
	; The following INTENTIONALLY passes too many args to the function because
	; each arg is 32-bit, which allows the function to automatically combine
	; them into one 64-bit arg (namely the POINT struct):
	return DllCall("WindowFromPoint", "int", ChildX + ParentX, "int", ChildY + ParentY)
}
