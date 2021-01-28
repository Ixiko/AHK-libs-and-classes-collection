; ======================================================================================================================
; Function:       LinearGradient
;                 Creates a linear gradient bitmap for a GUI Picture control. 
; AHK-Version:    1.1.05.00 U32
; OS-Versions:    Win Vista 32
; Author:         just me
; Parameter:      HWND        -  Control's HWND
;                 oColors     -  Array of integer RGB color values
;                                At least two colors must be passed, the start and the target color for the gradient
; (Optional)      oPositions  -  Array containing the relative positions of the color values as floating-point values 
;                                between 0.0 (start) and 1.0 (end) in ascending order
;                                Default: "" (or any non-object value)
;                                         Colors are divided automatically according to the number of colors.
;                 D           -  Direction:
;                                0 = horizontal
;                                1 = vertical
;                                2 = diagonal (upper-left -> lower-right)
;                                3 = diagonal (upper-right -> lower-left)
;                                Default: 0
;                 GC          -  Gamma Correction:
;                                0 = no
;                                1 = yes
;                                Default: 0
;                 BW          -  Brush width in pixel
;                                Default: 0 = control's width
;                 BH          -  Brush height in pixel
;                                Default: 0 = control's height
; ======================================================================================================================
LinearGradient(HWND, oColors, oPositions = "", D = 0, GC = 0, BW = 0, BH = 0) {
   ; -------------------------------------------------------------------------------------------------------------------
   ; Windows Constants
   Static SS_BITMAP    := 0xE
   Static SS_ICON      := 0x3
   Static STM_SETIMAGE := 0x172
   Static IMAGE_BITMAP := 0x0
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check Parameters
   If !IsObject(oColors) || (oColors.MaxIndex() < 2) {
      ErrorLevel := "Invalid parameter oColors!"
      Return False
   }
   IC := oColors.MaxIndex()
   If IsObject(oPositions) {
      If (oPositions.MaxIndex() <> IC) {
         ErrorLevel := "Invalid parameter oPositions!"
         Return False
      }
   } Else {
      oPositions := [0.0]
      P := 1.0 / (IC - 1)
      Loop, % (IC - 2)
         oPositions.Insert(P * A_Index)
      oPositions.Insert(1.0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check HWND
   WinGetClass, Class, ahk_id %HWND%
   If (Class != "Static") {
      ErrorLevel := "Class " . Class . " is not supported!"
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check the availability of GDIPlus
   If !DllCall("GetModuleHandle", "Str", "Gdiplus")
      hGDIP := DllCall("LoadLibrary", "Str", "Gdiplus")
   VarSetCapacity(SI, 16, 0)
   Numput(1, SI, "UInt")
   DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
   If (!pToken) {
       ErrorLevel := "GDIPlus could not be started!`nCheck the availability of GDIPlus on your system, please!"
       Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get client rectangle
   VarSetCapacity(RECT, 16, 0)
   DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT)
   W := NumGet(RECT, 8, "Int")
   H := NumGet(RECT, 12, "Int")
   ; -------------------------------------------------------------------------------------------------------------------
   ; Set default parameter values
   If D Not In 0,1,2,3
      D := 0
   If GC Not In 0,1
      GC := 0
   If BW Not Between 1 And W
      BW := W
   If BH Not Between 1 And H
      BH := H
   ; -------------------------------------------------------------------------------------------------------------------
   ; Create a GDI+ bitmap
   DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
         , "Int", 0x26200A, "Ptr", 0, "PtrP", pBitmap)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Create a pointer to the corresponding graphic object
   DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", pBitmap, "PtrP", pGraphics)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Fill the bitmap with a linear gradient
   ; RECTF structure for line brush
   VarSetCapacity(RECTF, 16, 0)
   NumPut(BW, RECTF,  8, "Float")
   NumPut(BH, RECTF, 12, "Float")
   ; Create a linear gradient brush
   DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect", "Ptr", &RECTF
         , "Int", 0, "Int", 0, "Int", D, "Int", 0, "PtrP", pBrush)
   ; Set gamma correction
   DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", pBrush, "Int", GC)
   ; Set line preset blend colors ...
   VarSetCapacity(COLORS, IC * 4, 0)
   O := -4
   For I, V In oColors 
      NumPut(V | 0xFF000000, COLORS, O += 4, "UInt")
   ; ... and positions
   VarSetCapacity(POSITIONS, IC * 4, 0)
   O := -4
   For I, V In oPositions
      NumPut(V, POSITIONS, O += 4, "Float")
   DllCall("Gdiplus.dll\GdipSetLinePresetBlend", "Ptr", pBrush, "Ptr", &COLORS, "Ptr", &POSITIONS, "Int", IC)
   ; Fill the bitmap
   DllCall("Gdiplus.dll\GdipFillRectangle", "Ptr", pGraphics, "Ptr", pBrush
         , "Float", 0, "Float", 0, "Float", W, "Float", H)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Create HBITMAP from bitmap
   DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "Int", 0X00FFFFFF)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Free resources
   DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
   DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush)
   DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", pGraphics)
   ; Shutdown GDI+
   DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
   If (hGDIP)
      DllCall("FreeLibrary", "Ptr", hGDIP)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Set control styles
   Control, Style, -%SS_ICON%, , ahk_id %HWND%
   Control, Style, +%SS_BITMAP%, , ahk_id %HWND%
   ; Assign the bitmap
   SendMessage, STM_SETIMAGE, IMAGE_BITMAP, hBitmap, , ahk_id %HWND%
   ; Done!
   DllCall("Gdi32.dll\DeleteObject", "Ptr", hBitmap)
   Return True
}