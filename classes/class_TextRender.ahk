; Script:    TextRender.ahk
; License:   MIT License
; Author:    Edison Hua (iseahound)
; Github:    https://github.com/iseahound/TextRender
; Date:      2022-06-13
; Version:   1.8.0

#Requires AutoHotkey v1.1.33+
#Persistent

; TextRender() - Display custom text on screen.
TextRender(text:="", background_style:="", text_style:="") {
   if (text == "" && background_style == "" && text_style == "")
      return new TextRender
   return (new TextRender).Render(text, background_style, text_style)
}

class TextRender {

   static windows := {}

   __New(title := "", style := 0x80000000, styleEx := 0x80088, parent := "") {
      this.gdiplusStartup()

      ; Create and show the window with DPI awareness PER_MONITOR_AWARE.
      dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
      if !(this.hwnd := this.CreateWindow(title, style, styleEx, parent))
         throw Exception("Max threads reached. Set #MaxThreads to a higher limit.")
      DllCall("ShowWindow", "ptr", this.hwnd, "int", 4) ; SW_SHOWNOACTIVATE
      DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

      ; Store a reference to this object accessed by the window handle.
      ; When processing window messages the hwnd can be used to retrieve "this".
      TextRender.windows[this.hwnd] := this
      ObjRelease(&this) ; Allow __Delete() to be called. RefCount - 1.

      ; Initalize default events.
      this.events := {}
      this.OnEvent("LeftMouseDown", this.EventMoveWindow)
      this.OnEvent("MiddleMouseDown", this.EventShowCoordinates)
      this.OnEvent("RightMouseDown", this.EventCopyData)

      ; Calls Flush() to allocate the graphics buffer via UpdateMemory().
      this.flush_pending := True

      ; xd
      this.hdc := ""
      this.BitmapWidth := 0, this.BitmapHeight := 0
      this.x := ""
      this.status := ""
      this.style1 := ""
      this.style2 := ""

      return this
   }

   __Delete() {
      ; FreeMemory() is called by DestroyWindow().
      this.DestroyWindow()
      this.gdiplusShutdown()

      ; Re-add the reference to avoid calling __Delete() twice.
      ; An unmanaged reference to "this" should be deleted manually.
      ObjAddRef(&this)
      TextRender.windows[this.hwnd] := ""
   }

   Default() {
      ; Left Click to drag. Right click to close.
      return this
         .OnEvent("MiddleMouseDown")
         .OnEvent("RightMouseDown")
         .OnEvent("RightMouseUp", this.DestroyWindow)
   }

   None() {
      ; Removes all events.
      return this
         .OnEvent("LeftMouseDown")
         .OnEvent("MiddleMouseDown")
         .OnEvent("RightMouseDown")
   }

   Show() {
      DllCall("ShowWindow", "ptr", this.hwnd, "int", 4) ; SW_SHOWNOACTIVATE
      return this
   }

   Hide() {
      DllCall("ShowWindow", "ptr", this.hwnd, "int", 0) ; SW_HIDE
      return this
   }

   ToggleVisible() {
      DllCall("IsWindowVisible", "ptr", this.hwnd) ? this.Hide() : this.Show()
      return this
   }

   TopMost() {
      WinSet AlwaysOnTop, On, % "ahk_id" this.hwnd
      return this
   }

   AlwaysOnTop() {
      WinSet AlwaysOnTop, Toggle, % "ahk_id" this.hwnd
      return this
   }

   ClickThrough() {
      return this.ToggleExStyle(0x20)
   }

   NoActivate() {
      return this.ToggleExStyle(0x8000000)
   }

   ToggleStyle(long) {
      return this.ToggleWindowLong(-16, long)
   }

   ToggleExStyle(long) {
      return this.ToggleWindowLong(-20, long)
   }

   ToggleWindowLong(index, long) {
      value := DllCall("GetWindowLong", "ptr", this.hwnd, "int", index, "int")
      (value & long) == long
         ? DllCall("SetWindowLong", "ptr", this.hwnd, "int", index, "int", value ^ long)
         : DllCall("SetWindowLong", "ptr", this.hwnd, "int", index, "int", value | long)
      return this
   }

   Render(terms*) {

      this.Draw(terms*)

      ; Allow Render() to commit only when previous calls to Draw() have occurred.
      if (this.layers.length() > 0) {

         ; Reminder: Only the visible screen area will be rendered. Clipping will occur.
         this.UpdateLayeredWindow()

         ; Ensure that Flush() will be called at the start of a new drawing.
         ; This approach keeps this.layers and the underlying graphics intact,
         ; so that calls to Save() and Screenshot() will not encounter a blank canvas.
         this.flush_pending := True

         ; Start Timestamp
         DllCall("QueryPerformanceCounter", "int64*", start:=0)
         this.t0 := start

         ; Create a timer that eventually clears the canvas.
         if (this.t > 0) {
            ; Create a reference to the object held by a timer.
            blank := ObjBindMethod(this, "blank", this.status) ; Calls Blank()
            SetTimer % blank, % -this.t ; Calls __Delete.
         }
      }

      return this
   }

   RenderOnScreen(terms*) {

      this.Draw(terms*)

      ; Allow Render() to commit when previous Draw() has happened.
      if (this.layers.length() > 0) {
         ; Use the default rendering when the canvas coordinates fall within the bitmap area.
         if this.InBounds()
            return this.Render(terms*)

         ; Render objects that reside off screen.
         ; Create a new bitmap using the width and height of the canvas object.
         hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
         VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
            NumPut(       40, bi,  0,   "uint") ; Size
            NumPut(   this.w, bi,  4,   "uint") ; Width
            NumPut(  -this.h, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
            NumPut(        1, bi, 12, "ushort") ; Planes
            NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
         hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
         obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")
         gfx := DllCall("gdiplus\GdipCreateFromHDC", "ptr", hdc, "ptr*", gfx:=0, "int") ? False : gfx

         ; Set the origin to this.x and this.y
         DllCall("gdiplus\GdipTranslateWorldTransform", "ptr", gfx, "float", -this.x, "float", -this.y, "int", 0)

         ; Redraw on the canvas.
         for i, layer in this.layers
            this.DrawOnGraphics(gfx, layer[1], layer[2], layer[3], this.BitmapWidth, this.BitmapHeight)

         ; Show the objects on screen.
         ; This suffers from a windows limitation in that windows will appear in places that do not match the intended coordinates.
         ; Therefore this is not the default rendering approach as style commands are not respected.
         DllCall("UpdateLayeredWindow"
                  ,    "ptr", this.hwnd                ; hWnd
                  ,    "ptr", 0                        ; hdcDst
                  ,"uint64*", this.x | this.y << 32    ; *pptDst
                  ,"uint64*", this.w | this.h << 32    ; *psize
                  ,    "ptr", hdc                      ; hdcSrc
                  ,"uint64*", 0                        ; *pptSrc
                  ,   "uint", 0                        ; crKey
                  ,  "uint*", 0xFF << 16 | 0x01 << 24  ; *pblend
                  ,   "uint", 2)                       ; dwFlags

         ; Adjust location
         DllCall("SetWindowPos", "ptr", this.hwnd, "ptr", 0, "int", this.x, "int", this.y, "int", 0, "int", 0
            , "uint", 0x400 | 0x10 | 0x4 | 0x1) ; SWP_NOSENDCHANGING | SWP_NOACTIVATE | SWP_NOZORDER | SWP_NOSIZE

         ; Cleanup
         DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
         DllCall("SelectObject", "ptr", hdc, "ptr", obm)
         DllCall("DeleteObject", "ptr", hbm)
         DllCall("DeleteDC",     "ptr", hdc)

         ; Set Coordinates
         WinGetPos x, y, w, h, % "ahk_id " this.hwnd
         this.WindowLeft := x
         this.WindowTop := y
         this.WindowWidth := w
         this.WindowHeight := h
         this.WindowRight  := this.WindowLeft + this.WindowWidth
         this.WindowBottom := this.WindowTop + this.WindowHeight
      }

      ; Start Timestamp
      DllCall("QueryPerformanceCounter", "int64*", start:=0)
      this.t0 := start

      ; Create a timer that eventually clears the canvas.
      if (this.t > 0) {
         ; Create a reference to the object held by a timer.
         blank := ObjBindMethod(this, "blank", this.status) ; Calls Blank()
         SetTimer % blank, % -this.t ; Calls __Delete.
      }

      ; Ensure that Flush() will be called at the start of a new drawing.
      ; This approach keeps this.layers and the underlying graphics intact,
      ; so that calls to Save() and Screenshot() will not encounter a blank canvas.
      this.flush_pending := True
      return this
   }

   Fade(fade_in := 250, fade_out := 250, status := "") {
      if (fade_in > 0) {
         ; Render: Off-Screen areas are not rendered. Clip objects that reside off screen.

         duration := 0
         current := -1
         ;count := 0

         DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
         DllCall("QueryPerformanceCounter", "int64*", start:=0)
         while (duration < fade_in) {
            alpha := Ceil(duration/fade_in * 255)
            if (alpha != current) {
               ;if (count != alpha)
               ;   FileAppend % count ", " alpha "`n", log.txt
               ;count++
               this.UpdateLayeredWindow(alpha)
               current := alpha
            }
            DllCall("QueryPerformanceCounter", "int64*", now:=0)
            duration := (now - start)/frequency * 1000
         }

         if (alpha != 255)
            this.UpdateLayeredWindow()

         ; Start Timestamp
         DllCall("QueryPerformanceCounter", "int64*", start:=0)
         this.t0 := start

         ; Create a timer that eventually clears the canvas.
         if (this.t > 0) {
            ; Create a reference to the object held by a timer.
            fade := ObjBindMethod(this, "fade", 0, fade_out, this.status) ; Calls Fade() with no fade_in.
            SetTimer % fade, % -this.t ; Calls __Delete.
         }

         ; Ensure that Flush() will be called at the start of a new drawing.
         ; This approach keeps this.layers and the underlying graphics intact,
         ; so that calls to Save() and Screenshot() will not encounter a blank canvas.
         this.flush_pending := True
         return this
      }

      ; Check to see if the state of the canvas has changed before clearing and updating.
      if (fade_out > 0 && this.status = status) {
         duration := 0
         current := -1
         ;count := 0
         DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
         DllCall("QueryPerformanceCounter", "int64*", start:=0)
         while (duration < fade_out) {
            alpha := 255 - Ceil(duration/fade_out * 255)
            if (alpha != current) {
               ;if (count != alpha)
               ;   FileAppend % count ", " alpha "`n", log.txt
               ;count++
               this.UpdateLayeredWindow(alpha)
               current := alpha
            }
            DllCall("QueryPerformanceCounter", "int64*", now:=0)
            duration := (now - start)/frequency * 1000
         }
         this.UpdateLayeredWindow(0)
         return this
      }
   }

   Blank(status) {
      ; Check to see if the state of the canvas has changed before clearing and updating.
      if (this.status = status) {
         this.UpdateLayeredWindow(0)
      }
   }

   Draw(data := "", style1 := "", style2 := "") {

      ; Check if FreeMemory() was called between draws.
      if (!this.hdc && this.flush_pending == False) {
         this.UpdateMemory()
         ; Redraw on the canvas.
         for i, layer in this.layers
            this.DrawOnGraphics(this.gfx, layer[1], layer[2], layer[3])
      }

      ; A render to screen operation has occurred.
      if (this.flush_pending == True)
         this.Flush() ; Clears the graphics buffer.

      if (style1 = "" && style2 = "")
         style1 := this.style1, style2 := this.style2
      this.data := data
      this.style1 := style1, this.style2 := style2
      this.layers.push([data, style1, style2])

      ; Drawing
      dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
      obj := this.DrawOnGraphics(this.gfx, data, style1, style2, A_ScreenWidth, A_ScreenHeight)
      DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

      ; Create a unique signature for each call to Draw().
      this.CanvasChanged()

      ; Set canvas coordinates.
      this.t  := (this.t  == "") ? obj.t  : Max(this.t, obj.t)
      this.x  := (this.x  == "") ? obj.x  : Min(this.x, obj.x)
      this.y  := (this.y  == "") ? obj.y  : Min(this.y, obj.y)
      this.x2 := (this.x2 == "") ? obj.x2 : Max(this.x2, obj.x2)
      this.y2 := (this.y2 == "") ? obj.y2 : Max(this.y2, obj.y2)
      this.w  := this.x2 - this.x
      this.h  := this.y2 - this.y
      this.chars := obj.chars
      this.words := obj.words
      this.lines := obj.lines

      return this
   }

   Flush() {
      ; Reallocate the graphics buffer between draws.
      this.UpdateMemory()

      if (this.x != "") {
         DllCall("gdiplus\GdipSetClipRect", "ptr", this.gfx, "float", this.x, "float", this.y, "float", this.w, "float", this.h, "int", 0)
         DllCall("gdiplus\GdipGraphicsClear", "ptr", this.gfx, "uint", 0x00FFFFFF) ; All colors are the same speed.
         DllCall("gdiplus\GdipResetClip", "ptr", this.gfx)
         this.CanvasChanged()
      }

      this.t := this.x := this.y := this.x2 := this.y2 := this.w := this.h := ""
      this.layers := {}
      this.flush_pending := False
      return this
   }

   Clear() {
      this.Flush()
      this.UpdateLayeredWindow(0)
      return this
   }

   Wait(wait_time := 0) {

      ; Allow the user to override the original duration with a positive number.
      (wait_time <= 0) && wait_time := this.t

      if (wait_time > 0) {
         ; Prevents the timer from blanking the canvas.
         this.UpdateStatus()

         ; Always use QPC over GetTickCount for finer time intervals.
         DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)

         loop {
            DllCall("QueryPerformanceCounter", "int64*", end:=0)
            elapsed_time := (end - this.t0) / frequency * 1000
            remaining_time := wait_time - elapsed_time
            if (remaining_time > 30)
               Sleep 10
            if (remaining_time <= 0)
               break
         }
      }

      return this ; Allow the next render call to update the current window.
   }

   Sleep(sleep_time := 0, wait_time := 0) {
      this.Wait(wait_time)
      if (sleep_time > 0) {
         this.UpdateLayeredWindow(0)
         this.flush_pending := True
         Sleep sleep_time
      }
      return this
   }

   UpdateStatus() {
      loop ; Collision free
         Random rand, -2147483648, 2147483647
      until (rand != this.status)
      this.status := rand
   }

   CanvasChanged() {
      this.UpdateStatus()
      try if callback := this.events["CanvasChange"]
         return %callback%(this) ; Callbacks have a reference to "this".
   }

   get(name, p*) {
      return ObjHasKey(this, name) ? this.name : ""
   }

