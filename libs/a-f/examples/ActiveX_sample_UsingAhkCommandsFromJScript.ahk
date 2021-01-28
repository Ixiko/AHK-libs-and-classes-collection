#include *i %A_ScriptDir%\ActiveX.ahk
ActiveX()

MyClass_WinMaximize(this,prm,res,flags){
	WinMaximize,% evArgv(prm,0)
}
MyClass_Send(this,prm,res,flags){
	Send,% evArgv(prm,0)
}

;JScript
script=
(
	AutoHotkey.WinMaximize("A");
	Send("abcd{Shift Down}{Left 4}{Shift Up}");
)


sc:=CreateObject("MSScriptControl.ScriptControl.1")
pp(sc,"Language","jscript")
myobj:=CreateDispatchObject("MyClass_")
inv(sc,"AddObject","AutoHotkey",vObj(myobj),"true")
inv(sc,"Eval",script)

