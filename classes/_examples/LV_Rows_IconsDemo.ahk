#NoEnv
#SingleInstance, Force
#Include ..\Class_LV_Rows.ahk

; Create a menu with shortcuts.
Menu, EditMenu, Add, Copy`tCtrl+C, Copy
Menu, EditMenu, Add, Cut`tCtrl+X, Cut
Menu, EditMenu, Add, Paste`tCtrl+V, Paste
Menu, EditMenu, Add, Delete`tDelete, Delete
Menu, EditMenu, Add
Menu, EditMenu, Add, Move Up`tCtrl+Up, MoveUp
Menu, EditMenu, Add, Move Down`tCtrl+Down, MoveDown
Menu, MenuBar, Add, Edit, :EditMenu
Gui, Menu, MenuBar

; Create ListView and add some icons.
Gui, Add, ListView, h300 w300 hwndhLV vLV gLVLabel, Icon & Number
ImageListID := IL_Create(30)
LV_SetImageList(ImageListID)
Loop 30
{
    IL_Add(ImageListID, "shell32.dll", A_Index)
    LV_Add("Icon" . A_Index, A_Index)
}

; Create a handle for the ListView passing its Hwnd.
LvHandle := New LV_Rows(hLV)
Gui, Show,, [Class] LV_Rows - Icons Demonstration
return

; Context Menu.
GuiContextMenu:
If (A_GuiControl <> "LV")
    return
Menu, EditMenu, Show, %A_GuiX%, %A_GuiY%
return

; ListViews G-Label.
LVLabel:
; Detect Drag event.
If A_GuiEvent = D
    LvHandle.Drag()     ; Call Drag function using the Handle.
return

Copy:
LvHandle.Copy()         ; Copy active List selected rows.
return

Cut:
LvHandle.Cut()          ; Cut active List selected rows.
return                            

Paste:                            
LvHandle.Paste()        ; Paste contents from memory.
return                                 

Delete:                                
LvHandle.Delete()       ; Deletes seleted rows.
return                                 

MoveUp:                                
LvHandle.Move(1)        ; Move selected rows up.
return                                 

MoveDown:                              
LvHandle.Move()         ; Move selected rows down.
return

GuiClose:
ExitApp