   DrawOnGraphics(gfx, text := "", style1 := "", style2 := "", CanvasWidth := "", CanvasHeight := "") {
      ; Get default width and height from undocumented graphics pointer offset.
      (CanvasWidth == "") && CanvasWidth := NumGet(gfx + 20 + A_PtrSize, "uint")
      (CanvasHeight == "") && CanvasHeight := NumGet(gfx + 24 + A_PtrSize, "uint")

      ; RegEx help? https://regex101.com/r/rNsP6n/1
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\\\/\s:#%_a-z\-\.\d]+|\([\\\/\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      ; Extract styles to variables.
      if IsObject(style1) {
         style1.base.__get := this.get ; Returns the empty string for unknown properties.
         _t  := (style1.time != "")     ? style1.time     : style1.t
         _a  := (style1.anchor != "")   ? style1.anchor   : style1.a
         _x  := (style1.left != "")     ? style1.left     : style1.x
         _y  := (style1.top != "")      ? style1.top      : style1.y
         _w  := (style1.width != "")    ? style1.width    : style1.w
         _h  := (style1.height != "")   ? style1.height   : style1.h
         _r  := (style1.radius != "")   ? style1.radius   : style1.r
         _c  := (style1.color != "")    ? style1.color    : style1.c
         _m  := (style1.margin != "")   ? style1.margin   : style1.m
         _q  := (style1.quality != "")  ? style1.quality  : (style1.q) ? style1.q : style1.SmoothingMode
      } else {
         RegExReplace(style1, "\s+", A_Space) ; Limit whitespace for fixed width look-behinds.
         _t  := ((___ := RegExReplace(style1, q1    "(t(ime)?)"          q2, "${value}")) != style1) ? ___ : ""
         _a  := ((___ := RegExReplace(style1, q1    "(a(nchor)?)"        q2, "${value}")) != style1) ? ___ : ""
         _x  := ((___ := RegExReplace(style1, q1    "(x|left)"           q2, "${value}")) != style1) ? ___ : ""
         _y  := ((___ := RegExReplace(style1, q1    "(y|top)"            q2, "${value}")) != style1) ? ___ : ""
         _w  := ((___ := RegExReplace(style1, q1    "(w(idth)?)"         q2, "${value}")) != style1) ? ___ : ""
         _h  := ((___ := RegExReplace(style1, q1    "(h(eight)?)"        q2, "${value}")) != style1) ? ___ : ""
         _r  := ((___ := RegExReplace(style1, q1    "(r(adius)?)"        q2, "${value}")) != style1) ? ___ : ""
         _c  := ((___ := RegExReplace(style1, q1    "(c(olor)?)"         q2, "${value}")) != style1) ? ___ : ""
         _m  := ((___ := RegExReplace(style1, q1    "(m(argin)?)"        q2, "${value}")) != style1) ? ___ : ""
         _q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"       q2, "${value}")) != style1) ? ___ : ""
      }

      if IsObject(style2) {
         style2.base.__get := this.get ; Returns the empty string for unknown properties.
         t  := (style2.time != "")        ? style2.time        : style2.t
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
         v  := (style2.vertical != "")    ? style2.vertical    : style2.v
         n  := (style2.noWrap != "")      ? style2.noWrap      : style2.n
         z  := (style2.condensed != "")   ? style2.condensed   : style2.z
         d  := (style2.dropShadow != "")  ? style2.dropShadow  : style2.d
         o  := (style2.outline != "")     ? style2.outline     : style2.o
         q  := (style2.quality != "")     ? style2.quality     : (style2.q) ? style2.q : style2.TextRenderingHint
      } else {
         RegExReplace(style2, "\s+", A_Space) ; Limit whitespace for fixed width look-behinds.
         t  := ((___ := RegExReplace(style2, q1    "(t(ime)?)"          q2, "${value}")) != style2) ? ___ : ""
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
         v  := ((___ := RegExReplace(style2, q1    "(v(ertical)?)"      q2, "${value}")) != style2) ? ___ : ""
         n  := ((___ := RegExReplace(style2, q1    "(n(oWrap)?)"        q2, "${value}")) != style2) ? ___ : ""
         z  := ((___ := RegExReplace(style2, q1    "(z|condensed)"      q2, "${value}")) != style2) ? ___ : ""
         d  := ((___ := RegExReplace(style2, q1    "(d(ropShadow)?)"    q2, "${value}")) != style2) ? ___ : ""
         o  := ((___ := RegExReplace(style2, q1    "(o(utline)?)"       q2, "${value}")) != style2) ? ___ : ""
         q  := ((___ := RegExReplace(style2, q1    "(q(uality)?)"       q2, "${value}")) != style2) ? ___ : ""
      }

      ; Parse background color.
      _c := this.color(_c, 0xDD212121) ; Default color for background is transparent gray.

      ; Parse text color.
      AlphaCopy := False
      if (c ~= "i)(delete|eraser?|overwrite|AlphaCopy)")
         AlphaCopy := True, c := 0 ; Eraser brush for text.
      if (c ~= "^-") ; Allow negative color values to overwrite alpha.
         AlphaCopy := True, c := LTrim(c, "-")
      ; Default color is white text on a dark background or black text on a light background.
      c  := this.color(c, this.grayscale(_c) < 128 ? 0xFFFFFFFF : 0xFF000000)

      ; Default SmoothingMode is 5 for outlines and rounded corners. To disable use 0. See Draw 1, 2, 3.
      _q := (_q ~= "^\d+$" && _q >= 0 && _q <= 5) ? _q : 5 ; SmoothingModeAntiAlias8x8

      ; Default TextRenderingHint is Cleartype on a opaque background and Anti-Alias on a transparent background.
      if (q ~= "^\d+$") and (q < 0 || q > 5)
         q := (_c & 0xFF000000 = 0xFF000000) && (!AlphaCopy) ? 5 : 4 ; TextRenderingHintClearTypeGridFit = 5, TextRenderingHintAntialias = 4
      else
         q := 4

      ; Save original Graphics settings.
      DllCall("gdiplus\GdipSaveGraphics", "ptr", gfx, "ptr*", pState:=0)

      ; Use pixels as the defualt unit when rendering.
      DllCall("gdiplus\GdipSetPageUnit", "ptr", gfx, "int", 2) ; A unit is 1 pixel.

      ; Set Graphics settings.
      DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr", gfx, "int", 4) ; PixelOffsetModeHalf
      ;DllCall("gdiplus\GdipSetCompositingMode",    "ptr", gfx, "int", 1) ; CompositingModeSourceCopy
      DllCall("gdiplus\GdipSetCompositingQuality", "ptr", gfx, "int", 4) ; CompositingQualityGammaCorrected
      DllCall("gdiplus\GdipSetSmoothingMode",      "ptr", gfx, "int", _q)
      DllCall("gdiplus\GdipSetInterpolationMode",  "ptr", gfx, "int", 7) ; HighQualityBicubic
      DllCall("gdiplus\GdipSetTextRenderingHint",  "ptr", gfx, "int", q)

      ; These are the type checkers.
      static valid := "^\s*(-?((\d+(\.\d*)?)|(\.\d+)))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"
      static valid_positive := "^\s*((\d+(\.\d*)?)|(\.\d+))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"

      ; Define viewport width and height. This is the visible canvas area.
      vw := 0.01 * CanvasWidth         ; 1% of viewport width.
      vh := 0.01 * CanvasHeight        ; 1% of viewport height.
      vmin := Min(vw, vh)              ; 1vw or 1vh, whichever is smaller.
      vr := CanvasWidth / CanvasHeight ; Aspect ratio of the viewport.

      ; Get background width and height.
      _w := (_w ~= valid_positive) ? RegExReplace(_w, "\s") : ""
      _w := (_w ~= "i)(pt|px)$") ? SubStr(_w, 1, -2) : _w
      _w := (_w ~= "i)(%|vw)$") ? RegExReplace(_w, "i)(%|vw)$") * vw : _w
      _w := (_w ~= "i)vh$") ? RegExReplace(_w, "i)vh$") * vh : _w
      _w := (_w ~= "i)vmin$") ? RegExReplace(_w, "i)vmin$") * vmin : _w

      _h := (_h ~= valid_positive) ? RegExReplace(_h, "\s") : ""
      _h := (_h ~= "i)(pt|px)$") ? SubStr(_h, 1, -2) : _h
      _h := (_h ~= "i)vw$") ? RegExReplace(_h, "i)vw$") * vw : _h
      _h := (_h ~= "i)(%|vh)$") ? RegExReplace(_h, "i)(%|vh)$") * vh : _h
      _h := (_h ~= "i)vmin$") ? RegExReplace(_h, "i)vmin$") * vmin : _h

      ; Get Font size.
      s  := (s ~= valid_positive) ? RegExReplace(s, "\s") : "2.23vh"          ; Default font size is 2.23vh.
      s  := (s ~= "i)(pt|px)$") ? SubStr(s, 1, -2) : s                        ; Strip spaces, px, and pt.
      s  := (s ~= "i)vh$") ? RegExReplace(s, "i)vh$") * vh : s                ; Relative to viewport height.
      s  := (s ~= "i)vw$") ? RegExReplace(s, "i)vw$") * vw : s                ; Relative to viewport width.
      s  := (s ~= "i)(%|vmin)$") ? RegExReplace(s, "i)(%|vmin)$") * vmin : s  ; Relative to viewport minimum.

      ; Get Bold, Italic, Underline, NoWrap, and Justification of text.
      style := (b) ? 1 : 0         ; bold
      style += (i) ? 2 : 0         ; italic
      style += (u) ? 4 : 0         ; underline
      ; style += (strikeout) ? 8 : 0 ; strikeout, not implemented.
      n  := (n) ? 0x4000 | 0x1000 : 0x4000 ; Defaults to text wrapping.

      ; Define text justification. Default text justification to center.
      j := (j ~= "i)(near|left)") ? 0
         : (j ~= "i)cent(er|re)") ? 1
         : (j ~= "i)(far|right)") ? 2
         : (j ~= "^[1-3]$") ? j-1
         : 1

      ; Define vertical alignment. Default vertical alignment to top.
      v := (v ~= "i)(near|top)") ? 0
         : (v ~= "i)cent(er|re)") ? 1
         : (v ~= "i)(far|bottom)") ? 2
         : (v ~= "^[1-3]$") ? v-1
         : 0

      ; Later when text x and w are finalized and it is found that x + width exceeds the screen,
      ; then the _redrawBecauseOfCondensedFont flag is set to true.
      static _redrawBecauseOfCondensedFont := False
      if (_redrawBecauseOfCondensedFont == True)
         f:=z, z:=0, _redrawBecauseOfCondensedFont := False

      ; Specifies whether to load an external font file, or to use an font already installed on the system.
      if (f ~= "(ttf|otf)$") {
         ; Temporarily load a font from file. This does not install the font.
         DllCall("gdiplus\GdipNewPrivateFontCollection", "ptr*", hCollection:=0)
         DllCall("gdiplus\GdipPrivateAddFontFile", "ptr", hCollection, "wstr", f)

         ; A collection of fonts can hold more than just 1 font. Since only 1 font will be needed, a single pointer suffices.
         DllCall("gdiplus\GdipGetFontCollectionFamilyList", "ptr", hCollection, "int", 1, "ptr*", pFontFamily:=0, "int*", found:=0)

         ; Normally, pFontFamily is an array of pointers. For a single pointer, no special requirements are needed.
         VarSetCapacity(FontName, 256*(A_IsUnicode?2:1))
         DllCall("gdiplus\GdipGetFamilyName", "ptr", pFontFamily, "str", FontName, "ushort", 1033) ; en-US

         ; Create a font family. For ANSI compatibility, use str as the output type and StrGet to pass wide chars.
         DllCall("gdiplus\GdipCreateFontFamilyFromName", "wstr", StrGet(&FontName, "UTF-16"), "ptr", hCollection, "ptr*", hFamily:=0)

         ; Delete the private font collection. It is strange a pointer reference is used.
         DllCall("gdiplus\GdipDeletePrivateFontCollection", "ptr*", hCollection)
      } else {
         ; Create Font. Defaults to Segoe UI or Tahoma on older systems.
         if DllCall("gdiplus\GdipCreateFontFamilyFromName", "wstr",          f, "uint", 0, "ptr*", hFamily:=0)
         if DllCall("gdiplus\GdipCreateFontFamilyFromName", "wstr", "Segoe UI", "uint", 0, "ptr*", hFamily:=0)
            DllCall("gdiplus\GdipCreateFontFamilyFromName", "wstr",   "Tahoma", "uint", 0, "ptr*", hFamily:=0)
      }

      DllCall("gdiplus\GdipCreateFont", "ptr", hFamily, "float", s, "int", style, "int", 0, "ptr*", hFont:=0)
      DllCall("gdiplus\GdipCreateStringFormat", "int", n, "int", 0, "ptr*", hFormat:=0)
      DllCall("gdiplus\GdipSetStringFormatAlign", "ptr", hFormat, "int", j)     ; Left = 0, Center = 1, Right = 2
      DllCall("gdiplus\GdipSetStringFormatLineAlign", "ptr", hFormat, "int", v) ; Top = 0, Center = 1, Bottom = 2

      ; Use the declared width and height of the text box if given.
      VarSetCapacity(RectF, 16, 0)                    ; sizeof(RectF) = 16
         (_w != "") && NumPut(_w, RectF,  8, "float") ; Width
         (_h != "") && NumPut(_h, RectF, 12, "float") ; Height

      ; Otherwise simulate the drawing...
      DllCall("gdiplus\GdipMeasureString"
               ,    "ptr", gfx
               ,   "wstr", text
               ,    "int", -1                 ; string length is null terminated.
               ,    "ptr", hFont
               ,    "ptr", &RectF             ; (in) layout RectF that bounds the string.
               ,    "ptr", hFormat
               ,    "ptr", &RectF             ; (out) simulated RectF that bounds the string.
               ,  "uint*", chars:=0
               ,  "uint*", lines:=0)

      ; Extract the simulated width and height of the text string's bounding box...
      width := NumGet(RectF, 8, "float")
      height := NumGet(RectF, 12, "float")
      minimum := Min(width, height)
      aspect := (height != 0) ? width / height : 0

      ; And use those values for the background width and height.
      (_w == "") && _w := width
      (_h == "") && _h := height

      ; Get margin. Default margin is 1vmin.
      m  := this.margin_and_padding( m, vw, vh)
      _m := this.margin_and_padding(_m, vw, vh, (text != "" && m.void && _w > 0 && _h > 0) ? "1vmin" : "")

      ; Modify _w, _h with margin and padding, increasing the size of the background.
      _w += m.2 + m.4
      _h += m.1 + m.3

      ; Get background anchor. This is where the origin of the background is located.
      _a := (_a ~= "^[1-9]$") ? _a-1
         : (_a ~= "i)top" && _a ~= "i)left") ? 0
         : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 1
         : (_a ~= "i)top" && _a ~= "i)right") ? 2
         : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 3
         : (_a ~= "i)cent(er|re)" && _a ~= "i)right") ? 5
         : (_a ~= "i)bottom" && _a ~= "i)left") ? 6
         : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 7
         : (_a ~= "i)bottom" && _a ~= "i)right") ? 8
         : (_a ~= "i)top") ? 1
         : (_a ~= "i)left") ? 3
         : (_a ~= "i)right") ? 5
         : (_a ~= "i)bottom") ? 7
         : (_a ~= "i)cent(er|re)") ? 4
         ; The anchor can be implied from _x and _y (left, center, right, top, bottom).
         : ((_x ~= "i)left") ? 0 : (_x ~= "i)cent(er|re)") ? 1 : (_x ~= "i)right") ? 2 : 0)
         + ((_y ~= "i)top") ? 0 : (_y ~= "i)cent(er|re)") ? 3 : (_y ~= "i)bottom") ? 6 : 0)
         ; Default anchor is top-left (0).

      ; Convert English words to numbers. Don't mess with these values any further.
      _x := (_x ~= "i)left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*CanvasWidth : (_x ~= "i)right") ? CanvasWidth : _x
      _y := (_y ~= "i)top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*CanvasHeight : (_y ~= "i)bottom") ? CanvasHeight : _y

      ; Get _x and _y.
      _x := (_x ~= valid) ? RegExReplace(_x, "\s") : ""
      _x := (_x ~= "i)(pt|px)$") ? SubStr(_x, 1, -2) : _x
      _x := (_x ~= "i)(%|vw)$") ? RegExReplace(_x, "i)(%|vw)$") * vw : _x
      _x := (_x ~= "i)vh$") ? RegExReplace(_x, "i)vh$") * vh : _x
      _x := (_x ~= "i)vmin$") ? RegExReplace(_x, "i)vmin$") * vmin : _x

      _y := (_y ~= valid) ? RegExReplace(_y, "\s") : ""
      _y := (_y ~= "i)(pt|px)$") ? SubStr(_y, 1, -2) : _y
      _y := (_y ~= "i)vw$") ? RegExReplace(_y, "i)vw$") * vw : _y
      _y := (_y ~= "i)(%|vh)$") ? RegExReplace(_y, "i)(%|vh)$") * vh : _y
      _y := (_y ~= "i)vmin$") ? RegExReplace(_y, "i)vmin$") * vmin : _y

      ; Default x and y to center of the canvas. Default anchor to horizontal center and vertical center.
      if (_x == "")
         _x := 0.5*CanvasWidth, _a := 1+(_a//3*3)
      if (_y == "")
         _y := 0.5*CanvasHeight, _a := 3+mod(_a,3)

      ; Now let's modify the _x and _y values with the _anchor, so that the image has a new point of origin.
      ; We need our calculated _width and _height for this!
      _x -= (mod(_a,3) == 0) ? 0 : (mod(_a,3) == 1) ? _w/2 : (mod(_a,3) == 2) ? _w : 0
      _y -= ((_a//3) == 0) ? 0 : ((_a//3) == 1) ? _h/2 : ((_a//3) == 2) ? _h : 0

      ; Prevent half-pixel rendering and keep image sharp.
      _w := Round(_x + _w) - Round(_x) ; Use real x2 coordinate to determine width.
      _h := Round(_y + _h) - Round(_y) ; Use real y2 coordinate to determine height.
      _x := Round(_x)                  ; NOTE: simple Floor(w) or Round(w) will NOT work.
      _y := Round(_y)                  ; The float values need to be added up and then rounded!

      ; Get the text width and text height.
      w  := ( w ~= valid_positive) ? RegExReplace( w, "\s") : width ; Default is simulated text width.
      w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
      w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$") * vw :  w
      w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$") * vh :  w
      w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$") * vmin :  w
      w  := ( w ~= "%$") ? RegExReplace( w, "%$") * 0.01 * _w :  w

      h  := ( h ~= valid_positive) ? RegExReplace( h, "\s") : height ; Default is simulated text height.
      h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
      h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$") * vw :  h
      h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$") * vh :  h
      h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$") * vmin :  h
      h  := ( h ~= "%$") ? RegExReplace( h, "%$") * 0.01 * _h :  h

      ; Manually justify because text width and height may be set above.
      ; If text justification is set but x is not, align the justified text relative to the center
      ; or right of the backgound, after taking into account the text width.
      if (x == "")
         x  := (j = 1) ? _x + (_w/2) - (w/2) : (j = 2) ? _x + _w - w : x
      if (y == "")
         y  := (v = 1) ? _y + (_h/2) - (h/2) : (v = 2) ? _y + _h - h : y

      ; Get text anchor. This is where the origin of the text is located.
      a := (a ~= "i)top" && a ~= "i)left") ? 0
         : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 1
         : (a ~= "i)top" && a ~= "i)right") ? 2
         : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 3
         : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 5
         : (a ~= "i)bottom" && a ~= "i)left") ? 6
         : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 7
         : (a ~= "i)bottom" && a ~= "i)right") ? 8
         : (a ~= "i)top") ? 1
         : (a ~= "i)left") ? 3
         : (a ~= "i)right") ? 5
         : (a ~= "i)bottom") ? 7
         : (a ~= "i)cent(er|re)") ? 4
         : (a ~= "^[1-9]$") ? a-1
         : 0 ; Default anchor is top-left.

      ; Text x and text y can be specified as locations (left, center, right, top, bottom).
      ; These location words in text x and text y take precedence over the values in the text anchor.
      a  := ( x ~= "i)left") ? 0+( a//3*3) : ( x ~= "i)cent(er|re)") ? 1+( a//3*3) : ( x ~= "i)right") ? 2+( a//3*3) :  a
      a  := ( y ~= "i)top") ? 0+mod( a,3) : ( y ~= "i)cent(er|re)") ? 3+mod( a,3) : ( y ~= "i)bottom") ? 6+mod( a,3) :  a

      ; Convert English words to numbers. Don't mess with these values any further.
      ; Also, these values are relative to the background.
      x  := ( x ~= "i)left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*_w : (x ~= "i)right") ? _x + _w : x
      y  := ( y ~= "i)top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*_h : (y ~= "i)bottom") ? _y + _h : y

      ; Default text x is background x.
      x  := ( x ~= valid) ? RegExReplace( x, "\s") : _x
      x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
      x  := ( x ~= "i)vw$") ? RegExReplace( x, "i)vw$") * vw :  x
      x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$") * vh :  x
      x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$") * vmin :  x
      x  := ( x ~= "%$") ? RegExReplace( x, "%$") * 0.01 * _w :  x

      ; Default text y is background y.
      y  := ( y ~= valid) ? RegExReplace( y, "\s") : _y
      y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
      y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$") * vw :  y
      y  := ( y ~= "i)vh$") ? RegExReplace( y, "i)vh$") * vh :  y
      y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$") * vmin :  y
      y  := ( y ~= "%$") ? RegExReplace( y, "%$") * 0.01 * _h :  y

      ; If margin/padding are defined in the text parameter, shift the position of the text.
      x += (j == 0) ? m.4 : (j == 1) ? (m.4/2)-(m.2/2) : -m.2
      y += (v == 0) ? m.1 : (v == 1) ? (m.1/2)-(m.3/2) : -m.3

      ; Modify text x and text y values with the anchor, so that the text has a new point of origin.
      ; The text anchor is relative to the text width and height before margin/padding.
      ; This is NOT relative to the background width and height.
      x  -= (mod(a,3) == 0) ? 0 : (mod(a,3) == 1) ? w/2 : (mod(a,3) == 2) ? w : 0
      y  -= ((a//3) == 0) ? 0 : ((a//3) == 1) ? h/2 : ((a//3) == 2) ? h : 0

      ; Modify _x, _y, _w, _h with margin and padding, increasing the size of the background.
      _w += _m.4 + _m.2
      _h += _m.1 + _m.3
      _x -= _m.4
      _y -= _m.1

      ; Re-run: Condense Text using a Condensed Font if simulated text width exceeds screen width.
      if (z) {
         if (width + x > CanvasWidth) {
            _redrawBecauseOfCondensedFont := True
            return this.DrawOnGraphics(gfx, text, style1, style2, CanvasWidth, CanvasHeight)
         }
      }

      ; Define the smaller of the backgound width or height.
      _min := Min(_w, _h)

      ; Define the maximum roundness of the background bubble.
      _rmax := _min / 2

      ; Define radius of rounded corners. The default radius is 0, or square corners.
      _r := (_r ~= "i)max") ? _rmax : _r
      _r := (_r ~= valid_positive) ? RegExReplace(_r, "\s") : 0
      _r := (_r ~= "i)(pt|px)$") ? SubStr(_r, 1, -2) : _r
      _r := (_r ~= "i)vw$") ? RegExReplace(_r, "i)vw$") * vw : _r
      _r := (_r ~= "i)vh$") ? RegExReplace(_r, "i)vh$") * vh : _r
      _r := (_r ~= "i)vmin$") ? RegExReplace(_r, "i)vmin$") * vmin : _r
      _r := (_r ~= "%$") ? RegExReplace(_r, "%$") * 0.01 * _min : _r ; percentage of minimum
      _r := Min(_r, _rmax) ; Exceeding _rmax will create a candy wrapper effect.

      ; Define outline and dropShadow.
      o := this.outline(o, vw, vh, s, c)
      d := this.dropShadow(d, vw, vh, width, height, s)


      ; Draw 1 - Background
      if (_w && _h && (_c & 0xFF000000)) {
         ; Create background solid brush.
         DllCall("gdiplus\GdipCreateSolidFill", "uint", _c, "ptr*", pBrush:=0)

         ; Fill a rectangle with a solid brush. Draw sharp rectangular edges.
         if (_r == 0) {
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", gfx, "int", 0) ; SmoothingModeNoAntiAlias
            DllCall("gdiplus\GdipFillRectangle", "ptr", gfx, "ptr", pBrush, "float", _x, "float", _y, "float", _w, "float", _h) ; DRAWING!
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", gfx, "int", _q)
         }

         ; Fill a rounded rectangle with a solid brush.
         else {
            _r2 := (_r * 2) ; Calculate diameter
            DllCall("gdiplus\GdipCreatePath", "uint", 0, "ptr*", pPath:=0)
            DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", _x           , "float", _y           , "float", _r2, "float", _r2, "float", 180, "float", 90)
            DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", _x + _w - _r2, "float", _y           , "float", _r2, "float", _r2, "float", 270, "float", 90)
            DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", _x + _w - _r2, "float", _y + _h - _r2, "float", _r2, "float", _r2, "float",   0, "float", 90)
            DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", _x           , "float", _y + _h - _r2, "float", _r2, "float", _r2, "float",  90, "float", 90)
            DllCall("gdiplus\GdipClosePathFigure", "ptr", pPath) ; Connect existing arc segments into a rounded rectangle.
            DllCall("gdiplus\GdipFillPath", "ptr", gfx, "ptr", pBrush, "ptr", pPath) ; DRAWING!
            DllCall("gdiplus\GdipDeletePath", "ptr", pPath)
         }

         ; Delete background solid brush.
         DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
      }


      ; Draw 2 - DropShadow
      if (!d.void) {
         offset2 := d.3 + d.6 + Ceil(0.5*o.1)

         ; If blur is present, a second canvas must be seperately processed to apply the Gaussian Blur effect.
         if (True) {
            ;DropShadow := Gdip_CreateBitmap(w + 2*offset2, h + 2*offset2)
            ;DropShadow := Gdip_CreateBitmap(A_ScreenWidth, A_ScreenHeight, 0xE200B)
            DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", 0, "uint", 0xE200B, "ptr", 0, "ptr*", DropShadow:=0)
            DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", DropShadow, "ptr*", DropShadowG:=0)
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", DropShadowG, "int", 0) ; SmoothingModeNoAntiAlias
            DllCall("gdiplus\GdipSetTextRenderingHint", "ptr", DropShadowG, "int", 1) ; TextRenderingHintSingleBitPerPixelGridFit
            ;DllCall("gdiplus\GdipGraphicsClear", "ptr", gfx, "uint", d.4 & 0xFFFFFF)
            VarSetCapacity(RectF, 16, 0)          ; sizeof(RectF) = 16
               NumPut(d.1+x, RectF,  0, "float") ; Left
               NumPut(d.2+y, RectF,  4, "float") ; Top
               NumPut(     w, RectF,  8, "float") ; Width
               NumPut(     h, RectF, 12, "float") ; Height

            ;CreateRectF(RC, offset2, offset2, w + 2*offset2, h + 2*offset2)
         } else {
            ;CreateRectF(RC, x + d.1, y + d.2, w, h)
            VarSetCapacity(RectF, 16, 0)          ; sizeof(RectF) = 16
               NumPut(d.1+x, RectF,  0, "float") ; Left
               NumPut(d.2+y, RectF,  4, "float") ; Top
               NumPut(     w, RectF,  8, "float") ; Width
               NumPut(     h, RectF, 12, "float") ; Height
            DropShadowG := gfx
         }

         ; Use Gdip_DrawString if and only if there is a horizontal/vertical offset.
         if (o.void && d.6 == 0)
         {
            ; Use shadow solid brush.
            DllCall("gdiplus\GdipCreateSolidFill", "uint", d.4, "ptr*", pBrush:=0)
            DllCall("gdiplus\GdipDrawString"
                     ,    "ptr", DropShadowG
                     ,   "wstr", text
                     ,    "int", -1
                     ,    "ptr", hFont
                     ,    "ptr", &RectF
                     ,    "ptr", hFormat
                     ,    "ptr", pBrush)
            DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
         }
         else ; Otherwise, use the below code if blur, size, and opacity are set.
         {
            ; Draw the outer edge of the text string.
            DllCall("gdiplus\GdipCreatePath", "int", 1, "ptr*", pPath:=0)
            DllCall("gdiplus\GdipAddPathString"
                     ,    "ptr", pPath
                     ,   "wstr", text
                     ,    "int", -1
                     ,    "ptr", hFamily
                     ,    "int", style
                     ,  "float", s
                     ,    "ptr", &RectF
                     ,    "ptr", hFormat)
            DllCall("gdiplus\GdipCreatePen1", "uint", d.4, "float", 2*d.6 + o.1, "int", 2, "ptr*", pPen:=0)
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr", pPen, "uint", 2) ; LineJoinTypeRound
            DllCall("gdiplus\GdipDrawPath", "ptr", DropShadowG, "ptr", pPen, "ptr", pPath)
            DllCall("gdiplus\GdipDeletePen", "ptr", pPen)

            ; Fill in the outline. Turn off antialiasing and alpha blending so the gaps are 100% filled.
            DllCall("gdiplus\GdipCreateSolidFill", "uint", d.4, "ptr*", pBrush:=0)
            DllCall("gdiplus\GdipSetCompositingMode", "ptr", DropShadowG, "int", 1) ; CompositingModeSourceCopy
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", DropShadowG, "int", 0) ; SmoothingModeNoAntiAlias
            DllCall("gdiplus\GdipFillPath", "ptr", DropShadowG, "ptr", pBrush, "ptr", pPath) ; DRAWING!
            DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
            DllCall("gdiplus\GdipDeletePath", "ptr", pPath)
            DllCall("gdiplus\GdipSetCompositingMode", "ptr", DropShadowG, "int", 0) ; CompositingModeSourceOver
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", DropShadowG, "int", _q)
         }

         if (True) {
            DllCall("gdiplus\GdipDeleteGraphics", "ptr", DropShadowG)
            this.GaussianBlur(DropShadow, d.3, d.5)
            DllCall("gdiplus\GdipSetInterpolationMode", "ptr", gfx, "int", 5) ; NearestNeighbor
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", gfx, "int", 0) ; SmoothingModeNoAntiAlias
            ;Gdip_DrawImage(gfx, DropShadow, x + d.1 - offset2, y + d.2 - offset2, w + 2*offset2, h + 2*offset2) ; DRAWING!
            ;Gdip_DrawImage(gfx, DropShadow, 0, 0, A_Screenwidth, A_ScreenHeight) ; DRAWING!
            DllCall("gdiplus\GdipDrawImageRectRectI" ; DRAWING!
                     ,    "ptr", gfx
                     ,    "ptr", DropShadow
                     ,    "int", 0, "int", 0, "int", A_Screenwidth, "int", A_Screenwidth ; destination rectangle
                     ,    "int", 0, "int", 0, "int", A_Screenwidth, "int", A_Screenwidth ; source rectangle
                     ,    "int", 2  ; UnitTypePixel
                     ,    "ptr", 0  ; imageAttributes
                     ,    "ptr", 0  ; callback
                     ,    "ptr", 0) ; callbackData
            DllCall("gdiplus\GdipSetSmoothingMode", "ptr", gfx, "int", _q)
            DllCall("gdiplus\GdipDisposeImage", "ptr", DropShadow)
         }
      }


      ; Draw 3 - Outline
      if (!o.void) {
         ; Convert our text to a path.
         VarSetCapacity(RectF, 16, 0)     ; sizeof(RectF) = 16
            NumPut(x, RectF,  0, "float") ; Left
            NumPut(y, RectF,  4, "float") ; Top
            NumPut(w, RectF,  8, "float") ; Width
            NumPut(h, RectF, 12, "float") ; Height
         DllCall("gdiplus\GdipCreatePath", "int", 1, "ptr*", pPath:=0)
         DllCall("gdiplus\GdipAddPathString"
                  ,    "ptr", pPath
                  ,   "wstr", text
                  ,    "int", -1
                  ,    "ptr", hFamily
                  ,    "int", style
                  ,  "float", s
                  ,    "ptr", &RectF
                  ,    "ptr", hFormat)

         ; Create a glow effect around the edges.
         if (o.3) {
            DllCall("gdiplus\GdipSetClipPath", "ptr", gfx, "ptr", pPath, "int", 3) ; Exclude original text region from being drawn on.
            ARGB := Format("0x{:02X}",((o.4 & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(o.4 & 0x00FFFFFF))
            DllCall("gdiplus\GdipCreatePen1", "uint", ARGB, "float", 1, "int", 2, "ptr*", pPenGlow:=0) ; UnitTypePixel = 2
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr", pPenGlow, "uint", 2) ; LineJoinTypeRound

            loop % o.3
            {
               DllCall("gdiplus\GdipSetPenWidth", "ptr", pPenGlow, "float", o.1 + 2*A_Index)
               DllCall("gdiplus\GdipDrawPath", "ptr", gfx, "ptr", pPenGlow, "ptr", pPath) ; DRAWING!
            }
            DllCall("gdiplus\GdipDeletePen", "ptr", pPenGlow)
            DllCall("gdiplus\GdipResetClip", "ptr", gfx)
         }

         ; Draw outline text.
         if (o.1) {
            DllCall("gdiplus\GdipCreatePen1", "uint", o.2, "float", o.1, "int", 2, "ptr*", pPen:=0) ; UnitTypePixel = 2
            DllCall("gdiplus\GdipSetPenLineJoin", "ptr", pPen, "uint", 2) ; LineJoinTypeRound
            DllCall("gdiplus\GdipDrawPath", "ptr", gfx, "ptr", pPen, "ptr", pPath) ; DRAWING!
            DllCall("gdiplus\GdipDeletePen", "ptr", pPen)
         }

         ; Fill outline text.
         DllCall("gdiplus\GdipCreateSolidFill", "uint", c, "ptr*", pBrush:=0)
         DllCall("gdiplus\GdipSetCompositingMode", "ptr", gfx, "int", AlphaCopy)
         DllCall("gdiplus\GdipFillPath", "ptr", gfx, "ptr", pBrush, "ptr", pPath) ; DRAWING!
         DllCall("gdiplus\GdipSetCompositingMode", "ptr", gfx, "int", 0) ; CompositingModeSourceOver
         DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
         DllCall("gdiplus\GdipDeletePath", "ptr", pPath)
      }


      ; Draw 4 - Text
      if (text != "" && o.void) {
         DllCall("gdiplus\GdipSetCompositingMode", "ptr", gfx, "int", AlphaCopy)

         VarSetCapacity(RectF, 16, 0)     ; sizeof(RectF) = 16
            NumPut(x, RectF,  0, "float") ; Left
            NumPut(y, RectF,  4, "float") ; Top
            NumPut(w, RectF,  8, "float") ; Width
            NumPut(h, RectF, 12, "float") ; Height

         DllCall("gdiplus\GdipMeasureString"
                  ,    "ptr", gfx
                  ,   "wstr", text
                  ,    "int", -1                 ; string length.
                  ,    "ptr", hFont
                  ,    "ptr", &RectF             ; (in) layout RectF that bounds the string.
                  ,    "ptr", hFormat
                  ,    "ptr", &RectF             ; (out) simulated RectF that bounds the string.
                  ,  "uint*", chars:=0
                  ,  "uint*", lines:=0)

         DllCall("gdiplus\GdipCreateSolidFill", "uint", c, "ptr*", pBrush:=0)
         DllCall("gdiplus\GdipDrawString"
                  ,    "ptr", gfx
                  ,   "wstr", text
                  ,    "int", -1
                  ,    "ptr", hFont
                  ,    "ptr", &RectF
                  ,    "ptr", hFormat
                  ,    "ptr", pBrush)
         DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)

         x := NumGet(RectF,  0, "float")
         y := NumGet(RectF,  4, "float")
         w := NumGet(RectF,  8, "float")
         h := NumGet(RectF, 12, "float")

         x := Round(x)
         y := Round(y)
         w := Round(x + w) - Round(x)
         h := Round(y + h) - Round(y)
      }


      ; Cleanup.
      DllCall("gdiplus\GdipDeleteStringFormat", "ptr", hFormat)
      DllCall("gdiplus\GdipDeleteFont", "ptr", hFont)
      DllCall("gdiplus\GdipDeleteFontFamily", "ptr", hFamily)

      ; Restore original Graphics settings.
      DllCall("gdiplus\GdipRestoreGraphics", "ptr", gfx, "ptr", pState)

      ; Calulate the number of words.
      ; First, use the number of chars displayed by GdipMeasureString to truncate "text".
      ; Then count the number of words, as defined by Unicode Code Points, i.e. all languages.
      RegExReplace(SubStr(text, 1, chars), "(*UCP)\b\w+\b", "", words)

      ; Calculate time for string values.
      t := (_t) ? _t : t      ; Prefer style1 over style2.
      if (t = "fast")         ; For when the user has seen the text before; to linger a bit longer on screen.
         t := 1250 + 8*chars  ; Every character adds 8 milliseconds.
      if (t = "auto")         ; The average human reaction time is 250 ms. For the sudden appearance of text.
         t := 250 + 300*words ; Using 200 words/minute, divide 60,000 ms by 200 words to get 300 ms per word.

      ; Define canvas coordinates.
      ; string/background boundary.
      t_bound  := this.time(t)
      x_bound  := (_c & 0xFF000000) ? Min(_x, x) : x
      y_bound  := (_c & 0xFF000000) ? Min(_y, y) : y
      x2_bound := (_c & 0xFF000000) ? Max(_x+_w, x+w) : x+w
      y2_bound := (_c & 0xFF000000) ? Max(_y+_h, y+h) : y+h

      ; outline boundary.
      o_bound  := Ceil(0.5 * o.1 + o.3)
      x_bound  := Min(x - o_bound, x_bound)
      y_bound  := Min(y - o_bound, y_bound)
      x2_bound := Max(x + w + o_bound, x2_bound)
      y2_bound := Max(y + h + o_bound, y2_bound)

      ; dropShadow boundary.
      d_bound  := Ceil(0.5 * o.1 + d.3 + d.6)
      x_bound  := Min(x + d.1 - d_bound, x_bound)
      y_bound  := Min(y + d.2 - d_bound, y_bound)
      x2_bound := Max(x + w + d.1 + d_bound, x2_bound)
      y2_bound := Max(y + h + d.2 + d_bound, y2_bound)

      return {t: t_bound
            , x: x_bound
            , y: y_bound
            , x2: x2_bound
            , y2: y2_bound
            , w: x2_bound - x_bound
            , h: y2_bound - y_bound
            , chars: chars
            , words: words
            , lines: lines}
   }

   DrawOnBitmap(pBitmap, text := "", style1 := "", style2 := "") {
      DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", pBitmap, "ptr*", gfx:=0)
      obj := this.DrawOnGraphics(gfx, text, style1, style2)
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
      return obj
   }

   DrawOnHDC(hdc, text := "", style1 := "", style2 := "") {
      DllCall("gdiplus\GdipCreateFromHDC", "ptr", hdc, "ptr*", gfx:=0)
      obj := this.DrawOnGraphics(gfx, text, style1, style2)
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
      return obj
   }

   color(c, default := 0xFFFFFFFF) {
      static xARGB := "^0x([0-9A-Fa-f]{8})$"
      static  xRGB := "^0x([0-9A-Fa-f]{6})$"
      static  ARGB :=   "^([0-9A-Fa-f]{8})$"
      static   RGB :=   "^([0-9A-Fa-f]{6})$"

      if (c == "")
         return default

      ; Check string buffer.
      if ObjGetCapacity([c], 1) {
         c := Trim(c)                    ; Remove surrounding whitespace.
         if (c ~= "^#") {
            c := LTrim(c, "#")
            c := (c ~= ARGB) ? RegExReplace(c, "^([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})$", "$2$1")
               : (c ~= RGB) ? "0xFF" c
               : default
         }
         c := this.colormap(c, c)        ; Convert CSS color names to hexadecimal.
         c := (c ~= xRGB) ? "0xFF" RegExReplace(c, xRGB, "$1")
            : (c ~= ARGB) ? "0x" c
            : (c ~= RGB) ? "0xFF" c : c
         c := (c ~= xARGB) ? c : default ; Ensure hexadecimal format is valid ARGB.
      }

      ; Assume number buffer.
      else {
         c := Round(c)                   ; Integers only.
         if (c > 0 && c < 0x01000000)    ; Lift RGB to solid ARGB.
            c += 0xFF000000              ; But do not convert zero to solid black.
         if (c < 0 || c > 0xFFFFFFFF)    ; Catch integers outside of 0 - 0xFFFFFFFF.
            c := default
      }

      return c
   }

   colormap(c, default := 0xFFFFFFFF) {
      if (c = "random") ; 93% opacity + random RGB.
         return "0xEE" SubStr(ComObjCreate("Scriptlet.TypeLib").GUID, 2, 6)

      if (c = "random2") ; Solid opacity + random RGB.
         return "0xFF" SubStr(ComObjCreate("Scriptlet.TypeLib").GUID, 2, 6)

      if (c = "random3") ; Fully random opacity and RGB.
         return SubStr(ComObjCreate("Scriptlet.TypeLib").GUID, 2, 8)

      static colors1 :=
      ( LTrim Join
      {
         "Clear"                 : "0x00000000",
         "None"                  : "0x00000000",
         "Off"                   : "0x00000000",
         "Transparent"           : "0x00000000",
         "AliceBlue"             : "0xFFF0F8FF",
         "AntiqueWhite"          : "0xFFFAEBD7",
         "Aqua"                  : "0xFF00FFFF",
         "Aquamarine"            : "0xFF7FFFD4",
         "Azure"                 : "0xFFF0FFFF",
         "Beige"                 : "0xFFF5F5DC",
         "Bisque"                : "0xFFFFE4C4",
         "Black"                 : "0xFF000000",
         "BlanchedAlmond"        : "0xFFFFEBCD",
         "Blue"                  : "0xFF0000FF",
         "BlueViolet"            : "0xFF8A2BE2",
         "Brown"                 : "0xFFA52A2A",
         "BurlyWood"             : "0xFFDEB887",
         "CadetBlue"             : "0xFF5F9EA0",
         "Chartreuse"            : "0xFF7FFF00",
         "Chocolate"             : "0xFFD2691E",
         "Coral"                 : "0xFFFF7F50",
         "CornflowerBlue"        : "0xFF6495ED",
         "Cornsilk"              : "0xFFFFF8DC",
         "Crimson"               : "0xFFDC143C",
         "Cyan"                  : "0xFF00FFFF",
         "DarkBlue"              : "0xFF00008B",
         "DarkCyan"              : "0xFF008B8B",
         "DarkGoldenRod"         : "0xFFB8860B",
         "DarkGray"              : "0xFFA9A9A9",
         "DarkGrey"              : "0xFFA9A9A9",
         "DarkGreen"             : "0xFF006400",
         "DarkKhaki"             : "0xFFBDB76B",
         "DarkMagenta"           : "0xFF8B008B",
         "DarkOliveGreen"        : "0xFF556B2F",
         "DarkOrange"            : "0xFFFF8C00",
         "DarkOrchid"            : "0xFF9932CC",
         "DarkRed"               : "0xFF8B0000",
         "DarkSalmon"            : "0xFFE9967A",
         "DarkSeaGreen"          : "0xFF8FBC8F",
         "DarkSlateBlue"         : "0xFF483D8B",
         "DarkSlateGray"         : "0xFF2F4F4F",
         "DarkSlateGrey"         : "0xFF2F4F4F",
         "DarkTurquoise"         : "0xFF00CED1",
         "DarkViolet"            : "0xFF9400D3",
         "DeepPink"              : "0xFFFF1493",
         "DeepSkyBlue"           : "0xFF00BFFF",
         "DimGray"               : "0xFF696969",
         "DimGrey"               : "0xFF696969",
         "DodgerBlue"            : "0xFF1E90FF",
         "FireBrick"             : "0xFFB22222",
         "FloralWhite"           : "0xFFFFFAF0",
         "ForestGreen"           : "0xFF228B22",
         "Fuchsia"               : "0xFFFF00FF",
         "Gainsboro"             : "0xFFDCDCDC",
         "GhostWhite"            : "0xFFF8F8FF",
         "Gold"                  : "0xFFFFD700",
         "GoldenRod"             : "0xFFDAA520",
         "Gray"                  : "0xFF808080",
         "Grey"                  : "0xFF808080",
         "Green"                 : "0xFF008000",
         "GreenYellow"           : "0xFFADFF2F",
         "HoneyDew"              : "0xFFF0FFF0",
         "HotPink"               : "0xFFFF69B4",
         "IndianRed"             : "0xFFCD5C5C",
         "Indigo"                : "0xFF4B0082",
         "Ivory"                 : "0xFFFFFFF0",
         "Khaki"                 : "0xFFF0E68C",
         "Lavender"              : "0xFFE6E6FA",
         "LavenderBlush"         : "0xFFFFF0F5",
         "LawnGreen"             : "0xFF7CFC00",
         "LemonChiffon"          : "0xFFFFFACD",
         "LightBlue"             : "0xFFADD8E6",
         "LightCoral"            : "0xFFF08080",
         "LightCyan"             : "0xFFE0FFFF",
         "LightGoldenRodYellow"  : "0xFFFAFAD2",
         "LightGray"             : "0xFFD3D3D3",
         "LightGrey"             : "0xFFD3D3D3",
         "LightGreen"            : "0xFF90EE90",
         "LightPink"             : "0xFFFFB6C1",
         "LightSalmon"           : "0xFFFFA07A",
         "LightSeaGreen"         : "0xFF20B2AA",
         "LightSkyBlue"          : "0xFF87CEFA",
         "LightSlateGray"        : "0xFF778899",
         "LightSlateGrey"        : "0xFF778899",
         "LightSteelBlue"        : "0xFFB0C4DE",
         "LightYellow"           : "0xFFFFFFE0",
         "Lime"                  : "0xFF00FF00",
         "LimeGreen"             : "0xFF32CD32",
         "Linen"                 : "0xFFFAF0E6"
      }
      )
      static colors2 :=
      ( LTrim Join
      {
         "Magenta"               : "0xFFFF00FF",
         "Maroon"                : "0xFF800000",
         "MediumAquaMarine"      : "0xFF66CDAA",
         "MediumBlue"            : "0xFF0000CD",
         "MediumOrchid"          : "0xFFBA55D3",
         "MediumPurple"          : "0xFF9370DB",
         "MediumSeaGreen"        : "0xFF3CB371",
         "MediumSlateBlue"       : "0xFF7B68EE",
         "MediumSpringGreen"     : "0xFF00FA9A",
         "MediumTurquoise"       : "0xFF48D1CC",
         "MediumVioletRed"       : "0xFFC71585",
         "MidnightBlue"          : "0xFF191970",
         "MintCream"             : "0xFFF5FFFA",
         "MistyRose"             : "0xFFFFE4E1",
         "Moccasin"              : "0xFFFFE4B5",
         "NavajoWhite"           : "0xFFFFDEAD",
         "Navy"                  : "0xFF000080",
         "OldLace"               : "0xFFFDF5E6",
         "Olive"                 : "0xFF808000",
         "OliveDrab"             : "0xFF6B8E23",
         "Orange"                : "0xFFFFA500",
         "OrangeRed"             : "0xFFFF4500",
         "Orchid"                : "0xFFDA70D6",
         "PaleGoldenRod"         : "0xFFEEE8AA",
         "PaleGreen"             : "0xFF98FB98",
         "PaleTurquoise"         : "0xFFAFEEEE",
         "PaleVioletRed"         : "0xFFDB7093",
         "PapayaWhip"            : "0xFFFFEFD5",
         "PeachPuff"             : "0xFFFFDAB9",
         "Peru"                  : "0xFFCD853F",
         "Pink"                  : "0xFFFFC0CB",
         "Plum"                  : "0xFFDDA0DD",
         "PowderBlue"            : "0xFFB0E0E6",
         "Purple"                : "0xFF800080",
         "RebeccaPurple"         : "0xFF663399",
         "Red"                   : "0xFFFF0000",
         "RosyBrown"             : "0xFFBC8F8F",
         "RoyalBlue"             : "0xFF4169E1",
         "SaddleBrown"           : "0xFF8B4513",
         "Salmon"                : "0xFFFA8072",
         "SandyBrown"            : "0xFFF4A460",
         "SeaGreen"              : "0xFF2E8B57",
         "SeaShell"              : "0xFFFFF5EE",
         "Sienna"                : "0xFFA0522D",
         "Silver"                : "0xFFC0C0C0",
         "SkyBlue"               : "0xFF87CEEB",
         "SlateBlue"             : "0xFF6A5ACD",
         "SlateGray"             : "0xFF708090",
         "SlateGrey"             : "0xFF708090",
         "Snow"                  : "0xFFFFFAFA",
         "SpringGreen"           : "0xFF00FF7F",
         "SteelBlue"             : "0xFF4682B4",
         "Tan"                   : "0xFFD2B48C",
         "Teal"                  : "0xFF008080",
         "Thistle"               : "0xFFD8BFD8",
         "Tomato"                : "0xFFFF6347",
         "Turquoise"             : "0xFF40E0D0",
         "Violet"                : "0xFFEE82EE",
         "Wheat"                 : "0xFFF5DEB3",
         "White"                 : "0xFFFFFFFF",
         "WhiteSmoke"            : "0xFFF5F5F5",
         "Yellow"                : "0xFFFFFF00",
         "YellowGreen"           : "0xFF9ACD32"
      }
      )
      return colors1.HasKey(c) ? colors1[c] : colors2.HasKey(c) ? colors2[c] : default
   }

   dropShadow(d, vw, vh, width, height, font_size) {
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\\\/\s:#%_a-z\-\.\d]+|\([\\\/\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
      static valid := "^\s*(-?((\d+(\.\d*)?)|(\.\d+)))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"
      vmin := Min(vw, vh)

      if IsObject(d) {
         d.base.__get := this.get ; Returns the empty string for unknown properties.
         d.1 := (d.horizontal != "") ? d.horizontal : (d.h != "") ? d.h : d.1
         d.2 := (d.vertical   != "") ? d.vertical   : (d.v != "") ? d.h : d.2
         d.3 := (d.blur       != "") ? d.blur       : (d.b != "") ? d.h : d.3
         d.4 := (d.color      != "") ? d.color      : (d.c != "") ? d.h : d.4
         d.5 := (d.opacity    != "") ? d.opacity    : (d.o != "") ? d.h : d.5
         d.6 := (d.size       != "") ? d.size       : (d.s != "") ? d.h : d.6
      } else if (d != "") {
         _ := RegExReplace(d, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.base.__get := this.get ; Returns the empty string for unknown properties.
         _.1 := ((___ := RegExReplace(d, q1    "(h(orizontal)?)"    q2, "${value}")) != d) ? ___ : _.1
         _.2 := ((___ := RegExReplace(d, q1    "(v(ertical)?)"      q2, "${value}")) != d) ? ___ : _.2
         _.3 := ((___ := RegExReplace(d, q1    "(b(lur)?)"          q2, "${value}")) != d) ? ___ : _.3
         _.4 := ((___ := RegExReplace(d, q1    "(c(olor)?)"         q2, "${value}")) != d) ? ___ : _.4
         _.5 := ((___ := RegExReplace(d, q1    "(o(pacity)?)"       q2, "${value}")) != d) ? ___ : _.5
         _.6 := ((___ := RegExReplace(d, q1    "(s(ize)?)"          q2, "${value}")) != d) ? ___ : _.6
         d := _
      }
      else {
         return {void:True, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0}
      }

      loop 6 {
         i := A_Index
         if (i = 4) ; Don't mess with color data.
            continue
         d[i] := (d[i] ~= valid) ? RegExReplace(d[i], "\s") : 0 ; Default for everything is 0.
         d[i] := (d[i] ~= "i)(pt|px)$") ? SubStr(d[i], 1, -2) : d[i]
         d[i] := (d[i] ~= "i)vw$") ? RegExReplace(d[i], "i)vw$") * vw : d[i]
         d[i] := (d[i] ~= "i)vh$") ? RegExReplace(d[i], "i)vh$") * vh : d[i]
         d[i] := (d[i] ~= "i)vmin$") ? RegExReplace(d[i], "i)vmin$") * vmin : d[i]
      }

      d.1 := (d.1 ~= "%$") ? RTrim(d.1, "%") * 0.01 * width : d.1
      d.2 := (d.2 ~= "%$") ? RTrim(d.2, "%") * 0.01 * height : d.2
      d.3 := (d.3 ~= "%$") ? RTrim(d.3, "%") * 0.01 * font_size : d.3
      d.4 := this.color(d.4, 0xFFFF0000) ; Default color is red.
      d.5 := (d.5 ~= "%$") ? RTrim(d.5, "%") / 100 : d.5
      d.5 := (d.5 <= 0 || d.5 > 1) ? 1 : d.5 ; Range Opacity is a float from 0-1.
      d.6 := (d.6 ~= "%$") ? RTrim(d.6, "%") * 0.01 * font_size : d.6

      return d
   }

   grayscale(sRGB) {
      static rY := 0.212655
      static gY := 0.715158
      static bY := 0.072187

      c1 := 255 & ( sRGB >> 16 )
      c2 := 255 & ( sRGB >> 8 )
      c3 := 255 & ( sRGB )

      loop 3 {
         c%A_Index% := c%A_Index% / 255
         c%A_Index% := (c%A_Index% <= 0.04045) ? c%A_Index%/12.92 : ((c%A_Index%+0.055)/(1.055))**2.4
      }

      v := rY*c1 + gY*c2 + bY*c3
      v := (v <= 0.0031308) ? v * 12.92 : 1.055*(v**(1.0/2.4))-0.055
      return Round(v*255)
   }

   margin_and_padding(m, vw, vh, default := "") {
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\\\/\s:#%_a-z\-\.\d]+|\([\\\/\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
      static valid := "^\s*(-?((\d+(\.\d*)?)|(\.\d+)))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"
      vmin := Min(vw, vh)

      if IsObject(m) {
         m.base.__get := this.get ; Returns the empty string for unknown properties.
         m.1 := (m.top    != "") ? m.top    : (m.t != "") ? m.t : m.1
         m.2 := (m.right  != "") ? m.right  : (m.r != "") ? m.r : m.2
         m.3 := (m.bottom != "") ? m.bottom : (m.b != "") ? m.b : m.3
         m.4 := (m.left   != "") ? m.left   : (m.l != "") ? m.l : m.4
      } else if (m != "") {
         _ := RegExReplace(m, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.base.__get := this.get ; Returns the empty string for unknown properties.
         _.1 := ((___ := RegExReplace(m, q1    "(t(op)?)"           q2, "${value}")) != m) ? ___ : _.1
         _.2 := ((___ := RegExReplace(m, q1    "(r(ight)?)"         q2, "${value}")) != m) ? ___ : _.2
         _.3 := ((___ := RegExReplace(m, q1    "(b(ottom)?)"        q2, "${value}")) != m) ? ___ : _.3
         _.4 := ((___ := RegExReplace(m, q1    "(l(eft)?)"          q2, "${value}")) != m) ? ___ : _.4
         m := _
      } else if (default != "") {
         m := [default, default, default, default]
         _.base.__get := this.get ; Returns the empty string for unknown properties.
      } else {
         return {void:True, 1:0, 2:0, 3:0, 4:0}
      }

      ; Follow CSS guidelines for margin!
      exception := False
      if (m.2 == "" && m.3 == "" && m.4 == "")
         m.4 := m.3 := m.2 := m.1, exception := True
      if (m.3 == "" && m.4 == "")
         m.4 := m.2, m.3 := m.1
      if (m.4 == "")
         m.4 := m.2

      loop 4 {
         i := A_Index
         m[i] := (m[i] ~= valid) ? RegExReplace(m[i], "\s") : default
         m[i] := (m[i] ~= "i)(pt|px)$") ? SubStr(m[i], 1, -2) : m[i]
         m[i] := (m[i] ~= "i)vw$") ? RegExReplace(m[i], "i)vw$") * vw : m[i]
         m[i] := (m[i] ~= "i)vh$") ? RegExReplace(m[i], "i)vh$") * vh : m[i]
         m[i] := (m[i] ~= "i)vmin$") ? RegExReplace(m[i], "i)vmin$") * vmin : m[i]
      }

      m.1 := (m.1 ~= "%$") ? RTrim(m.1, "%") * vh : m.1
      m.2 := (m.2 ~= "%$") ? RTrim(m.2, "%") * (exception ? vh : vw) : m.2
      m.3 := (m.3 ~= "%$") ? RTrim(m.3, "%") * vh : m.3
      m.4 := (m.4 ~= "%$") ? RTrim(m.4, "%") * (exception ? vh : vw) : m.4

      ; Convert Float to Integer
      loop 4
         if i := A_Index
            m[i] := Round(m[i])

      return m
   }

   outline(o, vw, vh, font_size, font_color) {
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\\\/\s:#%_a-z\-\.\d]+|\([\\\/\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
      static valid_positive := "^\s*((\d+(\.\d*)?)|(\.\d+))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"
      vmin := Min(vw, vh)

      if IsObject(o) {
         o.base.__get := this.get  ; Returns the empty string for unknown properties.
         o.1 := (o.stroke != "") ? o.stroke : (o.s != "") ? o.s : o.1
         o.2 := (o.color  != "") ? o.color  : (o.c != "") ? o.c : o.2
         o.3 := (o.glow   != "") ? o.glow   : (o.g != "") ? o.g : o.3
         o.4 := (o.tint   != "") ? o.tint   : (o.t != "") ? o.t : o.4
      } else if (o != "") {
         _ := RegExReplace(o, ":\s+", ":")
         _ := RegExReplace(_, "\s+", " ")
         _ := StrSplit(_, " ")
         _.base.__get := this.get ; Returns the empty string for unknown properties.
         _.1 := ((___ := RegExReplace(o, q1    "(s(troke)?)"        q2, "${value}")) != o) ? ___ : _.1
         _.2 := ((___ := RegExReplace(o, q1    "(c(olor)?)"         q2, "${value}")) != o) ? ___ : _.2
         _.3 := ((___ := RegExReplace(o, q1    "(g(low)?)"          q2, "${value}")) != o) ? ___ : _.3
         _.4 := ((___ := RegExReplace(o, q1    "(t(int)?)"          q2, "${value}")) != o) ? ___ : _.4
         o := _
      }
      else {
         return {void:True, 1:0, 2:0, 3:0, 4:0}
      }

      loop 4 {
         i := A_Index
         if (i = 2) || (i = 4) ; Don't mess with color data.
            continue
         o[i] := (o[i] ~= valid_positive) ? RegExReplace(o[i], "\s") : 0 ; Default for everything is 0.
         o[i] := (o[i] ~= "i)(pt|px)$") ? SubStr(o[i], 1, -2) : o[i]
         o[i] := (o[i] ~= "i)vw$") ? RegExReplace(o[i], "i)vw$") * vw : o[i]
         o[i] := (o[i] ~= "i)vh$") ? RegExReplace(o[i], "i)vh$") * vh : o[i]
         o[i] := (o[i] ~= "i)vmin$") ? RegExReplace(o[i], "i)vmin$") * vmin : o[i]
      }

      o.1 := (o.1 ~= "%$") ? RTrim(o.1, "%") * 0.01 * font_size : o.1
      o.2 := this.color(o.2, font_color) ; Default color is the text font color.
      o.3 := (o.3 ~= "%$") ? RTrim(o.3, "%") * 0.01 * font_size : o.3
      o.4 := this.color(o.4, o.2) ; Default color is outline color.

      return o
   }

   time(t) {
      static times := "(?i)^\s*((\d+(\.\d*)?)|\.\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
      t := (t ~= times) ? RegExReplace(t, "\s") : 0 ; Default time is zero.
      t := ((___ := RegExReplace(t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) != t) ? ___ *        1 : t
      t := ((___ := RegExReplace(t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) != t) ? ___ *     1000 : t
      t := ((___ := RegExReplace(t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) != t) ? ___ *    60000 : t
      t := ((___ := RegExReplace(t, "i)(\d+)h(our)?s?$"               , "$1")) != t) ? ___ *  3600000 : t
      t := ((___ := RegExReplace(t, "i)(\d+)d(ay)?s?$"                , "$1")) != t) ? ___ * 86400000 : t
      static MAX_INT := (A_PtrSize = 4) ? 2**31-1 : 2**63-1
      return (t >= 0) ? t : MAX_INT ; Check sign for integer overflow.
   }

   GaussianBlur(pBitmap, radius, opacity := 1) {
      static code := (A_PtrSize = 4)
         ? "
         ( LTrim                                    ; 32-bit machine code
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
         )" : "
         ( LTrim                                    ; 64-bit machine code
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

      ; Get width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width:=0)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height:=0)

      ; Create a buffer of raw 32-bit ARGB pixel data.
      VarSetCapacity(Rect, 16, 0)          ; sizeof(Rect) = 16
         NumPut(  width, Rect,  8, "uint") ; Width
         NumPut( height, Rect, 12, "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0) ; sizeof(BitmapData) = 24, 32
      DllCall("gdiplus\GdipBitmapLockBits", "ptr", pBitmap, "ptr", &Rect, "uint", 3, "int", 0x26200A, "ptr", &BitmapData)

      ; Get the Scan0 of the pixel data. Create a working buffer of the exact same size.
      stride := NumGet(BitmapData, 8, "int")
      Scan01 := NumGet(BitmapData, 16, "ptr")
      Scan02 := DllCall("GlobalAlloc", "uint", 0x40, "uptr", stride * height, "ptr")

      ; Call machine code function.
      DllCall("crypt32\CryptStringToBinary", "str", code, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size:=0, "ptr", 0, "ptr", 0)
      p := DllCall("GlobalAlloc", "uint", 0, "uptr", size, "ptr")
      DllCall("VirtualProtect", "ptr", p, "ptr", size, "uint", 0x40, "uint*", op) ; Allow execution from memory.
      DllCall("crypt32\CryptStringToBinary", "str", code, "uint", 0, "uint", 0x1, "ptr", p, "uint*", size, "ptr", 0, "ptr", 0)
      e := DllCall(p, "ptr", Scan01, "ptr", Scan02, "uint", width, "uint", height, "uint", 4, "uint", radius, "float", opacity)
      DllCall("GlobalFree", "ptr", p)

      ; Free resources.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)
      DllCall("GlobalFree", "ptr", Scan02)

      return e
   }

   MCode(mcode) {
      static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
      if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
         return
      if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
         return
      p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
      if (c="x64")
         DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
      if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
         return p
      DllCall("GlobalFree", "ptr", p)
   }

   ; Source: ImagePut 1.7.0 - WindowClass()
   WindowClass() {
      ; The window class shares the name of this class.
      cls := this.__class
      VarSetCapacity(wc, size := A_PtrSize = 4 ? 48:80) ; sizeof(WNDCLASSEX) = 48, 80

      ; Check if the window class is already registered.
      hInstance := DllCall("GetModuleHandle", "ptr", 0, "ptr")
      if DllCall("GetClassInfoEx", "ptr", hInstance, "str", cls, "ptr", &wc)
         return cls

      ; Create window data.
      pWndProc := RegisterCallback(this.WindowProc,,, &this)
      hCursor := DllCall("LoadCursor", "ptr", 0, "ptr", 32512, "ptr") ; IDC_ARROW
      hBrush := DllCall("GetStockObject", "int", 5, "ptr") ; Hollow_brush

      ; struct tagWNDCLASSEXA - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
      ; struct tagWNDCLASSEXW - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexw
      _ := (A_PtrSize = 4)
         NumPut(       size, wc,         0,   "uint") ; cbSize
         NumPut(        0x8, wc,         4,   "uint") ; style
         NumPut(   pWndProc, wc,         8,    "ptr") ; lpfnWndProc
         NumPut(          0, wc, _ ? 12:16,    "int") ; cbClsExtra
         NumPut(          0, wc, _ ? 16:20,    "int") ; cbWndExtra
         NumPut(          0, wc, _ ? 20:24,    "ptr") ; hInstance
         NumPut(          0, wc, _ ? 24:32,    "ptr") ; hIcon
         NumPut(    hCursor, wc, _ ? 28:40,    "ptr") ; hCursor
         NumPut(     hBrush, wc, _ ? 32:48,    "ptr") ; hbrBackground
         NumPut(          0, wc, _ ? 36:56,    "ptr") ; lpszMenuName
         NumPut(       &cls, wc, _ ? 40:64,    "ptr") ; lpszClassName
         NumPut(          0, wc, _ ? 44:72,    "ptr") ; hIconSm

      ; Registers a window class for subsequent use in calls to the CreateWindow or CreateWindowEx function.
      DllCall("RegisterClassEx", "ptr", &wc, "ushort")

      ; Return the class name as a string.
      return cls
   }
      ; Define window behavior.
      WindowProc(uMsg, wParam, lParam) {
         Critical ; Thread must never be interrupted.
         hwnd := this
         ; Retrieve "this" from a dictionary stored as hwnd:this.
         if !(this := TextRender.windows[hwnd])

            return DllCall("DefWindowProc", "ptr", hwnd, "uint", uMsg, "uptr", wParam, "ptr", lParam, "ptr")


         ; WM_DESTROY calls FreeMemory().
         if (uMsg = 0x2)
            return this.DestroyWindow()

         ; WM_DISPLAYCHANGE calls UpdateMemory() via Draw().
         if (uMsg = 0x7E) {
            DllCall("QueryPerformanceFrequency", "int64*", frequency:=0)
            DllCall("QueryPerformanceCounter", "int64*", end:=0)
            time_elapsed := (end - this.t0) / frequency * 1000
            remaining_time := this.t - time_elapsed
            if (this.t == 0 || remaining_time > 0) {
               for i, layer in this.layers
                  this.Draw(layer[1], layer[2], layer[3])
               this.UpdateLayeredWindow()
               this.flush_pending := True
               ; Create a timer that eventually clears the canvas.
               if (remaining_time > 0) {
                  ; Create a reference to the object held by a timer.
                  blank := ObjBindMethod(this, "blank", this.status) ; Calls Blank()
                  SetTimer % blank, % -remaining_time ; Calls __Delete.
               }
            }
         }

         ; Match window messages to Rainmeter event names.
         ; https://docs.rainmeter.net/manual/mouse-actions/
         static dict :=
         ( LTrim Join
         {
            WM_LBUTTONDOWN := 0x0201    : "LeftMouseDown",
            WM_LBUTTONUP := 0x0202      : "LeftMouseUp",
            WM_LBUTTONDBLCLK := 0x0203  : "LeftMouseDoubleClick",
            WM_RBUTTONDOWN := 0x0204    : "RightMouseDown",
            WM_RBUTTONUP := 0x0205      : "RightMouseUp",
            WM_RBUTTONDBLCLK := 0x0206  : "RightMouseDoubleClick",
            WM_MBUTTONDOWN := 0x0207    : "MiddleMouseDown",
            WM_MBUTTONUP := 0x0208      : "MiddleMouseUp",
            WM_MBUTTONDBLCLK := 0x0209  : "MiddleMouseDoubleClick",
            WM_MOUSEHOVER := 0x02A1     : "MouseOver",
            WM_MOUSELEAVE := 0x02A3     : "MouseLeave"
         }
         )

         ; Process windows messages by invoking the associated callback.
         for message, event in dict
            if (uMsg = message)
               try if callback := this.events[event]
                  return %callback%(this) ; Callbacks have a reference to "this".

         ; Default processing of window messages.
         return DllCall("DefWindowProc", "ptr", hwnd, "uint", uMsg, "uptr", wParam, "ptr", lParam, "ptr")
      }


   OnEvent(event, callback := "") {
      this.events[event] := callback
      return this
   }

   EventDestroyWindow() {
      this.DestroyWindow()
   }

   EventMoveWindow() {
      ; Allows the user to drag to reposition the window.
      DllCall("DefWindowProc", "ptr", this.hwnd, "uint", 0xA1, "uptr", 2, "ptr", 0, "ptr")
   }

   EventShowCoordinates() {
      ; Shows a bubble displaying the current window coordinates.
      if not ObjHasKey(this, "friend1") {
         this.friend1 := new TextRender(,,, this.hwnd)
         this.friend1.OnEvent("MiddleMouseDown")
      }

      ; Get position in screen coordinates.
      DllCall("GetCursorPos", "ptr", &point := VarSetCapacity(point, 8))
         , _x := NumGet(point, 0, "int")
         , _y := NumGet(point, 4, "int")
      WinGetPos x, y, w, h, % "ahk_id " this.hwnd
      coordinates := Format("x:{:5} w:{:5}`r`ny:{:5} h:{:5}", x, w, y, h)

      this.friend1.Render(coordinates
         , {t: 7000, r: "0.5vmin", x: _x+20, y: _y+20}
         , "s:1.5vmin f:(Consolas) o:(0.5) m:0.5vmin j:right")
      WinSet AlwaysOnTop, On, % "ahk_id" this.friend1.hwnd
   }

   EventCopyData() {
      ; Copies the rendered text to clipboard.
      if !this.friend2 {
         this.friend2 := new TextRender(,,, this.hwnd)
         this.friend2.OnEvent("MiddleMouseDown", "")
         this.friend2.OnEvent("RightMouseDown", "")
      }
      for i, layer in this.layers
         if data := layer[1]
            break
      clipboard := data
      this.friend2.Render("Saved text to clipboard.", "t:1250 c:#F9E486 y:75vh r:10%")
      WinSet AlwaysOnTop, On, % "ahk_id" this.friend2.hwnd
   }

   CreateWindow(title := "", style := 0x80000000, styleEx := 0x80088, parent := "") {
      ; Window Styles - https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles
      WS_POPUP                  := 0x80000000   ; Allow small windows.

      ; Extended Window Styles - https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
      WS_EX_TOPMOST             :=        0x8   ; Always on top.
      WS_EX_TOOLWINDOW          :=       0x80   ; Hides from Alt+Tab menu. Removes small icon.
      WS_EX_LAYERED             :=    0x80000   ; For UpdateLayeredWindow.

      ; Start off hidden with WS_VISIBLE off and zero width/height coordinates.
      return DllCall("CreateWindowEx"
               ,   "uint", styleEx                  ; dwExStyle
               ,    "str", this.WindowClass()       ; lpClassName
               ,    "str", title                    ; lpWindowName
               ,   "uint", style                    ; dwStyle
               ,    "int", 0                        ; X
               ,    "int", 0                        ; Y
               ,    "int", 0                        ; nWidth
               ,    "int", 0                        ; nHeight
               ,    "ptr", (parent != "") ? parent : A_ScriptHwnd
               ,    "ptr", 0                        ; hMenu
               ,    "ptr", 0                        ; hInstance
               ,    "ptr", 0                        ; lpParam
               ,    "ptr")
   }

   ; Duality #2 - Destroys a window.
   DestroyWindow() {
      if (!this.hwnd)
         return this

      this.FreeMemory()
      DllCall("DestroyWindow", "ptr", this.hwnd)
      this.hwnd := ""
      return this
   }

   ; Duality #3 - Allocates the memory buffer.
   LoadMemory() {
      width := this.BitmapWidth, height := this.BitmapHeight

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
         NumPut(       40, bi,  0,   "uint") ; Size
         NumPut(    width, bi,  4,   "uint") ; Width
         NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         NumPut(        1, bi, 12, "ushort") ; Planes
         NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")
      gfx := DllCall("gdiplus\GdipCreateFromHDC", "ptr", hdc, "ptr*", gfx:=0, "int") ? False : gfx
      DllCall("gdiplus\GdipTranslateWorldTransform", "ptr", gfx, "float", -this.BitmapLeft, "float", -this.BitmapTop, "int", 0)

      this.hdc := hdc
      this.hbm := hbm
      this.obm := obm
      this.gfx := gfx
      this.ptr := pBits
      this.size := 4 * width * height

      return this
   }

   ; Duality #3 - Frees the memory buffer.
   FreeMemory() {
      if (!this.hdc)
         return this

      DllCall("gdiplus\GdipDeleteGraphics", "ptr", this.gfx)
      DllCall("SelectObject", "ptr", this.hdc, "ptr", this.obm)
      DllCall("DeleteObject", "ptr", this.hbm)
      DllCall("DeleteDC",     "ptr", this.hdc)
      this.gfx := this.obm := this.hbm := this.hdc := ""

      ; Allow subsequent calls to UpdateMemory() to call LoadMemory()
      this.BitmapWidth := ""
      this.BitmapHeight := ""
      this.BitmapLeft := ""
      this.BitmapTop := ""
      this.BitmapRight := ""
      this.BitmapBottom := ""
      return this
   }

   UpdateMemory() {
      ; Get true virtual screen coordinates.
      dpi := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
      sx := DllCall("GetSystemMetrics", "int", 76, "int")
      sy := DllCall("GetSystemMetrics", "int", 77, "int")
      sw := DllCall("GetSystemMetrics", "int", 78, "int")
      sh := DllCall("GetSystemMetrics", "int", 79, "int")
      DllCall("SetThreadDpiAwarenessContext", "ptr", dpi, "ptr")

      if (sw = this.BitmapWidth && sh = this.BitmapHeight)
         return this

      ; Deletes bitmap coordinates.
      this.FreeMemory()

      ; Sets bitmap coordinates.
      this.BitmapLeft := sx
      this.BitmapTop := sy
      this.BitmapRight := sx + sw
      this.BitmapBottom := sy + sh
      this.BitmapWidth := sw
      this.BitmapHeight := sh
      this.LoadMemory()

      return this
   }

   DebugMemory() {
      x := this.WindowLeft
      y := this.WindowTop
      w := Round(this.WindowWidth)
      h := Round(this.WindowHeight)

      ; Allocate buffer.
      VarSetCapacity(buffer, 4 * w * h, 0)

      ; Create a Bitmap with 32-bit pre-multiplied ARGB. (Owned by this object!)
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", this.BitmapWidth, "int", this.BitmapHeight
         , "uint", 4 * this.BitmapWidth, "uint", 0xE200B, "ptr", this.ptr, "ptr*", pBitmap:=0)

      ; Specify that only a cropped bitmap portion will be copied.
      VarSetCapacity(Rect, 16, 0)            ; sizeof(Rect) = 16
         NumPut(      x, Rect,  0,    "int") ; X
         NumPut(      y, Rect,  4,    "int") ; Y
         NumPut(      w, Rect,  8,   "uint") ; Width
         NumPut(      h, Rect, 12,   "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0) ; sizeof(BitmapData) = 24, 32
         NumPut(    4*w, BitmapData,  8,    "int")  ; Stride
         NumPut(&buffer, BitmapData, 16,    "ptr")  ; Scan0

      ; Convert pARGB to ARGB using a writable buffer created by LockBits.
      DllCall("gdiplus\GdipBitmapLockBits"
               ,    "ptr", pBitmap
               ,    "ptr", &Rect
               ,   "uint", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
               ,    "int", 0x26200A     ; Format32bppArgb
               ,    "ptr", &BitmapData) ; Contains the buffer.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

      ; Release reference to pBits.
      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

      ; Draw an enlarged pixel grid layout with printed color hexes.
      loop % h {
      _h := A_Index-1
         if _h*70 > A_ScreenHeight * 3
            break
      loop % w {
      _w := A_Index-1
         if _w*70 > A_ScreenWidth * 2
            continue
         formula := _h*w + _w
         pixel := Format("{:08X}", NumGet(buffer, 4*formula, "uint"))
         text := RegExReplace(pixel, "(.{4})(.{4})", "$1`r`n$2")
         this.Draw(text, "x" _w*70 " y"  70*(_h) " w70 h70 m0 c" pixel, "s:24pt v:center")
      }
      }

      ; Calling RenderOnScreen() is rather slow as every redraw happens again.
      this.RenderOnScreen()

      ; Note that this is a slow function in general. I'm not entirely sure how it can be sped up.
      return this
   }

   Hash() {
      return Format("{:08x}", DllCall("ntdll\RtlComputeCrc32", "uint", 0, "ptr", this.ptr, "uptr", this.size, "uint"))
   }

   CopyToBuffer() {
      ; Allocate buffer.
      buffer := DllCall("GlobalAlloc", "uint", 0, "uptr", 4 * this.w * this.h, "ptr")

      ; Create a Bitmap with 32-bit pre-multiplied ARGB. (Owned by this object!)
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", this.BitmapWidth, "int", this.BitmapHeight
         , "uint", 4 * this.BitmapWidth, "uint", 0xE200B, "ptr", this.ptr, "ptr*", pBitmap:=0)

      ; Crop the bitmap.
      VarSetCapacity(Rect, 16, 0)            ; sizeof(Rect) = 16
         NumPut( this.x, Rect,  0,    "int") ; X
         NumPut( this.y, Rect,  4,    "int") ; Y
         NumPut( this.w, Rect,  8,   "uint") ; Width
         NumPut( this.h, Rect, 12,   "uint") ; Height
      VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)   ; sizeof(BitmapData) = 24, 32
         NumPut(  4*this.w, BitmapData,  8,    "int") ; Stride
         NumPut(    buffer, BitmapData, 16,    "ptr") ; Scan0

      ; Use LockBits to create a writable buffer that converts pARGB to ARGB.
      DllCall("gdiplus\GdipBitmapLockBits"
               ,    "ptr", pBitmap
               ,    "ptr", &Rect
               ,   "uint", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
               ,    "int", 0x26200A     ; Format32bppArgb
               ,    "ptr", &BitmapData) ; Contains the buffer.
      DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

      return buffer
   }

   CopyToHBitmap() {
      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
         NumPut(       40, bi,  0,   "uint") ; Size
         NumPut(   this.w, bi,  4,   "uint") ; Width
         NumPut(  -this.h, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         NumPut(        1, bi, 12, "ushort") ; Planes
         NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      DllCall("gdi32\BitBlt"
               , "ptr", hdc, "int", 0, "int", 0, "int", this.w, "int", this.h
               , "ptr", this.hdc, "int", this.x, "int", this.y, "uint", 0x00CC0020) ; SRCCOPY

      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteDC",     "ptr", hdc)

      return hbm
   }

   RenderToHBitmap() {
      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
         NumPut(       40, bi,  0,   "uint") ; Size
         NumPut(   this.w, bi,  4,   "uint") ; Width
         NumPut(  -this.h, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         NumPut(        1, bi, 12, "ushort") ; Planes
         NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")
      gfx := DllCall("gdiplus\GdipCreateFromHDC", "ptr", hdc, "ptr*", gfx:=0, "int") ? False : gfx

      ; Set the origin to this.x and this.y
      DllCall("gdiplus\GdipTranslateWorldTransform", "ptr", gfx, "float", -this.x, "float", -this.y, "int", 0)

      for i, layer in this.layers
         this.DrawOnGraphics(gfx, layer[1], layer[2], layer[3], this.BitmapWidth, this.BitmapHeight)

      DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteDC",     "ptr", hdc)

      return hbm
   }

   CopyToBitmap() {
      ; Create a Bitmap with 32-bit pre-multiplied ARGB. (Owned by this object!)
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", this.BitmapWidth, "int", this.BitmapHeight
         , "uint", 4 * this.BitmapWidth, "uint", 0xE200B, "ptr", this.ptr, "ptr*", pBitmap:=0)

      ; Crop to fit and convert to 32-bit ARGB. (Managed impartially by GDI+)
      DllCall("gdiplus\GdipCloneBitmapAreaI", "int", this.x, "int", this.y, "int", this.w, "int", this.h
         , "uint", 0x26200A, "ptr", pBitmap, "ptr*", pBitmapCrop:=0)

      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

      return pBitmapCrop
   }

   RenderToBitmap() {
      DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", this.w, "int", this.h
         , "uint", 0, "uint", 0x26200A, "ptr", 0, "ptr*", pBitmap:=0)
      DllCall("gdiplus\GdipGetImageGraphicsContext", "ptr", pBitmap, "ptr*", gfx:=0)
      DllCall("gdiplus\GdipTranslateWorldTransform", "ptr", gfx, "float", -this.x, "float", -this.y, "int", 0)
      for i, layer in this.layers
         this.DrawOnGraphics(gfx, layer[1], layer[2], layer[3], this.BitmapWidth, this.BitmapHeight)
      DllCall("gdiplus\GdipDeleteGraphics", "ptr", gfx)
      return pBitmap
   }

   Save(filename := "", quality := "") {
      pBitmap := this.InBounds() ? this.CopyToBitmap() : this.RenderToBitmap()
      filepath := this.SaveImageToFile(pBitmap, filename, quality)
      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
      return filepath
   }

   Screenshot(filename := "", quality := "") {
      pBitmap := this.GetImageFromScreen([this.x, this.y, this.w, this.h])
      filepath := this.SaveImageToFile(pBitmap, filename, quality)
      DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
      return filepath
   }

   ; Source: ImagePut 1.7 - put_file()
   SaveImageToFile(pBitmap, filepath := "", quality := "") {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517
      extension := "png"

      ; Save default extension.
      default := extension

      ; Split the filepath, convert forward slashes, strip invalid chars.
      filepath := RegExReplace(filepath, "/", "\")
      filepath := RegExReplace(filepath, "[*?\x22<>|\x00-\x1F]")
      SplitPath % filepath,, directory, extension, filename

      ; Check if the entire filepath is a directory.
      if InStr(FileExist(filepath), "D")   ; If the filepath refers to a directory,
         directory := (directory != "")    ; then SplitPath wrongly assumes a directory to be a filename.
            ? ((filename != "")
               ? directory "\" filename    ; Combine directory + filename.
               : directory)                ; Do nothing.
            : (filepath ~= "^\\")
               ? "\" filename              ; Root level directory.
               : ".\" filename             ; Script level directory.
         , filename := ""

      ; Create a new directory if needed.
      if (directory != "" && !InStr(FileExist(directory), "D"))
         FileCreateDir % directory

      ; Default directory is a dot.
      (directory == "") && directory := "."

      ; Check if the filename is actually the extension.
      if (extension == "" && filename ~= "^(?i:bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$")
         extension := filename, filename := ""

      ; An invalid extension is actually part of the filename.
      if !(extension ~= "^(?i:bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") {
         ; Avoid appending an extra period without an extension.
         if (extension != "")
            filename .= "." extension

         ; Restore default extension.
         extension := default
      }

      ; Create a filepath based on the timestamp.
      if (filename == "") {
         FormatTime, filename,, % "yyyy-MM-dd HH꞉mm꞉ss"
         filepath := directory "\" filename "." extension
         while FileExist(filepath)
            filepath := directory "\" filename " (" A_Index ")." extension
      }

      ; Create a numeric sequence of files...
      else if (filename == "0" or filename == "1") {
         filepath := directory "\" filename "." extension
         while FileExist(filepath)
            filepath := directory "\" A_Index "." extension
      }

      ; Always overwrite specific filenames.
      else filepath := directory "\" filename "." extension

      ; Fill a buffer with the available image codec info.
      DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", count:=0, "uint*", size:=0)
      DllCall("gdiplus\GdipGetImageEncoders", "uint", count, "uint", size, "ptr", &ci := VarSetCapacity(ci, size))

      ; struct ImageCodecInfo - http://www.jose.it-berater.org/gdiplus/reference/structures/imagecodecinfo.htm
      loop {
         if (A_Index > count)
            throw Exception("Could not find a matching encoder for the specified file format.")

         idx := (48+7*A_PtrSize)*(A_Index-1)
      } until InStr(StrGet(NumGet(ci, idx+32+3*A_PtrSize, "ptr"), "UTF-16"), extension) ; FilenameExtension

      ; Get the pointer to the clsid of the matching encoder.
      pCodec := &ci + idx ; ClassID

      ; JPEG default quality is 75. Otherwise set a quality value from [0-100].
      if (quality ~= "^-?\d+$") and ("image/jpeg" = StrGet(NumGet(ci, idx+32+4*A_PtrSize, "ptr"), "UTF-16")) { ; MimeType
         ; Use a separate buffer to store the quality as ValueTypeLong (4).
         VarSetCapacity(v, 4), NumPut(quality, v, "uint")

         ; struct EncoderParameter - http://www.jose.it-berater.org/gdiplus/reference/structures/encoderparameter.htm
         ; enum ValueType - https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.encoderparametervaluetype
         ; clsid Image Encoder Constants - http://www.jose.it-berater.org/gdiplus/reference/constants/gdipimageencoderconstants.htm
         VarSetCapacity(ep, 24+2*A_PtrSize)            ; sizeof(EncoderParameter) = ptr + n*(28, 32)
            NumPut(    1, ep,            0,   "uptr")  ; Count
            DllCall("ole32\CLSIDFromString", "wstr", "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}", "ptr", &ep+A_PtrSize, "uint")
            NumPut(    1, ep, 16+A_PtrSize,   "uint")  ; Number of Values
            NumPut(    4, ep, 20+A_PtrSize,   "uint")  ; Type
            NumPut(   &v, ep, 24+A_PtrSize,    "ptr")  ; Value
      }

      ; Write the file to disk using the specified encoder and encoding parameters with exponential backoff.
      loop
         if !DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "wstr", filepath, "ptr", pCodec, "ptr", (ep) ? &ep : 0)
            break
         else
            if A_Index < 6
               Sleep (2**(A_Index-1) * 30)
            else throw Exception("Could not save file to disk.")

      return filepath
   }

   ; Source: ImagePut 1.7.0 - from_screenshot()
   GetImageFromScreen(image) {
      ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

      ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
      hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
      VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
         NumPut(       40, bi,  0,   "uint") ; Size
         NumPut( image[3], bi,  4,   "uint") ; Width
         NumPut(-image[4], bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
         NumPut(        1, bi, 12, "ushort") ; Planes
         NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
      hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
      obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

      ; Retrieve the device context for the screen.
      sdc := DllCall("GetDC", "ptr", 0, "ptr")

      ; Copies a portion of the screen to a new device context.
      DllCall("gdi32\BitBlt"
               , "ptr", hdc, "int", 0, "int", 0, "int", image[3], "int", image[4]
               , "ptr", sdc, "int", image[1], "int", image[2], "uint", 0x00CC0020 | 0x40000000) ; SRCCOPY | CAPTUREBLT

      ; Release the device context to the screen.
      DllCall("ReleaseDC", "ptr", 0, "ptr", sdc)

      ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
      DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap:=0)

      ; Cleanup the hBitmap and device contexts.
      DllCall("SelectObject", "ptr", hdc, "ptr", obm)
      DllCall("DeleteObject", "ptr", hbm)
      DllCall("DeleteDC",     "ptr", hdc)

      return pBitmap
   }

   UpdateLayeredWindow(alpha := 255) {
      ; If width and height are unset or zero, blank the canvas.
      if (!this.w || !this.h) {
         return DllCall("UpdateLayeredWindow"
                  ,    "ptr", this.hwnd                ; hWnd
                  ,    "ptr", 0                        ; hdcDst
                  ,    "ptr", 0                        ; *pptDst
                  ,    "ptr", 0                        ; *psize
                  ,    "ptr", 0                        ; hdcSrc
                  ,    "ptr", 0                        ; *pptSrc
                  ,   "uint", 0                        ; crKey
                  ,  "uint*", 0 << 16 | 0x01 << 24     ; *pblend
                  ,   "uint", 2                        ; dwFlags
                  ,    "int")                          ; Success = 1
      }

      ; Define the smaller of canvas and bitmap coordinates.
      x  := this.WindowLeft   := Max(this.BitmapLeft, this.x)
      y  := this.WindowTop    := Max(this.BitmapTop, this.y)
      x2 := this.WindowRight  := Min(this.BitmapRight, this.x2)
      y2 := this.WindowBottom := Min(this.BitmapBottom, this.y2)
      w  := this.WindowWidth  := this.WindowRight - this.WindowLeft
      h  := this.WindowHeight := this.WindowBottom - this.WindowTop

      ; Changing x, y, w, h to be stationary does not provide a speed boost.
      ; Nor does making the window opaque.
      return DllCall("UpdateLayeredWindow"
               ,    "ptr", this.hwnd                ; hWnd
               ,    "ptr", 0                        ; hdcDst
               ,"uint64*", x | y << 32              ; *pptDst
               ,"uint64*", w | h << 32              ; *psize
               ,    "ptr", this.hdc                 ; hdcSrc
               ,"uint64*", x - this.BitmapLeft
                        |  y - this.BitmapTop << 32 ; *pptSrc
               ,   "uint", 0                        ; crKey
               ,  "uint*", alpha << 16 | 0x01 << 24 ; *pblend
               ,   "uint", 2                        ; dwFlags
               ,    "int")                          ; Success = 1
   }

   InBounds() { ; Check if canvas coordinates are inside bitmap coordinates.
      return this.x >= this.BitmapLeft
         and this.y >= this.BitmapTop
         and this.x2 <= this.BitmapRight
         and this.y2 <= this.BitmapBottom
   }

   Bounds(default := "") {
      return (this.x2 > this.x && this.y2 > this.y) ? [this.x, this.y, this.x2, this.y2] : default
   }

   Rect(default := "") {
      return (this.x2 > this.x && this.y2 > this.y) ? [this.x, this.y, this.w, this.h] : default
   }

   ; All references to gdiplus and pToken must be absolute!
   static gdiplus := 0, pToken := 0

   gdiplusStartup() {
      TextRender.gdiplus++

      ; Startup gdiplus when counter goes from 0 -> 1.
      if (TextRender.gdiplus == 1) {

         ; Startup gdiplus.
         DllCall("LoadLibrary", "str", "gdiplus")
         VarSetCapacity(si, A_PtrSize = 4 ? 16:24, 0) ; sizeof(GdiplusStartupInput) = 16, 24
            , NumPut(0x1, si, "uint")
         DllCall("gdiplus\GdiplusStartup", "ptr*", pToken:=0, "ptr", &si, "ptr", 0)

         TextRender.pToken := pToken
      }
   }

   gdiplusShutdown(cotype := "", pBitmap := "") {
      TextRender.gdiplus--

      ; When a buffer object is deleted a bitmap is sent here for disposal.
      if (cotype == "smart_pointer")
         if DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
            throw Exception("The bitmap of this buffer object has already been deleted.")

      ; Check for unpaired calls of gdiplusShutdown.
      ; if (TextRender.gdiplus < 0)
      ;    throw Exception("Missing TextRender.gdiplusStartup().")

      ; Shutdown gdiplus when counter goes from 1 -> 0.
      if (TextRender.gdiplus == 0) {
         pToken := TextRender.pToken

         ; Shutdown gdiplus.
         DllCall("gdiplus\GdiplusShutdown", "ptr", pToken)
         DllCall("FreeLibrary", "ptr", DllCall("GetModuleHandle", "str", "gdiplus", "ptr"))

         ; Exit if GDI+ is still loaded. GdiplusNotInitialized = 18
         if (18 != DllCall("gdiplus\GdipCreateImageAttributes", "ptr*", ImageAttr:=0)) {
            DllCall("gdiplus\GdipDisposeImageAttributes", "ptr", ImageAttr)
            return
         }

         ; Otherwise GDI+ has been truly unloaded from the script and objects are out of scope.
         if (cotype = "bitmap")
            throw Exception("Out of scope error. `n`nIf you wish to handle raw pointers to GDI+ bitmaps, add the line"
               . "`n`n`t`t" this.__class ".gdiplusStartup()`n`nor 'pToken := Gdip_Startup()' to the top of your script."
               . "`nAlternatively, use 'obj := ImagePutBuffer()' with 'obj.pBitmap'."
               . "`nYou can copy this message by pressing Ctrl + C.")
      }
   }
} ; End of TextRender class.


TextRenderDesktop(text:="", background_style:="", text_style:="") {
   static WS_CHILD := (A_OSVersion = "WIN_7") ? 0x80000000 : 0x40000000 ; Fallback to WS_POPUP for Win 7.
   static WS_EX_LAYERED := 0x80000

   ; Used to show the desktop creations immediately.
   ; Post-Creator's Update Windows 10. WM_SPAWN_WORKER = 0x052C
   DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0xD, "ptr", 0)
   DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0xD, "ptr", 1)

   hwndParent := WinExist("ahk_class Progman")
   return (new TextRender(, WS_CHILD, WS_EX_LAYERED, hwndParent)).Render(text, background_style, text_style)
}

TextRenderWallpaper(text:="", background_style:="", text_style:="") {
   static WS_CHILD := (A_OSVersion = "WIN_7") ? 0x80000000 : 0x40000000 ; Fallback to WS_POPUP for Win 7.
   static WS_EX_LAYERED := 0x80000

   ; Post-Creator's Update Windows 10. WM_SPAWN_WORKER = 0x052C
   DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0xD, "ptr", 0)
   DllCall("SendMessage", "ptr", WinExist("ahk_class Progman"), "uint", 0x052C, "ptr", 0xD, "ptr", 1)

   ; Find a child window of class SHELLDLL_DefView.
   WinGet windows, List, ahk_class WorkerW
   Loop % windows
      hwnd := windows%A_Index%
   until DllCall("FindWindowEx", "ptr", hwnd, "ptr", 0, "str", "SHELLDLL_DefView", "ptr", 0)

   ; Find a child window of the desktop after the previous window of class WorkerW.
   if !(WorkerW := DllCall("FindWindowEx", "ptr", 0, "ptr", hwnd, "str", "WorkerW", "ptr", 0, "ptr"))
      throw Exception("Could not locate hidden window behind desktop icons.")

   return (new TextRender(, WS_CHILD, WS_EX_LAYERED, WorkerW)).Render(text, background_style, text_style)
}


ImageRender(image:="", style:="", polygons:="") {
   return (new ImageRender).Render(image, style, polygons)
}

class ImageRender extends TextRender {

   DrawOnGraphics(gfx, image := "", style := "", polygons := "", CanvasWidth := "", CanvasHeight := "") {

      ; Requires the ImagePut class for full features.
      if (image != "") {
         if ImagePut {
            try type := ImagePut.DontVerifyImageType(image)
            catch
               type := ImagePut.ImageType(image)
            pBitmap := ImagePut.ToBitmap(type, image)
         }

         ; Assume a pointer to a bitmap is passed.
         else {
            DllCall("gdiplus\GdipGetImageType", "ptr", image, "ptr*", type:=0)
            if (type != 1)
               throw Exception("Invalid pointer to a GDI+ bitmap.`n`nPlease #include ImagePut.ahk in the script.", -3)
            pBitmap := image
         }
      }

      ; Get default width and height from undocumented graphics pointer offset.
      (CanvasWidth == "") && CanvasWidth := NumGet(gfx + 20 + A_PtrSize, "uint")
      (CanvasHeight == "") && CanvasHeight := NumGet(gfx + 24 + A_PtrSize, "uint")

      ; RegEx help? https://regex101.com/r/rNsP6n/1
      static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
      static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\\\/\s:#%_a-z\-\.\d]+|\([\\\/\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

      ; Extract styles to variables.
      if IsObject(style) {
         t  := (style.time != "")        ? style.time        : style.t
         a  := (style.anchor != "")      ? style.anchor      : style.a
         x  := (style.left != "")        ? style.left        : style.x
         y  := (style.top != "")         ? style.top         : style.y
         w  := (style.width != "")       ? style.width       : style.w
         h  := (style.height != "")      ? style.height      : style.h
         m  := (style.margin != "")      ? style.margin      : style.m
         s  := (style.scale != "")       ? style.scale       : style.s
         c  := (style.color != "")       ? style.color       : style.c
         k  := (style.key != "")         ? style.key         : style.k
         q  := (style.quality != "")     ? style.quality     : (style.q) ? style.q : style.InterpolationMode
      } else {
         RegExReplace(style, "\s+", A_Space) ; Limit whitespace for fixed width look-behinds.
         t  := ((___ := RegExReplace(style, q1    "(t(ime)?)"          q2, "${value}")) != style) ? ___ : ""
         a  := ((___ := RegExReplace(style, q1    "(a(nchor)?)"        q2, "${value}")) != style) ? ___ : ""
         x  := ((___ := RegExReplace(style, q1    "(x|left)"           q2, "${value}")) != style) ? ___ : ""
         y  := ((___ := RegExReplace(style, q1    "(y|top)"            q2, "${value}")) != style) ? ___ : ""
         w  := ((___ := RegExReplace(style, q1    "(w(idth)?)"         q2, "${value}")) != style) ? ___ : ""
         h  := ((___ := RegExReplace(style, q1    "(h(eight)?)"        q2, "${value}")) != style) ? ___ : ""
         m  := ((___ := RegExReplace(style, q1    "(m(argin)?)"        q2, "${value}")) != style) ? ___ : ""
         s  := ((___ := RegExReplace(style, q1    "(s(cale)?)"         q2, "${value}")) != style) ? ___ : ""
         c  := ((___ := RegExReplace(style, q1    "(c(olor)?)"         q2, "${value}")) != style) ? ___ : ""
         k  := ((___ := RegExReplace(style, q1    "(k(ey)?)"           q2, "${value}")) != style) ? ___ : ""
         q  := ((___ := RegExReplace(style, q1    "(q(uality)?)"       q2, "${value}")) != style) ? ___ : ""
      }

      ; These are the type checkers.
      static valid := "^\s*(-?((\d+(\.\d*)?)|(\.\d+)))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"
      static valid_positive := "^\s*((\d+(\.\d*)?)|(\.\d+))\s*(?i:%|pt|px|vh|vmin|vw)?\s*$"

      ; Define viewport width and height. This is the visible screen area.
      vw := 0.01 * CanvasWidth         ; 1% of viewport width.
      vh := 0.01 * CanvasHeight        ; 1% of viewport height.
      vmin := Min(vw, vh)              ; 1vw or 1vh, whichever is smaller.
      vr := CanvasWidth / CanvasHeight ; Aspect ratio of the viewport.

      ; Get original image width and height.
      DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", width:=0)
      DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", height:=0)
      minimum := Min(width, height)
      aspect := width / height

      ; Get width and height.
      w  := ( w ~= valid_positive) ? RegExReplace( w, "\s") : ""
      w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
      w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$") * vw :  w
      w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$") * vh :  w
      w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$") * vmin :  w
      w  := ( w ~= "%$") ? RegExReplace( w, "%$") * 0.01 * width :  w

      h  := ( h ~= valid_positive) ? RegExReplace( h, "\s") : ""
      h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
      h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$") * vw :  h
      h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$") * vh :  h
      h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$") * vmin :  h
      h  := ( h ~= "%$") ? RegExReplace( h, "%$") * 0.01 * height :  h

      ; Default width and height.
      if (w == "" && h == "")
         w := width, h := height, wh_unset := True
      if (w == "")
         w := h * aspect
      if (h == "")
         h := w / aspect

      ; If scale is "fill" scale the image until there are no empty spaces but two sides of the image are cut off.
      ; If scale is "fit" scale the image so that the greatest edge will fit with empty borders along one edge.
      ; If scale is "harmonic" automatically downscale by the harmonic series. Ex: 50%, 33%, 25%, 20%...
      if (s = "auto" || s = "fill" || s = "fit" || s = "harmonic" || s = "limit") {
         if (wh_unset == True)
            w := CanvasWidth, h := CanvasHeight
         s := (s = "auto" || s = "limit")
            ? ((aspect > w / h) ? ((width > w) ? w / width : 1) : ((height > h) ? h / height : 1)) : s
         s := (s = "fill") ? ((aspect < w / h) ? w / width : h / height) : s
         s := (s = "fit") ? ((aspect > w / h) ? w / width : h / height) : s
         s := (s = "harmonic") ? ((aspect > w / h) ? 1 / (width // w + 1) : 1 / (height // h + 1)) : s
         w := width  ; width and height given were maximum values, not actual values.
         h := height ; Therefore restore the width and height to the image width and height.
      }

      s  := ( s ~= valid) ? RegExReplace( s, "\s") : ""
      s  := ( s ~= "i)(pt|px)$") ? SubStr( s, 1, -2) :  s
      s  := ( s ~= "i)vw$") ? RegExReplace( s, "i)vw$") * vw / width :  s
      s  := ( s ~= "i)vh$") ? RegExReplace( s, "i)vh$") * vh / height:  s
      s  := ( s ~= "i)vmin$") ? RegExReplace( s, "i)vmin$") * vmin / minimum :  s
      s  := ( s ~= "%$") ? RegExReplace( s, "%$") * 0.01 :  s

      ; If scale is negative automatically scale by a geometric series constant.
      ; Example: If scale is -0.5, then downscale by 50%, 25%, 12.5%, 6.25%...
      ; What the equation is asking is how many powers of -1/s can we fit in width/w?
      ; Then we use floor division and add 1 to ensure that we never exceed the bounds.
      ; While this is only designed to handle negative scales from 0 to -1.0,
      ; it works for negative numbers higher than -1.0. In this case, the 0 to -1 bounded
      ; are the left adjoint, meaning they never surpass the w and h. Higher negative Numbers
      ; are the right adjoint, meaning they never surpass w*-s and h*-s. Weird, huh.
      ; To clarify: Left adjoint: w*-s to w, h*-s to h. Right adjoint: w to w*-s, h to h*-s
      ; LaTex: \frac{1}{\frac{-1}{s}^{Floor(\frac{log(x)}{log(\frac{-1}{s})}) + 1}}
      ; Vertical asymptote at s := -1, which resolves to the empty string "".
      if (s < 0 && s != "") {
         if (wh_unset == True)
            w := CanvasWidth, h := CanvasHeight
         s := (s < 0) ? ((aspect > w / h)
            ? (-s) ** ((log(width/w) // log(-1/s)) + 1) : (-s) ** ((log(height/h) // log(-1/s)) + 1)) : s
         w := width  ; width and height given were maximum values, not actual values.
         h := height ; Therefore restore the width and height to the image width and height.
      }

      ; Default scale.
      if (s == "") {
         s := (x == "" && y == "" && wh_unset == True)         ; shrink image if x,y,w,h,s are all unset.
            ? ((aspect > vr)                                   ; determine whether width or height exceeds screen.
               ? ((width > CanvasWidth) ? CanvasWidth / width : 1)       ; scale will downscale image by its width.
               : ((height > CanvasHeight) ? CanvasHeight / height : 1))  ; scale will downscale image by its height.
            : 1                                                ; Default scale is 1.00.
      }

      ; Scale width and height.
      w  := w * s
      h  := h * s

      ; Get anchor. This is where the origin of the image is located.
      a  := RegExReplace( a, "\s")
      a  := (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
         : (a ~= "i)top" && a ~= "i)right") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
         : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 6 : (a ~= "i)bottom" && a ~= "i)left") ? 7
         : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8 : (a ~= "i)bottom" && a ~= "i)right") ? 9
         : (a ~= "i)top") ? 2 : (a ~= "i)left") ? 4 : (a ~= "i)right") ? 6 : (a ~= "i)bottom") ? 8
         : (a ~= "i)cent(er|re)") ? 5 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

      ; The anchor can be implied and overwritten by x and y (left, center, right, top, bottom).
      a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
      a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

      ; Convert English words to numbers. Don't mess with these values any further.
      x  := ( x ~= "i)left") ? 0 : (x ~= "i)cent(er|re)") ? 0.5*CanvasWidth : (x ~= "i)right") ? CanvasWidth : x
      y  := ( y ~= "i)top") ? 0 : (y ~= "i)cent(er|re)") ? 0.5*CanvasHeight : (y ~= "i)bottom") ? CanvasHeight : y

      ; Get x and y.
      x  := ( x ~= valid) ? RegExReplace( x, "\s") : ""
      x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
      x  := ( x ~= "i)(%|vw)$") ? RegExReplace( x, "i)(%|vw)$") * vw :  x
      x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$") * vh :  x
      x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$") * vmin :  x

      y  := ( y ~= valid) ? RegExReplace( y, "\s") : ""
      y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
      y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$") * vw :  y
      y  := ( y ~= "i)(%|vh)$") ? RegExReplace( y, "i)(%|vh)$") * vh :  y
      y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$") * vmin :  y

      ; Default x and y.
      if (x == "")
         x := 0.5*CanvasWidth, a := 2+((( a-1)//3)*3)
      if (y == "")
         y := 0.5*CanvasHeight, a := 4+(mod( a-1,3))

      ; Modify x and y values with the anchor, so that the image has a new point of origin.
      x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
      y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

      ; Prevent half-pixel rendering and keep image sharp.
      w  := Round(x + w) - Round(x)    ; Use real x2 coordinate to determine width.
      h  := Round(y + h) - Round(y)    ; Use real y2 coordinate to determine height.
      x  := Round(x)                   ; NOTE: simple Floor(w) or Round(w) will NOT work.
      y  := Round(y)                   ; The float values need to be added up and then rounded!

      ; Get margin.
      m  := this.margin_and_padding(m, vw, vh)

      ; Calculate border using margin.
      _w := w + m.2 + m.4
      _h := h + m.1 + m.3
      _x := x - m.4
      _y := y - m.1

      ; Save original Graphics settings.
      DllCall("gdiplus\GdipSaveGraphics", "ptr", gfx, "ptr*", pState:=0)

      ; Set some general Graphics settings.
      DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",gfx, "int",2) ; Half pixel offset.
      DllCall("gdiplus\GdipSetCompositingMode",    "ptr",gfx, "int",1) ; Overwrite/SourceCopy.
      DllCall("gdiplus\GdipSetCompositingQuality", "ptr",gfx, "int",0) ; AssumeLinear
      DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",gfx, "int",0) ; No anti-alias.
      DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",gfx, "int",7) ; HighQualityBicubic

      ; Begin drawing the image onto the canvas.
      if (pBitmap != "") {

         ; Draw background if color or margin is set.
         if (c != "" || !m.void) {
            c := this.color(c, 0xDD212121) ; Default color is transparent gray.
            if (c & 0xFF000000) {
               DllCall("gdiplus\GdipSetSmoothingMode", "ptr", gfx, "int", 0) ; SmoothingModeNoAntiAlias
               DllCall("gdiplus\GdipCreateSolidFill", "uint", c, "ptr*", pBrush:=0)
               DllCall("gdiplus\GdipFillRectangle", "ptr", gfx, "ptr", pBrush, "float", _x, "float", _y, "float", _w, "float", _h) ; DRAWING!
               DllCall("gdiplus\GdipDeleteBrush", "ptr", pBrush)
            }
         }

         ; Draw image using GDI.
         if (q = 0 || w == width && h == height) {
            ; Get a read-only device context associated with the Graphics object.
            DllCall("gdiplus\GdipGetDC", "ptr", gfx, "ptr*", ddc:=0)

            ; Allocate a top-down device independent bitmap (hbm) by inputting a negative height.
            ; Outputs a pointer to the pixel data. Select the new handle to a bitmap onto the cloned
            ; compatible device context. The old bitmap (obm) is a monochrome 1x1 default bitmap that
            ; will be reselected onto the device context (hdc) before deletion.
            ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
            hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
            VarSetCapacity(bi, 40, 0)              ; sizeof(bi) = 40
               NumPut(       40, bi,  0,   "uint") ; Size
               NumPut(    width, bi,  4,   "uint") ; Width
               NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
               NumPut(        1, bi, 12, "ushort") ; Planes
               NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
            hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
            obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

            ; The following routine is 4ms faster than hbm := Gdip_CreateHBITMAPFromBitmap(pBitmap).
            ; In the below code we do something really interesting to save a call of memcpy().
            ; When calling LockBits the third argument is set to 0x4 (ImageLockModeUserInputBuf).
            ; This means that we can use the pointer to the bits from our memory bitmap (DIB)
            ; as the Scan0 of the LockBits output. While this is not a speed up, this saves memory
            ; because we are (1) allocating a DIB, (2) getting a pBitmap, (3) using a LockBits buffer.
            ; Instead of LockBits creating a new buffer, we can use the allocated buffer from (1).
            ; The bottleneck in the code is LockBits(), which takes over 20 ms for a 1920 x 1080 image.
            ; https://stackoverflow.com/questions/6782489/create-bitmap-from-a-byte-array-of-pixel-data
            ; https://stackoverflow.com/questions/17030264/read-and-write-directly-to-unlocked-bitmap-unmanaged-memory-scan0
            VarSetCapacity(Rect, 16, 0)              ; sizeof(Rect) = 16
               NumPut(    width, Rect,  8,   "uint") ; Width
               NumPut(   height, Rect, 12,   "uint") ; Height
            VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
               NumPut(   4 * width, BitmapData,  8,    "int") ; Stride
               NumPut(       pBits, BitmapData, 16,    "ptr") ; Scan0
            DllCall("gdiplus\GdipBitmapLockBits"
                     ,    "ptr", pBitmap
                     ,    "ptr", &Rect
                     ,   "uint", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
                     ,    "int", 0xE200B      ; Format32bppPArgb
                     ,    "ptr", &BitmapData)
            DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", &BitmapData)

            ; A good question to ask is why don't we use the pBits already associated with the graphics hdc?
            ; One, if a Graphics object associated to a pBitmap via Gdip_GraphicsFromImage() is passed,
            ; there would be no underlying device independent bitmap, and thus no pBits at all!
            ; Two, since the size of the allocated DIB is not the same size as the underlying DIB,
            ; injection using x,y,w,h coordinates is required, and BitBlt supports this.
            ; Note: The Rect in LockBits is crops the image source and does not affect the destination.

            ; Make a color transparent if the color key option is specified.
            if (k != "") {
               static colorkey
               if !(colorkey)
                  colorkey := this.MCode("2,x86:VjHSU4tMJBQxwA+vTCQQi3QkDItcJBiFyXUO6yKNdgCDwAE5yInCdBaNFJY5GnXwg8ABOcjHAgAAAACJwnXquAEAAABbXsM=,x64:QQ+v0IXSdCeD6gFIjUSRBOsJSIPBBEg5wXQURDkJdfLHAQAAAABIg8EESDnBdey4AQAAAMM=")
               k := this.color(k, NumGet(pBits+0, "uint")) ; Default key is top-left pixel.
               DllCall(colorkey, "ptr", pBits, "uint", width, "uint", height, "uint", k)
            }

            (c != "" || !m.void) ; Check if color or margin is set to invoke AlphaBlend, otherwise BitBlt.

            ; AlphaBlend() does not overwrite the underlying pixels.
            ? DllCall("msimg32\AlphaBlend"
                     , "ptr", ddc, "int", x, "int", y, "int", w    , "int", h
                     , "ptr", hdc, "int", 0, "int", 0, "int", width, "int", height
                     , "uint", 0xFF << 16 | 0x01 << 24) ; BlendFunction

            ; BitBlt() is the fastest operation for copying pixels.
            : DllCall("gdi32\StretchBlt"
                     , "ptr", ddc, "int", x, "int", y, "int", w    , "int", h
                     , "ptr", hdc, "int", 0, "int", 0, "int", width, "int", height
                     , "uint", 0x00CC0020) ; SRCCOPY

            DllCall("SelectObject", "ptr", hdc, "ptr", obm)
            DllCall("DeleteObject", "ptr", hbm)
            DllCall("DeleteDC",     "ptr", hdc)

            DllCall("gdiplus\GdipReleaseDC", "ptr", gfx, "ptr", ddc)
         }

         ; Draw image scaled to a new width and height.
         else {
            ; Set InterpolationMode.
            q := (q >= 0 && q <= 7) ? q : 7    ; HighQualityBicubic

            DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr", gfx, "int", 2) ; Half pixel offset.
            DllCall("gdiplus\GdipSetCompositingMode",    "ptr", gfx, "int", 1) ; Overwrite/SourceCopy.
            DllCall("gdiplus\GdipSetSmoothingMode",      "ptr", gfx, "int", 0) ; No anti-alias.
            DllCall("gdiplus\GdipSetInterpolationMode",  "ptr", gfx, "int", q)
            DllCall("gdiplus\GdipSetCompositingQuality", "ptr", gfx, "int", 0) ; AssumeLinear

            ; Draw image with proper edges and scaling.
            DllCall("gdiplus\GdipCreateImageAttributes", "ptr*", ImageAttr)

            ; Make a color transparent if the color key option is specified.
            if (k != "") {
               DllCall("gdiplus\GdipBitmapGetPixel", "ptr", pBitmap, "int", 0, "int", 0, "uint*", k_default)
               k := this.color(k, k_default) ; Default key is top-left pixel.
               DllCall("gdiplus\GdipSetImageAttributesColorKeys", "ptr", ImageAttr, "int", 0, "int", 1, "uint", k, "uint", k)
            }

            DllCall("gdiplus\GdipSetImageAttributesWrapMode", "ptr", ImageAttr, "int", 3) ; WrapModeTileFlipXY
            DllCall("gdiplus\GdipDrawImageRectRectI"
                     ,    "ptr", gfx
                     ,    "ptr", pBitmap
                     ,    "int", x, "int", y, "int", w    , "int", h      ; destination rectangle
                     ,    "int", 0, "int", 0, "int", width, "int", height ; source rectangle
                     ,    "int", 2                                        ; UnitTypePixel
                     ,    "ptr", ImageAttr                                ; imageAttributes
                     ,    "ptr", 0                                        ; callback
                     ,    "ptr", 0)                                       ; callbackData
            DllCall("gdiplus\GdipDisposeImageAttributes", "ptr", ImageAttr)
         }
      }

      ; Begin drawing the polygons onto the canvas.
      if (polygons != "") {
         DllCall("gdiplus\GdipSetPixelOffsetMode",   "ptr",gfx, "int",0) ; No pixel offset.
         DllCall("gdiplus\GdipSetCompositingMode",   "ptr",gfx, "int",1) ; Overwrite/SourceCopy.
         DllCall("gdiplus\GdipSetSmoothingMode",     "ptr",gfx, "int",2) ; Use anti-alias.

         DllCall("gdiplus\GdipCreatePen1", "uint", 0xFFFF0000, "float", 1, "int", 2, "ptr*", pPen:=0)

         for i, polygon in polygons {
            DllCall("gdiplus\GdipCreatePath", "int",1, "ptr*",pPath)
            VarSetCapacity(pointf, 8*polygons[i].polygon.maxIndex(), 0)
            for j, point in polygons[i].polygon {
               NumPut(point.x*s + x, pointf, 8*(A_Index-1) + 0, "float")
               NumPut(point.y*s + y, pointf, 8*(A_Index-1) + 4, "float")
            }
            DllCall("gdiplus\GdipAddPathPolygon", "ptr",pPath, "ptr",&pointf, "uint",polygons[i].polygon.maxIndex())
            DllCall("gdiplus\GdipDrawPath", "ptr",gfx, "ptr",pPen, "ptr",pPath) ; DRAWING!
         }

         DllCall("gdiplus\GdipDeletePen", "ptr", pPen)
      }

      ; Restore original Graphics settings.
      DllCall("gdiplus\GdipRestoreGraphics", "ptr", gfx, "ptr", pState)

      ; Define bounds.
      t_bound := this.time(t)
      x_bound := _x
      y_bound := _y
      w_bound := _w
      h_bound := _h

      return {t: t_bound
            , x: x_bound
            , y: y_bound
            , w: w_bound
            , h: h_bound
            , x2: x_bound + w_bound
            , y2: y_bound + h_bound}
   }
} ; End of ImageRender class.


; |‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
; | Double click TextRender.ahk or .exe to show GUI. |
; |__________________________________________________|
if (A_LineFile == A_ScriptFullPath) {
   MsgBox % "TextRender GUI is currently available only on AutoHotkey v2."
}
