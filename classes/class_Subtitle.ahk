; Script:    Subtitle.ahk
; Author:    iseahound
; Version:   2018-04-17 (April 2018)
; Recent:    2018-05-15

#include <Gdip_All>


class Subtitle {

   layers := {}, ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

   __New(title := "") {
      global pToken
      if !(this.outer.Startup())
         if !(pToken)
            if !(this.pToken := Gdip_Startup())
               throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

      Gui, New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndhwnd
      this.hwnd := hwnd
      this.title := (title != "") ? title : "Subtitle_" this.hwnd
      DllCall("ShowWindow", "ptr",this.hwnd, "int",8)
      DllCall("SetWindowText", "ptr",this.hwnd, "str",this.title)
      this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
      this.hdc := CreateCompatibleDC()
      this.obm := SelectObject(this.hdc, this.hbm)
      this.G := Gdip_GraphicsFromHDC(this.hdc)
      return this
   }

   __Delete() {
      global pToken
      if (this.outer.pToken)
         return this.outer.Shutdown()
      if (pToken)
         return
      if (this.pToken)
         return Gdip_Shutdown(this.pToken)
   }

   FreeMemory() {
      SelectObject(this.hdc, this.obm)
      DeleteObject(this.hbm)
      DeleteDC(this.hdc)
      Gdip_DeleteGraphics(this.G)
      return this
   }

   Destroy() {
      this.FreeMemory()
      DllCall("DestroyWindow", "ptr",this.hwnd)
      return this
   }

   Hide() {
      DllCall("ShowWindow", "ptr",this.hwnd, "int",0)
      return this
   }

   Show(i := 8) {
      DllCall("ShowWindow", "ptr",this.hwnd, "int",i)
      return this
   }

   ToggleVisible() {
      return (this.isVisible()) ? this.Hide() : this.Show()
   }

   isVisible() {
      return DllCall("IsWindowVisible", "ptr",this.hwnd)
   }

   AlwaysOnTop() {
      WinSet, AlwaysOnTop, Toggle, % "ahk_id" this.hwnd
      return this
   }

   Bottom() {
      WinSet, Bottom,, % "ahk_id" this.hwnd
      return this
   }

   ClickThrough() {
      _dhw := A_DetectHiddenWindows
      DetectHiddenWindows On
      WinGet, ExStyle, ExStyle, % "ahk_id" this.hwnd
      if (ExStyle & 0x20)
         WinSet, ExStyle, -0x20, % "ahk_id" this.hwnd
      else
         WinSet, ExStyle, +0x20, % "ahk_id" this.hwnd
      DetectHiddenWindows %_dhw%
      return this
   }

   Desktop() {
      ; Based on: https://www.codeproject.com/Articles/856020/Draw-Behind-Desktop-Icons-in-Windows-plus?msg=5478543#xx5478543xx
      DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",0)
      DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",1) ; Post-Creator's Update Windows 10.
      WinGet, windows, List, ahk_class WorkerW
      Loop, %windows%
         if (DllCall("FindWindowEx", "ptr",windows%A_Index%, "ptr",0, "str","SHELLDLL_DefView", "ptr",0) != 0)
            WorkerW := DllCall("FindWindowEx", "ptr",0, "ptr",windows%A_Index%, "str","WorkerW", "ptr",0)

      if (WorkerW) {
         this.Destroy()
         this.hwnd := WorkerW
         DllCall("SetWindowPos", "uint",WorkerW, "uint",1, "int",0, "int",0, "int",this.ScreenWidth, "int",this.ScreenHeight, "uint",0)
         this.base.FreeMemory := ObjBindMethod(this, "DesktopFreeMemory")
         this.base.Destroy := ObjBindMethod(this, "DesktopDestroy")
         this.hdc := DllCall("GetDCEx", "ptr",WorkerW, "ptr",0, "int",0x403)
         this.G := Gdip_GraphicsFromHDC(this.hdc)
      }
      return this
   }

   DesktopFreeMemory() {
      ReleaseDC(this.hdc)
      Gdip_DeleteGraphics(this.G)
      return this
   }

   DesktopDestroy() {
      this.FreeMemory()
      DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",0)
      DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",1)
      return this
   }

   Normal() {
      WinSet, AlwaysOnTop, Off, % "ahk_id" this.hwnd
      return this
   }

   DetectScreenResolutionChange(width := "", height := "") {
      width := (width) ? width : A_ScreenWidth
      height := (height) ? height : A_ScreenHeight
      if (width != this.ScreenWidth || height != this.ScreenHeight) {
         this.ScreenWidth := width, this.ScreenHeight := height
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         Gdip_DeleteGraphics(this.G)
         this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
         this.hdc := CreateCompatibleDC()
         this.obm := SelectObject(this.hdc, this.hbm)
         this.G := Gdip_GraphicsFromHDC(this.hdc)
         loop % this.layers.maxIndex()
            this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
      }
   }

   Bitmap(x := "", y := "", w := "", h := "") {
      x := (x != "") ? x : this.x
      y := (y != "") ? y : this.y
      w := (w != "") ? w : this.xx - this.x
      h := (h != "") ? h : this.yy - this.y

      pBitmap := Gdip_CreateBitmap(this.ScreenWidth, this.ScreenHeight)
      pGraphics := Gdip_GraphicsFromImage(pBitmap)
      loop % this.layers.maxIndex()
         this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
      Gdip_DeleteGraphics(pGraphics)
      pBitmapCopy := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
      Gdip_DisposeImage(pBitmap)
      return pBitmapCopy ; Please dispose of this image responsibly.
   }

