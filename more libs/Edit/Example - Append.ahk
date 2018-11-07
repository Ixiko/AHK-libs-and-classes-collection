;-- Credit: The idea for this example from TheGood.  Thanks!
;   Post:   http://www.autohotkey.com/board/topic/52441-append-text-to-an-edit-control/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Build/Show GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Edit,hwndhEdit w400 r15
gui Font

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Start with some text so we can tell what's happening
Edit_SetText(hEdit,"The Quick Brown Fox Jumps Over The Lazy Dog`r`n")

;-- Append stuff once per second
SetTimer Append,1000
return


GUIClose:
GUIEscape:
ExitApp


Append:

;-- Position the caret to the last position + 1
Edit_SetSel(hEdit,Edit_GetTextLength(hEdit))

;-- Insert new text
Random RandomNumber,100000,999999
Edit_ReplaceSel(hEdit,A_Now . ": " . RandomNumber . "`r`n")
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
