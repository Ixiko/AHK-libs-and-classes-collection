#include %A_ScriptDir%\..\..\lib\Windy
#include Windy.ahk

arrBorder := ["l","r","hc","t","b","vc", "l t", "l b", "l vc", "r t", "r b", "r vc", "hc t", "hc b", "hc vc"]
obj := new Windy(0,0)
Loop % arrBorder.MaxIndex() {
	OutputDebug % "********************************* " arrBorder[A_Index] " ************************************************"
	obj.move(200,200)
	obj.debug := 1
	obj.moveBorder(arrBorder[A_Index])
	obj.debug := 0
	sleep 2000
}
obj.kill()

ExitApp