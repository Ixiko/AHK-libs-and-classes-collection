#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
if not Spell_Init(hSpell,"dic\en_US.aff","dic\en_US.dic","lib\")
    return

;-- The example
Word :="autohotkey"
Loop
    {
    InputBox Word,Spell Check Example,Enter a word to check:,,w300,h200,,,,,%Word%
    if ErrorLevel
        Break

    if Spell_Spell(hSpell,Word)
        MsgBox "%Word%" found in the dictionary.
     else
        {
        SuggestCount:=Spell_Suggest(hSPell,Word,SuggestList)
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
