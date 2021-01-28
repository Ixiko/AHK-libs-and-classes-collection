; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=65170&hilit=is+overlapped
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

IsWindowCloaked(hwnd) {
    return DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "int", 14, "int*", cloaked, "int", 4) >= 0
        && cloaked
}