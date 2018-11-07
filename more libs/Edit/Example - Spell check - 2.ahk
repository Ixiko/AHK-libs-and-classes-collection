/*
    In this example, the Edit_SpellCheckGUI add-on function is used to spell
    check the text in any edit control.  Run the script for the instructions.
*/
#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
$SpellInit:=False
    ;-- This variable to used to keep the Spell library from initializing until
    ;   the Spell Check is requested for the first time.  It slows down the
    ;   first call a tiny bit but it keeps the script from using memory used by
    ;   the Spell library until it is actually needed.  This variable is also
    ;   used to determine if the Spell_Uninit function should be called.

;-- Create GUI
gui -DPIScale +AlwaysOnTop
gui Add,Text,xm,
   (ltrim
    In this example, a Spell Check can be performed on any Edit control.

    WARNING: This example can make real changes to real data.  Use with care.

    Instructions:

    1) Open any program that uses an Edit control.  Use Notepad if you can't
    think of anything else.

    2) Make sure the Edit control has text that can be checked by the Spell
    Check routine.  If using Notepad, load any text document.

    3) While on the Edit control, use Ctrl+Shift+F7 to start the Spell Check.

    This example will remain active as long as this window remains open.  Close
    this window to stop the example.
    )

;-- Show
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,y0,%$ScriptTitle%
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


SpellCheck:
;-- On an Edit control?  If not, bounce
if not Edit_GetActiveHandles(hEdit,hWindow,True)
    return

if not $SpellInit
    {
    gosub Spell_Init
    if not $SpellInit  ;-- Just in case Spell_Init failed
        return
    }

SetBatchLines 200ms ;-- Significant bump in priority
Edit_SetReadOnly(hEdit,True)
Edit_SpellCheckGUI(0,hEdit,hSPell,CustomDic)
Edit_SetReadOnly(hEdit,False)
SetBatchLines 10ms  ;-- System default
return


;*****************
;*               *
;*    Hotkeys    *
;*               *
;*****************
^+F7::gosub SpellCheck
