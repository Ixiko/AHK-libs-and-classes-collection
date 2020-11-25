#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

launchWin := new VisualStyle()

launchWinProp := launchWin.WinCreate("Example Launcher", "", "", "BtnClose", "-1", "", "", 480, 430, "Win")
GuiControl,, % launchWinProp.CmdBtnCancel, Close

HeaderFont := launchWin.GetFontProperties("AEROWIZARD", AW_HEADERAREA)

Gui, % launchWinProp.hwnd ": Font", % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui, % launchWinProp.hwnd ": Add", Text, x15 y10, Which example would you like to run?

launchWin.CommandLink("Example1", "p", "+20", 450, 60, "Blank Aero Wizard Example", "Simple AeroWizard-like GUI with return and command buttons", 1)
launchWin.CommandLink("Example2", "p",  "+5", 450, 60, "System Task Dialog Example", "TaskDialog-like GUI with button using the SetElevationRequired method")
launchWin.CommandLink("Example3", "p",  "+5", 450, 60, "Content Link Example", "Simple TaskDialog-like GUI with styles applied to content link controls")
launchWin.CommandLink("Example4", "p",  "+5", 450, 60, "Full Aero Wizard Example", "Multipage Aero Wizard GUI for AutoHotkey Installation")
launchWin.CommandLink("Example5", "p",  "+5", 450, 60, "Vistual Style Example", "Simple standard GUI with Visual Style applied to Treeview Control")

launchWin.WinShow()
Return

Example1:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, Example1.ahk
Return

Example2:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, Example2.ahk
Return

Example3:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, Example3.ahk
Return

Example4:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, Example4.ahk
Return

Example5:
	if (A_GuiEvent = "Normal") and (A_EventInfo = 0x0000)
		Run, Example5.ahk
Return

BtnClose:
GuiClose:
ExitApp