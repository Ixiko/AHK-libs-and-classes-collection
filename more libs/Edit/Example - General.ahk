;*************************
;*                       *
;*    AHK environment    *
;*                       *
;*************************
#NoEnv
#NoTrayIcon
#SingleInstance Force
ListLines Off

;********************
;*                  *
;*    Initialize    *
;*                  *
;********************
;[=============]
;[  Constants  ]
;[=============]
;-- GUIs
$EEGUI:=2

;-- FindReplace flags
FR_DOWN          :=0x1
FR_WHOLEWORD     :=0x2
FR_MATCHCASE     :=0x4
FR_SHOWHELP      :=0x80
FR_NOUPDOWN      :=0x400
FR_NOMATCHCASE   :=0x800
FR_NOWHOLEWORD   :=0x1000
FR_HIDEUPDOWN    :=0x4000
FR_HIDEMATCHCASE :=0x8000
FR_HIDEWHOLEWORD :=0x10000
FR_REGEX         :=0x100000  ;-- FindGUI2 flag
FR_NOREGEX       :=0x200000  ;-- FindGUI2 flag
FR_HIDEREGEX     :=0x400000  ;-- FindGUI2 flag

;-- Font
$DefaultEditorFont     :="Lucida Console"
$DefaultEditorFontSize :=10

;-- Menu items
s_AlwaysOnTop_MI :="&Always On Top`tCtrl+Shift+A"
s_WordWrap_MI    :="&Word Wrap`tCtrl+W"

;[==========]
;[  Global  ]
;[==========]
$EditorFont     :=$DefaultEditorFont
$EditorFontSize :=$DefaultEditorFontSize
Dlg_Flags       :=0

;*****************
;*               *
;*    Process    *
;*               *
;*****************
gosub EEGUI
return


;***************************
;*                         *
;*                         *
;*        Functions        *
;*                         *
;*                         *
;***************************
#include %A_ScriptDir%\_Functions
    ;--  Changes the working directory for subsequent #includes

#include Edit.ahk
#include Dlg2.ahk
#include Edit_Duplicate.ahk
#include Edit_Sort.ahk
#include Fnt.ahk
#include MoveChildWindow.ahk    ;-- Used by the SortOptionsGUI function
#include SortOptionsGUI.ahk
#include WinGetPosEx.ahk        ;-- Used by the MoveChildWindow function


;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*                           *
;*                           *
;*****************************
;*****************
;*               *
;*     OnFind    *
;*    (EEGUI)    *
;*               *
;*****************
EEGUI_OnFind(hDialog,p_Event,p_Flags,p_FindWhat,Dummy="")
    {
    Global $EEGUI
          ,Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_FindFromTheTop
          ,hEEGUI
          ,hEdit

    Static Dummy2117

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000
          ,FR_REGEX        :=0x100000   ;-- FindGUI2 flag
          ,FR_NOREGEX      :=0x200000   ;-- FindGUI2 flag
          ,FR_HIDEREGEX    :=0x400000   ;-- FindGUI2 flag

          ;-- Message Box return values
          ,IDOK    :=1
          ,IDCANCEL:=2

    ;[===================]
    ;[  Set GUI default  ]
    ;[===================]
    gui %$EEGUI%:Default  ;-- Required to support independent threads

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if (p_Event="C")
        return

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- If needed, set hDialog to the master window
    IfWinNotExist ahk_id %hDialog%  ;-- Dialog not showing
        hDialog:=hEEGUI

    ;-- Update globals
    Dlg_Flags   :=p_Flags
    Dlg_FindWhat:=p_FindWhat
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to Edit_FindText flags
    l_Flags:=""
    if p_Flags & FR_MATCHCASE
        l_Flags.="MatchCase "

    if p_Flags & FR_REGEX
        l_Flags.="RegEx "

    ;[===========]
    ;[  Find it  ]
    ;[===========]
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Which direction?
    if p_Flags & FR_DOWN
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags,l_RegExOut)
     else
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_StartSelPos,0,l_Flags,l_RegExOut)

    ;-- Find anything?
    if (l_FindPos>-1)
        {
        ;-- Select and scroll to it
        if StrLen(l_RegExOut)
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(l_RegExOut))
         else
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))

        ;-- Make sure caret is showing
        Edit_ScrollCaret(hEdit)

        ;-- First selected line showing?
        Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
        l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
        l_FirstVisibleLine :=Edit_GetFirstVisibleLine(hEdit)
        if (l_FirstVisibleLine>l_FirstSelectedLine)
            Edit_LineScroll(hEdit,0,(l_FirstVisibleLine-l_FirstSelectedLine)*-1)
        }
     else
        {
        ;-- Notify/Prompt the user
        $Message=Next occurrence of "%p_FindWhat%" not found.
        if (Dlg_FindFromTheTop or not (p_Flags & FR_DOWN))
            {
            Dlg_MessageBox(hDialog
                ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
                ,"Find"
                ,$Message)

            Dlg_FindFromTheTop:=False
            return
            }

        RC:=Dlg_MessageBox(hDialog
            ,0x21   ;-- 0x1 (OK/Cancel buttons) + 0x20 ("?" icon)
            ,"Find"
            ,$Message . "`nContinue search from the top?")

        if (RC=IDCANCEL)
            {
            Dlg_FindFromTheTop:=False
            return
            }

        ;[===================]
        ;[  Start searching  ]
        ;[    from the top   ]
        ;[===================]
        Dlg_FindFromTheTop:=True
        Edit_SetSel(hEdit,0,0)   ;-- Move caret to the top
        EEGUI_OnFind(hDialog,"F",p_Flags,p_FindWhat)
            ;-- Recursive call
        }

    ;-- Return to sender
    return
    }


