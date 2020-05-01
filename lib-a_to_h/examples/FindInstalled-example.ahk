#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance ignore
#include %A_ScriptDir%\..\FindInstalled.ahk

Programs := FindInstalled("Down")

Gui, Add, ListBox, vMyListBox gMyListBox w640 r20, % Programs
Gui, Add, Button, Default, OK
Gui, Show


return

MyListBox:
if A_GuiEvent <> DoubleClick
    return
; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
; So fall through to the next label.
ButtonOK:
GuiClose:
GuiEscape:
ExitApp







