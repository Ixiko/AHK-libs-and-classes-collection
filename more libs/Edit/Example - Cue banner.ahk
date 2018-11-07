#NoEnv
#SingleInstance Force
ListLines Off

;-- Microsoft constants
WM_COMMAND :=0x111

;-- Create GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Edit,xm w350 hWndhEdit1
Edit_SetCueBanner(hEdit1,"Name",True)
gui Add,Edit,xm w350 hWndhEdit2
Edit_SetCueBanner(hEdit2,"Address 1")
gui Add,Edit,xm w350 hWndhEdit3
Edit_SetCueBanner(hEdit3,"Address 2")
gui Add,Edit,xm w190 hWndhEdit4
Edit_SetCueBanner(hEdit4,"City")
gui Add,Edit,x+0 w50 hWndhEdit5
Edit_SetCueBanner(hEdit5,"State")
gui Add,Edit,x+0 w110 hWndhEdit6
Edit_SetCueBanner(hEdit6,"Zip")
gui Add,Edit,xm w350 hWndhEdit7 +Password
Edit_SetCueBanner(hEdit7,"Password",True)

gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Monitor change of focus (notification is sent via the WM_COMMAND message)
OnMessage(WM_COMMAND,"WM_COMMAND")

;-- Set the status bar text for the first Edit control
SetSBText(hEdit1)
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

SetSBText(hEdit)
    {
    Text:=Edit_GetCueBanner(hEdit)
    if Text is Space   ;-- Always returns blank if not Vista+
        Text:="GetCueBanner does not work on this version of Windows."

    SB_SetText(Text)
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
        SetSBText(lParam)

    Return
    }

