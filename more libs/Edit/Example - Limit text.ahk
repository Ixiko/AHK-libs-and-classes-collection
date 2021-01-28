#NoEnv
#SingleInstance Force
ListLines Off

gui -DPIScale -MinimizeBox
gui Add,Text,,Single-line edit control:
gui Add,Edit,xm w400 hWndhEdit1
gui Add,Text,,Multiline edit control:
gui Add,Edit,xm w400 r5 hWndhEdit2
gui Add,Button,xm gGetLimit,%A_Space%Get Limit%A_Space%
gui Add,Text,x+10,Set Limit:%A_Space%
gui Add,DropDownList,x+0 w60 vLimit gSetLimit,0||10|20|30|40|50|60|70|80|90|100
gui Add,Text,x+5,(Choose 0 to remove limit)

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return

GUIEscape:
GUIClose:
ExitApp


GetLimit:
MsgBox % "Limit for single-line edit control: " . Edit_getLimitText(hEdit1)
    . "`nLimit for multiline edit control: " . Edit_getLimitText(hEdit2)
return


SetLimit:
gui Submit,NoHide
Edit_SetLimitText(hEdit1,Limit)
Edit_SetLimitText(hEdit2,Limit)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
