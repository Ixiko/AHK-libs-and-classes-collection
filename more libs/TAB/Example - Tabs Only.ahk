/*
    In this example, the tabs in the tab control are used to manipulate the
    information that is shown but no GUI controls are assigned to any of the
    tabs.

    This example is based on a script from derRaphael which was published in
    the forum.


    Notes:

    Showing just the tabs of tab control and then positioning the Edit control
    immediately after is a mix of art and math.  The tab control was not
    designed to be shown this way so identifying exactly where to make the cut
    can be tricky.  Cutting too short will make the tabs look odd but leaving
    too much also looks odd.  The tab control will give the developer an
    accurate measurement of the tabs and the display area but after that, it's
    up to developer to determine exactly where to make the cut.
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
IconDir :=A_ScriptDir . "\_Example Files\ico\Fresh Fruit"
Fruit=
   (ltrim join|
    Apple
    Grapes
    Lemon
    Mango
    Orange
    Pear
   )

TCWidth :=400

;-- Create and populate image list
hIL :=TAB_CreateImageList(32)
Loop Parse,Fruit,|
    IL_Add(hIL,IconDir . "\" . A_LoopField . ".ico")

;-- Create GUI
gui -DPIScale

;-- Introduction
gui Add,Text,cm w%TCWidth%,
   (ltrim join`s
    In this example, only the tabs of the tab control are shown.  No GUI
    controls are assigned to any of the tabs.  The selected tab determines what
    information is shown in the Edit control.
    )

;-- Add Tab control
;   Note: At least one tab must be specified here.  Otherwise, space for the
;   tabs is not allocated.  Also note that the height of the control is set to
;   0.  This is done so that AutoHotkey does not calculate a height for this
;   control.

TabStyle :=0  ;TCS_FIXEDWIDTH
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
    TAB_InsertItem(hTab,A_Index,A_LoopField,A_Index)

;-- End of tabs
gui Tab

;-- Add the first GUI control after the tab control.  The y-Position of the
;   control should be where the display area of the tab control begins.
EditY :=DisplayAreaY+0
gui Add,Edit,xm y%EditY% w400 r10 vMyEdit,
   (ltrim join`s
    This Edit Control is independent of the tab control.  However, it is updated
    when a tab is selected.
   )

gui Font

gui Add,Button,xm gAdd,%A_Space%Add%A_Space%
gui Add,Button,x+0 gModifyName,Modify Name
gui Add,Button,x+0 gModifyIcon,Modify Icon
gui Add,Button,x+0 gDelete,Delete
gui Add,Button,x+0 gDeleteAll,Delete All

;-- Misc.
gui Add,Button,xm gReload,%A_Space%Reload...%A_Space%

;-- Status bar
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
gosub UpdateSB
return

Add:
gui +OwnDialogs
FileSelectFile IconFile,1,%IconDir%\,Icon,Icons (*.ico)
if ErrorLevel
    Return

SplitPath IconFile,,,,TabName
TAB_InsertItem(hTAB,,TabName,IL_Add(hIL,IconFile))
gosub UpdateSB
return


Delete:
gui +OwnDialogs
if not iTab:=TAB_GetCurSel(hTab)
    return

TAB_DeleteItem(hTab,iTab)
gosub UpdateSB
return


DeleteAll:
TAB_DeleteAllItems(hTab)
gosub UpdateSB
return


ModifyName:
if not iTab:=TAB_GetCurSel(hTab)
    return

gui +OwnDialogs
InputBox TabName,Label,New label:,,,,,,,,% TAB_GetText(hTab,iTab)
if ErrorLevel
    return

TAB_SetText(hTAB,iTab,TabName)
gosub UpdateSB
return


ModifyIcon:
if not iTab:=TAB_GetCurSel(hTab)
    return

gui +OwnDialogs
FileSelectFile IconFile,1,%IconDir%\,Icon,Icons (*.ico)
if ErrorLevel
    return

TAB_SetIcon(hTAB,iTab,IL_Add(hIL,IconFile))
gosub UpdateSB
return


SelectedTab:
gui Submit,NoHide
GUIControl,,Edit1,Selected tab: %MyTab%
gosub UpdateSB
return


GUIEscape:
GUIClose:
IL_Destroy(hIL)  ;-- Required for image lists used by tab controls.
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
#include %A_ScriptDir%/_Functions
#include TAB.ahk
