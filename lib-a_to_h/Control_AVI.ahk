/*
Control_AVI.ahk

Add a SysAnimate32 (AVI animation) control to your AHK Gui.
Base code by daonlyfreez -- http://www.autohotkey.com/forum/viewtopic.php?t=13588

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.02.000 -- 2007/05/25 (PL) -- Improved encapsulation.
 1.01.000 -- 2007/05/16 (PL) -- Changed API for consistency with Control_AniGif.
 1.00.000 -- 2006/11/13 (PL) -- Creation.
*/
/* Copyright notice: For details, see the following file:
http://Phi.Lho.free.fr/softwares/PhiLhoSoft/PhiLhoSoftLicence.txt
This program is distributed under the zlib/libpng license.
Copyright (c) 2006-2007 Philippe Lhoste / PhiLhoSoft
*/

/**
 * Control creation: you have to provide the ID of the GUI in which the control goes,
 * its position (_x, _y) and it size (_w, _h), plus a reference to the AVI to display.
 * The later can be a digit (number/ID of AVI in the resources of a DLL) or a file name
 * (AVI in separate file). In the case of a number the DLL name must be given in _aviDLL.
 * Last, the style of the control can be changed, by giving a string with keywords:
 * - transparent to use the transparency of the AVI (strongly recommended)
 * - center to center the AVI in the control
 * - autoplay to let the AVI start on control creation
 * - all combines the three styles above.
 */
AVI_CreateControl(_guiHwnd, _x, _y, _w, _h, _aviRef, _aviDLL="", _style="")
{
	local aviHwnd, aviInstance, style
	local msg, r, c

	msg = Creation of '%_aviRef%' AVI failed:

	If (_aviDLL = "")
		_aviDLL = Shell32.dll	; Lot of standard AVIs in there
	If _aviRef is digit
	{
		aviInstance := DllCall("LoadLibrary", "Str", _aviDLL)
		If (aviInstance = 0)
		{
			msg = %msg% Cannot load '%_aviDLL%' DLL
			Return msg
		}
	}

	style := 0
	If (_style != "")
	{
		If _style contains transparent
			style |= 2	; ACS_TRANSPARENT
		If _style contains center
			style |= 1	; ACS_CENTER
		If _style contains autoplay
			style |= 4	; ACS_AUTOPLAY
		If _style contains all	; Simpler defaut...
			style |= 7
	}
	; WS_CHILD | WS_VISIBLE
	style := 0x50000000 | style

	; http://msdn.microsoft.com/library/en-us/winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/createwindowex.asp
	aviHwnd := DLLCall("CreateWindowEx"
			, "UInt", 0             ; Style
			, "Str", "SysAnimate32" ; Class Name
			, "UInt", 0             ; Window name
			, "UInt", style         ; Window style
			, "Int", _x             ; X position
			, "Int", _y             ; Y position
			, "Int", _w             ; Width
			, "Int", _h             ; Height
			, "UInt", _guiHwnd      ; Handle of parent
			, "UInt", 0             ; Menu
			, "UInt", 0             ; hInstance, unneeded with User32 components
			, "UInt", 0)            ; User defined style
	If (ErrorLevel != 0 or aviHwnd = 0)
	{
		msg = %msg% Cannot create AVI control (%ErrorLevel%/%A_LastError%)
		Gosub AVI_CreateControl_CleanUp
		Return msg
	}

	; http://msdn.microsoft.com/library/en-us/shellcc/platform/commctls/animation/messages/acm_open.asp
	; wParam: Instance handle to the module from which the resource should be loaded.
	;   Note that if the window is created by a DLL, the default value for hinst is the HINSTANCE value of the DLL,
	;   not of the application that calls the DLL.
	; lParam: Pointer to a buffer that contains the path of the AVI file or the name of an AVI resource.
	;   Alternatively, this parameter can consist of the AVI resource identifier in the low-order word and
	;   zero in the high-order word.
	; ACM_OPEN := WM_USER + 100
	If _aviRef is digit
	{
		SendMessage 1124, aviInstance, _aviRef, , ahk_id %aviHwnd%
	}
	Else
	{
		SendMessage 1124, 0, &_aviRef, , ahk_id %aviHwnd%
	}
	If (ErrorLevel = "FAIL" or ErrorLevel = 0)
	{
		msg = %msg% Cannot open AVI (%ErrorLevel%)
		Gosub AVI_CreateControl_CleanUp
		Return msg
	}

	Return aviHwnd

AVI_CreateControl_CleanUp:	; In case of error
	; Nothing to do here
Return
}

