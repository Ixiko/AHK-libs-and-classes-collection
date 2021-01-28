; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=7947
; Author:
; Date:
; for:     	AHK_L

/*


*/

WinGetClientPos( Hwnd ) {
	VarSetCapacity( size, 16, 0 )
	DllCall( "GetClientRect", "Ptr", Hwnd, "Ptr", &size )		;full client size - x,y always 0
	DllCall( "ClientToScreen", "Ptr", Hwnd, "Ptr", &size )		;x,y co-oordinates only
	x := NumGet( size, 0, "Int"), y := NumGet( size, 4, "Int")
	w := NumGet( size, 8, "Int" ), h := NumGet( size, 12, "Int" )
	return { X: x, Y: y, W: w, H: h }
}