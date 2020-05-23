; ======================================================================================================================
; Namespace:      TransparentListBox
; AHK version:    AHK 1.1.13.00
; Function:       Helper object for transparent ListBoxes
; Language:       English
; Tested on:      Win XP (U32) & Win7 x64 (U64)
; Version:        0.1.00.00/2013-10-03/just me - Initial release.
; ======================================================================================================================
; CLASS TransparentListBox
;
; The class provides transparent background for ListBox controls. The whole stuff is done by subclassing the control.
;
; On creation via 'TLB := New TranparentListBox' you have to pass the HWNDs of the ListBox and the underlying control
; or window. Additionally you may pass a text color and a seperate color to draw selected items with. Colors have to
; be passed as RGB integer values.
;
; After you've changed the content or size of the ListBox, or if you want to change the text or selection color, you
; have to call 'TLB.Update()' once, passing the new color values if desired. Thw whole action should be enclosed by
; two calls of 'TLB.SetRedraw(False/True)' to avoid flickering as far as possible.
;
; Due to the complex way ListBoxes do their scrolling not all options of a common ListBox are supported.
; You have to keep in mind the following restrictions:
; - The new object instance has to be created before the Gui is shown.
; - The ListBox must not have a horizontal scroll bar (because I haven't a clue how to do the scrolling).
; - The Multi(select) option is not supported as yet (but it may be feasible).
; - Scrolling is not 'smooth'.
; ======================================================================================================================
Class TransparentListBox {
   ; -------------------------------------------------------------------------------------------------------------------
   ; Constructor
   ; -------------------------------------------------------------------------------------------------------------------
   __New(HLB, HBG, TxtColor := "", SelColor := "", SelBkGnd := "", SelBkTrans := 255) {
      ; ----------------------------------------------------------------------------------------------------------------
      ; HLB        : HWND of the ListBox.
      ; HBG        : HWND of the control or Gui containing the background.
      ; TxtColor   : Optional - Text color (RGB integer value, e.g. 0xRRGGBB).
      ; SelColor   : Optional - Selected text color (RGB integer value, e.g. 0xRRGGBB).
      ; SelBkGnd   : Optional - Color of the selection rectangel (RGB integer value, e.g. 0xRRGGBB).
      ; SelBkTrans : Optional - Transparency of the selection rectangle (0 - 255).
      ; ----------------------------------------------------------------------------------------------------------------
      Static LB_GETCOUNT := 0x018B, LB_GETITEMRECT := 0x0198, WM_GETFONT := 0x0031
      This.HLB := HLB
      This.HBG := HBG
      This.Parent := DllCall("User32.dll\GetParent", "Ptr", HLB, "UPtr")
      This.CtrlID := DllCall("User32.dll\GetDlgCtrlID", "Ptr", HLB, "UPtr")
      HDC := DllCall("User32.dll\GetDC", "Ptr", HLB, "UPtr")
      If (TxtColor <> "")
         This.TxtColor := ((TxtColor >> 16) & 0xFF) | (TxtColor & 0x00FF00) | ((TxtColor & 0xFF) << 16)
      Else
         This.TxtColor := DllCall("Gdi32.dll\GetTextColor", "Ptr", HDC, "UInt")
      If (SelColor <> "")
         This.SelColor := ((SelColor >> 16) & 0xFF) | (SelColor & 0x00FF00) | ((SelColor & 0xFF) << 16)
      If (SelBkGnd <> "") {
         This.SelBkGnd := ((SelBkGnd >> 16) & 0xFF) | (SelBkGnd & 0x00FF00) | ((SelBkGnd & 0xFF) << 16)
         This.SelBkTrans := (SelBkTrans & 0xFF)
      }
      DllCall("User32.dll\ReleaseDC", "Ptr", HLB, "Ptr", HDC)
      VarSetCapacity(RECT, 16, 0)
      SendMessage, %LB_GETITEMRECT%, 0, % &RECT, , ahk_id %HLB%
      This.ItemWidth := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")
      This.ItemHeight := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")
      SendMessage, %LB_GETCOUNT%, 0, 0, , ahk_id %HLB%
      This.ItemCount := ErrorLevel
      SendMessage, %WM_GETFONT%, 0, 0, , ahk_id %HLB%
      This.Font := ErrorLevel
      ControlGet, Content, List, , , ahk_id %HLB%
      This.Items := StrSplit(Content, "`n")
      This.HasBackground := False
      This.TopIndex := This.CurSel := -1
      This.Drawing := True
      VarSetCapacity(SI, 28, 0) ; SCROLLINFO
      NumPut(28, SI, 0, "UInt") ; cbSize
      NumPut(3, SI, 4, "UInt")  ; fMask = SIF_RANGE | SIF_PAGE
      DllCall("User32.dll\GetScrollInfo", "Ptr", HLB, "Int", 1, "Ptr", &SI)
      This.SIMin := NumGet(SI, 8, "Int")    ; nMin
      This.SIMax := NumGet(SI, 12, "Int")   ; nMax
      This.SIPage := NumGet(SI, 16, "UInt") ; nPage
      SCCB := RegisterCallback("TransparentListBox.SubClassCallback")
      DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HLB, "Ptr", SCCB, "Ptr", HLB, "Ptr", &This)
      This.SCCB := SCCB
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Destructor
   ; -------------------------------------------------------------------------------------------------------------------
   __Delete() {
      Static SRCCOPY := 0x00CC0020
      If (This.BMPDC) {
         BGDC := DllCall("User32.dll\GetDC", "Ptr", This.HBG, "UPtr")
         DllCall("Gdi32.dll\BitBlt", "Ptr", BGDC, "Int", This.Left, "Int", This.Top, "Int", This.Width
                                   , "Int", This.Height, "Ptr", This.BMPDC, "Int", 0, "Int", 0, "UInt", SRCCOPY)
         DllCall("User32.dll\ReleaseDC", "Ptr", This.HBG, "Ptr", BGDC)
         DllCall("Gdi32.dll\DeleteDC", "Ptr", This.BMPDC)
         DllCall("Gdi32.dll\DeleteObject", "Ptr", This.HBMP)
         This.BMPDC := This.HBMP := 0
      }
      If (This.SELDC) {
         DllCall("Gdi32.dll\DeleteDC", "Ptr", This.SELDC)
         DllCall("Gdi32.dll\DeleteObject", "Ptr", This.HSEL)
      }
      If (This.HLB) {
         DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", This.HLB, "Ptr", This.SCCB, "Ptr", This.HLB)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Subclass callback function - for internal use only
   ; -------------------------------------------------------------------------------------------------------------------
   SubClassCallback(uMsg, wParam, lParam, IdSubclass, RefData) {
      Critical 100
      hWnd := This ; first parameter 'hWnd' is passed as 'This'
      Return Object(RefData).SubClassProc(hWnd, uMsg, wParam, lParam)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Subclassproc - for internal use only
   ; -------------------------------------------------------------------------------------------------------------------
   SubClassProc(hWnd, uMsg, wParam, lParam) {
      Static LB := {GETCOUNT: 0x018B, GETCURSEL: 0x0188, GETITEMRECT: 0x0198, GETTEXT: 0x0189,GETTEXTLEN: 0x018A
                  , GETTOPINDEX: 0x018E, ITEMFROMPOINT: 0x01A9, SETCURSEL: 0x0186}
      Static LBN := {SELCHANGE: 1, DBLCLK: 2}
      Static WM := {DESTROY: 0x0002, DRAWITEM: 0x002B, LBUTTONDBLCLK: 0x0203, ERASEBKGND: 0x0014, HSCROLL: 0x0114
                  , KEYDOWN: 0x0100, KILLFOCUS: 0x0008, LBUTTONDOWN: 0x0201, LBUTTONUP: 0x0202, MOUSEWHEEL: 0x020A
                  , PAINT: 0x000F, SETFOCUS: 0x0007, SETREDRAW: 0x000B, VSCROLL: 0x0115}
      Static VK := {DOWN: 0x28, END: 0x23, HOME: 0x24, NEXT: 0x22, PRIOR: 0x21, UP: 0x26
                  , 0x21: 1, 0x22: 1, 0x23: 1, 0x24: 1, 0x26: 1, 0x28: 1}
      Static SRCCOPY := 0x00CC0020
      Static DrawingMsg := ""
      ; ----------------------------------------------------------------------------------------------------------------
      ; Painting
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_PAINT message
      If (uMsg = WM.PAINT) {
         VarSetCapacity(PAINTSTRUCT, A_PtrSize + (4 * 7) + 32 + (A_PtrSize - 4), 0)
         LBDC := DllCall("USer32.dll\BeginPaint", "Ptr", This.HLB, "Ptr", &PAINTSTRUCT, "UPtr")
         SendMessage, % LB.GETCURSEL, 0, 0, , ahk_id %hWnd%
         CurSel := ErrorLevel
         SendMessage, % LB.GETTOPINDEX, 0, 0, , ahk_id %hWnd%
         TopIndex := ErrorLevel
         This.TopIndex := TopIndex
         This.CurSel := CurSel
         DllCall("Gdi32.dll\BitBlt", "Ptr", LBDC, "Int", 0, "Int", 0, "Int", This.Width, "Int", This.Height
                                   , "Ptr", This.BMPDC, "Int", 0, "Int", 0, "UInt", SRCCOPY)
         HFONT := DllCall("Gdi32.dll\SelectObject", "Ptr", LBDC, "Ptr", This.Font, "UPtr")
         DllCall("Gdi32.dll\SetBkMode", "Ptr", LBDC, "Int", 1) ; TRANSPARENT
         VarSetCapacity(RECT, 16, 0)
         SendMessage, % LB.GETITEMRECT, %TopIndex%, &RECT, , ahk_id %hWnd%
         While (TopIndex < This.ItemCount) && (NumGet(RECT, 12, "Int") <= This.Height) {
            If (This.SELDC) && (TopIndex = CurSel) {
               L := NumGet(RECT, 0, "Int"), T := NumGet(RECT, 4, "Int")
               W := NumGet(RECT, 8, "Int") - L, H := NumGet(RECT, 12, "Int") - T
               If (This.SelBkTrans = 255)
                  DllCall("Gdi32.dll\BitBlt", "Ptr", LBDC, "Int", L, "Int", T, "Int", W, "Int", H
                                            , "Ptr", This.SELDC, "Int", 0, "Int", 0, "UInt", SRCCOPY)
               Else
                  DllCall("Gdi32.dll\GdiAlphaBlend", "Ptr", LBDC, "Int", L, "Int", T, "Int", W, "Int", H
                                                   , "Ptr", This.SELDC, "Int", 0, "Int", 0, "Int", W, "Int", H
                                                   , "UInt", (This.SelBkTrans << 16))
            }
            Txt := This.Items[TopIndex + 1], Len := StrLen(Txt)
            TextColor := (TopIndex = CurSel ? This.SelColor : This.TxtColor)
            DllCall("Gdi32.dll\SetTextColor", "Ptr", LBDC, "UInt", TextColor)
            NumPut(NumGet(RECT, 0, "Int") + 3, RECT, 0, "Int")
            DllCall("User32.dll\DrawText", "Ptr", LBDC, "Ptr", &Txt, "Int", Len, "Ptr", &RECT, "UInt", 0x0840)
            NumPut(NumGet(RECT, 0, "Int") - 3, RECT, 0, "Int")
            DllCall("User32.dll\OffsetRect", "Ptr", &RECT, "Int", 0, "Int", This.ItemHeight)
            TopIndex++
         }
         DllCall("Gdi32.dll\SelectObject", "Ptr", LBDC, "Ptr", HFONT, "UPtr")
         DllCall("User32.dll\EndPaint", "Ptr", &PAINTSTRUCT)
         Return 0
      }
      ; WM_ERASEBKGND message
      If (uMsg = WM.ERASEBKGND) {
         If (!This.HasBackground) { ; processed once after creation/update
            VarSetCapacity(RECT, 16, 0)
            DllCall("User32.dll\GetClientRect", "Ptr", This.HLB, "Ptr", &RECT)
            This.Width := W := NumGet(RECT, 8, "Int")
            This.Height := H := NumGet(RECT, 12, "Int")
            DllCall("User32.dll\ClientToScreen", "Ptr", This.HLB, "Ptr", &RECT)
            DllCall("User32.dll\ScreenToClient", "Ptr", This.HBG, "Ptr", &RECT)
            This.Left := L := NumGet(RECT, 0, "Int")
            This.Top := T := NumGet(RECT, 4, "Int")
            BGDC := DllCall("User32.dll\GetDC", "Ptr", This.HBG, "UPtr")
            BMPDC := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr", BGDC, "UPtr")
            HBMP := DllCall("Gdi32.dll\CreateCompatibleBitmap", "Ptr", BGDC, "Int", W, "Int", H, "UPtr")
            DllCall("Gdi32.dll\SelectObject", "Ptr", BMPDC, "Ptr", HBMP)
            DllCall("Gdi32.dll\BitBlt", "Ptr", BMPDC, "Int", 0, "Int", 0, "Int", W, "Int", H
                                      , "Ptr", BGDC, "Int", L, "Int", T, "UInt", SRCCOPY)
            If (This.SelBkGnd <> "") {
               SELDC := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr", BGDC, "UPtr")
               HSEL := DllCall("Gdi32.dll\CreateCompatibleBitmap", "Ptr", BGDC, "Int", This.ItemWidth
                                                                 , "Int", This.ItemHeight, "UPtr")
               DllCall("Gdi32.dll\SelectObject", "Ptr", SELDC, "Ptr", HSEL)
               Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", This.SelBkGnd, "UPtr")
               VarSetCapacity(RECT, 16, 0)
               NumPut(This.ItemWidth, RECT, 8, "Int")
               NumPut(This.ItemHeight, RECT, 12, "Int")
               DllCall("User32.dll\FillRect", "Ptr", SELDC, "Ptr", &RECT, "Ptr", Brush)
               DllCall("Gdi32.dll\DeleteObject", "Ptr", Brush)
               This.SELDC := SELDC
               This.HSEL := HSEL
            }
            DllCall("User32.dll\ReleaseDC", "Ptr", This.HBG, "Ptr", BGDC)
            This.BMPDC := BMPDC
            This.HBMP := HBMP
            LBDC := DllCall("User32.dll\GetDC", "Ptr", hWnd, "UPtr")
            DllCall("Gdi32.dll\BitBlt", "Ptr", LBDC, "Int", 0, "Int", 0, "Int", W, "Int", H
                                      , "Ptr", This.BMPDC, "Int", 0, "Int", 0, "UInt", SRCCOPY)
            DllCall("User32.dll\ReleaseDC", "Ptr", hWnd, "Ptr", LBDC)
            This.HasBackground := True
         }
         Return True
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Selection & Focus
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_KILLFOCUS and WM_SETFOCUS messages
      If (uMsg = WM.KILLFOCUS) Or (uMsg = WM.SETFOCUS) { ; not processed
         Return 0
      }
      ; LB_SETCURSEL message
      If (uMsg = LB.SETCURSEL) {
         If (This.Drawing) {
            DrawingMsg := uMsg
            This.SetRedraw(False)
         }
         DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
         If (DrawingMsg = LB.SETCURSEL) {
            This.SetRedraw(True)
            DrawingMsg := ""
         }
         SendMessage, % LB.GETTOPINDEX, 0, 0, , ahk_id %hWnd%
         TopIndex := ErrorLevel
         DllCall("User32.dll\SetScrollPos", "Ptr", hWnd, "Int", 1, "Int", TopIndex, "UInt", True)
         Return 0
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Keyboard
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_KEYDOWN message
      If (uMsg = WM.KEYDOWN) {
         If VK.HasKey(wParam) {
            CurSel := This.CurSel
            CurSel := (wParam = VK.DOWN)  ? (CurSel + 1)
                   :  (wParam = VK.UP)    ? (CurSel - 1)
                   :  (wParam = VK.Next)  ? (CurSel + This.SIPage)
                   :  (wParam = VK.PRIOR) ? (CurSel - This.SIPage)
                   :  (wParam = VK.HOME)  ? This.SIMin
                   :  (wParam = VK.END)   ? This.SIMax
                   :  CurSel
            CurSel := (CurSel < This.SIMin) ? This.SIMin : (CurSel > This.SIMax) ? This.SIMax : CurSel
            If (Cursel <> This.Cursel) {
               If (This.Drawing) {
                  DrawingMsg := uMsg
                  This.SetRedraw(False)
               }
               SendMessage, % LB.SETCURSEL, %CurSel%, 0, , ahk_id %hWnd%
               If (DrawingMsg = WM.KEYDOWN) {
                  This.SetRedraw(True)
                  DrawingMsg := ""
               }
               PostMessage, 0x0111, % (This.CtrlID | (LBN.SELCHANGE << 16)), %hWnd%, , % "ahk_id " . This.Parent
               This.Cursel := CurSel
            }
         }
         Return 0
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Mouse
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_LBUTTONDOWN message
      If (uMsg = WM.LBUTTONDOWN) {
         ControlFocus, , ahk_id %hWnd%
         Return 0
      }
      ; WM_LBUTTONUP message
      If (uMsg = WM.LBUTTONUP) {
         SendMessage, % LB.ITEMFROMPOINT, 0, %lParam%, , ahk_id %hWnd%
         Item := ErrorLevel
         If !(Item & 0xFFFF0000) && (Item <> This.CurSel) {
            If (This.Drawing) {
               DrawingMsg := uMsg
               This.SetRedraw(False)
            }
            SendMessage, % LB.SETCURSEL, %Item%, 0, , ahk_id %hWnd%
            If (DrawingMsg =  WM.LBUTTONUP) {
               This.SetRedraw(True)
               DrawingMsg := ""
            }
            This.Cursel := Item
            PostMessage, 0x0111, % (This.CtrlID | (LBN.SELCHANGE << 16)), %hWnd%, , % "ahk_id " . This.Parent
         }
         Return 0
      }
      ; WM_LBUTTONDBLCLK message
      If (uMsg = WM.LBUTTONDBLCLK) {
         PostMessage, 0x0111, % (This.CtrlID | (LBN.DBLCLK << 16)), %hWnd%, , % "ahk_id " . This.Parent
         Return 0
      }
      ; WM_MOUSEWHEEL message
      If (uMsg = WM.MOUSEWHEEL) {
         Delta := (wParam >> 16) & 0xFFFF
         If ((Delta <= 0x7FFF) && (This.TopIndex > This.SIMin))
         Or ((Delta >  0x7FFF) && ((This.TopIndex + This.SIPage) <= This.SIMax))
            PostMessage, % WM.VSCROLL, % (Delta > 0x7FFF ? 1 : 0), 0, , ahk_id %hWnd%
         Return 0
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Scrolling
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_HCROLL message
      If (uMsg = WM.HSCROLL) {
         Return 0
      }
      ; WM_VSCROLL message
      If (uMsg = WM.VSCROLL) {
         If (((wParam = 1) || (wParam = 3) || (wParam = 7)) && ((This.TopIndex + This.SIPage) > This.SIMax))
         Or (((wParam = 0) || (wParam = 2) || (wParam = 6)) && (This.TopIndex <= This.SIMin))
         Or (wParam = 8) || (wParam = 4)
            Return 0
         If (This.Drawing) {
            DrawingMsg := uMsg
            This.SetRedraw(False)
         }
         DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
         If (DrawingMsg = WM.VSCROLL) {
            This.SetRedraw(True)
            DrawingMsg := ""
         }
         SendMessage, % LB.GETTOPINDEX, 0, 0, , ahk_id %hWnd%
         This.TopIndex := ErrorLevel
         ; Seems that you must not return here, because DefSubClassProc apparently updates the scroll bar
         ; position on the second call!!!
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; Destroy
      ; ----------------------------------------------------------------------------------------------------------------
      ; WM_DESTROY message
      If (uMsg = WM.DESTROY) {
         This.__Delete()
      }
      Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Update the instance variables
   ; -------------------------------------------------------------------------------------------------------------------
   UpDate(TxtColor := "", SelColor := "", SelBkGnd := "", SelBkTrans := "") {
      ; ----------------------------------------------------------------------------------------------------------------
      ; Optional TxtColor : New text color (RGB integer value, e.g. 0xRRGGBB).
      ; Optional SelColor : New selected text color (RGB integer value, e.g. 0xRRGGBB).
      ; Changes of the content or the size of the ListBox will be processed automatically.
      ; ----------------------------------------------------------------------------------------------------------------
      Drawing := This.Drawing
      If (Drawing)
         This.SetRedraw(False)
      This.__Delete()
      If (TxtColor = "")
         If (This.TxtColor)
            TxtColor := ((This.TxtColor >> 16) & 0xFF) | (This.TxtColor & 0x00FF00) | ((This.TxtColor & 0xFF) << 16)
      If (SelColor = "")
         If (This.SelColor)
            SelColor := ((This.SelColor >> 16) & 0xFF) | (This.SelColor & 0x00FF00) | ((This.SelColor & 0xFF) << 16)
      If (SelBkGnd = "")
         If (This.SelBkGnd)
            SelBkGnd := ((This.SelBkGnd >> 16) & 0xFF) | (This.SelBkGnd & 0x00FF00) | ((This.SelBkGnd & 0xFF) << 16)
      If (SelBkTrans = "")
         If (This.SelBkTrans)
            SelBkTrans := This.SelBkTrans
      This.__New(This.HLB, This.HBG, TxtColor, SelColor, SelBkGnd, SelBkTrans)
      If (Drawing)
         This.SetRedraw(True)
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Set Redrawing True/False
   ; -------------------------------------------------------------------------------------------------------------------
   SetRedraw(Mode) {
      ; It's highly recommended to call this function instead of using GuiControl, -/+Redraw,
      ; because the drawing state will be stored internally for use by other methods.
      Static WM_SETREDRAW := 0x000B
      Mode := !!Mode
      This.Drawing := Mode
      SendMessage, %WM_SETREDRAW%, %Mode%, 0, , % "ahk_id " . This.HLB
      If (Mode)
         WinSet, Redraw, , % "ahk_id " . This.HLB
      Return True
   }
}