; WM_USER := 0x400 ; 1024

/**
 * Start (or continue) the animation.
 */
AVI_Play(_aviHwnd)
{
	; http://msdn.microsoft.com/library/en-us/shellcc/platform/commctls/animation/messages/acm_play.asp
	; wParam: Number of times to replay the AVI clip. A value of -1 means replay the clip indefinitely.
	; lParam: MAKELONG(wFrom, wTo)
	;   wFrom: Zero-based index of the frame where playing begins. The value must be less than 65,536.
	;     A value of zero means begin with the first frame in the AVI clip.
	;   wTo: Zero-based index of the frame where playing ends.
	;     The value must be less than 65,536. A value of -1 means end with the last frame in the AVI clip.
	; ACM_PLAY := WM_USER + 101
	PostMessage 1125, -1, -1, , ahk_id %_aviHwnd%
}

/**
 * Stop (pause) the animation.
 */
AVI_Stop(_aviHwnd)
{
	; http://msdn.microsoft.com/library/en-us/shellcc/platform/commctls/animation/messages/acm_stop.asp
	; ACM_STOP := WM_USER + 102
	PostMessage 1126, 0, 0, , ahk_id %_aviHwnd%
}

; Probably optional, automatic on script close
AVI_DestroyControl(_aviHwnd)
{
	If (_aviHwnd != 0)
		DllCall("DestroyWindow", "UInt", _aviHwnd)
}


;-----8<----- For real use, just remove the part below before including the file ----------
; Run test code only if the file is ran standalone
If (A_ScriptName = "Control_AVI.ahk")
{

AVI_Shell32 =
( Join|
000 - File
150 - Search flashlight
151 - Search documents
152 - Search computer
160 - Move files
161 - Copy files
162 - Delete files
163 - Empty trash
164 - Empty folder
165 - Check files
166 - Search internet
167 - Move files
168 - Copy files
169 - Empty folder
170 - Download files
)
AVI_MSGina = 2413 - Ctrl+Alt+Delete
AVI_SyncUI = 133 - Sync|134 - Compare
AVI_WIADefUI =
( Join|
1000 - Camera connect
1001 - Scanner connect
1002 - Camcorder connect
1003 - Camcorder copy
1004 - Scanner copy
1005 - Camera copy
1006 - Camera and scanner connect
)
AVI_XPSP2 = 140 - Search flashlight|160 - Network connect

Gui +LastFound
guiID := WinExist()

width := 300

h1 := AVI_CreateControl(guiID, 10, 10, width, 130, 165, "", "all")
If h1 is not integer
	MsgBox %h1%
Gui Add, Button, x10 y150 w50 v11 gControl_AVI_Control, Start
Gui Add, Button, x70 y150 w50 v01 gControl_AVI_Control, Stop

h2 := AVI_CreateControl(guiID, 350, 10, width, 130, 1006, "WIADefUI.dll", "all")
If h2 is not integer
	MsgBox %h2%
Gui Add, Button, x350 y150 w50 v12 gControl_AVI_Control, Start
Gui Add, Button, x420 y150 w50 v02 gControl_AVI_Control, Stop

;~ h3 := AVI_CreateControl(guiID, 650, 10, width, 130, A_WinDir . "\Clock.avi")
;~ h3 := AVI_CreateControl(guiID, 650, 10, width, 130, A_ScriptDir . "\CtrlAltDel.avi")
h3 := AVI_CreateControl(guiID, 650, 10, width, 130, A_ScriptDir . "\G.avi")
If h3 is not integer
	MsgBox %h3%
Gui Add, Button, x650 y150 w50 v13 gControl_AVI_Control, Start
Gui Add, Button, x720 y150 w50 v03 gControl_AVI_Control, Stop

Gui Add, Button, x10 y200 w50 gControl_AVI_Exit, End

Gui Show, w960, AVI Demo
Return

Control_AVI_Control:
	StringLeft action, A_GuiControl, 1
	StringRight control, A_GuiControl, 1
	If (action = 1)
		AVI_Play(h%control%)
	Else If (action = 0)
		AVI_Stop(h%control%)
Return

Control_AVI_Exit:
	ExitApp

}
