/*
    In this example, the user can close a tab by clicking on the close tab icon.
*/
#NoEnv
#SingleInstance Force
ListLines Off

;-- Tab control styles
TCS_RIGHTJUSTIFY      :=0x0
TCS_SINGLELINE        :=0x0
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

;-- Initialize
DeleteSound :=A_ScriptDir . "\_Example Files\Sounds\Delete.wav"
IconDir     :=A_ScriptDir . "\_Example Files\ico"
MarginX     :=10
MarginY     :=10
TCWidth     :=300
TCHeight    :=300

Colors=
   (ltrim join|
    Aqua
    Black
    Blue
    Fuchsia
    Gray
    Green
    Lime
    Maroon
    Navy
    Olive
    Purple
    Red
    Silver
    Teal
    White
    Yellow
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
gui Font,% Fnt_GetMessageFontOptions(),% Fnt_GetMessageFontName()
TabStyle :=TCS_FIXEDWIDTH
gui Add,Tab3,xm h0 w%TCWidth% -Wrap %TabStyle% hWndhTab gSelectedTab vMyTab,Dummy
gui Font

;-- Set the tab size to reflect the size of the labels
hFont :=Fnt_GetFont(hTab)
TAB_SetItemSize(hTab,Fnt_GetStringWidth(hFont,"Fuchsiaxxxxx")+16,Fnt_GetFontHeight(hFont)+14)
    ;-- Note: A little bit taller than the minimum.  This gives the tabs a
    ;   little bit a breathing room.

;-- Add the TCS_OWNERDRAWFIXED style
;   Note: This is performed after the tab control is created.  In most cases,
;   AutoHotkey will automatically remove this style if it exists when the tab
;   control is created.
TAB_SetStyle(hTab,TCS_OWNERDRAWFIXED)

;-- Reset the tab control
;   This will force the tab control to reposition.  Note: This is not necessary
;   for the Tab and Tab2 controls but it remains for completeness.
GUIControl,,%hTab%

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
Loop Parse,Colors,|
    TAB_InsertItem(hTab,A_Index,A_LoopField,1)

;-- After this statement, all new controls are added outside of the tab control
gui Tab

;-- Add the first GUI control after the tab control.  The y-Position of the
;   control should be where the display area of the tab control begins.
ProgressY :=DisplayAreaY+0
gui Add,Progress,xm y%ProgressY% w%TCWidth% h200 vMyProgress

;-- Misc.
gui Add,Button,xm gReload,%A_Space%Reload...%A_Space%

;-- Status bar
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%

;-- Monitor WM_DRAWITEM
WM_DRAWITEM :=0x2B
OnMessage(WM_DRAWITEM,"OnDrawItem")

;-- Monitor WM_NOTIFY
WM_NOTIFY :=0x4E
OnMessage(WM_NOTIFY,"OnClick")

;-- Reset the tab control
;   This will force the tab control (and text) to redraw
GUIControl,,%hTab%

;-- Set the color for the first selection
GUIControl % "+Background" . TAB_GetText(hTab,TAB_GetCurSel(hTab)),MyProgress
gosub UpdateSB
return


SelectedTab:
gui Submit,NoHide
GUIControl % "+Background" . TAB_GetText(hTab,TAB_GetCurSel(hTab)),MyProgress
gosub UpdateSB
return


GUIEscape:
GUIClose:
ExitApp


Reload:
Reload
return


UpdateSB:
SelectedTab :=TAB_GetCurSel(hTab)
SBText :=""
    . "There are " . TAB_GetItemCount(hTab) . " tabs. "
    . (SelectedTab ? "Tab """ . TAB_GetText(hTab,SelectedTab) . """ is selected.":"No tab is selected.")

SB_SetText(SBText)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
OnDrawItem(wParam,lParam,Msg,hWnd)
    {
    Global DrawItem,IconDir
    Static Dummy15968469

          ;-- CtlType - Control Types
          ,ODT_MENU    :=1
          ,ODT_LISTBOX :=2
          ,ODT_COMBOBOX:=3
          ,ODT_BUTTON  :=4
          ,ODT_STATIC  :=5
          ,ODT_TAB     :=101
          ,ODT_LISTVIEW:=102

          ;-- itemAction - Required drawing action
          ,ODA_DRAWENTIRE:=0x1
          ,ODA_SELECT    :=0x2
          ,ODA_FOCUS     :=0x4

          ;-- itemState - The visual state of the item after the current drawing
          ;   action takes place.
          ,ODS_SELECTED    :=0x1
          ,ODS_GRAYED      :=0x2
          ,ODS_DISABLED    :=0x4
          ,ODS_CHECKED     :=0x8
          ,ODS_DEFAULT     :=0x20
          ,ODS_HOTLIGHT    :=0x40
          ,ODS_INACTIVE    :=0x80
          ,ODS_NOACCEL     :=0x100
          ,ODS_NOFOCUSRECT :=0x200
          ,ODS_COMBOBOXEDIT:=0x1000

          ;-- System colors
          ,COLOR_MENU         :=4
          ,COLOR_WINDOW       :=5
          ,COLOR_HIGHLIGHT    :=13
          ,COLOR_HIGHLIGHTTEXT:=14
          ,COLOR_3DFACE       :=15
          ,COLOR_BTNFACE      :=15

          ;-- Drawing flags
          ,DI_MASK       :=0x1
          ,DI_IMAGE      :=0x2
          ,DI_NORMAL     :=0x3     ;-- Combination of DI_IMAGE and DI_MASK
          ,DI_COMPAT     :=0x4     ;-- Not used
          ,DI_DEFAULTSIZE:=0x8
          ,DI_NOMIRROR   :=0x10

          ;-- DrawText flags
          ,DT_LEFT                :=0x0
          ,DT_TOP                 :=0x0
          ,DT_CENTER              :=0x1
          ,DT_RIGHT               :=0x2
          ,DT_VCENTER             :=0x4
          ,DT_BOTTOM              :=0x8
          ,DT_WORDBREAK           :=0x10
          ,DT_SINGLELINE          :=0x20
          ,DT_EXPANDTABS          :=0x40
          ,DT_TABSTOP             :=0x80
          ,DT_NOCLIP              :=0x100
          ,DT_EXTERNALLEADING     :=0x200
          ,DT_CALCRECT            :=0x400
          ,DT_NOPREFIX            :=0x800
          ,DT_INTERNAL            :=0x1000
          ,DT_EDITCONTROL         :=0x2000
          ,DT_PATH_ELLIPSIS       :=0x4000
          ,DT_END_ELLIPSIS        :=0x8000
          ,DT_MODIFYSTRING        :=0x10000
          ,DT_RTLREADING          :=0x20000
          ,DT_WORD_ELLIPSIS       :=0x40000
          ,DT_NOFULLWIDTHCHARBREAK:=0x80000
          ,DT_HIDEPREFIX          :=0x100000
          ,DT_PREFIXONLY          :=0x200000

          ;-- Misc.
          ,CXEDGE
          ,CYEDGE
          ,FirstCall:=True
          ,hIcon1
          ,hIcon2

    /*
        Programming notes:

        This example only has one tab control and so all WM_DRAWITEM messages
        are from that control.  This function does not check to verify if the
        message are for the tab control but if other controls that trigger the
        WM_DRAWITEM message were added, the function would need to verify that
        only the messages from the specified tab control are processed.
    */
    /*
    DRAWITEMSTRUCT structure
    Provides information that the owner window uses to determine how to paint an
    owner-drawn control or menu item. The owner window of the owner-drawn
    control or menu item receives a pointer to this structure as the lParam
    parameter of the WM_DRAWITEM message.

        [Member]       [Type]      [32bitA]  [32bitU]  [64bitU]
    1   CtlType        UINT        [00] 4    [00] 4    [00] 4
    2   CtlID          UINT        [04] 4    [04] 4    [04] 4
    3   itemID         UINT        [08] 4    [08] 4    [08] 4
    4   itemAction     UINT        [12] 4    [12] 4    [12] 4
    5   itemState      UINT        [16] 4    [16] 4    [16] 4
    6   hwndItem       HWND        [20] 4    [20] 4    [24] 8
    7   hDC            HDC         [24] 4    [24] 4    [32] 8
    8   rcItem.left    int         [28] 4    [28] 4    [40] 4
    9   rcItem.top     int         [32] 4    [32] 4    [44] 4
    10  rcItem.right   int         [36] 4    [36] 4    [48] 4
    11  rcItem.bottom  int         [40] 4    [40] 4    [52] 4
    12  itemData       ULONG_PTR   [44] 4    [44] 4    [56] 8
                                        --        --        --
                                        48        48        64
    */
    ;[============================]
    ;[     Extract values from    ]
    ;[  DRAWITEMSTRUCT structure  ]
    ;[============================]
    CtlType:=NumGet(lParam+0,0,"UInt")
        ;-- For this example, the value is always ODT_TAB (101).  Only need to
        ;   check if there are are other controls that send the WM_DRAWITEM
        ;   message.

    CtlID:=NumGet(lParam+0,4,"UInt")
        ;-- For this example, the value is always 3.  Not sure if this value is
        ;   important for this message.  Not likely.

    itemID:=NumGet(lParam+0,8,"UInt")
        ;-- Contains the 0-based tab index

    iTab:=itemID+1
        ;-- 1-based tab index.  Used by the TAB library.

    itemAction:=NumGet(lParam+0,12,"UInt")
        ;-- For this example, the value is always ODA_DRAWENTIRE (0x1).  This
        ;   may contain other values if the tab has an icon.

    itemState:=NumGet(lParam+0,16,"UInt")
        ;-- For this example, the value is either ODS_SELECTED (0x1) or 0 (no
        ;   constant value) which indicates "not selected".

    hTab:=hwndItem:=NumGet(lParam+0,A_PtrSize=8 ? 24:20,"Ptr")
        ;-- The handle to the tab control.  Used by the TAB library.

    hDC:=NumGet(lParam+0,A_PtrSize=8 ? 32:24,"Ptr")
        ;-- The handle to a device context.  msdn: This device context must be
        ;   used when performing drawing operations on the control.

    ;[===============]
    ;[  First call?  ]
    ;[===============]
    if FirstCall
        {
        FirstCall:=False

        ;------------------
        ;-- System metrics
        ;------------------
        SysGet CXEDGE,45
        SysGet CYEDGE,46
            ;-- Dimensions of a 3-D border, in pixels

        ;--------------
        ;-- Load icons
        ;--------------
        hIcon1:=LoadPicture(IconDir . "\Close_16x16-32b.ico","",ImageType)
        hIcon2:=LoadPicture(IconDir . "\Close_16x16-NS.ico","",ImageType)
        }

    ;[============]
    ;[  Draw tab  ]
    ;[============]
    if (itemState=ODS_SELECTED)
        {
        ;-- Get the tab name (color name)
        Text:=TAB_GetText(hTab,iTab)

        ;-- Convert the name to the RGB color value and then to BGR
        RGB:=Fnt_ColorName2RGB(Text)
        BGR:=((RGB&0xFF)<<16)|(RGB&0xFF00)|((RGB>>16)&0xFF)

        ;-- Paint the tab
        hBrush:=DllCall("CreateSolidBrush","UInt",BGR)
        DllCall("FillRect","Ptr",hDC,"Ptr",lParam+(A_PtrSize=8 ? 40:28),"Ptr",hBrush)
        DllCall("DeleteObject","Ptr",hBrush)

        ;-- Set the text background color (same as the tab color)
        DllCall("SetBkColor","Ptr",hDC,"UInt",BGR)

        ;-- Set the text color
        if (Text="Gray")
            TextColor:=0xFFFFFF
         else
            TextColor:=~BGR&0xFFFFFF

        DllCall("SetTextColor","Ptr",hDC,"UInt",TextColor)
        }
     else  ;-- Tab is not selected
        {
        ;-- Copy the RECT so that we can make minor changes
        ;   The rectangle defines the boundaries of the control to be drawn.
        VarSetCapacity(RECT,16,0)
        DllCall("CopyRect","Ptr",&RECT,"Ptr",lParam+(A_PtrSize=8 ? 40:28))

        ;-- Paint the tab
        ;   Note: The default color is used but the size of the rectangle is
        ;   changed slighty.
        hBrush:=DllCall("CreateSolidBrush","UInt",DllCall("GetSysColor","Int",COLOR_MENU))
        Bottom:=NumGet(RECT,12,"Int")
        NumPut(Bottom+CYEDGE,RECT,12,"Int")
        DllCall("FillRect","Ptr",hDC,"Ptr",&RECT,"Ptr",hBrush)
        DllCall("DeleteObject","Ptr",hBrush)
        }

    ;[=============]
    ;[  Draw icon  ]
    ;[=============]
    ;-- Calculate the position of icon
    TAB_GetItemRect(hTab,iTab,Left,Top,Right,Bottom)
    X:=Right-(16+2)
    Y:=Top+2

    ;-- Draw icon
    p_Flags:=DI_NORMAL
    hIcon  :=(itemState=ODS_SELECTED ? hIcon1:hIcon2)
    RC:=DllCall("DrawIconEx"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Int",X                                        ;-- xLeft
        ,"Int",Y                                        ;-- yTop
        ,"Ptr",hIcon                                    ;-- hIcon
        ,"Int",0                                        ;-- cxWidth
        ,"Int",0                                        ;-- cyWidth
        ,"UInt",0                                       ;-- istepIfAniCur
        ,"Ptr",0                                        ;-- hbrFlickerFreeDraw
        ,"UInt",p_Flags)                                ;-- diFlags

    ;[=================]
    ;[  Draw the text  ]
    ;[=================]
    ;-- Draw text
    ;   Note: The text is drawn using the tab control's current font.  The text
    ;   and background color were set ealier.
    uFormat:=DT_CENTER|DT_VCENTER|DT_SINGLELINE
    RC:=DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",TAB_GetText(hTab,iTab)                   ;-- lpchText
        ,"Int",-1                                       ;-- nCount
        ,"Ptr",lParam+(A_PtrSize=8 ? 40:28)             ;-- lpRect
        ,"UInt",uFormat)                                ;-- uFormat

    ;-- Notify the system that this message has been processed.  The OS will
    ;   not try to draw the tab when is this done.
    Return True
    }

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

    ;-- Collect the notification code
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

    ;-- Hit test
    if not iTab:=TAB_HitTest(hTab,X,Y,flags)
        return

    ;-- Get the item rect
    TAB_GetItemRect(hTab,iTab,Left,Top,Right,Bottom)
    IconX:=Right-(16+2)
    IconY:=Top+2

    ;-- Bounce if not over the icon
    ;   Note: This test is based on the values that were used to draw the icon.
    ;   They need to change and the icon position and/or size changes.
    if not (X>=IconX and X<=IconX+16 and Y>=IconY and Y<=IconY+16)
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

#include Fnt.ahk
#include HSV.ahk