;*******************
;*                 *
;*    OnReplace    *
;*     (EEGUI)     *
;*                 *
;*******************
EEGUI_OnReplace(hDialog,p_Event,p_Flags,p_FindWhat,p_ReplaceWith)
    {
    Global Dlg_Flags
          ,Dlg_FindWhat
          ,Dlg_ReplaceWith
          ,Dlg_FindFromTheTop
          ,hEdit

    Static Dummy6011

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000
          ,FR_REGEX        :=0x100000   ;-- FindGUI2 flag
          ,FR_NOREGEX      :=0x200000   ;-- FindGUI2 flag
          ,FR_HIDEREGEX    :=0x400000   ;-- FindGUI2 flag

          ;-- Message Box return values
          ,IDOK    :=1
          ,IDCANCEL:=2

    ;[==========]
    ;[  Close?  ]
    ;[==========]
    if (p_Event="C")
        return

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Update globals
    Dlg_Flags      :=p_Flags
    Dlg_FindWhat   :=p_FindWhat
    Dlg_ReplaceWith:=p_ReplaceWith
        ;-- These global variables are used by Find, FindNext, FindPrevious, and
        ;   Replace routines.

    ;-- Convert Dlg_Find flags to Edit_FindText flags
    l_Flags:=""
    if p_Flags & FR_MATCHCASE
        l_Flags.="MatchCase "

    if p_Flags & FR_REGEX
        l_Flags.="RegEx "

    ;-- Get select positions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;[=========]
    ;[  Find   ]
    ;[=========]
    if (p_Event="F")
        {
        ;-- Look for it
        l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)

        ;-- Anything found?
        if (l_FindPos>-1)
            {
            ;-- Select and scroll to it
            Edit_SetSel(hEdit,l_FindPos,l_FindPos+StrLen(p_FindWhat))
            Edit_ScrollCaret(hEdit)
            }
         else
            {
            ;-- Notify/Prompt the user
            $Message="%p_FindWhat%" not found.
            if Dlg_FindFromTheTop
                {
                Dlg_MessageBox(hDialog
                    ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
                    ,"Find"
                    ,$Message)

                Dlg_FindFromTheTop:=False
                return
                }

            RC:=Dlg_MessageBox(hDialog
                ,0x21   ;-- 0x1 (OK/Cancel buttons) + 0x20 ("?" icon)
                ,"Find"
                ,$Message . "`nContinue search from the top?")

            if (RC=IDCANCEL)
                {
                Dlg_FindFromTheTop:=False
                return
                }

            ;[===================]
            ;[  Start searching  ]
            ;[    from the top   ]
            ;[===================]
            Dlg_FindFromTheTop:=True
            Edit_SetSel(hEdit,0,0)  ;-- Move caret to the top
            EEGUI_OnReplace(hDialog,"F",p_Flags,p_FindWhat,p_ReplaceWith)
                ;-- Recursive call
            }
        }

    ;[===========]
    ;[  Replace  ]
    ;[===========]
    if (p_Event="R")
        {
        ;-- Anything selected and if so, is it the same length of p_FindWhat?
         if (l_StartSelPos<>l_EndSelPos)
        and StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos
            {
            ;-- Look for it within the selected area
            l_FindPos:=Edit_FindText(hEdit,p_FindWhat,l_StartSelPos,l_EndSelPos,l_Flags)
                ;-- Programming note: The Edit_FindText function is called here
                ;   instead of just doing a plain "If selected=p_FindWhat"
                ;   test because the function takes the search flags into
                ;   consideration.


            ;-- If found, replace with p_ReplaceWith
            if (l_FindPos=l_StartSelPos)
                Edit_ReplaceSel(hEdit,p_ReplaceWith)
            }

        ;-- Find next
        EEGUI_OnReplace(hDialog,"F",p_Flags,p_FindWhat,p_ReplaceWith)
            ;-- Recursive call
        }

    ;[================]
    ;[  Replace All   ]
    ;[================]
    if (p_Event="A")
        {
        ;-- Disable dialog
        WinSet Disable,,ahk_id %hDialog%

        ;-- Position caret
         if (l_StartSelPos<>l_EndSelPos)
            if (StrLen(p_FindWhat)=l_EndSelPos-l_StartSelPos)
                Edit_SetSel(hEdit,l_StartSelPos,l_StartSelPos)
             else
                Edit_SetSel(hEdit,l_EndSelPos+1,l_EndSelPos+1)

        ;-- Replace All
        l_ReplaceCount:=0
        Loop
            {
            ;-- Get select positions
            Edit_GetSel(hEdit,Dummy,l_EndSelPos)

            ;-- Look for next
            l_FoundPos:=Edit_FindText(hEdit,p_FindWhat,l_EndSelPos,-1,l_Flags)

            ;-- Are we done?
            if (l_FoundPos<0)
                Break

            ;-- Select and scroll to it
            Edit_SetSel(hEdit,l_FoundPos,l_FoundPos+StrLen(p_FindWhat))
            Edit_ScrollCaret(hEdit)

            ;-- Replace with p_ReplaceWith
            Edit_ReplaceSel(hEdit,p_ReplaceWith)

            ;-- Count it
            l_ReplaceCount++
            }

        ;-- Enable dialog and return focus
        WinSet Enable,,ahk_id %hDialog%
        WinActivate ahk_id %hDialog%

        ;-- Display message
        if (l_ReplaceCount=0)
            $Message="%p_FindWhat%" not found.
         else
            $Message="%p_FindWhat%" replaced %l_ReplaceCount% times.

        Dlg_MessageBox(hDialog
            ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
            ,"Replace All"
            ,$Message)
        }

    ;-- Return to sender
    return
    }


