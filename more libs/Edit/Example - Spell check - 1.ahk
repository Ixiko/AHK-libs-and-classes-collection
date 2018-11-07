/*
    In this example, the Edit_SpellCheckGUI add-on function is used to spell
    check a document that has been loaded to an edit control.  Note that the
    function uses an existing spell object.  The parent script (this script in
    this example) is is responsible for initializing and destroying the spell
    object.
*/
#NoEnv
#SingleInstance Force
ListLines Off

;-- Intialize
$SpellInit:=False
    ;-- This variable to used to keep the Spell library from initializing until
    ;   the Spell Check is requested for the first time.  It slows down the
    ;   first call a tiny bit but it keeps the script from using memory used by
    ;   the Spell library until it is actually needed.  This variable is also
    ;   used to determine if the Spell_Uninit function should be called.

;-- Menu
Menu MyMenu,Add,&Spell Check (F7),SpellCheck
Menu MyMenu,Add,Reload,Reload

;-- Create GUI
gui -DPIScale
gui Margin,0,0
gui Menu,MyMenu
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add
   ,Edit
   ,% "w500 r14 "
        . "hWndhEdit "
        . "+0x100 " ;-- ES_NOHIDESEL

gui Font

;-- Collect hWnd
gui +LastFound
WinGet hWindow,ID
GroupAdd $TestGroup,ahk_id %hWindow%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Load example spell document
Edit_ReadFile(hEdit,"_Example Files\Spell Check Example.txt")
return


GUIEscape:
GUIClose:
gosub Spell_Uninit
ExitApp


Reload:
gosub Spell_Uninit
Reload
return


;***************************
;*                         *
;*                         *
;*        Functions        *
;*                         *
;*                         *
;***************************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Edit_SpellCheckGUI.ahk
#include Fnt.ahk
#include Spell.ahk
#include MoveChildWindow.ahk
#include WinGetPosEx.ahk


;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*                           *
;*                           *
;*****************************
Spell_Init:
;-- Initialize Hunspell and load the primary dictionary
if not Spell_Init(hSpell,"dic\en_US.aff","dic\en_US.dic","lib\")
    return

;-- Load the custom dictionary
$CustomDic:="dic\Edit_SpellCheckGUI.Custom.dic"
Spell_InitCustom(hSpell,$CustomDic)
$SpellInit:=True
return


Spell_Uninit:
if $SpellInit
    {
    Spell_Uninit(hSpell)
        ;-- This step also flushes all the "Ignore All" words from the
        ;   dictionary

    $SpellInit:=False
    }

return


;*****************
;*               *
;*    Hotkeys    *
;*               *
;*****************
#IfWinActive ahk_group $TestGroup
F7::
SpellCheck:
if not $SpellInit
    {
    gosub Spell_Init
    if not $SpellInit  ;-- Check just in case Spell_Init failed
        return
    }

SetBatchLines 200ms  ;-- Significant priority bump for Spell Check
$Font:="Lucida Console:s9"
$Font:="Message"
Edit_SpellCheckGUI(GUI,hEdit,hSpell,$CustomDic,"",$Font)
SetBatchLines 10ms   ;-- System default
return
#IfWinActive
