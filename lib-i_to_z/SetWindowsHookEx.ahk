;~ return
; http://www.autohotkey.com/board/topic/45574-detecting-keystrokesmouse-movement-not-logging-them/#entry283734

;~ hHookKeybd := SetWindowsHookEx(WH_KEYBOARD_LL	:= 13, RegisterCallback("__Keyboard", "Fast"))
;~ hHookMouse := SetWindowsHookEx(WH_MOUSE_LL   := 14, RegisterCallback("__MouseMove", "Fast"))
;~ UnhookWindowsHookEx(hHookMouse)



SetWindowsHookEx(idHook, pfn)
{
   Return DllCall("SetWindowsHookEx", "int", idHook, "Uint", pfn, "Uint", DllCall("GetModuleHandle", "Uint", 0), "Uint", 0)
}


UnhookWindowsHookEx(hHook)
{
   Return DllCall("UnhookWindowsHookEx", "Uint", hHook)
}
/*
__MouseMove(nCode, wParam, lParam){
	If nCode || !(wParam = 0x200)
		return
	;~ X := lParam & 0xFFFF      ;  in case I need the mouse X position
	;~ Y := lParam >> 16         ;  in case I need the mouse Y position
	static priorX,priorY
	x:=NumGet(lParam+0, 0, "int")
	y:=NumGet(lParam+0, 4, "int")
	Return CallNextHookEx(nCode, wParam, lParam)
}

__Keyboard(nCode, wParam, lParam)
{
	Critical
	SetFormat, Integer, H
	If ((wParam = 0x100)  ; WM_KEYDOWN
	|| (wParam = 0x101))  ; WM_KEYUP
	{
		KeyName := GetKeyName("vk" NumGet(lParam+0, 0))
		Tooltip, % (wParam = 0x100) ? KeyName " Down" : KeyName " Up"
	}
	Return CallNextHookEx(nCode, wParam, lParam)
}

*/
CallNextHookEx(nCode, wParam, lParam, hHook = 0)
{
   Return DllCall("CallNextHookEx", "Uint", hHook, "int", nCode, "Uint", wParam, "Uint", lParam)
}