;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*                           *
;*                           *
;*****************************
EEGUI:
;-- Initialize
$CurrentFile:="Untitled"

;-- Build it
gosub EEGUI_BuildMenus
gosub EEGUI_BuildGUI
gosub EEGUI_UpdateTitle
return


EEGUI_BuildMenus:

;-- File
Menu EEGUI_FileMenu,Add,&New`tCtrl+N,                       EEGUI_New
Menu EEGUI_FileMenu,Add,&Open...`tCtrl+O,                   EEGUI_Open
Menu EEGUI_FileMenu,Add
Menu EEGUI_FileMenu,Add,E&xit`tAlt+F4,                      EEGUI_Close

;-- Convert Case (Sub-Menu of Edit menu)
Menu EEGUI_ConvertCaseMenu,Add,&Uppercase`tCtrl+Win+U,      EEGUI_Uppercase
Menu EEGUI_ConvertCaseMenu,Add,&Lowercase`tCtrl+Win+L,      EEGUI_Lowercase
Menu EEGUI_ConvertCaseMenu,Add,&Capitalize`tCtrl+Win+C,     EEGUI_Capitalize
Menu EEGUI_ConvertCaseMenu,Add,&Sentence case`tCtrl+Win+S,  EEGUI_SentenceCase
Menu EEGUI_ConvertCaseMenu,Add,&Toggle case`tCtrl+Win+T,    EEGUI_ToggleCase

;-- Edit
Menu EEGUI_EditMenu,Add,&Undo`tCtrl+Z,                      EEGUI_Undo
Menu EEGUI_EditMenu,Add
Menu EEGUI_EditMenu,Add,Cu&t`tCtrl+X,                       EEGUI_Cut
Menu EEGUI_EditMenu,Add,&Copy`tCtrl+C,                      EEGUI_Copy
Menu EEGUI_EditMenu,Add,&Paste`tCtrl+V,                     EEGUI_Paste
Menu EEGUI_EditMenu,Add,De&lete`tDel,                       EEGUI_Clear
Menu EEGUI_EditMenu,Add,Select &All`tCtrl+A,                EEGUI_SelectAll
Menu EEGUI_EditMenu,Add
Menu EEGUI_EditMenu,Add,Duplicate`tCtrl+Shift+D,            EEGUI_Duplicate
Menu EEGUI_EditMenu,Add,Sort...`tCtrl+1,                    EEGUI_Sort
Menu EEGUI_EditMenu,Add,Sort (No Prompt)`tCtrl+2,           EEGUI_SortNoPrompt
Menu EEGUI_EditMenu,Add
Menu EEGUI_EditMenu,Add,Con&vert Case,                      :EEGUI_ConvertCaseMenu

;-- Search
Menu EEGUI_SearchMenu,Add,&Find`tCtrl+F,                    EEGUI_Find
Menu EEGUI_SearchMenu,Add,Find &Next`tF3,                   EEGUI_FindNext
Menu EEGUI_SearchMenu,Add,Find &Previous`tShift+F3,         EEGUI_FindPrevious
Menu EEGUI_SearchMenu,Add,&Replace`tCtrl+H,                 EEGUI_Replace
Menu EEGUI_SearchMenu,Add,&Go To`tCtrl+G,                   EEGUI_Goto

