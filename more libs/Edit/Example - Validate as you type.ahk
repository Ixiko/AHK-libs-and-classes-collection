/*
    Thanks to jsherk for the idea for this example.
    Post: http://www.autohotkey.com/forum/viewtopic.php?t=73246
*/
;[===============]
;[  Environment  ]
;[===============]
#NoEnv
#SingleInstance Force
ListLines Off

;[=============]
;[  Build GUI  ]
;[=============]
gui -DPIScale -MinimizeBox
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Text,,Example 1: File name.`nAll characters allowed except for the following: \ / : * ? < > |
gui Add,Edit,w500 hWndhEdit1 gEdit1
gui Add,Text ;-- Spacer
gui Add,Text,,Example 2: Number (0-9) characters only.  Maximum of 10 digits.`nExample of use: American telephone number.
gui Add,Edit,w120 hWndhEdit2 gEdit2  ; Number
    ;   Update 20140727:  The Number option was removed to allow the user to
    ;   paste a number that may include formatting characters.  This change was
    ;   necessary because after Windows XP, the Number option became a lot more
    ;   restrictive.
    ;
    ;-- Note 2: The "Limit" option is not used here because when pasting, the
    ;   option may truncate the value before the script has a chance to remove
    ;   any invalid characters.  For example, the "Limit10" option would
    ;   truncate the value of "(403) 555-1212" to "(403) 555-" before the script
    ;   has a chance to remove all non-Number characters.  The end result would
    ;   be "403555".  Without the "Limit10" option, all 10 number characters are
    ;   preserved and the end result is "4035551212".

gui Add,Text ;-- Spacer
gui Add,Text,,Example 3: Hexadecimal (0-9, A-F) characters only.  Maximum of 16 digits/characters.`nExample of use: 64-bit hex value.
gui Add,Edit,w200 hWndhEdit3 gEdit3 Uppercase
    ;-- Note: The "Uppercase" option is used to keep the any hex letters
    ;   consistently one case (Uppercase).  "Lowercase" can be used instead.

gui Font

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return

GUIEscape:
GuiClose:
ExitApp


;[============]
;[  Validate  ]
;[============]
Edit1:
Text:=Edit_GetText(hEdit1)
NewText:= RegExReplace(Text,"[\\/:*?<>|]","")
    ;-- Allow everything except for the following: \ / : * ? < > |

if (NewText<>Text)
    {
    Edit_GetSel(hEdit1,StartSelPos,EndSelPos)    ;-- Get caret position
    Edit_SetText(hEdit1,NewText)                 ;-- Replace text.
        ;-- Note: The Undo buffer is automatically flushed after this command is
        ;   executed.  This is not a bad thing.  Undo is not desired if the user
        ;   entered or pasted invalid characters.

    NewSelPos:=EndSelPos-(StrLen(Text)-StrLen(NewText))
    Edit_SetSel(hEdit1,NewSelPos,NewSelPos)      ;-- Reposition caret
    SoundPlay *-1  ;-- Default system beep
        ;-- Note: The sound is both informative and behavioral.  It informs the
        ;   user that an invalid character has been entered and, after a while,
        ;   it encourages the user to refrain from entering invalid characters
        ;   in the future.  When pasting text that include one or more invalid
        ;   characters, this sound may be the only indicator that not all
        ;   characters from the clipboard made it to the Edit field.
    }

return


Edit2:
Text:=Edit_GetText(hEdit2)
NewText:=SubStr(RegExReplace(Text,"[^0-9]",""),1,10)
    ;-- Unsigned integer only.  Max of 10 digits.

if (NewText<>Text)
    {
    Edit_GetSel(hEdit2,StartSelPos,EndSelPos)       ;-- Get caret position
    Edit_SetText(hEdit2,NewText)                    ;-- Replace text
    NewSelPos:=EndSelPos-(StrLen(Text)-StrLen(NewText))
    Edit_SetSel(hEdit2,NewSelPos,NewSelPos)         ;-- Reposition caret
    SoundPlay *-1                                   ;-- Default system beep
    }

return


Edit3:
Text:=Edit_GetText(hEdit3)
NewText:=SubStr(RegExReplace(Text,"[^0-9A-F]",""),1,16)
    ;-- Hex characters only.  Max of 16 characters.

if (NewText<>Text)
    {
    Edit_GetSel(hEdit3,StartSelPos,EndSelPos)       ;-- Get caret position
    Edit_SetText(hEdit3,NewText)                    ;-- Replace text
    NewSelPos:=EndSelPos-(StrLen(Text)-StrLen(NewText))
    Edit_SetSel(hEdit3,NewSelPos,NewSelPos)         ;-- Reposition caret
    SoundPlay *-1                                   ;-- Default system beep
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

