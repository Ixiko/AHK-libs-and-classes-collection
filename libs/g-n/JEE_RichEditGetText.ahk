; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=5&t=38385&p=176827
; Author:
; Date:
; for:     	AHK_L

/*


*/

;tested on WordPad (Windows XP and Windows 7 versions)
a:: ;RichEdit control - set text (RTF)
ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
FormatTime, vDate,, HH:mm dd/MM/yyyy
vRtf := "{\rtf{\b " vDate "}}"
JEE_RichEditSetText(hCtl, vRtf)
return

;==================================================

q:: ;richedit (internal control) - get stream
WinGet, hWnd, ID, A
ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
MsgBox, % vText := JEE_RichEditGetStream(hCtl, 0x11)
MsgBox, % vRtf := JEE_RichEditGetStream(hCtl, 0x2)
ControlSetText, RICHEDIT50W1, % "", % "ahk_id " hWnd
MsgBox, % vText := JEE_RichEditGetStream(hCtl, 0x11)
MsgBox, % vRtf := JEE_RichEditGetStream(hCtl, 0x2)
return

;not working
w:: ;richedit (internal control) - set stream
ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
vText := "abcdefghijklmnopqrstuvwxyz"
JEE_RichEditSetStream(hCtl, 0x11, vText)
Sleep, 2000
FormatTime, vDate,, HH:mm dd/MM/yyyy
vRtf := "{\rtf{\b " vDate "}}"
JEE_RichEditSetStream(hCtl, 0x2, vText)
return

e:: ;richedit - create GUI
DetectHiddenWindows, On
Gui, New, +HwndhGui, MyWinTitle
hModuleME := DllCall("kernel32\LoadLibrary", Str,"msftedit.dll", Ptr)
Gui, Add, Custom, ClassRICHEDIT50W r1
ControlSetText, RICHEDIT50W1, % "RICH 1", % "ahk_id " hGui
Gui, Show, w300 h300
return

;e.g.
r::
ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
MsgBox, % JEE_RichEditGetStream(hCtl, 0x11)
MsgBox, % JEE_RichEditGetStream(hCtl, 0x2)
return

;==================================================

