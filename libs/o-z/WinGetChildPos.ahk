; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=7947
; Author:
; Date:
; for:     	AHK_L

/*
	I searched and searched but just could not find what I was looking for so I made it myself. The closest I came was this thread.
	Get the position of a child window in relation to it parent. Also returns the size of the child window. Works on windows with or without captions.

*/

WinGetChildPos( childHwnd, parentHwnd ) {
	VarSetCapacity( points, 16, 0 )
	DllCall( "GetWindowRect", "Ptr", childHwnd, "Ptr", &points )
	DllCall( "MapWindowPoints", "Ptr", NULL, "Ptr", parentHwnd, "Ptr", &points, "Uint", 2 )	; NULL assumes --> Hwnd of Desktop --> DllCall( "GetDesktopWindow" )
	x := NumGet( points, 0, "Int" ), y := NumGet( points, 4, "Int" )
	w := NumGet( points, 8, "Int" ) - x, h := NumGet( points, 12, "Int" ) - y
	return { X: x, Y: y, W: w, H: h }
}