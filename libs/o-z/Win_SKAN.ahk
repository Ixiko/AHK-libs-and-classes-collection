; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77235&hilit=WinPos
; Author:	SKAN
; Date:
; for:     	AHK_L
; A set functions to move a DWM composed (or not) windows.
; Note: Windows are moved/resized based on their apparent position/dimensions rather than actual values.


/*	WinPos_Get(hWnd)

	Returns X,Y,W,H as an Object. This function is a an alternative to WinGetPos command.

	Example:
	The following example shows the apparent position as well as the adjustments applied to derive X,Y,W,H

	Gui +hWndhWnd
	Gui, Show, x0 y0 w200 h200
	G := WinPos_Get(hWnd)
	Msgbox %  G.X  . A_Tab . G.Y  . A_Tab . G.W  . A_Tab . G.H . "`n"
		   .  G.XA . A_Tab . G.YA . A_Tab . G.WA . A_Tab . G.HA

*/
WinPos_Get(hWnd) {                                                	; ver 0.50 by SKAN on D36A/D36C @ tiny.cc/winpos
Local N:=VarSetCapacity(R,16,0), X1,Y1,W1,H1, X2,Y2,W2,H2, XA,YA,WA,HA
  If !(DllCall("GetWindowRect", "Ptr",hWnd, "Ptr",&R) && NumGet(R,12,"Int")>0)
    Return
  X1:=NumGet(R,0,"Int"), Y1:=NumGet(R,4,"Int"), W1:=NumGet(R,8,"Int")-X1,  H1:=NumGet(R,12,"Int")-Y1
  If !DllCall("dwmapi\DwmGetWindowAttribute", "Ptr",hWnd, "Int",9, "Ptr",&R, "Int",16)=0
    Return {"X":X1, "Y":Y1, "W":W1, "H":H1, "XA":0, "YA":0, "WA":0, "HA":0}
  X2:=NumGet(R,0,"Int"), Y2:=NumGet(R,4,"Int"), W2:=NumGet(R,8,"Int")-X2,  H2:=NumGet(R,12,"Int")-Y2
  XA:=X2-X1, YA:=Y2-Y1, WA:=W2-W1, HA:=H2-H1
Return {"X":X1+XA, "Y":Y1+YA, "W":W1+WA, "H":H1+HA, "XA":X1-X2, "YA":Y1-Y2, "WA":W1-W2, "HA":H1-H2}
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*  WinPos_Set(hWnd, X, Y, W, H)

	Moves/resizes a window and returns a true when successful. This function is an alternative to WinMove command.
	You may not use X,Y,W,H returned by WinGetPos command.. Use WinPos_Get() instead.

	Example:
	Run, Notepad.exe
	WinWait ahk_class Notepad
	hWnd := WinExist()
	WinPos_Set(hWnd, 0, 0, 400, 400)

*/
WinPos_Set(hWnd, X:="", Y:="", W:="", H:="") {      	; ver 0.50 by SKAN on D36A/D36C @ tiny.cc/winpos
Local
  If !G:=WinPos_Get(hWnd)
    Return 0
  X:=X!="" ? X : G.X, Y:=Y!="" ? Y : G.Y, W:=W!="" ? W : G.W, H:=H!="" ? H : G.H
Return DllCall("MoveWindow","Ptr",hWnd, "Int",X+G.XA,"Int",Y+G.YA,"Int",W+G.WA,"Int",H+G.HA,"Int",1)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/* WinPos_OffEdge(hWnd, XOffset, YOffset, MonitorNumber)

	Moves a window relative to an edge of a monitor. Returns true when successful.
	If XOffset or YOffset is zero or greater, they are an offset from left,top edges.
	If XOffset or YOffset is a negative number, they are an offset from bottom, right edges.
	The windows will be centered on the respective axis if XOffset or YOffset or both are omitted.
	If MonitorNumber is omitted, window move will default to Primary monitor.

	XOffset,YOffset for common edges
	Image

	Example:
	WinPos_OffEdge() is API driven and will move a hidden window. One problem in Windows 10 is that DWM does not compose hidden windows.
	It applies effects only when window is shown. Therefore, a window has to be visible for correct calculation.
	The following example demonstrates how to keep a GUI pseudo-hidden until it is moved.


	#NoEnv
	#SingleInstance, Force
	DetectHiddenWindows, On
	Gui +hwndhGui
	WinSet, Trans, 1,   ahk_id %hGui%
	DetectHiddenWindows, Off
	Gui, Show, W200 h200
	WinPos_OffEdge(hGui, -1,-1)
	WinSet, Trans, 255, ahk_id %hGui%

*/
WinPos_OffEdge(hWnd, X:="",Y:="", M:="") {          	; ver 0.50 by SKAN on D36A/D36C @ tiny.cc/winpos
Local
  SysGet, M, MonitorWorkArea, %M%
  If !(G:=WinPos_Get(hWnd)) || (MLeft="")
    Return 0
  VarSetCapacity(R,48,0)
  DllCall("GetWindowRect","Ptr",WinExist("ahk_class Shell_TrayWnd"), "Ptr",&R)
  DllCall("SetRect", "Ptr",&R+16, "Int",MLeft, "Int",MTop, "Int",MRight-MLeft, "Int",MBottom-MTop)
  DllCall("SubtractRect", "Ptr",&R+32, "Ptr",&R+16, "Ptr",&R)
  L:=NumGet(R,32,"Int"), T:=NumGet(R,36,"Int"), R:=NumGet(R,40,"Int"), B:=NumGet(R,44,"Int")
  X:=X="" ? L+((R-L)/2)-(G.W/2) : X<0 ? R-G.W : L+X,  W:=G.W
  Y:=Y="" ? T+((B-T)/2)-(G.H/2) : Y<0 ? B-G.H : T+Y,  H:=G.H
Return DllCall("MoveWindow","Ptr",hWnd, "Int",X+G.XA,"Int",Y+G.YA,"Int",W+G.WA,"Int",H+G.HA,"Int",1)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
