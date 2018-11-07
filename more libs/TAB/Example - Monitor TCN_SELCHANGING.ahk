/*
    In this example, the TCN_SELCHANGING notification is monitored.  When the
    user attempts to select a new tab, the notification is sent and the program
    checks to see if the contents of the tab are valid.  If validation succeeds,
    the selection is allowed to complete.  If validation fails, an error message
    is shown and the selection remains on the current tab.

    Programming note:  If the program rejects the select tab request, the
    program should notify the user.  A beep, tooltip, MsgBox dialog, message
    on the status bar, etc.  Without some sort of visual or sound notification,
    the user won't know why the request was rejected and the will likely try
    again and again.

    Note: The TCS_FOCUSNEVER style is necessary to keep the user from changing
    the tab by clicking on the already selected tab and then using the arrow
    buttons to change the tab.  Reason: The arrow keyboard shortcuts call
    routines that do NOT send the TCN_SELCHANGING notification.  In addition,
    the PgUp and PgUp keys have been hijacked to call standard library function
    to navigate to the next/previous tab.  Reason: The same.
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
MarginX  :=10
MarginY  :=10
TCWidth  :=300
TCHeight :=250

;-- Build GUI
gui -DPIScale +hWndhGUI
gui Margin,%MarginX%,%MarginY%
GroupAdd ExampleGUIGroup,ahk_ID %hGUI%

;-- Instructions
gui Add,Text,xm w%TCWidth%,
   (ltrim join`s
    In this example, the user is not allowed to go to the next (or any other)
    tab until the current tab has valid data.  This is accomplished by
    monitoring the TCN_SELCHANGING notification.
   )

;-- Inform options
gui Add,Text,xm,Show errors as:
gui Add,Radio,xm y+2 vError_BalloonTip Checked,BalloonTip
gui Add,Radio,xm y+4 vError_MsgBox,MsgBox

;-- Tab control
TabStyle :=TCS_FOCUSNEVER
gui Add,Tab3,xm w%TCWidth% h%TCHeight% hWndhTab vMyTab %TabStyle%,Name|Address|Phone

;-- Get display area and calculate control size
TAB_GetDisplayArea(hTab,,,DisplayAreaW,DisplayAreaH)
ControlW :=DisplayAreaW-(MarginX*2)

gui Tab,Name
gui Add,Text,,Name:
gui Add,Edit,y+0 w%ControlW% vName hWndhName
gui Add,Button,gNext,%A_Space%Next -->%A_Space%

gui Tab,Address
gui Add,Text,,Address:
gui Add,Edit,y+0 w%ControlW% r5 vAddress  hWndhAddress
gui Add,Button,gNext,%A_Space%Next -->%A_Space%
gui Add,Button,y+0 gPrev,%A_Space%<-- Prev%A_Space%

gui Tab,Phone
gui Add,Text,,Phone:
gui Add,Edit,y+0 w%ControlW% vPhone hWndhPhone
gui Add,Button,gPrev,%A_Space%<-- Prev%A_Space%

;-- End of tabs
gui Tab

;-- After tabs
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%

;-- Monitor for TCN_SELCHANGING notification
OnMessage(WM_NOTIFY,"OnSelChanging")
return


GUIClose:
GUIEscape:
ExitApp


Next:
Tab_SelectNext(hTab)
return


Prev:
Tab_SelectPrev(hTab)
return


Reload:
Reload
return


;*****************
;*               *
;*    Hotkeys    *
;*               *
;*****************
#IfWinActive ahk_group ExampleGUIGroup

;-- The following keyboard shortcuts have been hijacked so that standard library
;   functions are used to navigate to the next or previous tabs.  This will
;   ensure that the TCN_SELCHANGING notification is sent when the tab is about
;   to change.  This allows this script to reject the request if the tab does
;   not contain valid data.
*^+Tab::
*^PgUp::
TAB_SelectPrev(hTab,,True)
return

*^Tab::
*^PgDn::
TAB_SelectNext(hTab,,True)
return

#IfWinActive


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
OnSelChanging(wParam,lParam,Msg,hWnd)
    {
    Global hName,hAddress,hPhone,Error_BalloonTip,Error_MsgBox
    Static Dummy16707803
          ,TCN_FIRST      :=-550
          ,TCN_SELCHANGING:=-552  ;-- TCN_FIRST - 2

    ;-- Collect notification code
    Code:=NumGet(lParam+0,(A_PtrSize=8) ? 16:8,"Int")
        ;-- hdr.code
        ;   Note: hdr.code is defined as "UInt" but it is read as "Int" because
        ;   the member contains negative values.

    ;-- Bounce if not a TCN_SELCHANGING notification
    if (Code<>TCN_SELCHANGING)
        return

    ;-- Collect data from the NMHDR structure
    hTab:=hWndFrom:=NumGet(lParam+0,0,"Ptr")

    ;-- The hWndFrom member contains the handle to the tab control.  If there
    ;   were more than one tab control, it would be checked here.

    idFrom :=NumGet(lParam+0,(A_PtrSize=8) ? 8:4,"Ptr")
        ;-- ##### Don't know what this is for but apparently this is not used
        ;   for this notification.  Always contains 3 on my computer.  The
        ;   wParam value is also 3 for this notification.  Mentioned because
        ;   for some other notifications, this member contains the current
        ;   zero-index tab number.

    ;-- Get the currently selected tab.
    ;   Note: This notification is sent before the new tab is selected so the
    ;   currently selected tab is the tab that is selected BEFORE the new tab
    ;   selected.
    iTab:=TAB_GetCurSel(hTab)

    ;-- Determine if a new selection should be allowed
    GUIControlGet Error_BalloonTip,,Error_BalloonTip
    if (iTab=1)
        {
        GUIControlGet Name,,Name
        if Name is Space
            {
            if Error_BalloonTip
                Edit_ShowBalloonTip(hName,"Invalid Name","Name must not be blank.",3)
             else
                {
                gui +OwnDialogs
                MsgBox 0x10,Invalid Name,Name must not be blank.
                GUIControl Focus,Name
                }

            Return True  ;-- Selection rejected
            }
        }

    if (iTab=2)
        {
        GUIControlGet Address,,Address
        if Address is Space
            {
            if Error_BalloonTip
                Edit_ShowBalloonTip(hAddress,"Invalid Address","Address must not be blank.",3)
             else
                {
                gui +OwnDialogs
                MsgBox 0x10,Invalid Address,Address must not be blank.
                GUIControl Focus,Address
                }

            Return True  ;-- Selection rejected
            }
        }

    if (iTab=3)
        {
        GUIControlGet Phone,,Phone
        if Phone is not Integer
            {
            if Error_BalloonTip
                Edit_ShowBalloonTip(hPhone,"Invalid Phone","Phone must contain an integer value.",3)
             else
                {
                gui +OwnDialogs
                MsgBox 0x10,Invalid Phone,Phone must contain an integer value.
                GUIControl Focus,Phone
                }

            Return True  ;-- Selection rejected
            }
        }

    ;-- No return value here.  Selection is allowed.
    }

#include %A_ScriptDir%/_Functions
#include TAB.ahk

#include Edit.ahk
