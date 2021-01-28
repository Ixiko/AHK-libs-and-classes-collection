CreateSurface(monitor := 0, window := 0) {
	global DrawSurface_Hwnd
	
	if(monitor = 0) {
		if(window) {
			WinGetPos, sX, sY, sW, sH, ahk_id %window%
		} else {
			WinGetPos, sX, sY, sW, sH, Program Manager
		}
	} else {
		Sysget, MonitorInfo, Monitor, %monitor%
		sX := MonitorInfoLeft, sY := MonitorInfoTop
		sW := MonitorInfoRight - MonitorInfoLeft
		sH := MonitorInfoBottom - MonitorInfoTop
	}
	
	Gui DrawSurface:Color, 0xFFFFFF
	Gui DrawSurface: +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
	WinGet, DrawSurface_Hwnd, ID, 
	WinSet, TransColor, 0xFFFFFF
	
	Gui DrawSurface:Show, x%sX% y%sY% w%sW% h%sH%
	Sleep, 100
	Gui DrawSurface:Submit
	
	return DrawSurface_Hwnd
}

ShowSurface() {
	WinGet, active_win, ID, A
	Gui DrawSurface:Show
	WinActivate, ahk_id %active_win%
}

HideSurface() {
	Gui DrawSurface:Submit
}

WipeSurface(hwnd) {
	DllCall("InvalidateRect", UInt, hwnd, UInt, 0, Int, 1)
    DllCall("UpdateWindow", UInt, hwnd)
}

StartDraw(wipe := true) {
	global DrawSurface_Hwnd
	
	if(wipe)
		WipeSurface(DrawSurface_Hwnd)
    
    HDC := DllCall("GetDC", Int, DrawSurface_Hwnd)
    
    return HDC
}

EndDraw(hdc) {
	global DrawSurface_Hwnd
	DllCall("ReleaseDC", Int, DrawSurface_Hwnd, Int, hdc)
}

SetPen(color, thickness, hdc) {
	global DrawSurface_Hwnd
	
	static pen := 0
	
	if(pen) {
		DllCall("DeleteObject", Int, pen)
		pen := 0
	}
	
	pen := DllCall("CreatePen", UInt, 0, UInt, thickness, UInt, color)
    DllCall("SelectObject", Int, hdc, Int, pen)
}

DrawLine(hdc, rX1, rY1, rX2, rY2) {
	DllCall("MoveToEx", Int, hdc, Int, rX1, Int, rY1, UInt, 0)
	DllCall("LineTo", Int, hdc, Int, rX2, Int, rY2)
}

DrawRectangle(hdc, left, top, right, bottom) {
	DllCall("MoveToEx", Int, hdc, Int, left, Int, top, UInt, 0)
    DllCall("LineTo", Int, hdc, Int, right, Int, top)
    DllCall("LineTo", Int, hdc, Int, right, Int, bottom)
    DllCall("LineTo", Int, hdc, Int, left, Int, bottom)
    DllCall("LineTo", Int, hdc, Int, left, Int, top-1)
}