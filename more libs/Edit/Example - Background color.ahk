#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
$FontName   :="Verdana"
$FontOptions:="s10 cNavy"

;-- GUI options
gui -DPIScale -MinimizeBox
gui Margin,0,0

;-- GUI objects
gui Add,Button,       gBG1,      %A_Space%      1      %A_Space%
gui Add,Button,x+0 wp gBG2,      2
gui Add,Button,x+0 wp gBG3,      3
gui Add,Button,x+0 wp gBGRandom, Random
gui Add,Button,x+0 wp gBGDefault,Default

gui Font,%$FontOptions%,%$FontName%
gui Add
   ,Edit
   ,% "xm w500 r12 "
        . "+WantTab "
        . "+Wrap "
        . "+0x100 "         ;-- ES_NOHIDESEL
        . "hWndhEdit "
        . "vMyEdit "

;-- Reset font
gui Font

;-- Load default text
DefaultText=
   (ltrim join`s
    Instructions: Press any of "Background" buttons to see the changes to the
    background color.
    `r`n`r`nThis example shows one way to change the background color of an Edit
    control without a lot of programming.  This method uses the built-in
    AutoHotkey "gui Color" command.
    `r`n`r`nThere is good news and bad news.
    `r`n`r`nThe bad news first.  The "gui Color" command sets the background
    color of other GUI controls so there are some limitations.
    `r`n`r`nThe good news is that under most circumstances, there are simple
    changes that can be made that will allow this method to work for many/most
    windows.
   )

Edit_SetText(hEdit,DefaultText)

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GUIClose:
GUIEscape:
Exitapp


BG1:
gui Color,,FFCECE
return


BG2:
gui Color,,CEFFFF
return


BG3:
gui Color,,CEE7FF
return


BGRandom:
Random RandomColor,0x000000,0xFFFFFF
gui Color,,% Format("0x{:06X}",RandomColor)
return


BGDefault:
gui Color,,Default
return


Reload:
Reload
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
