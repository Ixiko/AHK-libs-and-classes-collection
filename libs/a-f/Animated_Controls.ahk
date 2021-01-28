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
AVI_CreateControl(_guiHwnd, _x, _y, _w, _h, _aviRef, _aviDLL="", _style="") {
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
AVI_Play(_aviHwnd) {
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
AVI_Stop(_aviHwnd) {
	; http://msdn.microsoft.com/library/en-us/shellcc/platform/commctls/animation/messages/acm_stop.asp
	; ACM_STOP := WM_USER + 102
	PostMessage 1126, 0, 0, , ahk_id %_aviHwnd%
}

; Probably optional, automatic on script close
AVI_DestroyControl(_aviHwnd) {
	If (_aviHwnd != 0)
		DllCall("DestroyWindow", "UInt", _aviHwnd)
}



/* GIF
Control_AniGif.ahk

Add a AniGif control to your AHK Gui.
AniGif by akyprian: http://www.winasm.net/forum/index.php?showtopic=279
From his source file:
;|AniGIF is a copyright of Antonis Kyprianou.                             |
;|                                                                        |
;|You can use AniGIF for NON commercial purposes provided you             |
;|have the following information on your application's about box:         |
;|AniGIF control is copyright of Antonis Kyprianou (http://www.winasm.net)|
;|                                                                        |
;|You need my WRITTEN permission to use AniGIF in commercial applications |

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.03.000 -- 2007/05/17 (PL) -- Total encapsulation.
 1.02.000 -- 2007/05/16 (PL) -- Changed functions names (thanks majkinetor), added more wrappers, freed correctly DLL.
 1.01.000 -- 2007/05/16 (PL) -- Update to 1.0.4.0 with WAGM_SETBKCOLOR.
 1.00.000 -- 2007/05/16 (PL) -- Creation.
*/
/* Copyright notice: For details, see the following file:
http://Phi.Lho.free.fr/softwares/PhiLhoSoft/PhiLhoSoftLicence.txt
This program is distributed under the zlib/libpng license.
Copyright (c) 2007 Philippe Lhoste / PhiLhoSoft
*/

/**
 * Control creation: you have to provide the ID of the GUI in which the control goes,
 * its position (_x, _y) and size (_w, _h) and optionally additional styles,
 * made of a string with keywords:
 * - autosize to make the control adapts to the Gif size
 * - center to center the Gif in the control
 * - hyperlink to allow clicking on the control and opening the URL defined later
 * Note that the required DLL is loaded automatically on first call.
 */
AniGif_CreateControl(_guiHwnd, _x, _y, _w, _h, _style="") {
	local hAniGif, agHwnd
	local msg, style
	static $bFirstCall := true

	If ($bFirstCall) {
		$bFirstCall := false
		; It will be unloaded at script end
		hAniGif := DllCall("LoadLibrary", "Str", "AniGif.dll")
	}

	style := 0
	If (_style != "") {
		If _style contains autosize
			style |= 1	; WAGS_AUTOSIZE
		If _style contains center
			style |= 2	; WAGS_CENTER
		If _style contains hyperlink
			style |= 4	; WAGS_HYPERLINK
	}
	; WS_CHILD | WS_VISIBLE
	style := 0x50000000 | style

	; http://msdn.microsoft.com/library/en-us/winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/createwindowex.asp
	agHwnd := DLLCall("CreateWindowEx"
			, "UInt", 0                     ; Style, can be WS_EX_CLIENTEDGE = 0x200
			, "Str", "AniGIF"               ; Class Name
			, "Str", "AnimatedGif"          ; Window name
			, "UInt",  style                ; Window style
			, "Int", _x                     ; X position
			, "Int", _y                     ; Y position
			, "Int", _w                     ; Width
			, "Int", _h                     ; Height
			, "UInt", _guiHwnd              ; Handle of parent
			, "UInt", 0                     ; Menu
			, "UInt", 0               ; hInstance of the module registering the component's class
			, "UInt", 0)                    ; User defined style
	If (ErrorLevel != 0 or agHwnd = 0) {
		msg = %msg% Cannot create AniGif control (%ErrorLevel%/%A_LastError%)
		Gosub AniGif_CreateControl_CleanUp
		Return msg
	}

	Return agHwnd

AniGif_CreateControl_CleanUp:	; In case of error
	; Nothing to do here
Return
}

/**
 * Function to call before exiting or destroying the GUI.
 */
AniGif_DestroyControl(_agHwnd) {
	If (_agHwnd != 0)
	{
		AniGif_UnloadGif(_agHwnd)
		DllCall("DestroyWindow", "UInt", _agHwnd)
	}
}


;AniGIF control messages
; WM_USER := 0x400 ; 1024
; WAGM_BASE := WM_USER+1000 ; 2024

/**
 * After control creation, allows to load the indicated file.
 */
AniGif_LoadGifFromFile(_agHwnd, _gifFile) {
	; WAGM_LOADGIFFROMFILE EQU WAGM_BASE+0	;wParam:N/A,		lParam:lpFileName
	SendMessage 2024, 0, &_gifFile, , ahk_id %_agHwnd%
}

; Skipped WAGM_LOADGIFFROMRESOURCE	EQU WAGM_BASE+1	;wParam:hInstance,	lParam:ResourceID
/**
 * Probably free memory used by the loaded Gif.
 */
AniGif_UnloadGif(_agHwnd) {
	; WAGM_UNLOADGIF EQU WAGM_BASE+2	;wParam:N/A,		lParam:N/A
	SendMessage 2026, 0, 0, , ahk_id %_agHwnd%
}

/**
 * Set the URL of the hyperlink called when clicking on the Gif.
 * The control must be created with the 'hyperlink' style.
 */
AniGif_SetHyperlink(_agHwnd, _url) {
	; WAGM_SETHYPERLINK EQU WAGM_BASE+3	;wParam:N/A,		lParam:lpszHyprelink
	SendMessage 2027, 0, &_url, , ahk_id %_agHwnd%
}

/**
 * Zoom in (_bZoomIn = 1) or zoom out (bZoomIn = 0) the given Gif by steps of 10%.
 */
AniGif_Zoom(_agHwnd, _bZoomIn) {
	; WAGM_ZOOM EQU WAGM_BASE+4	;wParam:N/A,		lParam:TRUE(Zoom In by 10%)/FALSE(Zoom Out by 10%)
	PostMessage 2028, 0, _bZoomIn, , ahk_id %_agHwnd%
}

/**
 * Change background color of the Gif (if it has transparency or if it is smaller than the control).
 * Color is in BGR format (ie. 0xFF8800 sets blue to FF, green to 88 and red to 00).
 */
AniGif_SetBkColor(_agHwnd, _backColor) {
	; WAGM_SETBKCOLOR EQU WAGM_BASE+5	;wParam:N/A,		lParam:BkColor
	PostMessage 2029, 0, _backColor, , ahk_id %_agHwnd%
}

