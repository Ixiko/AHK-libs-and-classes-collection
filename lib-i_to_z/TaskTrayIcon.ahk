/*
#NoTrayIcon
name=AutoHotkey.exe
action=0x203

cnt:=Tray_GetCount()
DetectHiddenWindows,On
Loop,%cnt%{
	Tray_GetInfo(A_Index,hwnd,uid,msg)
	WinGet,pn,ProcessName,ahk_id %hwnd%
	if(pn=name){
		PostMessage,%msg%,%uid%,%action%,,ahk_id %hwnd%
	}
}
DetectHiddenWindows,Off
*/

Tray_GetCount(){
	SendMessage,0x418,0,0,ToolbarWindow321,ahk_class Shell_TrayWnd
	return ErrorLevel
}
Tray_GetInfo(idx,ByRef hwnd,ByRef uid,ByRef msg,ByRef hicon){
	WinGet,pid,pid,ahk_class Shell_TrayWnd
	hp:=DllCall("OpenProcess",UInt,0x001F0FFF,UInt,0,UInt,pid,UInt)
	lpTB:=DllCall("VirtualAllocEx",UInt,hp,UInt,0,UInt,20,UInt,0x1000,UInt,0x4,UInt)
	SendMessage,0x417,% idx-1,%lpTB%,ToolbarWindow321,ahk_class Shell_TrayWnd

	DllCall("ReadProcessMemory",UInt,hp,UInt,lpTB+12,UIntP,dwData,UInt,4,UInt,0)
	DllCall("ReadProcessMemory",UInt,hp,UInt,dwData  ,UIntP,hwnd,UInt,4,UInt,0)
	DllCall("ReadProcessMemory",UInt,hp,UInt,dwData+4,UIntP,uid ,UInt,4,UInt,0)
	DllCall("ReadProcessMemory",UInt,hp,UInt,dwData+8,UIntP,msg ,UInt,4,UInt,0)
	DllCall("ReadProcessMemory",UInt,hp,UInt,dwData+20,UIntP,hicon ,UInt,4,UInt,0)

	DllCall("VirtualFreeEx", UInt,lpTB, UInt,0, UInt,0x8000)
	DllCall("psapi\CloseProcess",UInt,hp)
}
Tray_GetText(idx){
	WinGet,pid,pid,ahk_class Shell_TrayWnd
	hp:=DllCall("OpenProcess",UInt,0x001F0FFF,UInt,0,UInt,pid,UInt)
	lpStr:=DllCall("VirtualAllocEx",UInt,hp,UInt,0,UInt,512,UInt,0x1000,UInt,0x4,UInt)

	SendMessage,0x417,% idx-1,%lpStr%,ToolbarWindow321,ahk_class Shell_TrayWnd

	DllCall("ReadProcessMemory",UInt,hp,UInt,lpStr+4,UIntP,idButton,UInt,4,UInt,0)

	SendMessage,0x42D,%idButton%,%lpStr%,ToolbarWindow321,ahk_class Shell_TrayWnd
	length=%ErrorLevel%
	VarSetCapacity(res,length)
	DllCall("ReadProcessMemory",UInt,hp,UInt,lpStr,Str,res,UInt,length+1,UInt,0)

	DllCall("VirtualFreeEx", UInt,lpStr, UInt,0, UInt,0x8000)
	DllCall("psapi\CloseProcess",UInt,hp)
	return res
}
SAlloc(size){
	return DllCall("GlobalAlloc",UInt,0x40,UInt,size,UInt)
}
SFree(pStruct){
	DllCall("GlobalFree",UInt,pStruct,UInt)
}
SSetInt(pStruct,offset,val){
	DllCall("RtlMoveMemory", UInt,pStruct+offset, UIntP,val, Int,4)
}
Tray_HideButton(hwnd,uid,hide=1){
	pnid:=SAlloc(504)
	SSetInt(pnid,0,504)
	SSetInt(pnid,4,hwnd)
	SSetInt(pnid,8,uid)
	SSetInt(pnid,12,0x8)
	SSetInt(pnid,152,hide=1)
	SSetInt(pnid,156,0x1)
	DllCall("Shell32.dll\Shell_NotifyIcon",UInt,1,UInt,pnid,UInt)
	SFree(pnid)
}
Tray_MoveButton(from,to){
	PostMessage,0x452,% from-1,% to-1,ToolbarWindow321,ahk_class Shell_TrayWnd
}

