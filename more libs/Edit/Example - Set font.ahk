#NoEnv
#SingleInstance Force
ListLines Off

;-- Build/Show GUI
gui -DPIScale -MinimizeBox
gui Margin,0,0

;-- Explanation for ListView control
gui Add,Text,,This ListView control was created using Verdana and a random font size.

;-- ListView using Verdana and a random font size
Random RandomFontSize,6,20
gui Font,s%RandomFontSize%,Verdana
gui Add,ListView,w500 r6 hWndhLV,Column 1|Column 2|Column 3

;-- Reset font to system default
gui Font

;-- Populate ListView
Loop 5
    {
    Row:=A_Index
    LV_Add("")
    Loop 3
        {
        Random RandomNumber,100000,999999
        LV_Modify(Row,"Col" . A_Index,RandomNumber)
        }
    }

Loop 3
    LV_ModifyCol(A_Index,"AutoHdr")

;-- Edit control
gui Add,Edit,w500 h200 hWndhEdit,
   (ltrim join`s
    This Edit control was created using the system default font and size.  The
    font was then changed to match the ListView control.  Press the
    "Reload" button to get a new font size.
   )

;-- Set font using the font from the ListView control
Edit_SetFont(hEdit,Edit_GetFont(hLV))

;-- Buttons
gui Add,Button,gReload,%A_Space%     Rebuild example...     %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GUIClose:
GUIEscape:
ExitApp


Reload:
Reload
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
