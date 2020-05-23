; Example script
; Use a GetWindowRect Dll Call to get a RECT structure containing information on the Size of the window
; Use a GetCursorPos Dll Call to get a POINT structure containing mouse position
; Pass bits of each to a MoveWindow Dll Call

#NoEnv
#SingleInstance force

#include <_Struct>
#include <WinStructs>

Gui,+LastFound
Gui,Show,w100 h100									;show window
hwnd:=WinExist()									;get window handle

/*
GetWindowRect
Docs:												https://msdn.microsoft.com/en-us/library/windows/desktop/ms633519%28v=vs.85%29.aspx
Returns a RECT:										https://msdn.microsoft.com/en-us/library/windows/desktop/dd162897(v=vs.85).aspx
A RECT is defined thus in WinStructs:
	static RECT := "
	(
		LONG left;
		LONG top;
		LONG right;
		LONG bottom;
	)"
*/

RECT:=new _Struct(WinStructs.RECT)					;create structure
DllCall("GetWindowRect","Uint",hwnd,"Uint",RECT[])	;get window position
RECT.right  := RECT.right - RECT.left				;Set RECT.right to be the width
RECT.bottom := RECT.bottom - RECT.top				;Set RECT.bottom to be the height

/*
GetCursorPos
Docs:						 						https://msdn.microsoft.com/en-us/library/windows/desktop/ms648390%28v=vs.85%29.aspx
Returns a POINT:									https://msdn.microsoft.com/en-us/library/windows/desktop/dd162805(v=vs.85).aspx
A POINT is defined thus in WinStructs:
	static POINT := "
		(
			LONG x;
			LONG y;
		)"
*/

/*
MoveWindow
Docs:												https://msdn.microsoft.com/en-gb/library/windows/desktop/ms633534(v=vs.85).aspx
*/
POINT := new _Struct(WinStructs.POINT)
While DllCall("GetCursorPos","Uint",POINT[]) && DllCall("MoveWindow","Uint",hwnd,"int",POINT.x,"int",POINT.y,"int",RECT.right,"int",RECT.bottom,"Int",1){
	Sleep, 10
}

return

Esc::
GuiClose:
	Gui,Destroy
	RECT:=""
	ExitApp