#NoEnv
SetBatchLines, -1
#Include TV_SetSelColors.ahk
Gui, Margin, 20, 20
Gui, Add, TreeView, w600 r20 hwndHTV
Root := TV_Add("Root")
Loop, 20
   TV_Add("Child" . A_Index, Root)
TV_SetSelColors(HTV, 0xD9EBF9)
Gui, Show, , TreeView with user-defined selection colors
Return
GuiClose:
ExitApp