;-- View
Menu EEGUI_ViewMenu,Add,%s_AlwaysOnTop_MI%,                 EEGUI_ToggleAlwaysOnTop
Menu EEGUI_ViewMenu,Add,%s_WordWrap_MI%,                    EEGUI_ToggleWordWrap
Menu EEGUI_ViewMenu,Add
Menu EEGUI_ViewMenu,Add,&Increase Font Size`tCtrl+Numpad+,  EEGUI_IncreaseEditorFontSize
Menu EEGUI_ViewMenu,Add,&Decrease Font Size`tCtrl+Numpad-,  EEGUI_DecreaseEditorFontSize
Menu EEGUI_ViewMenu,Add,De&fault Font Size`tCtrl+Numpad0,   EEGUI_DefaultEditorFontSize

;-- Options
Menu EEGUI_OptionsMenu,Add,&Font...,                        EEGUI_EditorFont

;-- Misc
Menu EEGUI_MiscMenu,Add,CanUndo,                EEGUI_CanUndo
Menu EEGUI_MiscMenu,Add,EmptyUndoBuffer,        EEGUI_EmptyUndoBuffer
Menu EEGUI_MiscMenu,Add
Menu EEGUI_MiscMenu,Add,GetFirstVisibleLine,    EEGUI_GetFirstVisibleLine
Menu EEGUI_MiscMenu,Add,GetLastVisibleLine,     EEGUI_GetLastVisibleLine
Menu EEGUI_MiscMenu,Add,GetLine,                EEGUI_GetLine
Menu EEGUI_MiscMenu,Add,GetLineCount,           EEGUI_GetLineCount
Menu EEGUI_MiscMenu,Add,GetMargins,             EEGUI_GetMargins
Menu EEGUI_MiscMenu,Add,GetModify,              EEGUI_GetModify
Menu EEGUI_MiscMenu,Add,GetRect,                EEGUI_GetRect
Menu EEGUI_MiscMenu,Add,GetSel,                 EEGUI_GetSel
Menu EEGUI_MiscMenu,Add,GetSelText,             EEGUI_GetSelText
Menu EEGUI_MiscMenu,Add,GetText,                EEGUI_GetText
Menu EEGUI_MiscMenu,Add,GetTextLength,          EEGUI_GetTextLength
Menu EEGUI_MiscMenu,Add,GetTextRange,           EEGUI_GetTextRange
Menu EEGUI_MiscMenu,Add
Menu EEGUI_MiscMenu,Add,IsWordWrap,             EEGUI_IsWordWrap
Menu EEGUI_MiscMenu,Add
Menu EEGUI_MiscMenu,Add,LineLength,             EEGUI_LineLength
Menu EEGUI_MiscMenu,Add,ReplaceSel,             EEGUI_ReplaceSel
Menu EEGUI_MiscMenu,Add
Menu EEGUI_MiscMenu,Add,ScrollCaret,            EEGUI_ScrollCaret
Menu EEGUI_MiscMenu,Add,SetMargins,             EEGUI_SetMargins
Menu EEGUI_MiscMenu,Add,SetSel,                 EEGUI_SetSel

;-- Menubar
Menu EEGUI_Menubar,Add,&File,   :EEGUI_FileMenu
Menu EEGUI_Menubar,Add,&Edit,   :EEGUI_EditMenu
Menu EEGUI_Menubar,Add,&Search, :EEGUI_SearchMenu
Menu EEGUI_Menubar,Add,&View,   :EEGUI_ViewMenu
Menu EEGUI_Menubar,Add,&Options,:EEGUI_OptionsMenu
Menu EEGUI_Menubar,Add,&More...,   :EEGUI_MiscMenu
return


EEGUI_BuildGUI:
gui %$EEGUI%:Default
gui -DPIScale
gui Margin,0,0
gui Menu,EEGUI_Menubar
gui +LabelEEGUI_

;-- GUI objects
gui Font,s%$EditorFontSize% c%$EditorFontColor% %$EditorFontStyle%,%$EditorFont%
gui Add
   ,Edit
   ,% "w500 r18 "
        . "Hidden "
        . "hWndhEdit_WordWrap_On "
        . "+WantTab "
        . "+Wrap "
        . "+0x100 "                  ;-- ES_NOHIDESEL
        . "hWndhEdit_WordWrap_On "
        . "v$EEGUI_Edit_WordWrap_On "

gui Add
   ,Edit
   ,% "xp yp wp hp "
        . "Hidden "
        . "+WantTab "
        . "-Wrap "
        . "+0x100 "                  ;-- ES_NOHIDESEL
        . "+0x100000 "               ;-- WS_HSCROLL
        . "hWndhEdit_WordWrap_Off "
        . "v$EEGUI_Edit_WordWrap_Off "

;-- Start off with WordWrap On
GUIControl Show,$EEGUI_Edit_WordWrap_On
GUIControl Focus,$EEGUI_Edit_WordWrap_On
Menu EEGUI_ViewMenu,Check,%s_WordWrap_MI%
hEdit :=hEdit_WordWrap_On

;-- Reset font
gui Font

;-- Status bar
gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

;-- Identify window handle
gui +LastFound
WinGet hEEGUI,ID
GroupAdd $EEGUI_Group,ahk_id %hEEGUI%

;-- Load default text
DefaultText=
   (ltrim join`s
    This example is a stripped down version of the QuickEdit script:
    `r`n`r`n     http://tinyurl.com/7p8tx7z
    `r`n`r`n...with a few additional options added to demonstrate some of the
    features of the Edit library.
    `r`n`r`nSee the menu for a list of options that can be tested.  If desired,
    use the Open command (Ctrl+O) to load a file to this example editor -OR-
    drag a text file from Windows Explorer to this window.
   )