;==================================================
JEE_RichEditGetText(hCtl){
	ControlGetText, vText,, % "ahk_id " hCtl
	return vText
}
;==================================================
JEE_RichEditSetText(hCtl, vText, vFlags:=0x0, vCP:=0x0){

	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;ST_UNICODE := 0x8 ;ST_NEWCHARS := 0x4
	;ST_SELECTION := 0x2 ;ST_KEEPUNDO := 0x1
	;ST_DEFAULT := 0x0
	;CP_ACP := 0 ;Unicode (1200)
	VarSetCapacity(SETTEXTEX, 8)
	NumPut(vFlags, &SETTEXTEX, 0, "UInt") ;flags
	NumPut(vCP, &SETTEXTEX, 4, "UInt") ;codepage

	if (vCP = 0)	{
		vSize := StrPut(vText, "CP0")
		VarSetCapacity(vOutput, vSize)
		StrPut(vText, &vOutput, "CP0")
	}
	else	{
		vSize := StrLen(vText)*2+2
		vOutput := vText
	}

	if vIsLocal
		SendMessage, 0x461, % &SETTEXTEX, % &vOutput,, % "ahk_id " hCtl ;EM_SETTEXTEX := 0x461
	else	{

		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, 8+vSize, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &SETTEXTEX, 8, 0)
		JEE_DCWriteProcessMemory(hProc, pBuf+8, &vOutput, vSize, 0)
		SendMessage, 0x461, % pBuf, % pBuf+8,, % "ahk_id " hCtl ;EM_SETTEXTEX := 0x461
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
;==================================================
JEE_DCOpenProcess(vAccess, hInherit, vPID){
	return DllCall("kernel32\OpenProcess", UInt,vAccess, Int,hInherit, UInt,vPID, Ptr)
}
JEE_DCVirtualAllocEx(hProc, vAddress, vSize, vAllocType, vProtect){
	return DllCall("kernel32\VirtualAllocEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vAllocType, UInt,vProtect, Ptr)
}
JEE_DCWriteProcessMemory(hProc, vBAddress, pBuf, vSize, vWritten){
	return DllCall("kernel32\WriteProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vWritten)
}
JEE_DCReadProcessMemory(hProc, vBAddress, pBuf, vSize, vRead){
	return DllCall("kernel32\ReadProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vRead)
}
JEE_DCVirtualFreeEx(hProc, vAddress, vSize, vFreeType){
	return DllCall("kernel32\VirtualFreeEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vFreeType)
}
JEE_DCCloseHandle(hObject) {
	return DllCall("kernel32\CloseHandle", Ptr,hObject)
}


;only works on internal controls
JEE_RichEditGetStream(hCtl, vFormat){
	static  pFunc := RegisterCallback("JEE_RichEditGetStreamCallback")
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_USECODEPAGE := 0x20 ;SF_UNICODE := 0x10
	;SF_RTFNOOBJS := 0x3 ;SF_RTF := 0x2 ;SF_TEXT := 0x1
	vSize := A_PtrSize=8?20:12
	VarSetCapacity(EDITSTREAM, vSize, 0)
	NumPut(vFormat, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	SendMessage, 0x44A, % vFormat, % &EDITSTREAM,, % "ahk_id " hCtl ;EM_STREAMOUT := 0x44A
	return JEE_RichEditGetStreamCallback("Get", 0, 0, 0)
}
;==================================================
JEE_RichEditGetStreamCallback(dwCookie, pbBuff, cb, pcb){
	static vTextOut := ""
	if (cb > 0)
	{
		if (dwCookie & 0x10)
			vTextOut .= StrGet(pbBuff, cb/2, "UTF-16")
		else
			vTextOut .= StrGet(pbBuff, cb, "CP0")
		return 0
	}
	if (dwCookie = "Get")
	{
		vTemp := vTextOut
		vTextOut := ""
		return vTemp
	}
	return 1
}
;==================================================
;not working
;only works on internal controls
JEE_RichEditSetStream(hCtl, vFormat, ByRef vText){
	static pFunc := RegisterCallback("JEE_RichEditSetStreamCallback")
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_UNICODE := 0x10
	;SF_RTF := 0x2 ;SF_TEXT := 0x1
	vSize := A_PtrSize=8?20:12
	VarSetCapacity(EDITSTREAM, vSize, 0)
	NumPut(&vText, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	vSize2 := (StrLen(vText)+1)*((vFormat & 0x10)?2:1)
	if !(vFormat & 0x10)
		StrPut(vText, &vText, "CP0")
	JEE_RichEditSetStreamCallback("Init", vSize2, 0, 0)
	SendMessage, 0x449, % vFormat, % &EDITSTREAM,, % "ahk_id " hCtl ;EM_STREAMIN := 0x449
	vRet := ErrorLevel
	return vRet
}
;==================================================
;not working
JEE_RichEditSetStreamCallback(dwCookie, pbBuff, cb, pcb){
	static vRemain, vOffset
	if (dwCookie = "Init")
	{
		vRemain := pbBuff, vOffset := 0
		return
	}
	if (vRemain <= cb)
	{
		DllCall("kernel32\RtlMoveMemory", Ptr,pbBuff, Ptr,dwCookie+vOffset, UPtr,vRemain)
		NumPut(vRemain, pcb, 0, "Ptr")
		vOffset += vRemain
		vRemain := 0
		return 1
	}
	else
	{
		DllCall("kernel32\RtlMoveMemory", Ptr,pbBuff, Ptr,dwCookie+vOffset, UPtr,cb)
		NumPut(cb, pcb, 0, "Ptr")
		vOffset += cb
		vRemain -= cb
		return 0
	}
}
;==================================================

