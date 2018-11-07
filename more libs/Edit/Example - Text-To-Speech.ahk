#NoEnv
#SingleInstance Force
ListLines Off

;-- Initialize
SplitPath A_ScriptName,,,,$ScriptName

;-- Menu
Menu Menubar,Add,Text-To-Speech,TTS
Menu Menubar,Add,Reload...,Reload

;-- GUI
gui -DPIScale +Resize -MaximizeBox -MinimizeBox
gui Margin,0,0
gui Menu,Menubar
gui Font,% "s" . Fnt_GetMessageFontSize(),% Fnt_GetMessageFontName()
gui Add
   ,Edit
   ,% ""
        . "w500 r20 "
        . "+0x100 "     ;-- ES_NOHIDESEL
        . "hWndhEdit "
        . "vMyEdit "

gui Font  ;-- Reset to default

;-- Show it
SplitPath A_ScriptName,,,,$ScriptTitle
gui Show,,%$ScriptTitle%

;-- Load example file
Edit_ReadFile(hEdit,A_ScriptDir . "\_Example Files\TTS Example.txt")
return


GUIEscape:
GUIClose:
IfWinExist ahk_id %hTTSGUI%
    {
    WinClose ahk_id %hTTSGUI%
    WinWaitClose ahk_id %hTTSGUI%,,2
    }

ExitApp


GUISize:
GUIControl Move,MyEdit,% "w" . A_GUIWidth . " h" . A_GUIHeight
return


Reload:
Reload
return


TTS:

;-- Bounce if the Edit_TTSGUI window is already open
IfWinExist ahk_id %hTTSGUI%
    return

;-- Open it up
hTTSGUI:=Edit_TTSGUI(1,hEdit,Options)
return

;*******************
;*                 *
;*    Functions    *
;*                 *
;*******************
#include %A_ScriptDir%\_Functions
#include Edit.ahk
#include Edit_TTSGUI.ahk

#include AddToolTip.ahk
#include Fnt.ahk
#include MoveChildWindow.ahk
#include WinGetPosEx.ahk
