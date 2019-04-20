; #Include CMDret_stream.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Gui, Add, Edit, x6 y10 w460 h360 +HScroll
Gui, Show, x398 y110 h377 w477, CMDret - AHK version - Streaming Test App

Gui +LastFound
StrOut := CMDret_Stream("cmd /c dir c:\")
MsgBox %StrOut%

Return

GuiClose:
ExitApp

CMDret_Output(CMDout, CMDname="")
{
	Global OutputWindow
	ControlSetText, Edit1, %CMDout%
	Sleep, 200
}