Edit_SetText(hEdit,DefaultText)

;-- Show
gui Show
return


EEGUI_CanUndo:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Can Undo: " . (Edit_CanUndo(hEdit) ? "TRUE":"FALSE") . "   "
return


EEGUI_EmptyUndoBuffer:
Edit_EmptyUndoBuffer(hEdit)
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,Request to empty undo buffer submitted.  %A_Space%
return


EEGUI_GetFirstVisibleLine:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "First visible line: " . Edit_GetFirstVisibleLine(hEdit) . "   "
return


EEGUI_GetLastVisibleLine:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Last visible line: " . Edit_GetLastVisibleLine(hEdit) . "   "
return


EEGUI_GetLine:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Current line: " . "`n""" . Edit_GetLine(hEdit) . """   "
return


EEGUI_GetLineCount:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Line count: " . Edit_GetLineCount(hEdit) . "   "
return


EEGUI_GetMargins:
Edit_GetMargins(hEdit,LeftMargin,RightMargin)
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Left margin: " . LeftMargin
    . "   `nRight margin: " . RightMargin . "   "
return


EEGUI_GetModify:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Modify flag: " . (Edit_GetModify(hEdit) ? "TRUE":"FALSE") . "   "
return


EEGUI_GetRect:
Edit_GetRect(hEdit,Left,Top,Right,Bottom)
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Left: " . Left . "   "
    . "`nTop: " . Top . "   "
    . "`nRight: " . Right . "   "
    . "`nBottom: " . Bottom . "   "
return


EEGUI_GetSel:
Edit_GetSel(hEdit,StartSelPos,EndSelPos)
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "StartSelPos: " . StartSelPos . "   "
    . "`nEndSelPos: " . EndSelPos . "   "
return


