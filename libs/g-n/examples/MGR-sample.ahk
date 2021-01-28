#Include %A_ScriptDir%\MGR.ahk
#Include %A_ScriptDir%\MGR_UDF.ahk
#MaxHotkeysPerInterval 200
#NoEnv
#SingleInstance, Force

Menu, Tray, NoStandard
Menu, Tray, Add, Sample.ahk,   Open
Menu, Tray, Add, MGR.ahk,      Open
Menu, Tray, Add, MGR_UDF.ahk,  Open
Menu, Tray, Add, Gestures.ini, Open
Menu, Tray, Add, Folder,       Open
Menu, Tray, Add
Menu, AutoHotkey, Standard
Menu, Tray, Add, AutoHotkey, :AutoHotkey
Menu, Tray, Add, Suspend,    Manage
Menu, Tray, Add, Exit,       Manage
Menu, Tray, Click, 1
Menu, Tray, Default, Suspend
Menu, Tray, Icon, Shell32, 44
Menu, Tray, Tip, MGR

mgr_Config := A_ScriptDir "\Gestures.ini"
Return

Open:
If (A_ThisMenuItem~="i)(sample.ahk|mgr(_udf)?.ahk|gestures.ini)")
	cmd = notepad "%A_ScriptDir%\%A_ThisMenuItem%"
Else If (A_ThisMenuItem="Folder")
	cmd = "%A_ScriptDir%"
Run, % cmd, % A_ScriptDir, Max|UseErrorLevel
If ErrorLevel
	MsgBox, 4112, ERRRO:, % cmd
Return

Manage:
If (A_ThisMenuItem="Suspend")
	Suspend
Else If (A_ThisMenuItem="Exit")
	ExitApp
Return


Label_Test:
MsgBox, % "Current subroutine : " A_ThisLabel
Return

Msg(txt)
{
	MsgBox, % A_ThisFunc "()`n" txt
}