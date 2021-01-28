#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global Funclet := new _Funclet

Gui, Add, Text,, Type in an AutoHotkey expression, then press Enter:
Gui, Add, Edit, w300 vCode, msg("Hello, world!")
Gui, Add, Button, w0 Default gExec
Gui, Add, Text, vRes x+0 w300, Result =
Gui, Add, Text, y+4 w300,
(
Additional functions:

msg(text) - displays a message box
input(text) - displays an input box
eval(expr) - evaluates a dynamic expression
rep(count, expr) - evaluates a dynamic expression 'count' times

You can use global variables (including built-in variables), as well as objects.

Additional limitations:
- Double-derefs are not supported yet
- Clipboard is read-only
- ClipboardAll doesn't work
)
Gui, Show, AutoSize, eval() demo
Send, {Right}
return

Exec:
Gui, +OwnDialogs
Gui, Submit, NoHide
GuiControl,, res, % "Result = " eval(code)
GuiControl,, Code
return

GuiClose:
ExitApp

msg(x)
{
	msgbox % x
}

input(x)
{
	InputBox, v,, % x
	return v
}

rep(n,x)
{
	Loop, %n%
		eval(x)
}
