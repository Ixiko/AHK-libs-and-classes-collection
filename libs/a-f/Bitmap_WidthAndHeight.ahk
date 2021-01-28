; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=44115
; Author:
; Date:
; for:     	AHK_L

/*


*/

; ----------------------------------------------------------------------------------------------------------------------
; Returns the width of a bitmap.
; ----------------------------------------------------------------------------------------------------------------------
Bitmap_GetWidth(hBitmap) {
   Static Size := (4 * 5) + A_PtrSize + (A_PtrSize - 4)
   VarSetCapacity(BITMAP, Size, 0)
   DllCall("Gdi32.dll\GetObject", "Ptr", hBitmap, "Int", Size, "Ptr", &BITMAP, "Int")
   Return NumGet(BITMAP, 4, "Int")
}
; ----------------------------------------------------------------------------------------------------------------------
; Returns the height of a bitmap.
; ----------------------------------------------------------------------------------------------------------------------
Bitmap_GetHeight(hBitmap) {
   Static Size := (4 * 5) + A_PtrSize + (A_PtrSize - 4)
   VarSetCapacity(BITMAP, Size, 0)
   DllCall("Gdi32.dll\GetObject", "Ptr", hBitmap, "Int", Size, "Ptr", &BITMAP, "Int")
   Return NumGet(BITMAP, 8, "Int")
}