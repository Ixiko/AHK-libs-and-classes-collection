;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HoverScroll() Example Script
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
Instructions:

Scroll normally over any window or control to scroll vertically
Hold down Ctrl while scrolling to zoom in/out
Hold down Alt while scrolling to scroll horizontally
*/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv
#SingleInstance Force

;Prevent hotkey limit reached warning (500 is just an arbitrarily high number)
#MaxHotkeysPerInterval 500

#Include %A_ScriptDir%\..\Acc.ahk ;Required for scrolling in MS Office applications
#Include %A_ScriptDir%\..\HoverScroll.ahk

;Acc.ahk courtesy of AHK user "jethrow", for information please refer to the following thread:
;http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Normal vertical scrolling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WheelUp::
	Lines := ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines)
Return

WheelDown::
	Lines := -ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines)
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Horizontal scrolling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Note: Scrolling direction (left/right) can be inverted by adding a minus sign to Lines.
!WheelUp::
	Lines := -ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines, 0) ;0 = horizontal, 1 (or omit) = vertical
	ToolTip % "<    "
	SetTimer KillToolTip, -300
Return

!WheelDown::
	Lines := ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines, 0) ;0 = horizontal, 1 (or omit) = vertical
	ToolTip % "    >"
	SetTimer KillToolTip, -300
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Zooming (Ctrl-Scroll)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If required, you can split *WheelUp and *WheelDown into hotkeys for Shift, Alt, Ctrl and combinations of these.. In this example we separate the Ctrl-Scroll hotkeys so that different code runs whhen Ctrl is held down, in this case a tooltip is displayed when zooming. We could also pass different parameters to the ScrollLines() function if different acceleration is required when zooming.

;NOTE: For zooming scrolling more than 1 line per notch can cause target control to scroll vertically as well, so I suggest using a value of 1.

;Zoom IN
^WheelUp::
	Lines := -1
	HoverScroll(Lines,,1)
	ToolTip % "IN"
	SetTimer KillToolTip, -400
Return

;Zoom OUT
^WheelDown::
	Lines := 1
	HoverScroll(Lines,,1)
	ToolTip % "OUT"
	SetTimer KillToolTip, -400
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;All other modifiers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;NOTE: Although in theory *WheelUp already includes ^WheelUp, ^WheelUp takes precedence because it appears first in the script (above *WheelUp). The same applies to WheelDown, so you don't need to worry about duplicate hotkeys.

*WheelUp::
	Lines := ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines)
Return

*WheelDown::
	Lines := -ScrollLines_1(HoverScrollMinLines, HoverScrollMaxLines, HoverScrollThreshold, HoverScrollCurve)
	HoverScroll(Lines)
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KillToolTip:
	Tooltip
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;