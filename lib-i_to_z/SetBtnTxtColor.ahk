; ===========================================================================================================
; AHK 1.1.05+
; ===========================================================================================================
; Function:          "Draws" colored captions on pushbuttons.
; AHK version:       1.1.05+ (U32)
; Language:          English
; Tested on:         Win XPSP3 (ANSI), VistaSP2 (U32), 7 (U64)
; Version:           0.1.00.00/2012-04-05/just me
; Credits:           THX tic     for GDIP.AHK     : http://www.autohotkey.com/forum/post-198949.html
;                    THX tkoi    for ILBUTTON.AHK : http://www.autohotkey.com/forum/topic40468.html
;                    THX Lexikos for AHK_L
; Remarks:           The look of the colored caption depends on the font, its size and its weight.
; ===========================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ===========================================================================================================
; ===========================================================================================================
; FUNCTION SetBtnTxtColor()
; ===========================================================================================================
SetBtnTxtColor(HWND, TxtColor) {
   Static HTML := {BLACK: "000000", GRAY: "808080", SILVER: "C0C0C0", WHITE: "FFFFFF", MAROON: "800000"
                , PURPLE: "800080", FUCHSIA: "FF00FF", RED: "FF0000", GREEN:  "008000", OLIVE:  "808000"
                , YELLOW: "FFFF00", LIME: "00FF00", NAVY: "000080", TEAL: "008080", AQUA: "00FFFF", BLUE: "0000FF"}
   Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x4, BS_GROUPBOX := 0x7, BS_AUTORADIOBUTTON := 0x9
        , BS_LEFT := 0x100, BS_RIGHT := 0x200, BS_CENTER := 0x300, BS_TOP := 0x400, BS_BOTTOM := 0x800
        , BS_VCENTER := 0xC00, BS_BITMAP := 0x0080, SA_LEFT := 0x0, SA_CENTER := 0x1, SA_RIGHT := 0x2
        , WM_GETFONT := 0x31, BCM_SETIMAGELIST := 0x1602, IMAGE_BITMAP := 0x0, BITSPIXEL := 0xC
        , RCBUTTONS := BS_CHECKBOX | BS_RADIOBUTTON | BS_AUTORADIOBUTTON
        , BUTTON_IMAGELIST_ALIGN_LEFT := 0, BUTTON_IMAGELIST_ALIGN_RIGHT := 1, BUTTON_IMAGELIST_ALIGN_CENTER := 4
   ; -------------------------------------------------------------------------------------------------------------------
   ErrorLevel := ""
   GDIPDll := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "Ptr")
   VarSetCapacity(SI, 24, 0)
   Numput(1, SI)
   DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", GDIPToken, "Ptr", &SI, "Ptr", 0)
   If (!GDIPToken) {
       ErrorLevel := "GDIPlus could not be started!`n`nSetBtnTxtColor won't work!"
       Return False
   }
   If !DllCall("User32.dll\IsWindow", "Ptr", HWND) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Invalid parameter HWND!"
      Return False
   }
   WinGetClass, BtnClass, ahk_id %HWND%
   ControlGet, BtnStyle, Style, , , ahk_id %HWND%
   If (BtnClass != "Button") || ((BtnStyle & 0xF ^ BS_GROUPBOX) = 0) || ((BtnStyle & RCBUTTONS) > 1) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "You can use SetBtnTxtColor only for PushButtons!"
      Return False
   }
   PFONT := 0
   DC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
   BPP := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", BITSPIXEL)
   HFONT := DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", WM_GETFONT, "Ptr", 0, "Ptr", 0, "Ptr")
   DllCall("Gdi32.dll\SelectObject", "Ptr", DC, "Ptr", HFONT)
   DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", DC, "PtrP", PFONT)
   DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", DC)
   If !(PFONT) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's font!"
      Return False
   }
   VarSetCapacity(RECT, 16, 0)
   If !(DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT)) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's rectangle!"
      Return False
   }
   W := NumGet(RECT,  8, "Int"), H := NumGet(RECT, 12, "Int")
   BtnCaption := ""
   Len := DllCall("User32.dll\GetWindowTextLength", "Ptr", HWND) + 1
   If (Len > 1) {
      VarSetCapacity(BtnCaption, Len * (A_IsUnicode ? 2 : 1), 0)
      If !(DllCall("User32.dll\GetWindowText", "Ptr", HWND, "Str", BtnCaption, "Int", Len)) {
         GoSub, CreateImageButton_GDIPShutdown
         ErrorLevel := "Couldn't get button's caption!"
         Return False
      }
      VarSetCapacity(BtnCaption, -1)
   } Else {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's caption!"
      Return False
   }
   If HTML.HasKey(TxtColor)
      TxtColor := HTML[TxtColor]
   DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
         , "UInt", 0x26200A, "Ptr", 0, "PtrP", PBITMAP)
   DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", PBITMAP, "PtrP", PGRAPHICS)
   DllCall("Gdiplus.dll\GdipStringFormatGetGenericTypographic", "PtrP", PFORMAT)
   HALIGN := (BtnStyle & BS_CENTER) = BS_CENTER ? SA_CENTER : (BtnStyle & BS_CENTER) = BS_RIGHT ? SA_RIGHT
           : (BtnStyle & BS_CENTER) = BS_Left ? SA_LEFT : SA_CENTER
   DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", PFORMAT, "Int", HALIGN)
   VALIGN := (BtnStyle & BS_VCENTER) = BS_TOP ? 0 : (BtnStyle & BS_VCENTER) = BS_BOTTOM ? 2 : 1
   DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", PFORMAT, "Int", VALIGN)
   DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", PGRAPHICS, "Int", 3)
   NumPut(4, RECT, 0, "Float"), NumPut(2, RECT, 4, "Float")
   NumPut(W - 8, RECT, 8, "Float"), NumPut(H - 4, RECT, 12, "Float")
   DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", "0xFF" . TxtColor, "PtrP", PBRUSH)
   DllCall("Gdiplus.dll\GdipDrawString", "Ptr", PGRAPHICS, "WStr", BtnCaption, "Int", -1, "Ptr", PFONT, "Ptr", &RECT
         , "Ptr", PFORMAT, "Ptr", PBRUSH)
   DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", PBITMAP, "PtrP", HBITMAP, "UInt", 0X00FFFFFF)
   DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBITMAP)
   DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
   DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", PFORMAT)
   DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", PGRAPHICS)
   DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", PFONT)
   HIL := DllCall("Comctl32.dll\ImageList_Create", "UInt", W, "UInt", H, "UInt", BPP, "Int", 1, "Int", 0, "Ptr")
   DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", HBITMAP, "Ptr", 0)
   VarSetCapacity(BIL, 20 + A_PtrSize, 0)
   NumPut(HIL, BIL, 0, "Ptr"), Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, A_PtrSize + 16, "UInt")
   GuiControl, , %HWND%
   SendMessage, BCM_SETIMAGELIST, 0, 0, , ahk_id %HWND%
   SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
   GoSub, CreateImageButton_FreeBitmaps
   GoSub, CreateImageButton_GDIPShutdown
   Return True
   ; -------------------------------------------------------------------------------------------------------------------
   CreateImageButton_FreeBitmaps:
      DllCall("Gdi32.dll\DeleteObject", "Ptr", HBITMAP)
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   CreateImageButton_GDIPShutdown:
      DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GDIPToken)
      DllCall("Kernel32.dll\FreeLibrary", "Ptr", GDIPDll)
   Return
}