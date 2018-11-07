#NoEnv
#SingleInstance Force
ListLines Off

;-- GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0
gui Font,,Lucida Console
gui Add
   ,Edit
   ,% ""
        . "xm w450 r13 "
        . "+0x100000 "  ;-- WS_HSCROLL
        . "hWndhEdit "
gui Font

;-- Buttons
gui Add,Button,xm +Hidden,Dummy   ;-- Dummy button used to establish height
gui Add,Text,xp yp hp,                                  %A_Space%Horizontal:%A_Space%
gui Add,Button,x+0 hp Section   gDisableHScrollBar,     %A_Space%   Disable   %A_Space%
gui Add,Button,x+0 wp           gEnableHScrollBar,      Enable
gui Add,Button,x+0 wp           gHideHScrollBar,        Hide
gui Add,Button,x+0 wp           gShowHScrollBar,        Show
gui Add,Text,xm,                                        %A_Space%Vertical:
gui Add,Button,xs yp            gDisableVScrollBar,     %A_Space%   Disable   %A_Space%
gui Add,Button,x+0 wp           gEnableVScrollBar,      Enable
gui Add,Button,x+0 wp           gHideVScrollBar,        Hide
gui Add,Button,x+0 wp           gShowVScrollBar,        Show
gui Add,Text,xm,                                        %A_Space%All:
gui Add,Button,xs yp            gDisableAllScrollBars,  %A_Space%   Disable   %A_Space%
gui Add,Button,x+0 wp           gEnableAllScrollBars,   Enable
gui Add,Button,x+0 wp           gHideAllScrollBars,     Hide
gui Add,Button,x+0 wp           gShowAllScrollBars,     Show

;-- Status bar
gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

;-- Show it!
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Populate control
Edit_ReadFile(hEdit,A_ScriptDir . "\_Example Files\Scroll Example.txt")

;-- Start ToolTip status timer
SetTimer ToolTipStatus
return

GUIClose:
GUIEscape:
ExitApp


DisableHScrollBar:
DisableVScrollBar:
DisableAllScrollBars:
EnableHScrollBar:
EnableVScrollBar:
EnableAllScrollBars:
HideHScrollBar:
HideVScrollBar:
HideAllScrollBars:
ShowHScrollBar:
ShowVScrollBar:
ShowAllScrollBars:
RC :=Edit_%A_ThisLabel%(hEdit)
SB_SetText("Return code from request: " . RC)
if not RC
    SoundPlay *-1  ; Default system sound

return


ToolTipStatus:
RC :=Edit_IsHScrollBarVisible(hEdit)
Message:="Horizontal scroll bar is "
Message.=RC ? "visible":"hidden."

if RC
    {
    Message.=" and "
    Message.=Edit_IsHScrollBarEnabled(hEdit) ? "enabled.":"disabled."
    }

RC :=Edit_IsVScrollBarVisible(hEdit)
Message.="`nVertical scroll bar is "
Message.=RC ? "visible":"hidden."

if RC 
    {
    Message.=" and "
    Message.=Edit_IsVScrollBarEnabled(hEdit) ? "enabled.":"disabled."
    }

ToolTip %Message%,0,-40
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
