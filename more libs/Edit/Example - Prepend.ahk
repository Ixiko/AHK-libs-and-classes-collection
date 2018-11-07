/*
    Credit: The idea for this example (and some code) from SKAN.  Thanks!
    Post:   http://www.autohotkey.com/board/topic/84520-prepend-text-to-edit-control/#entry538568
*/

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
    ;-- Note: CR+LF added at the end of the text to support quick changes to
    ;   this example.

;-- Prepend stuff once per second
SetTimer Prepend,1000
return


GUIClose:
GUIEscape:
ExitApp


Prepend:

;-- Position the caret at the very top
Edit_SetSel(hEdit,0,0)
    ;-- Hint: The values "0,0" just mean start position 0 and end position 0.
    ;   These values can be changed to any value.  Try changing the values to
    ;   "45,45" to see that new text is prepended (oxymoronic use of the word
    ;   "prepend" at this point) after the "The Quick Brown..." header.   

;-- Insert new text
Random RandomNumber,100000,999999
Edit_ReplaceSel(hEdit,A_Now . ": " . RandomNumber . "`r`n")

;-- (Optional) Move the caret back to the very first position.
;   Note: This step gives the UI a cleaner look.
Edit_SetSel(hEdit,0,0)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
