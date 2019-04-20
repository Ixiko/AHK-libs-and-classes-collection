#include %A_ScriptDir%\..\..\lib\Windy
#include Recty.ahk
#include Windy.ahk

obj := new Mousy()

obj.confine := false
sleep, 1000
obj.confineRect := new Recty(100,100,200,200)
obj.confine := true
sleep, 10000
obj.confine := false
sleep, 1000
obj.confineRect := new Recty(500,500,700,700)
obj.confine := true
sleep, 10000
obj.confine := false
sleep, 1000


