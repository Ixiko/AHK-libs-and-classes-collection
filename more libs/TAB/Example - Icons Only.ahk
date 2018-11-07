/*
    In this example, each tab has an icon but no label.  A tooltip has been set
    for each tab so that if the user hovers the mouse over a tab, a tooltip
    explaining what the tab is for is shown.
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
IconDir  :=A_ScriptDir . "\_Example Files\ico\Camping"
PicDir   :=A_ScriptDir . "\_Example Files\jpg"
TCWidth  :=400
TCHeight :=250

;-- Create and populate image list
hIL:=TAB_CreateImageList(32,32,3)
IL_Add(hIL,IconDir . "\Axe.ico",1)
IL_Add(hIL,IconDir . "\Campfire.ico",1)
IL_Add(hIL,IconDir . "\Compass.ico",1)

;-- Build GUI
gui -DPIScale +hWndhGUI
gui Margin,10,10

;-- Introduction
gui Add,Text,xm w%TCWidth%,
   (ltrim join`s
    In this example, the tabs have an icon but no label (i.e. name).  A tooltip
    has been set for each tab so if the user hovers the mouse over a tab, a
    tooltip explaining what the tab is for is shown.
   )

;-- Tab control
;   Note: The tab control is created with labels so that much of the built-in
;   functionality can be used.
TabStyle :=TCS_TOOLTIPS
gui Add,Tab3,xm w%TCWidth% h%TCHeight% hWndhTab vMyTab %TabStyle%,Axe|Campfire|Compass

;-- Assign image list to the tab control
TAB_SetImageList(hTab,hIL)

;-- Assign icons to the tabs
Loop 3
    TAB_SetIcon(hTab,A_Index,A_Index)

;-- Force the tab control to reset all (OK, most) of the tab objects
GUIControl,,%hTab%

;-- Set static tooltips
Loop % TAB_GetItemCount(hTab)
    TAB_Tooltips_SetText(hTab,A_Index,TAB_GetText(hTab,A_Index))

;-- Add GUI controls for each tab
gui Tab,Axe
Random Day,1,7
gui Add,Text,,Just some text on the first tab control.
gui Add,ListBox,r7 Choose%Day%,Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday

gui Tab,Campfire
gui Add,Button,,%A_Space%Test Button%A_Space%
gui Add,Picture,w-1 h150,% PicDir . "\PH02068J.jpg"

gui Tab,Compass
gui Add,Edit,w200,Test Edit
Random PPos,25,95
gui Add,Progress,w350 h30 -Smooth,%PPos%
gui Add,DateTime
gui Tab

;-- GUI controls are created.  OK to remove the text from the tabs.
;   Note: After this, the tabs must be referenced via the tab number.
Loop % TAB_GetItemCount(hTab)
    TAB_SetText(hTab,A_Index,"")

;-- After
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
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
#include %A_ScriptDir%/_Functions
#include TAB.ahk
