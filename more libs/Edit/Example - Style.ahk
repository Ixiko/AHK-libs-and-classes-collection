#NoEnv
#SingleInstance Force
ListLines Off

;-- Static
ES_UPPERCASE  :=0x8
ES_LOWERCASE  :=0x10
ES_PASSWORD   :=0x20    ;-- The Edit_SetPasswordChar function is used for this sytle
ES_OEMCONVERT :=0x400   ;-- Only useful for Windows 3.1 or older.  Do not use.
ES_READONLY   :=0x800   ;-- The Edit_SetReadOnly function is used for this style
ES_WANTRETURN :=0x1000
ES_NUMBER     :=0x2000

gui -DPIScale -MinimizeBox
gui Add,Text,,Single-line edit control:
gui Add,Edit,xm w400 hWndhEdit1
gui Add,Text,,Multiline edit control:
gui Add,Edit,xm w400 r5 hWndhEdit2
gui Add,Text,,Styles:
gui Add,Checkbox,xm     gUppercase,Uppercase     %A_Space%
gui Add,Checkbox,x+0 wp gLowercase,Lowercase
gui Add,Checkbox,x+0 wp gNumber,Number
gui Add,Checkbox,xm  wp gPassword,Password
gui Add,Checkbox,x+0 wp gWantReturn,Want Return
gui Add,Checkbox,x+0 wp gReadOnly,Read Only
gui Show,,Style Example
return

GUIEscape:
GUIClose:
ExitApp


Uppercase:
Edit_SetStyle(hEdit1,ES_UPPERCASE,"^")
Edit_SetStyle(hEdit2,ES_UPPERCASE,"^")
Text:="Uppercase style has been " . (Edit_IsStyle(hEdit1,ES_UPPERCASE) ? "added.":"removed.")
SB_setText(Text)
return


Lowercase:
Edit_SetStyle(hEdit1,ES_LOWERCASE,"^")
Edit_SetStyle(hEdit2,ES_LOWERCASE,"^")
Text:="Lowercase style has been " . (Edit_IsStyle(hEdit1,ES_LOWERCASE) ? "added.":"removed.")
SB_setText(Text)
return


;-- Note: Both controls are updated but this style only works on single-line
;   edit controls.
;
;   Observation 20140912: Seems to also work on multiline edit controls when
;   tested on Windows 7.  Probably should still assume that the style is only
;   good for single-line edit controls.
;
Password:
if Edit_IsStyle(hEdit1,ES_PASSWORD)
    {
    Edit_SetPasswordChar(hEdit1,0)
    Edit_SetPasswordChar(hEdit2,0)
    }
 else
    {
    ;-- For this example, the default password character is used
    Edit_SetPasswordChar(hEdit1)
    Edit_SetPasswordChar(hEdit2)
    }

Text:="Password style has been " . (Edit_IsStyle(hEdit1,ES_PASSWORD) ? "added.":"removed.")
SB_setText(Text)
return


Number:
Edit_SetStyle(hEdit1,ES_NUMBER,"^")
Edit_SetStyle(hEdit2,ES_NUMBER,"^")
Text:="Number style has been " . (Edit_IsStyle(hEdit1,ES_NUMBER) ? "added.":"removed.")
SB_setText(Text)
return


;-- Note: Both controls are updated but this style only works on multiline edit
;   controls.
WantReturn:
Edit_SetStyle(hEdit1,ES_WANTRETURN,"^")
Edit_SetStyle(hEdit2,ES_WANTRETURN,"^")
Text:="Want Return style has been " . (Edit_IsStyle(hEdit1,ES_WANTRETURN) ? "added.":"removed.")
SB_setText(Text)
return


ReadOnly:
Edit_SetReadOnly(hEdit1,!Edit_IsReadOnly(hEdit1))
Edit_SetReadOnly(hEdit2,!Edit_IsReadOnly(hEdit2))
SB_setText("")
return


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
