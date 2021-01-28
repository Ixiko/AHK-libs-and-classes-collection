#NoEnv
#Include MDMF.ahk
Monitors := MDMF_Enum()
Gui, Margin, 20, 20
Gui, +OwnDialogs
Gui, Add, ListView, w660 r10 Grid, HMON|Num|Name|Primary|Left|Top|Right|Bottom|WALeft|WATop|WARight|WABottom
For HMON, M In Monitors {
   LV_Add("", HMON, M.Num, M.Name, M.Primary, M.Left, M.Top, M.Right, M.Bottom, M.WALeft, M.WATop, M.WARight, M.WABottom)
}
Loop, % LV_GetCount("Column")
   LV_ModifyCol(A_Index, "AutoHdr")
Gui, Show, ,Monitors
Return
GuiClose:
ExitApp