; http://msdn.microsoft.com/zh-tw/library/windows/desktop/ms644989(v=vs.85).aspx
; wParam = 4 or 32772 -> window activated
; wParam = 1 -> window created
; lParam = hwnd


WindowShellEvent(funcName){
	global
	gui,shellEventGui: +hwndshellEventGUIhwnd
	;~ p:=DllCall("GetCurrentProcessId")
	;~ winget,id,id,ahk_pid %p%
	
	DllCall( "RegisterShellHookWindow", UInt,shellEventGUIhwnd )
	MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
	OnMessage( MsgNum, funcName)
	;~ return MsgNum
}

