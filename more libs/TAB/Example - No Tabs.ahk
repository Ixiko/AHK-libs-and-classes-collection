/*
    In this example, the tab control is used to determine what information is
    shown but the tab control itself is not shown.  The user selects items from
    another control (a ListView in this example) to determine which tab is
    selected.

    This example is based on an example script from adabo which was published in
    the AutoHotkey forum.
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
IconDir :=A_ScriptDir . "\_Example Files\ico\Country Flags"
PicDir  :=A_ScriptDir . "\_Example Files\jpg"
Countries=
   (ltrim join|
    China
    India
    United States
    Indonesia
    Brazil
    Pakistan
    Nigeria
    Bangladesh
    Russia
    Mexico
   )

MarginX  :=10
MarginY  :=10
GBW      :=250
GBH      :=250
ControlW :=GBW-(MarginX*2)

;-- Create and populate image list
hIL :=TAB_CreateImageList(32)
Loop Parse,Countries,|
    IL_Add(hIL,IconDir . "\" . A_LoopField . ".ico")

;-- Buil GUI
gui -DPIScale
gui Margin,%MarginX%,%MarginY%
gui Color,% Fnt_GetSysColor(COLOR_WINDOW:=5)

;-- ListView
;   This example uses a ListView control but any control where the user can
;   select from a list can be used -- ListBox, TreeView, Radio, etc.
gui Font,% Fnt_GetMessageFontOptions(),% Fnt_GetMessageFontName()
gui Add,ListView,xm w200 h250 +AltSubmit +BackGround0xEAEAFF -Hdr -Multi vMyLV gLVAction,Country
gui Font

LV_SetImageList(hIL,1)
Loop Parse,Countries,|
    LV_Add("Icon" . A_Index,A_LoopField)

LV_ModifyCol(1,"Auto")
LV_Modify(1,"Select Focus")

;-- Add Tab control
;   Note: The tab control does not take up any space but the location is
;   important.  The GUI controls added to each tab start in this location and
;   take up the space immediately after.
gui Add,Tab2,ym w0 h0 -Wrap hWndhTab vMyTab Choose1,%Countries%
TAB_GetPos(hTab,TabPosX,TabPosY)

Loop Parse,Countries,|
    {
    gui Tab,%A_LoopField%
    gui Add,GroupBox,x%TabPosX% y%TabPosY% w%GBW% h%GBH%,%A_LoopField%

    if (A_Index=1)  ;-- Could also be (A_LoopField="China")
    	{
        ButtonW:=GBW-(MarginX*2)
    	gui Add,Button,xp+%MarginX% yp+20 w%ButtonW%,Button 1
        Loop 4
    	   gui Add,Button,wp,% "Button " . A_Index+1
    	}

    if (A_Index=2)
    	{
    	gui Add,Checkbox,xp+%MarginX% yp+20,Checkbox 1
        Loop 7
    	   gui Add,Checkbox,,% "Checkbox " . A_Index+1
    	}

    if (A_Index=3)
        gui Add,Picture,xp+%MarginX% yp+20 w%ControlW% h-1,% PicDir . "\PH02068J.jpg"

    if (A_Index=4)
    	{
    	gui Add,Edit,xp+%MarginX% yp+20 w%ControlW%,Edit control 1
        Loop 4
    	   gui Add,Edit,wp,% "Edit control " . A_Index+1
    	}

    if (A_Index=5)
    	{
        Random This,1,3
    	gui Add,ListBox,xp+%MarginX% yp+20 w%ControlW% Choose%This%,Red|Green|Blue
        Random This,1,3
    	gui Add,ListBox,wp Choose%This%,Aqua|Beige|Brown
        Random This,1,3
    	gui Add,ListBox,wp Choose%This%,Cyan|Magenta|Yellow
    	}

    if (A_Index=6)
        {
        Random PPos,0,100
    	gui Add,Progress,xp+%MarginX% yp+20 w%ControlW% h30 -Smooth,%PPos%
        Loop 4
            {
            Random PPos,0,100
            gui Add,Progress,wp hp -Smooth,%PPos%
            }
        }

    if (A_Index=7)
    	{
    	gui Add,Radio,xp+%MarginX% yp+20 Checked,Radio 1
        Loop 7
    	   gui Add,Radio,,% "Radio " . A_Index+1
    	}

    if (A_Index=8)
        {
        Random SPos,0,100
    	gui Add,Slider,xp+%MarginX% yp+20 w%ControlW% h30,%SPos%
        Loop 4
            {
            Random SPos,0,100
            gui Add,Slider,wp hp,%SPos%
            }
        }

    if (A_Index=9)
    	{
    	gui Add,Text,xp+%MarginX% yp+20 +Border,Text control 1
        Loop 4
    	   gui Add,Text,,% "Text control " . A_Index+1
    	}

    if (A_Index=10)
    	gui Add,MonthCal,xp+%MarginX% yp+20 w%ControlW%
    }

;-- End of tabs
gui Tab

;-- After tabs
gui Add,Button,xm gReload,%A_Space%Reload...%A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
return


Reload:
Reload
return


LVAction:

;-- Bounce if not selecting a new item
if (A_GUIEvent<>"I" or InStr(ErrorLevel,"S",True)=0)
    return

;-- Select
TAB_SelectItem(hTab,A_EventInfo)

;-- Return focus back to the ListView control
;   This allows the user to use the keyboard to navigate through the list.  The
;   user can still press the Tab key to get to the fields in the page of the
;   tab that is showing.
GUIControl Focus,MyLV
return


GUIClose:
GUIEscape:
ExitApp


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%/_Functions
#include TAB.ahk

#include Fnt.ahk
