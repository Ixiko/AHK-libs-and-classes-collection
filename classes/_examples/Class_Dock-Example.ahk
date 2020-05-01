#NoEnv
#SingleInstance, force
#include %A_ScriptDir%\..\class_dock.ahk


Gui, +hwndGuihwnd
Gui, Font, s13
Gui, Add, Button, gBtn, Dock to Top
Gui, Add, Button, gBtn, Dock to Bottom
Gui, Add, Button, gBtn, Dock to Right
Gui, Add, Button, gBtn, Dock to Left
Gui, Add, Button, gAdd, Add dock
Gui, Add, Button, gAdd, Add dock to Top
Gui, Add, Button, gAdd, Add dock to Bottom
Gui, Add, Button, gAdd, Add dock to Right
Gui, Add, Button, gAdd, Add dock to Left
Gui, Show, xCenter yCenter w300, class Dock Example

ParentID:= WinExist("Editor")
;exDock := new Dock(Guihwnd, Dock.HelperFunc.Run("notepad.exe"))
exDock := new Dock(ParentID, Guihwnd)
exDock.Position("R")
exDock.CloseCallback := Func("CloseCallback")
Return

Btn:
exDock.Position(A_GuiControl)
Return

Add:
exDock.Add(Dock.HelperFunc.Run("notepad.exe"), A_GuiControl)
Return

CloseCallback(self)
{
	WinKill, % "ahk_id " self.hwnd.Client
	ExitApp
}

GuiClose:
Gui, Destroy
ExitApp