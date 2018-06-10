#NoEnv
SetBatchLines, -1
Gui, Margin, 10, 10
Gui, Color, C00000
Gui, Font, s12
Gui, Add, Button, x10 y10 w300 vNormalButton gClick, Normal Button
Gui, Add, Button, vBT1 xp y+10 w300 hwndHBTN vTransButton gClick, Transparent Button
TransButton_SubClass(HBTN)
Gui, Add, Button, vBT2 xp y+10 w300 Default hwndHBTN vDefaultButton gClick, Default Button
TransButton_SubClass(HBTN)
Gui, Add, Button, vBT3 xp y+10 w300 hwndHBTN vDisabledButton gClick +Disabled, Disabled Button
TransButton_SubClass(HBTN)
Gui, Font
Gui, Add, StatusBar
Gui, Show, , Transparent Buttons
Return
GuiClose:
ExitApp
Click:
SB_SetText("  You clicked on " . A_GuiControl . "!")
Return

; ======================================================================================================================
; Namespace:      TransButton
; Function:       Functions for transparent pushbuttons.
; AHK version:    1.1.09.04 (U32)
; Language:       English
; Version:        0.1.00.00/2013-04-27/just me
; Note:           Transparency is only possible for themed windows.
;                 Transparency is faked by drawing the underlying background of the parent window.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; ======================================================================================================================
; Super-global object to store buttons properties
; ======================================================================================================================
Global TransButton_Buttons
; ======================================================================================================================
; TransButton_Subclass() - Installs a window subclass callback for the passed button handle.
; Call this function once for each button you want to have a "transparent" background.
; Parameters:     HBTN  -  Handle (HWND) of the button.
; Return values:  On success: True.
;                 On failure: False.
; ======================================================================================================================
TransButton_Subclass(HBTN) {
   Static SubclassProc := RegisterCallback("TransButton_SubclassProc")
   If !(IsObject(TransButton_Buttons))
      TransButton_Buttons := {}
   If !DllCall("User32.dll\IsWindow", "Ptr", HBTN, "UPtr")
      Return False
   If !(TransButton_SetProperties(HBTN))
      Return False
   If !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HBTN, "Ptr", SubclassProc, "Ptr", HBTN, "Ptr", 0) {
      TransButton_Buttons.Remove(HBTN, "")
      Return False
   }
   TransButton_Buttons.Subclass := SubclassProc
   WinSet, Redraw, , ahk_id %HBTN%
   Return True

}
; ======================================================================================================================
; TransButton_SetProperties()
; Call this function on every change of button properties, such as caption, style, or size.
; This function is called internally from TransButton_Subclass()
; Parameters:     HBTN  -  Handle (HWND) of the button.
; Return values:  On success: True.
;                 On failure: False.
; ======================================================================================================================
TransButton_SetProperties(HBTN) {
   ; Styles
   Static BS_DEFPUSHBUTTON := 0x01, BS_LEFT := 0x0100, BS_RIGHT := 0x0200, BS_CENTER := 0x0300, BS_TOP := 0x0400
        , BS_BOTTOM := 0x0800, BS_VCENTER := 0x0C00, WS_DISABLED := 0x08000000
   ; DrawText() format flags
   Static DT_LEFT := 0x00, DT_TOP := 0x00, DT_CENTER := 0x01, DT_RIGHT := 0x02, DT_VCENTER := 0x04
        , DT_BOTTOM := 0x08, DT_WORDBREAK := 0x10, DT_SINGLELINE := 0x20, DT_NOCLIP := 0x0100, DT_CALCRECT := 0x0400
   Static WM_GETFONT := 0x31
   If !(HTHEME := DllCall("UxTheme.dll\OpenThemeData", "Ptr", HBTN, "WStr", "Button", "Ptr"))
      Return False
   TxColor := DllCall("UxTheme.dll\GetThemeSysColor", "Ptr", HTHEME, "Int", 18, "UInt")
   RcColor := DllCall("UxTheme.dll\GetThemeSysColor", "Ptr", HTHEME, "Int", 17, "UInt")
   HFONT := DllCall("User32.dll\SendMessage", "Ptr", HBTN, "Int", WM_GETFONT, "Ptr", 0, "Ptr", 0)
   VarSetCapacity(CTLRECT, 16, 0)
   DllCall("User32.dll\GetClientRect", "Ptr", HBTN, "Ptr", &CTLRECT)
   HDC := DllCall("User32.dll\GetDC", "Ptr", HBTN, "UPtr")
   VarSetCapacity(TXTRECT, 16, 0)
   DllCall("UxTheme.dll\GetThemeBackgroundContentRect", "Ptr", HTHEME, "Ptr", HDC, "Int", 1, "Int", 1
         , "Ptr", &CTLRECT, "Ptr", &TXTRECT)
   TL := , TT := 
   TR := NumGet(TXTRECT, 8, "Int"), TB := NumGet(TXTRECT, 12, "Int")
   DllCall("User32.dll\ReleaseDC", "Ptr", HBTN, "Ptr", HDC)
   DllCall("UxTheme.dll\CloseThemeData", "Ptr", HTHEME)
   ControlGetText, BtnText, , ahk_id %HBTN%
   ControlGet, Styles, Style, , , ahk_id %HBTN%
   Align := (Styles & BS_CENTER) = BS_CENTER ? DT_CENTER
          : (Styles & BS_CENTER) = BS_RIGHT ? DT_RIGHT
          : (Styles & BS_CENTER) = BS_LEFT ? DT_LEFT
          : DT_CENTER
   Align |= DT_WORDBREAK
   If (Styles & WS_DISABLED)
      TxColor := RcColor
   Else
      RcColor := TxColor
   If (TransButton_Buttons[HBTN].Pen) {
      DllCall("Gdi32.dll\DeleteObject", "Ptr", TransButton_Buttons[HBTN].Pen)
      TransButton_Buttons[HBTN].Pen := 0
   }
   HPEN := DllCall("Gdi32.dll\CreatePen", "Int", 0, "Int", 1, "UInt", RcColor, "UPtr")
   Properties := {}
   Properties.Calc    := True
   Properties.Font    := HFONT
   Properties.Pen     := HPEN
   Properties.Caption := BtnText
   Properties.Styles  := Styles
   Properties.Align   := Align
   Properties.TxColor := TxColor
   Properties.RcColor := RcColor
   Properties.CW      := NumGet(CTLRECT,  8, "Int")
   ProPerties.CH      := NumGet(CTLRECT, 12, "Int")
   Properties.TL      := NumGet(TXTRECT,  0, "Int")
   Properties.TT      := NumGet(TXTRECT,  4, "Int")
   Properties.TR      := NumGet(TXTRECT,  8, "Int")
   Properties.TB      := NumGet(TXTRECT, 12, "Int")
   TransButton_Buttons[HBTN] := Properties
   Return True
}
; ======================================================================================================================
; TransButton_SubclassProc() - Subclass procedure to handle WM_PAINT and WM_DESTROY messages.
; ======================================================================================================================
TransButton_SubclassProc(HWND, Message, wParam, lParam, IdSubclass, RefData) {
   ; -------------------------------------------------------------------------------------------------------------------
   Static WM_DESTROY  := 0x02,   WM_PAINT   := 0x0F
   Static BS_BOTTOM   := 0x0800, BS_VCENTER := 0x0C00
   Static DT_CALCRECT := 0x0400
   Static NullBrush := DllCall("Gdi32.dll\GetStockObject", "Int", 5, "UPtr") ; NULL_BRUSH
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check the message
   If (Message = WM_DESTROY) {
      If (TransButton_Buttons[HWND].Pen)
         DllCall("Gdi32.dll\DeleteObject", "Ptr", TransButton_Buttons[HBTN].Pen)
      TransButton_Buttons.Remove(HWND, "")
      DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", HWND, "Ptr", TransButton_Buttons.SubclassProc, "Ptr", HWND)
      Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", HWND, "UInt", Message, "Ptr", wParam, "Ptr", lParam)
   }
   If (Message <> WM_PAINT)
      Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", HWND, "UInt", Message, "Ptr", wParam, "Ptr", lParam)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Prepare drawing
   Critical
   Btn := TransButton_Buttons[HWND]
   CW := Btn.CW, CH := Btn.CH, TL := Btn.TL, TT := Btn.TT, TR := Btn.TR, TB := Btn.TB
   VarSetCapacity(PS, (4 * 16) + (2 * (A_PtrSize - 4)), 0) ; PAINTSTRUCT structure
   HDC := DllCall("User32.dll\BeginPaint", "Ptr", HWND, "Ptr", &PS, "Ptr")
   ; -------------------------------------------------------------------------------------------------------------------
   ; Draw the parent window background within the button
   DllCall("UxTheme.dll\DrawThemeParentBackground", "Ptr", HWND, "Ptr", HDC, "Ptr", &PS + A_PtrSize + 4)
   ; -------------------------------------------------------------------------------------------------------------------
   ; GDI RoundRect() draws the border
   DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", NullBrush, "UPtr")
   DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "Ptr", Btn.Pen, "UPtr")
   DllCall("Gdi32.dll\RoundRect", "Ptr", HDC, "Int", 1, "Int", 1, "Int", CW - 1, "Int", CH - 1, "Int", 5, "Int", 5)
   ; -------------------------------------------------------------------------------------------------------------------
   ; GDI DrawText() draws the caption
   DllCall("Gdi32.dll\SelectObject", "Ptr", HDC, "UInt", Btn.Font)
   DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "Int", 1)
   DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", Btn.TxColor)
   VarSetCapacity(RECT, 16, 0)
   If (Btn.Calc) {
      VC := Btn.Styles & BS_VCENTER
      If (VC = BS_VCENTER) Or (VC = BS_BOTTOM) OR (VC = 0) {
         NumPut(TR - TL, RECT, 8, "Int"), NumPut(TB - TT, RECT, 12, "Int")
         DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Btn.Caption, "Int", -1, "Ptr", &RECT
                                      , "UInt", Btn.Align | DT_CALCRECT)
         H := NumGet(RECT, 12, "Int")
         If (VC = BS_BOTTOM)
            TT := TB - H
         Else If (H < CH)
            TT := (CH - H) // 2
         Btn.TT := TT
      }
      Btn.Calc := False
   }
   NumPut(TL, RECT, 0, "Int"), NumPut(TT, RECT, 4, "Int"), NumPut(TR, RECT, 8, "Int"), NumPut(TB, RECT, 12, "Int")
   DllCall("User32.dll\DrawText", "Ptr", HDC, "Str", Btn.Caption, "Int", -1, "Ptr", &RECT, "UInt", Btn.Align)
   ; -------------------------------------------------------------------------------------------------------------------
   ; Done!
   DllCall("User32.dll\EndPaint", "Ptr", HWND, "Ptr", &PAINTSTRUCT)
   Return 0
}