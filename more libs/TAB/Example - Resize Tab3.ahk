/*
    For the Tab3 control, AutoHotkey automatically repositions the GUI controls
    in each tab when the position and/or size of the tab control's display area
    changes.  Changing the position of the controls when the size of the tab
    control changes is another story.

    Only adjusting the width and/or height of any control is easy because
    AutoHotkey does not interfere with these changes.  Functions like Attach,
    Anchor, and AutoXYWH can be used as long as they are instructed to only
    adjust the width and/or height.

    Adjusting of the position (X and/or Y) of a control can be tricky because
    if must be done in concert with the changes that AutoHotkey does
    automatically.  This example shows one way to accomplish this task.

    Note: This is a relatively simple example.  Repositioning a large number of
    controls can be complex and code intensive.
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

;-- Prompt the user
gui +hWndhGUI -MinimizeBox
gui Add,Text,,Tab Type:
gui Add,Radio,y+2 Checked vguiStandard,Standard
gui Add,Radio,vguiButtons,Buttons
gui Add,Text,,Tab Location:
gui Add,Radio,y+2 Checked,Top
gui Add,Radio,vguiLeft,Left
gui Add,Radio,vguiRight,Right
gui Add,Radio,vguiBottom,Bottom
gui Add,Text,,Margin:
gui Add,Edit,y+2 w100 Number vguiMargin,10
gui Add,Button,wp gOK,OK
gui Show
WinWaitClose ahk_id %hGUI%

;-- Initialize
TabStyle :=0

MarginX  :=MarginY:=guiMargin
if guiButtons
    TabStyle|=TCS_BUTTONS

if guiLeft
    TabStyle|=TCS_VERTICAL

if guiRight
    TabStyle|=TCS_VERTICAL|TCS_RIGHT

if guiBottom
    TabStyle|=TCS_BOTTOM

Vegetables=
    (ltrim join|
    1. Avocado
    2. Broccoli
    3. Cabbage
    4. Daikon
    5. Endive
    Fennel
    Green Beans
    Horse Radish
    Kale
    Lettuce
    Mushrooms
    Nettles
    Okra
    Peas
    Radish
    Spinach
    Turnip
    Watercress
    Yam
    Zucchini
    )

;-- Build GUI
gui -DPIScale +hWndhGUI +Resize -MinimizeBox -MaximizeBox
gui Margin,%MarginX%,%MarginY%

Random TCWidth,350,500
Random TCHeight,250,450

;-- Tab control
gui Add,Tab3,w%TCWidth% h%TCHeight% hWndhTab vMyTab %TabStyle%,%Vegetables%

;-- Get the display area
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

;-- Calculate the position and size of the controls for each tab
ControlX :=DisplayAreaX+MarginX
ControlY :=DisplayAreaY+MarginY
ControlW :=DisplayAreaW-(MarginX*2)
ControlH :=DisplayAreaH-(MarginY*2)

gui Tab,1
gui Add
   ,Text
   ,% ""
        . "x" . ControlX . A_Space
        . "y" . ControlY . A_Space
        . "w" . ControlW . A_Space
        . "h" . ControlH . A_Space
        . "+Border "
        . "vTab1_Text ",
    (ltrim join`s
    This tab control is created with a random size.  The TAB_GetDisplayArea
    function is used to get the position and size of the display area of
    this tab control.  The position and size of controls in each tab are based
    on this information.
    `n`nInstruction: Resize this window to see what happens.  Controls have
    been added to the first 5 tabs.  The rest of the tabs are there to show
    what happens when the number of tab rows changes.
    )

gui Tab,2
gui Add
   ,Edit
   ,% ""
        . "x" . ControlX . A_Space
        . "y" . ControlY . A_Space
        . "w" . ControlW . A_Space
        . "h" . ControlH . A_Space
        . "vTab2_Edit "
   ,Edit control in the group box in the Broccoli tab.

gui Tab,3
gui Add
   ,ListView
   ,% ""
        . "x" . ControlX . A_Space
        . "y" . ControlY . A_Space
        . "w" . Round(ControlW/2) . A_Space
        . "h" . ControlH . A_Space
        . "vTab3_ListView "
   ,Title

LV_Add("","One")
LV_Add("","Two")
LV_Add("","Three")

gui Add
   ,MonthCal
   ,% ""
        . "x+0 "
        . "w" . Round(ControlW/2) . A_Space
        . "h" . ControlH . A_Space
        . "+Border "
        . "vTab3_MonthCal "

gui Tab,4
gui Add
   ,Edit
   ,% ""
        . "x" . ControlX . A_Space
        . "y" . ControlY . A_Space
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space
        . "vTab4_Edit1 "

gui Add
   ,Edit
   ,% ""
        . "x+0 "
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space
        . "vTab4_Edit2 "

gui Add
   ,Edit
   ,% ""
        . "x+0 "
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space
        . "vTab4_Edit3 "

gui Tab,5
gui Add
   ,Edit
   ,% ""
        . "x" . ControlX . A_Space
        . "y" . ControlY . A_Space
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space
        . "vTab5_Edit1 "

gui Add
   ,Edit
   ,% ""
        . "y+0 "
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space
        . "vTab5_Edit2 "

gui Add
   ,Edit
   ,% ""
        . "y+0 "
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space
        . "vTab5_Edit3 "

;-- End of tabs
gui Tab

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
return


OK:
gui Submit,NoHide
gui Destroy
return


GUIEscape:
GUIClose:
ExitApp


GUISize:

;-- Set the size of the tab control
GUIControl Move,MyTab,% "w" . A_GUIWidth-(MarginX*2) . " h" . A_GUIHeight-(MarginY*2)

;-- Get the new display area position and size
TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

;-- Calculate the new position and size for the controls within each tab
ControlX :=DisplayAreaX+MarginX
ControlY :=DisplayAreaY+MarginY
ControlW :=DisplayAreaW-(MarginX*2)
ControlH :=DisplayAreaH-(MarginY*2)

;-- Calculate the X and Y offset
;   Note: These values are used to offset the changes made by AutoHotkey when
;   changing the position (X and/or Y) of a control in a Tab3 control.  OffsetX
;   is used when chaning the X position and OffsetY is used when changing the Y
;   position.  These values should be _subtracted_ from the new calculated
;   position.
TAB_GetDisplayRect(hTAB,OffsetX,OffsetY)
OffsetX+=MarginX
OffsetY+=MarginY

;-- Tab 1 and 2
;   Note: For these tabs, only the width and height of the controls is changed.
;   AutoHotkey does not interfere with changes to the width and/or height so no
;   additional adjustments are needed.
GUIControl MoveDraw,Tab1_Text,w%ControlW% h%ControlH%
GUIControl Move,    Tab2_Edit,w%ControlW% h%ControlH%

;-- Tab 3
GUIControl
    ,Move
    ,Tab3_ListView
    ,% ""
        . "w" . Round(ControlW/2) . A_Space
        . "h" . ControlH . A_Space

SetTimer GUISize_MoveMonth,100

;-- Tab 4
GUIControl
    ,Move
    ,Tab4_Edit1
    ,% ""
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space


GUIControlGet Tab4_Edit1Pos,Pos,Tab4_Edit1
GUIControl,,Tab4_Edit1,X, Y, W, H:`n%Tab4_Edit1PosX%, %Tab4_Edit1PosY%, %Tab4_Edit1PosW%, %Tab4_Edit1PosH%

GUIControl
    ,Move
    ,Tab4_Edit2
    ,% ""
        . "x" . ControlX+Round(ControlW/3)-OffsetX . A_Space
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space

GUIControlGet Tab4_Edit2Pos,Pos,Tab4_Edit2
GUIControl,,Tab4_Edit2,X, Y, W, H:`n%Tab4_Edit2PosX%, %Tab4_Edit2PosY%, %Tab4_Edit2PosW%, %Tab4_Edit2PosH%

GUIControl
    ,Move
    ,Tab4_Edit3
    ,% ""
        . "x" . ControlX+(Round(ControlW/3)*2)-OffsetX . A_Space
        . "w" . Round(ControlW/3) . A_Space
        . "h" . ControlH . A_Space

GUIControlGet Tab4_Edit3Pos,Pos,Tab4_Edit3
GUIControl,,Tab4_Edit3,X, Y, W, H:`n%Tab4_Edit3PosX%, %Tab4_Edit3PosY%, %Tab4_Edit3PosW%, %Tab4_Edit3PosH%

;-- Tab 5
GUIControl
    ,Move
    ,Tab5_Edit1
    ,% ""
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space


GUIControlGet Tab5_Edit1Pos,Pos,Tab5_Edit1
GUIControl,,Tab5_Edit1,X, Y, W, H:`n%Tab5_Edit1PosX%, %Tab5_Edit1PosY%, %Tab5_Edit1PosW%, %Tab5_Edit1PosH%

GUIControl
    ,Move
    ,Tab5_Edit2
    ,% ""
        . "y" . ControlY+Round(ControlH/3)-OffsetY . A_Space
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space

GUIControlGet Tab5_Edit2Pos,Pos,Tab5_Edit2
GUIControl,,Tab5_Edit2,X, Y, W, H:`n%Tab5_Edit2PosX%, %Tab5_Edit2PosY%, %Tab5_Edit2PosW%, %Tab5_Edit2PosH%

GUIControl
    ,Move
    ,Tab5_Edit3
    ,% ""
        . "y" . ControlY+(Round(ControlH/3)*2)-OffsetY . A_Space
        . "w" . ControlW . A_Space
        . "h" . Round(ControlH/3) . A_Space

GUIControlGet Tab5_Edit3Pos,Pos,Tab5_Edit3
GUIControl,,Tab5_Edit3,X, Y, W, H:`n%Tab5_Edit3PosX%, %Tab5_Edit3PosY%, %Tab5_Edit3PosW%, %Tab5_Edit3PosH%
return


GUISize_MoveMonth:
SetTimer %A_ThisLabel%,Off
GUIControl
    ,Move
    ,Tab3_MonthCal
    ,% ""
        . "x" . ControlX+Round(ControlW/2)-OffsetX . A_Space
        . "w" . Round(ControlW/2) . A_Space
        . "h" . ControlH . A_Space
return


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
