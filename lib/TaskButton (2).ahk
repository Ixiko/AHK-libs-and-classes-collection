;?add 2010 Modified by Tuncay to work with the stdlib mechanism.
;?add The function names are changed, mostly a prefix Tray_ is 
;?add added and names changed: TaskButtons() becomes to TaskButton()
;?add and HideButton() becomes to TaskButton_Hide().
;?add All changed or added lines are commented with ;? comments.
;?add http://www.autohotkey.com/forum/viewtopic.php?t=17314 by Sean

;?out-begin
/*
#NoTrayIcon
DetectHiddenWindows, On

MsgBox % TaskButtons()
Return
*/
;?out-end

;?out TaskButtons(sExeName = "")
TaskButton(sExeName = "")
{
	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	TaskButton_GetTaskSwBar()
		SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12)
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "int64P", hWnd:=0, "Uint", NumGet(btn,12) ? 4:8, "Uint", 0)
		If Not	hWnd
			Continue
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	sTaskButtons .= "idx: " . A_Index-1 . " | idn: " . idn . " | pid: " . pid . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . "`n" . "   | Tooltip: " . sTooltip . "`n"
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	Return	sTaskButtons
}

;?out HideButton(idn, bHide = True)
TaskButton_Hide(idn, bHide = True)
{
	idxTB := TaskButton_GetTaskSwBar()
	SendMessage, 0x404, idn, bHide, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_HIDEBUTTON
}

;?out DeleteButton(idx)
TaskButton_Delete(idx)
{
	idxTB := TaskButton_GetTaskSwBar()
	SendMessage, 0x416, idx, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_DELETEBUTTON
}

;?out MoveButton(idxOld, idxNew)
TaskButton_Move(idxOld, idxNew)
{
	idxTB := TaskButton_GetTaskSwBar()
	SendMessage, 0x452, idxOld, idxNew, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd    ; TB_MOVEBUTTON
}

;?out GetTaskSwBar()
TaskButton_GetTaskSwBar()
{
	ControlGet, hParent, hWnd,, MSTaskSwWClass1 , ahk_class Shell_TrayWnd
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
