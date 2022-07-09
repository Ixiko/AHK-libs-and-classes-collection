;functions from other libraries:
;JEE_DCXXX (6 functions)
;JEE_GetSelectedText
;JEE_SetSelectedText
;JEE_StrRept
;JEE_WinIs64Bit

;==================================================

JEE_DCOpenProcess(vAccess, hInherit, vPID)
{
	return DllCall("kernel32\OpenProcess", UInt,vAccess, Int,hInherit, UInt,vPID, Ptr)
}
JEE_DCVirtualAllocEx(hProc, vAddress, vSize, vAllocType, vProtect)
{
	return DllCall("kernel32\VirtualAllocEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vAllocType, UInt,vProtect, Ptr)
}
JEE_DCWriteProcessMemory(hProc, vBAddress, pBuf, vSize, vWritten)
{
	return DllCall("kernel32\WriteProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vWritten)
}
JEE_DCReadProcessMemory(hProc, vBAddress, pBuf, vSize, vRead)
{
	return DllCall("kernel32\ReadProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vRead)
}
JEE_DCVirtualFreeEx(hProc, vAddress, vSize, vFreeType)
{
	return DllCall("kernel32\VirtualFreeEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vFreeType)
}
JEE_DCCloseHandle(hObject) ;e.g. hProc
{
	return DllCall("kernel32\CloseHandle", Ptr,hObject)
}

;==================================================

; ;===============
; ;e.g.
; vText := JEE_GetSelectedText()
; ;===============

; ;===============
; ;e.g. get selected text simple alternative
; Clipboard := ""
; SendInput, ^c
; ClipWait, 3
; if ErrorLevel
; {
; 	MsgBox, % "error: failed to retrieve clipboard text"
; 	return
; }
; vText := Clipboard
; ;===============

JEE_GetSelectedText(vWait:=3)
{
	static vIsV1 := !!SubStr(1, 0)
	hWnd := WinGetID("A")
	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		vText := ControlGetSelected(vCtlClassNN, "ahk_id " hWnd)
	else
	{
		ClipSaved := vIsV1 ? ClipboardAll : ClipboardAll()
		Clipboard := ""
		SendInput("^c")
		ClipWait(vWait)
		if ErrorLevel
		{
			ToolTip("ClipWait failed (" A_ThisHotkey ")")
			Clipboard := ClipSaved
			ClipSaved := ""
			Sleep(1000)
			ToolTip()
			Exit() ;terminate the thread that launched this function
		}
		vText := Clipboard
		Clipboard := ClipSaved
		ClipSaved := ""
	}
	return vText
}

;==================================================

JEE_SetSelectedText(vText, vWait:=3)
{
	;adapted from ClipPaste by ObiWanKenobi
	;Robust copy and paste routine (function) - Scripts and Functions - AutoHotkey Community
	;https://autohotkey.com/board/topic/111817-robust-copy-and-paste-routine-function/

	static vIsV1 := !!SubStr(1, 0)
	hWnd := WinGetID("A")
	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		ControlEditPaste(vText, "Edit1", "ahk_id " hWnd)
	else
	{
		ClipSaved := vIsV1 ? ClipboardAll : ClipboardAll()
		Clipboard := vText
		SendInput("{Shift Down}{Shift Up}{Ctrl Down}{vk56 Down}") ;vk56 sc02F
		;'PasteWait'
		vWait *= 1000
		vStartTime := A_TickCount
		Sleep(100)
		while (DllCall("user32\GetOpenClipboardWindow", Ptr) && (A_TickCount-vStartTime < vWait))
			Sleep(100)
		SendInput("{vk56 Up}{Ctrl Up}") ;vk56 sc02F
		Clipboard := ClipSaved
		ClipSaved := ""
	}
}

;==================================================

JEE_StrRept(vText, vNum)
{
	if (vNum <= 0)
		return
	return StrReplace(Format("{:" vNum "}","")," ",vText)
	;return StrReplace(Format("{:0" vNum "}",0),0,vText)
}

;==================================================

JEE_WinIs64Bit(hWnd)
{
	vPID := WinGetPID("ahk_id " hWnd)
	if !vPID
		return
	if !A_Is64bitOS
		return 0
	;PROCESS_QUERY_INFORMATION := 0x400
	hProc := DllCall("kernel32\OpenProcess", UInt,0x400, Int,0, UInt,vPID, Ptr)
	DllCall("kernel32\IsWow64Process", Ptr,hProc, IntP,vIsWow64Process)
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return !vIsWow64Process
}

;==================================================
