#include %A_ScriptDir%\..\..\lib\Windy
#include WindLy.ahk
#include Windy.ahk

OutputDebug % "******** All windows ***********************************************************************"
x := new WindLy()
x.Snapshot()
for key, data in x.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

OutputDebug % "******** All windows on monitor 2 ***********************************************************"
y:= new WindLy()
y.byMonitorId(2)
for key, data in y.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

OutputDebug % "############## SET-Operation DIFFERENCE: WindLy.difference() ###################################"
; Create difference  of WindLy instance x and WindLy instance y
x.difference(y) ; y is removed from x - the result is stored in x again 
OutputDebug % "******** WindLy After Union *******************************************************************"
for key, data in x.list {
	OutputDebug %  "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

ExitApp
