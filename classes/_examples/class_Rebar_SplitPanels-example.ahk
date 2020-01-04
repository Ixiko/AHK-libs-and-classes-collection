; Example of Split Panels with resizable GUI and controls

#NoEnv
#SingleInstance Force
#Include %A_ScriptDir%\..\Class_Rebar.ahk

Gui, LeftPanel:+HwndhLeft -Caption
Gui, LeftPanel:Add, DDL, vDList, Item1||Item2|Item3
Gui, LeftPanel:Add, ListBox, r10 vListB, Item1|Item2|Item3

Gui, RightPanel:+HwndhRight -Caption
Gui, RightPanel:Add, Tab2, h160 w100 vTabC, Tab A|Tab B|Tab C

Gui, +Resize
Gui, Add, Custom, ClassReBarWindow32 hwndhSplitter vSplitWin w380 -Theme 0x0800 0x0040 0x8000 0x0008
Gui, Show, h200 w400

rbSplitter := New Rebar(hSplitter)
rbSplitter.InsertBand(hLeft, 0, "NoGripper", 10, "", 150, 0, "", 170, 80, 10)
rbSplitter.InsertBand(hRight, 0, "", 20, "", 150, 0, "", 170, 80, 10)
rbSplitter.SetMaxRows(1)

WM_NOTIFY := 0x4E
OnMessage(WM_NOTIFY, "RB_Notify")
return

GuiClose:
ExitApp

GuiSize:
rbSplitter.ModifyBand(1, "MinHeight", (A_GuiHeight - 15))
rbSplitter.ModifyBand(2, "MinHeight", (A_GuiHeight - 15))
GuiControl, Move, SplitWin, % "W" (A_GuiWidth - 10) "H" (A_GuiHeight - 10)
return

LeftPanelGuiSize:
GuiControl, LeftPanel:Move, DList, % "W" (A_GuiWidth - 25)
GuiControl, LeftPanel:Move, ListB, % "W" (A_GuiWidth - 25) "H" (A_GuiHeight - 40)
return

RightPanelGuiSize:
GuiControl, RightPanel:Move, TabC, % "W" (A_GuiWidth - 25) "H" (A_GuiHeight - 20)
return

RB_Notify(wParam, lParam)
{
    Global rbSplitter
    rbSplitter.OnNotify(lParam)
}

