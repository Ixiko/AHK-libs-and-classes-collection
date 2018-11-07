#NoEnv 
#SingleInstance Force

;-- Create GUI
gui -DPIScale -MinimizeBox
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add,Text,xm,This is a standard combo box control.
gui Add,ComboBox,xm w400 r5 hWndhCombo,Item 1||Item 2|This is item3|Item 4|Item 5
gui Add,Text,xm wp,
   (ltrim join`s
    A combo box is a unique type of control that combines much of the
    functionality of a list box and an edit control.  However, the handle
    returned via the "gui Add" command is the handle to the combo box, not to
    the edit control.  To get the handle to the edit control within the combo
    box, use the Edit_GetComboBoxEdit function.
   )

gui Add,Button,xm gGetComboBoxEdit,%A_Space% Get ComboBoxEdit %A_Space%

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%
return


GetComboBoxEdit:
hEdit :=Edit_GetComboBoxEdit(hCombo)
MsgBox % "hCombo=" . Format("0x{:X}",hCombo) . "`nhEdit=" . Format("0x{:X}",hEdit)
Edit_SetText(hEdit,"Yes, this was updated using the Edit library.")
Loop 3
    {
    Sleep 500
    Edit_SetText(hEdit,"")
    Sleep 500
    Edit_SetText(hEdit,"Yes, this was updated using the Edit library.")
    }

return


GUIEscape:
GUIClose:
ExitApp


;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Fnt.ahk
