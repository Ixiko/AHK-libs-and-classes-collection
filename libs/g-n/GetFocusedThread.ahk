; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=225&start=400
; Author:	Drugwash
; Date:
; for:     	AHK_L

/*


*/

GetFocusedThread(hwnd := 0){
if !hwnd
	return 0	; current thread
tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", NULL)
VarSetCapacity(GTI, sz := 24+6*A_PtrSize, 0)			; GUITHREADINFO struct
NumPut(sz, GTI, 0, "UInt")	; cbSize
if DllCall("GetGUIThreadInfo", "UInt", tid, "Ptr", &GTI)
	if hF := NumGet(GTI, 8+A_PtrSize, "Ptr")
		return DllCall("GetWindowThreadProcessId", "Ptr", hF, "Ptr", NULL)
return 0	; current thread (actually it's an error but we couldn't care less)
}