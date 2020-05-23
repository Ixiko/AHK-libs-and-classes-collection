#include %A_ScriptDir%\..\..\lib\Windy
#include WindLy.ahk
#include Windy.ahk

OutputDebug % "******** All windows on monitor 1 ***********************************************************"
x := new WindLy()
x.byMonitorId(1)
for key, data in x.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

OutputDebug % "******** All windows on monitor 2 ***********************************************************"
y:= new WindLy()
y.byMonitorId(2)
for key, data in x.list { ; As y is manipulated within loop, we have to use a list-clone to iterate over 
	i := i + 1 
	if (i < 2) {
		y.insert(data)
	}
}
for key, data in y.list {
	OutputDebug % "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

OutputDebug % "############## SET-Operation SYMMETRICDIFFERENCE: WindLy.symmetricDifference() ##################"
; Create difference  of WindLy instance x and WindLy instance y
x.symmetricDifference(y) ; y is removed from x - the result is stored in x again 
OutputDebug % "******** WindLy After Union *******************************************************************"
for key, data in x.list {
	OutputDebug %  "  " key ": " data.hwnd ": " data.title " (" key ")" 
}

ExitApp
