/*
    This is a poor man's example of closing (i.e. deleting) a tab.  The tab's
    icon is used to determine if a clicked-on tab should be closed or not.


    Observations:

    Although this solution will work and it's probably good enough in a pinch,
    it's not ideal because the icon is too big and it's on the left.  Yes, the
    icon can be made smaller but having it on the left is still very
    non-standard.
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

;-- Intialize
CloseIcon   :=A_ScriptDir . "\_Example Files\ico\Close_24x24-32b.ico"
DeleteSound :=A_ScriptDir . "\_Example Files\Sounds\Delete.wav"
Fruit=
   (ltrim join|
    Apple
    Grapes
    Lemon
    Mango
    Orange
    Pear
    Pineapple
    Pomegranate
   )

TCWidth :=400

;-- Messages
WM_NOTIFY :=0x4E

;-- Create and populate image list
hIL :=TAB_CreateImageList(24)
IL_Add(hIL,CloseIcon)

;-- Create GUI
gui -DPIScale

;-- Introduction
gui Add,Text,cm w%TCWidth%,
   (ltrim join`s
    Instructions:

    Click on the tab's close button icon to close a tab.
    )

gui Add,CheckBox,xm vConfirmClose Checked,Confirm close

;-- Add Tab control
;   Note: At least one tab must be specified here.  Otherwise, space for the
;   tabs is not allocated.  Also note that the height of the control is set to
;   0.  This is done so that AutoHotkey does not calculate a height for this
;   control.
TabStyle :=TCS_FORCEICONLEFT|TCS_FIXEDWIDTH
gui Add,Tab3,xm h0 w%TCWidth% -Wrap %TabStyle% hWndhTab gSelectedTab vMyTab,Dummy

;-- Associate an image list with the tab control
;   Note: The tab control will automatically change the size of the tabs to
;   accommodate for the icons when this command is performed.
TAB_SetImageList(hTab,hIL)

;-- Get the position of the tab control and the display area
TAB_GetPos(hTab,MyTabPosX,MyTabPosY,MyTabPosW,MyTabPosH)
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

;-- Change the height of the tab control so that only the tabs are showing
;   The +4 is included to adjust for the gap between the tabs and the beginning
;   of the display area.  This can be adjusted at the developer's discretion.
GUIControl Move,MyTab,% "h" . MyTabPosH-(DisplayAreaH+4)

;-- Delete the dummy tab
TAB_DeleteAllItems(hTab)

;-- Add the tabs and assign an icon
Loop Parse,Fruit,|
    TAB_InsertItem(hTab,A_Index,A_LoopField,1)

;-- After this statement, all new controls are added outside of the tab control
gui Tab

;-- Add the first GUI control after the tab control.  The y-Position of the
;   control should be where the display area of the tab control begins.
EditY :=DisplayAreaY+0
gui Add,Edit,xm y%EditY% w%TCWidth% r10 vMyEdit,
   (ltrim join`s
    This Edit Control is independent of the tab control.  However, it is updated
    when a tab is selected.
   )

;-- Misc.
gui Add,Button,xm gReload,%A_Space%Reload...%A_Space%

;-- Status bar
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
gosub UpdateSB

;-- Monitor for NM_CLICK notification
OnMessage(WM_NOTIFY,"OnClick")
return


SelectedTab:
gui Submit,NoHide
GUIControl,,Edit1,Selected tab: %MyTab%
gosub UpdateSB
return


GUIEscape:
GUIClose:
IL_Destroy(hIL)   ;-- Required for image lists used by tab controls
ExitApp


Reload:
Reload
return


UpdateSB:
SelectedTab :=TAB_GetCurSel(hTab)
SBText :=""
    . "There are " . TAB_GetItemCount(hTab) . " tabs. "
    . (SelectedTab ? "Tab " . SelectedTab . " (""" . TAB_GetText(hTab,SelectedTab) . """) is selected.":"No tab is selected.")

SB_SetText(SBText)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
OnClick(wParam,lParam,Msg,hWnd)
    {
    Global DeleteSound
    Static Dummy68787760

          ;-- Notifications
          ,NM_FIRST     :=0
          ,NM_CLICK     :=-2        ;-- NM_FIRST - 2
          ,NM_DBLCLK    :=-3        ;-- NM_FIRST - 3
          ,NM_RCLICK    :=-5        ;-- NM_FIRST - 5
          ,NM_RDBLCLK   :=-6        ;-- NM_FIRST - 6
          ,NM_CUSTOMDRAW:=-12       ;-- NM_FIRST - 12

          ,TCN_FIRST      :=-550
          ,TCN_KEYDOWN    :=-550    ;-- TCN_FIRST - 0
          ,TCN_SELCHANGE  :=-551    ;-- TCN_FIRST - 1
          ,TCN_SELCHANGING:=-552    ;-- TCN_FIRST - 2
          ,TCN_FOCUSCHANGE:=-554    ;-- TCN_FIRST - 4

          ;-- Hit flags
          ,TCHT_NOWHERE    :=0x1
          ,TCHT_ONITEMICON :=0x2
          ,TCHT_ONITEMLABEL:=0x4
          ,TCHT_ONITEM     :=TCHT_ONITEMICON|TCHT_ONITEMLABEL

    ;-- Collect notification code
    Code:=NumGet(lParam+0,(A_PtrSize=8) ? 16:8,"Int")
        ;-- hdr.code
        ;   Note: hdr.code is defined as "UInt" but it is read as "Int" because
        ;   the member contains negative values.

    ;-- Bounce if not a NM_CLICK or TCN_SELCHANGING
    if Code not in %NM_CLICK%,%TCN_SELCHANGING%
        return

    ;-- If TCN_SELCHANGING, ensure that it was as a result of a click
    ;   This double-check test is needed because a tab selection can occur
    ;   programatically.
    if (Code=TCN_SELCHANGING and not GetKeyState("LButton"))
        {
        outputdebug TCN_SELCHANGING but not LBUTTON.  No changes made.
        return
        }

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

    ;-- Get the current cursor position relative to the tab control
    VarSetCapacity(POINT,8,0)
    DllCall("GetCursorPos","Ptr",&POINT)
    DllCall("ScreenToClient","Ptr",hTab,"Ptr",&POINT)
    X:=NumGet(POINT,0,"Int")
    Y:=NumGet(POINT,4,"Int")

    ;-- Hit test.  Bounce if not over a tab
    if not iTab:=TAB_HitTest(hTab,X,Y,flags)
        return

    ;-- Bounce if not directly on the icon on a tab
    if (flags<>TCHT_ONITEMICON)  ;-- Icon only
        return

    ;-- Determine if request should be confirmed
    GUIControlGet ConfirmClose,,ConfirmClose
    if ConfirmClose
        {
        gui +OwnDialogs
        MsgBox
            ,0x21
            ,Confirm Close
            ,% "Close the " . TAB_GetText(hTab,iTab) . " tab?"

        IfMsgBox Cancel
            {
            if (Code=TCN_SELCHANGING)
                Return True  ;-- This stops the tab selection from occuring

            return
            }
        }

    ;-- Get the currently selected tab
    Selected_iTab:=TAB_GetCurSel(hTab)

    ;-- Delete the requested tab
    TAB_DeleteItem(hTab,iTab)

    ;-- If the selected tab was deleted, selected closest tab if possible
    if (iTab=Selected_iTab)
        {
        if l_ItemCount:=TAB_GetItemCount(hTab)
            {
            if (l_ItemCount>=iTab)
                TAB_SelectItem(hTab,iTab)
             else
                TAB_SelectItem(hTab,l_ItemCount)
            }
        }

    ;-- Update the status bar
    gosub UpdateSB

    ;-- Play sound
    SoundPlay %DeleteSound%,Wait
    if (Code=TCN_SELCHANGING)
        Return True  ;-- This stops the tab selection from occuring
    }

#include %A_ScriptDir%/_Functions
#include TAB.ahk
