/*
    This example uses the Edit_MouseInSelect function to determine if the mouse
    pointer is over selected text.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants
WM_MOUSEMOVE :=0x200

;-- Example file exists?
ExampleFile :=A_ScriptDir . "\_Example Files\Abraham Lincoln - Gettysburg Address.txt"
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
gui Margin,20,20
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Text,xm
    ,Instructions: Select any text and then move the mouse over the selected text.
gui Add
   ,Edit
   ,% ""
        . "xm w600 r20 "
        . "+0x100 "     ;-- ES_NOHIDESEL
        . "hWndhEdit "
        . "vMyEdit "

gui Font
gui Add,Button,xm gReload,%A_Space% Reload... %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Update text on the Edit control
GUIControl,,MyEdit,%ExampleData%

;-- Track mouse movement
OnMessage(WM_MOUSEMOVE,"OnMouseMove")
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
#include Fnt.ahk

/*
    Documentation for the WM_MOUSEMOVE message can be found here:
        http://msdn.microsoft.com/en-us/library/windows/desktop/ms645616(v=vs.85).aspx

    Note: The return value for the WM_MOUSEMOVE message should always be null.
    Returning any other value may interfere with other operations.
*/
OnMouseMove(wParam,lParam,Msg,hWnd)
    {
    Global hEdit
    Static PreviouslParam
          ,TooltipShowing

    ;-- Bouce if the mouse has not moved
    if (lParam=PreviouslParam)
        return

    ;-- Update PrevlParam
    PreviouslParam:=lParam

    ;-- Bounce if not over the Edit control
    ;   Observation: The WM_MOUSEMOVE message is not captured while over the
    ;   scroll bar.
    if (hWnd<>hEdit)
        {
        if TooltipShowing
            gosub OnMouseMove_ClearTooltip

        return
        }

    if not Edit_MouseInSelection(hEdit)
        {
        if TooltipShowing
            gosub OnMouseMove_ClearTooltip

        return
        }

    ;-- Show tooltip
    Tooltip Mouse is over selected text
    TooltipShowing:=True
    SetTimer OnMouseMove_ClearTooltip,5000
    return


    OnMouseMove_ClearTooltip:
    SetTimer %A_ThisLabel%,Off
    Tooltip
    TooltipShowing:=False
    return
    }
