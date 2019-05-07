#NoEnv
#SingleInstance, Force
#Include ..\Class_LV_Rows.ahk

; Create a menu with shortcuts.
Menu, EditMenu, Add, Copy`tCtrl+C, Copy
Menu, EditMenu, Add, Cut`tCtrl+X, Cut
Menu, EditMenu, Add, Paste`tCtrl+V, Paste
Menu, EditMenu, Add, Delete`tDelete, Delete
Menu, EditMenu, Add
Menu, EditMenu, Add, Undo`tCtrl+Z, Undo
Menu, EditMenu, Add, Redo`tCtrl+Y, Redo
Menu, EditMenu, Add
Menu, EditMenu, Add, Move Up`tCtrl+Up, MoveUp
Menu, EditMenu, Add, Move Down`tCtrl+Down, MoveDown
Menu, GroupsMenu, Add, Enable Groups, EnableGroups
Menu, GroupsMenu, Add
Menu, GroupsMenu, Add, Insert Group, InsertGroup
Menu, GroupsMenu, Add, Remove Group, RemoveGroup
Menu, GroupsMenu, Add, Remove All Groups, RemoveAllGroup
Menu, GroupsMenu, Add
Menu, GroupsMenu, Add, Collapse All Groups, CollapseAll
Menu, GroupsMenu, Add, Expand All Groups, ExpandAll
Menu, MenuBar, Add, Edit, :EditMenu
Menu, MenuBar, Add, Groups, :GroupsMenu
Gui, Menu, MenuBar

Gui, Add, ListView, AltSubmit vLV1 hwndhLV1 gLVLabel xm w400 r20 LV0x10000, Folder|Root|Attributes ; LVS_EX_DOUBLEBUFFER := LV0x10000 Avoids flickering.
Loop, %A_ProgramFiles%\*.*, 2
    LV_Add("", A_LoopFileName, A_LoopFileDir, A_LoopFileAttrib)
LV_ModifyCol()

Gui, Add, ListView, Checked AltSubmit vLV2 hwndhLV2 gLVLabel yp x+10 w400 r20 LV0x10000, Folder|Root|Attributes
Gui, ListView, Lv2
Loop, %A_WinDir%\*.*, 2
    LV_Add("", A_LoopFileName, A_LoopFileDir, A_LoopFileAttrib)
LV_ModifyCol()

; Create a handle for both ListViews with the hwnds to enable groups.
LvHandle := New LV_Rows(hLV1, hLV2)
LvHandle.Add()

Gui, Show,, [Class] LV_Rows - Demostration Script
return

; Context Menu.
GuiContextMenu:
If !InStr(A_GuiControl, "LV")
    return
Menu, EditMenu, Show, %A_GuiX%, %A_GuiY%
return

; ListViews G-Label.
LVLabel:
Gui, ListView, %A_GuiControl%     ; Set selected ListView as Default.
LvHandle.SetHwnd(h%A_GuiControl%) ; Select active hwnd in Handle.

; Detect Drag event.
If A_GuiEvent = D
{
    LvHandle.Drag()               ; Call Drag function.
    LvHandle.Add()                ; Add an entry in History.
}
return

Copy:
LvHandle.Copy()                   ; Copy active List selected rows.
return

Cut:
LvHandle.Cut()                    ; Cut active List selected rows.
LvHandle.Add()                    ; Add an entry in History.
return

Paste:
If (LvHandle.Paste())             ; Paste contents from memory.
    LvHandle.Add()                ; Add an entry in History if Paste had data.
return

Delete:
If (LvHandle.Delete())            ; Deletes seleted rows.
    LvHandle.Add()                ; Add an entry in History if there are rows selected.
return

MoveUp:
If (LvHandle.Move(1))             ; Move selected rows up.
    LvHandle.Add()                ; Add an entry in History if there are rows selected.
return

MoveDown:
If (LvHandle.Move())              ; Move selected rows down.
    LvHandle.Add()                ; Add an entry in History if there are rows selected.
return

Undo:
GuiControl, -Redraw, %ActiveList%
LvHandle.Undo()                   ; Go to previous History entry.
GuiControl, +Redraw, %ActiveList%
return

Redo:
GuiControl, -Redraw, %ActiveList%
LvHandle.Redo()                   ; Go to next History entry.
GuiControl, +Redraw, %ActiveList%
return

EnableGroups:
LvHandle.EnableGroups()
return

InsertGroup:
LvHandle.InsertGroup()
return

RemoveGroup:
LvHandle.RemoveGroup()
return

RemoveAllGroup:
LvHandle.RemoveAllGroups()
return

CollapseAll:
LvHandle.CollapseAll()
return

ExpandAll:
LvHandle.CollapseAll(false)
return

GuiClose:
ExitApp
