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
MarginX :=10
MarginY :=10
TabStyle :=0  ;|TCS_TOOLTIPS  ;|TCS_BUTTONS ;|TCS_FORCELABELLEFT|TCS_FIXEDWIDTH   ;|TCS_TOOLTIPS|TCS_FORCEICONLEFT|TCS_FIXEDWIDTH

;-- Build GUI
gui -DPIScale +hWndhGUI
gui Margin,%MarginX%,%MarginY%
Loop 3
    {
    Random TCWidth,250,400
    Random TCHeight,200,350
    if (A_Index=1)
        {
        gui Font,Bold
        gui Add,Text,xm,Tab Control
        gui Font
        gui Add,Tab,xm w%TCWidth% h%TCHeight% hWndhTab1 vMyTab1 gActionMyTab1 %TabStyle%,Avocado|Broccoli|Cabbage
        hTab:=hTab1
        }
    else if (A_Index=2)
        {
        gui Font,Bold
        gui Add,Text,ym Section,Tab2 Control
        gui Font
        gui Add,Tab2,xs w%TCWidth% h%TCHeight% hWndhTab2 vMyTab2 gActionMyTab2 %TabStyle%,Avocado|Broccoli|Cabbage
        hTab:=hTab2
        }
    else if (A_Index=3)
        {
        gui Font,Bold
        gui Add,Text,ym Section,Tab3 Control
        gui Font
        gui Add,Tab3,xs w%TCWidth% h%TCHeight% hWndhTab3 vMyTab3 gActionMyTab3 %TabStyle%,Avocado|Broccoli|Cabbage
        hTab:=hTab3
        }

    ;-- Get the display area
    TAB_GetDisplayArea(hTab,DisplayAreaX,DisplayAreaY,DisplayAreaW,DisplayAreaH)

    ;-- Calculate the group box position and size
    GBX:=DisplayAreaX+MarginX
    GBY:=DisplayAreaY+MarginY
    GBW:=DisplayAreaW-(MarginX*2)
    GBH:=DisplayAreaH-(MarginY*2)

    ;-- Calculate the control position and size
    ;   Note: These calculations work OK for a small font and a standard margin
    ;   but can be improved by calculating the Y coordinate based on the height
    ;   of the group box font instead of just (Margin * 2).  The Height would
    ;   then need to be adjusted accordingly.
    ControlX:=GBX+MarginX
    ControlY:=GBY+(MarginY*2)
    ControlW:=GBW-(MarginX*2)
    ControlH:=GBH-(MarginY*3)

    gui Tab,Avocado
    gui Add,GroupBox,x%GBX% y%GBY% w%GBW% h%GBH%,Group box in the Avocado tab
    gui Add,Text,x%ControlX% y%ControlY% w%ControlW% h%ControlH%,
        (ltrim join`s
        This tab control is created with a random size.  The TAB_GetDisplayArea
        function is used to get the position and size of the display area of
        this tab control.  The position and size of the GUI controls is based on
        the display area.
        )

    gui Tab,Broccoli
    gui Add,GroupBox,x%GBX% y%GBY% w%GBW% h%GBH%,Group box in the Broccoli tab
    gui Add,Edit,x%ControlX% y%ControlY% w%ControlW% h%ControlH%,Edit control in the group box in the Broccoli tab.

    gui Tab,Cabbage
    gui Add,GroupBox,x%GBX% y%GBY% w%GBW% h%GBH%,Group box in the Cabbage tab
    Random PPos,0,100
    gui Add,Progress,x%ControlX% y%ControlY% w%ControlW% h30 -Smooth,%PPos%
    gui Tab
    }

;-- After
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%
gui Add,StatusBar

;-- Show it
SplitPath A_ScriptName,,,,$ScriptName
gui Show,,%$ScriptName%
return


GUIEscape:
GUIClose:
ExitApp


Reload:
Reload
return


ActionMyTab1:
ActionMyTab2:
ActionMyTab3:
gui Submit,NoHide
ThisTabControl :=SubStr(A_ThisLabel,0)
SB_SetText(A_TickCount . ": Value of MyTab" . ThisTabControl . " variable: " . MyTab%ThisTabControl%)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%/_Functions
#include TAB.ahk
