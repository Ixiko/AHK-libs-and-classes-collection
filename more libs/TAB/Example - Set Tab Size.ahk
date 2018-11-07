/*
    In this example, the user is allowed to change the size of the tabs.
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
MarginX   :=10
MarginY   :=10
TCWidth   :=400
TCHeight  :=350
IconDir   :=A_ScriptDir . "\_Example Files\ico\Social Flat Buttons"

MinTabWidth  :=0
MinTabHeight :=0
MaxTabWidth  :=TCWidth
MaxTabHeight :=300

TabNames=
   (ltrim join|
    Facebook
    Google
    Pandora
    Pinterest
    Reddit
    Twitter
   )

;-- Create and populate image list
hIL:=TAB_CreateImageList(32,32,3)
Loop Parse,TabNames,|
    IL_Add(hIL,IconDir . "\" . A_LoopField . ".ico",1)

;-- Build GUI
gui -DPIScale +hWndhGUI
gui Margin,%MarginX%,%MarginY%

;-- Add the window handle to the ExampleGUI_Group
GroupAdd ExampleGUI_Group,ahk_id %hGUI%

;-- Introduction
gui Add,Text,xm w%TCWidth%,
   (ltrim join`s
    Instructions: Move the sliders to change the width or height of the
    tabs.  Alternatively, Ctrl+[Left|Right|Up|Down] can be used.
   )

;-- Tab control
TabStyle :=TCS_FIXEDWIDTH|TCS_TOOLTIPS
   ;|TCS_TOOLTIPS|TCS_FORCEICONLEFT|TCS_FIXEDWIDTH
gui Add,Tab3,xm w%TCWidth% h%TCHeight% hWndhTab vMyTab %TabStyle%,%TabNames%

;-- Assign image list to the tab control
TAB_SetImageList(hTab,hIL)

;-- Assign icons to the tabs
Loop Parse,TabNames,|
    TAB_SetIcon(hTab,A_Index,A_Index)

;-- Force the tab control to reset all (OK, most) of the tab objects
GUIControl,,%hTab%

;-- Set static tooltips
Loop % TAB_GetItemCount(hTab)
    TAB_Tooltips_SetText(hTab,A_Index,TAB_GetText(hTab,A_Index))

;- Get the display area
TAB_GetDisplayArea(hTab,TabDisplayAreaX,TabDisplayAreaY,TabDisplayAreaW,TabDisplayAreaH)
ControlW :=TabDisplayAreaW-(MarginX*2)

;-- Add GUI controls for each tab
gui Tab,1
gui Add,Button,% "w" . Round(TCWidth/3),Button 1
Loop 4
   gui Add,Button,wp,% "Button " . A_Index+1


gui Tab,2
gui Add,Checkbox,,Checkbox 1
Loop 6
   gui Add,Checkbox,,% "Checkbox " . A_Index+1

gui Tab,3
gui Add,Edit,w%ControlW%,Edit control 1
Loop 4
   gui Add,Edit,wp,% "Edit control " . A_Index+1

gui Tab,4
Random This,1,3
gui Add,ListBox,% "w" . Round(TCWidth/3) . " Choose" . This,Red|Green|Blue
Random This,1,3
gui Add,ListBox,wp Choose%This%,Aqua|Beige|Brown
Random This,1,3
gui Add,ListBox,wp Choose%This%,Cyan|Magenta|Yellow

gui Tab,5
Random PPos,0,100
gui Add,Progress,w%ControlW% h30 -Smooth,%PPos%
Loop 4
    {
    Random PPos,0,100
    gui Add,Progress,wp hp -Smooth,%PPos%
    }

gui Tab,6
gui Add,Radio,Checked,Radio 1
Loop 6
   gui Add,Radio,,% "Radio " . A_Index+1

gui Tab,7
Random SPos,0,100
gui Add,Slider,w%ControlW% h30,%SPos%
Loop 4
    {
    Random SPos,0,100
    gui Add,Slider,wp hp,%SPos%
    }

;-- After tabs
gui Tab
gui Add,Text,xm Section,Width:%A_Space%
gui Add,Text,x+0 w50 +ReadOnly vTabWidthDisplay,% TAB_GetItemWidth(hTab)
gui Add,Slider,xs vTabWidthSlider gTabWidthSlider AltSubmit NoTicks Range%MinTabWidth%-%MaxTabWidth%-%MaxTabWidth%,% TAB_GetItemWidth(hTab)
gui Add,Text,ys Section,Height:%A_Space%
gui Add,Text,x+0 w50 +ReadOnly vTabHeightDisplay,% TAB_GetItemHeight(hTab)
gui Add,Slider,xs vTabHeightSlider gTabHeightSlider AltSubmit NoTicks Range%MinTabHeight%-%MaxTabHeight% Vertical,% TAB_GetItemHeight(hTab)
gui Add,Text,x+5,Drag to 0 (the very top) to`nset the default height

gui Add,CheckBox,xm Checked vShowIcons gToggleIcons,Icons

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


TabHeightSlider:
gui Submit,NoHide
TAB_SetItemSize(hTab,,TabHeightSlider)
GUIControl,,%hTab%
GUIControl,,TabHeightDisplay,% TAB_GetItemHeight(hTab)
return


TabWidthSlider:
gui Submit,NoHide
TAB_SetItemSize(hTab,TabWidthSlider)
GUIControl,,%hTab%
GUIControl,,TabWidthDisplay,% TAB_GetItemWidth(hTab)
return


ToggleIcons:
gui Submit,NoHide
if ShowIcons
    TAB_SetImageList(hTab,hIL)
 else
    TAB_SetImageList(hTab,0)

;-- Set the sliders to the actual tab size
GUIControl,,TabWidthSlider,% TAB_GetItemWidth(hTab)
GUIControl,,TabHeightSlider,% TAB_GetItemHeight(hTab)

;-- Reset
GUIControl,,%hTab%
return


UpdateDisplay:
GUIControl,,TabWidthDisplay,% TAB_GetItemWidth(hTab)
GUIControl,,TabHeightDisplay,% TAB_GetItemHeight(hTab)
return

;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%/_Functions
#include TAB.ahk

#include Fnt.ahk


;*****************
;*               *
;*    HotKeys    *
;*               *
;*****************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group ExampleGUI_Group

^Left::
TabWidth :=TAB_GetItemWidth(hTab)
if (TabWidth<=MinTabWidth)
    return

TAB_SetItemSize(hTab,TabWidth-1)
GUIControl,,%hTab%
GUIControl,,TabWidthDisplay,% TAB_GetItemWidth(hTab)
GUIControl,,TabWidthSlider,% TAB_GetItemWidth(hTab)
return

^Right::
TabWidth :=TAB_GetItemWidth(hTab)
if (TabWidth>=MaxTabWidth)
    return

TAB_SetItemSize(hTab,TabWidth+1)
GUIControl,,%hTab%
GUIControl,,TabWidthDisplay,% TAB_GetItemWidth(hTab)
GUIControl,,TabWidthSlider,% TAB_GetItemWidth(hTab)
return

^Up::
TabHeight :=TAB_GetItemHeight(hTab)
if (TabHeight<=MinTabHeight)
    return

TAB_SetItemSize(hTab,,TabHeight-1)
GUIControl,,%hTab%
GUIControl,,TabHeightDisplay,% TAB_GetItemHeight(hTab)
GUIControl,,TabHeightSlider,% TAB_GetItemHeight(hTab)
return

^Down::
TabHeight :=TAB_GetItemHeight(hTab)
if (TabHeight>=MaxTabHeight)
    return

TAB_SetItemSize(hTab,,TabHeight+1)
GUIControl,,%hTab%
GUIControl,,TabHeightDisplay,% TAB_GetItemHeight(hTab)
GUIControl,,TabHeightSlider,% TAB_GetItemHeight(hTab)
return

;-- End #IfWinActive directive
#IfWinActive
