#NoEnv
#NoTrayIcon
#Include <Class_VisualStyle>

SendMode Input
SetBatchLines -1

posX := ((A_ScreenWidth - 570) - 50)

Wizard  := new VisualStyle()
WizProp := Wizard.WinCreate("", "Back", "Next", "ButtonCancel", "", posX, 50)

GuiControl, Enable, % WizProp.NavBtn
GuiControl, Disable, % WizProp.CmdBtnNext

Wizard.WinShow()
Return 

Back:
Next:
ButtonCancel:
GuiClose:
ExitApp