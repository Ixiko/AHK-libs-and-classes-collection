/*
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
AniGif_CreateControl(_guiHwnd, _x, _y, _w, _h, _style="")
{
	local hAniGif, agHwnd
	local msg, style
	static $bFirstCall := true

	If ($bFirstCall)
	{
		$bFirstCall := false
		; It will be unloaded at script end
		hAniGif := DllCall("LoadLibrary", "Str", "AniGif.dll")
	}

	style := 0
	If (_style != "")
	{
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
	If (ErrorLevel != 0 or agHwnd = 0)
	{
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
AniGif_DestroyControl(_agHwnd)
{
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

AniGif_LoadGifFromFile(_agHwnd, _gifFile)
{
; WAGM_LOADGIFFROMFILE EQU WAGM_BASE+0 ;wParam:N/A, lParam:lpFileName
VarSetCapacity(var, StrPut(_gifFile, "cp0") * 2)
StrPut(_gifFile, &var, "cp0")
SendMessage, 2024, 0, &var, , ahk_id %_agHwnd%
}

; Skipped WAGM_LOADGIFFROMRESOURCE	EQU WAGM_BASE+1	;wParam:hInstance,	lParam:ResourceID

/**
 * Probably free memory used by the loaded Gif.
 */
AniGif_UnloadGif(_agHwnd)
{
	; WAGM_UNLOADGIF EQU WAGM_BASE+2	;wParam:N/A,		lParam:N/A
	SendMessage 2026, 0, 0, , ahk_id %_agHwnd%
}

/**
 * Set the URL of the hyperlink called when clicking on the Gif.
 * The control must be created with the 'hyperlink' style.
 */
AniGif_SetHyperlink(_agHwnd, _url)
{
	; WAGM_SETHYPERLINK EQU WAGM_BASE+3	;wParam:N/A,		lParam:lpszHyprelink
	SendMessage 2027, 0, &_url, , ahk_id %_agHwnd%
}

/**
 * Zoom in (_bZoomIn = 1) or zoom out (bZoomIn = 0) the given Gif by steps of 10%.
 */
AniGif_Zoom(_agHwnd, _bZoomIn)
{
	; WAGM_ZOOM EQU WAGM_BASE+4	;wParam:N/A,		lParam:TRUE(Zoom In by 10%)/FALSE(Zoom Out by 10%)
	PostMessage 2028, 0, _bZoomIn, , ahk_id %_agHwnd%
}

/**
 * Change background color of the Gif (if it has transparency or if it is smaller than the control).
 * Color is in BGR format (ie. 0xFF8800 sets blue to FF, green to 88 and red to 00).
 */
AniGif_SetBkColor(_agHwnd, _backColor)
{
	; WAGM_SETBKCOLOR EQU WAGM_BASE+5	;wParam:N/A,		lParam:BkColor
	PostMessage 2029, 0, _backColor, , ahk_id %_agHwnd%
}