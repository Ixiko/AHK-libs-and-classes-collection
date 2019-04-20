#include %A_ScriptDir%\..\..\lib\Windy
#include Mousy.ahk

CoordMode,Mouse,Screen
obj := new Mousy()
OutputDebug % ">>>>>[" A_ThisFunc "]>>>>>"
MouseMove, 1,1,50
savetrail := obj.trail
obj.trail := 7
MouseMove, 1000, 1000,50
OutputDebug % obj.trail
obj.trail := 1
MouseMove, 1,1,50
OutputDebug % obj.trail
obj.trail := 4
OutputDebug % "<<<<<[" A_ThisFunc "]<<<<<"
obj.trail := savetrail
ExitApp
