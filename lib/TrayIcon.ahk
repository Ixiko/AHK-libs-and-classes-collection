;?add 2010 Modified by Tuncay to work with the stdlib mechanism.
;?add The function names are changed, mostly a prefix Tray_ is 
;?add added and names changed: TrayIcons() becomes to TrayIcon()
;?add and HideTrayIcon() becomes to TrayIcon_Hide().
;?add All changed or added lines are commented with ;? comments.
;?add http://www.autohotkey.com/forum/viewtopic.php?t=17314 by Sean

;?out-begin
/*
#NoTrayIcon
DetectHiddenWindows, On

MsgBox % TrayIcons()
Return
*/
;?out-end

/*
WM_MOUSEMOVE	= 0x0200
WM_LBUTTONDOWN	= 0x0201
WM_LBUTTONUP	= 0x0202
WM_LBUTTONDBLCLK= 0x0203
WM_RBUTTONDOWN	= 0x0204
WM_RBUTTONUP	= 0x0205
WM_RBUTTONDBLCLK= 0x0206
WM_MBUTTONDOWN	= 0x0207
WM_MBUTTONUP	= 0x0208
WM_MBUTTONDBLCLK= 0x0209

PostMessage, nMsg, uID, WM_RBUTTONDOWN, , ahk_id %hWnd%
PostMessage, nMsg, uID, WM_RBUTTONUP  , , ahk_id %hWnd%
*/


;?out TrayIcons(sExeName = "")
TrayIcon(sExeName = "")
{
	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	TrayIcon_GetTrayBar()
		SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12)
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12)
			hWnd	:= NumGet(nfo, 0)
		,	uID	:= NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8), nMsg:=NumGet(nfo,12)
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	sTrayIcons .= "idx: " . A_Index-1 . " | idn: " . idn . " | Pid: " . pid . " | uID: " . uID . " | MessageID: " . nMsg . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . "`n" . "   | Tooltip: " . sTooltip . "`n"
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	Return	sTrayIcons
}

;?out RemoveTrayIcon(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
TrayIcon_Remove(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
{
	NumPut(VarSetCapacity(ni,444,0), ni)
	NumPut(hWnd , ni, 4)
	NumPut(uID  , ni, 8)
	NumPut(1|2|4, ni,12)
	NumPut(nMsg , ni,16)
	NumPut(hIcon, ni,20)
	Return	DllCall("shell32\Shell_NotifyIconA", "Uint", nRemove, "Uint", &ni)
}

;?out HideTrayIcon(idn, bHide = True)
TrayIcon_Hide(idn, bHide = True)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x404, idn, bHide, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_HIDEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

;?out DeleteTrayIcon(idx)
TrayIcon_Delete(idx)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x416, idx - 1, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_DELETEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

;?out MoveTrayIcon(idxOld, idxNew)
TrayIcon_Move(idxOld, idxNew)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x452, idxOld - 1, idxNew - 1, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd ; TB_MOVEBUTTON
}

;?out GetTrayBar()
TrayIcon_GetTrayBar()
{
	ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
	Loop
	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
		If  Not	hWnd
			Break
		Else If	hWnd = %hChild%
		{
			idxTB := A_Index
			Break
		}
	}
	Return	idxTB
}
