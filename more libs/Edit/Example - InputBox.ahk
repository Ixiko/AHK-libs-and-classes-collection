/*
    This example includes a lot of custom changes to the Edit field in the
    standard AutoHtokey InputBox window.  Read through the script to see all the
    changes.

    Idea for this example: just me.
    Post: http://www.autohotkey.com/board/topic/88206-inputbox-data-validation-5-characters-or-less/#entry559627

*/

#NoEnv
#SingleInstance Force
ListLines Off

;-- Constants
ES_UPPERCASE :=0x8
ES_LOWERCASE :=0x10
ES_NUMBER    :=0x2000

;-------------
;-- Build GUI
;-------------
gui -DPIScale -MinimizeBox
gui Add,Text,xm,Edit control Options/Styles:
gui Add,CheckBox,xm+10 Section vEditBalloonTip,                 Balloon Tip
gui Add,CheckBox,xs            vEditCueBanner,                  Cue Banner
gui Add,CheckBox,xs            vEditLimitOption,                Limit:
gui Add,Edit,x+5 w50 Number    vEditLimit,3
gui Add,CheckBox,xs            vEditNumber,                     Number
gui Add,Checkbox,xs            vEditPassword,                   Password
gui Add,CheckBox,xs            vEditUppercase   gEditUppercase, Uppercase
gui Add,CheckBox,xs            vEditLowercase   gEditLowercase, Lowercase
gui Add,Text,xm ;-- Filler
gui Add,Text,xm,InputBox Values:
gui Add,Text,xm+10 w60 Section,                                 Title:
gui Add,Edit,x+0 w200          vIBTitle,                        InputBox Title
gui Add,Text,xs  w60,                                           Prompt:
gui Add,Edit,x+0 w200          vIBPrompt,                       Enter stuff:
gui Add,Text,xs  w60,                                           Default:
gui Add,Edit,x+0 w200          vIBDefault

;-- Buttons
gui Add,Button,xm              vInstructions    gInstructions,  %A_Space% Instructions %A_Space%
gui Font,Bold
gui Add,Button,x+5 wp                           gTestButton,    Test
gui Font
gui Add,Button,x+5 wp                           gReload,        Reload...

;-- Status bar
gui Font,% "s" . Fnt_GetStatusFontSize(),% Fnt_GetStatusFontName()
gui Add,StatusBar
gui Font

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
    ,0x40   ;-- 0x40 (Info icon) + 0x0 (OK button)
    ,Instruction,
       (ltrim join`s
        In this example, the script changes the options and/or style(s) of
        the InputBox's Edit control.
        `n`nInstructions:
        `n`n1) Select one or more of the "Edit control Options/Styles"
        options.
        `n`n2) For the "InputBox Values" section, enter or update the title,
        prompt, and default values for the InputBox dialog.  Note: Some of the
        features in the example will not be shown unless there is default value.
        The cue banner will not show unless there is no default value.
        `n`n3) Press the "Test" button to perform the test.  The options
        entered/selected in Steps 1 and 2 will be applied to the InputBox dialog
        and to the InputBox's Edit control.
        `n`n4) Repeat if desired.
       )

return


Reload:
Reload
return


TestButton:

;-- Collect form values
gui Submit,NoHide

;-- Set selected options on the InputBox's Edit control 
SetTimer SetEditOptions,1

;-- Show input box
gui +OwnDialogs  ;-- Give ownership of the dialog to the GUI
InputBox OutputVar,%IBTitle%,%IBPrompt%,,500,200,,,,,%IBDefault%

if ErrorLevel   ;-- User canceled
    SB_SetText("InputBox cancelled.")
 else
    SB_SetText("User entered: " . OutputVar)

return


SetEditOptions:
Critical
SetTimer %A_ThisLabel%,Off

;-- Wait for the InputBox window to exist.
;   Programming note:  To improve response, a loop is used here instead of the
;   using the WinWait command or waiting for a predetermined time
;   (Ex: SetTimer or Sleep 100).

Loop 70  ;-- ~1000ms maximum
    {
    IfWinExist % IBTitle . " ahk_class #32770"
        Break

    Sleep 1
    }

;-- Bounce if the InputBox is not showing (s/b very rare)
IfWinNotExist % IBTitle . " ahk_class #32770"
    return

;-- Get the handle to the Edit control
ControlGetFocus $Control,A
ControlGet hEdit,hWnd,,%$Control%,A

;-- Cue banner.  Note: The cue banner will only show if the there is no default
;   value.  For Windows versions earlier that Windows Vista, the value of
;   the cue banner feature is limited here because the cue banner will only show
;   when the edit field is not active which is almost never.
if EditCueBanner
    Edit_SetCueBanner(hEdit,"Instructions on what to enter here.",True)

;-- Limit size.  Note: Setting the limit of the Edit control after the control
;   has been created and populated will not enforce the size (read: truncate)
;   the limit that has been specified.  It only enforces the limit from that
;   point on.  This step will truncate the text to specified limit (if needed)
;   before the user can make any new changes to text.  Truncating the text is
;   not necessarily recommended.  This code just shows how to do it if needed.

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

;-- Number.  Note: Setting the Number style on the Edit control after the
;   control has been created and populated will not enforce the style (read:
;   remove all non-number characters) that has been specified.  It only enforces
;   the style from that point on.  To remove non-number characters from the text
;   at the same time as setting the Number style, see the Uppercase/Lowercase
;   example (below) for an example of how to read, check, modify, and replace
;   the text of the Edit control.

if EditNumber
    Edit_SetStyle(hEdit,ES_NUMBER)

;-- Set password character.  Note: This example uses the default password
;   character but any character can be used.
;
;   Important: If the user is allowed to type over an existing hidden value, the
;   Edit_SetPasswordChar function should not be used here because there is
;   slight delay between the time the text is displayed and when the Edit
;   option/styles are applied.  In this instance, the InputBox's "Hide" option
;   should be used instead.
 
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

        ;-- Update if the text has changed
        if (InStr(Text,NewText,True)=0)
            {
            Edit_SetText(hEdit,NewText,True)
            Edit_SetSel(hEdit,0,-1)  ;-- Select all
            }
        }
    }

;-- Balloon tip
;   Note: Showing the balloon tip was moved to the bottom of this routine to
;   allow the other commands to complete first.  This can improve the user
;   experience a little (OK, not much really) by reducing the GUI activity to a
;   minimum.

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

return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
