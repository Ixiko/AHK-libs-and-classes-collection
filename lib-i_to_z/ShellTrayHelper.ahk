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
;	http://blog.csdn.net/hailongchang/archive/2008/12/05/3454569.aspx
;	http://blog.csdn.net/hailongchang/archive/2008/12/10/3490353.aspx

#Include Utils\ToolbarWrapper.ahk
#Include Utils\Utils.ahk

; ##################################################
; 	Relative structures
; ##################################################

; Please refer to the description about NOTIFYICONDATA in MSDN
; typedef struct _TRAYDATA
; {
; 	HWND hWnd;					4 bytes		Handle to the window that receives notification messages associated with an icon in the taskbar status area
; 	UINT uID;						4 bytes		Application-defined identifier of the taskbar icon
; 	UINT uCallbackMessage;		4 bytes		Application-defined message identifier
; 	DWORD dwReserved1[2];		8 bytes
; 	HICON hIcon;					4 bytes
; 	WORD wReserved2[6];			12 bytes
; 	WCHAR szExePath[256];		512 bytes
; 	WORD wReserved3[4];			8 bytes
; 	WCHAR szTips[128];				256 bytes
; }TRAYDATA, *LPTRAYDATA;
;  sizeof(TRAYDATA) = 812

sizeof_TRAYDATA := 812	; Do NOT modify this variable!

; ##################################################
; 	Easy2Visit the member of TRAYDATA structure
; ##################################################

_TD_hWnd(ByRef td)
{
	return NumGet(td, 0, "UInt")
}

_TD_uID(ByRef td)
{
	return NumGet(td, 4, "UInt")
}

_TD_uCallbackMessage(ByRef td)
{
	return NumGet(td, 8, "UInt")
}

_TD_hIcon(ByRef td)
{
	return NumGet(td, 20, "UInt")
}

_TD_szExePath(ByRef td)
{
	pszExePath := &td+36
	return TransformWideCharToMultiByte(pszExePath, 256)
}

_TD_szTips(ByRef td)
{
	pszTips := &td+556
	return TransformWideCharToMultiByte(pszTips, 128)
}

; ##################################################
; 	"Interfaces" of the ShellTrayHelper
; ##################################################

; Find the Shelltray toolbar
; �������������
ShellTray_FindToolbar()
{
; Shelltray/TaskBar under WinXP:

; Shell_TrayWnd
; 	|- Button ("Start" button/"��ʼ"�˵�)
; 	|- TrayNotifyWnd (ShellTray area/����)
; 	|		|- TrayClockWClass (SysClock/ϵͳʱ�)
; 	|		|- SysPager
; 	|		|		|- ToolbarWindow32 (ShellTray Toolbar/Ŀ�깤�������������ͼ�� ***
; 	|		|- Button
; 	|- ReBarWindow32 (Quick Launch, Language Bar.../��������������ͼ�깤����������
;			|- CiceroUIWndFrame (TF_FloatingLangBar_WndTitle)
;			|- ToolbarWindow32 ("Desktop"/��)
;			|- MSTaskSwWClass
;					|- ToolbarWindow32 (TaskBar/���) ***
;			|- ToolbarWindow32 (Quick Launch)

	hToolbar := FindWindow( "Shell_TrayWnd", 0)
	if ( hToolbar )
	{
		hToolbar := FindWindowEx(hToolbar, 0, "TrayNotifyWnd", 0)
		if ( hToolbar )
		{
			hToolbar := FindWindowEx(hToolbar, 0, "SysPager", 0)
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

; ##################################################
; 	Retrieve the Structure TRAYDATA
; ##################################################

GetShellTrayToolbarTrayDataByIndex( szToolbarName, nIndex, ByRef pTRAYDATA )
{
	Local pTBBUTTON
	if( !TW_GetToolbarButton( szToolbarName, nIndex, pTBBUTTON ) )
		return false
	return GetShellTrayToolbarTrayDataByBtn(pTBBUTTON, pTRAYDATA )
}

GetShellTrayToolbarTrayDataByBtn( ByRef pTBBUTTON, ByRef pTRAYDATA )
{
	Global
	if ( TW_GetToolbarProcessMemory( g_szShellTrayName, sizeof_TRAYDATA ) )
		return sizeof_TRAYDATA = TW_ReadToolbarProcessMemory( g_szShellTrayName, pTRAYDATA, sizeof_TRAYDATA, _TB_dwData(pTBBUTTON) )
	return false
}

; ##################################################
; 	Mouse actions simulate
; ##################################################

RightClickShellTrayToolbarButton(ByRef pTRAYDATA)
{
	Global
	Local hWnd := _TD_hWnd(pTRAYDATA)
	Local uID := _TD_uID(pTRAYDATA)
	Local uCallbackMessage := _TD_uCallbackMessage(pTRAYDATA)
	PostMessage( hWnd,  uCallbackMessage, uID, WM_RBUTTONDOWN)
	Sleep, 20
	PostMessage( hWnd,  uCallbackMessage, uID, WM_RBUTTONUP)
}

LeftClickShellTrayToolbarButton(ByRef pTRAYDATA)
{
	Global
	Local hWnd := _TD_hWnd(pTRAYDATA)
	Local uID := _TD_uID(pTRAYDATA)
	Local uCallbackMessage := _TD_uCallbackMessage(pTRAYDATA)
	PostMessage( hWnd,  uCallbackMessage, uID, WM_LBUTTONDOWN)
	Sleep, 20
	PostMessage( hWnd,  uCallbackMessage, uID, WM_LBUTTONUP)
}

LeftDbClickShellTrayToolbarButton(ByRef pTRAYDATA)
{
	Global
	Local hWnd := _TD_hWnd(pTRAYDATA)
	Local uID := _TD_uID(pTRAYDATA)
	Local uCallbackMessage := _TD_uCallbackMessage(pTRAYDATA)
	PostMessage( hWnd,  uCallbackMessage, uID, WM_LBUTTONDBLCLK)
}