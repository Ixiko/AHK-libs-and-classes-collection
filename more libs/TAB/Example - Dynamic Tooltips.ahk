/*
    In this example, a dynamic tooltip is shown every time the mouse hovers over
    a tab.

    This example also uses TAB_ToolTips_SetTitle to create a title for the
    tooltips.  This function should only be called if the title is same for all
    tooltips or, as in this example, the title is changed every time a tooltip
    is shown.


    Programming Notes:

    This example uses the tooltip control created by the operating system.  This
    tooltip control is automatically created and attached to the tab control
    when the TCS_TOOLTIPS style is included when the tab control is created.  By
    default, this tooltip control does not show multiple lines of text.  However,
    because a tooltip title is shown, the OS makes an exception to the rule and
    multiple lines of text are shown.  If a title is not set and multiple lines
    of text are required, create a custom tooltip control or use the
    TTM_SETMAXTIPWIDTH message to modify the tooltip control so that multiple
    lines of text are shown.
*/
#NoEnv
#SingleInstance Force
ListLines Off

;-- Tab control styles
TCS_RIGHTJUSTIFY      :=0x0
TCS_SINGLELINE        :=0x0
TCS_EX_FLATSEPARATORS :=0x1
TCS_SCROLLOPPOSITE    :=0x1
TCS_RIGHT             :=0x2
TCS_BOTTOM            :=0x2
TCS_MULTISELECT       :=0x4
TCS_FLATBUTTONS       :=0x8
TCS_FORCEICONLEFT     :=0x10
TCS_FORCELABELLEFT    :=0x20
TCS_HOTTRACK          :=0x40
TCS_VERTICAL          :=0x80
TCS_BUTTONS           :=0x100
TCS_MULTILINE         :=0x200
TCS_FIXEDWIDTH        :=0x400
TCS_RAGGEDRIGHT       :=0x800
TCS_FOCUSONBUTTONDOWN :=0x1000
TCS_OWNERDRAWFIXED    :=0x2000
TCS_TOOLTIPS          :=0x4000
TCS_FOCUSNEVER        :=0x8000

;-- Messages
WM_NOTIFY :=0x4E

;-- Initialize
TCWidth     :=400
TCHeight    :=300
StringStyle :=""
IconDir     :=A_ScriptDir . "\_Example Files\ico"
MarginX     :=10
MarginY     :=10

Servers=
   (ltrim join|
    Dallas
    Decatur
    Denver
    Detroit
    Dover
    Dodge City
   )

;-- Create and populate image list
hIL:=TAB_CreateImageList(32,32)
IL_Add(hIL,IconDir . "\Server.png",1)

;-- Build GUI
gui -DPIScale +hWndhGUI
gui Margin,%MarginX%,%MarginY%

;-- Tab control
TabStyle :=TCS_TOOLTIPS  ;|TCS_BUTTONS ;|TCS_FORCELABELLEFT|TCS_FIXEDWIDTH   ;|TCS_FORCEICONLEFT|TCS_FIXEDWIDTH
gui Add,Tab3,xm w%TCWidth% h%TCHeight% %TabStyle% hWndhTab vMyTab,%Servers%

;-- Assign image list to the tab control
TAB_SetImageList(hTab,hIL)

;-- Assign icons to the tabs
Loop Parse,Servers,|
    TAB_SetIcon(hTab,A_Index,1)

;-- (Slightly) increase the height of the tabs
;   ##### Experimental.  This is done so that icon fits comfortably within each
;   tab.
TAB_SetItemSize(hTab,1,42)

;-- Force the tab control to reset all (OK, most) of the tab objects
;   Note: For the Tab3 control, this step is necessary to (re)position/(re)size
;   the tabs so that GUI controls added to the tab control are positioned and
;   displayed correctly.  It's not necessary for the Tab and Tab2 control but
;   it does no harm.
GUIControl,,%hTab%

;-- Get display area
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)
ControlW :=DisplayAreaW-(MarginX*2)

