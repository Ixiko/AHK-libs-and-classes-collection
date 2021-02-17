; Title:
; Link:   	https://autohotkey.com/board/topic/92043-problems-with-flashwindowex/
; Author:
; Date:
; for:     	AHK_L

/*

;https://docs.microsoft.com/fr-fr/windows/win32/api/winuser/ns-winuser-flashwinfo
; example : FlashWindowEx(hWnd, 1, 3, 0)

*/

FlashWindowEx(hWnd := 0, dwFlags := 0, uCount := 0, dwTimeout := 0) {
   Static A64 := (A_PtrSize = 8 ? 4 : 0) ; alignment for pointers in 64-bit environment
   Static cbSize := 4 + A64 + A_PtrSize + 4 + 4 + 4 + A64
   VarSetCapacity(FLASHWINFO, cbSize, 0) ; FLASHWINFO structure
   Addr := &FLASHWINFO
   Addr := NumPut(cbSize,    Addr + 0, 0,   "UInt")
   Addr := NumPut(hWnd,      Addr + 0, A64, "Ptr")
   Addr := NumPut(dwFlags,   Addr + 0, 0,   "UInt")
   Addr := NumPut(uCount,    Addr + 0, 0,   "UInt")
   Addr := NumPut(dwTimeout, Addr + 0, 0,   "Uint")
   Return DllCall("User32.dll\FlashWindowEx", "Ptr", &FLASHWINFO, "UInt")
}
© 2021 GitHub, Inc.