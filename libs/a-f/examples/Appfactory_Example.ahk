#SingleInstance force
#NoEnv
;#Include AppFactory.ahk

factory := new AppFactory()
factory.AddInputButton("HK1", "w200", Func("InputEvent").Bind("1"))
factory.AddInputButton("HK2", "xm w200", Func("InputEvent").Bind("2"))
factory.AddControl("MyEdit", "Edit", "xm w200", "Default Value", Func("GuiEvent").Bind("MyEdit"))
factory.AddControl("MyDDL", "DDL", "xm w200 AltSubmit", "One||Two|Three", Func("GuiEvent").Bind("MyDDL"))

Gui, Show, x0 y0
return

InputEvent(ctrl, state){
	Global factory
	Tooltip % "Input " ctrl " changed state to: " state " after " A_TickCount " ticks while MyEdit was '" factory.GuiControls.MyEdit.Get() "'"
}

GuiEvent(ctrl, state){
	Tooltip % "GuiControl " ctrl " changed state to: '" state "' after " A_TickCount " ticks"
}

^Esc::
GuiClose:
	ExitApp
