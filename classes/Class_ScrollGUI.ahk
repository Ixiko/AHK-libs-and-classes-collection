; ======================================================================================================================
; Namepace:       ScrollGUI
; Function:       Creates a scrollable GUI as a parent for GUI windows.
; Tested with:    AHK 1.1.20.03 (1.1.20+ required)
; Tested on:      Win 8.1 (x64)
; License:        The Unlicense -> http://unlicense.org
; Change log:
;                 1.0.00.00/2015-02-06/just me        -  initial release on ahkscript.org
;                 1.0.01.00/2015-02-08/just me        -  bug fixes
;                 1.1.00.00/2015-02-13/just me        -  bug fixes, mouse wheel handling, AutoSize method
;                 1.2.00.00/2015-03-12/just me        -  mouse wheel handling, resizing, OnMessage, bug fixes
; ======================================================================================================================
Class ScrollGUI {
   Static Instances := []
   ; ===================================================================================================================
   ; __New          Creates a scrollable parent window (ScrollGUI) for the passed GUI.
   ; Parameters:
   ;    HGUI        -  HWND of the GUI child window.
   ;    Width       -  Width of the client area of the ScrollGUI.
   ;                   Pass 0 to set the client area to the width of the child GUI.
   ;    Height      -  Height of the client area of the ScrollGUI.
   ;                   Pass 0 to set the client area to the height of the child GUI.
   ;    ----------- Optional:
   ;    GuiOptions  -  GUI options to be used when creating the ScrollGUI (e.g. +LabelMyLabel).
   ;                   Default: empty (no options)
   ;    ScrollBars  -  Scroll bars to register:
   ;                   1 : horizontal
   ;                   2 : vertical
   ;                   3 : both
   ;                   Default: 3
   ;    Wheel       -  Register WM_MOUSEWHEEL / WM_MOUSEHWHEEL messages:
   ;                   1 : register WM_MOUSEHWHEEL for horizontal scrolling (reqires Win Vista+)
   ;                   2 : register WM_MOUSEWHEEL for vertical scrolling
   ;                   3 : register both
   ;                   4 : register WM_MOUSEWHEEL for vertical and Shift+WM_MOUSEWHEEL for horizontal scrolling
   ;                   Default: 0
   ; Return values:
   ;    On failure:    False
   ; Remarks:
   ;    The dimensions of the child GUI are determined internally according to the visible children.
   ;    The maximum width and height of the parent GUI will be restricted to the dimensions of the child GUI.
   ;    If you register mouse wheel messages, the messages will be passed to the focused control, unless the mouse 
   ;    is hovering on one of the ScrollGUI's scroll bars. If the control doesn't process the message, it will be
   ;    returned back to the ScrollGUI.
   ;    Common controls seem to ignore wheel messages whenever the CTRL is down. So you can use this modifier to 
   ;    scroll the ScrollGUI even if a scrollable control has the focus.
   ; ===================================================================================================================
   __New(HGUI, Width, Height, GuiOptions := "", ScrollBars := 3, Wheel := 0) {
      Static WS_HSCROLL := "0x100000", WS_VSCROLL := "0x200000"
      Static FN_SCROLL := ObjBindMethod(ScrollGui, "On_WM_Scroll")
      Static FN_SIZE := ObjBindMethod(ScrollGui, "On_WM_Size")
      Static FN_WHEEL := ObjBindMethod(ScrollGUI, "On_WM_Wheel")
      ScrollBars &= 3
      Wheel &= 7
      If ((ScrollBars <> 1) && (ScrollBars <> 2) && (ScrollBars <> 3))
      || ((Wheel <> 0) && (Wheel <> 1) && (Wheel <> 2) && (Wheel <> 3) && (Wheel <> 4))
         Return False
      If !DllCall("User32.dll\IsWindow", "Ptr", HGUI, "UInt")
         Return False
      VarSetCapacity(RC, 16, 0)
      ; Child GUI
      If !This.AutoSize(HGUI, GuiW, GuiH)
         Return False
      Gui, %HGUI%:-Caption -Resize
      Gui, %HGUI%:Show, w%GuiW% h%GuiH% Hide
      MaxH := GuiW
      MaxV := GuiH
      LineH := Ceil(MaxH / 20)
      LineV := Ceil(MaxV / 20)
      ; ScrollGUI
      If (Width = 0) || (Width > MaxH)
         Width := MaxH
      If (Height = 0) || (Height > MaxV)
         Height := MaxV
      Styles := (ScrollBars & 1 ? " +" . WS_HSCROLL : "") . (ScrollBars & 2 ? " +" . WS_VSCROLL : "")
      Gui, New, %GuiOptions% %Styles% +hwndHWND
      Gui, %HWND%:Show, w%Width% h%Height% Hide
      Gui, %HWND%:+MaxSize%MaxH%x%MaxV%
      PageH := Width + 1
      PageV := Height + 1
      ; Instance variables
      This.HWND := HWND + 0
      This.HGUI := HGUI
      This.Width := Width
      This.Height := Height
      This.UseShift := False
      If (ScrollBars & 1) {
         This.SetScrollInfo(0, {Max: MaxH, Page: PageH, Pos: 0}) ; SB_HORZ = 0
         OnMessage(0x0114, FN_SCROLL) ; WM_HSCROLL = 0x0114
         If (Wheel & 1)
            OnMessage(0x020E, FN_WHEEL) ; WM_MOUSEHWHEEL = 0x020E
         Else If (Wheel & 4) {
            OnMessage(0x020A, FN_WHEEL) ; WM_MOUSEWHEEL = 0x020A
            This.UseShift := True
         }
         This.MaxH := MaxH
         This.LineH := LineH
         This.PageH := PageH
         This.PosH := 0
         This.ScrollH := True
         If (Wheel & 5)
            This.WheelH := True
      }
      If (ScrollBars & 2) {
         This.SetScrollInfo(1, {Max: MaxV, Page: PageV, Pos: 0}) ; SB_VERT = 1
         OnMessage(0x0115, FN_SCROLL) ; WM_VSCROLL = 0x0115
         If (Wheel & 6)
            OnMessage(0x020A, FN_WHEEL) ; WM_MOUSEWHEEL = 0x020A
         This.MaxV := MaxV
         This.LineV := LineV
         This.PageV := PageV
         This.PosV := 0
         This.ScrollV := True
         If (Wheel & 6)
            This.WheelV := True
      }
      ; Set the position of the child GUI
      Gui, %HGUI%:+Parent%HWND%
      Gui, %HGUI%:Show, x0 y0
      ; Adjust the scroll bars
      This.Instances[This.HWND] := &This
      This.Size()
      OnMessage(0x0005, FN_SIZE) ; WM_SIZE = 0x0005
   }
   ; ===================================================================================================================
   ; __Delete       Destroy the GUIs, if they still exist.
   ; ===================================================================================================================
   __Delete() {
      This.Destroy()
   }
   ; ===================================================================================================================
   ; Show           Shows the ScrollGUI.
   ; Parameters:
   ;    Title       -  Title of the ScrollGUI window
   ;    ShowOptions -  Gui, Show command options, width or height options are ignored
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; ===================================================================================================================
   Show(Title := "", ShowOptions := "") {
      ShowOptions := RegExReplace(ShowOptions, "i)\+?AutoSize")
      W := This.Width
      H := This.Height
      Gui, % This.HWND . ":Show", %ShowOptions% w%W% h%H%, %Title%
      Return True
   }
   ; ===================================================================================================================
   ; Destroy        Destroys the ScrollGUI and the associated child GUI.
   ; Parameters:
   ;    None.
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; Remarks:
   ;    Use this method instead of 'Gui, Destroy' to remove the ScrollGUI from the 'Instances' object.
   ; ===================================================================================================================
   Destroy() {
      If This.Instances.HasKey(This.HWND) {
         Gui, % This.HWND . ":Destroy"
         This.Instances.Remove(This.HWND, "")
         Return True
      }
   }
   ; ===================================================================================================================
   ; AdjustToChild  Adjust the scroll bars to the new child dimensions.
   ; Parameters:
   ;    None
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; Remarks:
   ;    Call this method whenever the visible area of the child GUI has to be changed, e.g. after adding, hiding,
   ;    unhiding, resizing, or repositioning controls.
   ;    The dimensions of the child GUI are determined internally according to the visible children.
   ; ===================================================================================================================
   AdjustToChild() {
      VarSetCapacity(RC, 16, 0)
      DllCall("User32.dll\GetWindowRect", "Ptr", This.HGUI, "Ptr", &RC)
      PrevW := NumGet(RC, 8, "Int") - NumGet(RC, 0, "Int")
      PrevH := Numget(RC, 12, "Int") - NumGet(RC, 4, "Int")
      DllCall("User32.dll\ScreenToClient", "Ptr", This.HWND, "Ptr", &RC)
      XC := XN := NumGet(RC, 0, "Int")
      YC := YN := NumGet(RC, 4, "Int")
      If !This.AutoSize(This.HGUI, GuiW, GuiH)
         Return False
      Gui, % This.HGUI . ":Show", x%XC% y%YC% w%GuiW% h%GuiH%
      MaxH := GuiW
      MaxV := GuiH
      Gui, % This.HWND . ":+MaxSize" . MaxH . "x" . MaxV
      If (GuiW < This.Width) || (GuiH < This.Height) {
         Gui, % This.HWND . ":Show", w%GuiW% h%GuiH%
         This.Width := GuiW
         This.SetPage(1, MaxH + 1)
         This.Height := GuiH
         This.SetPage(2, MaxV + 1)
      }
      LineH := Ceil(MaxH / 20)
      LineV := Ceil(MaxV / 20)
      If This.ScrollH {
         This.SetMax(1, MaxH)
         This.LineH := LineH
         If (XC + MaxH) < This.Width {
            XN += This.Width - (XC + MaxH)
            If (XN > 0)
               XN := 0
            This.SetScrollInfo(0, {Pos: XN * -1})
            This.GetScrollInfo(0, SI)
            This.PosH := NumGet(SI, 20, "Int")
         }
      }
      If This.ScrollV {
         This.SetMax(2, MaxV)
         This.LineV := LineV
         If (YC + MaxV) < This.Height {
            YN += This.Height - (YC + MaxV)
            If (YN > 0)
               YN := 0
            This.SetScrollInfo(1, {Pos: YN * -1})
            This.GetScrollInfo(1, SI)
            This.PosV := NumGet(SI, 20, "Int")
         }
      }
      If (XC <> XN) || (YC <> YN)
         DllCall("User32.dll\ScrollWindow", "Ptr", This.HWND, "Int", XN - XC, "Int", YN - YC, "Ptr", 0, "Ptr", 0)
      Return True
   }
   ; ===================================================================================================================
   ; SetMax         Sets the width or height of the scrolling area.
   ; Parameters:
   ;    SB          -  Scroll bar to set the value for:
   ;                   1 = horizontal
   ;                   2 = vertical
   ;    Max         -  Width respectively height of the scrolling area in pixels
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; ===================================================================================================================
   SetMax(SB, Max) {
      ; SB_HORZ = 0, SB_VERT = 1
      SB--
      If (SB <> 0) && (SB <> 1)
         Return False
      If (SB = 0)
         This.MaxH := Max
      Else
         This.MaxV := Max
      Return This.SetScrollInfo(SB, {Max: Max})
   }
   ; ===================================================================================================================
   ; SetLine        Sets the number of pixels to scroll by line.
   ; Parameters:
   ;    SB          -  Scroll bar to set the value for:
   ;                   1 = horizontal
   ;                   2 = vertical
   ;    Line        -  Number of pixels.
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; ===================================================================================================================
   SetLine(SB, Line) {
      ; SB_HORZ = 0, SB_VERT = 1
      SB--
      If (SB <> 0) && (SB <> 1)
         Return False
      If (SB = 0)
         This.LineH := Line
      Else
         This.LineV := Line
      Return True
   }
   ; ===================================================================================================================
   ; SetPage        Sets the number of pixels to scroll by page.
   ; Parameters:
   ;    SB          -  Scroll bar to set the value for:
   ;                   1 = horizontal
   ;                   2 = vertical
   ;    Page        -  Number of pixels.
   ; Return values:
   ;    On success: True
   ;    On failure: False
   ; Remarks:
   ;    If the ScrollGUI is resizable, the page size will be recalculated automatically while resizing.
   ; ===================================================================================================================
   SetPage(SB, Page) {
      ; SB_HORZ = 0, SB_VERT = 1
      SB--
      If (SB <> 0) && (SB <> 1)
         Return False
      If (SB = 0)
         This.PageH := Page
      Else
         This.PageV := Page
      Return This.SetScrollInfo(SB, {Page: Page})
   }
   ; ===================================================================================================================
   ; Methods for internal or system use!!!
   ; ===================================================================================================================
   AutoSize(HGUI, ByRef Width, ByRef Height) {
      DHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
      VarSetCapacity(RECT, 16, 0)
      Width := Height := 0
      HWND := HGUI
      CMD := 5 ; GW_CHILD
      L := T := R := B := LH := TH := ""
      While (HWND := DllCall("GetWindow", "Ptr", HWND, "UInt", CMD, "UPtr")) && (CMD := 2) {
         WinGetPos, X, Y, W, H, ahk_id %HWND%
         W += X, H += Y
         WinGet, Styles, Style, ahk_id %HWND%
         If (Styles & 0x10000000) { ; WS_VISIBLE
            If (L = "") || (X < L)
               L := X
            If (T = "") || (Y < T)
               T := Y
            If (R = "") || (W > R)
               R := W
            If (B = "") || (H > B)
               B := H
         }
         Else {
            If (LH = "") || (X < LH)
               LH := X
            If (TH = "") || (Y < TH)
               TH := Y
         }
      }
      DetectHiddenWindows, %DHW%
      If (LH <> "") {
         VarSetCapacity(POINT, 8, 0)
         NumPut(LH, POINT, 0, "Int")
         DllCall("ScreenToClient", "Ptr", HGUI, "Ptr", &POINT)
         LH := NumGet(POINT, 0, "Int")
      }
      If (TH <> "") {
         VarSetCapacity(POINT, 8, 0)
         NumPut(TH, POINT, 4, "Int")
         DllCall("ScreenToClient", "Ptr", HGUI, "Ptr", &POINT)
         TH := NumGet(POINT, 4, "Int")
      }
      NumPut(L, RECT, 0, "Int"), NumPut(T, RECT,  4, "Int")
      NumPut(R, RECT, 8, "Int"), NumPut(B, RECT, 12, "Int")
      DllCall("MapWindowPoints", "Ptr", 0, "Ptr", HGUI, "Ptr", &RECT, "UInt", 2)
      Width := NumGet(RECT, 8, "Int") + (LH <> "" ? LH : NumGet(RECT, 0, "Int"))
      Height := NumGet(RECT, 12, "Int") + (TH <> "" ? TH : NumGet(RECT,  4, "Int"))
      Return True
   }
   ; ===================================================================================================================
   GetScrollInfo(SB, ByRef SI) {
      VarSetCapacity(SI, 28, 0) ; SCROLLINFO
      NumPut(28, SI, 0, "UInt")
      NumPut(0x17, SI, 4, "UInt") ; SIF_ALL = 0x17
      Return DllCall("User32.dll\GetScrollInfo", "Ptr", This.HWND, "Int", SB, "Ptr", &SI, "UInt")
   }
   ; ===================================================================================================================
   SetScrollInfo(SB, Values) {
      Static SIF := {Max: 0x01, Page: 0x02, Pos: 0x04}
      Static Off := {Max: 12, Page: 16, Pos: 20}
      Mask := 0
      VarSetCapacity(SI, 28, 0) ; SCROLLINFO
      NumPut(28, SI, 0, "UInt")
      For Key, Value In Values {
         If SIF.HasKey(Key) {
            Mask |= SIF[Key]
            NumPut(Value, SI, Off[Key], "UInt")
         }
      }
      If (Mask) {
         NumPut(Mask | 0x08, SI, 4, "UInt") ; SIF_DISABLENOSCROLL = 0x08
         Return DllCall("User32.dll\SetScrollInfo", "Ptr", This.HWND, "Int", SB, "Ptr", &SI, "UInt", 1, "UInt")
      }
      Return False
   }
   ; ===================================================================================================================
   On_WM_Scroll(WP, LP, Msg, HWND) {
      ; WM_HSCROLL = 0x0114, WM_VSCROLL = 0x0115
      If (Instance := Object(This.Instances[HWND]))
         If ((Msg = 0x0114) && Instance.ScrollH)
         || ((Msg = 0x0115) && Instance.ScrollV)
            Return Instance.Scroll(WP, LP, Msg, HWND)
   }
   ; ===================================================================================================================
   Scroll(WP, LP, Msg, HWND) {
      ; WM_HSCROLL = 0x0114, WM_VSCROLL = 0x0115
      Static SB_LINEMINUS := 0, SB_LINEPLUS := 1, SB_PAGEMINUS := 2, SB_PAGEPLUS := 3, SB_THUMBTRACK := 5
      If (LP <> 0)
         Return
      SB := (Msg = 0x0114 ? 0 : 1) ; SB_HORZ : SB_VERT
      SC := WP & 0xFFFF
      SD := (Msg = 0x0114 ? This.LineH : This.LineV)
      SI := 0
      If !This.GetScrollInfo(SB, SI)
         Return
      PA := PN := NumGet(SI, 20, "Int")
      PN := (SC = 0) ? PA - SD ; SB_LINEMINUS
          : (SC = 1) ? PA + SD ; SB_LINEPLUS
          : (SC = 2) ? PA - NumGet(SI, 16, "UInt") ; SB_PAGEMINUS
          : (SC = 3) ? PA + NumGet(SI, 16, "UInt") ; SB_PAGEPLUS
          : (SC = 5) ? NumGet(SI, 24, "Int") ; SB_THUMBTRACK
          : PA
      If (PA = PN)
         Return 0
      This.SetScrollInfo(SB, {Pos: PN})
      This.GetScrollInfo(SB, SI)
      PN := NumGet(SI, 20, "Int")
      If (SB = 0)
         This.PosH := PN
      Else
         This.PosV := PN
      If (PA <> PN) {
         HS := (Msg = 0x0114) ? PA - PN : 0
         VS := (Msg = 0x0115) ? PA - PN : 0
         DllCall("User32.dll\ScrollWindow", "Ptr", This.HWND, "Int", HS, "Int", VS, "Ptr", 0, "Ptr", 0)
      }
      Return 0
   }
   ; ===================================================================================================================
   On_WM_Size(WP, LP, Msg, HWND) {
      If ((WP = 0) || (WP = 2)) && (Instance := Object(This.Instances[HWND]))
         Return Instance.Size(LP & 0xFFFF, (LP >> 16) & 0xFFFF)
   }
   ; ===================================================================================================================
   Size(Width := 0, Height := 0) {
      If (Width = 0) || (Height = 0) {
         VarSetCapacity(RC, 16, 0)
         DllCall("User32.dll\GetClientRect", "Ptr", This.HWND, "Ptr", &RC)
         Width := NumGet(RC, 8, "Int")
         Height := Numget(RC, 12, "Int")
      }
      SH := SV := 0
      If This.ScrollH {
         If (Width <> This.Width) {
            This.SetScrollInfo(0, {Page: Width + 1})
            This.Width := Width
            This.GetScrollInfo(0, SI)
            PosH := NumGet(SI, 20, "Int")
            SH := This.PosH - PosH
            This.PosH := PosH
         }
      }
      If This.ScrollV {
         If (Height <> This.Height) {
            This.SetScrollInfo(1, {Page: Height + 1})
            This.Height := Height
            This.GetScrollInfo(1, SI)
            PosV := NumGet(SI, 20, "Int")
            SV := This.PosV - PosV
            This.PosV := PosV
         }
      }
      If (SH) || (SV)
         DllCall("User32.dll\ScrollWindow", "Ptr", This.HWND, "Int", SH, "Int", SV, "Ptr", 0, "Ptr", 0)
      Return 0
   }
   ; ===================================================================================================================
   On_WM_Wheel(WP, LP, Msg, HWND) {
      ; MK_SHIFT = 0x0004, WM_MOUSEWHEEL = 0x020A, WM_MOUSEHWHEEL = 0x020E, WM_NCHITTEST = 0x0084
      HACT := WinActive("A") + 0
      If (HACT <> HWND) && (Instance := Object(This.Instances[HACT])) {
         SendMessage, 0x0084, 0, % (LP & 0xFFFFFFFF), , ahk_id %HACT%
         OnBar := ErrorLevel
         If (OnBar = 6) && Instance.WheelH ; HTHSCROLL = 6
            Return Instance.Wheel(WP, LP, 0x020E, HACT)
         If (OnBar = 7) && Instance.WheelV ; HTVSCROLL = 7
            Return Instance.Wheel(WP, LP, 0x020A, HACT)
      }
      If (Instance := Object(This.Instances[HWND])) {
         If ((Msg = 0x020E) && Instance.WheelH)
         || ((Msg = 0x020A) && (Instance.WheelV || (Instance.WheelH && Instance.UseShift && (WP & 0x0004))))
            Return Instance.Wheel(WP, LP, Msg, HWND)
      }
   }
   ; ===================================================================================================================
   Wheel(WP, LP, Msg, HWND) {
      ; MK_SHIFT = 0x0004, WM_MOUSEWHEEL = 0x020A, WM_MOUSEHWHEEL = 0x020E, WM_HSCROLL = 0x0114, WM_VSCROLL = 0x0115
      ; SB_LINEMINUS = 0, SB_LINEPLUS = 1
      If (Msg = 0x020A) && This.UseShift && (WP & 0x0004)
         Msg := 0x020E
      Msg := (Msg = 0x020A ? 0x0115 : 0x0114)
      SB := ((WP >> 16) > 0x7FFF) || (WP < 0) ? 1 : 0
      Return This.Scroll(SB, 0, Msg, HWND)
   }
}