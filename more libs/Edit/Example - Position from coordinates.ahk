/*
    This example uses the Edit_CharFromPos function to get the zero-based
    indexes of the line and character where the mouse is currently positioned.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants
WM_MOUSEMOVE :=0x200

;-- Example file exists?
ExampleFile :=A_ScriptDir . "\_Example Files\John F. Kennedy - Inaugural Address.txt"
IfNotExist %ExampleFile%
    {
    MsgBox
        ,0x10   ;-- 0x10 (Error icon) + 0x0 (OK button)
        ,Example File Not Found,
           (ltrim join`s
            Unable to locate the data file for this
            example:`n`n%ExampleFile%  %A_Space%
           )

    return
    }

;-- Load data
FileRead ExampleData,%ExampleFile%

;-- Build GUI
gui -DPIScale -MinimizeBox
gui Margin,10,10
gui Add,Text,xm,Instructions: Move the mouse over the Edit control.
gui Font,s10
gui Add
   ,Edit
   ,% ""
        . "xm w600 r20 "
        . "+0x100 "     ;-- ES_NOHIDESEL
        . "hWndhEdit "
        . "vMyEdit "

gui Add,Text,xm w130,Line index:
gui Add,Text,x+0 cNavy vLineIdx,000000
gui Add,Text,xm y+0 w130,Character pos:
gui Add,Text,x+0 cNavy vCharPos,000000
gui Add,Text,xm y+0 w130,Text from pos:%A_Space%
gui Add,Text,x+0 w470 cNavy vCharPosText
gui Font

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Update text on the Edit control
GUIControl,,MyEdit,%ExampleData%

;-- Track mouse movement
OnMessage(WM_MOUSEMOVE,"TrackMouse")
return


GUIEscape:
GUIClose:
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


/*
    Documentation for the WM_MOUSEMOVE message can be found here:
        http://msdn.microsoft.com/en-us/library/windows/desktop/ms645616(v=vs.85).aspx

    Note: The return value for the WM_MOUSEMOVE message should always be null.
    Returning any other value may interfere with other operations.
*/
TrackMouse(wParam,lParam,Msg,hWnd)
    {
    Global hEdit

    ;-- Bounce if not over the Edit control
    ;   Observation: The WM_MOUSEMOVE message is not captured while over the
    ;   scroll bar.
    if (hWnd<>hEdit)
        Return

    ;-- Extract the mouse coordinates from lParam
    MousePosX:=(lParam&0xFFFF)<<48>>48
        ;-- LOWORD of lParam and converted from UShort to Short

    MousePosY:=(lParam>>16)<<48>>48
        ;-- HIWORD of lParam and converted from UShort to Short

    ;-- Get Edit control positions using the mouse coordinates
    Edit_CharFromPos(hEdit,MousePosX,MousePosY,CharPos,LineIdx)
    GUIControl,,LineIdx,%LineIdx%
    GUIControl,,CharPos,%CharPos%
    GUIControl,,CharPosText,% (CharPos<0) ? "":Edit_GetTextRange(hEdit,CharPos,CharPos+200)
    Return
    }
