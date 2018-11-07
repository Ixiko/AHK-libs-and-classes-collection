/*
    In this example, the Edit_AutoSetTabStops add-on function is used to
    automatically establish the tab stops for an Edit control.  This example and
    the add-on function use the Fnt library.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
$FontName    :="Arial"
$FontOptions :="s8"

;-- Create GUI using default font
gui -DPIScale +hWndhWindow -MinimizeBox
gui Margin,10,10

Fnt_GetStringSize(0,"Random Reportxxx",ButtonW,ButtonH)
ButtonH :=Round(ButtonH*3.2)
ShortButtonH :=Round(ButtonH/2)
gui Add
   ,Button
   ,xm w%ButtonW% h%ButtonH% Default vRRG gRRG
   ,Random Report`nGenerator`n

gui Add,Button,x+5      w%ButtonW% h%ButtonH%       vChooseFile gChooseFile,Choose File...
gui Add,Button,x+5      w%ButtonW% h%ShortButtonH%  vChooseFont gChooseFont,Choose Font...
gui Add,Button,xp y+0   w%ButtonW% h%ShortButtonH%              gRandomFont,Random Font
gui Font,Bold
gui Add,Button,x+5 ym   w%ButtonW% h%ButtonH%                   gAutoSetTabStops,Auto Set`nTab Stops
gui Font
gui Add,Button,x+5      w%ButtonW% hp                           gDefaultTabStops,Set Tab Stops`nTo Defaults
gui Add,Button,x+40     w%ButtonW% hp               vReload     gReload,Reload...

gui Add
   ,Edit
   ,% ""
        . "xm w1000 r35 "
        . "+HScroll "
        . "+WantTab "
        . "-Wrap "
        . "hWndhEdit "
        . "vMyEdit "

gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

;-- Set focus
GUIControl Focus,RRG

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%

;-- Set initial tab stops
gosub DefaultTabStops
return


GUIEscape:
GUIClose:
Fnt_DeleteFont(hFont)
ExitApp


AutoSetTabStops:
SetBatchLines -1
TabStops :=Edit_AutoSetTabStops(hEdit)
SetBatchLines 10ms  ;-- AutoHotkey default

;-- Build list of tab stops
TSList :=""
Loop % TabStops.MaxIndex()
    TSList.=(StrLen(TSList) ? ", ":"") . TabStops[A_Index]

;-- Update status bar
if TabStops.MaxIndex()
    SB_SetText("Tab stops (in DTUs): " . TSList)
 else
    SB_SetText("Tab stops (in DTUs): Default (i.e. 32, 64, etc.)")
return


ChooseFile:
gui +OwnDialogs
FileSelectFile
    ,ExampleFile
    ,1              ;-- 1=File must exit
    ,% A_ScriptDir . "\_Example Files\Tab-Delimited\"
    ,Tab-Delimited File
    ,*.txt

if ErrorLevel
    return

;-- Load data to the Edit control
Edit_ReadFile(hEdit,ExampleFile)

;-- Set tab stops to default
gosub DefaultTabStops
return


ChooseFont:
if not Fnt_ChooseFont(hWindow,$FontName,$FontOptions,False)
    return

gosub CreateFont
return


CreateFont:
;-- Create new font
hFontOld :=hFont
hFont    :=Fnt_CreateFont($FontName,$FontOptions)

;-- Attach to the edit control and redraw
Fnt_SetFont(hEdit,hFont,True)

;-- Delete old font, if it exists
Fnt_DeleteFont(hFontOld)

;-- Set tab stops to default
gosub DefaultTabStops
return


RandomFont:
$FontName    :=Fnt_RandomTTFont()
Random $FontSize,8,14
$FontOptions :="s" . $FontSize
gosub CreateFont
return


RRG:
Text :="c1`tc2`tc3`tc4`tc5"
Random NumberOfLines,5,35
Loop % NumberOfLines
    {
    Title:=""
    Random TitleWords,1,8
    Loop % TitleWords
        if (A_Index=1)
            Title:="Title"
        else if (A_Index=2)
            Title.=" for"
        else if (A_Index=3)
            Title.=" the"
        else if (A_Index=4)
            Title.=" data"
        else if (A_Index=5)
            Title.=" you"
        else if (A_Index=6)
            Title.=" want"
        else if (A_Index=7)
            Title.=" to"
        else if (A_Index=8)
            Title.=" show"

    Title.=":"
    Text.=(StrLen(Text) ? "`r`n":"") . Title
    Random NumberOfColumns,1,5
    Loop % NumberOfColumns
        {
        Random SizeTest,-2147483648,2147483647
        if (SizeTest>0)
            Random RandomData,100000,999999999
         else
            Random RandomData,10,9999
        Text.="`t" . RandomData
        }
    }

Edit_SetText(hEdit,Text)
gosub DefaultTabStops
return


Reload:
Reload
return


DefaultTabStops:
Edit_SetTabStops(hEdit)

;-- Update status bar
SB_SetText("Tab stops (in DTUs): Default (i.e. 32, 64, etc.)")
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Edit_AutoSetTabStops.ahk
#include Fnt.ahk
#include Fnt_RandomTTFont.ahk
