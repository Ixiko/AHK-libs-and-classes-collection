/*
    In this example, the developer is responsible for drawing the tab.  This
    allows horizontal text to be drawn on vertical tabs.

    Disclaimer: This is a very limited example that was created after trial and
    error.  It certainly can be improved and it's possible that it contains bugs
    that should be fixed before using something like this in production
    environment.

    Observation: This was written for the Tab and Tab2 controls.  It works on
    the Tab3 control but there are some conflicting object issues that may cause
    the tabs to be drawn incorrectly.
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

;-- Initialize
MarginX  :=8
MarginY  :=8
TCWidth  :=300
TCHeight :=250

;-- Create GUI
gui -DPIScale +AlwaysOnTop -MinimizeBox
gui Margin,%MarginX%,%MarginY%

;-- Add the tab control
TabStyle :=TCS_VERTICAL|TCS_FIXEDWIDTH  ;|TCS_FOCUSNEVER  ;  |TCS_BUTTONS  ;|TCS_OWNERDRAWFIXED
gui Add,Tab2,xm w%TCWidth% h%TCHeight% %TabStyle% hWndhTab gSelectedTab vMyTab,A-C|D-F|G-J|K-M|N-Q|R-T|U-Z
gui Font

;-- Set the tab size to reflect the size of the labels
hFont :=Fnt_GetFont(hTab)
TAB_SetItemSize(hTab,Fnt_GetFontHeight(hFont)+10,Fnt_GetStringWidth(hFont,"K-Mxx"))
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

;-- Get the display area
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

;-- Adjust for the margins
EditX :=DisplayAreaX+MarginX
EditY :=DisplayAreaY+MarginY
EditW :=DisplayAreaW-(MarginX*2)
EditH :=DisplayAreaH-(MarginY*2)

;-- Populate the tabs
gui Tab,A-C
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH% vMyEditAC,
   (ltrim
    1205`tAdam Sandler
    6791`tAl Pacino
    7852`tAngelina Jolie
    5532`tAnne Hathaway
    3600`tArnold Schwarzenegger
    4815`tBen Affleck
    7506`tBill Murray
    4691`tBrad Pitt
    9208`tBradley Cooper
    6440`tBruce Willis
    6294`tCameron Diaz
    9654`tChanning Tatum
    4115`tCharles Chaplin
    7713`tChris Hemsworth
    4414`tClint Eastwood
   )

;-- Collect the text from the first Edit control and then empty the control
;   This text is used later to populate the control after the screen is showing.
GUIControlGet MyEditAC,,MyEditAC
GUIControl,,MyEditAC

gui Tab,D-F
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    9024`tDaniel Craig
    4349`tDaniel Radcliffe
    5398`tDwayne Johnson
    6156`tEdward Norton
    2138`tEmma Stone
    5795`tEmma Watson
   )

gui Tab,G-J
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    3558`tGeorge Clooney
    4425`tHalle Berry
    4413`tHarrison Ford
    4566`tHugh Jackman
    4332`tIan McKellen
    7349`tJack Nicholson
    7772`tJackie Chan
    1785`tJake Gyllenhaal
    7314`tJames Cameron
    9799`tJames McAvoy
    1827`tJennifer Aniston
    6004`tJessica Alba
    7009`tJim Carrey
    8804`tJohnny Depp
    3266`tJulia Roberts
   )

gui Tab,K-M
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    1107`tKate Beckinsale
    5952`tKate Winslet
    3344`tKeanu Reeves
    8697`tKeira Knightley
    8436`tLeonardo DiCaprio
    7299`tLiam Neeson
    2940`tMacaulay Culkin
    1018`tMark Wahlberg
    7715`tMarlon Brando
    8379`tMatt Damon
    1147`tMegan Fox
    2412`tMel Gibson
    4666`tMorgan Freeman
   )

gui Tab,N-Q
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    7708`tNatalie Portman
    6901`tNicolas Cage
    3068`tOrlando Bloom
    5592`tOwen Wilson
    1728`tPeter Jackson
    8429`tPierce Brosnan
    3836`tSandra Bullock
   )

gui Tab,R-T
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    7643`tRachel McAdams
    9188`tRobert De Niro
    5758`tRobert Downey Jr.
    1048`tRowan Atkinson
    2732`tRussell Crowe
    3346`tSamuel L. Jackson
    5501`tScarlett Johansson
    4337`tSean Connery
    3101`tSigourney Weaver
    9449`tSteven Spielberg
    3972`tSylvester Stallone
    2309`tTim Allen
    2148`tTom Cruise
    3583`tTom Hanks
   )

gui Tab,U-Z
gui Add,Edit,x%EditX% y%EditY% w%EditW% h%EditH%,
   (ltrim
    2395`tVin Diesel
    2777`tWill Ferrell
    4585`tWill Smith
    3176`tZach Galifianakis
   )

;-- End of tabs
gui Tab

;-- Misc. controls
gui Add,Button,xm vReload gReload,%A_Space%Reload...%A_Space%
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,AutoSize,%$ScriptName%
gosub UpdateSB

;-- Reload the first Edit control
;   This keeps the control from selecting all text
GUIControl,,MyEditAC,%MyEditAC%

;-- Monitor WM_DRAWITEM
WM_DRAWITEM :=0x2B
OnMessage(WM_DRAWITEM,"OnDrawItem")

;-- Reset the tab control
;   This will force the tab control (and text) to redraw
GUIControl,,%hTab%
return


SelectedTab:
gui Submit,NoHide
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
    Global DrawItem
    Static Dummy15968469

          ;-- CtlType - Control types
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
          ,FirstCall:=True
          ,CXEDGE
          ,CYEDGE
          ,hDrawFont

          ;-- System colors
          ,COLOR_MENU         :=4
          ,COLOR_WINDOW       :=5
          ,COLOR_HIGHLIGHT    :=13
          ,COLOR_HIGHLIGHTTEXT:=14
          ,COLOR_3DFACE       :=15
          ,COLOR_BTNFACE      :=15

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
    owner-drawn control or menu item. The owner window of the owner-drawn control or
    menu item receives a pointer to this structure as the lParam parameter of the
    WM_DRAWITEM message.

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

        ;---------------
        ;-- Create font
        ;---------------
        ;-- Get the tab control's font
        hFont:=Fnt_GetFont(hTab)

        ;-- Create a new font using the attributes of the tab control's font
        ;   Note: In this example, this font remains static and not deleted
        ;   until the script ends.  This may not work in all situations.
        hDrawFont:=Fnt_CreateFont(Fnt_GetFontName(hFont),Fnt_GetFontOptions(hFont))
        }

    ;[============]
    ;[  Draw tab  ]
    ;[============]
    if (itemState=ODS_SELECTED)
        {
        hBrush:=DllCall("CreateSolidBrush","UInt",DllCall("GetSysColor","Int",COLOR_HIGHLIGHT))  ;COLOR_WINDOW))
        DllCall("FillRect","Ptr",hDC,"Ptr",lParam+(A_PtrSize=8 ? 40:28),"Ptr",hBrush)
        DllCall("DeleteObject","Ptr",hBrush)

        ;-- Set the text background color
        DllCall("SetBkColor","Ptr",hDC,"Int",DllCall("GetSysColor","Int",COLOR_HIGHLIGHT))

        ;-- Set the text color
        DllCall("SetTextColor","Ptr",hDC,"UInt",DllCall("GetSysColor","Int",COLOR_HIGHLIGHTTEXT))
        }

    ;[=============]
    ;[  Draw text  ]
    ;[=============]
    ;-- Select the font into the device context provided by this message
    hDrawFont_Old:=DllCall("SelectObject","Ptr",hDC,"Ptr",hDrawFont)

    ;-- Draw the text
    uFormat:=DT_CENTER|DT_VCENTER|DT_SINGLELINE
    RC:=DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",TAB_GetText(hTab,iTab)                   ;-- lpchText
        ,"Int",-1                                       ;-- nCount
        ,"Ptr",lParam+(A_PtrSize=8 ? 40:28)             ;-- lpRect
        ,"UInt",uFormat)                                ;-- uFormat

    ;-- Release the objects needed by the "DrawText" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",hDrawFont_Old)
        ;-- Necessary to avoid memory leak

    ;-- Notify the system that this message has been processed.  The OS will
    ;   not try to draw the tab when is this done.
    Return True
    }

#include %A_ScriptDir%/_Functions
#include TAB.ahk

#include Fnt.ahk
