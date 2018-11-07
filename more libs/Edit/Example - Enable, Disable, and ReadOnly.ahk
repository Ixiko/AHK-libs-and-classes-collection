/*
    This example shows the difference between disabling and enabling an Edit
    control versus setting or removing the ReadOnly style.  Although a disabled
    Edit control is visually similar to an Edit control using the ReadOnly
    style, the functionality is very different.
*/

#NoEnv
#SingleInstance Force
ListLines Off

gui -DPIScale -MinimizeBox
gui Add,Text,,Single-line edit control:
gui Add,Edit,xm w450 hWndhEdit1,Just some text. Don't freak out!
gui Add,Text,,Multiline edit control:
gui Add,Edit,xm w450 r5 hWndhEdit2,Line 1`nLine 2`nLine 3`nLine 4`nLine 5`nLine 6`nLine 7`nLine 8`nLine 9
gui Add,Button,xm     gDisable,%A_Space%     Disable     %A_Space%
gui Add,Button,x+0 wp gEnable,Enable
gui Add,Button,xm  wp gReadOnlyOn,+ReadOnly
gui Add,Button,x+0 wp gReadOnlyOff,-ReadOnly

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GUIEscape:
GUIClose:
ExitApp


Enable:
gui Submit,NoHide
Edit_Enable(hEdit1)
Edit_Enable(hEdit2)
return


Disable:
gui Submit,NoHide
Edit_Disable(hEdit1)
Edit_Disable(hEdit2)
return


ReadOnlyOn:
Edit_SetReadOnly(hEdit1,True)
Edit_SetReadOnly(hEdit2,True)
return


ReadOnlyOff:
Edit_SetReadOnly(hEdit1,False)
Edit_SetReadOnly(hEdit2,False)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
