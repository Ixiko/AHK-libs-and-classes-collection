#include %A_ScriptDir%\..\..\lib\Windy\WindLy.ahk
#include %A_ScriptDir%\..\..\lib\Windy\Const_WinUser.ahk
#include %A_ScriptDir%\..\..\lib\DbgOut.ahk

OutputDebug DBGVIEWCLEAR

OutputDebug % "******** All Windows **************************************************************************"
x := new WindLy()
for key, data in x.Snapshot() {  ; access the window list directly by function call
	OutputDebug % data.hwnd ": " data.title "`n" 
}

OutputDebug % "******** removeNonExisting *********************************************************************"
MsgBox % "Close any window and watch, if the window is removed from the list"
x.removeNonExisting()

OutputDebug % "******** On Monitor 1 *************************************************************************"
x.byMonitorId(1)
for key, data in x.list { ; access the window list via member variable
	OutputDebug % data.hwnd ": " data.title "`n" 
}

OutputDebug % "******** Minimized ****************************************************************************"
ww := x.byStyle(WS.MINIMIZE)
for key, data in ww {  ; access the window list via helper variable
	OutputDebug % data.hwnd ": " data.title "`n" 
}


 
ExitApp