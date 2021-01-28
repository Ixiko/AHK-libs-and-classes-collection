/*
** TaskbarMove.ahk - Move the taskbar (startbar) around the screen
**
**   Updated: Sat, Nov 19, 2011 --- 11/19/11, 4:19:19pm EST
**   Updated: Jan 2018 by MBKane, striping out all but the functions
**  Keywords: move taskbar, move startbar, move task bar, move start bar
**
**    Author: JSLover - r.secsrv.net/JSLover - r.secsrv.net/JSLoverAHK
**		 Web: http://jslover.secsrv.net/AutoHotkey/Scripts/TaskbarMove.ahk
*/

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

TaskbarMove(p_pos) {
	label:="TaskbarMove_" p_pos

	WinExist("ahk_class Shell_TrayWnd")
	SysGet, s, Monitor

	if (IsLabel(label)) {
		Goto, %label%
	}
	return

	TaskbarMove_Top:
	TaskbarMove_Bottom:
	WinMove(sLeft, s%p_pos%, sRight, 0)
	return

	TaskbarMove_Left:
	TaskbarMove_Right:
	WinMove(s%p_pos%, sTop, 0, sBottom)
	return
}

WinMove(p_x, p_y, p_w="", p_h="", p_hwnd="") {
	WM_ENTERSIZEMOVE:=0x0231
	WM_EXITSIZEMOVE :=0x0232

	if (p_hwnd!="") {
		WinExist("ahk_id " p_hwnd)
	}

	SendMessage, WM_ENTERSIZEMOVE
	;//Tooltip WinMove(%p_x%`, %p_y%`, %p_w%`, %p_h%)
	WinMove, , , p_x, p_y, p_w, p_h
	SendMessage, WM_EXITSIZEMOVE
	
	;WinGetPos, n_x, n_y, n_w, n_h, 
	;MsgBox, p_x:%p_x% p_y:%p_y% p_w:%p_w% p_h:%p_h% -- n_x:%n_x% n_y:%n_y% n_w:%n_w% n_h:%n_h%
	;MsgBox, p_x:%p_x% p_y:%p_y% p_w:%p_w% p_h:%p_h% -- n_x:%n_x% n_y:%n_y% n_w:%n_w% n_h:%n_h%
}