#include %A_ScriptDir%\..\..\lib\Windy
#include Windy.ahk

obj := new Windy(0,0)

ToolTip, ClickThrough:= 1`nAlwaysOnTop:=1, 100, 150
obj.alwaysontop := 1
obj.clickthrough := 1
sleep 10000
ToolTip, ClickThrough:= 0`nAlwaysOnTop:=0, 100, 150
obj.clickthrough := 0
obj.alwaysontop := 0
sleep 10000
ToolTip
obj.kill()

ExitApp