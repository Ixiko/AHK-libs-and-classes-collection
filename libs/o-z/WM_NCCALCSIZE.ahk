; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=76464&sid=ac33d6f8b3fdd13807df3874f0a5a988
; Author:
; Date:
; for:     	AHK_L

/*

	Gui,+HWNDdHWND
	Gui, Color, 000001

	Gui, show, w600 h450, hello
	OnMessage(0x0083,"WM_NCCALCSIZE")



	Dwm_ExtendFrameIntoClientArea(dHWND, -1)
	Dwm_SetWindowAttributeAllowNCPaint(dHWND, 1)

	;WinSet,TransColor, 000001, ahk_id %dHWND%
	WinGetPos,x,y,w,h,ahk_id %dHWND%
	DllCall("User32.dll\SetWindowPos", "Ptr", dHWND, "Uint", 0, "Int", x, "Int", y, "Int", w, "Int", h, "Uint", 0x0020) ; SWP_FRAMECHANGED=0x0020


	Gui, add, Button,x+m y+m gButton1 ,Press me.

	return
	Button1:
		MsgBox, Thanks!
	return

*/



WM_NCCALCSIZE(wParam, lParam, msg, hwnd){

	x1:=NumGet(lParam+0,0,"Int")
	y1:=NumGet(lParam+0,4,"Int")
	x2:=NumGet(lParam+0,8,"Int")
	y2:=NumGet(lParam+0,12,"Int")

	old_x1:=NumGet(lParam+0,32,"Int")
	old_y1:=NumGet(lParam+0,4+32,"Int")
	old_x2:=NumGet(lParam+0,8+32,"Int")
	old_y2:=NumGet(lParam+0,12+32,"Int")
	dx1:=abs(x1-old_x1)
	dx2:=abs(x2-old_x2)
	dy1:=abs(y1-old_y1)
	dy2:=abs(y2-old_y2)


;	Msgbox, %dx1%  %dy1% %dx2% %dy2%
	NumPut(x1-dx1,lParam+0,0,"Int")
	NumPut(y1-dy1,lParam+0,4,"Int")
	NumPut(x2+dx2,lParam+0,8,"Int")
	NumPut(y2+dy2,lParam+0,12,"Int")

	NumPut(0x0040,wParam+0,0,"UInt")
}

Dwm_SetWindowAttributeAllowNCPaint(hwnd,onOff){                                       ;	Enables content rendered in the non-client area to be visible on the frame drawn by DWM.
	;	DWMWA_ALLOW_NCPAINT = 4
	;	Enables content rendered in the non-client area to be visible on the frame drawn by DWM.
	;	The pvAttribute parameter points to a value of TRUE to enable content rendered in the
	;	non-client area to be visible on the frame; otherwise, it points to FALSE.
	dwAttribute := 4
	cbAttribute := 4
	VarSetCapacity(pvAttribute, 4)
	NumPut(onOff, pvAttribute, 0, "Int")
	hr:=DllCall("Dwmapi.dll\DwmSetWindowAttribute", "Ptr", hwnd, "Uint", dwAttribute, "Ptr", &pvAttribute, "Uint", cbAttribute)
	return hr ; 0 is ok!
}

Dwm_ExtendFrameIntoClientArea(hwnd,l:=0,r:=0,t=0,b:=0){                        	;	Extends the window frame into the client area.
	;	Extends the window frame into the client area.
	;	Input:
	;			hwnd, unique id to the window to which to extend window frame
	;			l,r,t,b is left, right top and bottom margins, respectively. Use negative to create "sheet of glass"-effect
	;	Notes:
	;			https://msdn.microsoft.com/en-us/library/windows/desktop/aa969512(v=vs.85).aspx
	;			https://msdn.microsoft.com/en-us/library/windows/desktop/bb773244(v=vs.85).aspx (margins struct)
	VarSetCapacity(margin, 16)
	NumPut(l, margin, 0, "Int")
	NumPut(r, margin, 4, "Int")
	NumPut(t, margin, 8, "Int")
	NumPut(b, margin, 12, "Int")
	hr:=DllCall("Dwmapi.dll\DwmExtendFrameIntoClientArea", "Ptr", hwnd, "Ptr", &margin)
	return hr	; 0 is ok!
}


