#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

winTitle := "Customer Experience Improvement Program"
winIcon  := -1
headerText := "Do you want to join the Windows Customer Experience`nImprovement Program?"
bodyText    = 
(LTrim
		The program helps Microsoft improve Windows. Without interrupting you, it collects
		information about your computer hardware and how you use Windows. The program also
		periodically downloads a file to collect information about problems you might have with
		Windows. The information collected is not used to identify or contact you.
)

TaskDialog := new VisualStyle()
TaskDialogProp := TaskDialog.WinCreate(winTitle, "", "btnSaveChanges", "btnCancel", winIcon, 50, 50, 538, 265, "Win")

HeaderFont	:= TaskDialog.GetFontProperties("AEROWIZARD", AW_HEADERAREA)
ContentFont	:= TaskDialog.GetFontProperties("AEROWIZARD", AW_CONTENTAREA)

Gui, % TaskDialogProp.hwnd ": Add" , Pic, x10 y10, % "HICON:*" LoadPicture("C:\Windows\System32\wsqmcons.exe", "Icon1 GDI+ h32", vType)
Gui, % TaskDialogProp.hwnd ": Font", % "s" HeaderFont.Size " c" HeaderFont.Color,
Gui, % TaskDialogProp.hwnd ": Add" , Text, x50 y10, % headerText
Gui, % TaskDialogProp.hwnd ": Font", % "s" ContentFont.Size " c" ContentFont.Color,
Gui, % TaskDialogProp.hwnd ": Add" , Text, xp y+15, % bodyText
Gui, % TaskDialogProp.hwnd ": Add" , Link, xp y+15, <a>Read the privacy statement online</a>
Gui, % TaskDialogProp.hwnd ": Font",,
Gui, % TaskDialogProp.hwnd ": Font", % "s" ContentFont.Size, % ContentFont.Name
Gui, % TaskDialogProp.hwnd ": Add" , Radio, xp y+15 Checked, Yes, I want to participate in the program.
Gui, % TaskDialogProp.hwnd ": Add" , Radio, xp y+5, No, I don't want to participate in the program.

nExt := TaskDialog.GetTextExtent("Save Changes", "", "", "", "")
GuiControl   ,, % TaskDialogProp.CmdBtnNext, Save Changes
ControlGetPos, btnX, , btnW, , , % "ahk_id " TaskDialogProp.CmdBtnNext
GuiControl   , Move, % TaskDialogProp.CmdBtnNext, % "X" btnX-((nExt.W+30)-btnW) "W" (nExt.W+30)
TaskDialog.ButtonSetElevationRequiredState(TaskDialogProp.CmdBtnNext)

TaskDialog.WinShow()
Return 

btnSaveChanges:
btnCancel:
GuiClose:
ExitApp