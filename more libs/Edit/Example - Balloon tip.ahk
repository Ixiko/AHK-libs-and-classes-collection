#NoEnv
#SingleInstance Force
ListLines Off

;-- Microsoft constants
WM_COMMAND :=0x111

;-- Build/Show GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Edit,xm w350  hWndhEdit1
gui Add,Edit,xm w350  hWndhEdit2
gui Add,Edit,xm w350  hWndhEdit3
gui Add,Edit,xm w190  hWndhEdit4
gui Add,Edit,x+0 w50  hWndhEdit5
gui Add,Edit,x+0 w110 hWndhEdit6
gui Add,Edit,xm w350  hWndhEdit7 +Password

gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Monitor change of focus (notification is sent via the WM_COMMAND message)
OnMessage(WM_COMMAND,"WM_COMMAND")

;-- Show the balloon tip for the first Edit control
ShowBalloonTip(hEdit1)
return


GUIEscape:
GUIClose:
ExitApp


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk

ShowBalloonTip(hEdit)
    {
    Global hEdit1,hEdit2,hEdit3,hEdit4,hEdit5,hEdit6,hEdit7
    Random ShowTitle,0,1
    Random Icon,0,3
    Title:=ShowTitle ? "The Title is optional but the icon (if any) will not show without it":""
    if (hEdit=hEdit1)
        FieldLabel:="Name"
    else if (hEdit=hEdit2)
        FieldLabel:="Address 1"
    else if (hEdit=hEdit3)
        FieldLabel:="Address 2"
    else if (hEdit=hEdit4)
        FieldLabel:="City"
    else if (hEdit=hEdit5)
        FieldLabel:="State"
    else if (hEdit=hEdit6)
        FieldLabel:="Zip Code"
    else if (hEdit=hEdit7)
        FieldLabel:="Password"

    Edit_ShowBalloonTip(hEdit,Title,FieldLabel,Icon)
    SB_SetText(FieldLabel)
    }


/*
    Documentation for the WM_COMMAND message can be found here:
        http://msdn.microsoft.com/en-us/library/windows/desktop/ms647591(v=vs.85).aspx

    Documentation for the EN_SETFOCUS notification can be found here:
        http://msdn.microsoft.com/en-us/library/windows/desktop/bb761685(v=vs.85).aspx
*/
WM_COMMAND(wParam,lParam,Msg,hWnd)
    {
    Static EN_SETFOCUS:=0x100
    if (wParam>>16=EN_SETFOCUS)
        ShowBalloonTip(lParam)

    Return
    }

