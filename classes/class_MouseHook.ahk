; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 
;    Name:				class_MouseHook.ahk
;    Description: 	lowlevel mousehook class for retrieving mousemovement
;    Author: 			Helgef
;    Posted: 			01 Sep 2017, 02:25
;    Link: ﻿				https://autohotkey.com/boards/viewtopic.php?t=36495
;	MSDN:				https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setwindowshookexa
; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 

/* Example(s)
#Persistent
mh:=new mouseHook("h")
mh.hook()
esc::exitapp
; you can turn off the hook by calling: mh.unhook()
h(h,x,y){
	; the x and y parameters are in screen coords.
	mouseGetPos,x,y,wum
	if winexist("ahk_class Notepad ahk_id " wum)
		ToolTip, % "Mouse moved at " x " " y " in notepad"
}
*/

class mouseHook{
	; User methods
	hook(){
		if !this.hHook												; WH_MOUSE_LL := 14									  hMod:=0	 dwThreadId:=0
			this.hHook:=DllCall("User32.dll\SetWindowsHookEx", "Int", 14, "Ptr", this.regCallBack:=RegisterCallback(this.LowLevelMouseProc,"",4, &this), "Uint", 0, "Uint", 0, "Ptr")
		return
	}
	unHook(){
		if this.hHook
			DllCall("User32.dll\UnhookWindowsHookEx", "Uint", this.hHook)
		return this.hHook:=""
	}
	; Internal methods.
	__new(callbackFunc){
		(this.callbackFunc:= isObject(callbackFunc)  ? callbackFunc : isFunc(callbackFunc) ? func(callbackFunc) : "")
		if !this.callbackFunc
			throw exception("invalid callbackFunc")
	}
	LowLevelMouseProc(args*) {  
		; (nCode, wParam, lParam)
		Critical
		this:=Object(A_EventInfo),nCode:=NumGet(args-A_PtrSize,"Int"), wParam:=NumGet(args+0,0,"Ptr"), lParam:=NumGet(args+0,A_PtrSize,"UPtr") 
		x:=NumGet(lParam+0,0,"Int"),y:=NumGet(lParam+0,4,"Int"),flags:=NumGet(lParam+0,12,"UInt")
		this.callbackFunc.Call(flags,x,y)
		
		return DllCall("User32.dll\CallNextHookEx","Uint",0, "Int", nCode,"Uptr", wParam,"Ptr",lParam)
	}
	__Delete(){  
		this.unHook()
		if this.regCallBack
			DllCall("GlobalFree", "Ptr", this.regCallBack)
		return 
	}
}
