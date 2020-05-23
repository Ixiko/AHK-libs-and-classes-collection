#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
if not Spell_Init(hSpell,"dic\en_US.aff","dic\en_US.dic","lib\")
    return

;-- Load the custom dictionary
Spell_InitCustom(hSpell,"dic\AutoHotkey.dic","L")

;-- The example
MsgBox 0x40,Spell with Custom Dictionary,
   (ltrim join`s
    In this example, a custom dictionary that contains a list of AutoHotkey
    commands and key words is loaded in addition to a standard Hunspell
    dictionary.  Try to enter any AutoHotkey command or key word to see what
    happens.
    `n`nPress OK to continue.
   )

Word :="WinWaitActive"
Loop
    {
    InputBox Word,Spell Check Example,Enter a word to check:,,w300,h200,,,,,%Word%
    if ErrorLevel
        Break

    if Spell_Spell(hSpell,Word)
        MsgBox "%Word%" found in the dictionary.
     else
        {
        SuggestCount:=Spell_Suggest(hSpell,Word,SuggestList)
        MsgBox,
           (ltrim join`s
           "%Word%" not found in the dictionary.  There are %SuggestCount%
            suggested words which are as follows:
            `n`n%SuggestList%
           )
        }
    }

;-- Uninitialize
Spell_Uninit(hSpell)
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%
#include Spell.ahk
