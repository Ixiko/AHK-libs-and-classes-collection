#NoEnv
#SingleInstance Force
ListLines Off

gui -DPIScale -MinimizeBox
gui Add,Text,xm,Password:
gui Add,Edit,xm w300 hWndhEdit +Password,ThisIsTh3P@ssw0rd
PWCharValue:=Edit_GetPasswordChar(hEdit)
gui Add,CheckBox,vShowPassword gShowPassword,Show password

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GUIEscape:
GUIClose:
ExitApp


ShowPassword:
gui Submit,NoHide
if ShowPassword
    Edit_SetPasswordChar(hEdit,0)  ;-- 0=Remove password character
 else
    Edit_SetPasswordChar(hEdit,PWCharValue)

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
