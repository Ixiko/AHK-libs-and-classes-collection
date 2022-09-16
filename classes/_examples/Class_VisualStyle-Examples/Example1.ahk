#NoEnv
#NoTrayIcon
#Include A_ScriptDir\..\..\..\Class_VisualStyle.ahk
#Include %A_ScriptDir%\..\..\..\libs\a-f\Const_Theme.ahk
#Include %A_ScriptDir%\..\..\..\libs\o-z\UxTheme.ahk

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