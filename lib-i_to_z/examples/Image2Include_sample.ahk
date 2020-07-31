#NoEnv
#Include CreateBitmap_ImgProps_png.ahk ; change the name to what you need
SetBatchLines, -1
T := A_TickCount
HBITMAP := CreateBitmap_ImgProps_png() ; change the name to what you need
H := Bitmap_GetHeight(HBITMAP)
W := Bitmap_GetWidth(HBITMAP)
; ----------------------------------------------------------------------------------------------------------------------
Gui, Margin, 0, 0
Gui, Add, Text, x0 y0 w%W% h%H% hwndHPic1
Bitmap_SetImage(HPic1, HBITMAP)
T := A_TickCount - T
Gui, Show, , Included Image - %T% ms
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
GuiEscape:
ExitApp
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
; ----------------------------------------------------------------------------------------------------------------------
; Associates a new bitmap with a static control.
; Parameters:     hCtrl    -  Handle to the GUI control (Pic or Text).
;                 hBitmap  -  Handle to the bitmap to associate with the GUI control.
; Return value:   Handle to the image previously associated with the GUI control, if any; otherwise, NULL.
; ----------------------------------------------------------------------------------------------------------------------
Bitmap_SetImage(hCtrl, hBitmap) {
   ; STM_SETIMAGE = 0x172, IMAGE_BITMAP = 0x00, SS_BITMAP = 0x0E
   WinSet, Style, +0x0E, ahk_id %hCtrl%
   SendMessage, 0x172, 0x00, %hBitmap%, , ahk_id %hCtrl%
   Return ErrorLevel
}
