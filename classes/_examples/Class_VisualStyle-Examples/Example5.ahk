#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

posX := ((A_ScreenWidth - 400) - 50)
posY := ((A_ScreenHeight - 400) - 50)

Gui, Add, TreeView, hwndhTree1
P1 := TV_Add("First parent")
P1C1 := TV_Add("Parent 1's first child", P1)
P2 := TV_Add("Second parent")
P2C1 := TV_Add("Parent 2's first child", P2)
P2C2 := TV_Add("Parent 2's second child", P2)

UxTheme_SetWindowTheme(hTree1, "EXPLORER", "TREEVIEW")
Tree := new VisualStyle()
Tree.TVSetExtendedStyle(hTree1, (TVS_EX_FADEINOUTEXPANDOS|TVS_EX_AUTOHSCROLL))
Tree.TVSetBKColor(hTree1, 0xBDBDBD)
Tree.TVSetTextColor(hTree1, 0x424242)

Gui, Add, TreeView, hwndhTree2
P1 := TV_Add("First parent")
P1C1 := TV_Add("Parent 1's first child", P1)
P2 := TV_Add("Second parent")
P2C1 := TV_Add("Parent 2's first child", P2)
P2C2 := TV_Add("Parent 2's second child", P2)

Gui, Add, Edit, hWndhEdit w240
Tree.SetCueBannerText(hEdit, "Type Some Text Here", 1)

Gui, Show, % "x" posX " y" posY "h220",
return

GuiClose:
ExitApp