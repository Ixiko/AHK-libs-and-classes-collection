
;get active window
	WinGet, hWnd, ID, A
	hWnd2 := DllCall("GetForegroundWindow", Ptr)
	MsgBox, % hWnd "`r`n" Format("0x{:x}", hWnd2)

;window get class
	WinGetClass, vWinClass, % "ahk_id " hWnd
	vWinClass2 := ""
	VarSetCapacity(vWinClass2, 261*2, 0)
	DllCall("GetClassName", Ptr,hWnd, Str,vWinClass2, Int,261)
	MsgBox, % vWinClass "`r`n" vWinClass2

;==============================

;list child windows (controls)
	EnumFunc("", "c")
	pEnumFunc := RegisterCallback("EnumFunc", "F", 2)
	DllCall("EnumChildWindows", Ptr,hWnd, Ptr,pEnumFunc, Ptr,0)
	vList := EnumFunc("", "r")
	MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;list child windows (controls)
	WinGet, vCtlList, ControlListHwnd, % "ahk_id " hWnd
	vList := ""
	Loop, Parse, vCtlList, `n
	{
		hCtl := A_LoopField
		vList .= (hCtl+0) "`r`n"
	}
	vList := SubStr(vList, 1, -1)
	MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;==============================

;list all windows
EnumFunc("", "c")
pEnumFunc := RegisterCallback("EnumFunc", "F", 2)
DllCall("EnumWindows", Ptr,pEnumFunc, Ptr,0)
vList := EnumFunc("", "r")
MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;list all windows
DetectHiddenWindows, On
WinGet, vWinList, List
vList := ""
Loop, % vWinList{
	hWnd := vWinList%A_Index%
	vList .= (hWnd+0) "`n"
}
vList := SubStr(vList, 1, -1)
MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;==============================

;list hidden windows
	EnumFunc("", "c")
	pEnumFunc := RegisterCallback("EnumFunc", "F", 2)
	DllCall("EnumWindows", Ptr,pEnumFunc, Ptr,0)
	vListAll := EnumFunc("", "r")
	vList := ""
	Loop, Parse, vListAll, % "`n"
	{
		if DllCall("user32\IsWindowVisible", Ptr,A_LoopField)
			vList .= A_LoopField "`n"
	}
	vList := SubStr(vList, 1, -1)
	MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;list hidden windows
	DetectHiddenWindows, Off
	WinGet, vWinList, List
	vList := ""
	Loop, % vWinList {
		hWnd := vWinList%A_Index%
		vList .= (hWnd+0) "`n"
	}
	vList := SubStr(vList, 1, -1)
	MsgBox, % StrSplit(vList, "`n").Length() "`n" vList

;==============================

ExitApp

;==================================================

EnumFunc(hWnd, vMode) {

	static vList

	if (vMode = "c")
		return vList := ""
	else if (vMode = "r")
		return RTrim(vList, "`n")

	vList .= hWnd "`n"

return 1
}

;==================================================