   hBitmap(alpha := 0xFFFFFFFF) {
      ; hBitmap converts alpha channel to specified alpha color.
      ; Adds 1 pixel because Anti-Alias (SmoothingMode = 4)
      ; Should it be crop 1 pixel instead?
      pBitmap := this.Bitmap()
      hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, alpha)
      Gdip_DisposeImage(pBitmap)
      return hBitmap
   }

   Save(filename := "", quality := 92) {
      filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
               : (filename != "") ? filename ".png" : this.title ".png"
      pBitmap := this.Bitmap()
      Gdip_SaveBitmapToFile(pBitmap, filename, quality)
      Gdip_DisposeImage(pBitmap)
      return this
   }

   Screenshot(filename := "", quality := 92) {
      filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
               : (filename != "") ? filename ".png" : this.title ".png"
      pBitmap := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.xx - this.x "|" this.yy - this.y)
      Gdip_SaveBitmapToFile(pBitmap, filename, quality)
      Gdip_DisposeImage(pBitmap)
      return this
   }

   Render(text := "", style1 := "", style2 := "", update := true) {
      if !(this.hwnd){
         _subtitle := (this.outer) ? new this.outer.Subtitle() : new Subtitle()
         return _subtitle.Render(text, style1, style2, update)
      }
      else {
         Critical On
         this.Draw(text, style1, style2)
         this.DetectScreenResolutionChange()
         if (this.allowDrag == true)
            this.Reposition()
         if (update == true) {
            UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
         }
         if (this.time) {
            self_destruct := ObjBindMethod(this, "Destroy")
            SetTimer, % self_destruct, % -1 * this.time
         }
         this.rendered := true
         Critical Off
         return this
      }
   }

   RenderToBitmap(text := "", style1 := "", style2 := "") {
      if !(this.hwnd){
         _subtitle := (this.outer) ? new this.outer.Subtitle() : new Subtitle()
         return _subtitle.RenderToBitmap(text, style1, style2)
      } else {
         this.Render(text, style1, style2, false)
         return this.Bitmap()
      }
   }

   RenderToHBitmap(text := "", style1 := "", style2 := "") {
      if !(this.hwnd){
         _subtitle := (this.outer) ? new this.outer.Subtitle() : new Subtitle()
         return _subtitle.RenderToHBitmap(text, style1, style2)
      } else {
         this.Render(text, style1, style2, false)
         return this.hBitmap()
      }
   }

   Reposition() {
      CoordMode, Mouse, Screen
      MouseGetPos, x_mouse, y_mouse
      this.LButton := GetKeyState("LButton", "P") ? 1 : 0
      this.keypress := (this.LButton && DllCall("GetForegroundWindow") == this.hwnd) ? ((!this.keypress) ? 1 : -1) : ((this.keypress == -1) ? 2 : 0)

      if (this.keypress == 1) {
         this.x_mouse := x_mouse, this.y_mouse := y_mouse
         this.hbm2 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
         this.hdc2 := CreateCompatibleDC()
         this.obm2 := SelectObject(this.hdc2, this.hbm2)
         this.G2 := Gdip_GraphicsFromHDC(this.hdc2)
      }

      if (this.keypress == -1) {
         dx := x_mouse - this.x_mouse
         dy := y_mouse - this.y_mouse
         safe_x := (0 + dx <= 0) ? 0 : 0 + dx
         safe_y := (0 + dy <= 0) ? 0 : 0 + dy
         safe_w := (0 + this.ScreenWidth + dx >= this.ScreenWidth) ? this.ScreenWidth : 0 + this.ScreenWidth + dx
         safe_h := (0 + this.ScreenHeight + dy >= this.ScreenHeight) ? this.ScreenHeight : 0 + this.ScreenHeight + dy
         source_x := (dx < 0) ? -dx : 0
         source_y := (dy < 0) ? -dy : 0
         ;Tooltip % dx ", " dy "`n" safe_x ", " safe_y ", " safe_w ", " safe_h
         Gdip_GraphicsClear(this.G2)
         BitBlt(this.hdc2, safe_x, safe_y, safe_w, safe_h, this.hdc, source_x, source_y)
         UpdateLayeredWindow(this.hwnd, this.hdc2, 0, 0, this.ScreenWidth, this.ScreenHeight)
      }

      if (this.keypress == 2) {
         Gdip_DeleteGraphics(this.G)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         this.hdc := this.hdc2
         this.obm := this.obm2
         this.hbm := this.hbm2
         this.G := Gdip_GraphicsFromHDC(this.hdc2)
      }

      Reposition := ObjBindMethod(this, "Reposition")
      SetTimer, % Reposition, -10
   }

   Draw(text := "", style1 := "", style2 := "", pGraphics := "") {
      ; If the image was previously rendered, reset everything like a new Subtitle object.
      if (pGraphics == "") {
         if (this.rendered == true) {
            this.rendered := false
            this.layers := {}
            this.x := this.y := this.xx := this.yy := "" ; not 0!
            Gdip_GraphicsClear(this.G)
         }
         this.layers.push([text, style1, style2]) ; Saves each call of Draw()
         pGraphics := this.G
      }

      ; Remove excess whitespace. This is required for proper RegEx detection.
      style1 := !IsObject(style1) ? RegExReplace(style1, "\s+", " ") : style1
      style2 := !IsObject(style2) ? RegExReplace(style2, "\s+", " ") : style2

      ; Load saved styles if and only if both styles are blank.
      if (style1 == "" && style2 == "")
         style1 := this.style1, style2 := this.style2
      else
         this.style1 := style1, this.style2 := style2 ; Remember styles so that they can be loaded next time.

      ; RegEx help? https://regex101.com/r/xLzZzO/2
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      ; Extract the time variable and save it for later when we Render() everything.
      this.time := (style1.time) ? style1.time : (style1.t) ? style1.t
         : (!IsObject(style1) && (___ := RegExReplace(style1, q1 "(t(ime)?)" q2, "${value}")) != style1) ? ___
         : (style2.time) ? style2.time : (style2.t) ? style2.t
         : (!IsObject(style2) && (___ := RegExReplace(style2, q1 "(t(ime)?)" q2, "${value}")) != style2) ? ___
         : this.time

      ; Extract styles from the background styles parameter.
      if IsObject(style1) {
         _a  := (style1.anchor != "")   ? style1.anchor   : style1.a
         _x  := (style1.left != "")     ? style1.left     : style1.x
         _y  := (style1.top != "")      ? style1.top      : style1.y
         _w  := (style1.width != "")    ? style1.width    : style1.w
         _h  := (style1.height != "")   ? style1.height   : style1.h
         _r  := (style1.radius != "")   ? style1.radius   : style1.r
         _c  := (style1.color != "")    ? style1.color    : style1.c
         _m  := (style1.margin != "")   ? style1.margin   : style1.m
         _p  := (style1.padding != "")  ? style1.padding  : style1.p
         _q  := (style1.quality != "")  ? style1.quality  : (style1.q) ? style1.q : style1.SmoothingMode
      } else {
         _a  := ((___ := RegExReplace(style1, q1    "(a(nchor)?)"        q2, "${value}")) != style1) ? ___ : ""
         _x  := ((___ := RegExReplace(style1, q1    "(x|left)"           q2, "${value}")) != style1) ? ___ : ""
         _y  := ((___ := RegExReplace(style1, q1    "(y|top)"            q2, "${value}")) != style1) ? ___ : ""
         _w  := ((___ := RegExReplace(style1, q1    "(w(idth)?)"         q2, "${value}")) != style1) ? ___ : ""
         _h  := ((___ := RegExReplace(style1, q1    "(h(eight)?)"        q2, "${value}")) != style1) ? ___ : ""
         _r  := ((___ := RegExReplace(style1, q1    "(r(adius)?)"        q2, "${value}")) != style1) ? ___ : ""
         _c  := ((___ := RegExReplace(style1, q1    "(c(olor)?)"         q2, "${value}")) != style1) ? ___ : ""
         _m  := ((___ := RegExReplace(style1, q1    "(m(argin)?)"        q2, "${value}")) != style1) ? ___ : ""
         _p  := ((___ := RegExReplace(style1, q1    "(p(adding)?)"       q2, "${value}")) != style1) ? ___ : ""
         _q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"       q2, "${value}")) != style1) ? ___ : ""
      }

      ; Extract styles from the text styles parameter.
      if IsObject(style2) {
         a  := (style2.anchor != "")      ? style2.anchor      : style2.a
         x  := (style2.left != "")        ? style2.left        : style2.x
         y  := (style2.top != "")         ? style2.top         : style2.y
         w  := (style2.width != "")       ? style2.width       : style2.w
         h  := (style2.height != "")      ? style2.height      : style2.h
         m  := (style2.margin != "")      ? style2.margin      : style2.m
         f  := (style2.font != "")        ? style2.font        : style2.f
         s  := (style2.size != "")        ? style2.size        : style2.s
         c  := (style2.color != "")       ? style2.color       : style2.c
         b  := (style2.bold != "")        ? style2.bold        : style2.b
         i  := (style2.italic != "")      ? style2.italic      : style2.i
         u  := (style2.underline != "")   ? style2.underline   : style2.u
         j  := (style2.justify != "")     ? style2.justify     : style2.j
         n  := (style2.noWrap != "")      ? style2.noWrap      : style2.n
         z  := (style2.condensed != "")   ? style2.condensed   : style2.z
         d  := (style2.dropShadow != "")  ? style2.dropShadow  : style2.d
         o  := (style2.outline != "")     ? style2.outline     : style2.o
         q  := (style2.quality != "")     ? style2.quality     : (style2.q) ? style2.q : style2.TextRenderingHint
      } else {
         a  := ((___ := RegExReplace(style2, q1    "(a(nchor)?)"        q2, "${value}")) != style2) ? ___ : ""
         x  := ((___ := RegExReplace(style2, q1    "(x|left)"           q2, "${value}")) != style2) ? ___ : ""
         y  := ((___ := RegExReplace(style2, q1    "(y|top)"            q2, "${value}")) != style2) ? ___ : ""
         w  := ((___ := RegExReplace(style2, q1    "(w(idth)?)"         q2, "${value}")) != style2) ? ___ : ""
         h  := ((___ := RegExReplace(style2, q1    "(h(eight)?)"        q2, "${value}")) != style2) ? ___ : ""
         m  := ((___ := RegExReplace(style2, q1    "(m(argin)?)"        q2, "${value}")) != style2) ? ___ : ""
         f  := ((___ := RegExReplace(style2, q1    "(f(ont)?)"          q2, "${value}")) != style2) ? ___ : ""
         s  := ((___ := RegExReplace(style2, q1    "(s(ize)?)"          q2, "${value}")) != style2) ? ___ : ""
         c  := ((___ := RegExReplace(style2, q1    "(c(olor)?)"         q2, "${value}")) != style2) ? ___ : ""
         b  := ((___ := RegExReplace(style2, q1    "(b(old)?)"          q2, "${value}")) != style2) ? ___ : ""
         i  := ((___ := RegExReplace(style2, q1    "(i(talic)?)"        q2, "${value}")) != style2) ? ___ : ""
         u  := ((___ := RegExReplace(style2, q1    "(u(nderline)?)"     q2, "${value}")) != style2) ? ___ : ""
         j  := ((___ := RegExReplace(style2, q1    "(j(ustify)?)"       q2, "${value}")) != style2) ? ___ : ""
         n  := ((___ := RegExReplace(style2, q1    "(n(oWrap)?)"        q2, "${value}")) != style2) ? ___ : ""
         z  := ((___ := RegExReplace(style2, q1    "(z|condensed)"      q2, "${value}")) != style2) ? ___ : ""
         d  := ((___ := RegExReplace(style2, q1    "(d(ropShadow)?)"    q2, "${value}")) != style2) ? ___ : ""
         o  := ((___ := RegExReplace(style2, q1    "(o(utline)?)"       q2, "${value}")) != style2) ? ___ : ""
         q  := ((___ := RegExReplace(style2, q1    "(q(uality)?)"       q2, "${value}")) != style2) ? ___ : ""
      }

      ; These are the type checkers.
      static valid := "^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
      static valid_positive := "^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

      ; Define viewport width and height. This is the visible screen area.
      this.vw := 0.01 * this.ScreenWidth    ; 1% of viewport width.
      this.vh := 0.01 * this.ScreenHeight   ; 1% of viewport height.
      this.vmin := (this.vw < this.vh) ? this.vw : this.vh ; 1vw or 1vh, whichever is smaller.

      ; Get Rendering Quality.
      _q := (_q >= 0 && _q <= 4) ? _q : 4          ; Default SmoothingMode is 4 if radius is set. See Draw 1.
      q  := (q >= 0 && q <= 5) ? q : 4             ; Default TextRenderingHint is 4 (antialias).

      ; Get Font size.
      s  := (s ~= valid_positive) ? RegExReplace(s, "\s", "") : "2.23vh"           ; Default font size is 2.23vh.
      s  := (s ~= "(pt|px)$") ? SubStr(s, 1, -2) : s                               ; Strip spaces, px, and pt.
      s  := (s ~= "vh$") ? RegExReplace(s, "vh$", "") * this.vh : s                ; Relative to viewport height.
      s  := (s ~= "vw$") ? RegExReplace(s, "vw$", "") * this.vw : s                ; Relative to viewport width.
      s  := (s ~= "(%|vmin)$") ? RegExReplace(s, "(%|vmin)$", "") * this.vmin : s  ; Relative to viewport minimum.

      ; Get Bold, Italic, Underline, NoWrap, and Justification of text.
      style += (b) ? 1 : 0         ; bold
      style += (i) ? 2 : 0         ; italic
      style += (u) ? 4 : 0         ; underline
      style += (strikeout) ? 8 : 0 ; strikeout, not implemented.
      n  := (n) ? 0x4000 | 0x1000 : 0x4000
      j  := (j ~= "i)cent(er|re)") ? 1 : (j ~= "i)(far|right)") ? 2 : 0   ; Left/near, center/centre, far/right.

      ; Later when text x and w are finalized and it is found that x + ReturnRC[3] exceeds the screen,
      ; then the _redrawBecauseOfCondensedFont flag is set to true.
      if (this._redrawBecauseOfCondensedFont == true)
         f:=z, z:=0, this._redrawBecauseOfCondensedFont := false

      ; Create Font.
      hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial") ; Default font is Arial.
      hFont := Gdip_FontCreate(hFamily, s, style)
      hFormat := Gdip_StringFormatCreate(n)
      Gdip_SetStringFormatAlign(hFormat, j)  ; Left = 0, Center = 1, Right = 2

      ; Simulate string width and height. This will get the exact width and height of the text.
      CreateRectF(RC, 0, 0, 0, 0)
      Gdip_SetSmoothingMode(pGraphics, _q)     ; None = 3, AntiAlias = 4
      Gdip_SetTextRenderingHint(pGraphics, q)  ; Anti-Alias = 4, Cleartype = 5 (and gives weird effects.)
      ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
      ReturnRC := StrSplit(ReturnRC, "|")      ; Contains the values for measured x, y, w, h text.

      ; Get background width and height. Default width and height are simulated width and height.
      _w := (_w ~= valid_positive) ? RegExReplace(_w, "\s", "") : ReturnRC[3]
      _w := (_w ~= "(pt|px)$") ? SubStr(_w, 1, -2) : _w
      _w := (_w ~= "(%|vw)$") ? RegExReplace(_w, "(%|vw)$", "") * this.vw : _w
      _w := (_w ~= "vh$") ? RegExReplace(_w, "vh$", "") * this.vh : _w
      _w := (_w ~= "vmin$") ? RegExReplace(_w, "vmin$", "") * this.vmin : _w
      ; Output is a decimal with pixel units.

      _h := (_h ~= valid_positive) ? RegExReplace(_h, "\s", "") : ReturnRC[4]
      _h := (_h ~= "(pt|px)$") ? SubStr(_h, 1, -2) : _h
      _h := (_h ~= "vw$") ? RegExReplace(_h, "vw$", "") * this.vw : _h
      _h := (_h ~= "(%|vh)$") ? RegExReplace(_h, "(%|vh)$", "") * this.vh : _h
      _h := (_h ~= "vmin$") ? RegExReplace(_h, "vmin$", "") * this.vmin : _h
      ; Output is a decimal with pixel units.

      ; Get background anchor. This is where the origin of the image is located.
      ; The default origin is the top left corner. Default anchor is 1.
      _a := RegExReplace(_a, "\s", "")
      _a := (_a = "top") ? 2 : (_a = "left") ? 4 : (_a = "right") ? 6 : (_a = "bottom") ? 8
         : (_a ~= "i)top" && _a ~= "i)left") ? 1 : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 2
         : (_a ~= "i)top" && _a ~= "i)bottom") ? 3 : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 4
         : (_a ~= "i)cent(er|re)") ? 5 : (_a ~= "i)cent(er|re)" && _a ~= "i)bottom") ? 6
         : (_a ~= "i)bottom" && _a ~= "i)left") ? 7 : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 8
         : (_a ~= "i)bottom" && _a ~= "i)right") ? 9 : (_a ~= "^[1-9]$") ? _a : 1 ; Default anchor is top-left.

      ; _x and _y can be specified as locations (left, center, right, top, bottom).
      ; These location words in _x and _y take precedence over the values in _a.
      _a  := (_x ~= "i)left") ? 1+(((_a-1)//3)*3) : (_x ~= "i)cent(er|re)") ? 2+(((_a-1)//3)*3) : (_x ~= "i)right") ? 3+(((_a-1)//3)*3) : _a
      _a  := (_y ~= "i)top") ? 1+(mod(_a-1,3)) : (_y ~= "i)cent(er|re)") ? 4+(mod(_a-1,3)) : (_y ~= "i)bottom") ? 7+(mod(_a-1,3)) : _a

      ; Convert English words to numbers. Don't mess with these values any further.
      _x  := (_x ~= "i)left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*this.ScreenWidth : (_x ~= "i)right") ? this.ScreenWidth : _x
      _y  := (_y ~= "i)top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*this.ScreenHeight : (_y ~= "i)bottom") ? this.ScreenHeight : _y

      ; Get _x value.
      _x := (_x ~= valid) ? RegExReplace(_x, "\s", "") : 0  ; Default _x is 0.
      _x := (_x ~= "(pt|px)$") ? SubStr(_x, 1, -2) : _x
      _x := (_x ~= "(%|vw)$") ? RegExReplace(_x, "(%|vw)$", "") * this.vw : _x
      _x := (_x ~= "vh$") ? RegExReplace(_x, "vh$", "") * this.vh : _x
      _x := (_x ~= "vmin$") ? RegExReplace(_x, "vmin$", "") * this.vmin : _x

      ; Get _y value.
      _y := (_y ~= valid) ? RegExReplace(_y, "\s", "") : 0  ; Default _y is 0.
      _y := (_y ~= "(pt|px)$") ? SubStr(_y, 1, -2) : _y
      _y := (_y ~= "vw$") ? RegExReplace(_y, "vw$", "") * this.vw : _y
      _y := (_y ~= "(%|vh)$") ? RegExReplace(_y, "(%|vh)$", "") * this.vh : _y
      _y := (_y ~= "vmin$") ? RegExReplace(_y, "vmin$", "") * this.vmin : _y

      ; Now let's modify the _x and _y values with the _anchor, so that the image has a new point of origin.
      ; We need our calculated _width and _height for this.
      _x  -= (mod(_a-1,3) == 0) ? 0 : (mod(_a-1,3) == 1) ? _w/2 : (mod(_a-1,3) == 2) ? _w : 0
      _y  -= (((_a-1)//3) == 0) ? 0 : (((_a-1)//3) == 1) ? _h/2 : (((_a-1)//3) == 2) ? _h : 0
      ; Fractional y values might cause gdi+ slowdown.


      ; Get the text width and text height.
      ; Note that there are two new lines. Matching a percent symbol (%) will give text width/height
      ; that is relative to the background width/height. This is undesirable behavior, and so
      ; the user should use "vh" and "vw" whenever possible.
      w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : ReturnRC[3] ; Default is simulated text width.
      w  := ( w ~= "(pt|px)$") ? SubStr( w, 1, -2) :  w
      w  := ( w ~= "vw$") ? RegExReplace( w, "vw$", "") * this.vw :  w
      w  := ( w ~= "vh$") ? RegExReplace( w, "vh$", "") * this.vh :  w
      w  := ( w ~= "vmin$") ? RegExReplace( w, "vmin$", "") * this.vmin :  w
      w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * _w :  w

      h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : ReturnRC[4] ; Default is simulated text height.
      h  := ( h ~= "(pt|px)$") ? SubStr( h, 1, -2) :  h
      h  := ( h ~= "vw$") ? RegExReplace( h, "vw$", "") * this.vw :  h
      h  := ( h ~= "vh$") ? RegExReplace( h, "vh$", "") * this.vh :  h
      h  := ( h ~= "vmin$") ? RegExReplace( h, "vmin$", "") * this.vmin :  h
      h  := ( h ~= "%$") ? RegExReplace( h, "%$", "") * 0.01 * _h :  h

      ; If text justification is set but x is not, align the justified text relative to the center
      ; or right of the backgound, after taking into account the text width.
      if (x == "")
         x  := (j = 1) ? _x + (_w/2) - (w/2) : (j = 2) ? _x + _w - w : x

      ; Get anchor.
      a  := RegExReplace( a, "\s", "")
      a  := (a = "top") ? 2 : (a = "left") ? 4 : (a = "right") ? 6 : (a = "bottom") ? 8
         : (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
         : (a ~= "i)top" && a ~= "i)bottom") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
         : (a ~= "i)cent(er|re)") ? 5 : (a ~= "i)cent(er|re)" && a ~= "i)bottom") ? 6
         : (a ~= "i)bottom" && a ~= "i)left") ? 7 : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8
         : (a ~= "i)bottom" && a ~= "i)right") ? 9 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

      ; Text x and text y can be specified as locations (left, center, right, top, bottom).
      ; These location words in text x and text y take precedence over the values in the text anchor.
      a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
      a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

      ; Convert English words to numbers. Don't mess with these values any further.
      ; Also, these values are relative to the background.
      x  := ( x ~= "i)left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*_w : (x ~= "i)right") ? _x + _w : x
      y  := ( y ~= "i)top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*_h : (y ~= "i)bottom") ? _y + _h : y

      ; Validate text x and y, convert to pixels.
      x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : _x ; Default text x is background x.
      x  := ( x ~= "(pt|px)$") ? SubStr( x, 1, -2) :  x
      x  := ( x ~= "vw$") ? RegExReplace( x, "vw$", "") * this.vw :  x
      x  := ( x ~= "vh$") ? RegExReplace( x, "vh$", "") * this.vh :  x
      x  := ( x ~= "vmin$") ? RegExReplace( x, "vmin$", "") * this.vmin :  x
      x  := ( x ~= "%$") ? RegExReplace( x, "%$", "") * 0.01 * _w :  x

      y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : _y ; Default text y is background y.
      y  := ( y ~= "(pt|px)$") ? SubStr( y, 1, -2) :  y
      y  := ( y ~= "vw$") ? RegExReplace( y, "vw$", "") * this.vw :  y
      y  := ( y ~= "vh$") ? RegExReplace( y, "vh$", "") * this.vh :  y
      y  := ( y ~= "vmin$") ? RegExReplace( y, "vmin$", "") * this.vmin :  y
      y  := ( y ~= "%$") ? RegExReplace( y, "%$", "") * 0.01 * _h :  y

      ; Modify text x and text y values with the anchor, so that the text has a new point of origin.
      ; The text anchor is relative to the text width and height before margin/padding.
      ; This is NOT relative to the background width and height.
      x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
      y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

      ; Define margin and padding. Both parameters will leave the text unchanged,
      ; expanding the background box. The difference between the two is NON-EXISTENT.
      ; What does matter is if the margin/padding is a background style, the position of the text will not change.
      ; If the margin/padding is a text style, the text position will change.
      ; THERE REALLY IS NO DIFFERENCE BETWEEN MARGIN AND PADDING.
      _p := this.margin_and_padding(_p)
      _m := this.margin_and_padding(_m)
      p  := this.margin_and_padding( p)
      m  := this.margin_and_padding( m)

      ; Modify _x, _y, _w, _h with margin and padding, increasing the size of the background.
      if (_w || _h) {
         _w  += (_m.2 + _m.4 + _p.2 + _p.4) + (m.2 + m.4 + p.2 + p.4)
         _h  += (_m.1 + _m.3 + _p.1 + _p.3) + (m.1 + m.3 + p.1 + p.3)
         _x  -= (_m.4 + _p.4)
         _y  -= (_m.1 + _p.1)
      }

      ; If margin/padding are defined in the text parameter, shift the position of the text.
      x  += (m.4 + p.4)
      y  += (m.1 + p.1)

      ; Re-run: Condense Text using a Condensed Font if simulated text width exceeds screen width.
      if (Gdip_FontFamilyCreate(z)) {
         if (ReturnRC[3] + x > this.ScreenWidth) {
            this._redrawBecauseOfCondensedFont := true
            return this.Draw(text, style1, style2, pGraphics)
         }
      }

      ; Define radius of rounded corners.
      _r := (_r ~= valid_positive) ? RegExReplace(_r, "\s", "") : 0  ; Default radius is 0, or square corners.
      _r := (_r ~= "(pt|px)$") ? SubStr(_r, 1, -2) : _r
      _r := (_r ~= "vw$") ? RegExReplace(_r, "vw$", "") * this.vw : _r
      _r := (_r ~= "vh$") ? RegExReplace(_r, "vh$", "") * this.vh : _r
      _r := (_r ~= "vmin$") ? RegExReplace(_r, "vmin$", "") * this.vmin : _r
      ; percentage is defined as a percentage of the smaller background width/height.
      _r := (_r ~= "%$") ? RegExReplace(_r, "%$", "") * 0.01 * ((_w > _h) ? _h : _w) : _r
      ; the radius cannot exceed the half width or half height, whichever is smaller.
      _r  := (_r <= ((_w > _h) ? _h : _w) / 2) ? _r : 0

      ; Define color.
      _c := this.color(_c, 0xDD424242) ; Default background color is transparent gray.
      SourceCopy := (c ~= "i)(delete|eraser?|overwrite|sourceCopy)") ? 1 : 0 ; Eraser brush for text.
      c  := (SourceCopy) ? 0x00000000 : this.color( c, 0xFFFFFFFF) ; Default text color is white.

      ; Define outline and dropShadow.
      o := this.outline(o, s, c)
      d := this.dropShadow(d, ReturnRC[3], ReturnRC[4], s)

      ; Round 9 - Define Text
      if (!A_IsUnicode){
         nSize := DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",0, "int",0)
         VarSetCapacity(wtext, nSize*2)
         DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",&wtext, "int",nSize)
      }

      ; Round 10 - Finalize _x, _y, _w, _h
      _x  := Round(_x)
      _y  := Round(_y)
      _w  := Round(_w)
      _h  := Round(_h)

      ; Define image boundaries using the background boundaries.
      this.x  := (this.x  = "" || _x < this.x) ? _x : this.x
      this.y  := (this.y  = "" || _y < this.y) ? _y : this.y
      this.xx := (this.xx = "" || _x + _w > this.xx) ? _x + _w : this.xx
      this.yy := (this.yy = "" || _y + _h > this.yy) ? _y + _h : this.yy

      ; Define image boundaries using the text boundaries + outline boundaries.
      artifacts := Ceil(o.3 + 0.5*o.1)
      this.x  := (x - artifacts < this.x) ? x - artifacts : this.x
      this.y  := (y - artifacts < this.y) ? y - artifacts : this.y
      this.xx := (x + w + artifacts > this.xx) ? x + w + artifacts : this.xx
      this.yy := (y + h + artifacts > this.yy) ? y + h + artifacts : this.yy

      ; Define image boundaries using the dropShadow boundaries.
      artifacts := Ceil(d.3 + d.6 + 0.5*o.1)
      this.x  := (x + d.1 - artifacts < this.x) ? x + d.1 - artifacts : this.x
      this.y  := (y + d.2 - artifacts < this.y) ? y + d.2 - artifacts : this.y
      this.xx := (x + d.1 + w + artifacts > this.xx) ? x + d.1 + w + artifacts : this.xx
      this.yy := (y + d.2 + h + artifacts > this.yy) ? y + d.2 + h + artifacts : this.yy

      ; Round to the nearest integer.
      this.x := Floor(this.x)
      this.y := Floor(this.y)
      this.xx := Ceil(this.xx)
      this.yy := Ceil(this.yy)

      ; Draw 1 - Background
      if (_w && _h && _c && (_c & 0xFF000000)) {
         if (_r == 0)
            Gdip_SetSmoothingMode(pGraphics, 1) ; Turn antialiasing off if not a rounded rectangle.
         pBrushBackground := Gdip_BrushCreateSolid(_c)
         Gdip_FillRoundedRectangle(pGraphics, pBrushBackground, _x, _y, _w, _h, _r) ; DRAWING!
         Gdip_DeleteBrush(pBrushBackground)
         if (_r == 0)
            Gdip_SetSmoothingMode(pGraphics, _q) ; Turn antialiasing on for text rendering.
      }

      ; Draw 2 - DropShadow
      if (!d.void) {
         offset2 := d.3 + d.6 + Ceil(0.5*o.1)

         if (d.3) {
            DropShadow := Gdip_CreateBitmap(w + 2*offset2, h + 2*offset2)
            DropShadowG := Gdip_GraphicsFromImage(DropShadow)
            Gdip_SetSmoothingMode(DropShadowG, _q)
            Gdip_SetTextRenderingHint(DropShadowG, q)
            CreateRectF(RC, offset2, offset2, w + 2*offset2, h + 2*offset2)
         } else {
            CreateRectF(RC, x + d.1, y + d.2, w, h)
            DropShadowG := pGraphics
         }

         ; Use Gdip_DrawString if and only if there is a horizontal/vertical offset.
         if (o.void && d.6 == 0)
         {
            pBrush := Gdip_BrushCreateSolid(d.4)
            Gdip_DrawString(DropShadowG, Text, hFont, hFormat, pBrush, RC) ; DRAWING!
            Gdip_DeleteBrush(pBrush)
         }
         else ; Otherwise, use the below code if blur, size, and opacity are set.
         {
            ; Draw the outer edge of the text string.
            DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
            DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                               , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)
            pPen := Gdip_CreatePen(d.4, 2*d.6 + o.1)
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)
            DllCall("gdiplus\GdipDrawPath", "ptr",DropShadowG, "ptr",pPen, "ptr",pPath)
            Gdip_DeletePen(pPen)

            ; Fill in the outline. Turn off antialiasing and alpha blending so the gaps are 100% filled.
            pBrush := Gdip_BrushCreateSolid(d.4)
            Gdip_SetCompositingMode(DropShadowG, 1) ; Turn off alpha blending
            Gdip_SetSmoothingMode(DropShadowG, 3)   ; Turn off anti-aliasing
            Gdip_FillPath(DropShadowG, pBrush, pPath)
            Gdip_DeleteBrush(pBrush)
            Gdip_DeletePath(pPath)
            Gdip_SetCompositingMode(DropShadowG, 0)
            Gdip_SetSmoothingMode(DropShadowG, _q)
         }

         if (d.3) {
            Gdip_DeleteGraphics(DropShadowG)
            this.GaussianBlur(DropShadow, d.3, d.5)
            Gdip_SetInterpolationMode(pGraphics, 5) ; NearestNeighbor
            Gdip_SetSmoothingMode(pGraphics, 3) ; Turn off anti-aliasing
            Gdip_DrawImage(pGraphics, DropShadow, x + d.1 - offset2, y + d.2 - offset2, w + 2*offset2, h + 2*offset2) ; DRAWING!
            Gdip_SetSmoothingMode(pGraphics, _q)
            Gdip_DisposeImage(DropShadow)
         }
      }

      ; Draw 3 - Text Outline
      if (!o.void) {
         ; Convert our text to a path.
         CreateRectF(RC, x, y, w, h)
         DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
         DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                            , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)

         ; Create a glow effect around the edges.
         if (o.3) {
            Gdip_SetClipPath(pGraphics, pPath, 3) ; Exclude original text region from being drawn on.
            pPenGlow := Gdip_CreatePen(Format("0x{:02X}",((o.4 & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(o.4 & 0x00FFFFFF)), 1)
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPenGlow, "uint",2)

            loop % o.3
            {
               DllCall("gdiplus\GdipSetPenWidth", "ptr",pPenGlow, "float",o.1 + 2*A_Index)
               DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPenGlow, "ptr",pPath) ; DRAWING!
            }
            Gdip_DeletePen(pPenGlow)
            Gdip_ResetClip(pGraphics)
         }

         ; Draw outline text.
         if (o.1) {
            pPen := Gdip_CreatePen(o.2, o.1)
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)
            DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath) ; DRAWING!
            Gdip_DeletePen(pPen)
         }

         ; Fill outline text.
         pBrush := Gdip_BrushCreateSolid(c)
         Gdip_SetCompositingMode(pGraphics, SourceCopy)
         Gdip_FillPath(pGraphics, pBrush, pPath) ; DRAWING!
         Gdip_SetCompositingMode(pGraphics, 0)
         Gdip_DeleteBrush(pBrush)
         Gdip_DeletePath(pPath)
      }

      ; Draw Text if outline is not are not specified.
      if (text != "" && o.void) {
         CreateRectF(RC, x, y, w, h)
         pBrushText := Gdip_BrushCreateSolid(c)
         Gdip_SetCompositingMode(pGraphics, SourceCopy)
         Gdip_DrawString(pGraphics, A_IsUnicode ? text : wtext, hFont, hFormat, pBrushText, RC) ; DRAWING!
         Gdip_SetCompositingMode(pGraphics, 0)
         Gdip_DeleteBrush(pBrushText)
      }

      ; Delete Font Objects.
      Gdip_DeleteStringFormat(hFormat)
      Gdip_DeleteFont(hFont)
      Gdip_DeleteFontFamily(hFamily)

      return (pGraphics == "") ? this : ""
   }

   color(c, default := 0xDD424242) {
      static colorRGB  := "^0x([0-9A-Fa-f]{6})$"
      static colorARGB := "^0x([0-9A-Fa-f]{8})$"
      static hex6      :=   "^([0-9A-Fa-f]{6})$"
      static hex8      :=   "^([0-9A-Fa-f]{8})$"

      if ObjGetCapacity([c], 1) {
         c  := (c ~= "^#") ? SubStr(c, 2) : c
         c  := ((___ := this.colorMap(c)) != "") ? ___ : c
         c  := (c ~= colorRGB) ? "0xFF" RegExReplace(c, colorRGB, "$1") : (c ~= hex8) ? "0x" c : (c ~= hex6) ? "0xFF" c : c
         c  := (c ~= colorARGB) ? c : default
      }
      return (c != "") ? c : default
   }

   dropShadow(d, x_simulated, y_simulated, font_size) {
      static valid := "^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      if IsObject(d) {
         d.1 := (d.1) ? d.1 : (d.horizontal != "") ? d.horizontal : d.h
         d.2 := (d.2) ? d.2 : (d.vertical   != "") ? d.vertical   : d.v
         d.3 := (d.3) ? d.3 : (d.blur       != "") ? d.blur       : d.b
         d.4 := (d.4) ? d.4 : (d.color      != "") ? d.color      : d.c
         d.5 := (d.5) ? d.5 : (d.opacity    != "") ? d.opacity    : d.o
         d.6 := (d.6) ? d.6 : (d.size       != "") ? d.size       : d.s
      } else if (d != "") {
         _ := RegExReplace(d, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.1 := ((___ := RegExReplace(d, q1    "(h(orizontal)?)"    q2, "${value}")) != d) ? ___ : _.1
         _.2 := ((___ := RegExReplace(d, q1    "(v(ertical)?)"      q2, "${value}")) != d) ? ___ : _.2
         _.3 := ((___ := RegExReplace(d, q1    "(b(lur)?)"          q2, "${value}")) != d) ? ___ : _.3
         _.4 := ((___ := RegExReplace(d, q1    "(c(olor)?)"         q2, "${value}")) != d) ? ___ : _.4
         _.5 := ((___ := RegExReplace(d, q1    "(o(pacity)?)"       q2, "${value}")) != d) ? ___ : _.5
         _.6 := ((___ := RegExReplace(d, q1    "(s(ize)?)"          q2, "${value}")) != d) ? ___ : _.6
         d := _
      }
      else return {"void":true, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0}

      for key, value in d {
         if (key = 4) ; Don't mess with color data.
            continue
         d[key] := (d[key] ~= valid) ? RegExReplace(d[key], "\s", "") : 0 ; Default for everything is 0.
         d[key] := (d[key] ~= "(pt|px)$") ? SubStr(d[key], 1, -2) : d[key]
         d[key] := (d[key] ~= "vw$") ? RegExReplace(d[key], "vw$", "") * this.vw : d[key]
         d[key] := (d[key] ~= "vh$") ? RegExReplace(d[key], "vh$", "") * this.vh : d[key]
         d[key] := (d[key] ~= "vmin$") ? RegExReplace(d[key], "vmin$", "") * this.vmin : d[key]
      }

      d.1 := (d.1 ~= "%$") ? SubStr(d.1, 1, -1) * 0.01 * x_simulated : d.1
      d.2 := (d.2 ~= "%$") ? SubStr(d.2, 1, -1) * 0.01 * y_simulated : d.2
      d.3 := (d.3 ~= "%$") ? SubStr(d.3, 1, -1) * 0.01 * font_size : d.3
      d.4 := this.color(d.4, 0xFFFF0000) ; Default color is red.
      d.5 := (d.5 ~= "%$") ? SubStr(d.5, 1, -1) / 100 : d.5
      d.5 := (d.5 <= 0 || d.5 > 1) ? 1 : d.5 ; Range Opacity is a float from 0-1.
      d.6 := (d.6 ~= "%$") ? SubStr(d.6, 1, -1) * 0.01 * font_size : d.6
      return d
   }

   font(f, default := "Arial"){

   }

   margin_and_padding(m, default := 0) {
      static valid := "^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      if IsObject(m) {
         m.1 := (m.top    != "") ? m.top    : m.t
         m.2 := (m.right  != "") ? m.right  : m.r
         m.3 := (m.bottom != "") ? m.bottom : m.b
         m.4 := (m.left   != "") ? m.left   : m.l
      } else if (m != "") {
         _ := RegExReplace(m, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.1 := ((___ := RegExReplace(m, q1    "(t(op)?)"           q2, "${value}")) != m) ? ___ : _.1
         _.2 := ((___ := RegExReplace(m, q1    "(r(ight)?)"         q2, "${value}")) != m) ? ___ : _.2
         _.3 := ((___ := RegExReplace(m, q1    "(b(ottom)?)"        q2, "${value}")) != m) ? ___ : _.3
         _.4 := ((___ := RegExReplace(m, q1    "(l(eft)?)"          q2, "${value}")) != m) ? ___ : _.4
         m := _
      }
      else return {1:default, 2:default, 3:default, 4:default}

      ; Follow CSS guidelines for margin!
      if (m.2 == "" && m.3 == "" && m.4 == "")
         m.4 := m.3 := m.2 := m.1, exception := true
      if (m.3 == "" && m.4 == "")
         m.4 := m.2, m.3 := m.1
      if (m.4 == "")
         m.4 := m.2

      for key, value in m {
         m[key] := (m[key] ~= valid) ? RegExReplace(m[key], "\s", "") : default
         m[key] := (m[key] ~= "(pt|px)$") ? SubStr(m[key], 1, -2) : m[key]
         m[key] := (m[key] ~= "vw$") ? RegExReplace(m[key], "vw$", "") * this.vw : m[key]
         m[key] := (m[key] ~= "vh$") ? RegExReplace(m[key], "vh$", "") * this.vh : m[key]
         m[key] := (m[key] ~= "vmin$") ? RegExReplace(m[key], "vmin$", "") * this.vmin : m[key]
      }
      m.1 := (m.1 ~= "%$") ? SubStr(m.1, 1, -1) * this.vh : m.1
      m.2 := (m.2 ~= "%$") ? SubStr(m.2, 1, -1) * (exception ? this.vh : this.vw) : m.2
      m.3 := (m.3 ~= "%$") ? SubStr(m.3, 1, -1) * this.vh : m.3
      m.4 := (m.4 ~= "%$") ? SubStr(m.4, 1, -1) * (exception ? this.vh : this.vw) : m.4
      return m
   }

   outline(o, font_size, font_color) {
      static valid_positive := "^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      if IsObject(o) {
         o.1 := (o.1) ? o.1 : (o.stroke != "") ? o.stroke : o.s
         o.2 := (o.2) ? o.2 : (o.color  != "") ? o.color  : o.c
         o.3 := (o.3) ? o.3 : (o.glow   != "") ? o.glow   : o.g
         o.4 := (o.4) ? o.4 : (o.tint   != "") ? o.tint   : o.t
      } else if (o != "") {
         _ := RegExReplace(o, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.1 := ((___ := RegExReplace(o, q1    "(s(troke)?)"        q2, "${value}")) != o) ? ___ : _.1
         _.2 := ((___ := RegExReplace(o, q1    "(c(olor)?)"         q2, "${value}")) != o) ? ___ : _.2
         _.3 := ((___ := RegExReplace(o, q1    "(g(low)?)"          q2, "${value}")) != o) ? ___ : _.3
         _.4 := ((___ := RegExReplace(o, q1    "(t(int)?)"          q2, "${value}")) != o) ? ___ : _.4
         o := _
      }
      else return {"void":true, 1:0, 2:0, 3:0, 4:0}

      for key, value in o {
         if (key = 2) || (key = 4) ; Don't mess with color data.
            continue
         o[key] := (o[key] ~= valid_positive) ? RegExReplace(o[key], "\s", "") : 0 ; Default for everything is 0.
         o[key] := (o[key] ~= "(pt|px)$") ? SubStr(o[key], 1, -2) : o[key]
         o[key] := (o[key] ~= "vw$") ? RegExReplace(o[key], "vw$", "") * this.vw : o[key]
         o[key] := (o[key] ~= "vh$") ? RegExReplace(o[key], "vh$", "") * this.vh : o[key]
         o[key] := (o[key] ~= "vmin$") ? RegExReplace(o[key], "vmin$", "") * this.vmin : o[key]
      }

      o.1 := (o.1 ~= "%$") ? SubStr(o.1, 1, -1) * 0.01 * font_size : o.1
      o.2 := this.color(o.2, font_color) ; Default color is the text font color.
      o.3 := (o.3 ~= "%$") ? SubStr(o.3, 1, -1) * 0.01 * font_size : o.3
      o.4 := this.color(o.4, o.2) ; Default color is outline color.
      return o
   }

   colorMap(c) {
      static map

      if !(map) {
      color := [] ; 73 LINES MAX
      color["Clear"] := color["Off"] := color["None"] := color["Transparent"] := "0x00000000"

         color["AliceBlue"]             := "0xFFF0F8FF"
      ,  color["AntiqueWhite"]          := "0xFFFAEBD7"
      ,  color["Aqua"]                  := "0xFF00FFFF"
      ,  color["Aquamarine"]            := "0xFF7FFFD4"
      ,  color["Azure"]                 := "0xFFF0FFFF"
      ,  color["Beige"]                 := "0xFFF5F5DC"
      ,  color["Bisque"]                := "0xFFFFE4C4"
      ,  color["Black"]                 := "0xFF000000"
      ,  color["BlanchedAlmond"]        := "0xFFFFEBCD"
      ,  color["Blue"]                  := "0xFF0000FF"
      ,  color["BlueViolet"]            := "0xFF8A2BE2"
      ,  color["Brown"]                 := "0xFFA52A2A"
      ,  color["BurlyWood"]             := "0xFFDEB887"
      ,  color["CadetBlue"]             := "0xFF5F9EA0"
      ,  color["Chartreuse"]            := "0xFF7FFF00"
      ,  color["Chocolate"]             := "0xFFD2691E"
      ,  color["Coral"]                 := "0xFFFF7F50"
      ,  color["CornflowerBlue"]        := "0xFF6495ED"
      ,  color["Cornsilk"]              := "0xFFFFF8DC"
      ,  color["Crimson"]               := "0xFFDC143C"
      ,  color["Cyan"]                  := "0xFF00FFFF"
      ,  color["DarkBlue"]              := "0xFF00008B"
      ,  color["DarkCyan"]              := "0xFF008B8B"
      ,  color["DarkGoldenRod"]         := "0xFFB8860B"
      ,  color["DarkGray"]              := "0xFFA9A9A9"
      ,  color["DarkGrey"]              := "0xFFA9A9A9"
      ,  color["DarkGreen"]             := "0xFF006400"
      ,  color["DarkKhaki"]             := "0xFFBDB76B"
      ,  color["DarkMagenta"]           := "0xFF8B008B"
      ,  color["DarkOliveGreen"]        := "0xFF556B2F"
      ,  color["DarkOrange"]            := "0xFFFF8C00"
      ,  color["DarkOrchid"]            := "0xFF9932CC"
      ,  color["DarkRed"]               := "0xFF8B0000"
      ,  color["DarkSalmon"]            := "0xFFE9967A"
      ,  color["DarkSeaGreen"]          := "0xFF8FBC8F"
      ,  color["DarkSlateBlue"]         := "0xFF483D8B"
      ,  color["DarkSlateGray"]         := "0xFF2F4F4F"
      ,  color["DarkSlateGrey"]         := "0xFF2F4F4F"
      ,  color["DarkTurquoise"]         := "0xFF00CED1"
      ,  color["DarkViolet"]            := "0xFF9400D3"
      ,  color["DeepPink"]              := "0xFFFF1493"
      ,  color["DeepSkyBlue"]           := "0xFF00BFFF"
      ,  color["DimGray"]               := "0xFF696969"
      ,  color["DimGrey"]               := "0xFF696969"
      ,  color["DodgerBlue"]            := "0xFF1E90FF"
      ,  color["FireBrick"]             := "0xFFB22222"
      ,  color["FloralWhite"]           := "0xFFFFFAF0"
      ,  color["ForestGreen"]           := "0xFF228B22"
      ,  color["Fuchsia"]               := "0xFFFF00FF"
      ,  color["Gainsboro"]             := "0xFFDCDCDC"
      ,  color["GhostWhite"]            := "0xFFF8F8FF"
      ,  color["Gold"]                  := "0xFFFFD700"
      ,  color["GoldenRod"]             := "0xFFDAA520"
      ,  color["Gray"]                  := "0xFF808080"
      ,  color["Grey"]                  := "0xFF808080"
      ,  color["Green"]                 := "0xFF008000"
      ,  color["GreenYellow"]           := "0xFFADFF2F"
      ,  color["HoneyDew"]              := "0xFFF0FFF0"
      ,  color["HotPink"]               := "0xFFFF69B4"
      ,  color["IndianRed"]             := "0xFFCD5C5C"
      ,  color["Indigo"]                := "0xFF4B0082"
      ,  color["Ivory"]                 := "0xFFFFFFF0"
      ,  color["Khaki"]                 := "0xFFF0E68C"
      ,  color["Lavender"]              := "0xFFE6E6FA"
      ,  color["LavenderBlush"]         := "0xFFFFF0F5"
      ,  color["LawnGreen"]             := "0xFF7CFC00"
      ,  color["LemonChiffon"]          := "0xFFFFFACD"
      ,  color["LightBlue"]             := "0xFFADD8E6"
      ,  color["LightCoral"]            := "0xFFF08080"
      ,  color["LightCyan"]             := "0xFFE0FFFF"
      ,  color["LightGoldenRodYellow"]  := "0xFFFAFAD2"
      ,  color["LightGray"]             := "0xFFD3D3D3"
      ,  color["LightGrey"]             := "0xFFD3D3D3"
         color["LightGreen"]            := "0xFF90EE90"
      ,  color["LightPink"]             := "0xFFFFB6C1"
      ,  color["LightSalmon"]           := "0xFFFFA07A"
      ,  color["LightSeaGreen"]         := "0xFF20B2AA"
      ,  color["LightSkyBlue"]          := "0xFF87CEFA"
      ,  color["LightSlateGray"]        := "0xFF778899"
      ,  color["LightSlateGrey"]        := "0xFF778899"
      ,  color["LightSteelBlue"]        := "0xFFB0C4DE"
      ,  color["LightYellow"]           := "0xFFFFFFE0"
      ,  color["Lime"]                  := "0xFF00FF00"
      ,  color["LimeGreen"]             := "0xFF32CD32"
      ,  color["Linen"]                 := "0xFFFAF0E6"
      ,  color["Magenta"]               := "0xFFFF00FF"
      ,  color["Maroon"]                := "0xFF800000"
      ,  color["MediumAquaMarine"]      := "0xFF66CDAA"
      ,  color["MediumBlue"]            := "0xFF0000CD"
      ,  color["MediumOrchid"]          := "0xFFBA55D3"
      ,  color["MediumPurple"]          := "0xFF9370DB"
      ,  color["MediumSeaGreen"]        := "0xFF3CB371"
      ,  color["MediumSlateBlue"]       := "0xFF7B68EE"
      ,  color["MediumSpringGreen"]     := "0xFF00FA9A"
      ,  color["MediumTurquoise"]       := "0xFF48D1CC"
      ,  color["MediumVioletRed"]       := "0xFFC71585"
      ,  color["MidnightBlue"]          := "0xFF191970"
      ,  color["MintCream"]             := "0xFFF5FFFA"
      ,  color["MistyRose"]             := "0xFFFFE4E1"
      ,  color["Moccasin"]              := "0xFFFFE4B5"
      ,  color["NavajoWhite"]           := "0xFFFFDEAD"
      ,  color["Navy"]                  := "0xFF000080"
      ,  color["OldLace"]               := "0xFFFDF5E6"
      ,  color["Olive"]                 := "0xFF808000"
      ,  color["OliveDrab"]             := "0xFF6B8E23"
      ,  color["Orange"]                := "0xFFFFA500"
      ,  color["OrangeRed"]             := "0xFFFF4500"
      ,  color["Orchid"]                := "0xFFDA70D6"
      ,  color["PaleGoldenRod"]         := "0xFFEEE8AA"
      ,  color["PaleGreen"]             := "0xFF98FB98"
      ,  color["PaleTurquoise"]         := "0xFFAFEEEE"
      ,  color["PaleVioletRed"]         := "0xFFDB7093"
      ,  color["PapayaWhip"]            := "0xFFFFEFD5"
      ,  color["PeachPuff"]             := "0xFFFFDAB9"
      ,  color["Peru"]                  := "0xFFCD853F"
      ,  color["Pink"]                  := "0xFFFFC0CB"
      ,  color["Plum"]                  := "0xFFDDA0DD"
      ,  color["PowderBlue"]            := "0xFFB0E0E6"
      ,  color["Purple"]                := "0xFF800080"
      ,  color["RebeccaPurple"]         := "0xFF663399"
      ,  color["Red"]                   := "0xFFFF0000"
      ,  color["RosyBrown"]             := "0xFFBC8F8F"
      ,  color["RoyalBlue"]             := "0xFF4169E1"
      ,  color["SaddleBrown"]           := "0xFF8B4513"
      ,  color["Salmon"]                := "0xFFFA8072"
      ,  color["SandyBrown"]            := "0xFFF4A460"
      ,  color["SeaGreen"]              := "0xFF2E8B57"
      ,  color["SeaShell"]              := "0xFFFFF5EE"
      ,  color["Sienna"]                := "0xFFA0522D"
      ,  color["Silver"]                := "0xFFC0C0C0"
      ,  color["SkyBlue"]               := "0xFF87CEEB"
      ,  color["SlateBlue"]             := "0xFF6A5ACD"
      ,  color["SlateGray"]             := "0xFF708090"
      ,  color["SlateGrey"]             := "0xFF708090"
      ,  color["Snow"]                  := "0xFFFFFAFA"
      ,  color["SpringGreen"]           := "0xFF00FF7F"
      ,  color["SteelBlue"]             := "0xFF4682B4"
      ,  color["Tan"]                   := "0xFFD2B48C"
      ,  color["Teal"]                  := "0xFF008080"
      ,  color["Thistle"]               := "0xFFD8BFD8"
      ,  color["Tomato"]                := "0xFFFF6347"
      ,  color["Turquoise"]             := "0xFF40E0D0"
      ,  color["Violet"]                := "0xFFEE82EE"
      ,  color["Wheat"]                 := "0xFFF5DEB3"
      ,  color["White"]                 := "0xFFFFFFFF"
      ,  color["WhiteSmoke"]            := "0xFFF5F5F5"
         color["Yellow"]                := "0xFFFFFF00"
      ,  color["YellowGreen"]           := "0xFF9ACD32"
      map := color
      }

      return map[c]
   }

   GaussianBlur(ByRef pBitmap, radius, opacity := 1) {
      static x86 := "
      (LTrim
      VYnlV1ZTg+xci0Uci30c2UUgx0WsAwAAAI1EAAGJRdiLRRAPr0UYicOJRdSLRRwP
      r/sPr0UYiX2ki30UiUWoi0UQjVf/i30YSA+vRRgDRQgPr9ONPL0SAAAAiUWci0Uc
      iX3Eg2XE8ECJVbCJRcCLRcSJZbToAAAAACnEi0XEiWXk6AAAAAApxItFxIllzOgA
      AAAAKcSLRaiJZcjHRdwAAAAAx0W8AAAAAIlF0ItFvDtFFA+NcAEAAItV3DHAi12c
      i3XQiVXgAdOLfQiLVdw7RRiNDDp9IQ+2FAGLTcyLfciJFIEPtgwDD69VwIkMh4tN
      5IkUgUDr0THSO1UcfBKLXdwDXQzHRbgAAAAAK13Q6yAxwDtFGH0Ni33kD7YcAQEc
      h0Dr7kIDTRjrz/9FuAN1GItF3CtF0AHwiceLRbg7RRx/LDHJO00YfeGLRQiLfcwB
      8A+2BAgrBI+LfeQDBI+ZiQSPjTwz933YiAQPQevWi0UIK0Xci03AAfCJRbiLXRCJ
      /itdHCt13AN14DnZfAgDdQwrdeDrSot1DDHbK3XcAf4DdeA7XRh9KItV4ItFuAHQ
      A1UID7YEGA+2FBop0ItV5AMEmokEmpn3fdiIBB5D69OLRRhBAUXg66OLRRhDAUXg
      O10QfTIxyTtNGH3ti33Ii0XgA0UID7YUCIsEjynQi1XkAwSKiQSKi1XgjTwWmfd9
      2IgED0Hr0ItF1P9FvAFF3AFF0OmE/v//i0Wkx0XcAAAAAMdFvAAAAACJRdCLRbAD
      RQyJRaCLRbw7RRAPjXABAACLTdwxwItdoIt10IlN4AHLi30Mi1XcO0UYjQw6fSEP
      thQBi33MD7YMA4kUh4t9yA+vVcCJDIeLTeSJFIFA69Ex0jtVHHwSi13cA10Ix0W4
      AAAAACtd0OsgMcA7RRh9DYt95A+2HAEBHIdA6+5CA03U68//RbgDddSLRdwrRdAB
      8InHi0W4O0UcfywxyTtNGH3hi0UMi33MAfAPtgQIKwSPi33kAwSPmYkEj408M/d9
      2IgED0Hr1otFDCtF3ItNwAHwiUW4i10Uif4rXRwrddwDdeA52XwIA3UIK3Xg60qL
      dQgx2yt13AH+A3XgO10YfSiLVeCLRbgB0ANVDA+2BBgPthQaKdCLVeQDBJqJBJqZ
      933YiAQeQ+vTi0XUQQFF4Ouji0XUQwFF4DtdFH0yMck7TRh97Yt9yItF4ANFDA+2
      FAiLBI+LfeQp0ItV4AMEj4kEj408Fpn3fdiIBA9B69CLRRj/RbwBRdwBRdDphP7/
      //9NrItltA+Fofz//9no3+l2PzHJMds7XRR9OotFGIt9CA+vwY1EBwMx/zt9EH0c
      D7Yw2cBHVtoMJFrZXeTzDyx15InyiBADRRjr30MDTRDrxd3Y6wLd2I1l9DHAW15f
      XcM=
      )"
      static x64 := "
      (LTrim
      VUFXQVZBVUFUV1ZTSIHsqAAAAEiNrCSAAAAARIutkAAAAIuFmAAAAESJxkiJVRhB
      jVH/SYnPi42YAAAARInHQQ+v9Y1EAAErvZgAAABEiUUARIlN2IlFFEljxcdFtAMA
      AABIY96LtZgAAABIiUUID6/TiV0ESIld4A+vy4udmAAAAIl9qPMPEI2gAAAAiVXQ
      SI0UhRIAAABBD6/1/8OJTbBIiVXoSINl6PCJXdxBifaJdbxBjXD/SWPGQQ+v9UiJ
      RZhIY8FIiUWQiXW4RInOK7WYAAAAiXWMSItF6EiJZcDoAAAAAEgpxEiLRehIieHo
      AAAAAEgpxEiLRehIiWX46AAAAABIKcRIi0UYTYn6SIll8MdFEAAAAADHRdQAAAAA
      SIlFyItF2DlF1A+NqgEAAESLTRAxwEWJyEQDTbhNY8lNAflBOcV+JUEPthQCSIt9
      +EUPthwBSItd8IkUhw+vVdxEiRyDiRSBSP/A69aLVRBFMclEO42YAAAAfA9Ii0WY
      RTHbMdtNjSQC6ytMY9oxwE0B+0E5xX4NQQ+2HAMBHIFI/8Dr7kH/wUQB6uvGTANd
      CP/DRQHoO52YAAAAi0W8Ro00AH82SItFyEuNPCNFMclJjTQDRTnNftRIi1X4Qg+2
      BA9CKwSKQgMEiZlCiQSJ930UQogEDkn/wevZi0UQSWP4SAN9GItd3E1j9kUx200B
      /kQpwIlFrEiJfaCLdaiLRaxEAcA580GJ8XwRSGP4TWPAMdtMAf9MA0UY60tIi0Wg
      S408Hk+NJBNFMclKjTQYRTnNfiFDD7YUDEIPtgQPKdBCAwSJmUKJBIn3fRRCiAQO
      Sf/B69r/w0UB6EwDXQjrm0gDXQhB/8FEO00AfTRMjSQfSY00GEUx20U53X7jSItF
      8EMPthQcQosEmCnQQgMEmZlCiQSZ930UQogEHkn/w+vXi0UEAUUQSItF4P9F1EgB
      RchJAcLpSv7//0yLVRhMiX3Ix0UQAAAAAMdF1AAAAACLRQA5RdQPja0BAABEi00Q
      McBFichEA03QTWPJTANNGEE5xX4lQQ+2FAJIi3X4RQ+2HAFIi33wiRSGD69V3ESJ
      HIeJFIFI/8Dr1otVEEUxyUQ7jZgAAAB8D0iLRZBFMdsx202NJALrLUxj2kwDXRgx
      wEE5xX4NQQ+2HAMBHIFI/8Dr7kH/wQNVBOvFRANFBEwDXeD/wzudmAAAAItFsEaN
      NAB/NkiLRchLjTwjRTHJSY00A0U5zX7TSItV+EIPtgQPQisEikIDBImZQokEifd9
      FEKIBA5J/8Hr2YtFEE1j9klj+EwDdRiLXdxFMdtEKcCJRaxJjQQ/SIlFoIt1jItF
      rEQBwDnzQYnxfBFNY8BIY/gx20gDfRhNAfjrTEiLRaBLjTweT40kE0UxyUqNNBhF
      Oc1+IUMPthQMQg+2BA8p0EIDBImZQokEifd9FEKIBA5J/8Hr2v/DRANFBEwDXeDr
      mkgDXeBB/8FEO03YfTRMjSQfSY00GEUx20U53X7jSItF8EMPthQcQosEmCnQQgME
      mZlCiQSZ930UQogEHkn/w+vXSItFCP9F1EQBbRBIAUXISQHC6Uf+////TbRIi2XA
      D4Ui/P//8w8QBQAAAAAPLsF2TTHJRTHARDtF2H1Cicgx0kEPr8VImEgrRQhNjQwH
      McBIA0UIO1UAfR1FD7ZUAQP/wvNBDyrC8w9ZwfNEDyzQRYhUAQPr2kH/wANNAOu4
      McBIjWUoW15fQVxBXUFeQV9dw5CQkJCQkJCQkJCQkJAAAIA/
      )"
      width := Gdip_GetImageWidth(pBitmap)
      height := Gdip_GetImageHeight(pBitmap)
      clone := Gdip_CloneBitmapArea(pBitmap, 0, 0, width, height)
      E1 := Gdip_LockBits(pBitmap, 0, 0, width, height, Stride1, Scan01, BitmapData1)
      E2 := Gdip_LockBits(clone, 0, 0, width, height, Stride2, Scan02, BitmapData2)

      DllCall("crypt32\CryptStringToBinary", "str",(A_PtrSize == 8) ? x64 : x86, "uint",0, "uint",0x1, "ptr",0, "uint*",s, "ptr",0, "ptr",0)
      p := DllCall("GlobalAlloc", "uint",0, "ptr",s, "ptr")
      if (A_PtrSize == 8)
         DllCall("VirtualProtect", "ptr",p, "ptr",s, "uint",0x40, "uint*",op)
      DllCall("crypt32\CryptStringToBinary", "str",(A_PtrSize == 8) ? x64 : x86, "uint",0, "uint",0x1, "ptr",p, "uint*",s, "ptr",0, "ptr",0)
      value := DllCall(p, "ptr",Scan01, "ptr",Scan02, "uint",width, "uint",height, "uint",4, "uint",radius, "float",opacity)
      DllCall("GlobalFree", "ptr", p)

      Gdip_UnlockBits(pBitmap, BitmapData1)
      Gdip_UnlockBits(clone, BitmapData2)
      Gdip_DisposeImage(clone)
      return value
   }

   outer[]
   {
      get {
         ; Determine if there is a parent class. this.__class will retrive the
         ; current instance's class name. Array notation [] will dereference.
         ; Returns void if this function is not nested in at least 2 classes.
         if ((_class := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
            Loop, Parse, _class, .
               outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
         return outer
      }
   }

   x1() {
      return this.x
   }

   y1() {
      return this.y
   }

   x2() {
      return this.xx
   }

   y2() {
      return this.yy
   }

   width() {
      return this.xx - this.x
   }

   height() {
      return this.yy - this.y
   }
} ; End of Subtitle class.
