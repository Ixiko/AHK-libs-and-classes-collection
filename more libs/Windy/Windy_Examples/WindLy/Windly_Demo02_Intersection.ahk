#include %A_ScriptDir%\..\..\lib\Windy
#include WindLy.ahk
#include Windy.ahk
#include ..\DbgOut.ahk

OutputDebug DBGVIEWCLEAR

OutputDebug % "******** Start Situation: All windows of monitor 1 *******************"
x := new WindLy(0)
x.byMonitorId(1)
for key, data in x.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}


; Prepare an example list to intersect with (use original list and remove some items ...)
y := x
i := 0
for key, data in y.list.Clone() { ; As y is manipulated within loop, we have to use a list-clone to iterate over 
	i := i + 1 
	if (i != 1) {
		y.delete(data)
	}
}
OutputDebug % "******** WindLy To Intersect *****************************************"
for key, data in y.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}


OutputDebug % "############## SET-Operation INTERSECTION: WindLy.intersection() ########################"
; Determine Intersection between orignal WindLy instance x and newly generated WindLy instance y
x.intersection(y) ; x is intersected with y - the result is stored in x again 
OutputDebug % "******** WindLy After Intersection *****************************************"
for key, data in x.list {
	OutputDebug %  "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

ExitApp
