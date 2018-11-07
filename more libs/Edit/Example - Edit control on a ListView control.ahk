/*
    This examples show how the edit control on the ListView control -- what the
    user sees when pressing F2 on a row -- can be enhanced to provide additional
    information, restrictions, and/or modifications to the data.

    Many of the examples just apply a style to the Edit control to enforce a
    restriction but sometimes, especially if the row already contains text, this
    is not enough.  Read through the entire script to see how some conditions
    are handled.
*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants
ES_UPPERCASE :=0x8
ES_LOWERCASE :=0x10
ES_NUMBER    :=0x2000

;-- Messages
LVM_GETEDITCONTROL :=0x1018     ;-- LVM_FIRST + 24

;-------------
;-- Build GUI
;-------------
gui -DPIScale -MinimizeBox
gui Add,Button,xm vInstructions  gInstructions,%A_Space%  Instructions  %A_Space%
gui Add,Button,x+5 wp           gReload,      Reload...
gui Add,Text,xm,Edit control Options/Styles:
gui Add,CheckBox,xm+10 Section vEditBalloonTip,                 Balloon Tip
gui Add,CheckBox,xs            vEditLimitOption,                Limit:
gui Add,Edit,x+5 w35 Number    vEditLimit,3
gui Add,CheckBox,xs            vEditNumber,                     Number
gui Add,Checkbox,xs            vEditPassword,                   Password
gui Add,CheckBox,xs            vEditUppercase gEditUppercase,   Uppercase
gui Add,CheckBox,xs            vEditLowercase gEditLowercase,   Lowercase

;-- ListView control
gui Add,Text,xm,   ;-- Dummy/Filler
gui Add,Text,xm,ListView:
gui Add
    ,ListView
    ,xm w500 r10 hWndhLV gLVAction +AltSubmit +Grid -Hdr -ReadOnly
    ,Zero

;-- Populate
Loop 20
    LV_Add("","")

LV_ModifyCol(1,"AutoHdr")

;------------
;-- Show GUI
;------------
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GUIEscape:
GUIClose:
ExitApp


EditUppercase:
GUIControl,,EditLowercase,0
return


EditLowercase:
GUIControl,,EditUppercase,0
return


Instructions:
gui +OwnDialogs
MsgBox
    ,0x40   ;-- 0x0 (OK button) + 0x40 (Info icon)
    ,Instruction,
       (ltrim join`s
        In this example, the script changes the options and/or style(s) of
        the edit control that is used by the ListView control to edit the
        item's text.
        `n`nInstructions:
        `n`n1) Select one or more of the "Edit control Options/Styles"
        options.
        `n`n2) Select one of the ListView items and then press F2 to begin
        editing the text of the item's text.  The options selected in Step 1
        should be in effect when entering/editing the text.
       )

return


Reload:
Reload
return


LVAction:
Critical
if (A_GUIEvent=="E")  ;-- The user has begun editing the first field of a row 
    {
    ;-- Get form values 
    gui Submit,NoHide

    ;-- Get the handle to the Edit control
    SendMessage LVM_GETEDITCONTROL,0,0,,ahk_id %hLV%
    hEdit:=ErrorLevel

    ;-- Balloon tip.
    if EditBalloonTip
        {
        Title:="Title.  This is optional"
        Text=
           (ltrim join`s
            This text might include information on what to enter.  See the
            documentation in the Edit library for additional information.
           )

        Edit_ShowBalloonTip(hEdit,Title,Text)
        }

    /*
        Limit size

        Setting the limit of the edit control after the control has been created
        and populated will not enforce the size (read: truncate) the limit that
        has been specified.  It only enforces the limit from that point on.
        This step will truncate the text to specified limit (if needed) before
        the user can make any new changes to text. Truncating the text is not
        necessarily recommended.  This code just shows how to do it if needed.
    */
    if EditLimitOption
        if EditLimit is Integer
            if (EditLimit>0)
                {
                Edit_SetLimitText(hEdit,EditLimit)

                ;-- Get text
                Text:=Edit_GetText(hEdit)

                ;-- Truncate if needed
                if (StrLen(Text)>EditLimit)
                    {
                    Edit_SetText(hEdit,SubStr(Text,1,EditLimit),True)
                    Edit_SetSel(hEdit,0,-1)  ;-- Select all
                    }
                }

    /*
        Number

        Setting the Number style on the Edit control after the control has been
        created and populated will not enforce the style (read: remove all
        non-number characters) that has been specified.  It only enforces the
        style from that point on.  To remove non-number characters from the text
        at the same time as setting the Number style, see the
        Uppercase/Lowercase example (below) for an example of how to read,
        check, modify, and replace the text of the Edit control.
    */
    if EditNumber
        Edit_SetStyle(hEdit,ES_NUMBER)

    ;-- Set password character.  Note: This example uses the default password
    ;   character but any character can be used.
    if EditPassword
        Edit_SetPasswordChar(hEdit)

    ;-- Uppercase or Lowercase
    if EditUppercase or EditLowercase
        {
        if EditUppercase
            Edit_SetStyle(hEdit,ES_UPPERCASE)
         else    
            Edit_SetStyle(hEdit,ES_LOWERCASE)

        ;-- Get text
        Text:=Edit_GetText(hEdit)
        if StrLen(Text)
            {
            ;-- Convert text if needed.  Note: Changing the style of the edit
            ;   control after the control has been created and populated will
            ;   force the user to use the new style but does not affect the text
            ;   that is currently in the control.  This step will convert the
            ;   text to use the new style (if needed) before the user can make
            ;   any new changes to text.
            if EditUppercase
                StringUpper NewText,Text
             else
                StringLower NewText,Text

            ;-- Update if text has changed
            if (InStr(Text,NewText,True)=0)
                {
                Edit_SetText(hEdit,NewText,True)
                Edit_SetSel(hEdit,0,-1)  ;-- Select all
                }
            }
        }
    }

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