;-- Add GUI controls for each tab
Loop Parse,Servers,|
    {
    gui Tab,%A_LoopField%
    gui Add,Text,w%ControlW%,
       (ltrim join`s
        The GUI controls shown in this tab are for display purposes only.  Hover
        the mouse over the tabs see the tooltips.
       )

    gui Add,Text,,Utilization:
    Random PPos,10,100
    gui Add,Progress,y+1 w%ControlW% h30 -Smooth,%PPos%

    gui Add,Text,,Temperature:
    Random PPos,70,100
    gui Add,Progress,y+1 w%ControlW% h30 -Smooth,%PPos%
    }

;-- End of tabs
gui Tab

;-- After
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%

;-- Track mouse movement
OnMessage(WM_NOTIFY,"OnTooltipNotify")
return


GUIEscape:
GUIClose:
IL_Destroy(hIL)
ExitApp


Reload:
Reload
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
OnTooltipNotify(wParam,lParam,Msg,hWnd)
    {
    Global hTab
    Static Dummy28696638
          ,Previous_iTab
          ,Previous_TickCount
          ,wText

          ;-- Notifications
          ,TTN_FIRST       :=-520
          ,TTN_GETDISPINFOA:=-520                       ;-- TTN_FIRST - 0
          ,TTN_GETDISPINFOW:=-530                       ;-- TTN_FIRST - 10

    ;-- Collect notification code
    Code:=NumGet(lParam+0,(A_PtrSize=8) ? 16:8,"Int")
        ;-- hdr.code
        ;   Note: hdr.code is defined as "UInt" but it is read as "Int" because
        ;   the member contains negative values.

    ;-- Bounce if not a TTN_GETDISPINFO notification
    if Code not in %TTN_GETDISPINFOA%,%TTN_GETDISPINFOW%
        return

    ;-- Collect data from the NMHDR structure
    hTT:=hWndFrom:=NumGet(lParam+0,0,"Ptr")
        ;-- Handle to the tooltip control.  Superfluous for this example because
        ;   if needed, the TAB library function will get it from tab control.
        ;   But it's available if other any program needs it.

    idFrom :=NumGet(lParam+0,(A_PtrSize=8) ? 8:4,"Ptr")
    iTab:=idFrom+1

    ;-- If duplicate request, return TRUE with the same text
    if (iTab=Previous_iTab and A_TickCount=Previous_TickCount)
        {
        NumPut(&wText,lParam+0,(A_PtrSize=8) ? 24:12,"Ptr") ;-- lpszText
        Return True
        }

    Previous_iTab:=iTab
    Previous_TickCount:=A_TickCount

    ;-- Create a dynamic tooltip
    ServerName :=TAB_GetText(hTab,iTab)
    Random RandomCondition,1,3
    if (RandomCondition=1)  ;-- Normal
        {
        TAB_Tooltips_SetTitle(hTab,ServerName,4)
        Text=
           (ltrim join`s
            The server is operating normally.
           )
        }

    if (RandomCondition=2)  ;-- Alert
        {
        TAB_Tooltips_SetTitle(hTab,ServerName,5)
        Text=
           (ltrim
            The server temperature is above normal but
            within safe levels.
           )
        }

    if (RandomCondition=3)  ;-- Error
        {
        TAB_Tooltips_SetTitle(hTab,ServerName,6)
        Text=
           (ltrim
            The server temperature is above safe levels.
            Attention is required.
           )
        }

    ;-- If needed, convert text to Unicode
    wText:=Text
    if not A_IsUnicode and StrLen(Text)
        {
        VarSetCapacity(wText,StrLen(Text)*2,0)
        StrPut(Text,&wText,"UTF-16")
        }

    ;-- Set text
    NumPut(&wText,lParam+0,(A_PtrSize=8) ? 24:12,"Ptr") ;-- lpszText
        ;   Note: lpszText must point to a static variable in this case because
        ;   the function ends well before the text is displayed.  A pointer to
        ;   a global variable would also work.

    ;-- Notify the system that this message has been processed
    Return True
    }

#include %A_ScriptDir%/_Functions
#include TAB.ahk
