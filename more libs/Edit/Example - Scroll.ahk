/*
    Most (all?) of the Edit library's scroll-related functions are demonstrated
    in this example.  There are few scrolling-via-mouse hotkeys hidden in
    the example.  Look in the "Hotkeys" section at the bottom for more
    information.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Get Window handle
gui +LastFound
WinGet hWindow,ID
GroupAdd ExampleGroup,ahk_ID %hWindow%

;-- GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0
gui Font,,Lucida Console
gui Add
   ,Edit
   ,w450 r13 hWndhEdit +0x100000 ;-- 0x100000=WS_HSCROLL
gui Font

;-- Buttons
gui Add,Button,xm +Hidden,1234567890   ;-- Dummy button used to establish width

gui Font,,Wingdings
gui Add,Button,xp yp wp     gVScrollUp,             á
gui Add,Button,x+0 wp hp    gVScrollDn,             â
gui Font
gui Add,Button,x+0 wp hp    gVScrollPageUp,         Page Up
gui Add,Button,x+0 wp hp    gVScrollPageDn,         Page Dn

gui Font,,Wingdings
gui Add,Button,xm wp hp     gHScrollLeft,           ß
gui Add,Button,x+0 wp hp    gHScrollRight,          à
gui Font
gui Add,Button,x+0 wp hp    gHScrollPageLeft,       Page Left
gui Add,Button,x+0 wp hp    gHScrollPageRight,      Page Right

gui Font,,Wingdings
gui Add,Button,xm  wp hp    gTop,                   é
gui Add,Button,x+0 wp hp    gBottom,                ê
gui Add,Button,xm  wp hp    gLeft,                  ç
gui Add,Button,x+0 wp hp    gRight,                 è
gui Add,Button,xm  wp hp    gLeftTop,               ë
gui Add,Button,x+0 wp hp    gRightTop,              ì
gui Add,Button,xm  wp hp    gLeftBottom,            í
gui Add,Button,x+0 wp hp    gRightBottom,           î
gui Font
gui Add,Button,xm           gDisableAllScrollBars,  %A_Space% Disable Scroll Bars %A_Space%
gui Add,Button,x+0 wp       gEnableAllScrollBars,   Enable Scroll Bars
gui Add,Button,xm  wp       gHideAllScrollBars,     Hide Scroll Bars
gui Add,Button,x+0 wp       gShowAllScrollBars,     Show Scroll Bars
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%

;-- Status bar
gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Populate control
Edit_ReadFile(hEdit,A_ScriptDir . "\_Example Files\Scroll Example.txt")
return

GUIClose:
GUIEscape:
ExitApp


HScrollLeft:
RC :=Edit_LineScroll(hEdit,-1)
SB_SetText("Return code from request: " . RC)
return

HScrollRight:
RC :=Edit_LineScroll(hEdit,1)
SB_SetText("Return code from request: " . RC)
return

HScrollPageLeft:
RC :=Edit_ScrollPage(hEdit,-1)
SB_SetText("Return code from request: " . RC)
return

HScrollPageRight:
RC :=Edit_ScrollPage(hEdit,1)
SB_SetText("Return code from request: " . RC)
return

VScrollUp:
RC :=Edit_Scroll(hEdit,0,-1)
SB_SetText("Return code from request: " . RC)
return

VScrollDn:
RC :=Edit_Scroll(hEdit,0,1)
SB_SetText("Return code from request: " . RC)
return

VScrollPageUp:
RC :=Edit_Scroll(hEdit,-1)
SB_SetText("Return code from request: " . RC)
return

VScrollPageDn:
RC :=Edit_Scroll(hEdit,1)
SB_SetText("Return code from request: " . RC)
return

Left:
RC :=Edit_LineScroll(hEdit,"Left")
SB_SetText("Return code from request: " . RC)
return

Right:
RC :=Edit_LineScroll(hEdit,"Right")
SB_SetText("Return code from request: " . RC)
return

Top:
RC :=Edit_LineScroll(hEdit,"Top")
SB_SetText("Return code from request: " . RC)
return

Bottom:
RC :=Edit_LineScroll(hEdit,"Bottom")
SB_SetText("Return code from request: " . RC)
return

LeftTop:
RC :=Edit_LineScroll(hEdit,"Left","Top")
SB_SetText("Return code from request: " . RC)
return

RightTop:
RC :=Edit_LineScroll(hEdit,"Right","Top")
SB_SetText("Return code from request: " . RC)
return

LeftBottom:
RC :=Edit_LineScroll(hEdit,"Left","Bottom")
SB_SetText("Return code from request: " . RC)
return

RightBottom:
RC :=Edit_LineScroll(hEdit,"Right","Bottom")
SB_SetText("Return code from request: " . RC)
return

DisableAllScrollBars:
EnableAllScrollBars:
HideAllScrollBars:
ShowAllScrollBars:
RC :=Edit_%A_ThisLabel%(hEdit)
SB_SetText("Return code from request: " . RC)
if not RC
    SoundPlay *-1  ; Default system sound

return


Reload:
Reload
return


;*************************
;*                       *
;*                       *
;*        Hotkeys        *
;*                       *
;*                       *
;*************************
#IfWinActive ahk_group ExampleGroup

WheelUp::
RC :=Edit_LineScroll(hEdit,0,-3)
SB_SetText("Return code from request: " . RC)
Return

+WheelUp::
RC :=Edit_LineScroll(hEdit,-3)
SB_SetText("Return code from request: " . RC)
Return

WheelDown::
RC :=Edit_LineScroll(hEdit,0,3)
SB_SetText("Return code from request: " . RC)
Return

+WheelDown::
RC :=Edit_LineScroll(hEdit,3)
SB_SetText("Return code from request: " . RC)
Return

#IfWinActive


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
