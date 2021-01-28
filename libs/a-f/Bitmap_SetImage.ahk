; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=44115
; Author:
; Date:
; for:     	AHK_L

/*


*/

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
   DllCall("DeleteObject", "ptr", ErrorLevel)		;  Delete Objects for prevent memory leak
   DllCall("DeleteObject", "Uint", hBitmap)
   Return ErrorLevel
}