EEGUI_GetSelText:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Selected text: "
    . "`n""" . Edit_GetSelText(hEdit) . """   "
Return


EEGUI_GetText:
Edit_SetSel(hEdit,0,10)  ;-- Just to show what text is collected
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "First 10 characters of the edit control: "
    . "`n""" . Edit_GetText(hEdit,10) . """   "
Return


EEGUI_GetTextLength:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Number of characters in the edit control: "
    . Edit_GetTextLength(hEdit) . "   "
Return


EEGUI_GetTextRange:
Edit_SetSel(hEdit,10,20)  ;-- Just to show what text is collected
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "The second 10 characters of the edit control: "
    . "`n""" . Edit_GetTextRange(hEdit,10,20) . """   "
Return


EEGUI_IsWordWrap:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% Edit_IsWordWrap(hEdit) ? "Word Wrap is enabled.  ":"Word Wrap is NOT enabled.  "
return


EEGUI_LineLength:
gui +OwnDialogs
MsgBox 0x40,% SubStr(A_ThisLabel,7)
    ,% "Length (number of characters) of the current line: " . Edit_LineLength(hEdit) . "   "
return


EEGUI_ReplaceSel:
Edit_ReplaceSel(hEdit,"{Replaced With This}")
return


EEGUI_ScrollCaret:
Edit_ScrollCaret(hEdit)
return


EEGUI_SetMargins:
Edit_GetMargins(hEdit,LeftMargin,RightMargin)
if (LeftMargin=0)
    Edit_SetMargins(hEdit,50,50)
 else
    Edit_SetMargins(hEdit,0,0)

;-- Reload control so that the margin changes will show
gosub EEGUI_ToggleWordWrap
gosub EEGUI_ToggleWordWrap
return


EEGUI_SetSel:
Edit_GetSel(hEdit,StartSelPos,EndSelPos)
Edit_SetSel(hEdit,StartSelPos,StartSelPos+200)
return


EEGUI_Clear:
Edit_Clear(hEdit)
return


EEGUI_ClearStatusBar:
SetTimer %A_ThisLabel%,Off
SB_SetText("")
return


EEGUI_Copy:
Edit_Copy(hEdit)
return


EEGUI_Cut:
Edit_Cut(hEdit)
return


EEGUI_DecreaseEditorFontSize:
gui %$EEGUI%:Default
if ($EditorFontSize>1)
    {
    $EditorFontSize--
    gui Font,s%$EditorFontSize% c%$EditorFontColor% %$EditorFontStyle%,%$EditorFont%
    GUiControl Font,$EEGUI_Edit_WordWrap_On
    GUiControl Font,$EEGUI_Edit_WordWrap_Off
    gui Font

    ;-- Update status bar
    SB_SetText("Font=" . $EditorFont . "   Size=" . $EditorFontSize)
    SetTimer EEGUI_ClearStatusBar,15000
    }
 else
    SoundPlay *-1  ;-- System default sound

return


EEGUI_DefaultEditorFontSize:
gui %$EEGUI%:Default
$EditorFontSize:=$DefaultEditorFontSize
gui Font,s%$EditorFontSize% c%$EditorFontColor% %$EditorFontStyle%,%$EditorFont%
GUiControl Font,$EEGUI_Edit_WordWrap_On
GUiControl Font,$EEGUI_Edit_WordWrap_Off
gui Font

;-- Update status bar
SB_SetText("Default font size set.  Font=" . $EditorFont . "   Size=" . $EditorFontSize)
SetTimer EEGUI_ClearStatusBar,15000
return


EEGUI_DropFiles:

;-- Get the first file
Loop Parse,A_GUIControlEvent,`n,`r
    {
    $DropFile:=Trim(A_LoopField," `f`n`r`t`v")
        ;-- Assign and remove all leading/trailing white space

	Break
    }

;-- File not found?
IfNotExist %$DropFile%
    {
    gui +OwnDialogs
    MsgBox
        ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
        ,Open Error,
           (ltrim
            Unable to find the dropped file:  %A_Space%
            %$DropFile%  %A_Space%
           )

    return
    }

;-- Dropped a folder?
if InStr(FileExist($DropFile),"D")
    {
    gui +OwnDialogs
    MsgBox
        ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
        ,Open Error,
           (ltrim
            Dropped parameter contains a folder name:  %A_Space%
            %$DropFile%  %A_Space%
           )

    return
    }

;-- Load the contents of the dropped file to edit control
if (Edit_ReadFile(hEdit,$DropFile,True)<0)
    {
    ;-- Notify the user
    gui +OwnDialogs
    MsgBox
        ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
        ,Open Error,
           (ltrim
            Unable to open the dropped file:  %A_Space%
            %$DropFile%.  %A_Space%
           )

    return
    }

;-- Set $CurrentFile
$CurrentFile:=$DropFile

;-- Update title
gosub EEGUI_UpdateTitle

;-- Clear status bar
gosub EEGUI_ClearStatusBar
return


EEGUI_Duplicate:
Edit_Duplicate(hEdit)
return


EEGUI_EditorFont:
gui %$EEGUI%:Default

;-- Initialize
t_FontOptions :=""
    . "s" . $EditorFontSize . A_Space
    . "c" . $EditorFontColor . A_Space
    . $EditorFontStyle

;-- Choose font.  Bounce if cancelled.
if not Dlg_ChooseFont(hEEGUI,$EditorFont,t_FontOptions)
    return

;-- Extract font options
;   Note: It's not necessary to extract the color or size elements from the Font
;   options into separate variables.  This is just an example to show how it can
;   be done.
$EditorFontColor:="000000"  ;-- Black (the default)
$EditorFontSize :=$DefaultEditorFontSize
$EditorFontStyle:=""
Loop Parse,t_FontOptions,%A_Space%
    {
    if A_LoopField is Space
        Continue

    ;-- Color
    if (SubStr(A_LoopField,1,1)="c")
        {
        StringTrimLeft $EditorFontColor,A_LoopField,1
        Continue
        }

    ;-- Font size?
    if (SubStr(A_LoopField,1,1)="s")
        {
        t_FontSize:=SubStr(A_LoopField,2)
        if t_FontSize is Integer
            {
            StringTrimLeft $EditorFontSize,A_LoopField,1
            Continue
            }
        }

    ;-- For everything else, append to $EditorFontStyle
    $EditorFontStyle.=(StrLen($EditorFontStyle) ? A_Space:"") . A_LoopField
    }

;-- Refresh controls
gui Font,s%$EditorFontSize% c%$EditorFontColor% %$EditorFontStyle%,%$EditorFont%
GUIControl Font,$EEGUI_Edit_WordWrap_On
GUIControl Font,$EEGUI_Edit_WordWrap_Off
gui Font
return


EEGUI_Find:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Where are we starting from?
Edit_GetSel(hEdit,Dummy,$EndSelectPos)
Dlg_FindFromTheTop :=($EndSelectPos=0) ? True:False

;-- Set Dlg_Flags
Dlg_Flags :=FR_DOWN

;-- Anything selected?
$Selected:=Edit_GetSelText(hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if not InStr($Selected,"`n")
        Dlg_FindWhat:=$Selected
    }

;-- Show the Find dialog
hFRDialog :=Dlg_FindText(hEEGUI,Dlg_Flags|FR_HIDEWHOLEWORD,Dlg_FindWhat,"EEGUI_OnFind")
return


EEGUI_FindNext:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Bounce if Find was never called
if not StrLen(Dlg_FindWhat)
	return

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- Update Dlg_Flags
Dlg_Flags|=FR_DOWN

;-- Find next
EEGUI_OnFind(0,"F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return


EEGUI_FindPrevious:
gui %$EEGUI%:Default

;-- Bounce if Find was never called
if not StrLen(Dlg_FindWhat)
	return

;-- Save Dlg_Flags
$Saved_Dlg_Flags:=Dlg_Flags

;-- Update Dlg_Flags
Dlg_Flags&=~FR_DOWN

;-- Find previous
EEGUI_OnFind(0,"F",Dlg_Flags,Dlg_FindWhat)

;-- Restore Dlg_Flags
Dlg_Flags :=$Saved_Dlg_Flags
return


EEGUI_Goto:
gui %$EEGUI%:Default
gui +OwnDialogs
InputBox $GoToLine,Go To,Line number:,,140,130
if ErrorLevel
	return

;-- Adjust GoTo line for zero-based index
$MaxLineNumber:=Edit_GetLineCount(hEdit)
if ($GoToLine>$MaxLineNumber)
	$GoToLine:=$MaxLineNumber-1
 else
    $GotoLine--

;-- Go to it
$CharPos:=Edit_LineIndex(hEdit,$GoToLine)
Edit_SetSel(hEdit,$CharPos,$CharPos)
Edit_ScrollCaret(hEdit)
return


EEGUI_IncreaseEditorFontSize:
gui %$EEGUI%:Default
if ($EditorFontSize<99)
    {
    $EditorFontSize++
    gui Font,s%$EditorFontSize% c%$EditorFontColor% %$EditorFontStyle%,%$EditorFont%
    GUiControl Font,$EEGUI_Edit_WordWrap_On
    GUiControl Font,$EEGUI_Edit_WordWrap_Off
    gui Font

    ;-- Update status bar
    SB_SetText("Font=" . $EditorFont . "   Size=" . $EditorFontSize)
    SetTimer EEGUI_ClearStatusBar,15000
    }
 else
    SoundPlay *-1  ;-- System default sound

return


EEGUI_New:
gui %$EEGUI%:Default

;-- Clear control
Edit_SetText(hEdit,"")  ;-- Undo buffer automatically reset

;-- Set $CurrentFile
$CurrentFile:="Untitled"

;-- Update title
gosub EEGUI_UpdateTitle

;-- Clear status bar
gosub EEGUI_ClearStatusBar
return


EEGUI_Open:
gui %$EEGUI%:Default
gui +OwnDialogs

;-- Check/Set $DefaultPath
IfNotExist %$DefaultPath%
    $DefaultPath:=A_ScriptDir

;-- Browse for it
FileSelectFile
    ,t_CurrentFile                              ;-- OutputVar
    ,1                                          ;-- Options. 1=File must exist
    ,%$DefaultPath%                             ;-- Starting path
    ,Open                                       ;-- Prompt
    ,Text Documents (*.txt)                     ;-- Filter

;-- Cancel?
if ErrorLevel
    return

;-- Load it
if (Edit_ReadFile(hEdit,t_CurrentFile,True)<0)
    {
    MsgBox
        ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
        ,Open Error,
           (ltrim
            Unable to open the selected file:  %A_Space%
            %t_CurrentFile%.  %A_Space%
           )

    return
    }

;-- Set $CurrentFile
$CurrentFile:=t_CurrentFile

;-- Redefine $DefaultPath
SplitPath $CurrentFile,,$DefaultPath

;-- Update title
gosub EEGUI_UpdateTitle

;-- Clear status bar
gosub EEGUI_ClearStatusBar
return


EEGUI_Paste:
Edit_Paste(hEdit)
return


EEGUI_Replace:
gui %$EEGUI%:Default

;-- Bounce if Find or Replace dialog is already showing
IfWinExist ahk_id %hFRDialog%
    return

;-- Where are we starting from?
Edit_GetSel(hEdit,Dummy,$EndSelectPos)
Dlg_FindFromTheTop :=($EndSelectPos=0) ? True:False

;-- Anything selected?
$Selected:=Edit_GetSelText(hEdit)
if StrLen($Selected)
    {
    ;-- Ignore if multiple lines are selected
    if not InStr($Selected,"`n")
        Dlg_FindWhat:=$Selected
    }

;-- Set Dlg_Flags
Dlg_Flags:=FR_DOWN

;-- Show Replace dialog
hFRDialog :=Dlg_ReplaceText(hEEGUI,Dlg_Flags|FR_HIDEWHOLEWORD,Dlg_FindWhat,Dlg_ReplaceWith,"EEGUI_OnReplace")
return


EEGUI_SelectAll:
Edit_SelectAll(hEdit)
return


EEGUI_Sort:
gui %$EEGUI%:Default

;-- Anything selected?
Edit_GetSel(hEdit,$StartSelPos,$EndSelPos)
if ($StartSelPos=$EndSelPos)
    {
    ;-- Make a noise
    SoundPlay *-1  ;-- System default sound

    ;-- Update status bar
    SB_SetText("Nothing selected. Sort request aborted.")
    SetTimer EEGUI_ClearStatusBar,9000
    return
    }

$SortOptions:=SortOptionsGUI($EEGUI,$SortOptions)
If ErrorLevel
    Return

;-- Fall through...

EEGUI_SortNoPrompt:
Edit_Sort(hEdit,$SortOptions)
return


EEGUI_ToggleAlwaysOnTop:
gui %$EEGUI%:Default
if $AlwaysOnTop
    {
    gui -AlwaysOnTop
    $AlwaysOnTop:=False
    }
 else
    {
    gui +AlwaysOnTop
    $AlwaysOnTop:=True
    }

;-- update menu
Menu EEGUI_ViewMenu,ToggleCheck,%s_AlwaysOnTop_MI%

;-- Update status bar
SB_SetText("Always On Top " . ($AlwaysOnTop ? "enabled.":"disabled."))
SetTimer EEGUI_ClearStatusBar,9000
return


EEGUI_ToggleWordWrap:
gui %$EEGUI%:Default

;-- Get the current modify state
$Modify:=Edit_GetModify(hEdit)

;-- Get current select positions
Edit_GetSel(hEdit,$StartSelPos,$EndSelPos)

;-- Toggle control
if (hEdit=hEdit_WordWrap_On)
    {
    Edit_SetText(hEdit_WordWrap_Off,Edit_GetText(hEdit_WordWrap_On))
    Edit_SetModify(hEdit_WordWrap_Off,$Modify)
    Edit_SetText(hEdit_WordWrap_On,"")
    hEdit:=hEdit_WordWrap_Off
    GUIControl Hide,$EEGUI_Edit_WordWrap_On
    GUIControl Show,$EEGUI_Edit_WordWrap_Off
    GUIControl Focus,$EEGUI_Edit_WordWrap_Off
    }
 else
    {
    Edit_SetText(hEdit_WordWrap_On,Edit_GetText(hEdit_WordWrap_Off))
    Edit_SetModify(hEdit_WordWrap_On,$Modify)
    Edit_SetText(hEdit_WordWrap_Off,"")
    hEdit:=hEdit_WordWrap_On
    GUIControl Hide,$EEGUI_Edit_WordWrap_Off
    GUIControl Show,$EEGUI_Edit_WordWrap_On
    GUIControl Focus,$EEGUI_Edit_WordWrap_On
    }

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

;-- Toggle menu
Menu EEGUI_ViewMenu,ToggleCheck,%s_WordWrap_MI%
return


EEGUI_Undo:
Edit_Undo(hEdit)
return


EEGUI_UpdateTitle:
;-- Build title
if ($CurrentFile="Untitled")
    $EEGUI_Title:="{Untitled}"
 else
    {
    SplitPath $CurrentFile,$CurrentFileName,$CurrentDir,,$CurrentFileNameNoExt
    $EEGUI_Title:=$CurrentFileName
    }

;-- Update the title but don't steal focus
gui %$EEGUI%:Show,NA,%$EEGUI_Title%
    ;-- Note: The GUI is specified here to allow this routine to called without
    ;   regard to the default GUI.

return


EEGUI_Close:
ExitApp
return


;*************************
;*                       *
;*                       *
;*        Hotkeys        *
;*                       *
;*                       *
;*************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $EEGUI_Group

;[=============]
;[  Font Size  ]
;[=============]
^]::
^NumpadAdd::
^WheelUp::
gosub EEGUI_IncreaseEditorFontSize
return

^[::
^NumpadSub::
^WheelDown::
gosub EEGUI_DecreaseEditorFontSize
return

^Numpad0::
^NumpadIns::
^NumpadDiv::
gosub EEGUI_DefaultEditorFontSize
return

;[=========]
;[  Misc.  ]
;[=========]
^+a::gosub EEGUI_ToggleAlwaysOnTop
^f:: gosub EEGUI_Find
F3:: gosub EEGUI_FindNext
+F3::gosub EEGUI_FindPrevious
^1:: gosub EEGUI_Sort
^2:: gosub EEGUI_SortNoPrompt
^+d::gosub EEGUI_Duplicate
^g:: gosub EEGUI_Goto
^h:: gosub EEGUI_Replace
^n:: gosub EEGUI_New
^o:: gosub EEGUI_Open
^w:: gosub EEGUI_ToggleWordWrap


EEGUI_Capitalize:
EEGUI_Lowercase:
EEGUI_SentenceCase:
EEGUI_ToggleCase:
EEGUI_Uppercase:
^#c::
^#l::
^#s::
^#t::
^#u::
if (StrLen(A_ThisLabel)>3)
    Edit_ConvertCase(hEdit,SubStr(A_ThisLabel,7))
 else
    if (SubStr(A_ThisHotKey,0)=".")
        Edit_ConvertCase(hEdit,"S")
     else
        Edit_ConvertCase(hEdit,SubStr(A_ThisHotKey,0))

return

#IfWinActive
