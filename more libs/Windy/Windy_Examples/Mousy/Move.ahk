#include %A_ScriptDir%\..\..\lib\Windy
#include Mousy.ahk

obj := new Mousy()
OutputDebug % ">>>>>[" A_ThisFunc "]>>>>>"
obj.x := 100
obj.y := 100
obj.movespeed := 25
obj.speed := 10
obj.movemode := 1
obj.x :=1000
obj.movemode := 3
obj.pos := new Pointy(500,500)
OutputDebug % "<<<<<[" A_ThisFunc "]<<<<<"
ExitApp