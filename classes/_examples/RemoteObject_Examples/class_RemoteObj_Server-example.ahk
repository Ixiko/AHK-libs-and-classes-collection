#NoEnv
SetBatchLines, -1

#Include <Socket>
#Include <Jxon>
#Include ..\RemoteObj.ahk

MyClass := new ExampleClass()
Remote := new RemoteObj(MyClass, ["127.0.0.1", 1337])
return

class ExampleClass
{
	__New()
	{
		Gui, New, +hWndhWnd +AlwaysOnTop
		this.hWnd := hWnd
		Gui, Add, Text, w100 Center, Remote!
		Gui, Show
	}
	
	AddButton(ButtonText, Action, Params*)
	{
		hWnd := this.hWnd
		Gui, %hWnd%: Default
		Gui, Add, Button, xm y+m w100 hWndhButton, %ButtonText%
		
		BoundFunc := this[Action].Bind(this, Params*)
		GuiControl, +g, %hButton%, %BoundFunc%
		
		Gui, Show, AutoSize
	}
	
	Run(Target)
	{
		Run, %Target%
	}
	
	MsgBox(Text)
	{
		MsgBox, %Text%
	}
}

GuiClose:
ExitApp
return