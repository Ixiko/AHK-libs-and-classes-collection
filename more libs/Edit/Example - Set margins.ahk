/*
    This example sets the margins on an edit control, shows how to convert from
    inches to pixels, and shows one way to safely reload the edit control after
    the margins (especially the right margin) has been set.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Example file exists?
ExampleFile :=A_ScriptDir . "\_Example Files\Abraham Lincoln - Gettysburg Address.txt"
IfNotExist %ExampleFile%
    {
    MsgBox
        ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
        ,Example File Not Found,
           (ltrim join`s
            Unable to locate the data file for this
            example:`n`n%ExampleFile%  %A_Space%
           )

    return
    }

;-- Initialize
LeftMarginInInches  :=0.5  ;-- Default for prompt
LeftMarginInPixels  :=0
RightMarginInInches :=0.5  ;-- Default for prompt
RightMarginInPixels :=0

;-- Load data
FileRead ExampleData,%ExampleFile%

;-- Build GUI
gui -DPIScale -MinimizeBox
gui Margin,10,10
gui Add
   ,Button
   ,xm Default vSetMargins gGetMargins
   ,%A_Space%    Set Margins...    %A_Space%

gui Add,Button,x+5 wp  hp           gResetMargins,Reset Margins
gui Add,Button,x+40 wp hp vReload   gReload,Rebuild...

gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add
   ,Edit
   ,% ""
        . "xm w600 r30 "
        . "+0x100 "     ;-- ES_NOHIDESEL
        . "hWndhEdit "
        . "vMyEdit "

gui Font

;-- Set focus
GUIControl Focus,SetMargins

;-- Collect window handle
gui +LastFound
WinGet hWindow,ID

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Update text on the Edit control
GUIControl,,MyEdit,%ExampleData%
return


GUIEscape:
GUIClose:
ExitApp


GetMargins:
gui 2:Default
gui 1:+Disabled  ;-- Disable owner
gui +Owner1
gui -DPIScale -MinimizeBox
gui Add,Text,xm,Left margin (in inches):
gui Add,Edit,xm y+1 w150 vLeftMarginInInches,%LeftMarginInInches%
gui Add,Text,xm,Right margin (in inches):
gui Add,Edit,xm y+1 w150 vRightMarginInInches,%RightMarginInInches%
gui Add,Button,xm Default gGetMargins_Set,%A_Space%     Set     %A_Space%
gui Add,Button,x+5 wp g2GUIClose,Cancel
gui Show,,Margins
return


GetMargins_Set:
;-- Collect form data
gui Submit,NoHide

;-- Shut it down
gosub 2GUIClose
Sleep 50
    ;-- Allow for the form to close

;-- Reset GUI default
gui 1:Default

;-- Check/Update values
if LeftMarginInInches is not Number
    LeftMarginInInches:=0

if RightMarginInInches is not Number
    RightMarginInInches:=0

/*
    Convert from inches to pixels

    For the EM_SETMARGINS message, the Edit control does not appear to be DPI
    aware.  The control assumes that the screen always has 96 pixels per inch,
    i.e. 96 DPI.  This makes conversion from inches to pixels easy.  Simply
    multiply inches by 96 to get the number of pixels.
*/
LeftMarginInPixels  :=Round(LeftMarginInInches*96)
RightMarginInPixels :=Round(RightMarginInInches*96)
gosub SetMargins
return


2GUIClose:
2GUIEscape:
gui 1:-Disabled    ;-- Enable owner
gui Destroy
return


Reload:
Reload
return


ResetMargins:
LeftMarginInPixels  :=0
RightMarginInPixels :=0
gosub SetMargins
return


SetMargins:
;-- Get the current modify state
$Modify:=Edit_GetModify(hEdit)

;-- Get current select positions
Edit_GetSel(hEdit,$StartSelPos,$EndSelPos)

;-- Set margins
Edit_SetMargins(hEdit,LeftMarginInPixels,RightMarginInPixels)

;-- Update control
Edit_SetText(hEdit,Edit_GetText(hEdit))
Edit_SetModify(hEdit,$Modify)

;-- Set caret
Edit_SetSel(hEdit,$StartSelPos,$StartSelPos)
Edit_ScrollCaret(hEdit)
    ;-- Initial selection and scroll.  This makes sure that the leftmost
    ;   position of the selection is showing.

;-- Re-select if necessary
if ($StartSelPos<>$EndSelPos)
    {
    Edit_SetSel(hEdit,$StartSelPos,$EndSelPos)

    ;-- Show as much of the selection as possible
    $FirstVisibleLine :=Edit_GetFirstVisibleLine(hEdit)
    $LastVisibleLine  :=Edit_GetLastVisibleLine(hEdit)
    $FirstSelectedLine:=Edit_LineFromChar(hEdit,$StartSelPos)
    $LastSelectedLine :=Edit_LineFromChar(hEdit,$EndSelPos)

    ;-- Last line showing?
    if ($LastSelectedLine>$LastVisibleLine)
        if ($LastSelectedLine-$LastVisibleLine<$FirstSelectedLine-$FirstVisibleLine)
            Edit_LineScroll(hEdit,0,($LastVisibleLine-$LastSelectedLine)*-1)
         else
            Edit_LineScroll(hEdit,0,($FirstVisibleLine-$FirstSelectedLine)*-1)
    }

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk

