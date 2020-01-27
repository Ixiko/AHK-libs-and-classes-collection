; AutoHotkey Version: 1.0.47.06
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
; Last updated: 2008-12-11
; Copyright:	
;		You are allowed to include the source code in your own product(in any form) when 
;	your product is released in binary form.
;		You are allowed to copy/modify/distribute the code in any way you want except
;	you can NOT modify/remove the copyright details at the top of each script file.

; References:
; 	http://www.codeproject.com/KB/shell/taskbarsorter.aspx

#Include Utils\ToolbarWrapper.ahk
#Include Utils\Utils.ahk

; ##################################################
; 	"Interfaces" of the TaskBarHelper
; ##################################################

; Find the TaskBar toolbar
; 获得托盘区域工具栏句柄
TaskBar_FindToolbar()
{
; Shelltray/TaskBar under WinXP:

; Shell_TrayWnd
; 	|- Button ("Start" button/"开始"菜单)
; 	|- TrayNotifyWnd (ShellTray area/托盘区域)
; 	|		|- TrayClockWClass (SysClock/系统时钟)
; 	|		|- SysPager
; 	|		|		|- ToolbarWindow32 (ShellTray Toolbar/目标工具栏，包含所有托盘图标)  ***
; 	|		|- Button
; 	|- ReBarWindow32 (Quick Launch, Language Bar.../包括快速启动栏、任务栏图标工具栏、语言栏等)
;			|- CiceroUIWndFrame (TF_FloatingLangBar_WndTitle)
;			|- ToolbarWindow32 ("Desktop"/桌面)
;			|- MSTaskSwWClass
;					|- ToolbarWindow32 (TaskBar/任务栏) ***
;			|- ToolbarWindow32 (Quick Launch)

	hToolbar := FindWindow( "Shell_TrayWnd", 0)
	if ( hToolbar )
	{
		hToolbar := FindWindowEx(hToolbar, 0, "ReBarWindow32", 0)
		if ( hToolbar )
		{
			hToolbar := FindWindowEx(hToolbar, 0, "MSTaskSwWClass", 0)
			if ( hToolbar )
			{
				hToolbar := FindWindowEx(hToolbar, 0, "ToolbarWindow32", 0)
				if( hToolbar )
					return hToolbar
			}
		}
	}
	return 0
}

GetTaskBarButtonBuddyWindowHandle(szToolbarName, ByRef pTBBUTTON)
{
	if( TW_ReadToolbarProcessMemory( szToolbarName, hWnd, 4, _TB_dwData(pTBBUTTON) ) > 0 )
		return NumGet(hWnd)
}
