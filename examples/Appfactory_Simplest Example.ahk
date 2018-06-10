#SingleInstance force
#NoEnv
;#Include AppFactory.ahk

factory := new AppFactory()
factory.AddInputButton("HK1", "w200", Func("InputEvent"))
factory.AddControl("MyEdit", "Edit", "xm w200", "Default Value", Func("GuiEvent"))

Gui, Show, x0 y0
return

InputEvent(state){
	Global factory
	Tooltip % "Input changed state to: " state " after " A_TickCount " ticks"
}

GuiEvent(state){
	Tooltip % "GuiControl changed state to: '" state "' after " A_TickCount " ticks"
}

^Esc::
GuiClose:
	ExitApp